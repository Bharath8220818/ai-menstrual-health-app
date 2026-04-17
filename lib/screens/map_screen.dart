// filepath: lib/screens/map_screen.dart
// OpenStreetMap integration for displaying user location and nearby healthcare services

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:femi_friendly/services/location_service.dart';
import 'dart:math' as math;

class NearbyPlace {
  final String name;
  final double lat;
  final double lng;
  final String type; // 'hospital', 'pharmacy', 'market'
  final String address;
  final double distance;
  final double rating;
  final String phone;

  NearbyPlace({
    required this.name,
    required this.lat,
    required this.lng,
    required this.type,
    required this.address,
    required this.distance,
    required this.rating,
    required this.phone,
  });
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController mapController;
  LatLng currentLocation = const LatLng(9.9312, 76.2673); // Default: Kochi, India
  List<NearbyPlace> nearbyPlaces = [];
  String selectedType = 'all'; // all, hospitals, pharmacies, markets
  bool isLoading = true;

  // Sample healthcare locations around Kochi
  final List<NearbyPlace> sampleHospitals = [
    NearbyPlace(
      name: 'City Hospital',
      lat: 9.9312,
      lng: 76.2673,
      type: 'hospital',
      address: 'Kochi, Kerala',
      distance: 0.5,
      rating: 4.8,
      phone: '+91-484-2403000',
    ),
    NearbyPlace(
      name: 'Medical Center',
      lat: 9.9350,
      lng: 76.2750,
      type: 'hospital',
      address: 'Panampilly Nagar, Kochi',
      distance: 1.2,
      rating: 4.6,
      phone: '+91-484-2500000',
    ),
    NearbyPlace(
      name: 'Apollo Medical',
      lat: 9.9280,
      lng: 76.2600,
      type: 'hospital',
      address: 'Ernakulatthapan, Kochi',
      distance: 1.8,
      rating: 4.7,
      phone: '+91-484-2304000',
    ),
  ];

  final List<NearbyPlace> samplePharmacies = [
    NearbyPlace(
      name: 'MediCare Pharmacy',
      lat: 9.9330,
      lng: 76.2690,
      type: 'pharmacy',
      address: 'Near Fort Kochi',
      distance: 0.8,
      rating: 4.5,
      phone: '+91-484-2221000',
    ),
    NearbyPlace(
      name: 'HealthCare Plus',
      lat: 9.9300,
      lng: 76.2720,
      type: 'pharmacy',
      address: 'Mattancherry, Kochi',
      distance: 1.5,
      rating: 4.4,
      phone: '+91-484-2244000',
    ),
    NearbyPlace(
      name: 'Wellness Store',
      lat: 9.9360,
      lng: 76.2650,
      type: 'pharmacy',
      address: 'Edappally, Kochi',
      distance: 2.1,
      rating: 4.3,
      phone: '+91-484-2340000',
    ),
  ];

  final List<NearbyPlace> sampleMarkets = [
    NearbyPlace(
      name: 'Fresh Market Supermarket',
      lat: 9.9290,
      lng: 76.2680,
      type: 'market',
      address: 'Main Bazaar',
      distance: 1.2,
      rating: 4.2,
      phone: '+91-484-2200000',
    ),
    NearbyPlace(
      name: 'Organic Store',
      lat: 9.9340,
      lng: 76.2760,
      type: 'market',
      address: 'High Street',
      distance: 1.9,
      rating: 4.6,
      phone: '+91-484-2250000',
    ),
    NearbyPlace(
      name: 'Health Products Mart',
      lat: 9.9380,
      lng: 76.2620,
      type: 'market',
      address: 'Shopping District',
      distance: 2.3,
      rating: 4.4,
      phone: '+91-484-2300000',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Get user's current location
      LatLng userLocation = await LocationService.getCurrentLocation();
      setState(() {
        currentLocation = userLocation;
      });

      // Load nearby places
      await _loadNearbyPlaces();
    } catch (e) {
      print('❌ Error initializing map: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadNearbyPlaces() async {
    // In a real app, you would fetch this from an API or OpenStreetMap Overpass API
    // For now, using sample data
    List<NearbyPlace> allPlaces = [
      ...sampleHospitals,
      ...samplePharmacies,
      ...sampleMarkets,
    ];

    setState(() {
      if (selectedType == 'all') {
        nearbyPlaces = allPlaces;
      } else if (selectedType == 'hospitals') {
        nearbyPlaces = sampleHospitals;
      } else if (selectedType == 'pharmacies') {
        nearbyPlaces = samplePharmacies;
      } else if (selectedType == 'markets') {
        nearbyPlaces = sampleMarkets;
      }
    });
  }

  void _filterPlaces(String type) {
    setState(() {
      selectedType = type;
    });
    _loadNearbyPlaces();
  }

  Color _getMarkerColor(String type) {
    switch (type) {
      case 'hospital':
        return Colors.red;
      case 'pharmacy':
        return Colors.green;
      case 'market':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _getMarkerIcon(String type) {
    switch (type) {
      case 'hospital':
        return '🏥';
      case 'pharmacy':
        return '💊';
      case 'market':
        return '🛒';
      default:
        return '📍';
    }
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    // Add user location marker
    markers.add(
      Marker(
        width: 80,
        height: 80,
        point: currentLocation,
        child: Tooltip(
          message: 'Your Location',
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.5),
                  blurRadius: 5,
                  spreadRadius: 2,
                )
              ],
            ),
            child: const Center(
              child: Icon(Icons.location_on, color: Colors.white, size: 30),
            ),
          ),
        ),
      ),
    );

    // Add place markers
    for (var place in nearbyPlaces) {
      markers.add(
        Marker(
          width: 80,
          height: 80,
          point: LatLng(place.lat, place.lng),
          child: GestureDetector(
            onTap: () => _showPlaceDetails(place),
            child: Tooltip(
              message: place.name,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getMarkerColor(place.type),
                  boxShadow: [
                    BoxShadow(
                      color: _getMarkerColor(place.type).withOpacity(0.5),
                      blurRadius: 5,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    _getMarkerIcon(place.type),
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  void _showPlaceDetails(NearbyPlace place) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  _getMarkerIcon(place.type),
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        place.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Address
            Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFFE91E63), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    place.address,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Distance & Rating
            Row(
              children: [
                // Distance
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '📏 ${place.distance.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Rating
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        place.rating.toString(),
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Phone
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone, color: Color(0xFFE91E63), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      place.phone,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE91E63)),
                    ),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Calling ${place.name}...'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                    ),
                    child: const Text('Call'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Healthcare Services'),
        backgroundColor: const Color(0xFFE91E63),
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE91E63)),
            )
          : Stack(
              children: [
                // Map
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: currentLocation,
                    initialZoom: 14,
                    minZoom: 5,
                    maxZoom: 18,
                  ),
                  children: [
                    // OpenStreetMap Tile Layer
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.femi_friendly',
                      retinaMode: false,
                    ),
                    // Markers Layer
                    MarkerLayer(
                      markers: _buildMarkers(),
                    ),
                  ],
                ),

                // Filter Chips
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: selectedType == 'all',
                          onSelected: (_) => _filterPlaces('all'),
                          selectedColor: const Color(0xFFE91E63),
                          labelStyle: TextStyle(
                            color: selectedType == 'all'
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('🏥 Hospitals'),
                          selected: selectedType == 'hospitals',
                          onSelected: (_) => _filterPlaces('hospitals'),
                          selectedColor: Colors.red.withOpacity(0.7),
                          labelStyle: TextStyle(
                            color: selectedType == 'hospitals'
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('💊 Pharmacies'),
                          selected: selectedType == 'pharmacies',
                          onSelected: (_) => _filterPlaces('pharmacies'),
                          selectedColor: Colors.green.withOpacity(0.7),
                          labelStyle: TextStyle(
                            color: selectedType == 'pharmacies'
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('🛒 Markets'),
                          selected: selectedType == 'markets',
                          onSelected: (_) => _filterPlaces('markets'),
                          selectedColor: Colors.orange.withOpacity(0.7),
                          labelStyle: TextStyle(
                            color: selectedType == 'markets'
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Place List (Bottom Sheet Style)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: nearbyPlaces.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                '📍 No places found',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: nearbyPlaces.length,
                            itemBuilder: (context, index) {
                              final place = nearbyPlaces[index];
                              return ListTile(
                                onTap: () => _showPlaceDetails(place),
                                leading: Text(
                                  _getMarkerIcon(place.type),
                                  style: const TextStyle(fontSize: 24),
                                ),
                                title: Text(
                                  place.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  '${place.distance.toStringAsFixed(1)} km away',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '⭐ ${place.rating}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.navigate_next,
                                        color: Color(0xFFE91E63)),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),

                // Find Nearby Button (Floating)
                Positioned(
                  bottom: 230,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🔍 Searching for nearby services...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      _initializeMap();
                    },
                    backgroundColor: const Color(0xFFE91E63),
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ],
            ),
    );
  }
}
