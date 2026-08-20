import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_salah/core/constants/app_constants.dart';
import 'package:gamer_salah/core/constants/game_data.dart';
import 'package:gamer_salah/core/models/game_profile.dart';
import 'package:gamer_salah/core/models/game_session_record.dart';
import 'package:gamer_salah/core/utils/risk_calculator.dart';

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
      expect(survival.requiresCompletion, isFalse);

      // Hardcore is pauseable singleplayer
      expect(hardcore.canPause, isTrue);

      // Server PvP is match locked and not pauseable
      expect(pvp.canPause, isFalse);
      expect(pvp.requiresCompletion, isTrue);
      expect(pvp.typicalDuration, lessThanOrEqualTo(20));

      // Creative is flexible
      expect(creative.canPause, isTrue);
      expect(creative.commitmentType, equals(GameCommitmentType.flexible));
    });

    test('Queue check evaluates target desired session duration correctly', () {
      final val = GameData.defaultCatalog.firstWhere((g) => g.id == 'valorant');
      final ranked = val.activities.firstWhere((a) => a.id == 'val_ranked');

      // Time until prayer: 45 min, Buffer: 10 min -> Safe available window = 35 min
      // 1. User wants 30 min session -> Fits within 35 min safe window -> LOW risk
      final result30 = RiskCalculator.checkQueue(
        game: val,
        activity: ranked,
        minutesUntilPrayer: 45,
        nextPrayerName: 'Asr',
        userGames: [val],
        bufferMinutes: 10,
        desiredSessionMinutes: 30,
      );
      expect(result30.riskLevel, equals(RiskLevel.low));
      expect(result30.verdictTitle, contains('SAFE TO START'));

      // 2. User wants 40 min session -> Fits prayer (45m) but cuts into 10m buffer -> MEDIUM risk
      final result40 = RiskCalculator.checkQueue(
        game: val,
        activity: ranked,
        minutesUntilPrayer: 45,
        nextPrayerName: 'Asr',
        userGames: [val],
        bufferMinutes: 10,
        desiredSessionMinutes: 40,
      );
      expect(result40.riskLevel, equals(RiskLevel.medium));
      expect(result40.verdictTitle, contains('TIGHT WINDOW'));

      // 3. User wants 60 min session -> Exceeds 45 min -> HIGH risk
      final result60 = RiskCalculator.checkQueue(
        game: val,
        activity: ranked,
        minutesUntilPrayer: 45,
        nextPrayerName: 'Asr',
        userGames: [val],
        bufferMinutes: 10,
        desiredSessionMinutes: 60,
      );
      expect(result60.riskLevel, equals(RiskLevel.high));
      expect(result60.verdictTitle, contains('NOT RECOMMENDED'));
    });

    test('User can create custom activities and custom games', () {
      const customActivity = GameActivity(
        id: 'mc_skyblock',
        gameId: 'minecraft',
        name: 'Skyblock Server',
        typicalDuration: 45,
        minMinutes: 20,
        maxMinutes: 90,
        canPause: true,
        requiresCompletion: false,
        isCompetitive: false,
        isCustom: true,
        notes: 'Weekend community island',
      );

      expect(customActivity.isCustom, isTrue);
      expect(customActivity.notes, equals('Weekend community island'));

      const customGame = GameProfile(
        id: 'fivem_server',
        name: 'My FiveM RP Server',
        category: GameCategory.casual,
        iconName: 'custom',
        color: 0xFF00E5FF,
        activities: [
          GameActivity(
            id: 'fivem_patrol',
            name: 'Police Patrol Shift',
            typicalDuration: 60,
            minMinutes: 30,
            maxMinutes: 120,
            canPause: false,
            requiresCompletion: false,
            isCustom: true,
          ),
        ],
        isCustom: true,
      );

      expect(customGame.isCustom, isTrue);
      expect(customGame.activities.length, equals(1));
      expect(customGame.modes.length, equals(1)); // backwards compatibility
    });

    test('Activity JSON serialization and backwards compatibility', () {
      // Test backwards compatible JSON with older keys
      final legacyJson = {
        'name': 'Ranked Match',
        'estimatedMinutes': 35,
        'minMinutes': 25,
        'maxMinutes': 45,
        'canLeaveSafely': false,
        'isCompetitive': true,
        'commitmentType': 0,
        'isEnabled': true,
      };

      final activity = GameActivity.fromJson(legacyJson);
      expect(activity.name, equals('Ranked Match'));
      expect(activity.typicalDuration, equals(35));
      expect(activity.estimatedMinutes, equals(35));
      expect(activity.canPause, isFalse);
      expect(activity.canLeaveSafely, isFalse);

      final jsonOutput = activity.toJson();
      expect(jsonOutput['typicalDuration'], equals(35));
      expect(jsonOutput['estimatedMinutes'], equals(35));
      expect(jsonOutput['canPause'], isFalse);
    });

    test('GameSessionRecord serialization and stats calculations', () {
      final now = DateTime.now();
      final record = GameSessionRecord(
        id: 'sess_1',
        gameId: 'minecraft',
        gameName: 'Minecraft',
        activityId: 'mc_survival',
        activityName: 'Singleplayer Survival',
        startedAt: now.subtract(const Duration(minutes: 47)),
        endedAt: now,
        durationMinutes: 47,
        wasInterruptedForPrayer: false,
      );

      final json = record.toJson();
      final restored = GameSessionRecord.fromJson(json);

      expect(restored.id, equals('sess_1'));
      expect(restored.durationMinutes, equals(47));
      expect(restored.activityName, equals('Singleplayer Survival'));
    });
  });
}
