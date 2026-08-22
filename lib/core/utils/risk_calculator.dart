import 'dart:math';
import '../constants/app_constants.dart';
import '../models/game_profile.dart';
import '../models/gaming_window.dart';
import 'time_utils.dart';

class RiskCalculator {
  /// Calculate the general gaming status based on minutes remaining until prayer and safety buffer
  static GamingStatus calculateGamingStatus(int minutesUntilPrayer,
      {int bufferMinutes = 10}) {
    if (minutesUntilPrayer <= 0) {
      return GamingStatus.prayerTime;
    }
    if (minutesUntilPrayer <= bufferMinutes) {
      return GamingStatus.dontQueue;
    }
    if (minutesUntilPrayer <= (bufferMinutes + 15)) {
      return GamingStatus.caution;
    }
    return GamingStatus.safe;
  }

  /// Calculate the risk of queuing for a specific activity given minutes until prayer, buffer, and optional desired session duration
  static RiskLevel calculateRisk(
    GameActivity activity,
    int minutesUntilPrayer, {
    int bufferMinutes = 10,
    int? desiredSessionMinutes,
  }) {
    if (minutesUntilPrayer <= 0) {
      return RiskLevel.high;
    }

    final effectiveBuffer = activity.safetyBuffer ?? bufferMinutes;
    final safeAvailableTime = minutesUntilPrayer - effectiveBuffer;

    // Singleplayer / pauseable activities can be paused or exited cleanly anytime
    if (activity.canPause && !activity.requiresCompletion) {
      // If prayer is within the safety buffer (e.g. <= 10m left), flag as caution
      if (minutesUntilPrayer <= effectiveBuffer) {
        return RiskLevel.medium;
      }
      return RiskLevel.low;
    }

    // If user specified a target session duration, the activity must fit BOTH within the planned session AND safe prayer window
    if (desiredSessionMinutes != null && desiredSessionMinutes > 0) {
      final effectiveSafeWindow = min(safeAvailableTime, desiredSessionMinutes);
      final effectiveRawWindow = min(minutesUntilPrayer, desiredSessionMinutes);

      if (activity.maxMinutes <= effectiveSafeWindow) {
        return RiskLevel.low;
      }
      if (activity.typicalDuration <= effectiveRawWindow &&
          activity.minMinutes <= effectiveSafeWindow) {
        return RiskLevel.medium;
      }
      return RiskLevel.high;
    }

    // Default mode evaluation based on activity typical and max bounds
    if (activity.maxMinutes <= safeAvailableTime) {
      return RiskLevel.low;
    }

    if (activity.typicalDuration <= minutesUntilPrayer &&
        activity.minMinutes <= safeAvailableTime) {
      return RiskLevel.medium;
    }

    return RiskLevel.high;
  }

  /// Check queue suitability and generate comprehensive recommendations
  static QueueCheckResult checkQueue({
    required GameProfile game,
    required GameActivity activity,
    required int minutesUntilPrayer,
    required String nextPrayerName,
    required List<GameProfile> userGames,
    int bufferMinutes = 10,
    int? desiredSessionMinutes,
  }) {
    final effectiveBuffer = activity.safetyBuffer ?? bufferMinutes;
    final safeAvailableMinutes =
        (minutesUntilPrayer - effectiveBuffer).clamp(0, 999);
    final risk = calculateRisk(
      activity,
      minutesUntilPrayer,
      bufferMinutes: bufferMinutes,
      desiredSessionMinutes: desiredSessionMinutes,
    );

    String verdictTitle;
    String message;
    String recommendation;
    List<String> alternatives = [];
    int? tightMargin;

    final formattedRemaining = TimeUtils.formatMinutes(minutesUntilPrayer);
    final formattedSafe = TimeUtils.formatMinutes(safeAvailableMinutes);

    if (activity.canPause && !activity.requiresCompletion) {
      if (minutesUntilPrayer <= effectiveBuffer) {
        verdictTitle = '⚠ PRAYER IMMINENT (PAUSEABLE)';
        message =
            '$nextPrayerName is in only $formattedRemaining (inside your ${effectiveBuffer}m safety buffer).';
        recommendation =
            'While ${game.name} · ${activity.name} can be left anytime without penalty, we recommend preparing for Salah instead of starting a new match.';
      } else {
        verdictTitle = '✓ PAUSEABLE SESSION';
        message =
            'You can pause, save, or leave ${game.name} · ${activity.name} anytime without penalties.';
        recommendation =
            '$nextPrayerName is in $formattedRemaining ($formattedSafe safe window). Enjoy your session and pause when prayer arrives.';
      }
    } else {
      if (desiredSessionMinutes != null && desiredSessionMinutes > 0) {
        tightMargin = (minutesUntilPrayer - desiredSessionMinutes).clamp(0, 999);
        final formattedDesired = TimeUtils.formatMinutes(desiredSessionMinutes);

        switch (risk) {
          case RiskLevel.low:
            verdictTitle = '✓ SAFE TO START';
            message =
                'Your desired session ($formattedDesired) fits comfortably inside the safe window ($formattedSafe before ${effectiveBuffer}m buffer).';
            recommendation =
                '$nextPrayerName is in $formattedRemaining. You have sufficient time to finish with zero rush.';
            break;

          case RiskLevel.medium:
            verdictTitle = '⚠ TIGHT WINDOW — USE CAUTION';
            message =
                'A $formattedDesired session will finish before $nextPrayerName ($formattedRemaining), but cuts into your ${effectiveBuffer}m safety buffer.';
            recommendation =
                'You have roughly ${TimeUtils.formatMinutes(tightMargin)} margin. If a match runs long, you may need to rush to prayer.';
            alternatives = _findAlternatives(
              minutesUntilPrayer,
              userGames,
              excludeGameId: game.id,
              excludeActivityId: activity.id,
              bufferMinutes: bufferMinutes,
            );
            break;

          case RiskLevel.high:
            verdictTitle = '✕ NOT RECOMMENDED (PRAY FIRST)';
            message =
                '$nextPrayerName is in $formattedRemaining. Your requested session ($formattedDesired) is too long for the safe window ($formattedSafe).';
            recommendation =
                'Pray $nextPrayerName first, then queue with total focus and peace of mind.';
            alternatives = _findAlternatives(
              minutesUntilPrayer,
              userGames,
              excludeGameId: game.id,
              excludeActivityId: activity.id,
              bufferMinutes: bufferMinutes,
            );
            break;
        }
      } else {
        tightMargin = (minutesUntilPrayer - activity.typicalDuration).clamp(0, 999);
        final formattedTypical = TimeUtils.formatMinutes(activity.typicalDuration);
        final formattedMin = TimeUtils.formatMinutes(activity.minMinutes);
        final formattedMax = TimeUtils.formatMinutes(activity.maxMinutes);

        switch (risk) {
          case RiskLevel.low:
            verdictTitle = activity.typicalDuration <= 15
                ? '✓ SAFE FOR A SHORT SESSION'
                : '✓ SAFE TO START';
            message =
                'Typical match: $formattedMin–$formattedMax. $nextPrayerName begins in $formattedRemaining.';
            recommendation =
                'You have a comfortable window with a ${effectiveBuffer}m safety buffer preserved.';
            break;

          case RiskLevel.medium:
            verdictTitle = '⚠ TIGHT WINDOW — USE CAUTION';
            message =
                'A normal match (~$formattedTypical) fits, but overtime or delay ($formattedMax) could overlap with $nextPrayerName in $formattedRemaining.';
            recommendation =
                'You have roughly ${TimeUtils.formatMinutes(tightMargin)} margin. Consider a shorter mode or pauseable activity if you want zero risk.';
            alternatives = _findAlternatives(
              minutesUntilPrayer,
              userGames,
              excludeGameId: game.id,
              excludeActivityId: activity.id,
              bufferMinutes: bufferMinutes,
            );
            break;

          case RiskLevel.high:
            verdictTitle = '✕ NOT RECOMMENDED (PRAY FIRST)';
            message =
                '$nextPrayerName is in $formattedRemaining. A typical ${game.name} · ${activity.name} session ($formattedTypical) is too long.';
            recommendation =
                'Pray $nextPrayerName first, then queue with complete peace of mind.';
            alternatives = _findAlternatives(
              minutesUntilPrayer,
              userGames,
              excludeGameId: game.id,
              excludeActivityId: activity.id,
              bufferMinutes: bufferMinutes,
            );
            break;
        }
      }
    }

    return QueueCheckResult(
      riskLevel: risk,
      verdictTitle: verdictTitle,
      minutesUntilPrayer: minutesUntilPrayer,
      availableSafeMinutes: safeAvailableMinutes,
      estimatedMatchDuration: desiredSessionMinutes ?? activity.typicalDuration,
      requestedDurationMinutes: desiredSessionMinutes,
      canPause: activity.canPause,
      isCompetitive: activity.isCompetitive,
      nextPrayerName: nextPrayerName,
      message: message,
      recommendation: recommendation,
      suggestedAlternatives: alternatives,
      tightMargin: tightMargin,
    );
  }

  /// Find alternative activities from the user's configured library that safely fit
  static List<String> _findAlternatives(
    int minutesAvailable,
    List<GameProfile> userGames, {
    String? excludeGameId,
    String? excludeActivityId,
    int bufferMinutes = 10,
  }) {
    final alternatives = <String>[];

    for (final game in userGames) {
      for (final activity in game.enabledActivities) {
        if (game.id == excludeGameId && activity.id == excludeActivityId) {
          continue;
        }

        final risk = calculateRisk(activity, minutesAvailable,
            bufferMinutes: bufferMinutes);
        if (risk != RiskLevel.high) {
          if (activity.canPause && !activity.requiresCompletion) {
            alternatives.add('${game.name} · ${activity.name} (Pauseable)');
          } else {
            alternatives.add(
                '${game.name} · ${activity.name} (~${TimeUtils.formatMinutes(activity.typicalDuration)})');
          }
        }
      }
    }

    return alternatives;
  }

  static String getRiskLabel(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'Recommended now';
      case RiskLevel.medium:
        return 'Use caution';
      case RiskLevel.high:
        return 'Not recommended right now';
    }
  }
}
