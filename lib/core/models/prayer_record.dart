import 'package:flutter/material.dart';
import '../../app/theme.dart';

enum PrayerStatus {
  onTime,
  late,
  missed,
  notRecorded,
  upcoming,
  skipped;

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
      case PrayerStatus.skipped:
        return 'Skipped';
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
      case PrayerStatus.skipped:
        return const Color(0xFF475569);
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
      case PrayerStatus.skipped:
        return Icons.remove_circle_outline_rounded;
    }
  }

  bool get isCompleted => this == PrayerStatus.onTime || this == PrayerStatus.late;
}

enum PrayerClassification {
  onTime,
  late,
  unknown;

  String get label {
    switch (this) {
      case PrayerClassification.onTime:
        return 'On Time';
      case PrayerClassification.late:
        return 'Late';
      case PrayerClassification.unknown:
        return 'Not Classified';
    }
  }

  Color get color {
    switch (this) {
      case PrayerClassification.onTime:
        return AppColors.successGreen;
      case PrayerClassification.late:
        return AppColors.warningAmber;
      case PrayerClassification.unknown:
        return AppColors.textMuted;
    }
  }
}

enum PrayerSource {
  automatic,
  manual,
  notification;

  String get label {
    switch (this) {
      case PrayerSource.automatic:
        return 'Automatic Quick Tap';
      case PrayerSource.manual:
        return 'Manual Log';
      case PrayerSource.notification:
        return 'Notification Action';
    }
  }
}

/// An individual auditable prayer completion record.
class PrayerRecordItem {
  final String id;
  final String prayerName;
  final DateTime adhanTime;
  final PrayerStatus status;
  final DateTime? completedAt;
  final PrayerClassification classification;
  final PrayerSource source;
  final String? notes;
  final DateTime updatedAt;

  const PrayerRecordItem({
    required this.id,
    required this.prayerName,
    required this.adhanTime,
    required this.status,
    this.completedAt,
    this.classification = PrayerClassification.unknown,
    this.source = PrayerSource.manual,
    this.notes,
    required this.updatedAt,
  });

  /// Derive classification rule-based from timestamps rather than arbitrary button clicks.
  static PrayerClassification deriveClassification({
    required DateTime adhanTime,
    required DateTime? completedAt,
    int onTimeWindowMinutes = 60,
  }) {
    if (completedAt == null) return PrayerClassification.unknown;
    final diff = completedAt.difference(adhanTime).inMinutes;
    // If prayed between Adhan and threshold (or within 5 min before if early prayer), it's On Time.
    if (diff >= -5 && diff <= onTimeWindowMinutes) {
      return PrayerClassification.onTime;
    }
    return PrayerClassification.late;
  }

  PrayerRecordItem copyWith({
    String? id,
    String? prayerName,
    DateTime? adhanTime,
    PrayerStatus? status,
    DateTime? completedAt,
    PrayerClassification? classification,
    PrayerSource? source,
    String? notes,
    DateTime? updatedAt,
  }) {
    return PrayerRecordItem(
      id: id ?? this.id,
      prayerName: prayerName ?? this.prayerName,
      adhanTime: adhanTime ?? this.adhanTime,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      classification: classification ?? this.classification,
      source: source ?? this.source,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prayerName': prayerName,
      'adhanTime': adhanTime.toIso8601String(),
      'status': status.name,
      'completedAt': completedAt?.toIso8601String(),
      'classification': classification.name,
      'source': source.name,
      'notes': notes,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PrayerRecordItem.fromJson(Map<String, dynamic> json) {
    return PrayerRecordItem(
      id: json['id'] as String? ?? UniqueKey().toString(),
      prayerName: json['prayerName'] as String,
      adhanTime: DateTime.parse(json['adhanTime'] as String),
      status: PrayerStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => PrayerStatus.notRecorded,
      ),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      classification: PrayerClassification.values.firstWhere(
        (c) => c.name == json['classification'],
        orElse: () => PrayerClassification.unknown,
      ),
      source: PrayerSource.values.firstWhere(
        (s) => s.name == json['source'],
        orElse: () => PrayerSource.manual,
      ),
      notes: json['notes'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}

class DailyPrayerRecord {
  final DateTime date;
  final Map<String, PrayerStatus> prayers;
  final Map<String, PrayerRecordItem>? detailedRecords;

  const DailyPrayerRecord({
    required this.date,
    required this.prayers,
    this.detailedRecords,
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
    Map<String, PrayerRecordItem>? detailedRecords,
  }) {
    return DailyPrayerRecord(
      date: date ?? this.date,
      prayers: prayers ?? Map.from(this.prayers),
      detailedRecords: detailedRecords ?? this.detailedRecords,
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
      if (detailedRecords != null)
        'detailedRecords': detailedRecords!.map((k, v) => MapEntry(k, v.toJson())),
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

    Map<String, PrayerRecordItem>? detailed;
    if (json['detailedRecords'] != null) {
      final map = json['detailedRecords'] as Map<String, dynamic>;
      detailed = map.map((k, v) => MapEntry(k, PrayerRecordItem.fromJson(v as Map<String, dynamic>)));
    }

    return DailyPrayerRecord(
      date: date,
      prayers: prayers,
      detailedRecords: detailed,
    );
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
  double get weekOverWeekImprovement => 12.0;
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
  final List<DailyPrayerRecord?> days;
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
        return 'Paused session to pray';
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
