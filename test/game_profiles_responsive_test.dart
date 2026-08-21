import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gamer_salah/app/theme.dart';
import 'package:gamer_salah/core/services/storage_service.dart';
import 'package:gamer_salah/features/game_profiles/screens/game_profiles_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'latitude': 21.4225,
      'longitude': 39.8262,
    });
    await StorageService.initialize();
  });

  testWidgets('GameProfilesScreen renders cleanly and opens modals on 320px screen',
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

    // Open Add Game Dialog via the header Add Game button
    FlutterErrorDetails? errorDetails;
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      errorDetails = details;
    };

    await tester.tap(find.text('Add Game'));
    await tester.pumpAndSettle();

    FlutterError.onError = originalOnError;
    if (errorDetails != null) {
      // ignore: avoid_print
      print('DEBUG_OVERFLOW: ${errorDetails!.exceptionAsString()} \nContext: ${errorDetails!.context}');
    }
    expect(errorDetails, isNull);

    // Switch to Custom Game Tab
    await tester.tap(find.text('+ Custom Game'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Game / Server Name'), findsOneWidget);

    // Close modal
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Card starts expanded by default; verify edit activity button is present
    final editActivityBtn = find.byTooltip('Edit activity');
    expect(editActivityBtn, findsWidgets);

    // Open edit dialog for first activity
    await tester.ensureVisible(editActivityBtn.first);
    await tester.tap(editActivityBtn.first, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Delete'), findsOneWidget);

    // Delete the activity from inside the edit pop up
    await tester.tap(find.text('Delete'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsOneWidget);

    // Tap Undo to restore activity
    await tester.tap(find.text('Undo'), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Verify Remove Game button is present and can remove game
    final removeBtn = find.text('Remove Game');
    expect(removeBtn, findsWidgets);
    await tester.ensureVisible(removeBtn.first);
    await tester.tap(removeBtn.first, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsOneWidget);

    // Tap Undo to restore game
    await tester.tap(find.text('Undo'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
