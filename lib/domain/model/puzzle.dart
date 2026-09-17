enum Difficulty {
  easy,
  medium,
  hard,
  expert;

  String get label {
    switch (this) {
      case Difficulty.easy:
        return '简单';
      case Difficulty.medium:
        return '普通';
      case Difficulty.hard:
        return '困难';
      case Difficulty.expert:
        return '专家';
    }
  }

  int get clues {
    switch (this) {
      case Difficulty.easy:
        return 45;
      case Difficulty.medium:
        return 35;
      case Difficulty.hard:
        return 28;
      case Difficulty.expert:
        return 22;
    }
  }

  int get errorCount {
    switch (this) {
      case Difficulty.easy:
        return 3;
      case Difficulty.medium:
        return 6;
      case Difficulty.hard:
        return 10;
      case Difficulty.expert:
        return 20;
    }
  }

  int get maxChecks {
    switch (this) {
      case Difficulty.easy:
        return 3;
      case Difficulty.medium:
        return 4;
      case Difficulty.hard:
        return 5;
      case Difficulty.expert:
        return 99;
    }
  }
}

enum GameMode {
  classic,
  portal,
  debug;

  String get label {
    switch (this) {
      case GameMode.classic:
        return '经典数独';
      case GameMode.portal:
        return '数独任意门';
      case GameMode.debug:
        return '纠错大师';
    }
  }
}

enum CellState {
  initial,
  userInput,
  note,
  error,
  hint,
}

class Puzzle {
  final String id;
  final List<List<int>> solution;
  final List<List<int>> initialBoard;
  final Difficulty difficulty;
  final GameMode mode;
  final int? pixelArtIndex;

  const Puzzle({
    required this.id,
    required this.solution,
    required this.initialBoard,
    required this.difficulty,
    required this.mode,
    this.pixelArtIndex,
  });

  Puzzle copyWith({
    String? id,
    List<List<int>>? solution,
    List<List<int>>? initialBoard,
    Difficulty? difficulty,
    GameMode? mode,
    int? pixelArtIndex,
  }) {
    return Puzzle(
      id: id ?? this.id,
      solution: solution ?? this.solution,
      initialBoard: initialBoard ?? this.initialBoard,
      difficulty: difficulty ?? this.difficulty,
      mode: mode ?? this.mode,
      pixelArtIndex: pixelArtIndex ?? this.pixelArtIndex,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'solution': solution.map((r) => r.join(',')).join('|'),
    'initialBoard': initialBoard.map((r) => r.join(',')).join('|'),
    'difficulty': difficulty.index,
    'mode': mode.index,
    'pixelArtIndex': pixelArtIndex,
  };

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    List<List<int>> parse(String raw) {
      return raw.split('|').map((r) =>
        r.split(',').map(int.parse).toList()
      ).toList();
    }
    return Puzzle(
      id: json['id'] as String,
      solution: parse(json['solution'] as String),
      initialBoard: parse(json['initialBoard'] as String),
      difficulty: Difficulty.values[json['difficulty'] as int? ?? 0],
      mode: GameMode.values[json['mode'] as int? ?? 0],
      pixelArtIndex: json['pixelArtIndex'] as int?,
    );
  }
}
