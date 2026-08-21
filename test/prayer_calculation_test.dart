import 'package:flutter_test/flutter_test.dart';
import 'package:pray_then_play/core/constants/app_constants.dart';
import 'package:pray_then_play/core/constants/prayer_constants.dart';
import 'package:pray_then_play/core/services/prayer_service.dart';

void main() {
  group('PrayerService Calculation Tests', () {
    test('calculatePrayerTimes generates all 5 daily prayers in chronological order', () {
      final schedule = PrayerService.calculatePrayerTimes(
        latitude: 30.0444, // Cairo, Egypt
        longitude: 31.2357,
        date: DateTime(2026, 8, 20),
        method: CalculationMethodType.egyptian,
        asrMethod: AsrMethodType.standard,
      );

      expect(schedule.fajr.isBefore(schedule.sunrise), isTrue);
      expect(schedule.sunrise.isBefore(schedule.dhuhr), isTrue);
      expect(schedule.dhuhr.isBefore(schedule.asr), isTrue);
      expect(schedule.asr.isBefore(schedule.maghrib), isTrue);
      expect(schedule.maghrib.isBefore(schedule.isha), isTrue);
    });

    test('Hanafi Asr calculation produces later time than Standard (Shafi) Asr', () {
      final standardSchedule = PrayerService.calculatePrayerTimes(
        latitude: 24.7136, // Riyadh, Saudi Arabia
        longitude: 46.6753,
        date: DateTime(2026, 8, 20),
        method: CalculationMethodType.ummAlQura,
        asrMethod: AsrMethodType.standard,
      );

      final hanafiSchedule = PrayerService.calculatePrayerTimes(
        latitude: 24.7136,
        longitude: 46.6753,
        date: DateTime(2026, 8, 20),
        method: CalculationMethodType.ummAlQura,
        asrMethod: AsrMethodType.hanafi,
      );

      // Hanafi Asr (2x shadow) must occur strictly after Standard Asr (1x shadow)
      expect(hanafiSchedule.asr.isAfter(standardSchedule.asr), isTrue);
    });

    test('getNextPrayer correctly resolves upcoming prayer', () {
      final nextPrayer = PrayerService.getNextPrayer(
        latitude: 30.0444,
        longitude: 31.2357,
        method: CalculationMethodType.egyptian,
        asrMethod: AsrMethodType.standard,
      );

      expect(nextPrayer, isNotNull);
      expect(['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'].contains(nextPrayer!.key), isTrue);
    });
  });
}
