import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/localization/app_language.dart';
import 'core/providers/settings_provider.dart';
import 'core/services/desktop_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Set preferred orientations for mobile
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      try {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);

        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Color(0xFF0B1020),
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        );
      } catch (_) {}
    }

    // Initialize core services
    try {
      await StorageService.initialize();
    } catch (e) {
      debugPrint('[Main] StorageService init error: $e');
    }

    try {
      await NotificationService.initialize();
    } catch (e) {
      debugPrint('[Main] NotificationService init error: $e');
    }

    if (DesktopService.isDesktop) {
      try {
        await DesktopService.instance.initialize();
      } catch (e) {
        debugPrint('[Main] DesktopService init error: $e');
      }
    }

    runApp(
      const ProviderScope(
        child: PrayThenPlayApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('[Main] Uncaught error: $error\n$stack');
  });
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

      // Handle HomeWidget deep linking on Android
      if (!kIsWeb) {
        try {
          if (defaultTargetPlatform == TargetPlatform.android) {
            HomeWidget.initiallyLaunchedFromHomeWidget().then((uri) {
              if (uri != null) _handleWidgetUri(uri);
            });
            HomeWidget.widgetClicked.listen((uri) {
              if (uri != null) _handleWidgetUri(uri);
            });
          }
        } catch (_) {}
      }
    });
  }

  void _handleWidgetUri(Uri uri) {
    final router = ref.read(routerProvider);
    if (uri.host == 'queue-check') {
      router.go('/queue-check');
    } else if (uri.host == 'prayer-times') {
      router.go('/prayer-times');
    } else {
      router.go('/');
    }
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
    final currentLanguage = ref.watch(appLanguageProvider);
    final router = ref.watch(routerProvider);
    final isLight = activeTheme.isLight;

    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: activeTheme.background,
      systemNavigationBarIconBrightness:
          isLight ? Brightness.dark : Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: MaterialApp.router(
        title: 'Pray Then Play',
        debugShowCheckedModeBanner: false,
        theme: PrayThenPlayTheme.getTheme(activeTheme),
        routerConfig: router,
        locale: currentLanguage.locale,
        supportedLocales: AppLanguage.values.map((e) => e.locale).toList(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return Directionality(
            textDirection: currentLanguage.direction,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

// Backwards compatibility alias
typedef GamerSalahApp = PrayThenPlayApp;
