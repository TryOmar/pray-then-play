class PrayerTimeInfo {
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final bool isCurrent;
  final Duration timeRemaining;

  const PrayerTimeInfo({
    required this.name,
    required this.startTime,
    required this.endTime,
    this.isCurrent = false,
    required this.timeRemaining,
  });

  /// How far through the prayer window we are (0.0 to 1.0)
  double get windowProgress {
    final totalWindow = endTime.difference(startTime).inSeconds;
    if (totalWindow <= 0) return 0;
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    return (elapsed / totalWindow).clamp(0.0, 1.0);
  }

  /// Minutes remaining until this prayer starts
  int get minutesUntilStart {
    final now = DateTime.now();
    if (now.isAfter(startTime)) return 0;
    return startTime.difference(now).inMinutes;
  }

  /// Minutes remaining in the prayer window
  int get minutesRemainingInWindow {
    final now = DateTime.now();
    if (now.isAfter(endTime)) return 0;
    return endTime.difference(now).inMinutes;
  }
}

class DailyPrayerTimes {
  final DateTime date;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  const DailyPrayerTimes({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  List<MapEntry<String, DateTime>> get allPrayers => [
        MapEntry('Fajr', fajr),
        MapEntry('Dhuhr', dhuhr),
        MapEntry('Asr', asr),
        MapEntry('Maghrib', maghrib),
        MapEntry('Isha', isha),
      ];

  List<MapEntry<String, DateTime>> get allTimings => [
        MapEntry('Fajr', fajr),
        MapEntry('Sunrise', sunrise),
        MapEntry('Dhuhr', dhuhr),
        MapEntry('Asr', asr),
        MapEntry('Maghrib', maghrib),
        MapEntry('Isha', isha),
      ];

  /// Get the next prayer after the given time
  MapEntry<String, DateTime>? getNextPrayer(DateTime now) {
    for (final prayer in allTimings) {
      if (prayer.value.isAfter(now)) {
        return prayer;
      }
    }
    return null; // All prayers passed for today
  }

  /// Get the current prayer (prayer whose window we're in)
  MapEntry<String, DateTime>? getCurrentPrayer(DateTime now) {
    MapEntry<String, DateTime>? current;
    for (final prayer in allTimings) {
      if (prayer.value.isBefore(now) || prayer.value.isAtSameMomentAs(now)) {
        current = prayer;
      }
    }
    return current;
  }

  /// Get the time of a specific prayer by name
  DateTime? getTimeFor(String name) {
    switch (name.toLowerCase()) {
      case 'fajr':
        return fajr;
      case 'sunrise':
        return sunrise;
      case 'dhuhr':
        return dhuhr;
      case 'asr':
        return asr;
      case 'maghrib':
        return maghrib;
      case 'isha':
        return isha;
      default:
        return null;
    }
  }

  /// Get the end time of a prayer window (= start of next prayer)
  DateTime? getEndTimeForPrayer(String prayerName) {
    final timings = allTimings;
    for (int i = 0; i < timings.length; i++) {
      if (timings[i].key == prayerName && i + 1 < timings.length) {
        return timings[i + 1].value;
      }
    }
    return null;
  }
}
