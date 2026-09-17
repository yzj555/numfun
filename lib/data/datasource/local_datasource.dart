import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/model/puzzle.dart';
import '../../domain/model/game_state.dart';
import 'game_datasource.dart';

class LocalDataSource implements GameDataSource {
  static const String _puzzlePrefix = 'puzzle_';
  static const String _progressPrefix = 'progress_';
  static const String _statsKey = 'user_stats';
  static const String _allProgressKey = 'all_progress_ids';

  @override
  Future<void> savePuzzle(Puzzle puzzle) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_puzzlePrefix${puzzle.id}', jsonEncode(puzzle.toJson()));
  }

  @override
  Future<Puzzle?> loadPuzzle(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('$_puzzlePrefix$id');
    if (data == null) return null;
    return Puzzle.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  @override
  Future<void> saveProgress(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    final boardData = state.board.map((row) =>
      row.map((c) => {
        'value': c.value,
        'state': c.state.index,
      }).toList()
    ).toList();

    final notesData = state.notes.map((row) =>
      row.map((s) => s.toList()).toList()
    ).toList();

    final progress = {
      'puzzleId': state.puzzle.id,
      'board': boardData,
      'elapsedSeconds': state.elapsedSeconds,
      'hintsUsed': state.hintsUsed,
      'score': state.score,
      'isCompleted': state.isCompleted,
      'notes': notesData,
    };

    await prefs.setString('$_progressPrefix${state.puzzle.id}', jsonEncode(progress));

    final ids = prefs.getStringList(_allProgressKey) ?? [];
    if (!ids.contains(state.puzzle.id)) {
      ids.add(state.puzzle.id);
      await prefs.setStringList(_allProgressKey, ids);
    }
  }

  @override
  Future<GameState?> loadProgress(String puzzleId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('$_progressPrefix$puzzleId');
    if (data == null) return null;

    final json = jsonDecode(data) as Map<String, dynamic>;
    final puzzle = await loadPuzzle(json['puzzleId'] as String);
    if (puzzle == null) return null;

    final boardList = (json['board'] as List).map((row) =>
      (row as List).map((c) {
        final m = c as Map<String, dynamic>;
        return CellData(
          row: 0, col: 0,
          value: m['value'] as int? ?? 0,
          state: CellState.values[m['state'] as int? ?? 0],
        );
      }).toList()
    ).toList();

    final notesList = (json['notes'] as List?)?.map((row) =>
      (row as List).map((s) =>
        Set<int>.from((s as List).cast<int>())
      ).toList()
    ).toList() ?? [];

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final old = boardList[r][c];
        boardList[r][c] = CellData(
          row: r,
          col: c,
          value: old.value,
          state: old.state,
        );
      }
    }

    return GameState(
      puzzle: puzzle,
      board: boardList,
      elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
      hintsUsed: json['hintsUsed'] as int? ?? 0,
      score: json['score'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      notes: notesList.isEmpty
          ? List.generate(9, (_) => List.generate(9, (_) => <int>{}))
          : notesList,
      undoStack: [],
      redoStack: [],
    );
  }

  @override
  Future<void> saveStats(Map<String, dynamic> stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, jsonEncode(stats));
  }

  @override
  Future<Map<String, dynamic>?> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_statsKey);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  @override
  Future<List<GameState>> getAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_allProgressKey) ?? [];
    final list = <GameState>[];
    for (final id in ids) {
      final state = await loadProgress(id);
      if (state != null) list.add(state);
    }
    return list;
  }
}
