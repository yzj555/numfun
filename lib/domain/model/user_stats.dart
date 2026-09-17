class PerDifficultyStats {
  final int gamesPlayed;
  final int gamesCompleted;
  final int totalScore;
  final int bestScore;
  final int bestTimeSec;
  final int totalTimeSec;

  const PerDifficultyStats({
    this.gamesPlayed = 0,
    this.gamesCompleted = 0,
    this.totalScore = 0,
    this.bestScore = 0,
    this.bestTimeSec = 0,
    this.totalTimeSec = 0,
  });

  PerDifficultyStats copyWith({
    int? gamesPlayed,
    int? gamesCompleted,
    int? totalScore,
    int? bestScore,
    int? bestTimeSec,
    int? totalTimeSec,
  }) {
    return PerDifficultyStats(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesCompleted: gamesCompleted ?? this.gamesCompleted,
      totalScore: totalScore ?? this.totalScore,
      bestScore: bestScore ?? this.bestScore,
      bestTimeSec: bestTimeSec ?? this.bestTimeSec,
      totalTimeSec: totalTimeSec ?? this.totalTimeSec,
    );
  }

  Map<String, dynamic> toJson() => {
    'gamesPlayed': gamesPlayed,
    'gamesCompleted': gamesCompleted,
    'totalScore': totalScore,
    'bestScore': bestScore,
    'bestTimeSec': bestTimeSec,
    'totalTimeSec': totalTimeSec,
  };

  factory PerDifficultyStats.fromJson(Map<String, dynamic> json) {
    return PerDifficultyStats(
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      gamesCompleted: json['gamesCompleted'] as int? ?? 0,
      totalScore: json['totalScore'] as int? ?? 0,
      bestScore: json['bestScore'] as int? ?? 0,
      bestTimeSec: json['bestTimeSec'] as int? ?? 0,
      totalTimeSec: json['totalTimeSec'] as int? ?? 0,
    );
  }
}

class UserStats {
  final int totalGames;
  final int completedGames;
  final int totalScore;
  final int totalHints;
  final int totalTimeSec;
  final Map<String, PerDifficultyStats> perDifficulty;
  final int totalPortalGames;
  final int completedPortalGames;
  final int totalDebugGames;
  final int completedDebugGames;
  final List<String> unlockedAchievements;

  const UserStats({
    this.totalGames = 0,
    this.completedGames = 0,
    this.totalScore = 0,
    this.totalHints = 0,
    this.totalTimeSec = 0,
    this.perDifficulty = const {},
    this.totalPortalGames = 0,
    this.completedPortalGames = 0,
    this.totalDebugGames = 0,
    this.completedDebugGames = 0,
    this.unlockedAchievements = const [],
  });

  UserStats copyWith({
    int? totalGames,
    int? completedGames,
    int? totalScore,
    int? totalHints,
    int? totalTimeSec,
    Map<String, PerDifficultyStats>? perDifficulty,
    int? totalPortalGames,
    int? completedPortalGames,
    int? totalDebugGames,
    int? completedDebugGames,
    List<String>? unlockedAchievements,
  }) {
    return UserStats(
      totalGames: totalGames ?? this.totalGames,
      completedGames: completedGames ?? this.completedGames,
      totalScore: totalScore ?? this.totalScore,
      totalHints: totalHints ?? this.totalHints,
      totalTimeSec: totalTimeSec ?? this.totalTimeSec,
      perDifficulty: perDifficulty ?? this.perDifficulty,
      totalPortalGames: totalPortalGames ?? this.totalPortalGames,
      completedPortalGames: completedPortalGames ?? this.completedPortalGames,
      totalDebugGames: totalDebugGames ?? this.totalDebugGames,
      completedDebugGames: completedDebugGames ?? this.completedDebugGames,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalGames': totalGames,
    'completedGames': completedGames,
    'totalScore': totalScore,
    'totalHints': totalHints,
    'totalTimeSec': totalTimeSec,
    'perDifficulty': perDifficulty.map((k, v) => MapEntry(k, v.toJson())),
    'totalColorGames': totalPortalGames,
    'completedColorGames': completedPortalGames,
    'totalDebugGames': totalDebugGames,
    'completedDebugGames': completedDebugGames,
    'unlockedAchievements': unlockedAchievements,
  };

  factory UserStats.fromJson(Map<String, dynamic> json) {
    final rawPerDiff = json['perDifficulty'] as Map<String, dynamic>? ?? {};
    return UserStats(
      totalGames: json['totalGames'] as int? ?? 0,
      completedGames: json['completedGames'] as int? ?? 0,
      totalScore: json['totalScore'] as int? ?? 0,
      totalHints: json['totalHints'] as int? ?? 0,
      totalTimeSec: json['totalTimeSec'] as int? ?? 0,
      perDifficulty: rawPerDiff.map((k, v) =>
        MapEntry(k, PerDifficultyStats.fromJson(v as Map<String, dynamic>))),
      totalPortalGames: json['totalColorGames'] as int? ?? 0,
      completedPortalGames: json['completedColorGames'] as int? ?? 0,
      totalDebugGames: json['totalDebugGames'] as int? ?? 0,
      completedDebugGames: json['completedDebugGames'] as int? ?? 0,
      unlockedAchievements: (json['unlockedAchievements'] as List?)?.cast<String>() ?? [],
    );
  }
}
