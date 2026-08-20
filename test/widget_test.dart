import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamer_salah/main.dart';
import 'package:gamer_salah/core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.initialize();
  });

  testWidgets('GamerSalah app launches properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GamerSalahApp(),
      ),
    );

    // Initial frame rendered
    await tester.pump();
    expect(find.byType(GamerSalahApp), findsOneWidget);
  });
}
