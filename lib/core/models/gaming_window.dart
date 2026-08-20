import '../constants/app_constants.dart';

class GamingWindow {
  final DateTime start;
  final DateTime end;
  final GamingStatus status;
  final String label;
  final String? prayerName;
  final bool isCurrent;

  const GamingWindow({
    required this.start,
    required this.end,
    required this.status,
    required this.label,
    this.prayerName,
    this.isCurrent = false,
  });

  int get durationMinutes => end.difference(start).inMinutes;

  bool get isCurrentWindow {
    final now = DateTime.now();
    return now.isAfter(start) && now.isBefore(end);
  }
}

class QueueCheckResult {
  final RiskLevel riskLevel;
  final String verdictTitle;
  final int minutesUntilPrayer;
  final int availableSafeMinutes;
  final int estimatedMatchDuration;
  final int? requestedDurationMinutes;
  final bool canPause;
  final bool isCompetitive;
  final String nextPrayerName;
  final String message;
  final String recommendation;
  final List<String> suggestedAlternatives;
  final int? tightMargin;

  const QueueCheckResult({
    required this.riskLevel,
    this.verdictTitle = '',
    required this.minutesUntilPrayer,
    this.availableSafeMinutes = 0,
    required this.estimatedMatchDuration,
    this.requestedDurationMinutes,
    this.canPause = false,
    this.isCompetitive = false,
    required this.nextPrayerName,
    required this.message,
    required this.recommendation,
    this.suggestedAlternatives = const [],
    this.tightMargin,
  });

  /// How many minutes the session/match would overflow into prayer time
  int get overflowMinutes {
    final target = requestedDurationMinutes ?? estimatedMatchDuration;
    final diff = target - minutesUntilPrayer;
    return diff > 0 ? diff : 0;
  }

  /// Whether the match can safely fit before prayer
  bool get fitsBeforePrayer => riskLevel == RiskLevel.low;
}

class PrayerStatus {
  final String prayerName;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime date;

  const PrayerStatus({
    required this.prayerName,
    this.isCompleted = false,
    this.completedAt,
    required this.date,
  });

  PrayerStatus copyWith({
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return PrayerStatus(
      prayerName: prayerName,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      date: date,
    );
  }

  Map<String, dynamic> toJson() => {
        'prayerName': prayerName,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
        'date': date.toIso8601String(),
      };

  factory PrayerStatus.fromJson(Map<String, dynamic> json) => PrayerStatus(
        prayerName: json['prayerName'] as String,
        isCompleted: json['isCompleted'] as bool? ?? false,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
        date: DateTime.parse(json['date'] as String),
      );
}
