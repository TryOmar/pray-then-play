import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme.dart';
import '../constants/app_constants.dart';
import '../constants/game_data.dart';
import '../constants/prayer_constants.dart';
import '../localization/app_language.dart';
import '../models/game_profile.dart';
import '../models/game_session_record.dart';
import '../models/prayer_record.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Onboarding
  static bool get isOnboardingComplete =>
      _prefs.getBool(AppConstants.keyOnboardingComplete) ?? false;

  static Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool(AppConstants.keyOnboardingComplete, value);

  // Location
  static double? get latitude => _prefs.getDouble(AppConstants.keyLatitude);
  static double? get longitude => _prefs.getDouble(AppConstants.keyLongitude);
  static String get cityName =>
      _prefs.getString(AppConstants.keyCityName) ?? 'Makkah';
  static String get countryName =>
      _prefs.getString(AppConstants.keyCountryName) ?? 'Saudi Arabia';

  static Future<void> setLocation(double lat, double lng, String city, {String country = ''}) async {
    await _prefs.setDouble(AppConstants.keyLatitude, lat);
    await _prefs.setDouble(AppConstants.keyLongitude, lng);
    await _prefs.setString(AppConstants.keyCityName, city);
    if (country.isNotEmpty) {
      await _prefs.setString(AppConstants.keyCountryName, country);
    }
  }

  // Calculation method
  static CalculationMethodType get calculationMethod {
    final index = _prefs.getInt(AppConstants.keyCalculationMethod) ?? 0;
    if (index >= 0 && index < CalculationMethodType.values.length) {
      return CalculationMethodType.values[index];
    }
    return CalculationMethodType.muslimWorldLeague;
  }

  static Future<void> setCalculationMethod(CalculationMethodType method) =>
      _prefs.setInt(AppConstants.keyCalculationMethod, method.index);

  // Asr Method
  static AsrMethodType get asrMethod {
    final index = _prefs.getInt(AppConstants.keyAsrMethod) ?? 0;
    if (index >= 0 && index < AsrMethodType.values.length) {
      return AsrMethodType.values[index];
    }
    return AsrMethodType.standard;
  }

  static Future<void> setAsrMethod(AsrMethodType method) =>
      _prefs.setInt(AppConstants.keyAsrMethod, method.index);

  // Protection level & buffer
  static ProtectionLevel get protectionLevel {
    final index = _prefs.getInt(AppConstants.keyProtectionLevel) ?? 1;
    if (index >= 0 && index < ProtectionLevel.values.length) {
      return ProtectionLevel.values[index];
    }
    return ProtectionLevel.balanced;
  }

  static Future<void> setProtectionLevel(ProtectionLevel level) =>
      _prefs.setInt(AppConstants.keyProtectionLevel, level.index);

  // Gaming Theme
  static AppGamingTheme get gamingTheme {
    final index = _prefs.getInt(AppConstants.keyGamingTheme) ?? 0;
    if (index >= 0 && index < AppGamingTheme.values.length) {
      return AppGamingTheme.values[index];
    }
    return AppGamingTheme.midnight;
  }

  static Future<void> setGamingTheme(AppGamingTheme theme) =>
      _prefs.setInt(AppConstants.keyGamingTheme, theme.index);

  // Theme Mode (Manual, System, Sunrise/Sunset)
  static ThemeModeOption get themeMode {
    final index = _prefs.getInt(AppConstants.keyThemeMode) ?? 0;
    if (index >= 0 && index < ThemeModeOption.values.length) {
      return ThemeModeOption.values[index];
    }
    return ThemeModeOption.manual;
  }

  static Future<void> setThemeMode(ThemeModeOption mode) =>
      _prefs.setInt(AppConstants.keyThemeMode, mode.index);

  // App Language
  static AppLanguage get appLanguage {
    final code = _prefs.getString(AppConstants.keyAppLanguage);
    return AppLanguage.fromCode(code);
  }

  static Future<void> setAppLanguage(AppLanguage language) =>
      _prefs.setString(AppConstants.keyAppLanguage, language.code);

  // Time Format (12-Hour vs 24-Hour)
  static bool get is24HourFormat =>
      _prefs.getBool(AppConstants.keyIs24HourFormat) ?? false;

  static Future<void> setIs24HourFormat(bool is24Hour) =>
      _prefs.setBool(AppConstants.keyIs24HourFormat, is24Hour);

  // Desktop Windows Settings
  static bool get minimizeToTrayOnClose =>
      _prefs.getBool('desktop_minimize_to_tray') ?? true;

  static Future<void> setMinimizeToTrayOnClose(bool val) =>
      _prefs.setBool('desktop_minimize_to_tray', val);

  static bool get launchOnStartup =>
      _prefs.getBool('desktop_launch_on_startup') ?? false;

  static Future<void> setLaunchOnStartup(bool val) =>
      _prefs.setBool('desktop_launch_on_startup', val);

  // Gamer profile
  static GamerProfile get gamerProfile {
    final index = _prefs.getInt(AppConstants.keyGamerProfile) ?? 0;
    if (index >= 0 && index < GamerProfile.values.length) {
      return GamerProfile.values[index];
    }
    return GamerProfile.casual;
  }

  static Future<void> setGamerProfile(GamerProfile profile) =>
      _prefs.setInt(AppConstants.keyGamerProfile, profile.index);

  // Configured Games (User's active games & customized activity settings)
  static List<GameProfile> getUserGames() {
    final jsonStr = _prefs.getString(AppConstants.keyConfiguredGames);
    if (jsonStr == null || jsonStr.isEmpty) {
      // If user hasn't selected yet, default to top 3 popular games
      return [
        GameData.defaultCatalog.firstWhere((g) => g.id == 'valorant'),
        GameData.defaultCatalog.firstWhere((g) => g.id == 'league_of_legends'),
        GameData.defaultCatalog.firstWhere((g) => g.id == 'minecraft'),
      ];
    }
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) {
        final profile = GameProfile.fromJson(e as Map<String, dynamic>);
        final catalogMatch =
            GameData.defaultCatalog.where((g) => g.id == profile.id).firstOrNull;
        if (catalogMatch != null) {
          // Merge activities: retain user custom activities and customized overrides,
          // while ensuring newly available official activities appear
          final mergedActivities = <GameActivity>[];
          final userActivitiesMap = {for (var a in profile.activities) a.id: a};

          for (final officialAct in catalogMatch.activities) {
            if (userActivitiesMap.containsKey(officialAct.id)) {
              mergedActivities.add(userActivitiesMap[officialAct.id]!);
            } else {
              mergedActivities.add(officialAct);
            }
          }

          // Add any custom activities created by user
          for (final userAct in profile.activities) {
            if (userAct.isCustom &&
                !mergedActivities.any((a) => a.id == userAct.id)) {
              mergedActivities.add(userAct);
            }
          }

          return profile.copyWith(
            iconName: catalogMatch.iconName,
            color: catalogMatch.color,
            activities: mergedActivities,
          );
        }
        return profile;
      }).toList();
    } catch (_) {
      return [
        GameData.defaultCatalog.firstWhere((g) => g.id == 'valorant'),
        GameData.defaultCatalog.firstWhere((g) => g.id == 'league_of_legends'),
        GameData.defaultCatalog.firstWhere((g) => g.id == 'minecraft'),
      ];
    }
  }

  static Future<void> setUserGames(List<GameProfile> games) async {
    final jsonStr = jsonEncode(games.map((g) => g.toJson()).toList());
    await _prefs.setString(AppConstants.keyConfiguredGames, jsonStr);
  }

  // Gaming Session History & Personal Statistics
  static List<GameSessionRecord> getGameSessionHistory() {
    final jsonStr = _prefs.getString(AppConstants.keyGameSessions);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List;
      return list
          .map((e) => GameSessionRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveGameSession(GameSessionRecord record) async {
    final history = getGameSessionHistory();
    history.insert(0, record);
    // Keep last 100 sessions
    if (history.length > 100) {
      history.removeRange(100, history.length);
    }
    final jsonStr = jsonEncode(history.map((s) => s.toJson()).toList());
    await _prefs.setString(AppConstants.keyGameSessions, jsonStr);
  }

  static ActivitySessionStats getActivitySessionStats(
      String gameId, String activityId) {
    final history = getGameSessionHistory().where((s) =>
        s.gameId == gameId &&
        (s.activityId == activityId || s.activityName == activityId));

    if (history.isEmpty) {
      return ActivitySessionStats.empty;
    }

    final durations = history.map((s) => s.durationMinutes).toList();
    final count = durations.length;
    final avg = (durations.reduce((a, b) => a + b) / count).round();
    final longest = durations.reduce((a, b) => a > b ? a : b);
    final shortest = durations.reduce((a, b) => a < b ? a : b);

    return ActivitySessionStats(
      sessionCount: count,
      averageDurationMinutes: avg,
      longestDurationMinutes: longest,
      shortestDurationMinutes: shortest,
    );
  }

  // Prayer tracking (Boolean quick check)
  static Map<String, bool> getTodayPrayerStatus() {
    final record = getDailyPrayerRecord(DateTime.now());
    return {
      'Fajr': record.prayers['Fajr']?.isCompleted ?? false,
      'Dhuhr': record.prayers['Dhuhr']?.isCompleted ?? false,
      'Asr': record.prayers['Asr']?.isCompleted ?? false,
      'Maghrib': record.prayers['Maghrib']?.isCompleted ?? false,
      'Isha': record.prayers['Isha']?.isCompleted ?? false,
    };
  }

  static Future<void> markPrayerCompleted(
    String prayerName, {
    PrayerStatus status = PrayerStatus.onTime,
    DateTime? completedAt,
    DateTime? adhanTime,
    PrayerSource source = PrayerSource.manual,
    String? notes,
  }) async {
    final today = DateTime.now();
    final record = getDailyPrayerRecord(today);
    final completionTime = completedAt ?? DateTime.now();
    final adhan = adhanTime ?? completionTime;

    final classification = PrayerRecordItem.deriveClassification(
      adhanTime: adhan,
      completedAt: completionTime,
    );

    final item = PrayerRecordItem(
      id: '${prayerName}_${today.year}_${today.month}_${today.day}',
      prayerName: prayerName,
      adhanTime: adhan,
      status: status,
      completedAt: completionTime,
      classification: classification,
      source: source,
      notes: notes,
      updatedAt: DateTime.now(),
    );

    final updatedDetails = Map<String, PrayerRecordItem>.from(record.detailedRecords ?? {});
    updatedDetails[prayerName] = item;

    final updatedRecord = record.copyWith(
      prayers: Map.from(record.prayers)..[prayerName] = status,
      detailedRecords: updatedDetails,
    );

    await saveDailyPrayerRecord(updatedRecord);
  }

  static Future<void> togglePrayer(String prayerName, {DateTime? adhanTime}) async {
    final today = DateTime.now();
    final record = getDailyPrayerRecord(today);
    final current = record.prayers[prayerName] ?? PrayerStatus.notRecorded;

    if (current.isCompleted) {
      // Toggle to not recorded
      final updatedDetails = Map<String, PrayerRecordItem>.from(record.detailedRecords ?? {});
      updatedDetails.remove(prayerName);
      final updatedRecord = record.copyWith(
        prayers: Map.from(record.prayers)..[prayerName] = PrayerStatus.notRecorded,
        detailedRecords: updatedDetails,
      );
      await saveDailyPrayerRecord(updatedRecord);
    } else {
      // Quick mark as completed at current time
      final now = DateTime.now();
      final adhan = adhanTime ?? now;
      final classification = PrayerRecordItem.deriveClassification(
        adhanTime: adhan,
        completedAt: now,
      );
      final derivedStatus = classification == PrayerClassification.onTime
          ? PrayerStatus.onTime
          : PrayerStatus.late;

      await markPrayerCompleted(
        prayerName,
        status: derivedStatus,
        completedAt: now,
        adhanTime: adhan,
        source: PrayerSource.automatic,
      );
    }
  }

  static Future<void> savePrayerRecordItem(PrayerRecordItem item, DateTime date) async {
    final record = getDailyPrayerRecord(date);
    final updatedDetails = Map<String, PrayerRecordItem>.from(record.detailedRecords ?? {});
    updatedDetails[item.prayerName] = item;

    final updatedRecord = record.copyWith(
      prayers: Map.from(record.prayers)..[item.prayerName] = item.status,
      detailedRecords: updatedDetails,
    );
    await saveDailyPrayerRecord(updatedRecord);
  }

  // Multi-state Daily Prayer Records (Heatmap & Consistency History)
  static String _dateKey(DateTime date) =>
      'daily_prayer_record_${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}';

  static bool hasStoredDailyRecord(DateTime date) {
    final key = _dateKey(date);
    return _prefs.containsKey(key);
  }

  static bool get hasAnyRecordedHistory {
    final keys = _prefs.getKeys();
    return keys.any((k) => k.startsWith('daily_prayer_record_'));
  }

  static DailyPrayerRecord getDailyPrayerRecord(DateTime date) {
    final key = _dateKey(date);
    final jsonStr = _prefs.getString(key);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        return DailyPrayerRecord.fromJson(
            jsonDecode(jsonStr) as Map<String, dynamic>);
      } catch (_) {}
    }

    final today = DateTime.now();
    final isFuture = date.isAfter(DateTime(today.year, today.month, today.day));

    if (isFuture) {
      return DailyPrayerRecord(
        date: date,
        prayers: {
          'Fajr': PrayerStatus.upcoming,
          'Dhuhr': PrayerStatus.upcoming,
          'Asr': PrayerStatus.upcoming,
          'Maghrib': PrayerStatus.upcoming,
          'Isha': PrayerStatus.upcoming,
        },
      );
    }

    // Authentic clean slate: unrecorded days start empty
    return DailyPrayerRecord(
      date: date,
      prayers: {
        'Fajr': PrayerStatus.notRecorded,
        'Dhuhr': PrayerStatus.notRecorded,
        'Asr': PrayerStatus.notRecorded,
        'Maghrib': PrayerStatus.notRecorded,
        'Isha': PrayerStatus.notRecorded,
      },
    );
  }

  static Future<void> saveDailyPrayerRecord(DailyPrayerRecord record) async {
    final key = _dateKey(record.date);
    await _prefs.setString(key, jsonEncode(record.toJson()));
  }

  /// Clears all stored daily prayer records and resets metrics to Day 1
  static Future<void> clearAllDailyPrayerRecords() async {
    final keys = _prefs.getKeys().toList();
    for (final k in keys) {
      if (k.startsWith('daily_prayer_record_') ||
          k.startsWith('decision_') ||
          k == 'protected_prayers_count' ||
          k == 'unlocked_achievements') {
        await _prefs.remove(k);
      }
    }
  }

  /// Seeds realistic 30-day history for demo / screenshots
  static Future<void> loadSampleDemoHistory() async {
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final dayIndex = date.day + date.month * 31;
      final fStatus =
          (dayIndex % 7 == 0) ? PrayerStatus.late : PrayerStatus.onTime;
      final dStatus =
          (dayIndex % 11 == 0) ? PrayerStatus.late : PrayerStatus.onTime;
      final aStatus =
          (dayIndex % 13 == 0) ? PrayerStatus.late : PrayerStatus.onTime;
      final mStatus = (dayIndex % 5 == 0)
          ? PrayerStatus.late
          : ((dayIndex % 23 == 0)
              ? PrayerStatus.notRecorded
              : PrayerStatus.onTime);
      final iStatus =
          (dayIndex % 9 == 0) ? PrayerStatus.late : PrayerStatus.onTime;

      final record = DailyPrayerRecord(
        date: date,
        prayers: {
          'Fajr': fStatus,
          'Dhuhr': dStatus,
          'Asr': aStatus,
          'Maghrib': mStatus,
          'Isha': iStatus,
        },
      );
      await saveDailyPrayerRecord(record);
    }

    await _prefs.setInt('protected_prayers_count', 18);
    await _prefs.setInt('decision_avoidedRiskyQueue', 23);
    await _prefs.setInt('decision_stoppedToPray', 14);
    await _prefs.setInt('decision_choseShortGame', 8);
    await _prefs.setStringList('unlocked_achievements',
        ['first_step', 'queue_discipline', 'consistent_week', 'prayer_protector']);
  }

  // Gaming Discipline & Protection Metrics
  static int get protectedPrayersCount =>
      _prefs.getInt('protected_prayers_count') ?? 0;

  static Future<void> incrementProtectedPrayers() async {
    final count = protectedPrayersCount + 1;
    await _prefs.setInt('protected_prayers_count', count);
  }

  static int getGamingDecisionCount(GamingDecisionType type) {
    return _prefs.getInt('decision_${type.name}') ?? 0;
  }

  static Future<void> incrementGamingDecision(GamingDecisionType type) async {
    final current = getGamingDecisionCount(type);
    await _prefs.setInt('decision_${type.name}', current + 1);
  }

  // Unlocked Achievements
  static Set<String> getUnlockedAchievements() {
    final list = _prefs.getStringList('unlocked_achievements');
    return list?.toSet() ?? <String>{};
  }

  static Future<void> unlockAchievement(String id) async {
    final set = getUnlockedAchievements();
    set.add(id);
    await _prefs.setStringList('unlocked_achievements', set.toList());
  }

  // In-match state
  static bool get isInMatch =>
      _prefs.getBool(AppConstants.keyInMatch) ?? false;

  static Future<void> setInMatch(bool value) =>
      _prefs.setBool(AppConstants.keyInMatch, value);

  static DateTime? get matchStartTime {
    final ms = _prefs.getInt(AppConstants.keyMatchStartTime);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  static Future<void> setMatchStartTime(DateTime? time) async {
    if (time == null) {
      await _prefs.remove(AppConstants.keyMatchStartTime);
    } else {
      await _prefs.setInt(
          AppConstants.keyMatchStartTime, time.millisecondsSinceEpoch);
    }
  }

  // Special Modes
  static bool get jumuahMode =>
      _prefs.getBool(AppConstants.keyJumuahMode) ?? true;

  static Future<void> setJumuahMode(bool value) =>
      _prefs.setBool(AppConstants.keyJumuahMode, value);

  static bool get fajrMode =>
      _prefs.getBool(AppConstants.keyFajrMode) ?? true;

  static Future<void> setFajrMode(bool value) =>
      _prefs.setBool(AppConstants.keyFajrMode, value);
}
