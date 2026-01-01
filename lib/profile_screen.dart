import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'saved_screen.dart';
import 'places_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.initialName = 'ekram tofik',
    this.initialEmail = 'ekram31@gmail.com',
    this.joinedDays = 1,
    this.coverAssetPath = 'assets/images/images3.jpg',
    this.initialAvatarPath,
    this.initialAvatarBytes,
    this.userId,
  });

  final String initialName;
  final String initialEmail;
  final int joinedDays;
  final String coverAssetPath;
  final String? initialAvatarPath;
  final Uint8List? initialAvatarBytes;
  final String? userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _email = '';
  String? _avatarPath;
  Uint8List? _avatarBytes;
  Future<String?> _docIdFuture = Future.value(null);
  final Map<String, Future<int>> _ratedCache = {};

  Color get _headerBg => const Color(0xFFF7EEE9);
  Color get _navy => const Color(0xFF2E3A67);
  Color get _avatarRing => const Color(0xFFE74B4B);
  Color get _avatarIcon => const Color(0xFF3F5BD6);
  Color get _heartChipBg => const Color(0xFFDDE8FF);
  Color get _heartIcon => const Color(0xFF8EAFFF);
  Color get _starChipBg => const Color(0xFFFFD9C9);
  Color get _starIcon => const Color(0xFFE95B4B);
  Color get _avgChipBg => const Color(0xFFFFF2E8);
  Color get _avgIcon => const Color(0xFFF36D3A);
  Color get _activeChipBg => const Color(0xFFE7F7EA);
  Color get _activeIcon => const Color(0xFF55C26A);
  Color get _cardBorder => const Color(0xFFE8E8E8);

  @override
  void initState() {
    super.initState();
    _name = widget.initialName;
    _email = widget.initialEmail;
    _avatarPath = widget.initialAvatarPath;
    _avatarBytes = widget.initialAvatarBytes;
    _docIdFuture = _resolveDocId();
  }

  Future<String?> _resolveDocId() async {
    if (widget.userId != null && widget.userId!.isNotEmpty) {
      return widget.userId;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final col = FirebaseFirestore.instance.collection('user');
    final uid = user.uid;
    final emailKey = user.email?.split('@').first;
    final displayKey = user.displayName
        ?.trim()
        .split(' ')
        .first
        .toLowerCase()
        .trim();

    final uidDoc = await col.doc(uid).get();
    if (uidDoc.exists) return uid;

    if (emailKey != null && emailKey.isNotEmpty) {
      final emailDoc = await col.doc(emailKey).get();
      if (emailDoc.exists) return emailKey;
    }

    if (displayKey != null && displayKey.isNotEmpty) {
      final displayDoc = await col.doc(displayKey).get();
      if (displayDoc.exists) return displayKey;
    }

    return uid;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream(String id) {
    return FirebaseFirestore.instance.collection('user').doc(id).snapshots();
  }

  DateTime? _parseJoinedAt(dynamic joinedAt) {
    if (joinedAt is Timestamp) return joinedAt.toDate();
    if (joinedAt is String) return DateTime.tryParse(joinedAt);
    return null;
  }

  int _joinedDaysFrom(DateTime? joined) {
    if (joined == null) return widget.joinedDays;
    final days = DateTime.now().difference(joined).inDays;
    return days < 0 ? 0 : days;
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  Future<void> _openSettings(
    BuildContext context, {
    required String userId,
    required String currentName,
    required String currentEmail,
  }) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          initialName: currentName,
          initialEmail: currentEmail,
          initialAvatarPath: _avatarPath,
          initialAvatarBytes: _avatarBytes,
          savedPlaces: 0,
          ratedPlaces: 0,
        ),
      ),
    );

    if (result != null) {
      final nextName = result['name'] ?? _name;
      final nextEmail = result['email'] ?? _email;

      setState(() {
        _name = nextName;
        _email = nextEmail;
        _avatarPath = result['avatarPath'] ?? _avatarPath;
        _avatarBytes = result['avatarBytes'] ?? _avatarBytes;
      });

      await _saveProfileToFirestore(
        userId: userId,
        name: nextName,
        email: nextEmail,
      );
    }
  }

  Future<void> _saveProfileToFirestore({
    required String userId,
    required String name,
    required String email,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('user').doc(userId).set({
        'displayName': name,
        'email': email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save profile changes')),
        );
      }
    }
  }

  Future<int> _countQuery(Query query) async {
    try {
      final agg = await query.count().get();
      return agg.count ?? 0;
    } catch (_) {
      final snap = await query.get();
      return snap.size;
    }
  }

  Future<int> _loadRatedCount(String userId) {
    return _ratedCache.putIfAbsent(
      userId,
      () => _countQuery(
        FirebaseFirestore.instance
            .collectionGroup('ratings')
            .where('userId', isEqualTo: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tileWidth = (screenWidth - 18 * 2 - 14) / 2;

    return FutureBuilder<String?>(
      future: _docIdFuture,
      builder: (context, idSnap) {
        if (idSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (idSnap.hasError) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: Text('Error: ${idSnap.error}')),
          );
        }

        final userId = idSnap.data;
        if (userId == null) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: Text('Sign in to view your profile')),
          );
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _userStream(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Colors.white,
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Scaffold(
                backgroundColor: Colors.white,
                body: Center(child: Text('Error: ${snapshot.error}')),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Scaffold(
                backgroundColor: Colors.white,
                body: Center(child: Text('Profile not found')),
              );
            }

            final data = snapshot.data!.data() ?? {};
            final authUser = FirebaseAuth.instance.currentUser;
            final authDisplayName = authUser?.displayName?.trim();
            final authEmail = authUser?.email?.trim();
            final authPhoto = authUser?.photoURL?.trim();

            final displayName = (data['displayName'] as String?)?.trim();
            final email = (data['email'] as String?)?.trim();
            final photoUrl = (data['photoUrl'] as String?)?.trim();
            final savedCountFromDoc = (data['savedCount'] as num?)?.toInt();
            final ratedCountFromDoc = (data['ratedCount'] as num?)?.toInt();

            final joinedAtAuth = authUser?.metadata.creationTime;
            final joinedAtDt = joinedAtAuth ?? _parseJoinedAt(data['joinedAt']);
            final joinedDays = _joinedDaysFrom(joinedAtDt);
            final joinedDateLabel = _formatDate(joinedAtDt);

            final nameToShow = (displayName != null && displayName.isNotEmpty)
                ? displayName
                : (authDisplayName != null && authDisplayName.isNotEmpty
                      ? authDisplayName
                      : _name);
            final emailToShow = (email != null && email.isNotEmpty)
                ? email
                : (authEmail != null && authEmail.isNotEmpty
                      ? authEmail
                      : _email);
            final avatarUrl = (photoUrl != null && photoUrl.isNotEmpty)
                ? photoUrl
                : (authPhoto != null && authPhoto.isNotEmpty
                      ? authPhoto
                      : null);

            final ratedFuture = ratedCountFromDoc != null
                ? null
                : _loadRatedCount(userId);

            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: ListView(
                  padding: EdgeInsets.only(
                    bottom: 24 + MediaQuery.of(context).padding.bottom,
                  ),
                  children: [
                    _Header(
                      bg: _headerBg,
                      navy: _navy,
                      onSettingsTap: () => _openSettings(
                        context,
                        userId: userId,
                        currentName: nameToShow,
                        currentEmail: emailToShow,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ProfileCard(
                      name: nameToShow,
                      email: emailToShow,
                      joinedDays: joinedDays,
                      joinedDateLabel: joinedDateLabel,
                      coverAssetPath: widget.coverAssetPath,
                      navy: _navy,
                      avatarRing: _avatarRing,
                      avatarIcon: _avatarIcon,
                      avatarPath: _avatarPath,
                      avatarBytes: _avatarBytes,
                      avatarUrl: avatarUrl,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: FutureBuilder<int>(
                        future: ratedFuture,
                        builder: (context, ratedSnap) {
                          final ratedValue =
                              ratedCountFromDoc ??
                              (ratedFuture == null
                                  ? null
                                  : (ratedSnap.data ?? 0));
                          final savedValue = savedCountFromDoc ?? 0;
                          final savedCountLabel = '$savedValue';
                          final ratedCountLabel = ratedValue == null
                              ? '...'
                              : '$ratedValue';
                          return Wrap(
                            spacing: 14,
                            runSpacing: 14,
                            children: [
                              SizedBox(
                                width: tileWidth,
                                child: _StatTile(
                                  chipBg: _heartChipBg,
                                  iconColor: _heartIcon,
                                  icon: Icons.favorite,
                                  count: savedCountLabel,
                                  titleLine1: 'Saved',
                                  titleLine2: 'Places',
                                  navy: _navy,
                                ),
                              ),

                              SizedBox(
                                width: tileWidth,
                                child: _StatTile(
                                  chipBg: _activeChipBg,
                                  iconColor: _activeIcon,
                                  icon: Icons.access_time,
                                  count: '$joinedDays',
                                  titleLine1: 'Days',
                                  titleLine2: 'Active',
                                  navy: _navy,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: _QuickActionsCard(
                        navy: _navy,
                        borderColor: _cardBorder,
                        title: 'Quick Actions',
                        subtitle: 'Manage your travel\nexperience',
                        actions: [
                          _QuickAction(
                            icon: Icons.favorite,
                            label: 'View  Saved Place',
                            color: const Color(0xFFE74B4B),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SavedScreen(),
                              ),
                            ),
                          ),
                          _QuickAction(
                            icon: Icons.place_outlined,
                            label: 'Explore  Destination',
                            color: const Color(0xFFF36D3A),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PlacesScreen(),
                              ),
                            ),
                          ),
                          _QuickAction(
                            icon: Icons.settings_outlined,
                            label: 'Account Setting',
                            color: const Color(0xFF2E3A67),
                            onTap: () => _openSettings(
                              context,
                              userId: userId,
                              currentName: nameToShow,
                              currentEmail: emailToShow,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Counts {
  final int saved;
  final int rated;
  const _Counts({required this.saved, required this.rated});
}

/* ===== UI helpers below ===== */

class _Header extends StatelessWidget {
  const _Header({
    required this.bg,
    required this.navy,
    required this.onSettingsTap,
  });

  final Color bg;
  final Color navy;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        height: 88,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: navy, size: 28),
              onPressed: () => Navigator.of(context).maybePop(),
              splashRadius: 24,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      color: navy,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your travel journey',
                    style: TextStyle(
                      color: navy.withOpacity(0.85),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.settings, color: navy, size: 26),
              splashRadius: 24,
              onPressed: onSettingsTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.email,
    required this.joinedDays,
    required this.joinedDateLabel,
    required this.coverAssetPath,
    required this.navy,
    required this.avatarRing,
    required this.avatarIcon,
    required this.avatarPath,
    required this.avatarBytes,
    this.avatarUrl,
  });

  final String name;
  final String email;
  final int joinedDays;
  final String joinedDateLabel;
  final String coverAssetPath;
  final Color navy;
  final Color avatarRing;
  final Color avatarIcon;
  final String? avatarPath;
  final Uint8List? avatarBytes;
  final String? avatarUrl;

  Widget _buildAvatarCircle(String name, Color bg, Color textColor) {
    final letter = (name.isNotEmpty ? name.trim()[0].toUpperCase() : '?');
    return CircleAvatar(
      backgroundColor: bg,
      child: Text(
        letter,
        style: TextStyle(
          color: textColor,
          fontSize: 26,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasBytes = avatarBytes != null && avatarBytes!.isNotEmpty;
    final hasUrl = avatarUrl != null && avatarUrl!.isNotEmpty;

    Widget avatar;
    if (hasBytes) {
      avatar = Image.memory(avatarBytes!, fit: BoxFit.cover);
    } else if (hasUrl) {
      avatar = Image.network(
        avatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _buildAvatarCircle(name, const Color(0xFFE0E7FF), avatarIcon),
      );
    } else if (avatarPath != null && avatarPath!.isNotEmpty) {
      avatar = Image.asset(avatarPath!, fit: BoxFit.cover);
    } else {
      avatar = _buildAvatarCircle(name, const Color(0xFFE0E7FF), avatarIcon);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Image.asset(
                  coverAssetPath,
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: -32,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: avatarRing, width: 3),
                    color: Colors.white,
                  ),
                  child: ClipOval(child: avatar),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ).copyWith(bottom: 16),
            child: Column(
              children: [
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: navy,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Joined $joinedDays days ago • $joinedDateLabel',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.chipBg,
    required this.iconColor,
    required this.icon,
    required this.count,
    required this.titleLine1,
    required this.titleLine2,
    required this.navy,
  });

  final Color chipBg;
  final Color iconColor;
  final IconData icon;
  final String count;
  final String titleLine1;
  final String titleLine2;
  final Color navy;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 176),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(color: chipBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 34),
          ),
          const SizedBox(height: 10),
          Text(
            count,
            style: TextStyle(
              color: navy,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$titleLine1\n$titleLine2',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: navy,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({
    required this.navy,
    required this.borderColor,
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  final Color navy;
  final Color borderColor;
  final String title;
  final String subtitle;
  final List<_QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: navy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF6A6A6A),
              fontSize: 12.5,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (final a in actions) ...[
            _QuickActionPill(
              icon: a.icon,
              label: a.label,
              color: a.color,
              borderColor: borderColor,
              onTap: a.onTap,
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _QuickActionPill extends StatelessWidget {
  const _QuickActionPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.borderColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1F1F1F),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black26, size: 18),
          ],
        ),
      ),
    );
  }
}
