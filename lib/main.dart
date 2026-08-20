import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/providers/settings_provider.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0E1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize core services
  await StorageService.initialize();
  await NotificationService.initialize();

  runApp(
    const ProviderScope(
      child: GamerSalahApp(),
    ),
  );
}

class GamerSalahApp extends ConsumerWidget {
  const GamerSalahApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamingTheme = ref.watch(gamingThemeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'GamerSalah',
      debugShowCheckedModeBanner: false,
      theme: GamerSalahTheme.getTheme(gamingTheme),
      routerConfig: router,
    );
  }
}
