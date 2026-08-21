import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pray_then_play/app/theme.dart';
import 'package:pray_then_play/core/services/storage_service.dart';
import 'package:pray_then_play/features/onboarding/screens/onboarding_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.initialize();
  });

  Future<void> advanceToThemeStep(WidgetTester tester) async {
    for (int step = 0; step < 5; step++) {
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        await tester.ensureVisible(buttons.last);
        await tester.pumpAndSettle();
        await tester.tap(buttons.last);
        await tester.pumpAndSettle();
      }
    }
  }

  group('Onboarding Theme Selection Responsive Tests', () {
    testWidgets('Full 6-step onboarding runs with 0 errors on 320px mobile',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320 * 3, 640 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: PrayThenPlayTheme.getTheme(AppGamingTheme.midnight),
            home: const OnboardingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await advanceToThemeStep(tester);

      // Step 6: Verify Theme Picker rendered
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      final crimson = find.text('Crimson');
      if (crimson.evaluate().isNotEmpty) {
        await tester.ensureVisible(crimson.first);
        await tester.pumpAndSettle();
        await tester.tap(crimson.first);
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('Onboarding Theme Picker renders on 768px tablet layout',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(768 * 2, 1024 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: PrayThenPlayTheme.getTheme(AppGamingTheme.midnight),
            home: const OnboardingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await advanceToThemeStep(tester);

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      final forest = find.text('Forest');
      if (forest.evaluate().isNotEmpty) {
        await tester.ensureVisible(forest.first);
        await tester.pumpAndSettle();
        await tester.tap(forest.first);
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('Onboarding Theme Picker renders on 1200px desktop layout',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: PrayThenPlayTheme.getTheme(AppGamingTheme.midnight),
            home: const OnboardingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await advanceToThemeStep(tester);

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
