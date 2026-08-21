import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pray_then_play/app/theme.dart';
import 'package:pray_then_play/features/onboarding/screens/onboarding_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

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

      // Step 1 -> 2
      await tester.ensureVisible(find.text('Get Started'));
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Step 2 -> 3
      await tester.ensureVisible(find.text('Continue to Games'));
      await tester.tap(find.text('Continue to Games'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Step 3 -> 4
      final step3Btn = find.textContaining('Customize Modes');
      await tester.ensureVisible(step3Btn);
      await tester.tap(step3Btn);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Step 4 -> 5
      await tester.ensureVisible(find.text('Configure Protection Level'));
      await tester.tap(find.text('Configure Protection Level'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Step 5 -> 6
      await tester.ensureVisible(find.text('Choose Gaming Theme'));
      await tester.tap(find.text('Choose Gaming Theme'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Step 6: Verify Theme Picker
      expect(find.text('Choose Your Theme'), findsOneWidget);
      expect(find.text('Midnight'), findsWidgets);

      // Tap filter chips
      await tester.tap(find.text('Dark (5)'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Light (5)'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Specialized (2)'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('All (11)'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Select theme
      await tester.ensureVisible(find.text('Crimson').first);
      await tester.tap(find.text('Crimson').first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Complete button visible
      expect(find.text('Start Using Pray Then Play'), findsOneWidget);
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

      for (int i = 0; i < 5; i++) {
        final nextBtn = find.byType(ElevatedButton);
        if (nextBtn.evaluate().isNotEmpty) {
          await tester.ensureVisible(nextBtn.first);
          await tester.tap(nextBtn.first);
          await tester.pumpAndSettle();
        }
      }

      expect(find.text('Choose Your Theme'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Forest').first);
      await tester.pumpAndSettle();
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

      for (int i = 0; i < 5; i++) {
        final nextBtn = find.byType(ElevatedButton);
        if (nextBtn.evaluate().isNotEmpty) {
          await tester.ensureVisible(nextBtn.first);
          await tester.tap(nextBtn.first);
          await tester.pumpAndSettle();
        }
      }

      expect(find.text('Choose Your Theme'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
