import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class LocationService {
  /// Check if location services are enabled and permission is granted
  static Future<bool> isLocationAvailable() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (_) {
      return false;
    }
  }

  /// Request location permission
  static Future<LocationPermission> requestPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission;
    } catch (_) {
      return LocationPermission.denied;
    }
  }

  /// Get current position with IP fallback on desktop PCs
  static Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (e) {
      debugPrint('[LocationService] GPS getCurrentPosition failed: $e');
      return null;
    }
  }

  /// Fallback IP-based geolocation for desktop PCs without GPS hardware
  static Future<Map<String, dynamic>?> fetchIpLocation() async {
    try {
      final response = await http.get(
        Uri.parse('https://ipapi.co/json/'),
        headers: {'User-Agent': 'PrayThenPlay/2.0'},
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final lat = (data['latitude'] as num?)?.toDouble();
        final lng = (data['longitude'] as num?)?.toDouble();
        final city = data['city'] as String? ?? '';
        final country = data['country_name'] as String? ?? '';
        if (lat != null && lng != null) {
          return {
            'latitude': lat,
            'longitude': lng,
            'city': city.isNotEmpty ? city : 'Local PC Location',
            'country': country,
          };
        }
      }
    } catch (e) {
      debugPrint('[LocationService] IP Geolocation fallback failed: $e');
    }
    return null;
  }

  /// Get city name from coordinates safely across mobile and desktop
  static Future<String> getCityName(double lat, double lng) async {
    // 1. On Android/iOS use native geocoding
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      try {
        final placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final city = place.locality ?? place.subAdministrativeArea ?? '';
          final country = place.country ?? '';
          if (city.isNotEmpty && country.isNotEmpty) {
            return '$city, $country';
          }
          return city.isNotEmpty ? city : country;
        }
      } catch (_) {}
    }

    // 2. Fallback via free Nominatim OpenStreetMap reverse geocoding on desktop
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=10');
      final res = await http.get(url, headers: {
        'User-Agent': 'PrayThenPlay-App/2.0'
      }).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final city = address['city'] ??
              address['town'] ??
              address['village'] ??
              address['state'] ??
              '';
          final country = address['country'] ?? '';
          if (city.toString().isNotEmpty && country.toString().isNotEmpty) {
            return '$city, $country';
          }
          return city.toString().isNotEmpty ? city.toString() : country.toString();
        }
      }
    } catch (_) {}

    return 'Location ($lat, $lng)';
  }
}
