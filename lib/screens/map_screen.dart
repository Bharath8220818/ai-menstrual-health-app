// filepath: lib/screens/map_screen.dart
// OpenStreetMap + Overpass API — real live data, no API key needed

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:femi_friendly/services/location_service.dart';

// ── Base URL (mirrors ApiService) ─────────────────────────────────────────────
const String _kBaseUrl = 'https://ai-menstrual-health-app-1.onrender.com';

// ── Model ─────────────────────────────────────────────────────────────────────
class NearbyPlace {
  final String name;
  final double lat;
  final double lng;
  final String type; // 'hospital', 'pharmacy', 'market'
  final String address;
  final double distanceKm;
  final String rating;
  final String phone;

  NearbyPlace({
    required this.name,
    required this.lat,
    required this.lng,
    required this.type,
    required this.address,
    required this.distanceKm,
    required this.rating,
    required this.phone,
  });

  factory NearbyPlace.fromJson(Map<String, dynamic> j) {
    final rawDist = j['distance'] as String? ?? '0 km';
    final km = double.tryParse(rawDist.replaceAll(' km', '')) ?? 0.0;
    return NearbyPlace(
      name: j['name'] ?? 'Unknown',
      lat: (j['latitude'] as num).toDouble(),
      lng: (j['longitude'] as num).toDouble(),
      type: j['place_type'] ?? 'hospital',
      address: j['address'] ?? '',
      distanceKm: km,
      rating: j['rating'] ?? 'N/A',
      phone: j['phone'] ?? '',
    );
  }

  String get icon {
    switch (type) {
      case 'pharmacy':
        return '💊';
      case 'supermarket':
      case 'market':
        return '🛒';
      default:
        return '🏥';
    }
  }

  Color get markerColor {
    switch (type) {
      case 'pharmacy':
        return const Color(0xFF26A65B);
      case 'supermarket':
      case 'market':
        return const Color(0xFFE67E22);
      default:
        return const Color(0xFFE91E63);
    }
  }
}

// ── Cache entry ───────────────────────────────────────────────────────────────
class _CacheEntry {
  final List<NearbyPlace> places;
  final DateTime fetchedAt;
  _CacheEntry(this.places) : fetchedAt = DateTime.now();
  bool get isStale =>
      DateTime.now().difference(fetchedAt) > const Duration(minutes: 5);
}

// ── Screen ────────────────────────────────────────────────────────────────────
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  // Map
  final MapController _mapController = MapController();
  LatLng _userLoc = const LatLng(9.9312, 76.2673); // default Kochi

  // Data
  List<NearbyPlace> _places = [];
  String _selectedType = 'all';
  bool _isLoading = true;
  String? _errorMsg;
  String _source = '';

  // 5-minute cache keyed by "type@lat,lng"
  final Map<String, _CacheEntry> _cache = {};

  // FAB animation
  late AnimationController _fabController;
  late Animation<double> _fabScale;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _fabScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
    _initMap();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  // ── Init ───────────────────────────────────────────────────────────────
  Future<void> _initMap() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      // 5-second timeout — geolocator can hang on web (requires HTTPS).
      // Falls back to default Kochi location silently.
      final loc = await LocationService.getCurrentLocation()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => const LatLng(9.9312, 76.2673),
          );
      // Guard against NaN / infinite values from geolocator
      if (!loc.latitude.isNaN &&
          !loc.longitude.isNaN &&
          loc.latitude.isFinite &&
          loc.longitude.isFinite &&
          !(loc.latitude == 0 && loc.longitude == 0)) {
        if (mounted) setState(() => _userLoc = loc);
      } else {
        debugPrint('⚠️ GPS returned invalid coords, using default');
      }
    } catch (e) {
      debugPrint('⚠️ Location error (using default): $e');
    }
    // Always fetch places regardless of location success
    await _fetchPlaces();
  }

  // ── Fetch from backend ────────────────────────────────────────────────────
  Future<void> _fetchPlaces() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMsg = null;
      });
    }

    final types = _selectedType == 'all'
        ? ['hospitals', 'pharmacies', 'markets']
        : [_selectedType];

    final List<NearbyPlace> combined = [];
    String lastSource = '';

    try {
      for (final t in types) {
        final cacheKey =
            '$t@${_userLoc.latitude.toStringAsFixed(4)},${_userLoc.longitude.toStringAsFixed(4)}';
        final cached = _cache[cacheKey];
        if (cached != null && !cached.isStale) {
          combined.addAll(cached.places);
          lastSource = 'cache';
          continue;
        }

        try {
          final uri = Uri.parse(
            '$_kBaseUrl/nearby?lat=${_userLoc.latitude}&lng=${_userLoc.longitude}&type=$t&radius=3',
          );
          final response = await http
              .get(uri)
              .timeout(const Duration(seconds: 12));

          if (response.statusCode == 200) {
            final body = jsonDecode(response.body) as Map<String, dynamic>;
            final data = (body['data'] as List<dynamic>? ?? [])
                .map((e) => NearbyPlace.fromJson(e as Map<String, dynamic>))
                .toList();
            data.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
            final limited = data.take(20).toList();
            _cache[cacheKey] = _CacheEntry(limited);
            combined.addAll(limited);
            lastSource = body['source'] as String? ?? 'api';
          }
        } catch (e) {
          debugPrint('⚠️ Fetch $t failed: $e');
        }
      }
    } finally {
      // ALWAYS dismiss loader — even if every request timed out / threw
      if (mounted) {
        combined.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        final results = combined.take(20).toList();
        setState(() {
          _places = results;
          _source = lastSource;
          _isLoading = false;
          _errorMsg = results.isEmpty
              ? '📍 No places found. Backend may be waking up — tap 🔍 to retry.'
              : null;
        });
      }
    }
  }

  void _filterPlaces(String type) {
    setState(() => _selectedType = type);
    _fetchPlaces();
  }

  // ── Map markers ────────────────────────────────────────────────────────────
  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // User dot
    markers.add(Marker(
      width: 60,
      height: 60,
      point: _userLoc,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.45),
              blurRadius: 8,
              spreadRadius: 3,
            ),
          ],
        ),
        child:
            const Icon(Icons.my_location, color: Colors.white, size: 26),
      ),
    ));

    // Place markers
    for (final p in _places) {
      markers.add(Marker(
        width: 56,
        height: 56,
        point: LatLng(p.lat, p.lng),
        child: GestureDetector(
          onTap: () => _showDetails(p),
          child: Tooltip(
            message: p.name,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p.markerColor,
                boxShadow: [
                  BoxShadow(
                    color: p.markerColor.withValues(alpha: 0.5),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(p.icon, style: const TextStyle(fontSize: 22)),
              ),
            ),
          ),
        ),
      ));
    }
    return markers;
  }

  // ── Bottom sheet detail ────────────────────────────────────────────────────
  void _showDetails(NearbyPlace place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlaceDetailSheet(place: place),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🏥 Find Nearby Care',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFE91E63),
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_source.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _source == 'cache' ? '📦 cached' : '🌍 live',
                    style: const TextStyle(fontSize: 11, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLoc,
              initialZoom: 14,
              minZoom: 5,
              maxZoom: 19,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.femi_friendly',
                retinaMode: false,
              ),
              MarkerLayer(markers: _buildMarkers()),
            ],
          ),

          // ── Full-screen loader ────────────────────────────────────────────
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.35),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFE91E63)),
                    SizedBox(height: 12),
                    Text(
                      'Finding nearby care...',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

          // ── Filter chips ──────────────────────────────────────────────────
          if (!_isLoading)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chip('All', 'all', const Color(0xFFE91E63)),
                    const SizedBox(width: 8),
                    _chip('🏥 Hospitals', 'hospitals', Colors.red),
                    const SizedBox(width: 8),
                    _chip('💊 Pharmacies', 'pharmacies',
                        const Color(0xFF26A65B)),
                    const SizedBox(width: 8),
                    _chip('🛒 Markets', 'markets', const Color(0xFFE67E22)),
                  ],
                ),
              ),
            ),

          // ── Error banner ──────────────────────────────────────────────────
          if (_errorMsg != null && !_isLoading)
            Positioned(
              top: 60,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  _errorMsg!,
                  style: const TextStyle(
                      color: Colors.grey, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // ── Bottom places list ────────────────────────────────────────────
          if (!_isLoading)
            Positioned(
              bottom: 80,
              left: 12,
              right: 12,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 210),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _places.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            '📍 No places found. Tap 🔍 to search again.',
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        itemCount: _places.length,
                        separatorBuilder: (_, __) => const Divider(
                            height: 1, indent: 56),
                        itemBuilder: (_, i) {
                          final p = _places[i];
                          return ListTile(
                            onTap: () => _showDetails(p),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: p.markerColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(p.icon,
                                    style:
                                        const TextStyle(fontSize: 20)),
                              ),
                            ),
                            title: Text(
                              p.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${p.distanceKm.toStringAsFixed(1)} km away${p.address.isNotEmpty ? ' · ${p.address}' : ''}',
                              style: const TextStyle(fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (p.rating != 'N/A')
                                  Text('⭐ ${p.rating}',
                                      style:
                                          const TextStyle(fontSize: 11)),
                                const SizedBox(width: 4),
                                const Icon(Icons.chevron_right,
                                    color: Color(0xFFE91E63)),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),

          // ── Animated FAB ──────────────────────────────────────────────────
          Positioned(
            bottom: 16,
            right: 16,
            child: ScaleTransition(
              scale: _fabScale,
              child: FloatingActionButton.extended(
                heroTag: 'find_nearby_fab',
                onPressed: _isLoading ? null : _initMap,
                backgroundColor: const Color(0xFFE91E63),
                icon: const Icon(Icons.search, color: Colors.white),
                label: const Text(
                  'Find Nearby Care',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter chip helper ─────────────────────────────────────────────────────
  Widget _chip(String label, String type, Color color) {
    final selected = _selectedType == type;
    return GestureDetector(
      onTap: () => _filterPlaces(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight:
                selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ── Detail bottom sheet ────────────────────────────────────────────────────────
class _PlaceDetailSheet extends StatelessWidget {
  final NearbyPlace place;
  const _PlaceDetailSheet({required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: place.markerColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(place.icon,
                      style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      place.type.toUpperCase(),
                      style: TextStyle(
                          fontSize: 11, color: place.markerColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 16),

            // Info chips
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.directions_walk,
                  label: '${place.distanceKm.toStringAsFixed(1)} km',
                  color: Colors.blue,
                ),
                if (place.rating != 'N/A')
                  _InfoChip(
                    icon: Icons.star,
                    label: place.rating,
                    color: Colors.orange,
                  ),
                if (place.address.isNotEmpty)
                  _InfoChip(
                    icon: Icons.location_on,
                    label: place.address,
                    color: const Color(0xFFE91E63),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Phone
            if (place.phone.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  const Icon(Icons.phone,
                      color: Color(0xFFE91E63), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      place.phone,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ]),
              ),

            const SizedBox(height: 16),

            // Action buttons
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE91E63)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Close'),
                ),
              ),
              const SizedBox(width: 12),
              if (place.phone.isNotEmpty)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final uri =
                          Uri.parse('tel:${place.phone}');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.call,
                        color: Colors.white, size: 16),
                    label: const Text('Call',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              if (place.phone.isEmpty)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.directions,
                        color: Colors.white, size: 16),
                    label: const Text('Navigate',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
    );
  }
}
