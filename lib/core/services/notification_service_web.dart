class NotificationService {
  static Future<void> initialize() async {}

  static Future<void> requestPermission() async {}

  static Future<void> showPrayerReminder({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {}

  static Future<void> cancelAll() async {}

  static Future<void> cancel(int id) async {}
}
