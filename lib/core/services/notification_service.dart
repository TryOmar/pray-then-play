import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:local_notifier/local_notifier.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    if (kIsWeb) return;

    // 1. Windows Native Toast Setup
    if (Platform.isWindows) {
      try {
        await localNotifier.setup(
          appName: 'Pray Then Play',
          shortcutPolicy: ShortcutPolicy.ignore,
        );
      } catch (e) {
        debugPrint('[NotificationService] Windows LocalNotifier setup warning: $e');
      }
      return;
    }

    // 2. Mobile (Android/iOS) Setup
    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(settings);
    } catch (_) {}
  }

  static Future<void> requestPermission() async {
    if (kIsWeb) return;
    if (Platform.isWindows) return;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
    }
  }

  static Future<void> showPrayerReminder({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) return;

    // 1. Windows Native Toast Notification
    if (Platform.isWindows) {
      try {
        final notification = LocalNotification(
          identifier: 'pray_then_play_$id',
          title: title,
          body: body,
        );
        await notification.show();
        return;
      } catch (e) {
        debugPrint('[NotificationService] Windows show toast failed: $e');
      }
    }

    // 2. Android & iOS Local Notification
    const androidDetails = AndroidNotificationDetails(
      'gamer_salah_prayers',
      'Prayer Reminders',
      channelDescription: 'Smart prayer reminders for gamers',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }

  static Future<void> cancelAll() async {
    if (kIsWeb || Platform.isWindows) return;
    await _plugin.cancelAll();
  }

  static Future<void> cancel(int id) async {
    if (kIsWeb || Platform.isWindows) return;
    await _plugin.cancel(id);
  }
}
