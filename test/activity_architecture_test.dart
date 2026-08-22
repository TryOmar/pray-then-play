import 'package:flutter_test/flutter_test.dart';
import 'package:pray_then_play/core/constants/app_constants.dart';
import 'package:pray_then_play/core/constants/game_data.dart';
import 'package:pray_then_play/core/models/game_profile.dart';
import 'package:pray_then_play/core/utils/risk_calculator.dart';

void main() {
  group('Activity-Based Gaming Architecture Tests', () {
    test('Minecraft activities have distinct session and risk characteristics',
        () {
      final mc =
          GameData.defaultCatalog.firstWhere((g) => g.id == 'minecraft');

      final survival = mc.activities.firstWhere((a) => a.id == 'mc_survival');
      final hardcore = mc.activities.firstWhere((a) => a.id == 'mc_hardcore');
      final pvp = mc.activities.firstWhere((a) => a.id == 'mc_pvp');
      final creative = mc.activities.firstWhere((a) => a.id == 'mc_creative');

      // Survival is pauseable and flexible
      expect(survival.canPause, isTrue);
      expect(survival.canLeaveSafely, isTrue);
      expect(survival.requiresCompletion, isFalse);
      expect(survival.isCompetitive, isFalse);

      // Hardcore requires focus
      expect(hardcore.typicalDuration, equals(60));
      expect(hardcore.canPause, isTrue);

      // PvP is competitive multiplayer
      expect(pvp.isCompetitive, isTrue);
      expect(pvp.canPause, isFalse);
      expect(pvp.requiresCompletion, isTrue);

      // Creative is completely casual
      expect(creative.commitmentType, equals(GameCommitmentType.flexible));
    });

    test('Queue check evaluates target desired session duration correctly', () {
      final valorant =
          GameData.defaultCatalog.firstWhere((g) => g.id == 'valorant');
      final ranked =
          valorant.activities.firstWhere((a) => a.id == 'val_ranked');
      final swiftplay =
          valorant.activities.firstWhere((a) => a.id == 'val_swiftplay');

      // 1. User wants 30 min session with Swiftplay (18m max) -> Fits within 35 min safe window -> LOW risk
      final resultLow = RiskCalculator.checkQueue(
        game: valorant,
        activity: swiftplay,
        minutesUntilPrayer: 45,
        nextPrayerName: 'Asr',
        userGames: GameData.defaultCatalog,
        bufferMinutes: 10,
        desiredSessionMinutes: 30,
      );
      expect(resultLow.riskLevel, equals(RiskLevel.low));

      // 2. User wants 40 min session -> Fits prayer (45m) but cuts into 10m buffer -> MEDIUM risk
      final resultMed = RiskCalculator.checkQueue(
        game: valorant,
        activity: ranked,
        minutesUntilPrayer: 45,
        nextPrayerName: 'Asr',
        userGames: GameData.defaultCatalog,
        bufferMinutes: 10,
        desiredSessionMinutes: 40,
      );
      expect(resultMed.riskLevel, equals(RiskLevel.medium));

      // 3. User has 25 min until prayer (15m safe) -> Exceeds Ranked duration -> HIGH risk
      final resultHigh = RiskCalculator.checkQueue(
        game: valorant,
        activity: ranked,
        minutesUntilPrayer: 25,
        nextPrayerName: 'Asr',
        userGames: GameData.defaultCatalog,
        bufferMinutes: 10,
        desiredSessionMinutes: 60,
      );
      expect(resultHigh.riskLevel, equals(RiskLevel.high));
      expect(resultHigh.suggestedAlternatives, isNotEmpty);
    });

    test('User can create custom activities and custom games', () {
      const customAct = GameActivity(
        id: 'val_custom_scrim',
        gameId: 'valorant',
        name: 'Custom 5v5 Scrim',
        typicalDuration: 50,
        minMinutes: 40,
        maxMinutes: 65,
        safetyBuffer: 15,
        canPause: false,
        requiresCompletion: true,
        isCompetitive: true,
        isCustom: true,
      );

      expect(customAct.isCustom, isTrue);
      expect(customAct.safetyBuffer, equals(15));
      expect(customAct.typicalDuration, equals(50));

      const profile = GameProfile(
        id: 'custom_rpg',
        name: 'Custom Action RPG',
        category: GameCategory.casual,
        iconName: 'custom_gamepad',
        color: 0xFF00E5FF,
        isCustom: true,
        activities: [customAct],
      );

      expect(profile.isCustom, isTrue);
      expect(profile.activities.length, equals(1));
      expect(profile.activities.first.name, equals('Custom 5v5 Scrim'));
    });

    test('Activity JSON serialization and backwards compatibility', () {
      const activity = GameActivity(
        id: 'test_act',
        gameId: 'test_game',
        name: 'Ranked Match',
        typicalDuration: 35,
        minMinutes: 30,
        maxMinutes: 45,
        canPause: false,
        requiresCompletion: true,
        isCompetitive: true,
      );

      final json = activity.toJson();
      final restored = GameActivity.fromJson(json);

      expect(restored.id, equals('test_act'));
      expect(restored.gameId, equals('test_game'));
      expect(restored.name, equals('Ranked Match'));
      expect(restored.typicalDuration, equals(35));
      expect(restored.estimatedMinutes, equals(35));
      expect(restored.canPause, isFalse);
      expect(restored.canLeaveSafely, isFalse);

      final jsonOutput = activity.toJson();
      expect(jsonOutput['typicalDuration'], equals(35));
      expect(jsonOutput['estimatedMinutes'], equals(35));
      expect(jsonOutput['canPause'], isFalse);
    });
  });
}
