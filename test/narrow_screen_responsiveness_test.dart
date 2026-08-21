import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pray_then_play/app/shell_screen.dart';
import 'package:pray_then_play/app/theme.dart';
import 'package:pray_then_play/core/providers/prayer_provider.dart';
import 'package:pray_then_play/core/services/storage_service.dart';
import 'package:pray_then_play/features/game_profiles/screens/game_profiles_screen.dart';
import 'package:pray_then_play/features/heatmap/screens/prayer_consistency_screen.dart';
import 'package:pray_then_play/features/home/screens/home_screen.dart';
import 'package:pray_then_play/features/prayer_times/screens/prayer_times_screen.dart';
import 'package:pray_then_play/features/queue_check/screens/queue_check_screen.dart';
import 'package:pray_then_play/features/settings/screens/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'latitude': 21.4225,
      'longitude': 39.8262,
      'city_name': 'Makkah',
      'country_name': 'Saudi Arabia',
    });
    await StorageService.initialize();
  });

  group('Narrow Mobile Screen Responsiveness Tests (320px Viewport)', () {
    testWidgets('ShellScreen bottom navigation renders cleanly on 300px narrow width',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(300 * 3, 600 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveSecondTickerProvider.overrideWith(
              (ref) => Stream.value(DateTime.now()),
            ),
          ],
          child: MaterialApp(
            theme: PrayThenPlayTheme.getTheme(AppGamingTheme.midnight),
            home: const ShellScreen(
              child: Scaffold(body: Center(child: Text('Content'))),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ShellScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('HomeScreen renders without overflow on 320px narrow mobile',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320 * 3, 568 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveSecondTickerProvider.overrideWith(
              (ref) => Stream.value(DateTime.now()),
            ),
          ],
          child: MaterialApp(
            theme: PrayThenPlayTheme.getTheme(AppGamingTheme.midnight),
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('GameProfilesScreen with icon-only edit button renders cleanly on 320px width',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320 * 3, 568 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: PrayThenPlayTheme.getTheme(AppGamingTheme.midnight),
            home: const GameProfilesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GameProfilesScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Open Add Game Dialog
      await tester.tap(find.text('Add Game').first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Switch to '+ Custom Game' Tab
      await tester.tap(find.text('+ Custom Game'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Game / Server Name'), findsOneWidget);
      expect(find.text('Casual / Flexible'), findsOneWidget);
      expect(find.text('Competitive'), findsOneWidget);

      // Close modal
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Scroll card into view and tap expand
      await tester.ensureVisible(find.byIcon(Icons.expand_more_rounded).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.expand_more_rounded).first);
      await tester.pumpAndSettle();

      // Tap Edit Activity icon
      await tester.ensureVisible(find.byIcon(Icons.edit_rounded).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.edit_rounded).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Typical'), findsOneWidget);
      expect(find.text('Min'), findsOneWidget);
      expect(find.text('Max'), findsOneWidget);
    });

    testWidgets('QueueCheckScreen renders without overflow on 320px width',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320 * 3, 568 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveSecondTickerProvider.overrideWith(
              (ref) => Stream.value(DateTime.now()),
            ),
          ],
          child: MaterialApp(
            theme: PrayThenPlayTheme.getTheme(AppGamingTheme.midnight),
            home: const QueueCheckScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(QueueCheckScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('PrayerConsistencyScreen renders without overflow on 320px width',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320 * 3, 568 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: PrayThenPlayTheme.getTheme(AppGamingTheme.midnight),
            home: const PrayerConsistencyScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PrayerConsistencyScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Scroll down to layout behavioral insights and habit & discipline badges
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Scroll back up and position on tabs
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 1200));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -350));
      await tester.pumpAndSettle();

      // Tab 1: 5-Prayer Matrix
      await tester.tap(find.text('5-Prayer Matrix').first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Tab 2: Gaming Decisions
      await tester.tap(find.text('Gaming Decisions').first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('PrayerTimesScreen renders without overflow on 320px width',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320 * 3, 568 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: PrayThenPlayTheme.getTheme(AppGamingTheme.midnight),
            home: const PrayerTimesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PrayerTimesScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SettingsScreen renders without overflow on 320px width',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320 * 3, 568 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: PrayThenPlayTheme.getTheme(AppGamingTheme.midnight),
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
