import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login.dart'; // For logout

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Header with Background
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'EthioTravel Guide',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/background.jpg',
                    fit: BoxFit.cover,
                  ), // Use a beautiful Ethiopia mountain photo
                  Container(color: Colors.black.withOpacity(0.4)),
                  const Center(
                    child: Text(
                      'Your Gateway to Ethiopia\nDiscover History, Culture, and Natural Beauty',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatBadge(
                        Icons.location_on,
                        '10+ Destinations',
                        'Explore',
                      ),
                      _buildStatBadge(Icons.star, 'UNESCO Sites', '9 Total'),
                      _buildStatBadge(
                        Icons.calendar_today,
                        'Year-round Travel',
                        '',
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Featured Must-Visit
                  const Text(
                    'Featured Must-Visit Destinations',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildDestinationCard(
                    title: 'Lalibela Rock-Hewn Churches',
                    rating: 4.5,
                    tag: 'Popular',
                    image: 'assets/images/lalibela.jpg',
                    description:
                        'Ancient monolithic churches carved from rock, a UNESCO World Heritage site.',
                  ),
                  _buildDestinationCard(
                    title: 'Simien Mountains',
                    rating: 5.0,
                    tag: 'Top Rated',
                    image: 'assets/images/simien.jpg',
                    description:
                        'Dramatic mountain landscapes with unique wildlife and breathtaking views.',
                  ),
                  _buildDestinationCard(
                    title: 'Axum Obelisks',
                    rating: 4.5,
                    tag: 'Popular',
                    image: 'assets/images/axum.jpg',
                    description:
                        'Ancient stelae marking the heart of the Aksumite Empire.',
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to full places list
                    },
                    child: const Text('View All Destinations'),
                  ),
                  const SizedBox(height: 40),
                  // Why Ethiopia
                  const Text(
                    'Why Ethiopia',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const Text(
                    'Experience the Extraordinary\nA land of ancient wonders, diverse cultures, and unforgettable experiences.',
                  ),
                  const SizedBox(height: 20),
                  _buildWhyCard(
                    icon: Icons.history,
                    title: 'Ancient Heritage',
                    description:
                        'Over 3,000 years of documented history and cultural treasures',
                  ),
                  _buildWhyCard(
                    icon: Icons.nature,
                    title: 'Natural Beauty',
                    description:
                        'From highlands to lakes, diverse landscapes await exploration',
                  ),
                  _buildWhyCard(
                    icon: Icons.people,
                    title: 'Cultural Richness',
                    description:
                        'Home to over 80 ethnic groups with unique traditions',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Places',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
        ],
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Colors.blue),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(subtitle),
      ],
    );
  }

  Widget _buildDestinationCard({
    required String title,
    required double rating,
    required String tag,
    required String image,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Image.asset(image, width: 100, height: 100, fit: BoxFit.cover),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        color: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$rating ⭐',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View details →'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue[100],
              child: Icon(icon, size: 30, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
