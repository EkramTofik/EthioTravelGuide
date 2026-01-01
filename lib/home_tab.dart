import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'destination_detail_page.dart';
import 'places_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  static const _brandBlue = Color(0xFF5179BA);
  static const _buttonBlue = Color(0xFF2B60B6);
  static const _orange = Color(0xFFF36D3A);
  static const _red = Color(0xFFF64F59);
  static const _dark = Color(0xFF1F1F1F);
  static const _muted = Color(0xFF6A6A6A);
  static const _bg = Color(0xFFF7F7F7);
  static const _cardBorder = Color(0xFFE8E8E8);
  static const _placeholderColor = Color(0xFFE5E7EB);

  static final _destinationsQuery = FirebaseFirestore.instance
      .collection('destinations')
      .orderBy('rating', descending: true)
      .limit(5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const _HeroHeader(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _FeaturedHeader(),
                  const SizedBox(height: 12),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _destinationsQuery.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'Failed to load destinations\n${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        );
                      }

                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No destinations yet',
                              style: TextStyle(color: _muted),
                            ),
                          ),
                        );
                      }

                      final items = docs
                          .map((d) => _Destination.fromDoc(d))
                          .where((d) => d != null)
                          .cast<_Destination>()
                          .toList();

                      return Column(
                        children: items
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 330,
                                    ),
                                    child: _DestinationCard(
                                      item: item,
                                      imageHeight: 190,
                                      onView: () => _openDetail(context, item),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  _PrimaryButton(
                    label: 'View  All Destinations',
                    icon: Icons.place_outlined,
                    onTap: () => _openPlaces(context),
                  ),
                  const SizedBox(height: 22),
                  const _WhyEthiopiaSection(),
                  const SizedBox(height: 28),
                ],
              ),
            ),
            const _Footer(),
          ],
        ),
      ),
    );
  }

  static void _openDetail(BuildContext context, _Destination item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DestinationDetailPage(destinationId: item.id),
      ),
    );
  }

  static void _openPlaces(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Places')),
          body: const PlacesScreen(),
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      height: 360,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/images3.jpg', fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.45),
                  Colors.black.withOpacity(0.55),
                  Colors.black.withOpacity(0.35),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: _Pill(
                    label: 'Your Gateway to Ethiopia',
                    color: HomeTab._orange,
                    textColor: Colors.white,
                    horizontal: 14,
                    vertical: 8,
                  ),
                ),
                const Spacer(),
                const Text(
                  'EthioTravel\nGuide',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Discover Ethiopia’s History,\nCulture, and Natural Beauty',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  child: _CTA(
                    label: 'Explore Places',
                    fillColor: const Color.fromARGB(255, 81, 121, 186),
                    maxWidth: screenWidth * 0.6,
                    onTap: () => HomeTab._openPlaces(context),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    _StatPill(
                      icon: Icons.place_outlined,
                      label: '10+ Destinations Explore',
                    ),
                    SizedBox(width: 10),
                    _StatPill(
                      icon: Icons.star_border,
                      label: 'UNESCO Sites 9 Total',
                    ),
                    SizedBox(width: 10),
                    _StatPill(
                      icon: Icons.calendar_month_outlined,
                      label: 'Year-round Travel',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CTA extends StatelessWidget {
  const _CTA({
    required this.label,
    required this.fillColor,
    required this.onTap,
    this.maxWidth,
  });

  final String label;
  final Color fillColor;
  final VoidCallback onTap;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      height: 40,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: maxWidth == null
          ? child
          : ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth!),
              child: child,
            ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 81, 121, 186),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                height: 1.1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.color,
    required this.textColor,
    this.horizontal = 12,
    this.vertical = 6,
  });

  final String label;
  final Color color;
  final Color textColor;
  final double horizontal;
  final double vertical;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _FeaturedHeader extends StatelessWidget {
  const _FeaturedHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Text(
          'Featured',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Must-Visit\nDestinations',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: HomeTab._brandBlue,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Explore the most iconic and breathtaking locations Ethiopia has to offer',
          textAlign: TextAlign.center,
          style: TextStyle(color: HomeTab._muted, fontSize: 12, height: 1.35),
        ),
      ],
    );
  }
}

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({
    required this.item,
    required this.imageHeight,
    required this.onView,
  });

  final _Destination item;
  final double imageHeight;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onView,
      child: Container(
        constraints: const BoxConstraints(minHeight: 260),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: HomeTab._cardBorder),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardImage(item: item, height: imageHeight),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: HomeTab._dark,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      color: HomeTab._muted,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: onView,
                    child: Row(
                      children: const [
                        Text(
                          'View details',
                          style: TextStyle(
                            color: HomeTab._brandBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: HomeTab._brandBlue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({required this.item, required this.height});
  final _Destination item;
  final double height;

  @override
  Widget build(BuildContext context) {
    final hasImageUrl = item.imageUrl.isNotEmpty;
    final imageWidget = hasImageUrl
        ? Image.network(
            item.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: HomeTab._placeholderColor),
          )
        : Container(color: HomeTab._placeholderColor);

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: imageWidget,
            ),
          ),
          if (item.badge != null && item.badge!.isNotEmpty)
            Positioned(
              top: 8,
              left: 8,
              child: _Pill(
                label: item.badge!,
                color: item.badge == 'Popular' ? HomeTab._red : HomeTab._orange,
                textColor: Colors.white,
                horizontal: 10,
                vertical: 5,
              ),
            ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: HomeTab._brandBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                item.ratingLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Destination {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final double rating;
  final String? badge;

  const _Destination({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.rating,
    this.badge,
  });

  String get ratingLabel => '${rating.toStringAsFixed(1)}/5';

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static _Destination? fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return null;

    final name = (data['title'] ?? data['name'] ?? '').toString().trim();
    final region = (data['region'] ?? '').toString().trim();
    final category = (data['category'] ?? '').toString().trim();
    final imageUrl =
        (data['imageUrl'] ??
                data['heroImage'] ??
                data['thumbnail'] ??
                data['image'] ??
                '')
            .toString()
            .trim();
    final badge = (data['badge'] ?? '').toString().trim();
    final rating = _toDouble(data['rating']) ?? 4.5;

    return _Destination(
      id: doc.id,
      title: name.isNotEmpty ? name : doc.id,
      subtitle: region.isNotEmpty
          ? region
          : (category.isNotEmpty ? category : 'Ethiopia'),
      imageUrl: imageUrl,
      rating: rating,
      badge: badge.isNotEmpty ? badge : null,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: HomeTab._buttonBlue,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WhyEthiopiaSection extends StatelessWidget {
  const _WhyEthiopiaSection();

  @override
  Widget build(BuildContext context) {
    final features = const [
      _Feature(
        icon: Icons.home_outlined,
        title: 'Ancient Heritage',
        body: 'Over 3,000 years of documented history and cultural treasures',
      ),
      _Feature(
        icon: Icons.star_border,
        title: 'Natural Beauty',
        body: 'From highlands to lakes, diverse landscapes await exploration',
      ),
      _Feature(
        icon: Icons.person_outline,
        title: 'Cultural Richness',
        body: 'Home to over 80 ethnic groups with unique traditions',
      ),
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xFFF5F1EC),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Pill(
            label: 'Why Ethiopia',
            color: HomeTab._orange,
            textColor: Colors.white,
            horizontal: 12,
            vertical: 6,
          ),
          const SizedBox(height: 10),
          const Text(
            'Experience the\nExtraordinary',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: HomeTab._brandBlue,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          const SizedBox(
            width: 280,
            child: Text(
              'A land of ancient wonders, diverse cultures, and unforgettable experiences',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: HomeTab._muted,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Align(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 270),
                  child: _FeatureCard(feature: f),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature});
  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9E5DE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6C93D1), Color(0xFF5179BA)],
              ),
            ),
            child: Icon(feature.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            feature.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: HomeTab._brandBlue,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            feature.body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: HomeTab._muted,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String body;
  const _Feature({required this.icon, required this.title, required this.body});
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF141632), Color(0xFF0F1028)],
        ),
      ),
    );
  }
}
