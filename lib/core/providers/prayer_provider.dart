import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prayer_time.dart';
import '../services/prayer_service.dart';
import '../services/storage_service.dart';
import 'settings_provider.dart';

// Live prayer times provider that updates when method or location changes
final dailyPrayerTimesProvider = Provider<DailyPrayerTimes?>((ref) {
  final method = ref.watch(calculationMethodProvider);
  final asrMethod = ref.watch(asrMethodProvider);
  final lat = StorageService.latitude;
  final lng = StorageService.longitude;

  if (lat == null || lng == null) return null;

  return PrayerService.calculatePrayerTimes(
    latitude: lat,
    longitude: lng,
    date: DateTime.now(),
    method: method,
    asrMethod: asrMethod,
  );
});

// Next prayer provider
final nextPrayerProvider = Provider<MapEntry<String, DateTime>?>((ref) {
  final method = ref.watch(calculationMethodProvider);
  final asrMethod = ref.watch(asrMethodProvider);
  final lat = StorageService.latitude;
  final lng = StorageService.longitude;

  if (lat == null || lng == null) return null;

  return PrayerService.getNextPrayer(
    latitude: lat,
    longitude: lng,
    method: method,
    asrMethod: asrMethod,
  );
});

// Prayer tracking (today's completed prayers)
final prayerTrackingProvider =
    StateNotifierProvider<PrayerTrackingNotifier, Map<String, bool>>((ref) {
  return PrayerTrackingNotifier();
});

class PrayerTrackingNotifier extends StateNotifier<Map<String, bool>> {
  PrayerTrackingNotifier() : super(StorageService.getTodayPrayerStatus());

  void togglePrayer(String prayerName) {
    StorageService.togglePrayer(prayerName);
    state = StorageService.getTodayPrayerStatus();
  }

  void markCompleted(String prayerName) {
    StorageService.markPrayerCompleted(prayerName);
    state = StorageService.getTodayPrayerStatus();
  }
}
