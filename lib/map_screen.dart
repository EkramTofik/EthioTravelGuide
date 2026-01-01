import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _brandBlue = Color(0xFF5E86C5);
  static const _buttonBlue = Color(0xFF2B60B6);
  static const _orange = Color(0xFFF35C2C);
  static const _bg = Color(0xFFF7F7F7);
  static const _dark = Color(0xFF1F1F1F);
  static const _muted = Color(0xFF6A6A6A);
  static const _cardBorder = Color(0xFFE8E8E8);
  static const _softIconBg = Color(0xFFF0ECFB);
  static const LatLng _defaultCenter = LatLng(9.145, 40.4897);

  final MapController _mapController = MapController();
  _Location? _selected;
  bool _initializedSelection = false;

  void _moveTo(LatLng target, {double zoom = 7.0}) {
    _mapController.move(target, zoom);
  }

  Future<void> _openDirections(_Location loc) async {
    final dest = '${loc.latLng.latitude},${loc.latLng.longitude}';
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$dest&travelmode=driving',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open directions')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('destinations')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Could not load destinations',
                  style: TextStyle(color: Colors.red.shade600),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final locations = _buildLocations(snapshot.data!);
            if (!_initializedSelection && locations.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() {
                  _selected = locations.first;
                  _initializedSelection = true;
                });
              });
            }
            final selected =
                _selected ?? (locations.isNotEmpty ? locations.first : null);
            final initial = selected?.latLng ?? _defaultCenter;

            final markers = locations
                .map(
                  (l) => Marker(
                    point: l.latLng,
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selected = l);
                        _moveTo(l.latLng, zoom: 8.0);
                      },
                      child: const Icon(
                        Icons.place,
                        color: Colors.red,
                        size: 28,
                      ),
                    ),
                  ),
                )
                .toList();

            return Column(
              children: [
                const _MapHeader(),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _MapCard(
                    child: SizedBox(
                      height: 240,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: initial,
                            initialZoom: 6.5,
                            interactionOptions: const InteractionOptions(
                              enableMultiFingerGestureRace: true,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName:
                                  'com.example.flutter_application_1',
                            ),
                            MarkerLayer(markers: markers),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const _FeaturedHeading(text: 'Featured\nLocations'),
                      const Spacer(),
                      _CountCapsule(text: '${locations.length} Destinations'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    children: [
                      ...locations.map(
                        (l) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _LocationCard(
                            loc: l,
                            minHeight: 150,
                            onView: () {
                              setState(() => _selected = l);
                              _moveTo(l.latLng, zoom: 8.0);
                            },
                            onDirections: () => _openDirections(l),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const _PlanJourneyCard(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<_Location> _buildLocations(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final list = <_Location>[];
    for (final doc in snapshot.docs) {
      final loc = _locationFromDoc(doc);
      if (loc != null) list.add(loc);
    }
    return list;
  }

  _Location? _locationFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final latLng = _resolveLatLng(data);
    if (latLng == null) return null;

    final title = (data['title'] ?? data['name'] ?? 'Untitled').toString();
    final region = (data['region'] ?? data['location'] ?? 'Ethiopia')
        .toString();
    final coordsLabel =
        (data['coords'] ?? data['coordinates'] ?? _formatLatLng(latLng))
            .toString();

    return _Location(
      id: doc.id,
      title: title,
      region: region,
      coordsLabel: coordsLabel,
      latLng: latLng,
    );
  }

  LatLng? _resolveLatLng(Map<String, dynamic> data) {
    final lat = data['lat'] ?? data['latitude'];
    final lng = data['lng'] ?? data['longitude'];

    if (lat is num && lng is num) {
      return LatLng(lat.toDouble(), lng.toDouble());
    }

    final coords = data['coords'] ?? data['coordinates'];
    if (coords is String) {
      return _parseCoordsString(coords);
    }

    return null;
  }

  LatLng? _parseCoordsString(String coords) {
    final parts = coords.split(',');
    if (parts.length < 2) return null;

    double? parsePart(String p) {
      final match = RegExp(
        r'([0-9.+-]+)\s*°?\s*([NSEWnsew]?)',
      ).firstMatch(p.trim());
      if (match == null) return null;
      final value = double.tryParse(match.group(1)!);
      if (value == null) return null;
      final dir = match.group(2)?.toUpperCase();
      if (dir == 'S' || dir == 'W') return -value;
      return value;
    }

    final lat = parsePart(parts[0]);
    final lng = parsePart(parts[1]);
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  String _formatLatLng(LatLng latLng) {
    String fmt(double v, String pos, String neg) {
      final dir = v >= 0 ? pos : neg;
      final absVal = v.abs().toStringAsFixed(4);
      return '$absVal° $dir';
    }

    return '${fmt(latLng.latitude, 'N', 'S')}, ${fmt(latLng.longitude, 'E', 'W')}';
  }
}

/* ===== UI helpers below ===== */

class _MapHeader extends StatelessWidget {
  const _MapHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 36),
      decoration: const BoxDecoration(color: _MapScreenState._brandBlue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          _PillWithIcon(
            icon: Icons.map_outlined,
            label: 'Interactive Map',
            color: _MapScreenState._orange,
            textColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            radius: 26,
            iconSize: 22,
            fontSize: 18,
          ),
          SizedBox(height: 24),
          Text(
            'Explore Ethiopia',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Discover destinations\nacross the country',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5EEF4),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: child,
    );
  }
}

class _FeaturedHeading extends StatelessWidget {
  const _FeaturedHeading({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _MapScreenState._dark,
        fontSize: 14.5,
        fontWeight: FontWeight.w800,
        height: 1.1,
      ),
    );
  }
}

class _CountCapsule extends StatelessWidget {
  const _CountCapsule({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEAE6FA),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _MapScreenState._brandBlue,
          fontWeight: FontWeight.w800,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.loc,
    required this.onView,
    required this.onDirections,
    this.minHeight = 120,
  });

  final _Location loc;
  final double minHeight;
  final VoidCallback onView;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _MapScreenState._cardBorder),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  color: _MapScreenState._softIconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.place_outlined,
                  color: _MapScreenState._brandBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.title,
                      style: const TextStyle(
                        color: _MapScreenState._dark,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      loc.region,
                      style: const TextStyle(
                        color: _MapScreenState._dark,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_pin,
                color: _MapScreenState._muted,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  loc.coordsLabel,
                  style: const TextStyle(
                    color: _MapScreenState._muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _ViewButton(label: 'View on Map', onTap: onView),
              const SizedBox(width: 10),
              _OutlineButton(label: 'Directions', onTap: onDirections),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanJourneyCard extends StatelessWidget {
  const _PlanJourneyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F5FA),
        border: Border.all(color: _MapScreenState._cardBorder),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Icon(Icons.grade_outlined, color: Color(0xFF7B7C8A), size: 22),
          SizedBox(height: 10),
          Text(
            'Plan Your Journey',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _MapScreenState._dark,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            width: 240,
            child: Text(
              'Use the map to explore destinations and plan your Ethiopian adventure. Save your favorite places for easy access later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _MapScreenState._muted,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillWithIcon extends StatelessWidget {
  const _PillWithIcon({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    this.radius = 18,
    this.iconSize = 16,
    this.fontSize = 12.5,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final EdgeInsets padding;
  final double radius;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: textColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewButton extends StatelessWidget {
  const _ViewButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _MapScreenState._buttonBlue,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
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

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _MapScreenState._buttonBlue, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: _MapScreenState._buttonBlue,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: _MapScreenState._dark, size: 18),
      ),
    );
  }
}

class _Location {
  final String id;
  final String title;
  final String region;
  final String coordsLabel;
  final LatLng latLng;

  const _Location({
    required this.id,
    required this.title,
    required this.region,
    required this.coordsLabel,
    required this.latLng,
  });
}
