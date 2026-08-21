import 'package:intl/intl.dart';
import '../localization/app_language.dart';
import '../services/storage_service.dart';

class TimeUtils {
  static String formatTime(DateTime time, {bool? is24Hour}) {
    final use24 = is24Hour ?? StorageService.is24HourFormat;
    if (use24) {
      return DateFormat('HH:mm').format(time);
    }
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final isPm = hour >= 12;
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    final lang = StorageService.appLanguage;
    if (lang == AppLanguage.arabic) {
      final period = isPm ? 'م' : 'ص';
      return '$displayHour:$minute $period';
    } else if (lang == AppLanguage.urdu) {
      final period = isPm ? 'شام' : 'صبح';
      return '$displayHour:$minute $period';
    }
    final period = isPm ? 'PM' : 'AM';
    return '$displayHour:$minute $period';
  }

  static String formatTime24(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  static String formatMinutes(int minutes) {
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      if (m == 0) return '${h}h';
      return '${h}h ${m}m';
    }
    return '$minutes min';
  }

  static String formatCountdown(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  static String timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  static String formatDate(DateTime date) {
    return DateFormat('EEEE, MMM d').format(date);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Returns a human-readable description of time remaining
  static String describeTimeRemaining(int minutes) {
    if (minutes <= 0) return 'Now';
    if (minutes < 5) return 'Less than 5 minutes';
    if (minutes < 10) return 'About $minutes minutes';
    if (minutes < 60) return '$minutes minutes';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (m == 0) return '$h hour${h > 1 ? 's' : ''}';
    return '$h hour${h > 1 ? 's' : ''} $m min';
  }
}
