// lib/places_screen.dart
import 'package:flutter/material.dart';
import 'place_details_screen.dart'; // From earlier

class PlacesScreen extends StatefulWidget {
  const PlacesScreen({super.key});

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  String _selectedCategory = 'All Categories';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> allDestinations = [
    {
      'title': 'Lalibela Rock-Hewn Churches',
      'subtitle':
          'Ancient monolithic churches carved from rock – UNESCO World Heritage',
      'image':
          'https://whc.unesco.org/uploads/thumbs/site_0018_0016-1200-630-20151104173458.jpg',
      'rating': 4.8,
      'category': 'Historical',
    },
    {
      'title': 'Simien Mountains',
      'subtitle':
          'Dramatic landscapes with unique wildlife and breathtaking views',
      'image':
          'https://absoluteethiopia.com/wp-content/uploads/2025/07/Simiens-NP.webp',
      'rating': 5.0,
      'category': 'Nature',
    },
    {
      'title': 'Axum Obelisks',
      'subtitle': 'Ancient stelae marking the heart of the Aksumite Empire',
      'image':
          'https://cdn.britannica.com/23/93423-050-107B2836/obelisk-kingdom-Aksum-Ethiopian-name-city.jpg',
      'rating': 4.7,
      'category': 'Historical',
    },
    {
      'title': 'Harar Jugol',
      'subtitle': 'Ancient walled city known as the fourth holiest in Islam',
      'image':
          'https://whc.unesco.org/uploads/thumbs/site_0019_0003-1200-630-20151104173529.jpg',
      'rating': 4.6,
      'category': 'Cultural',
    },
    {
      'title': 'Gondar Royal Enclosure',
      'subtitle': 'Medieval castles and churches from the 17th century',
      'image':
          'https://www.ethiopianadventuretours.com/wp-content/uploads/2023/06/Fasil-Ghebbi-Gondar.jpg',
      'rating': 4.5,
      'category': 'Historical',
    },
    {
      'title': 'Lake Tana',
      'subtitle': 'Source of the Blue Nile with ancient monasteries',
      'image':
          'https://www.ethiopianadventuretours.com/wp-content/uploads/2023/06/Lake-Tana.jpg',
      'rating': 4.6,
      'category': 'Nature',
    },
  ];

  List<Map<String, dynamic>> get filteredDestinations {
    var list = allDestinations;
    if (_selectedCategory != 'All Categories') {
      list = list.where((d) => d['category'] == _selectedCategory).toList();
    }
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      list = list
          .where(
            (d) =>
                d['title'].toLowerCase().contains(query) ||
                d['subtitle'].toLowerCase().contains(query),
          )
          .toList();
    }
    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2B60B6), Color(0xFF2B60B6)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Explore',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  Text(
                    'Destinations',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Discover Ethiopia\'s iconic landmarks and hidden gems',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search destinations...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Category Chips
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _categoryChip('All Categories'),
                  _categoryChip('Historical'),
                  _categoryChip('Nature'),
                  _categoryChip('Cultural'),
                  _categoryChip('UNESCO Sites'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Destinations List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredDestinations.length,
                itemBuilder: (context, index) {
                  final dest = filteredDestinations[index];
                  return _destinationCard(
                    title: dest['title'],
                    subtitle: dest['subtitle'],
                    image: dest['image'],
                    rating: dest['rating'],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlaceDetailsScreen(
                            placeName: dest['title'],
                            imageUrl: dest['image'],
                            rating: dest['rating'],
                            description: dest['subtitle'],
                            whenToVisit: 'Best time varies by season',
                            visitorTips: [
                              'Bring comfortable shoes',
                              'Hire a local guide',
                              'Respect local customs',
                            ],
                            nearbyHotels: [], // Fill later
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(category),
        selected: isSelected,
        selectedColor: const Color(0xFF2B60B6),
        backgroundColor: Colors.grey[200],
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
        onSelected: (_) {
          setState(() {
            _selectedCategory = category;
          });
        },
      ),
    );
  }

  Widget _destinationCard({
    required String title,
    required String subtitle,
    required String image,
    required double rating,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20),
              ),
              child: Image.network(
                image,
                width: 130,
                height: 130,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          '$rating',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.star, color: Colors.orange, size: 20),
                        const Spacer(),
                        const Text(
                          'Explore More →',
                          style: TextStyle(
                            color: Color(0xFF2B60B6),
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
    );
  }
}
