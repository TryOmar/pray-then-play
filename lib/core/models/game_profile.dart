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

class GameProfile {
  final String id;
  final String name;
  final GameCategory category;
  final String iconName;
  final int color;
  final List<GameMode> modes;
  final bool isCustom;
  final bool isSelected;

  const GameProfile({
    required this.id,
    required this.name,
    this.category = GameCategory.competitive,
    required this.iconName,
    required this.color,
    required this.modes,
    this.isCustom = false,
    this.isSelected = true,
  });

  List<GameMode> get enabledModes => modes.where((m) => m.isEnabled).toList();

  GameProfile copyWith({
    String? id,
    String? name,
    GameCategory? category,
    String? iconName,
    int? color,
    List<GameMode>? modes,
    bool? isCustom,
    bool? isSelected,
  }) {
    return GameProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      modes: modes ?? this.modes,
      isCustom: isCustom ?? this.isCustom,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.index,
        'iconName': iconName,
        'color': color,
        'modes': modes.map((m) => m.toJson()).toList(),
        'isCustom': isCustom,
        'isSelected': isSelected,
      };

  factory GameProfile.fromJson(Map<String, dynamic> json) => GameProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        category: GameCategory.values[json['category'] as int? ?? 0],
        iconName: json['iconName'] as String,
        color: json['color'] as int,
        modes: (json['modes'] as List)
            .map((m) => GameMode.fromJson(m as Map<String, dynamic>))
            .toList(),
        isCustom: json['isCustom'] as bool? ?? false,
        isSelected: json['isSelected'] as bool? ?? true,
      );
}

class GameMode {
  final String name;
  final int estimatedMinutes;
  final int minMinutes;
  final int maxMinutes;
  final GameCommitmentType commitmentType;
  final bool canLeaveSafely;
  final bool isCompetitive;
  final bool isEnabled;

  const GameMode({
    required this.name,
    required this.estimatedMinutes,
    int? minMinutes,
    int? maxMinutes,
    this.commitmentType = GameCommitmentType.commitment,
    this.canLeaveSafely = false,
    this.isCompetitive = true,
    this.isEnabled = true,
  })  : minMinutes = minMinutes ?? (estimatedMinutes > 10 ? estimatedMinutes - 5 : estimatedMinutes),
        maxMinutes = maxMinutes ?? (estimatedMinutes > 10 ? estimatedMinutes + 10 : estimatedMinutes + 3);

  GameMode copyWith({
    String? name,
    int? estimatedMinutes,
    int? minMinutes,
    int? maxMinutes,
    GameCommitmentType? commitmentType,
    bool? canLeaveSafely,
    bool? isCompetitive,
    bool? isEnabled,
  }) {
    return GameMode(
      name: name ?? this.name,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      minMinutes: minMinutes ?? this.minMinutes,
      maxMinutes: maxMinutes ?? this.maxMinutes,
      commitmentType: commitmentType ?? this.commitmentType,
      canLeaveSafely: canLeaveSafely ?? this.canLeaveSafely,
      isCompetitive: isCompetitive ?? this.isCompetitive,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'estimatedMinutes': estimatedMinutes,
        'minMinutes': minMinutes,
        'maxMinutes': maxMinutes,
        'commitmentType': commitmentType.index,
        'canLeaveSafely': canLeaveSafely,
        'isCompetitive': isCompetitive,
        'isEnabled': isEnabled,
      };

  factory GameMode.fromJson(Map<String, dynamic> json) => GameMode(
        name: json['name'] as String,
        estimatedMinutes: json['estimatedMinutes'] as int,
        minMinutes: json['minMinutes'] as int?,
        maxMinutes: json['maxMinutes'] as int?,
        commitmentType: GameCommitmentType.values[json['commitmentType'] as int? ?? 0],
        canLeaveSafely: json['canLeaveSafely'] as bool? ?? false,
        isCompetitive: json['isCompetitive'] as bool? ?? true,
        isEnabled: json['isEnabled'] as bool? ?? true,
      );
}
