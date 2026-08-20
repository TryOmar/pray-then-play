import 'package:adhan/adhan.dart' as adhan;
import '../constants/app_constants.dart';
import '../constants/prayer_constants.dart';
import '../models/prayer_time.dart';

class PrayerService {
  /// Calculate prayer times for a given date, location, method, and Asr Madhhab
  static DailyPrayerTimes calculatePrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
    CalculationMethodType method = CalculationMethodType.muslimWorldLeague,
    AsrMethodType asrMethod = AsrMethodType.standard,
  }) {
    final coordinates = adhan.Coordinates(latitude, longitude);
    final dateComponents = adhan.DateComponents.from(date);
    final params = _getCalculationParameters(method);

    if (asrMethod == AsrMethodType.hanafi) {
      params.madhab = adhan.Madhab.hanafi;
    } else {
      params.madhab = adhan.Madhab.shafi;
    }

    final prayerTimes = adhan.PrayerTimes(
      coordinates,
      dateComponents,
      params,
    );

    return DailyPrayerTimes(
      date: date,
      fajr: prayerTimes.fajr,
      sunrise: prayerTimes.sunrise,
      dhuhr: prayerTimes.dhuhr,
      asr: prayerTimes.asr,
      maghrib: prayerTimes.maghrib,
      isha: prayerTimes.isha,
    );
  }

  /// Get the next upcoming prayer
  static MapEntry<String, DateTime>? getNextPrayer({
    required double latitude,
    required double longitude,
    CalculationMethodType method = CalculationMethodType.muslimWorldLeague,
    AsrMethodType asrMethod = AsrMethodType.standard,
  }) {
    final now = DateTime.now();
    final today = calculatePrayerTimes(
      latitude: latitude,
      longitude: longitude,
      date: now,
      method: method,
      asrMethod: asrMethod,
    );

    final next = today.getNextPrayer(now);
    if (next != null) return next;

    // If all prayers passed today, get tomorrow's Fajr
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowPrayers = calculatePrayerTimes(
      latitude: latitude,
      longitude: longitude,
      date: tomorrow,
      method: method,
      asrMethod: asrMethod,
    );

    return MapEntry('Fajr', tomorrowPrayers.fajr);
  }

  /// Get minutes until next prayer
  static int getMinutesUntilNextPrayer({
    required double latitude,
    required double longitude,
    CalculationMethodType method = CalculationMethodType.muslimWorldLeague,
    AsrMethodType asrMethod = AsrMethodType.standard,
  }) {
    final nextPrayer = getNextPrayer(
      latitude: latitude,
      longitude: longitude,
      method: method,
      asrMethod: asrMethod,
    );

    if (nextPrayer == null) return 999;
    return nextPrayer.value.difference(DateTime.now()).inMinutes;
  }

  static adhan.CalculationParameters _getCalculationParameters(
      CalculationMethodType method) {
    switch (method) {
      case CalculationMethodType.muslimWorldLeague:
        return adhan.CalculationMethod.muslim_world_league.getParameters();
      case CalculationMethodType.egyptian:
        return adhan.CalculationMethod.egyptian.getParameters();
      case CalculationMethodType.karachi:
        return adhan.CalculationMethod.karachi.getParameters();
      case CalculationMethodType.ummAlQura:
        return adhan.CalculationMethod.umm_al_qura.getParameters();
      case CalculationMethodType.dubai:
        return adhan.CalculationMethod.dubai.getParameters();
      case CalculationMethodType.qatar:
        return adhan.CalculationMethod.qatar.getParameters();
      case CalculationMethodType.kuwait:
        return adhan.CalculationMethod.kuwait.getParameters();
      case CalculationMethodType.moonsightingCommittee:
        return adhan.CalculationMethod.moon_sighting_committee.getParameters();
      case CalculationMethodType.singapore:
        return adhan.CalculationMethod.singapore.getParameters();
      case CalculationMethodType.turkey:
        return adhan.CalculationMethod.turkey.getParameters();
      case CalculationMethodType.tehran:
        return adhan.CalculationMethod.tehran.getParameters();
      case CalculationMethodType.northAmerica:
        return adhan.CalculationMethod.north_america.getParameters();
    }
  }
}
