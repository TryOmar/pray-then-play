import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamer_salah/core/providers/prayer_provider.dart';
import 'package:gamer_salah/core/services/storage_service.dart';
import 'package:gamer_salah/features/home/screens/home_screen.dart';
import 'package:gamer_salah/features/settings/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  testWidgets('GamerSalah app launches properly', (WidgetTester tester) async {
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
