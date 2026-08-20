import '../constants/app_constants.dart';
import '../models/game_profile.dart';
import '../models/gaming_window.dart';

class RiskCalculator {
  /// Calculate the gaming status based on minutes remaining until prayer and user's safety buffer
  static GamingStatus calculateGamingStatus(int minutesUntilPrayer, {int bufferMinutes = 10}) {
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

  /// Calculate the risk of queuing for a specific mode given minutes until prayer and safety buffer
  static RiskLevel calculateRisk(
    GameMode mode,
    int minutesUntilPrayer, {
    int bufferMinutes = 10,
  }) {
    // Flexible games (singleplayer/pauseable) are always safe to play
    if (mode.commitmentType == GameCommitmentType.flexible || mode.canLeaveSafely) {
      return RiskLevel.low;
    }

    if (minutesUntilPrayer <= 0) {
      return RiskLevel.high;
    }

    final safeAvailableTime = minutesUntilPrayer - bufferMinutes;

    // Match fits comfortably within the safe window
    if (mode.maxMinutes <= safeAvailableTime) {
      return RiskLevel.low;
    }

    // Match estimated time fits within absolute prayer time, but exceeds safe buffer
    if (mode.estimatedMinutes <= minutesUntilPrayer && mode.minMinutes <= safeAvailableTime) {
      return RiskLevel.medium;
    }

    // Match will definitely or likely overflow into prayer time
    return RiskLevel.high;
  }

  /// Check queue suitability and generate recommendations
  static QueueCheckResult checkQueue({
    required GameProfile game,
    required GameMode mode,
    required int minutesUntilPrayer,
    required String nextPrayerName,
    required List<GameProfile> userGames,
    int bufferMinutes = 10,
  }) {
    final risk = calculateRisk(mode, minutesUntilPrayer, bufferMinutes: bufferMinutes);

    String message;
    String recommendation;
    List<String> alternatives = [];

    if (mode.commitmentType == GameCommitmentType.flexible || mode.canLeaveSafely) {
      message = 'You can pause, save, or leave ${game.name} ${mode.name} at any time.';
      recommendation = '$nextPrayerName is in $minutesUntilPrayer minutes. Enjoy your session.';
    } else {
      switch (risk) {
        case RiskLevel.low:
          message = 'Typical match: ${mode.minMinutes}–${mode.maxMinutes} min. $nextPrayerName begins in $minutesUntilPrayer min.';
          recommendation = 'You have a comfortable gaming window with a ${bufferMinutes}m safety buffer.';
          break;

        case RiskLevel.medium:
          final tightMargin = minutesUntilPrayer - mode.estimatedMinutes;
          message = 'A normal match (~${mode.estimatedMinutes} min) fits, but overtime (${mode.maxMinutes} min) could overlap with $nextPrayerName in $minutesUntilPrayer min.';
          recommendation = 'You have roughly $tightMargin min margin. Consider a shorter mode if you want zero risk.';
          alternatives = _findAlternatives(minutesUntilPrayer, userGames, excludeGameId: game.id, excludeModeName: mode.name, bufferMinutes: bufferMinutes);
          break;

        case RiskLevel.high:
          message = '$nextPrayerName is in $minutesUntilPrayer minutes. A typical ${game.name} ${mode.name} match (${mode.estimatedMinutes} min) is too long.';
          recommendation = 'Pray $nextPrayerName first, then queue with total peace of mind.';
          alternatives = _findAlternatives(minutesUntilPrayer, userGames, excludeGameId: game.id, excludeModeName: mode.name, bufferMinutes: bufferMinutes);
          break;
      }
    }

    return QueueCheckResult(
      riskLevel: risk,
      minutesUntilPrayer: minutesUntilPrayer,
      estimatedMatchDuration: mode.estimatedMinutes,
      nextPrayerName: nextPrayerName,
      message: message,
      recommendation: recommendation,
      suggestedAlternatives: alternatives,
    );
  }

  /// Find alternative modes from the user's configured games that safely fit
  static List<String> _findAlternatives(
    int minutesAvailable,
    List<GameProfile> userGames, {
    String? excludeGameId,
    String? excludeModeName,
    int bufferMinutes = 10,
  }) {
    final alternatives = <String>[];

    for (final game in userGames) {
      for (final mode in game.enabledModes) {
        if (game.id == excludeGameId && mode.name == excludeModeName) continue;

        final risk = calculateRisk(mode, minutesAvailable, bufferMinutes: bufferMinutes);
        if (risk != RiskLevel.high) {
          if (mode.commitmentType == GameCommitmentType.flexible) {
            alternatives.add('${game.name} · ${mode.name} (Flexible)');
          } else {
            alternatives.add('${game.name} · ${mode.name} (~${mode.estimatedMinutes} min)');
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
