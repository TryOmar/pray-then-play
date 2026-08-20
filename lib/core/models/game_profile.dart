enum GameCategory {
  competitive('Competitive / Ranked', 'Match-based, penalty for leaving'),
  casual('Casual / Flexible', 'Can pause, save, or leave safely');

  const GameCategory(this.label, this.description);
  final String label;
  final String description;
}

enum GameCommitmentType {
  commitment('Match Locked', 'Full match commitment, cannot safely leave'),
  shortSession('Short Session', 'Quick match, low risk if interrupted'),
  flexible('Flexible', 'Can pause or quit anytime without penalty');

  const GameCommitmentType(this.label, this.description);
  final String label;
  final String description;
}

/// Represents a distinct mode, subgame, or activity within a Game
/// (e.g. Minecraft Survival vs Hardcore vs Skyblock server vs Creative; Valorant Ranked vs Swiftplay)
class GameActivity {
  final String id;
  final String gameId;
  final String name;
  final int typicalDuration; // Typical duration in minutes
  final int minMinutes;
  final int maxMinutes;
  final bool canPause; // Whether user can pause or exit cleanly without penalty
  final bool requiresCompletion; // Whether the match/activity requires full commitment
  final bool isCompetitive;
  final GameCommitmentType commitmentType;
  final int? safetyBuffer; // Optional per-activity safety buffer override in minutes
  final bool isEnabled;
  final bool isCustom; // Created or customized by user
  final String? notes;

  const GameActivity({
    String? id,
    this.gameId = '',
    required this.name,
    int? typicalDuration,
    int? estimatedMinutes,
    int? minMinutes,
    int? maxMinutes,
    bool? canPause,
    bool? canLeaveSafely,
    this.requiresCompletion = true,
    this.isCompetitive = true,
    this.commitmentType = GameCommitmentType.commitment,
    this.safetyBuffer,
    this.isEnabled = true,
    this.isCustom = false,
    this.notes,
  })  : id = id ?? name,
        typicalDuration = typicalDuration ?? estimatedMinutes ?? 30,
        minMinutes = minMinutes ??
            ((typicalDuration ?? estimatedMinutes ?? 30) > 10
                ? (typicalDuration ?? estimatedMinutes ?? 30) - 5
                : (typicalDuration ?? estimatedMinutes ?? 30)),
        maxMinutes = maxMinutes ??
            ((typicalDuration ?? estimatedMinutes ?? 30) > 10
                ? (typicalDuration ?? estimatedMinutes ?? 30) + 10
                : (typicalDuration ?? estimatedMinutes ?? 30) + 3),
        canPause = canPause ?? canLeaveSafely ?? false;

  // Backwards compatibility getters
  int get estimatedMinutes => typicalDuration;
  bool get canLeaveSafely => canPause;

  GameActivity copyWith({
    String? id,
    String? gameId,
    String? name,
    int? typicalDuration,
    int? minMinutes,
    int? maxMinutes,
    bool? canPause,
    bool? requiresCompletion,
    bool? isCompetitive,
    GameCommitmentType? commitmentType,
    int? safetyBuffer,
    bool? isEnabled,
    bool? isCustom,
    String? notes,
  }) {
    return GameActivity(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      name: name ?? this.name,
      typicalDuration: typicalDuration ?? this.typicalDuration,
      minMinutes: minMinutes ?? this.minMinutes,
      maxMinutes: maxMinutes ?? this.maxMinutes,
      canPause: canPause ?? this.canPause,
      requiresCompletion: requiresCompletion ?? this.requiresCompletion,
      isCompetitive: isCompetitive ?? this.isCompetitive,
      commitmentType: commitmentType ?? this.commitmentType,
      safetyBuffer: safetyBuffer ?? this.safetyBuffer,
      isEnabled: isEnabled ?? this.isEnabled,
      isCustom: isCustom ?? this.isCustom,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'gameId': gameId,
        'name': name,
        'typicalDuration': typicalDuration,
        'estimatedMinutes': typicalDuration, // Backwards compat
        'minMinutes': minMinutes,
        'maxMinutes': maxMinutes,
        'canPause': canPause,
        'canLeaveSafely': canPause, // Backwards compat
        'requiresCompletion': requiresCompletion,
        'isCompetitive': isCompetitive,
        'commitmentType': commitmentType.index,
        'safetyBuffer': safetyBuffer,
        'isEnabled': isEnabled,
        'isCustom': isCustom,
        'notes': notes,
      };

  factory GameActivity.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? 'Activity';
    final dur = json['typicalDuration'] as int? ??
        json['estimatedMinutes'] as int? ??
        30;
    final pause = json['canPause'] as bool? ??
        json['canLeaveSafely'] as bool? ??
        false;

    return GameActivity(
      id: json['id'] as String? ?? name,
      gameId: json['gameId'] as String? ?? '',
      name: name,
      typicalDuration: dur,
      minMinutes: json['minMinutes'] as int?,
      maxMinutes: json['maxMinutes'] as int?,
      canPause: pause,
      requiresCompletion: json['requiresCompletion'] as bool? ?? !pause,
      isCompetitive: json['isCompetitive'] as bool? ?? true,
      commitmentType: GameCommitmentType
          .values[json['commitmentType'] as int? ?? 0],
      safetyBuffer: json['safetyBuffer'] as int?,
      isEnabled: json['isEnabled'] as bool? ?? true,
      isCustom: json['isCustom'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }
}

// Backwards compatibility alias
typedef GameMode = GameActivity;

class GameProfile {
  final String id;
  final String name;
  final GameCategory category;
  final String iconName;
  final int color;
  final List<GameActivity> activities;
  final bool isCustom;
  final bool isSelected;
  final String? notes;

  const GameProfile({
    required this.id,
    required this.name,
    this.category = GameCategory.competitive,
    required this.iconName,
    required this.color,
    required this.activities,
    this.isCustom = false,
    this.isSelected = true,
    this.notes,
  });

  // Backwards compatibility getters
  List<GameActivity> get modes => activities;
  List<GameActivity> get enabledActivities =>
      activities.where((a) => a.isEnabled).toList();
  List<GameActivity> get enabledModes => enabledActivities;

  GameProfile copyWith({
    String? id,
    String? name,
    GameCategory? category,
    String? iconName,
    int? color,
    List<GameActivity>? activities,
    List<GameActivity>? modes, // Backwards compat
    bool? isCustom,
    bool? isSelected,
    String? notes,
  }) {
    return GameProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      activities: activities ?? modes ?? this.activities,
      isCustom: isCustom ?? this.isCustom,
      isSelected: isSelected ?? this.isSelected,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.index,
        'iconName': iconName,
        'color': color,
        'activities': activities.map((a) => a.toJson()).toList(),
        'modes': activities.map((a) => a.toJson()).toList(), // Backwards compat
        'isCustom': isCustom,
        'isSelected': isSelected,
        'notes': notes,
      };

  factory GameProfile.fromJson(Map<String, dynamic> json) {
    final rawList = (json['activities'] ?? json['modes']) as List? ?? [];
    return GameProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      category: GameCategory.values[json['category'] as int? ?? 0],
      iconName: json['iconName'] as String,
      color: json['color'] as int,
      activities: rawList
          .map((m) => GameActivity.fromJson(m as Map<String, dynamic>))
          .toList(),
      isCustom: json['isCustom'] as bool? ?? false,
      isSelected: json['isSelected'] as bool? ?? true,
      notes: json['notes'] as String?,
    );
  }
}
