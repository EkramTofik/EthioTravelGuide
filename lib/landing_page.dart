// lib/landing_page.dart
import 'package:flutter/material.dart';
import 'login.dart';
import 'place_details_screen.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Header with Background
            Stack(
              children: [
                Image.asset(
                  'assets/images/image6.png',
                  height: 600,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 600,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 80,
                  left: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Your Gateway to Ethiopia',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'EthioTravel\nGuide',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Discover Ethiopia\'s History,\nCulture, and Natural Beauty',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Explore Places',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            // Stats Badges
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statBadge(
                    icon: Icons.location_on,
                    value: '10+',
                    label: 'Destinations\nExplore',
                  ),
                  _statBadge(
                    icon: Icons.star,
                    value: 'UNESCO',
                    label: '9 Total',
                  ),
                  _statBadge(
                    icon: Icons.calendar_today,
                    value: 'Year-round',
                    label: 'Travel',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // Featured Destinations Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Featured\nMust-Visit Destinations',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Explore the most iconic and breathtaking locations Ethiopia has to offer',
              ),
            ),
            const SizedBox(height: 24),

            // Featured Cards
            _destinationCard(
              context: context,
              image: 'assets/images/image6.png',
              title: 'Lalibela Rock-Hewn Churches',
              region: 'Lalibela, Amhara Region',
              description:
                  'Ancient monolithic churches carved from rock, a UNESCO World Heritage site.',
              rating: 4.9,
              tag: 'Popular',
            ),
            _destinationCard(
              context: context,
              image: 'assets/images/image5.png',
              title: 'Simien Mountains',
              region: 'Amhara Region',
              description:
                  'Dramatic mountain landscapes with unique wildlife and breathtaking views.',
              rating: 5.0,
              tag: 'Top Rated',
            ),
            _destinationCard(
              context: context,
              image: 'assets/images/image4.png',
              title: 'Axum Obelisks',
              region: 'Tigray Region',
              description:
                  'Ancient stelae marking the heart of the Aksumite Empire, UNESCO site.',
              rating: 4.7,
              tag: 'Historical',
            ),

            const SizedBox(height: 60),

            // Why Ethiopia Section
            Container(
              padding: const EdgeInsets.all(32),
              color: Colors.grey[100],
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Why Ethiopia',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Experience the Extraordinary',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'A land of ancient wonders, diverse cultures, and unforgettable experiences.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  _whyCard(
                    icon: Icons.history,
                    title: 'Ancient Heritage',
                    description:
                        'Over 3,000 years of documented history and cultural treasures',
                  ),
                  _whyCard(
                    icon: Icons.nature,
                    title: 'Natural Beauty',
                    description:
                        'From highlands to lakes, diverse landscapes await exploration',
                  ),
                  _whyCard(
                    icon: Icons.people,
                    title: 'Cultural Richness',
                    description:
                        'Home to over 80 ethnic groups with unique traditions',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // Footer - Matches your screenshot exactly
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
              color: const Color(0xFF0A1E3A),
              child: Column(
                children: [
                  const Text(
                    'EthioTravel Guide',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your comprehensive guide to exploring\nEthiopia\'s wonders',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'About Us • Contact',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Terms of Service • Privacy Policy',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Bottom White Section with Navigation Preview (matches authenticated bottom bar style)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Container(height: 1, color: Colors.grey[200]),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _bottomNavPreviewItem(
                          icon: Icons.home_outlined,
                          label: 'Home',
                          isActive: true,
                        ),
                        _bottomNavPreviewItem(
                          icon: Icons.location_on_outlined,
                          label: 'Places',
                        ),
                        _bottomNavPreviewItem(
                          icon: Icons.map_outlined,
                          label: 'Map',
                        ),
                        _bottomNavPreviewItem(
                          icon: Icons.favorite_border,
                          label: 'Saved',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom navigation preview item (non-interactive, just visual hint)
  Widget _bottomNavPreviewItem({
    required IconData icon,
    required String label,
    bool isActive = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 28,
          color: isActive
              ? const Color.fromARGB(255, 5, 39, 90)
              : const Color.fromARGB(255, 58, 116, 203),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive
                ? const Color.fromARGB(255, 5, 39, 90)
                : const Color.fromARGB(255, 48, 76, 174),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _statBadge({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 50, color: Colors.blue),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _destinationCard({
    required BuildContext context,
    required String image,
    required String title,
    required String region,
    required String description,
    required double rating,
    required String tag,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlaceDetailsScreen(
                  placeName: title,
                  imageUrl: image,
                  rating: rating,
                  description: description,
                  whenToVisit: 'Best visited during dry season (Oct–Jun)',
                  visitorTips: [
                    'Bring comfortable shoes',
                    'Hire a local guide',
                    'Respect local customs and religious sites',
                  ],
                  nearbyHotels: [],
                ),
              ),
            );
          },
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  image,
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.9),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        region,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '$rating',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          const Icon(
                            Icons.star,
                            color: Colors.orange,
                            size: 24,
                          ),
                          const Spacer(),
                          const Text(
                            'View details →',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _whyCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.blue[100],
                child: Icon(icon, size: 40, color: Colors.blue[800]),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
