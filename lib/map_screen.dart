// lib/map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'place_details_screen.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  final List<Map<String, dynamic>> featuredLocations = const [
    {
      'title': 'Lalibela Rock-Hewn Churches',
      'region': 'Amhara Region',
      'coords': 'N 12.0316° E 39.0409°',
      'latlng': latlng.LatLng(12.0316, 39.0409),
    },
    {
      'title': 'Harar',
      'region': 'Historic Walled City - Harari Region',
      'coords': 'N 9.3110° E 42.1380°',
      'latlng': latlng.LatLng(9.3110, 42.1380),
    },
    {
      'title': 'Gondar',
      'region': 'Royal Castles - Amhara Region',
      'coords': 'N 12.6041° E 37.4679°',
      'latlng': latlng.LatLng(12.6041, 37.4679),
    },
    {
      'title': 'Simien Mountains',
      'region': 'National Park - Amhara Region',
      'coords': 'N 13.1833° E 38.1833°',
      'latlng': latlng.LatLng(13.1833, 38.1833),
    },
    {
      'title': 'Axum',
      'region': 'Ancient Kingdom - Tigray Region',
      'coords': 'N 14.1317° E 38.7189°',
      'latlng': latlng.LatLng(14.1317, 38.7189),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Interactive flutter_map
          FlutterMap(
            options: MapOptions(
              initialCenter: const latlng.LatLng(
                9.1450,
                40.4897,
              ), // Ethiopia center
              initialZoom: 6.5,
              minZoom: 5.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.ethiotravel',
              ),
              MarkerLayer(
                markers: featuredLocations.map((loc) {
                  return Marker(
                    point: loc['latlng'],
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Top Header Overlay
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Interactive Map',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B60B6),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Explore Ethiopia\nPin your dream destinations across the country',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Click locations below to explore or tap markers on the map',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Featured Locations List
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 340,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: const [
                        Text(
                          'Featured Locations',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Text(
                          '5 Destinations',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: featuredLocations.length,
                      itemBuilder: (context, index) {
                        final loc = featuredLocations[index];
                        return _locationItem(
                          context: context,
                          title: loc['title'],
                          region: loc['region'],
                          coords: loc['coords'],
                        );
                      },
                    ),
                  ),
                  // Planning Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.blue[50]),
                    child: Column(
                      children: [
                        const Text(
                          'Plan Your Journey',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Use the map to explore destinations and plan your Ethiopian adventure. Save your favorites for easy access later.',
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to PlacesScreen
                              },
                              child: const Text('Browse All Places'),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                // Navigate to SavedScreen
                              },
                              child: const Text('View Saved Places'),
                            ),
                          ],
                        ),
                      ],
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

  Widget _locationItem({
    required BuildContext context,
    required String title,
    required String region,
    required String coords,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.location_on, color: Colors.red, size: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$region\n$coords'),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlaceDetailsScreen(
                  placeName: title,
                  imageUrl: 'https://example.com/$title.jpg',
                  rating: 4.8,
                  description: 'Detailed description...',
                  whenToVisit: 'Best time...',
                  visitorTips: ['Tip 1', 'Tip 2'],
                  nearbyHotels: [],
                ),
              ),
            );
          },
          child: const Text('View Details'),
        ),
      ),
    );
  }
}
