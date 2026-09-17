import 'puzzle.dart';

class CellData {
  final int row;
  final int col;
  final int value;
  final CellState state;

  const CellData({
    required this.row,
    required this.col,
    required this.value,
    required this.state,
  });

  CellData copyWith({int? value, CellState? state}) {
    return CellData(
      row: row,
      col: col,
      value: value ?? this.value,
      state: state ?? this.state,
    );
  }
}

class GameState {
  final Puzzle puzzle;
  final List<List<CellData>> board;
  final int elapsedSeconds;
  final int hintsUsed;
  final int maxHints;
  final bool isCompleted;
  final bool checkErrors;
  final int selectedRow;
  final int selectedCol;
  final bool isNoteMode;
  final List<List<Set<int>>> notes;
  final int score;
  final int streak;
  final List<List<List<CellData>>> undoStack;
  final List<List<List<CellData>>> redoStack;
  final int remainingChecks;

  const GameState({
    required this.puzzle,
    required this.board,
    this.elapsedSeconds = 0,
    this.hintsUsed = 0,
    this.maxHints = 99,
    this.isCompleted = false,
    this.checkErrors = true,
    this.selectedRow = -1,
    this.selectedCol = -1,
    this.isNoteMode = false,
    required this.notes,
    this.score = 0,
    this.streak = 0,
    required this.undoStack,
    required this.redoStack,
    this.remainingChecks = 0,
  });

  bool get isComplete => isCompleted;

  int get errors {
    int count = 0;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c].state == CellState.error) count++;
      }
    }
    return count;
  }

  int get filledCount {
    int count = 0;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c].value != 0) count++;
      }
    }
    return count;
  }

  double get progress => filledCount / 81;

  static GameState fromPuzzle(Puzzle puzzle) {
    final board = <List<CellData>>[];
    final notes = <List<Set<int>>>[];
    for (int r = 0; r < 9; r++) {
      final row = <CellData>[];
      final noteRow = <Set<int>>[];
      for (int c = 0; c < 9; c++) {
        final val = puzzle.initialBoard[r][c];
        final state = puzzle.mode == GameMode.debug
            ? CellState.userInput
            : (val != 0 ? CellState.initial : CellState.userInput);
        row.add(CellData(
          row: r,
          col: c,
          value: val,
          state: state,
        ));
        noteRow.add(<int>{});
      }
      board.add(row);
      notes.add(noteRow);
    }
    return GameState(
      puzzle: puzzle,
      board: board,
      notes: notes,
      undoStack: [],
      redoStack: [],
      remainingChecks: puzzle.mode == GameMode.debug ? puzzle.difficulty.maxChecks : 0,
    );
  }

  GameState copyWith({
    Puzzle? puzzle,
    List<List<CellData>>? board,
    int? elapsedSeconds,
    int? hintsUsed,
    int? maxHints,
    bool? isCompleted,
    bool? checkErrors,
    int? selectedRow,
    int? selectedCol,
    bool? isNoteMode,
    List<List<Set<int>>>? notes,
    int? score,
    int? streak,
    List<List<List<CellData>>>? undoStack,
    List<List<List<CellData>>>? redoStack,
    int? remainingChecks,
  }) {
    return GameState(
      puzzle: puzzle ?? this.puzzle,
      board: board ?? this.board,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      maxHints: maxHints ?? this.maxHints,
      isCompleted: isCompleted ?? this.isCompleted,
      checkErrors: checkErrors ?? this.checkErrors,
      selectedRow: selectedRow ?? this.selectedRow,
      selectedCol: selectedCol ?? this.selectedCol,
      isNoteMode: isNoteMode ?? this.isNoteMode,
      notes: notes ?? this.notes,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      remainingChecks: remainingChecks ?? this.remainingChecks,
    );
  }

  static List<List<CellData>> cloneBoard(List<List<CellData>> src) {
    return src.map((row) => row.map((c) => c.copyWith()).toList()).toList();
  }
}
