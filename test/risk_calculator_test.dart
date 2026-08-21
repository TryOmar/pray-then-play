import 'package:flutter_test/flutter_test.dart';
import 'package:pray_then_play/core/constants/app_constants.dart';
import 'package:pray_then_play/core/models/game_profile.dart';
import 'package:pray_then_play/core/utils/risk_calculator.dart';
import 'package:pray_then_play/core/utils/time_utils.dart';

void main() {
  group('RiskCalculator Tests with Safety Buffer', () {
    test('calculateGamingStatus categorizes with safety buffer', () {
      expect(RiskCalculator.calculateGamingStatus(60, bufferMinutes: 10),
          equals(GamingStatus.safe));
      expect(RiskCalculator.calculateGamingStatus(20, bufferMinutes: 10),
          equals(GamingStatus.caution));
      expect(RiskCalculator.calculateGamingStatus(8, bufferMinutes: 10),
          equals(GamingStatus.dontQueue));
      expect(RiskCalculator.calculateGamingStatus(0, bufferMinutes: 10),
          equals(GamingStatus.prayerTime));
    });

    test('calculateRisk assesses match duration with safety buffer', () {
      const mode = GameActivity(
        name: 'Competitive',
        typicalDuration: 30,
        minMinutes: 25,
        maxMinutes: 40,
        canPause: false,
        requiresCompletion: true,
        commitmentType: GameCommitmentType.commitment,
      );

      // 40 min max + 10 min buffer = 50 min needed for low risk
      expect(RiskCalculator.calculateRisk(mode, 55, bufferMinutes: 10),
          equals(RiskLevel.low));
      expect(RiskCalculator.calculateRisk(mode, 35, bufferMinutes: 10),
          equals(RiskLevel.medium));
      expect(RiskCalculator.calculateRisk(mode, 20, bufferMinutes: 10),
          equals(RiskLevel.high));
    });

    test('Flexible games are always low risk', () {
      const flexMode = GameActivity(
        name: 'Singleplayer Survival',
        typicalDuration: 45,
        commitmentType: GameCommitmentType.flexible,
        canPause: true,
        requiresCompletion: false,
      );

      expect(RiskCalculator.calculateRisk(flexMode, 15, bufferMinutes: 10),
          equals(RiskLevel.low));
    });

    test('checkQueue returns personalized alternatives from user games only',
        () {
      const valGame = GameProfile(
        id: 'valorant',
        name: 'Valorant',
        iconName: 'valorant',
        color: 0xFFFF4655,
        activities: [
          GameActivity(
              id: 'val_comp',
              name: 'Competitive',
              typicalDuration: 40,
              minMinutes: 30,
              maxMinutes: 50,
              canPause: false,
              requiresCompletion: true),
          GameActivity(
              id: 'val_swift',
              name: 'Swiftplay',
              typicalDuration: 15,
              minMinutes: 10,
              maxMinutes: 18,
              canPause: false,
              requiresCompletion: true,
              commitmentType: GameCommitmentType.shortSession),
        ],
      );

      const mcGame = GameProfile(
        id: 'minecraft',
        name: 'Minecraft',
        iconName: 'minecraft',
        color: 0xFF5E9634,
        activities: [
          GameActivity(
              id: 'mc_surv',
              name: 'Survival',
              typicalDuration: 30,
              commitmentType: GameCommitmentType.flexible,
              canPause: true,
              requiresCompletion: false),
        ],
      );

      final result = RiskCalculator.checkQueue(
        game: valGame,
        activity: valGame.activities.first,
        minutesUntilPrayer: 20,
        nextPrayerName: 'Maghrib',
        userGames: [valGame, mcGame],
        bufferMinutes: 5,
      );

      expect(result.riskLevel, equals(RiskLevel.high));
      expect(result.suggestedAlternatives, isNotEmpty);
      expect(result.suggestedAlternatives.any((a) => a.contains('Swiftplay')),
          isTrue);
      expect(result.suggestedAlternatives.any((a) => a.contains('Minecraft')),
          isTrue);
    });
  });

  group('TimeUtils Tests', () {
    test('formatMinutes formats correctly', () {
      expect(TimeUtils.formatMinutes(25), equals('25 min'));
      expect(TimeUtils.formatMinutes(60), equals('1h'));
      expect(TimeUtils.formatMinutes(90), equals('1h 30m'));
    });

    test('describeTimeRemaining formats descriptions', () {
      expect(TimeUtils.describeTimeRemaining(0), equals('Now'));
      expect(TimeUtils.describeTimeRemaining(4), equals('Less than 5 minutes'));
      expect(TimeUtils.describeTimeRemaining(8), equals('About 8 minutes'));
    });
  });
}
