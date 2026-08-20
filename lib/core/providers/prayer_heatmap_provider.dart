import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prayer_record.dart';
import '../services/storage_service.dart';

class PrayerConsistencyState {
  final DateTime selectedDate;
  final int selectedYear;
  final int selectedMonth;
  final Map<String, DailyPrayerRecord> recordsCache; // key: YYYY-MM-DD
  final int protectedPrayers;
  final int avoidedRiskyQueue;
  final int stoppedToPray;
  final int choseShortGame;
  final Set<String> unlockedAchievements;

  const PrayerConsistencyState({
    required this.selectedDate,
    required this.selectedYear,
    required this.selectedMonth,
    required this.recordsCache,
    required this.protectedPrayers,
    required this.avoidedRiskyQueue,
    required this.stoppedToPray,
    required this.choseShortGame,
    required this.unlockedAchievements,
  });

  PrayerConsistencyState copyWith({
    DateTime? selectedDate,
    int? selectedYear,
    int? selectedMonth,
    Map<String, DailyPrayerRecord>? recordsCache,
    int? protectedPrayers,
    int? avoidedRiskyQueue,
    int? stoppedToPray,
    int? choseShortGame,
    Set<String>? unlockedAchievements,
  }) {
    return PrayerConsistencyState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      recordsCache: recordsCache ?? this.recordsCache,
      protectedPrayers: protectedPrayers ?? this.protectedPrayers,
      avoidedRiskyQueue: avoidedRiskyQueue ?? this.avoidedRiskyQueue,
      stoppedToPray: stoppedToPray ?? this.stoppedToPray,
      choseShortGame: choseShortGame ?? this.choseShortGame,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
    );
  }
}

class PrayerConsistencyNotifier extends StateNotifier<PrayerConsistencyState> {
  PrayerConsistencyNotifier()
      : super(PrayerConsistencyState(
          selectedDate: DateTime.now(),
          selectedYear: DateTime.now().year,
          selectedMonth: DateTime.now().month,
          recordsCache: _createInitialCache(),
          protectedPrayers: StorageService.protectedPrayersCount,
          avoidedRiskyQueue: StorageService.getGamingDecisionCount(GamingDecisionType.avoidedRiskyQueue),
          stoppedToPray: StorageService.getGamingDecisionCount(GamingDecisionType.stoppedToPray),
          choseShortGame: StorageService.getGamingDecisionCount(GamingDecisionType.choseShortGame),
          unlockedAchievements: StorageService.getUnlockedAchievements(),
        ));

  static Map<String, DailyPrayerRecord> _createInitialCache() {
    final cache = <String, DailyPrayerRecord>{};
    final now = DateTime.now();
    // Pre-populate past 140 days
    for (int i = 0; i < 140; i++) {
      final date = now.subtract(Duration(days: i));
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      cache[key] = StorageService.getDailyPrayerRecord(date);
    }
    return cache;
  }

  String _formatKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void setSelectedMonth(int year, int month) {
    state = state.copyWith(selectedYear: year, selectedMonth: month);
  }

  DailyPrayerRecord getRecord(DateTime date) {
    final key = _formatKey(date);
    if (state.recordsCache.containsKey(key)) {
      return state.recordsCache[key]!;
    }
    return StorageService.getDailyPrayerRecord(date);
  }

  Future<void> updatePrayerStatus(DateTime date, String prayerName, PrayerStatus status) async {
    final key = _formatKey(date);
    final current = getRecord(date);
    final updated = current.withPrayer(prayerName, status);

    await StorageService.saveDailyPrayerRecord(updated);

    final cache = Map<String, DailyPrayerRecord>.from(state.recordsCache);
    cache[key] = updated;

    state = state.copyWith(recordsCache: cache);

    // Check achievement unlock conditions
    _checkAchievements();
  }

  Future<void> logGamingDecision(GamingDecisionType type) async {
    await StorageService.incrementGamingDecision(type);
    if (type == GamingDecisionType.avoidedRiskyQueue || type == GamingDecisionType.stoppedToPray) {
      await StorageService.incrementProtectedPrayers();
    }

    state = state.copyWith(
      protectedPrayers: StorageService.protectedPrayersCount,
      avoidedRiskyQueue: StorageService.getGamingDecisionCount(GamingDecisionType.avoidedRiskyQueue),
      stoppedToPray: StorageService.getGamingDecisionCount(GamingDecisionType.stoppedToPray),
      choseShortGame: StorageService.getGamingDecisionCount(GamingDecisionType.choseShortGame),
    );

    _checkAchievements();
  }

  Future<void> resetHistory() async {
    await StorageService.clearAllDailyPrayerRecords();
    final cache = <String, DailyPrayerRecord>{};
    final now = DateTime.now();
    for (int i = 0; i < 140; i++) {
      final date = now.subtract(Duration(days: i));
      final key = _formatKey(date);
      cache[key] = StorageService.getDailyPrayerRecord(date);
    }
    state = state.copyWith(
      recordsCache: cache,
      protectedPrayers: 0,
      avoidedRiskyQueue: 0,
      stoppedToPray: 0,
      choseShortGame: 0,
      unlockedAchievements: <String>{},
    );
  }

  Future<void> loadDemoHistory() async {
    await StorageService.loadSampleDemoHistory();
    final cache = <String, DailyPrayerRecord>{};
    final now = DateTime.now();
    for (int i = 0; i < 140; i++) {
      final date = now.subtract(Duration(days: i));
      final key = _formatKey(date);
      cache[key] = StorageService.getDailyPrayerRecord(date);
    }
    state = state.copyWith(
      recordsCache: cache,
      protectedPrayers: StorageService.protectedPrayersCount,
      avoidedRiskyQueue: StorageService.getGamingDecisionCount(GamingDecisionType.avoidedRiskyQueue),
      stoppedToPray: StorageService.getGamingDecisionCount(GamingDecisionType.stoppedToPray),
      choseShortGame: StorageService.getGamingDecisionCount(GamingDecisionType.choseShortGame),
      unlockedAchievements: StorageService.getUnlockedAchievements(),
    );
  }

  void _checkAchievements() {
    bool hasAnyOnTime = false;
    bool hasFiveInDay = false;

    for (final record in state.recordsCache.values) {
      if (record.onTimeCount > 0) hasAnyOnTime = true;
      if (record.onTimeCount >= 5) hasFiveInDay = true;
    }

    if (hasAnyOnTime) {
      StorageService.unlockAchievement('first_step');
    }
    if (hasFiveInDay) {
      StorageService.unlockAchievement('five_in_day');
    }
    if (state.protectedPrayers >= 10) {
      StorageService.unlockAchievement('prayer_protector');
    }
    if (state.avoidedRiskyQueue >= 5) {
      StorageService.unlockAchievement('queue_discipline');
    }

    final currentStreak = getConsistencyStreak();
    if (currentStreak >= 7) {
      StorageService.unlockAchievement('consistent_week');
    }
    if (currentStreak >= 30) {
      StorageService.unlockAchievement('balanced_gamer');
    }

    state = state.copyWith(
        unlockedAchievements: StorageService.getUnlockedAchievements());
  }

  List<ContributionWeek> getContributionWeeks([int numberOfWeeks = 16]) {
    final now = DateTime.now();
    // Monday of current week
    final currentWeekMonday = now.subtract(Duration(days: now.weekday - 1));
    // Start Monday (numberOfWeeks - 1 weeks ago)
    final startMonday = currentWeekMonday.subtract(Duration(days: (numberOfWeeks - 1) * 7));

    final weeks = <ContributionWeek>[];
    int? lastMonthSeen;

    for (int w = 0; w < numberOfWeeks; w++) {
      final weekStart = startMonday.add(Duration(days: w * 7));
      final days = <DailyPrayerRecord?>[];
      String? monthLabel;

      for (int d = 0; d < 7; d++) {
        final dayDate = DateTime(weekStart.year, weekStart.month, weekStart.day + d);
        if (dayDate.isAfter(DateTime(now.year, now.month, now.day))) {
          days.add(null); // future
        } else {
          days.add(getRecord(dayDate));
        }

        // Check if 1st of month falls in this week or first week of month
        if (dayDate.day == 1 || (w == 0 && d == 0)) {
          if (lastMonthSeen != dayDate.month) {
            monthLabel = _monthAbbr(dayDate.month);
            lastMonthSeen = dayDate.month;
          }
        }
      }

      weeks.add(ContributionWeek(days: days, monthLabel: monthLabel));
    }

    return weeks;
  }

  static String _monthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  WeeklyPrayerSummary getWeeklySummary([DateTime? targetDate]) {
    final date = targetDate ?? DateTime.now();
    // Start of week (Monday)
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final days = <DailyPrayerRecord>[];

    for (int i = 0; i < 7; i++) {
      final dayDate = startOfWeek.add(Duration(days: i));
      days.add(getRecord(dayDate));
    }

    return WeeklyPrayerSummary(startOfWeek: startOfWeek, days: days);
  }

  MonthlyPrayerSummary getMonthlySummary(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final days = <DailyPrayerRecord>[];

    for (int day = 1; day <= daysInMonth; day++) {
      days.add(getRecord(DateTime(year, month, day)));
    }

    return MonthlyPrayerSummary(year: year, month: month, days: days);
  }

  int getConsistencyStreak() {
    int streak = 0;
    final now = DateTime.now();
    DateTime checkDate = DateTime(now.year, now.month, now.day);

    // If today has no recordings yet, also check yesterday as active baseline
    final todayRecord = getRecord(checkDate);
    if (todayRecord.completedCount == 0) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (true) {
      if (!StorageService.hasStoredDailyRecord(checkDate)) {
        break;
      }
      final record = getRecord(checkDate);
      if (record.onTimeCount >= 3) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
      if (streak >= 365) break;
    }
    return streak;
  }

  bool get hasAnyRecordedPrayers {
    for (final r in state.recordsCache.values) {
      if (r.prayers.values.any((s) =>
          s == PrayerStatus.onTime ||
          s == PrayerStatus.late ||
          s == PrayerStatus.missed ||
          s == PrayerStatus.skipped)) {
        return true;
      }
    }
    return StorageService.hasAnyRecordedHistory;
  }

  GamingHabitReflection getHabitReflection() {
    return GamingHabitReflection(
      protectedPrayersCount: state.protectedPrayers,
      avoidedRiskyQueueCount: state.avoidedRiskyQueue,
      stoppedToPrayCount: state.stoppedToPray,
      choseShortGameCount: state.choseShortGame,
      mostConsistentPrayer: hasAnyRecordedPrayers ? 'Fajr & Dhuhr' : 'None yet',
      opportunityPrayer: hasAnyRecordedPrayers ? 'Maghrib (Evening Gaming)' : 'Build your baseline',
      behavioralInsight: hasAnyRecordedPrayers
          ? 'Choosing short game modes before Maghrib protects your consistency and keeps your streak unbroken.'
          : 'Complete and record your daily prayers on time to generate personal habit reflection and gaming safety insights.',
    );
  }

  List<HabitAchievement> getAllAchievements() {
    final unlocked = state.unlockedAchievements;
    return [
      HabitAchievement(
        id: 'first_step',
        title: 'First Step',
        description: 'Complete and record your first prayer in Pray Then Play.',
        icon: Icons.flag_rounded,
        isUnlocked: unlocked.contains('first_step'),
        category: 'Getting Started',
      ),
      HabitAchievement(
        id: 'consistent_week',
        title: 'Consistent Week',
        description: 'Maintain your prayer routine on time for 7 days.',
        icon: Icons.calendar_today_rounded,
        isUnlocked: unlocked.contains('consistent_week'),
        category: 'Consistency',
      ),
      HabitAchievement(
        id: 'queue_discipline',
        title: 'Queue Discipline',
        description: 'Avoid starting a risky match before prayer 5 times.',
        icon: Icons.shield_rounded,
        isUnlocked: unlocked.contains('queue_discipline'),
        category: 'Gaming Discipline',
      ),
      HabitAchievement(
        id: 'five_in_day',
        title: 'Five in a Day',
        description: 'Record all five daily prayers on time.',
        icon: Icons.stars_rounded,
        isUnlocked: unlocked.contains('five_in_day'),
        category: 'Salah Focus',
      ),
      HabitAchievement(
        id: 'prayer_protector',
        title: 'Prayer Protector',
        description: 'Protect 10+ prayers by pausing or skipping risky queues.',
        icon: Icons.verified_user_rounded,
        isUnlocked: unlocked.contains('prayer_protector'),
        category: 'Gaming Discipline',
      ),
      HabitAchievement(
        id: 'balanced_gamer',
        title: 'Balanced Gamer',
        description: 'Maintain a balanced gaming and prayer routine for 30 days.',
        icon: Icons.military_tech_rounded,
        isUnlocked: unlocked.contains('balanced_gamer'),
        category: 'Mastery',
      ),
    ];
  }
}

final prayerConsistencyProvider =
    StateNotifierProvider<PrayerConsistencyNotifier, PrayerConsistencyState>((ref) {
  return PrayerConsistencyNotifier();
});
