import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Check if location services are enabled and permission is granted
  static Future<bool> isLocationAvailable() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Request location permission
  static Future<LocationPermission> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  /// Get current position
  static Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  /// Get city name from coordinates
  static Future<String> getCityName(double lat, double lng) async {
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
    } catch (_) {
      // Geocoding failed silently
    }
    return 'Unknown location';
  }
}
