import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'destination_detail_page.dart';
import 'map_screen.dart';
import 'places_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  static const _brandBlue = Color(0xFF5179BA);
  static const _buttonBlue = Color(0xFF2B60B6);
  static const _orange = Color(0xFFF36D3A);
  static const _bg = Color(0xFFF7F7F7);
  static const _dark = Color(0xFF1F1F1F);
  static const _muted = Color(0xFF6A6A6A);
  static const _cardBorder = Color(0xFFE8E8E8);
  static const _softBadge = Color(0xFFEDE8F7);
  static const _red = Color(0xFFF64F59);

  Stream<QuerySnapshot<Map<String, dynamic>>> _savedStream(String uid) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('savedDestinations')
        .orderBy('savedAt', descending: true)
        .snapshots();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _fetchLegacySaved(
    String uid,
  ) async {
    final snap = await FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('saved')
        .orderBy('savedAt', descending: true)
        .get();
    return snap.docs;
  }

  Future<void> _deleteSaved(
    String uid,
    String id, {
    bool legacy = false,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(uid)
          .collection(legacy ? 'saved' : 'savedDestinations')
          .doc(id)
          .delete();
      await _incrementSavedCount(uid, -1);
    } catch (_) {
      // ignore counter errors
    }
  }

  Future<void> _setSavedCount(String uid, int count) async {
    try {
      await FirebaseFirestore.instance.collection('user').doc(uid).set({
        'savedCount': count,
      }, SetOptions(merge: true));
    } catch (_) {
      // ignore counter errors
    }
  }

  Future<void> _incrementSavedCount(String uid, int delta) async {
    try {
      await FirebaseFirestore.instance.collection('user').doc(uid).set({
        'savedCount': FieldValue.increment(delta),
      }, SetOptions(merge: true));
    } catch (_) {
      // ignore counter errors
    }
  }

  void _openDetails(BuildContext context, String destinationId) {
    if (destinationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Destination details unavailable')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DestinationDetailPage(destinationId: destinationId),
      ),
    );
  }

  String _formatDate(dynamic ts) {
    DateTime? dt;
    if (ts is Timestamp) dt = ts.toDate();
    if (ts is int) dt = DateTime.fromMillisecondsSinceEpoch(ts);
    if (ts is String) dt = DateTime.tryParse(ts);
    if (dt == null) return '';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Widget _buildList(
    BuildContext context,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    String uid, {
    required bool legacy,
  }) {
    final count = docs.length;
    _setSavedCount(uid, count); // keep savedCount in user doc

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Header(total: count),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
          child: Column(
            children: [
              if (count == 0)
                const _EmptyState()
              else
                ...List.generate(docs.length, (i) {
                  final d = docs[i].data();
                  final title = d['title'] as String? ?? 'Unknown';
                  final region =
                      (d['region'] as String?) ??
                      (d['category'] as String?) ??
                      '';
                  final imageUrl =
                      d['imageUrl'] as String? ??
                      'https://via.placeholder.com/400x240?text=No+Image';
                  final savedAt = _formatDate(d['savedAt']);
                  final description = savedAt.isNotEmpty
                      ? 'Saved on $savedAt'
                      : (d['description'] as String? ?? '');
                  final destinationId =
                      (d['destinationId'] as String?) ?? docs[i].id;

                  return Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
                    child: _WishlistCard(
                      title: title,
                      region: region,
                      description: description,
                      imageUrl: imageUrl,
                      onDelete: () =>
                          _deleteSaved(uid, docs[i].id, legacy: legacy),
                      onViewDetails: () => _openDetails(context, destinationId),
                    ),
                  );
                }),
              if (count > 0) const SizedBox(height: 10),
              _ExploreMoreCard(
                onBrowse: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const PlacesScreen())),
                onMap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const MapScreen())),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: Text('Sign in to view saved places')),
      );
    }
    final uid = user.uid;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _savedStream(uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final primaryDocs = snapshot.data?.docs ?? [];
            if (primaryDocs.isNotEmpty) {
              return _buildList(context, primaryDocs, uid, legacy: false);
            }

            return FutureBuilder<
              List<QueryDocumentSnapshot<Map<String, dynamic>>>
            >(
              future: _fetchLegacySaved(uid),
              builder: (context, legacySnap) {
                if (legacySnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (legacySnap.hasError) {
                  return Center(child: Text('Error: ${legacySnap.error}'));
                }
                final fallbackDocs = legacySnap.data ?? [];
                _setSavedCount(uid, fallbackDocs.length);
                return _buildList(context, fallbackDocs, uid, legacy: true);
              },
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.total});
  final int total;

  @override
  Widget build(BuildContext context) {
    final countLabel = total == 1 ? '1 place' : '$total places';
    return Container(
      margin: const EdgeInsets.fromLTRB(6, 8, 6, 6),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: _SavedScreenState._brandBlue,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _OrangePill(
            icon: Icons.favorite_border,
            label: 'your collection',
          ),
          const SizedBox(height: 10),
          const Text(
            'Saved Destinations',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$countLabel waiting for\nyour visit',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  const _WishlistCard({
    required this.title,
    required this.region,
    required this.description,
    required this.imageUrl,
    required this.onDelete,
    this.onViewDetails,
  });

  final String title;
  final String region;
  final String description;
  final String imageUrl;
  final VoidCallback onDelete;
  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _SavedScreenState._cardBorder),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Your Travel\nWishlist',
                  style: TextStyle(
                    color: _SavedScreenState._dark,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
              ),
              _CountBadge(count: '1'),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Keep track of places you\nwant to visit in Ethiopia',
            style: TextStyle(
              color: _SavedScreenState._muted,
              fontSize: 11.5,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9FB),
              border: Border.all(color: _SavedScreenState._cardBorder),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          height: 110,
                          color: const Color(0xFFF2F4F8),
                          alignment: Alignment.center,
                          child: const Text(
                            'Image unavailable',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      top: 8,
                      left: 8,
                      child: _Badge(label: 'Popular'),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: onDelete,
                        child: Container(
                          height: 26,
                          width: 26,
                          decoration: BoxDecoration(
                            color: _SavedScreenState._red,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: _SavedScreenState._dark,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Color(0xFF7B6D5F),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        region,
                        style: const TextStyle(
                          color: _SavedScreenState._muted,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      color: _SavedScreenState._muted,
                      fontSize: 11.5,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _PrimaryPill(
                    label: 'View Full Details',
                    onTap: onViewDetails,
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

class _ExploreMoreCard extends StatelessWidget {
  const _ExploreMoreCard({this.onBrowse, this.onMap});
  final VoidCallback? onBrowse;
  final VoidCallback? onMap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F5FA),
        border: Border.all(color: _SavedScreenState._cardBorder),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.star_border,
            color: _SavedScreenState._red,
            size: 22,
          ),
          const SizedBox(height: 10),
          const Text(
            'Ready to\nExplore More?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _SavedScreenState._dark,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Discover more incredible destinations across Ethiopia and add them to your collection',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _SavedScreenState._muted,
              fontSize: 11.5,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _PrimaryPill(label: 'Browse All Places', onTap: onBrowse),
          const SizedBox(height: 12),
          _IconTextButton(
            icon: Icons.map_outlined,
            label: 'View Map',
            onTap: onMap,
          ),
        ],
      ),
    );
  }
}

class _OrangePill extends StatelessWidget {
  const _OrangePill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _SavedScreenState._orange,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
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
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _SavedScreenState._orange,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PrimaryPill extends StatelessWidget {
  const _PrimaryPill({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _SavedScreenState._buttonBlue,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final String count;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      width: 26,
      decoration: BoxDecoration(
        color: _SavedScreenState._softBadge,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _SavedScreenState._cardBorder),
      ),
      alignment: Alignment.center,
      child: Text(
        count,
        style: const TextStyle(
          color: _SavedScreenState._dark,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _IconTextButton extends StatelessWidget {
  const _IconTextButton({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _SavedScreenState._cardBorder),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: _SavedScreenState._muted),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: _SavedScreenState._muted,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No saved places yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text(
              'Save destinations to see them here for quick access.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
