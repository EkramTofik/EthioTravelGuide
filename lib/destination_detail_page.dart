import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'map_screen.dart';

class DestinationDetailPage extends StatefulWidget {
  final String destinationId;

  const DestinationDetailPage({Key? key, required this.destinationId})
    : super(key: key);

  @override
  State<DestinationDetailPage> createState() => _DestinationDetailPageState();
}

class _DestinationDetailPageState extends State<DestinationDetailPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _hotelsKey = GlobalKey();

  late final Future<DocumentSnapshot<Map<String, dynamic>>> _destinationFuture;

  bool _saved = false;
  bool _saving = false;

  bool _isRatingSubmitting = false;
  double? _userRating;
  double? _overrideRating;
  int? _overrideRatingCount;

  @override
  void initState() {
    super.initState();
    _destinationFuture = FirebaseFirestore.instance
        .collection('destinations')
        .doc(widget.destinationId)
        .get();
    _checkSaved();
    _loadUserRating();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> _checkSaved() async {
    final uid = _uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('savedDestinations')
        .doc(widget.destinationId)
        .get();
    if (mounted) setState(() => _saved = doc.exists);
  }

  Future<void> _loadUserRating() async {
    final uid = _uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('destinations')
        .doc(widget.destinationId)
        .collection('ratings')
        .doc(uid)
        .get();
    if (doc.exists) {
      final r = _asDouble(doc.data()?['rating']);
      if (mounted) setState(() => _userRating = r?.clamp(1.0, 5.0));
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _hotelsStream() {
    return FirebaseFirestore.instance
        .collection('destinations')
        .doc(widget.destinationId)
        .collection('hotels')
        .snapshots();
  }

  double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String _asString(dynamic value) => value?.toString() ?? '';

  Future<void> _scrollToHotels() async {
    final ctx = _hotelsKey.currentContext;
    if (ctx != null) {
      await Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _lockAndRestoreScroll(double? offset) {
    if (offset == null || !_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final target = offset.clamp(0, max).toDouble();

    _scrollController.jumpTo(target);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final maxAgain = _scrollController.position.maxScrollExtent;
        final targetAgain = target.clamp(0, maxAgain).toDouble();
        _scrollController.jumpTo(targetAgain);
      }
    });
  }

  Future<void> _openMapScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapScreen()),
    );
  }

  Future<void> _submitRating(double value) async {
    if (_isRatingSubmitting) return;

    final uid = _uid;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please sign in to rate.')));
      return;
    }

    final boundedValue = value.clamp(1.0, 5.0);
    final wantsRemove =
        _userRating != null && (_userRating! - boundedValue).abs() < 1e-6;
    final savedOffset = _scrollController.hasClients
        ? _scrollController.offset
        : null;
    final previousUserRating = _userRating;

    setState(() {
      _isRatingSubmitting = true;
      _userRating = wantsRemove ? null : boundedValue;
    });

    final docRef = FirebaseFirestore.instance
        .collection('destinations')
        .doc(widget.destinationId);
    final userRatingRef = docRef.collection('ratings').doc(uid);

    try {
      final result = await FirebaseFirestore.instance.runTransaction((
        txn,
      ) async {
        final snap = await txn.get(docRef);
        final userSnap = await txn.get(userRatingRef);

        final data = snap.data() ?? {};
        final currentRating = _asDouble(data['rating']) ?? 0.0;
        final currentCount = _asInt(data['ratingCount']) ?? 0;
        final currentTotal = currentRating * currentCount;

        if (userSnap.exists) {
          final u = userSnap.data() ?? {};
          final prev = _asDouble(u['rating']) ?? boundedValue;

          if (wantsRemove) {
            final newCount = currentCount > 0 ? currentCount - 1 : 0;
            final newTotal = currentTotal - prev;
            final newAvg = newCount > 0 ? newTotal / newCount : 0.0;
            txn.update(docRef, {
              'rating': newAvg.clamp(0.0, 5.0),
              'ratingCount': newCount,
            });
            txn.delete(userRatingRef);
            return {'rating': newAvg, 'count': newCount, 'cleared': true};
          } else {
            final newTotal = currentTotal - prev + boundedValue;
            final newAvg = currentCount > 0
                ? newTotal / currentCount
                : boundedValue;
            txn.update(docRef, {
              'rating': newAvg.clamp(0.0, 5.0),
              'ratingCount': currentCount,
            });
            txn.update(userRatingRef, {
              'rating': boundedValue,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            return {'rating': newAvg, 'count': currentCount, 'cleared': false};
          }
        } else {
          // first time rating
          final newCount = currentCount + 1;
          final newTotal = currentTotal + boundedValue;
          final newAvg = newTotal / newCount;
          txn.update(docRef, {
            'rating': newAvg.clamp(0.0, 5.0),
            'ratingCount': newCount,
          });
          txn.set(userRatingRef, {
            'rating': boundedValue,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          return {'rating': newAvg, 'count': newCount, 'cleared': false};
        }
      });

      if (mounted) {
        final cleared = (result['cleared'] as bool?) ?? false;
        setState(() {
          _isRatingSubmitting = false;
          _userRating = cleared ? null : _userRating;
          _overrideRating = (result['rating'] as num).toDouble().clamp(
            0.0,
            5.0,
          );
          _overrideRatingCount = (result['count'] as num).toInt();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRatingSubmitting = false;
          _userRating = previousUserRating;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not submit rating: $e')));
      }
    } finally {
      _lockAndRestoreScroll(savedOffset);
    }
  }

  Future<void> _toggleSave({
    required String title,
    required String imageUrl,
    required String category,
    required double rating,
    required String description,
    required String coords,
  }) async {
    if (_saving) return;
    final uid = _uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to save destinations.')),
      );
      return;
    }
    setState(() => _saving = true);
    final docRef = FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('savedDestinations')
        .doc(widget.destinationId);
    try {
      if (_saved) {
        await docRef.delete();
        if (mounted) setState(() => _saved = false);
      } else {
        await docRef.set({
          'id': widget.destinationId,
          'title': title,
          'imageUrl': imageUrl,
          'category': category,
          'region': category,
          'rating': rating,
          'description': description,
          'coords': coords,
          'savedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        if (mounted) setState(() => _saved = true);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not update saved: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Palette.page,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _Palette.page,
        foregroundColor: _Palette.text,
        title: const Text('Destination'),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _destinationFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load destination.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Destination not found.'));
          }

          final data = snapshot.data!.data() ?? {};
          final title = _asString(
            data['title'] ?? data['name'] ?? widget.destinationId,
          );
          final description = _asString(
            data['description'] ?? data['story'] ?? '',
          );
          final category = _asString(data['category']);
          final badge = _asString(data['badge']);
          final coords = _asString(data['coords']);
          final entryFee = _asString(data['entryFee']);
          final cultural = _asString(data['culturalSignificance']);
          final history = _asString(data['historicalBackground']);
          final duration = _asString(data['duration']);
          final visitors = _asString(data['visitors']);
          final bestTime = _asString(data['bestTime']);
          final visitorTips = data['visitorTips'] is List
              ? (data['visitorTips'] as List).map(_asString).toList()
              : <String>[];
          final imageUrl = _asString(
            data['imageUrl'] ??
                data['heroImage'] ??
                data['thumbnail'] ??
                data['image'] ??
                'https://via.placeholder.com/800x500?text=Destination',
          );
          final rawRating =
              _overrideRating ??
              _asDouble(data['rating'] ?? data['averageRating']) ??
              4.5;
          final rating = rawRating.clamp(0.0, 5.0).toDouble();
          final ratingCount =
              _overrideRatingCount ?? _asInt(data['ratingCount']) ?? 1;

          return SingleChildScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroBlock(
                  title: title,
                  category: category,
                  badge: badge,
                  coords: coords,
                  rating: rating,
                  imageUrl: imageUrl,
                  onMap: _openMapScreen,
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ActionRow(
                    saved: _saved,
                    onMap: _openMapScreen,
                    onHotels: _scrollToHotels,
                    onSave: () => _toggleSave(
                      title: title,
                      imageUrl: imageUrl,
                      category: category,
                      rating: rating,
                      description: description,
                      coords: coords,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _InfoGrid(
                    duration: duration,
                    entryFee: entryFee,
                    visitors: visitors,
                    rating: rating,
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _TextCard(
                        title: 'About This Place',
                        body: description.isNotEmpty
                            ? description
                            : 'Discover this destination in Ethiopia.',
                      ),
                      const SizedBox(height: 12),
                      _TextCard(
                        title: 'Historical Background',
                        body: history.isNotEmpty
                            ? history
                            : 'History will be added soon.',
                      ),
                      const SizedBox(height: 12),
                      _TextCard(
                        title: 'Cultural Significance',
                        body: cultural.isNotEmpty
                            ? cultural
                            : 'Cultural notes will be added soon.',
                      ),
                      const SizedBox(height: 12),
                      _TextCard(
                        title: 'Best Time to Visit',
                        body: bestTime.isNotEmpty
                            ? bestTime
                            : 'Visit during the dry season for clearer skies and better access.',
                      ),
                      const SizedBox(height: 12),
                      _TipsCard(
                        tips: visitorTips.isNotEmpty
                            ? visitorTips
                            : const [
                                'Hire a local guide for deeper context.',
                                'Wear comfortable shoes for uneven terrain.',
                                'Bring sunscreen and water; shade may be limited.',
                                'Respect religious ceremonies and customs.',
                              ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  key: _hotelsKey,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _HotelsSection(
                    stream: _hotelsStream(),
                    asString: _asString,
                    asDouble: _asDouble,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _RatingCard(
                    rating: rating,
                    ratingCount: ratingCount,
                    submitting: _isRatingSubmitting,
                    userRating: _userRating,
                    onRate: _submitRating,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroBlock extends StatelessWidget {
  final String title;
  final String category;
  final String badge;
  final String coords;
  final double rating;
  final String imageUrl;
  final VoidCallback onMap;

  const _HeroBlock({
    required this.title,
    required this.category,
    required this.badge,
    required this.coords,
    required this.rating,
    required this.imageUrl,
    required this.onMap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Image.asset('assets/images/images3.jpg', fit: BoxFit.cover),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC000000),
                  Color(0x66000000),
                  Color(0x99000000),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (badge.isNotEmpty)
                  _Pill(label: badge, color: _Palette.orange),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                    ),
                    _RatingChip(rating: rating),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  category.isNotEmpty ? category : 'Ethiopia',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                if (coords.isNotEmpty)
                  GestureDetector(
                    onTap: onMap,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.place,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          coords,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final VoidCallback onMap;
  final VoidCallback onHotels;
  final VoidCallback onSave;
  final bool saved;

  const _ActionRow({
    required this.onMap,
    required this.onHotels,
    required this.onSave,
    required this.saved,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionButton(icon: Icons.map_outlined, label: 'Map', onTap: onMap),
        const SizedBox(width: 8),
        _ActionButton(
          icon: Icons.hotel_outlined,
          label: 'Hotels',
          onTap: onHotels,
          color: _Palette.blue,
        ),
        const SizedBox(width: 8),
        _ActionButton(
          icon: saved ? Icons.favorite : Icons.favorite_border,
          label: saved ? 'Saved' : 'Save',
          onTap: onSave,
          color: _Palette.orange,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = _Palette.blueSoft,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final String duration;
  final String entryFee;
  final String visitors;
  final double rating;

  const _InfoGrid({
    required this.duration,
    required this.entryFee,
    required this.visitors,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double gutter = 14;
        final double cardWidth = (constraints.maxWidth - gutter) / 2;
        return Wrap(
          spacing: gutter,
          runSpacing: 16,
          children: [
            _InfoCard(
              width: cardWidth,
              icon: Icons.timer_outlined,
              iconColor: _Palette.purple,
              title: 'Duration',
              value: duration.isNotEmpty ? duration : 'Full Day (6-8 hours)',
            ),
            _InfoCard(
              width: cardWidth,
              icon: Icons.attach_money_rounded,
              iconColor: _Palette.red,
              title: 'Entry Fee',
              value: entryFee.isNotEmpty ? entryFee : 'See local rates',
            ),
            _InfoCard(
              width: cardWidth,
              icon: Icons.person_outline,
              iconColor: _Palette.purple,
              title: 'Visitors',
              value: visitors.isNotEmpty ? visitors : 'Popular annually',
            ),
            _InfoCard(
              width: cardWidth,
              icon: Icons.star_border_rounded,
              iconColor: _Palette.red,
              title: 'Rating',
              value: '${rating.toStringAsFixed(1)}/5',
            ),
          ],
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _InfoCard({
    required this.width,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        constraints: const BoxConstraints(minHeight: 160),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _Palette.cardBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: _Palette.deepText,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: _Palette.deepText,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextCard extends StatelessWidget {
  final String title;
  final String body;

  const _TextCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _Palette.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: _Palette.blue, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: _Palette.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              color: _Palette.muted,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  final List<String> tips;

  const _TipsCard({required this.tips});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _Palette.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.tips_and_updates_outlined,
                color: _Palette.blue,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Visitor Tips',
                style: TextStyle(
                  color: _Palette.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...tips.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _Palette.blue,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${e.key + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e.value,
                      style: const TextStyle(
                        color: _Palette.muted,
                        fontSize: 13,
                        height: 1.32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HotelsSection extends StatelessWidget {
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final String Function(dynamic) asString;
  final double? Function(dynamic) asDouble;

  const _HotelsSection({
    required this.stream,
    required this.asString,
    required this.asDouble,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            CircleAvatar(radius: 10, backgroundColor: _Palette.blue),
            SizedBox(width: 8),
            Text(
              'Nearby Accommodations',
              style: TextStyle(
                color: _Palette.text,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: stream,
          builder: (context, snap) {
            if (snap.hasError) {
              return const Text(
                'Could not load hotels.',
                style: TextStyle(color: _Palette.orange),
              );
            }
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Text(
                'No hotels listed yet.',
                style: TextStyle(color: _Palette.muted),
              );
            }
            return Column(
              children: docs.map((doc) {
                final h = doc.data();
                final name = asString(h['name']);
                final distance = asString(h['distance']);
                final price = asString(h['price']);
                final hotelRating = (asDouble(h['rating']) ?? 4.3)
                    .clamp(0.0, 5.0)
                    .toDouble();
                final image = asString(h['imageUrl'] ?? '');
                final imageToUse = image.isNotEmpty
                    ? image
                    : 'https://via.placeholder.com/400x250?text=Hotel';
                final List perks = (h['perks'] is List)
                    ? h['perks']
                    : <dynamic>[];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _HotelCard(
                    name: name.isNotEmpty ? name : 'Hotel',
                    distance: distance,
                    price: price,
                    rating: hotelRating,
                    imageUrl: imageToUse,
                    perks: perks.map(asString).toList(),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _HotelCard extends StatelessWidget {
  final String name;
  final String distance;
  final String price;
  final double rating;
  final String imageUrl;
  final List<String> perks;

  const _HotelCard({
    required this.name,
    required this.distance,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.perks,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _Palette.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Image.network(
              imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 150,
                color: _Palette.cardBorder,
                alignment: Alignment.center,
                child: const Text('No image'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: _Palette.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _RatingChip(rating: rating),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  distance.isNotEmpty ? distance : 'Nearby',
                  style: const TextStyle(color: _Palette.muted, fontSize: 12),
                ),
                const SizedBox(height: 8),
                if (perks.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: perks
                        .map(
                          (p) => _MiniChip(
                            label: p,
                            color: _Palette.blueSoft,
                            textColor: Colors.white,
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 10),
                Text(
                  price.isNotEmpty ? price : 'Price on request',
                  style: const TextStyle(
                    color: _Palette.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  final double rating;
  final int ratingCount;
  final bool submitting;
  final double? userRating;
  final ValueChanged<double> onRate;

  const _RatingCard({
    required this.rating,
    required this.ratingCount,
    required this.submitting,
    required this.userRating,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final cappedRating = rating.clamp(0.0, 5.0).toDouble();
    final label = ratingCount > 0
        ? '${cappedRating.toStringAsFixed(1)} (${ratingCount == 1 ? "1 rating" : "$ratingCount ratings"})'
        : 'No ratings yet';
    final highlight = (userRating ?? 0.0)
        .clamp(0.0, 5.0)
        .toDouble(); // starts empty

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _Palette.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.star_border_rounded, color: _Palette.red, size: 28),
              SizedBox(width: 10),
              Text(
                'Rate This Destination',
                style: TextStyle(
                  color: _Palette.deepText,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (i) {
              final starValue = i + 1.0;
              final filled = highlight >= starValue;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: submitting ? null : () => onRate(starValue),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_border_rounded,
                    color: _Palette.red,
                    size: 26,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.star_rounded, color: _Palette.orange, size: 20),
              const SizedBox(width: 6),
              Text(
                submitting ? 'Submitting...' : label,
                style: const TextStyle(
                  color: _Palette.deepText,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Thank you for rating!\nYou can update your rating anytime.',
            style: TextStyle(
              color: _Palette.deepText,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPage extends StatelessWidget {
  final String title;
  final String coords;

  const _MapPage({required this.title, required this.coords});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          coords.isNotEmpty
              ? 'Map view for $coords'
              : 'No coordinates available for this destination.',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 6)],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  final double rating;

  const _RatingChip({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 6)],
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 16),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: _Palette.text,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _MiniChip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _Palette {
  static const page = Color(0xFFF6F7FB);
  static const text = Color(0xFF1F1F2C);
  static const deepText = Color(0xFF2C2C6A);
  static const muted = Color(0xFF6F7380);
  static const blue = Color(0xFF2463EB);
  static const blueSoft = Color(0xFF6FA8FF);
  static const purple = Color(0xFF5B5AF1);
  static const red = Color(0xFFF64F59);
  static const orange = Color(0xFFF36D3A);
  static const cardBorder = Color(0xFFE4E6EC);
}
