class DesktopService {
  static final DesktopService instance = DesktopService._();
  DesktopService._();

  static bool get isDesktop => false;
  static bool get isWindows => false;

  Future<void> initialize() async {}

  Future<void> updateTrayMenu({
    String? nextPrayerName,
    String? nextPrayerTime,
    String? verdict,
  }) async {}
}
