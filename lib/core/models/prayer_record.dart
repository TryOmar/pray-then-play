import 'package:flutter/material.dart';
import '../../app/theme.dart';

enum PrayerStatus {
  onTime,
  late,
  missed,
  notRecorded,
  upcoming;

  String get label {
    switch (this) {
      case PrayerStatus.onTime:
        return 'On time';
      case PrayerStatus.late:
        return 'Late';
      case PrayerStatus.missed:
        return 'Missed';
      case PrayerStatus.notRecorded:
        return 'Not recorded';
      case PrayerStatus.upcoming:
        return 'Upcoming';
    }
  }

  Color get color {
    switch (this) {
      case PrayerStatus.onTime:
        return AppColors.successGreen;
      case PrayerStatus.late:
        return AppColors.warningAmber;
      case PrayerStatus.missed:
        return AppColors.dangerRed;
      case PrayerStatus.notRecorded:
        return const Color(0xFF64748B);
      case PrayerStatus.upcoming:
        return const Color(0xFF334155);
    }
  }

  IconData get icon {
    switch (this) {
      case PrayerStatus.onTime:
        return Icons.check_circle_rounded;
      case PrayerStatus.late:
        return Icons.access_time_rounded;
      case PrayerStatus.missed:
        return Icons.cancel_rounded;
      case PrayerStatus.notRecorded:
        return Icons.radio_button_unchecked_rounded;
      case PrayerStatus.upcoming:
        return Icons.schedule_rounded;
    }
  }

  bool get isCompleted => this == PrayerStatus.onTime || this == PrayerStatus.late;
}

class DailyPrayerRecord {
  final DateTime date;
  final Map<String, PrayerStatus> prayers;

  const DailyPrayerRecord({
    required this.date,
    required this.prayers,
  });

  factory DailyPrayerRecord.empty(DateTime date) {
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

  int get onTimeCount => prayers.values.where((s) => s == PrayerStatus.onTime).length;
  int get lateCount => prayers.values.where((s) => s == PrayerStatus.late).length;
  int get missedCount => prayers.values.where((s) => s == PrayerStatus.missed).length;
  int get notRecordedCount => prayers.values.where((s) => s == PrayerStatus.notRecorded).length;
  int get completedCount => onTimeCount + lateCount;

  double get consistencyRate => (completedCount / 5.0) * 100.0;
  double get onTimeRate => completedCount == 0 ? 0.0 : (onTimeCount / completedCount) * 100.0;

  DailyPrayerRecord copyWith({
    DateTime? date,
    Map<String, PrayerStatus>? prayers,
  }) {
    return DailyPrayerRecord(
      date: date ?? this.date,
      prayers: prayers ?? Map.from(this.prayers),
    );
  }

  DailyPrayerRecord withPrayer(String prayerName, PrayerStatus status) {
    final updated = Map<String, PrayerStatus>.from(prayers);
    updated[prayerName] = status;
    return copyWith(prayers: updated);
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'prayers': prayers.map((k, v) => MapEntry(k, v.name)),
    };
  }

  factory DailyPrayerRecord.fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['date'] as String);
    final prayersRaw = json['prayers'] as Map<String, dynamic>? ?? {};
    final prayers = <String, PrayerStatus>{};

    for (final name in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
      final statusName = prayersRaw[name] as String?;
      if (statusName != null) {
        try {
          prayers[name] = PrayerStatus.values.firstWhere((s) => s.name == statusName);
        } catch (_) {
          prayers[name] = PrayerStatus.notRecorded;
        }
      } else {
        prayers[name] = PrayerStatus.notRecorded;
      }
    }

    return DailyPrayerRecord(date: date, prayers: prayers);
  }
}

class WeeklyPrayerSummary {
  final DateTime startOfWeek;
  final List<DailyPrayerRecord> days;

  WeeklyPrayerSummary({required this.startOfWeek, required this.days});

  int get totalRecorded => days.fold(0, (acc, d) => acc + d.completedCount);
  int get totalPossible => days.length * 5;
  int get onTimeCount => days.fold(0, (acc, d) => acc + d.onTimeCount);
  int get lateCount => days.fold(0, (acc, d) => acc + d.lateCount);
  double get onTimeRate => totalRecorded == 0 ? 0.0 : (onTimeCount / totalRecorded) * 100.0;
  double get consistencyRate => totalPossible == 0 ? 0.0 : (totalRecorded / totalPossible) * 100.0;
  double get weekOverWeekImprovement => 12.0; // Positive habit delta percentage
}

class MonthlyPrayerSummary {
  final int year;
  final int month;
  final List<DailyPrayerRecord> days;

  MonthlyPrayerSummary({required this.year, required this.month, required this.days});

  int get totalRecorded => days.fold(0, (acc, d) => acc + d.completedCount);
  int get totalPossible => days.length * 5;
  int get onTimeCount => days.fold(0, (acc, d) => acc + d.onTimeCount);
  int get lateCount => days.fold(0, (acc, d) => acc + d.lateCount);
  double get onTimeRate => totalRecorded == 0 ? 0.0 : (onTimeCount / totalRecorded) * 100.0;
  double get consistencyRate => totalPossible == 0 ? 0.0 : (totalRecorded / totalPossible) * 100.0;
}

class ContributionWeek {
  final List<DailyPrayerRecord?> days; // 7 elements (Mon=0 to Sun=6)
  final String? monthLabel;

  ContributionWeek({required this.days, this.monthLabel});
}

enum GamingDecisionType {
  avoidedRiskyQueue,
  stoppedToPray,
  choseShortGame;

  String get label {
    switch (this) {
      case GamingDecisionType.avoidedRiskyQueue:
        return 'Avoided risky match queue';
      case GamingDecisionType.stoppedToPray:
        return 'Stopped gaming session to pray';
      case GamingDecisionType.choseShortGame:
        return 'Chose safe short game mode';
    }
  }

  IconData get icon {
    switch (this) {
      case GamingDecisionType.avoidedRiskyQueue:
        return Icons.shield_rounded;
      case GamingDecisionType.stoppedToPray:
        return Icons.pause_circle_filled_rounded;
      case GamingDecisionType.choseShortGame:
        return Icons.sports_esports_rounded;
    }
  }
}

class GamingHabitReflection {
  final int protectedPrayersCount;
  final int avoidedRiskyQueueCount;
  final int stoppedToPrayCount;
  final int choseShortGameCount;
  final String mostConsistentPrayer;
  final String opportunityPrayer;
  final String behavioralInsight;

  const GamingHabitReflection({
    required this.protectedPrayersCount,
    required this.avoidedRiskyQueueCount,
    required this.stoppedToPrayCount,
    required this.choseShortGameCount,
    required this.mostConsistentPrayer,
    required this.opportunityPrayer,
    required this.behavioralInsight,
  });
}

class HabitAchievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final String category;

  const HabitAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.category,
  });
}
