// lib/saved_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'place_details_screen.dart';
import 'places_screen.dart';
import 'map_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  // Sample saved places - later replace with Firestore user subcollection
  final List<Map<String, dynamic>> savedPlaces = const [
    {
      'title': 'Lalibela Rock-Hewn Churches',
      'region': 'Lalibela, Amhara Region',
      'description': 'Ancient monolithic churches carved from rock',
      'image':
          'https://whc.unesco.org/uploads/thumbs/site_0018_0016-1200-630-20151104173458.jpg',
      'tag': 'Popular',
    },
    // Add more as user saves
  ];

  @override
  Widget build(BuildContext context) {
    final int savedCount = savedPlaces.length;
    final bool hasSaved = savedCount > 0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2B60B6), Color(0xFF1E4A8C)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Collection',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Saved Destinations',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$savedCount place${savedCount == 1 ? '' : 's'} waiting for your visit',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: hasSaved
                  ? ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount:
                          savedPlaces.length +
                          1, // +1 for "Explore More" section
                      itemBuilder: (context, index) {
                        if (index == savedPlaces.length) {
                          return _exploreMoreSection(context);
                        }
                        final place = savedPlaces[index];
                        return _savedPlaceCard(context, place);
                      },
                    )
                  : _emptyWishlist(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyWishlist(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'Your wishlist is empty',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Start exploring destinations and save the ones you love!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlacesScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B60B6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Browse Destinations',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _savedPlaceCard(BuildContext context, Map<String, dynamic> place) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlaceDetailsScreen(
                placeName: place['title'],
                imageUrl: place['image'],
                rating: 4.8,
                description: place['description'],
                whenToVisit: 'October - March (dry season)',
                visitorTips: [
                  'Hire a local guide',
                  'Wear comfortable shoes',
                  'Respect religious sites - cover shoulders & knees',
                ],
                nearbyHotels: [],
              ),
            ),
          );
        },
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                place['image'],
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            if (place['tag'] != null)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    place['tag'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: const Icon(Icons.bookmark, color: Colors.white, size: 32),
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
                onPressed: () {
                  // Remove from saved (future Firestore delete)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${place['title']} removed from wishlist'),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place['region'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'View Full Details →',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _exploreMoreSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 24),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.star_rounded, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            const Text(
              'Ready to Explore More?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Discover more incredible destinations across Ethiopia and add them to your collection',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PlacesScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B60B6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Browse All Places',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MapScreen()),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('View Map', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
