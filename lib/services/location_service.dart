// filepath: lib/services/location_service.dart
// Location Service for handling permissions and getting current position

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  /// Check if location service is enabled on device
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request location permission from user
  static Future<LocationPermission> requestLocationPermission() async {
    final LocationPermission permission = await Geolocator.requestPermission();
    return permission;
  }

  /// Check current location permission status
  static Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Get current device location as LatLng
  /// Returns default location (Kochi, India) if permission denied
  static Future<LatLng> getCurrentLocation() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('📍 Location services disabled');
        return const LatLng(9.9312, 76.2673); // Default: Kochi, India
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Handle permission results
      if (permission == LocationPermission.deniedForever) {
        debugPrint('📍 Location permissions permanently denied');
        return const LatLng(9.9312, 76.2673); // Default: Kochi, India
      }

      if (permission == LocationPermission.denied) {
        debugPrint('📍 Location permission denied');
        return const LatLng(9.9312, 76.2673); // Default: Kochi, India
      }

      // Try last-known position first (instant, no permission dialog wait)
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null &&
          lastKnown.latitude.isFinite &&
          lastKnown.longitude.isFinite &&
          !(lastKnown.latitude == 0 && lastKnown.longitude == 0)) {
        return LatLng(lastKnown.latitude, lastKnown.longitude);
      }

      // Get fresh high-accuracy position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      if (position.latitude.isFinite && position.longitude.isFinite) {
        return LatLng(position.latitude, position.longitude);
      }
      return const LatLng(9.9312, 76.2673); // Default: Kochi, India
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
      return const LatLng(9.9312, 76.2673); // Default: Kochi, India
    }
  }

  /// Get current position with all details
  static Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error: $e');
      return null;
    }
  }

  /// Calculate distance between two locations in kilometers
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const Distance distance = Distance();
    return distance(
      LatLng(lat1, lon1),
      LatLng(lat2, lon2),
    );
  }
}
