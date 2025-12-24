// lib/authenticated_main.dart
import 'package:flutter/material.dart';

import 'home_tab.dart';
import 'places_screen.dart';
import 'map_screen.dart';
import 'saved_screen.dart';
import 'profile_screen.dart'; // ← Make sure this line is here

class AuthenticatedMain extends StatefulWidget {
  const AuthenticatedMain({super.key});

  @override
  State<AuthenticatedMain> createState() => _AuthenticatedMainState();
}

class _AuthenticatedMainState extends State<AuthenticatedMain> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const PlacesScreen(),
    const MapScreen(),
    const SavedScreen(),
    const ProfileScreen(), // ← Now recognized
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2B60B6),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Places',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
