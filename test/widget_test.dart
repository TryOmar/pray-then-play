import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pray_then_play/core/providers/prayer_provider.dart';
import 'package:pray_then_play/core/services/storage_service.dart';
import 'package:pray_then_play/features/home/screens/home_screen.dart';
import 'package:pray_then_play/features/settings/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  testWidgets('PrayThenPlay app launches properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          liveSecondTickerProvider.overrideWith(
            (ref) => Stream.value(DateTime.now()),
          ),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('SettingsScreen renders without error with populated and empty storage',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
