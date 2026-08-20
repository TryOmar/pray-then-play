class GameSessionRecord {
  final String id;
  final String gameId;
  final String gameName;
  final String activityId;
  final String activityName;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationMinutes;
  final bool wasInterruptedForPrayer;
  final String? notes;

  const GameSessionRecord({
    required this.id,
    required this.gameId,
    required this.gameName,
    required this.activityId,
    required this.activityName,
    required this.startedAt,
    this.endedAt,
    required this.durationMinutes,
    this.wasInterruptedForPrayer = false,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'gameId': gameId,
        'gameName': gameName,
        'activityId': activityId,
        'activityName': activityName,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt?.toIso8601String(),
        'durationMinutes': durationMinutes,
        'wasInterruptedForPrayer': wasInterruptedForPrayer,
        'notes': notes,
      };

  factory GameSessionRecord.fromJson(Map<String, dynamic> json) =>
      GameSessionRecord(
        id: json['id'] as String,
        gameId: json['gameId'] as String,
        gameName: json['gameName'] as String? ?? 'Game',
        activityId: json['activityId'] as String,
        activityName: json['activityName'] as String? ?? 'Session',
        startedAt: DateTime.parse(json['startedAt'] as String),
        endedAt: json['endedAt'] != null
            ? DateTime.parse(json['endedAt'] as String)
            : null,
        durationMinutes: json['durationMinutes'] as int? ?? 0,
        wasInterruptedForPrayer:
            json['wasInterruptedForPrayer'] as bool? ?? false,
        notes: json['notes'] as String?,
      );
}

class ActivitySessionStats {
  final int sessionCount;
  final int averageDurationMinutes;
  final int longestDurationMinutes;
  final int shortestDurationMinutes;

  const ActivitySessionStats({
    required this.sessionCount,
    required this.averageDurationMinutes,
    required this.longestDurationMinutes,
    required this.shortestDurationMinutes,
  });

  static const ActivitySessionStats empty = ActivitySessionStats(
    sessionCount: 0,
    averageDurationMinutes: 0,
    longestDurationMinutes: 0,
    shortestDurationMinutes: 0,
  );
}
