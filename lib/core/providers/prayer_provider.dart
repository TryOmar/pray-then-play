import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prayer_record.dart';
import '../models/prayer_time.dart';
import '../services/prayer_service.dart';
import '../services/storage_service.dart';
import 'settings_provider.dart';

/// Isolated live 1-second ticker stream provider.
/// Only widgets that specifically watch this provider will rebuild every second.
final liveSecondTickerProvider = StreamProvider.autoDispose<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});

/// Live prayer times provider that updates when method or location changes.
final dailyPrayerTimesProvider = Provider<DailyPrayerTimes?>((ref) {
  final method = ref.watch(calculationMethodProvider);
  final asrMethod = ref.watch(asrMethodProvider);
  final lat = StorageService.latitude ?? 21.4225;
  final lng = StorageService.longitude ?? 39.8262;

  return PrayerService.calculatePrayerTimes(
    latitude: lat,
    longitude: lng,
    date: DateTime.now(),
    method: method,
    asrMethod: asrMethod,
  );
});

/// Next prayer provider.
final nextPrayerProvider = Provider<MapEntry<String, DateTime>?>((ref) {
  final method = ref.watch(calculationMethodProvider);
  final asrMethod = ref.watch(asrMethodProvider);
  final lat = StorageService.latitude ?? 21.4225;
  final lng = StorageService.longitude ?? 39.8262;

  return PrayerService.getNextPrayer(
    latitude: lat,
    longitude: lng,
    method: method,
    asrMethod: asrMethod,
  );
});

/// Auditable Today's Prayer Record Provider (Multi-state).
final todayPrayerRecordProvider =
    StateNotifierProvider<PrayerTrackingNotifier, DailyPrayerRecord>((ref) {
  return PrayerTrackingNotifier();
});

/// Legacy compatibility map provider for simple boolean checks.
final prayerTrackingProvider = Provider<Map<String, bool>>((ref) {
  final record = ref.watch(todayPrayerRecordProvider);
  return {
    'Fajr': record.prayers['Fajr']?.isCompleted ?? false,
    'Dhuhr': record.prayers['Dhuhr']?.isCompleted ?? false,
    'Asr': record.prayers['Asr']?.isCompleted ?? false,
    'Maghrib': record.prayers['Maghrib']?.isCompleted ?? false,
    'Isha': record.prayers['Isha']?.isCompleted ?? false,
  };
});

class PrayerTrackingNotifier extends StateNotifier<DailyPrayerRecord> {
  PrayerTrackingNotifier() : super(StorageService.getDailyPrayerRecord(DateTime.now()));

  void refresh() {
    state = StorageService.getDailyPrayerRecord(DateTime.now());
  }

  Future<void> togglePrayer(String prayerName, {DateTime? adhanTime}) async {
    await StorageService.togglePrayer(prayerName, adhanTime: adhanTime);
    state = StorageService.getDailyPrayerRecord(DateTime.now());
  }

  Future<void> markCompleted(
    String prayerName, {
    PrayerStatus status = PrayerStatus.onTime,
    DateTime? completedAt,
    DateTime? adhanTime,
    PrayerSource source = PrayerSource.manual,
    String? notes,
  }) async {
    await StorageService.markPrayerCompleted(
      prayerName,
      status: status,
      completedAt: completedAt,
      adhanTime: adhanTime,
      source: source,
      notes: notes,
    );
    state = StorageService.getDailyPrayerRecord(DateTime.now());
  }

  Future<void> saveRecordItem(PrayerRecordItem item) async {
    await StorageService.savePrayerRecordItem(item, DateTime.now());
    state = StorageService.getDailyPrayerRecord(DateTime.now());
  }
}
