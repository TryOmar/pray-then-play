import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pray_then_play/core/services/storage_service.dart';
import 'package:pray_then_play/core/services/home_widget_service.dart';
import 'package:pray_then_play/core/providers/prayer_heatmap_provider.dart';
import 'package:pray_then_play/core/models/prayer_record.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.initialize();
  });

  group('Clean Heatmap & Data Management Tests', () {
    test('Fresh install starts with genuine clean slate (0 streak, 0 badges)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(prayerConsistencyProvider.notifier);
      final streak = notifier.getConsistencyStreak();
      final achievements = notifier.getAllAchievements();
      final hasHistory = notifier.hasAnyRecordedPrayers;

      expect(streak, equals(0), reason: 'Fresh install streak should be 0');
      expect(hasHistory, isFalse, reason: 'Fresh install should have no recorded history');
      expect(achievements.every((a) => !a.isUnlocked), isTrue,
          reason: 'All achievements should start locked on fresh install');
    });

    test('Recording a prayer on time unlocks first_step badge', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(prayerConsistencyProvider.notifier);
      final today = DateTime.now();

      await notifier.updatePrayerStatus(today, 'Dhuhr', PrayerStatus.onTime);

      final achievements = notifier.getAllAchievements();
      final firstStep = achievements.firstWhere((a) => a.id == 'first_step');

      expect(firstStep.isUnlocked, isTrue, reason: 'first_step badge should unlock after 1 on-time prayer');
      expect(notifier.hasAnyRecordedPrayers, isTrue);
    });

    test('Loading demo history populates 30 days and unlocks sample achievements', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(prayerConsistencyProvider.notifier);
      await notifier.loadDemoHistory();

      final achievements = notifier.getAllAchievements();
      final unlockedCount = achievements.where((a) => a.isUnlocked).length;

      expect(notifier.hasAnyRecordedPrayers, isTrue);
      expect(unlockedCount, greaterThanOrEqualTo(3));
      expect(StorageService.protectedPrayersCount, equals(18));
    });

    test('Resetting history restores clean slate', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(prayerConsistencyProvider.notifier);
      await notifier.loadDemoHistory();
      expect(notifier.hasAnyRecordedPrayers, isTrue);

      await notifier.resetHistory();
      expect(notifier.hasAnyRecordedPrayers, isFalse);
      expect(notifier.getConsistencyStreak(), equals(0));
      expect(StorageService.protectedPrayersCount, equals(0));
    });

    test('HomeWidgetService updateWidgets completes safely on any platform', () async {
      await expectLater(
        HomeWidgetService.updateWidgets(streak: 5),
        completes,
      );
    });
  });
}
