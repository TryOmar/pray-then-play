import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_salah/core/models/prayer_record.dart';

void main() {
  group('PrayerRecord Domain & Classification Tests', () {
    test('deriveClassification classifies prayer within on-time window as onTime', () {
      final adhan = DateTime(2026, 8, 20, 12, 30);
      final prayedAt = DateTime(2026, 8, 20, 12, 45); // 15 mins after Adhan

      final classification = PrayerRecordItem.deriveClassification(
        adhanTime: adhan,
        completedAt: prayedAt,
        onTimeWindowMinutes: 60,
      );

      expect(classification, equals(PrayerClassification.onTime));
    });

    test('deriveClassification classifies prayer beyond threshold as late', () {
      final adhan = DateTime(2026, 8, 20, 12, 30);
      final prayedAt = DateTime(2026, 8, 20, 14, 00); // 90 mins after Adhan

      final classification = PrayerRecordItem.deriveClassification(
        adhanTime: adhan,
        completedAt: prayedAt,
        onTimeWindowMinutes: 60,
      );

      expect(classification, equals(PrayerClassification.late));
    });

    test('PrayerRecordItem serializes and deserializes cleanly', () {
      final item = PrayerRecordItem(
        id: 'test_fajr_001',
        prayerName: 'Fajr',
        adhanTime: DateTime(2026, 8, 20, 4, 30),
        status: PrayerStatus.onTime,
        completedAt: DateTime(2026, 8, 20, 4, 45),
        classification: PrayerClassification.onTime,
        source: PrayerSource.automatic,
        notes: 'Congregation prayer',
        updatedAt: DateTime(2026, 8, 20, 4, 46),
      );

      final json = item.toJson();
      final restored = PrayerRecordItem.fromJson(json);

      expect(restored.id, equals(item.id));
      expect(restored.prayerName, equals('Fajr'));
      expect(restored.status, equals(PrayerStatus.onTime));
      expect(restored.classification, equals(PrayerClassification.onTime));
      expect(restored.source, equals(PrayerSource.automatic));
      expect(restored.notes, equals('Congregation prayer'));
    });

    test('DailyPrayerRecord computes consistency and on-time statistics accurately', () {
      final record = DailyPrayerRecord(
        date: DateTime(2026, 8, 20),
        prayers: {
          'Fajr': PrayerStatus.onTime,
          'Dhuhr': PrayerStatus.onTime,
          'Asr': PrayerStatus.late,
          'Maghrib': PrayerStatus.missed,
          'Isha': PrayerStatus.notRecorded,
        },
      );

      expect(record.completedCount, equals(3));
      expect(record.onTimeCount, equals(2));
      expect(record.lateCount, equals(1));
      expect(record.missedCount, equals(1));
      expect(record.consistencyRate, equals(60.0)); // 3/5 = 60%
    });
  });
}
