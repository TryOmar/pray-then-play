class CityInfo {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  const CityInfo({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  String get displayName => '$name, $country';
}

class CityDatabase {
  static const List<CityInfo> popularCities = [
    // Middle East & North Africa
    CityInfo(name: 'Makkah', country: 'Saudi Arabia', latitude: 21.4225, longitude: 39.8262),
    CityInfo(name: 'Madinah', country: 'Saudi Arabia', latitude: 24.5247, longitude: 39.5692),
    CityInfo(name: 'Riyadh', country: 'Saudi Arabia', latitude: 24.7136, longitude: 46.6753),
    CityInfo(name: 'Jeddah', country: 'Saudi Arabia', latitude: 21.5433, longitude: 39.1728),
    CityInfo(name: 'Cairo', country: 'Egypt', latitude: 30.0444, longitude: 31.2357),
    CityInfo(name: 'Alexandria', country: 'Egypt', latitude: 31.2001, longitude: 29.9187),
    CityInfo(name: 'Dubai', country: 'United Arab Emirates', latitude: 25.2048, longitude: 55.2708),
    CityInfo(name: 'Abu Dhabi', country: 'United Arab Emirates', latitude: 24.4539, longitude: 54.3773),
    CityInfo(name: 'Doha', country: 'Qatar', latitude: 25.2854, longitude: 51.5310),
    CityInfo(name: 'Kuwait City', country: 'Kuwait', latitude: 29.3759, longitude: 47.9774),
    CityInfo(name: 'Manama', country: 'Bahrain', latitude: 26.2285, longitude: 50.5860),
    CityInfo(name: 'Muscat', country: 'Oman', latitude: 23.5880, longitude: 58.3829),
    CityInfo(name: 'Amman', country: 'Jordan', latitude: 31.9454, longitude: 35.9284),
    CityInfo(name: 'Beirut', country: 'Lebanon', latitude: 33.8938, longitude: 35.5018),
    CityInfo(name: 'Baghdad', country: 'Iraq', latitude: 33.3152, longitude: 44.3661),
    CityInfo(name: 'Algiers', country: 'Algeria', latitude: 36.7538, longitude: 3.0588),
    CityInfo(name: 'Casablanca', country: 'Morocco', latitude: 33.5731, longitude: -7.5898),
    CityInfo(name: 'Rabat', country: 'Morocco', latitude: 34.0209, longitude: -6.8416),
    CityInfo(name: 'Tunis', country: 'Tunisia', latitude: 36.8065, longitude: 10.1815),
    CityInfo(name: 'Tripoli', country: 'Libya', latitude: 32.8872, longitude: 13.1913),
    
    // Turkey & Central Asia
    CityInfo(name: 'Istanbul', country: 'Turkey', latitude: 41.0082, longitude: 28.9784),
    CityInfo(name: 'Ankara', country: 'Turkey', latitude: 39.9334, longitude: 32.8597),
    CityInfo(name: 'Baku', country: 'Azerbaijan', latitude: 40.4093, longitude: 49.8671),
    CityInfo(name: 'Tashkent', country: 'Uzbekistan', latitude: 41.2995, longitude: 69.2401),
    CityInfo(name: 'Almaty', country: 'Kazakhstan', latitude: 43.2220, longitude: 76.8512),

    // South & Southeast Asia
    CityInfo(name: 'Karachi', country: 'Pakistan', latitude: 24.8607, longitude: 67.0011),
    CityInfo(name: 'Lahore', country: 'Pakistan', latitude: 31.5204, longitude: 74.3587),
    CityInfo(name: 'Islamabad', country: 'Pakistan', latitude: 33.6844, longitude: 73.0479),
    CityInfo(name: 'Dhaka', country: 'Bangladesh', latitude: 23.8103, longitude: 90.4125),
    CityInfo(name: 'Jakarta', country: 'Indonesia', latitude: -6.2088, longitude: 106.8456),
    CityInfo(name: 'Surabaya', country: 'Indonesia', latitude: -7.2575, longitude: 112.7521),
    CityInfo(name: 'Kuala Lumpur', country: 'Malaysia', latitude: 3.1390, longitude: 101.6869),
    CityInfo(name: 'Singapore', country: 'Singapore', latitude: 1.3521, longitude: 103.8198),
    CityInfo(name: 'Mumbai', country: 'India', latitude: 19.0760, longitude: 72.8777),
    CityInfo(name: 'Delhi', country: 'India', latitude: 28.7041, longitude: 77.1025),

    // Europe & Americas
    CityInfo(name: 'London', country: 'United Kingdom', latitude: 51.5074, longitude: -0.1278),
    CityInfo(name: 'Birmingham', country: 'United Kingdom', latitude: 52.4862, longitude: -1.8904),
    CityInfo(name: 'Paris', country: 'France', latitude: 48.8566, longitude: 2.3522),
    CityInfo(name: 'Berlin', country: 'Germany', latitude: 52.5200, longitude: 13.4050),
    CityInfo(name: 'Amsterdam', country: 'Netherlands', latitude: 52.3676, longitude: 4.9041),
    CityInfo(name: 'Toronto', country: 'Canada', latitude: 43.6532, longitude: -79.3832),
    CityInfo(name: 'New York', country: 'United States', latitude: 40.7128, longitude: -74.0060),
    CityInfo(name: 'Los Angeles', country: 'United States', latitude: 34.0522, longitude: -118.2437),
    CityInfo(name: 'Chicago', country: 'United States', latitude: 41.8781, longitude: -87.6298),
    CityInfo(name: 'Houston', country: 'United States', latitude: 29.7604, longitude: -95.3698),
    CityInfo(name: 'Sydney', country: 'Australia', latitude: -33.8688, longitude: 151.2093),
    CityInfo(name: 'Melbourne', country: 'Australia', latitude: -37.8136, longitude: 144.9631),
  ];

  static List<CityInfo> search(String query) {
    if (query.trim().isEmpty) return popularCities;
    final q = query.toLowerCase().trim();
    return popularCities.where((c) =>
        c.name.toLowerCase().contains(q) ||
        c.country.toLowerCase().contains(q)).toList();
  }
}
