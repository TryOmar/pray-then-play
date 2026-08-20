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
      systemNavigationBarColor: Color(0xFF0B1020),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize core services
  await StorageService.initialize();
  await NotificationService.initialize();

  runApp(
    const ProviderScope(
      child: PrayThenPlayApp(),
    ),
  );
}

class PrayThenPlayApp extends ConsumerStatefulWidget {
  const PrayThenPlayApp({super.key});

  @override
  ConsumerState<PrayThenPlayApp> createState() => _PrayThenPlayAppState();
}

class _PrayThenPlayAppState extends ConsumerState<PrayThenPlayApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Sync initial system brightness
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      ref.read(systemBrightnessProvider.notifier).state = brightness;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    ref.read(systemBrightnessProvider.notifier).state = brightness;
  }

  @override
  Widget build(BuildContext context) {
    final activeTheme = ref.watch(effectiveThemeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Pray Then Play',
      debugShowCheckedModeBanner: false,
      theme: PrayThenPlayTheme.getTheme(activeTheme),
      routerConfig: router,
    );
  }
}

// Backwards compatibility alias
typedef GamerSalahApp = PrayThenPlayApp;
