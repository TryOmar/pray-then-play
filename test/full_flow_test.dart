import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pray_then_play/main.dart';
import 'package:pray_then_play/app/shell_screen.dart';
import 'package:pray_then_play/features/queue_check/screens/queue_check_screen.dart';
import 'package:pray_then_play/core/services/storage_service.dart';
import 'package:pray_then_play/core/providers/prayer_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('Complete onboarding and transition to ShellScreen and all tabs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({
      'onboarding_complete': false,
    });
    await StorageService.initialize();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          liveSecondTickerProvider.overrideWith(
            (ref) => Stream.value(DateTime.now()),
          ),
        ],
        child: const PrayThenPlayApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Step 0: Welcome page
    expect(find.text('Get Started'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Step 1: Location & Calculation page
    final nextBtn1 = find.widgetWithText(ElevatedButton, 'Next');
    expect(nextBtn1, findsOneWidget);
    await tester.tap(nextBtn1);
    await tester.pumpAndSettle();

    // Step 2: Games selection page - select a game first
    final valorantRow = find.text('Valorant');
    expect(valorantRow, findsOneWidget);
    await tester.tap(valorantRow);
    await tester.pumpAndSettle();

    final nextBtn2 = find.widgetWithText(ElevatedButton, 'Customize Game Modes (1)');
    expect(nextBtn2, findsOneWidget);
    await tester.tap(nextBtn2);
    await tester.pumpAndSettle();

    // Step 3: Game Modes customization page
    final nextBtn3 = find.widgetWithText(ElevatedButton, 'Set Protection Buffer');
    expect(nextBtn3, findsOneWidget);
    await tester.tap(nextBtn3);
    await tester.pumpAndSettle();

    // Step 4: Protection Level page
    final nextBtn4 = find.widgetWithText(ElevatedButton, 'Theme & Visuals');
    expect(nextBtn4, findsOneWidget);
    await tester.tap(nextBtn4);
    await tester.pumpAndSettle();

    // Step 5: Theme selection page -> Finish Setup
    final finishBtn = find.text('Finish Setup & Enter App');
    expect(finishBtn, findsOneWidget);
    await tester.tap(finishBtn);
    await tester.pumpAndSettle();

    // Now verify we are on ShellScreen and QueueCheckScreen!
    expect(find.byType(ShellScreen), findsOneWidget);
    expect(find.byType(QueueCheckScreen), findsOneWidget);
    expect(find.text('Safe to Play'), findsWidgets);

    // Tap Tab 1: Consistency
    await tester.tap(find.byIcon(Icons.auto_graph_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Prayer Consistency'), findsWidgets);

    // Tap Tab 2: My Games
    await tester.tap(find.byIcon(Icons.videogame_asset_rounded));
    await tester.pumpAndSettle();
    expect(find.text('My Games & Activities'), findsWidgets);

    // Tap Tab 3: Settings
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);

    // Tap Tab 0: Can I Queue?
    await tester.tap(find.byIcon(Icons.timer_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(QueueCheckScreen), findsOneWidget);
    expect(find.text('Safe to Play'), findsWidgets);
  });
}
