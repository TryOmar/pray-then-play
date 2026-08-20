import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../models/prayer_time.dart';
import '../services/prayer_service.dart';
import '../services/storage_service.dart';
import '../utils/time_utils.dart';

class HomeWidgetService {
  HomeWidgetService._();

  static const String _mediumProvider = 'PtpMediumWidgetProvider';
  static const String _smallProvider = 'PtpSmallWidgetProvider';
  static const String _timelineProvider = 'PtpTimelineWidgetProvider';
  static const String _recommendedProvider = 'PtpRecommendedWidgetProvider';

  static bool get _isAndroidSupported {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid;
    } catch (_) {
      return false;
    }
  }

  /// Synchronize prayer schedule and gaming safety data with Android Home Screen Widgets
  static Future<void> updateWidgets({
    String? nextPrayerName,
    DateTime? nextPrayerTime,
    int? streak,
  }) async {
    if (!_isAndroidSupported) return;

    try {
      final now = DateTime.now();
      String prayerName = nextPrayerName ?? 'Salah';
      String prayerTimeStr = '--:--';
      String countdownStr = 'Next Salah';
      String safetyVerdict = 'SAFE TO PLAY';
      String safetyDetail = 'Safe for 35m match';
      String safetyShort = 'SAFE';
      String safetyColorHex = '#10B981';

      int diffMinutes = 999;

      if (nextPrayerTime != null) {
        prayerTimeStr = TimeUtils.formatTime(nextPrayerTime);
        diffMinutes = nextPrayerTime.difference(now).inMinutes;

        if (diffMinutes <= 0) {
          countdownStr = 'Salah Time';
          safetyVerdict = 'PRAYER TIME';
          safetyDetail = 'Stop gaming to pray';
          safetyShort = 'PRAY';
          safetyColorHex = '#EF4444';
        } else if (diffMinutes < 60) {
          countdownStr = '$prayerName in ${diffMinutes}m';
        } else {
          final hours = diffMinutes ~/ 60;
          final mins = diffMinutes % 60;
          countdownStr = '$prayerName in ${hours}h ${mins}m';
        }

        // Professional Safety evaluation (No emojis)
        if (diffMinutes >= 45) {
          safetyVerdict = 'SAFE TO PLAY';
          safetyDetail = 'Safe for 35m match';
          safetyShort = 'SAFE';
          safetyColorHex = '#10B981';
        } else if (diffMinutes >= 20) {
          safetyVerdict = 'PLAY WITH CAUTION';
          safetyDetail = 'Casual / short mode only';
          safetyShort = 'CAUTION';
          safetyColorHex = '#F59E0B';
        } else if (diffMinutes > 0) {
          safetyVerdict = 'RISKY TO QUEUE';
          safetyDetail = 'Salah in ${diffMinutes}m • Avoid match';
          safetyShort = 'RISKY';
          safetyColorHex = '#EF4444';
        }
      }

      final streakCount = streak ?? 0;
      final streakStr = '${streakCount}d streak';

      // Save Core Widget Data
      await HomeWidget.saveWidgetData<String>('next_prayer_name', prayerName);
      await HomeWidget.saveWidgetData<String>('next_prayer_time', prayerTimeStr);
      await HomeWidget.saveWidgetData<String>('countdown_text', countdownStr);
      await HomeWidget.saveWidgetData<String>('safety_verdict', safetyVerdict);
      await HomeWidget.saveWidgetData<String>('safety_detail', safetyDetail);
      await HomeWidget.saveWidgetData<String>('safety_short', safetyShort);
      await HomeWidget.saveWidgetData<String>('safety_color_hex', safetyColorHex);
      await HomeWidget.saveWidgetData<String>('streak_text', streakStr);

      // Save 5-Prayer Timeline Data
      final lat = StorageService.latitude;
      final lng = StorageService.longitude;
      if (lat != null && lng != null) {
        final daily = PrayerService.calculatePrayerTimes(
          latitude: lat,
          longitude: lng,
          date: now,
          method: StorageService.calculationMethod,
          asrMethod: StorageService.asrMethod,
        );
        await HomeWidget.saveWidgetData<String>(
            'fajr_time', TimeUtils.formatTime(daily.fajr));
        await HomeWidget.saveWidgetData<String>(
            'dhuhr_time', TimeUtils.formatTime(daily.dhuhr));
        await HomeWidget.saveWidgetData<String>(
            'asr_time', TimeUtils.formatTime(daily.asr));
        await HomeWidget.saveWidgetData<String>(
            'maghrib_time', TimeUtils.formatTime(daily.maghrib));
        await HomeWidget.saveWidgetData<String>(
            'isha_time', TimeUtils.formatTime(daily.isha));
      }

      // Save Recommended Safe Gaming Modes Data
      final userGames = StorageService.getUserGames();
      final activeGames = userGames.where((g) => g.isSelected).toList();

      final availableWindow = diffMinutes > 0 && diffMinutes < 600
          ? '${diffMinutes}m available'
          : 'Check time';
      await HomeWidget.saveWidgetData<String>(
          'rec_window_text', availableWindow);

      if (activeGames.isNotEmpty) {
        final g1 = activeGames.first;
        final act1 = g1.activities.isNotEmpty ? g1.activities.first : null;
        await HomeWidget.saveWidgetData<String>('rec_name_1', g1.name);
        await HomeWidget.saveWidgetData<String>(
            'rec_detail_1',
            act1 != null
                ? '${act1.name} • ${act1.typicalDuration}m'
                : g1.category.label);
        await HomeWidget.saveWidgetData<String>(
            'rec_badge_1',
            act1 != null && act1.typicalDuration <= (diffMinutes - 10)
                ? 'SAFE'
                : 'CHECK');

        if (activeGames.length > 1) {
          final g2 = activeGames[1];
          final act2 = g2.activities.isNotEmpty ? g2.activities.first : null;
          await HomeWidget.saveWidgetData<String>('rec_name_2', g2.name);
          await HomeWidget.saveWidgetData<String>(
              'rec_detail_2',
              act2 != null
                  ? '${act2.name} • ${act2.typicalDuration}m'
                  : g2.category.label);
          await HomeWidget.saveWidgetData<String>(
              'rec_badge_2',
              act2 != null && act2.typicalDuration <= (diffMinutes - 10)
                  ? 'SAFE'
                  : 'CHECK');
        } else {
          await HomeWidget.saveWidgetData<String>(
              'rec_name_2', 'Custom Mode');
          await HomeWidget.saveWidgetData<String>(
              'rec_detail_2', 'Pauseable session');
          await HomeWidget.saveWidgetData<String>('rec_badge_2', 'SAFE');
        }
      } else {
        await HomeWidget.saveWidgetData<String>('rec_name_1', 'Valorant');
        await HomeWidget.saveWidgetData<String>(
            'rec_detail_1', 'Swiftplay • 15m');
        await HomeWidget.saveWidgetData<String>('rec_badge_1', 'SAFE');

        await HomeWidget.saveWidgetData<String>('rec_name_2', 'Minecraft');
        await HomeWidget.saveWidgetData<String>(
            'rec_detail_2', 'Building • Pauseable');
        await HomeWidget.saveWidgetData<String>('rec_badge_2', 'SAFE');
      }

      // Update all 4 widgets
      await HomeWidget.updateWidget(
        name: _mediumProvider,
        androidName: _mediumProvider,
      );

      await HomeWidget.updateWidget(
        name: _smallProvider,
        androidName: _smallProvider,
      );

      await HomeWidget.updateWidget(
        name: _timelineProvider,
        androidName: _timelineProvider,
      );

      await HomeWidget.updateWidget(
        name: _recommendedProvider,
        androidName: _recommendedProvider,
      );
    } catch (e) {
      debugPrint('HomeWidget update error: $e');
    }
  }
}
