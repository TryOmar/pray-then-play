import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import '../localization/app_language.dart';
import '../localization/app_translations.dart';
import 'storage_service.dart';

class DesktopService with TrayListener, WindowListener {
  static final DesktopService instance = DesktopService._();
  DesktopService._();

  static bool get isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (!isDesktop) return;
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      // 1. Initialize Window Manager
      await windowManager.ensureInitialized();
      windowManager.addListener(this);

      await windowManager.setSize(const Size(1100, 780));
      await windowManager.setMinimumSize(const Size(400, 650));
      await windowManager.center();
      await windowManager.setTitle('Pray Then Play - Gaming Salah Companion');
      await windowManager.show();
      await windowManager.focus();

      // 2. Initialize System Tray
      try {
        await trayManager.setIcon(
          Platform.isWindows
              ? 'assets/branding/icon/app_icon.ico'
              : 'assets/branding/icon/app_icon_512.png',
        );
        trayManager.addListener(this);
        await updateTrayMenu();
      } catch (e) {
        debugPrint('[DesktopService] Tray icon setup warning: $e');
      }

      // 3. Initialize Local Notifier for Windows Toasts
      try {
        await localNotifier.setup(
          appName: 'Pray Then Play',
          shortcutPolicy: ShortcutPolicy.ignore,
        );
      } catch (e) {
        debugPrint('[DesktopService] LocalNotifier setup warning: $e');
      }

      // 4. Initialize Launch At Startup
      try {
        launchAtStartup.setup(
          appName: 'PrayThenPlay',
          appPath: Platform.resolvedExecutable,
        );
      } catch (e) {
        debugPrint('[DesktopService] LaunchAtStartup setup warning: $e');
      }
    } catch (e) {
      debugPrint('[DesktopService] Desktop initialization error: $e');
    }
  }

  Future<void> updateTrayMenu({
    String? nextPrayerName,
    String? nextPrayerTime,
    String? verdict,
  }) async {
    if (!isDesktop) return;
    try {
      final lang = StorageService.appLanguage;
      final localizedPrayer = nextPrayerName != null
          ? AppTranslations.get('prayer_${nextPrayerName.toLowerCase()}', lang)
          : null;
      final appName = AppTranslations.get('app_name', lang);
      final nextLabel = AppTranslations.get('next_prayer', lang);
      final queueLabel = AppTranslations.get('nav_queue', lang);

      final tooltip = localizedPrayer != null
          ? '$appName: $nextLabel $localizedPrayer at $nextPrayerTime ${verdict != null ? '($verdict)' : ''}'
          : '$appName - Gaming Salah Companion';

      await trayManager.setToolTip(tooltip);

      final menu = Menu(
        items: [
          MenuItem(
            key: 'status',
            label: localizedPrayer != null
                ? '🕌 $nextLabel: $localizedPrayer • $nextPrayerTime'
                : '🎮 $appName',
            disabled: true,
          ),
          MenuItem.separator(),
          MenuItem(
            key: 'show_app',
            label: 'Open $appName',
          ),
          MenuItem(
            key: 'queue_check',
            label: '⚡ $queueLabel',
          ),
          MenuItem.separator(),
          MenuItem(
            key: 'exit_app',
            label: 'Exit',
          ),
        ],
      );
      await trayManager.setContextMenu(menu);
    } catch (e) {
      debugPrint('[DesktopService] updateTrayMenu error: $e');
    }
  }

  // --- WindowListener Events ---
  @override
  void onWindowClose() async {
    final minimizeToTray = StorageService.minimizeToTrayOnClose;
    if (minimizeToTray) {
      await windowManager.hide();
    } else {
      await windowManager.destroy();
    }
  }

  // --- TrayListener Events ---
  @override
  void onTrayIconMouseDown() {
    windowManager.show();
    windowManager.focus();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'show_app' || menuItem.key == 'queue_check') {
      windowManager.show();
      windowManager.focus();
    } else if (menuItem.key == 'exit_app') {
      windowManager.destroy();
    }
  }
}
