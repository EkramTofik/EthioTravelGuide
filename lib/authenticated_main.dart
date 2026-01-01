import 'package:flutter/material.dart';

import 'home_tab.dart';
import 'places_screen.dart';
import 'map_screen.dart';
import 'saved_screen.dart';
import 'profile_screen.dart';

class AuthenticatedMain extends StatefulWidget {
  final int initialTabIndex;

  const AuthenticatedMain({super.key, this.initialTabIndex = 0});

  static Route<void> route({int initialTabIndex = 0}) {
    return MaterialPageRoute<void>(
      builder: (_) => AuthenticatedMain(initialTabIndex: initialTabIndex),
    );
  }

  @override
  State<AuthenticatedMain> createState() => _AuthenticatedMainState();
}

class _AuthenticatedMainState extends State<AuthenticatedMain> {
  late int _selectedIndex;

  // Use const where constructors allow; keep non-const where not supported.
  late final List<Widget> _tabs = [
    const HomeTab(),
    const PlacesScreen(),
    const MapScreen(),
    const SavedScreen(),
    ProfileScreen(), // non-const constructor
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex.clamp(0, _tabs.length - 1);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false, // allow hero headers to reach status bar if desired
        child: IndexedStack(index: _selectedIndex, children: _tabs),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromARGB(255, 5, 39, 90),
        unselectedItemColor: const Color.fromARGB(255, 58, 116, 203),
        selectedFontSize: 14,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        showUnselectedLabels: true,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            activeIcon: Icon(Icons.location_on),
            label: 'Places',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            activeIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
