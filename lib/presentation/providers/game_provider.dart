import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/model/puzzle.dart';
import '../../domain/model/game_state.dart';
import '../../domain/model/user_stats.dart';
import '../../domain/model/achievement.dart';
import '../../domain/generator/sudoku_generator.dart';
import '../../domain/solver/sudoku_solver.dart';
import '../../core/constants/palette_data.dart';

class GameProvider extends ChangeNotifier {
  final SudokuGenerator _generator = SudokuGenerator();
  final SudokuSolver _solver = SudokuSolver();
  GameState _state;
  bool _isLoading = false;
  int _currentLevel = 0;
  bool _hasMadeMove = false;
  Map<Difficulty, int> _levelProgress = {};
  UserStats _stats = const UserStats();
  Set<String> _conflictFlashCells = {};
  bool _conflictVisible = false;
  int? _conflictSourceRow;
  int? _conflictSourceCol;
  Timer? _conflictTimer;
  int _numPadLayout = 0;

  static const _levelKeyPrefix = 'level_progress_';
  static const _statsKey = 'user_stats_v2';
  static const _numPadLayoutKey = 'numPadLayout';

  int get currentLevel => _currentLevel;
  int get numPadLayout => _numPadLayout;
  Map<Difficulty, int> get levelProgress => Map.unmodifiable(_levelProgress);
  UserStats get stats => _stats;
  bool isConflictSource(int r, int c) => _conflictSourceRow == r && _conflictSourceCol == c;
  bool isFlashCell(int r, int c) => _conflictVisible && _conflictFlashCells.contains('${r}_$c');
  List<Achievement> get unlockedAchievements {
    return _stats.unlockedAchievements
      .map((id) => Achievement.findById(id))
      .whereType<Achievement>()
      .toList();
  }

  void setLevel(int level) {
    _currentLevel = level;
    notifyListeners();
  }

  Future<void> initLevelProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <Difficulty, int>{};
    for (final d in Difficulty.values) {
      map[d] = prefs.getInt('$_levelKeyPrefix${d.name}') ?? 0;
    }
    _levelProgress = map;
    notifyListeners();
  }

  Future<void> saveLevelProgress(Difficulty diff, int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_levelKeyPrefix${diff.name}', level);
  }

  Future<void> setNumPadLayout(int layout) async {
    _numPadLayout = layout.clamp(0, 2);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_numPadLayoutKey, _numPadLayout);
    notifyListeners();
  }

  Future<void> initNumPadLayout() async {
    final prefs = await SharedPreferences.getInstance();
    _numPadLayout = prefs.getInt(_numPadLayoutKey) ?? 0;
    notifyListeners();
  }

  Future<void> initStats() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_statsKey);
    if (data != null) {
      _stats = UserStats.fromJson(jsonDecode(data) as Map<String, dynamic>);
    }
    notifyListeners();
  }

  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, jsonEncode(_stats.toJson()));
  }

  GameProvider() : _state = GameState(
    puzzle: Puzzle(
      id: 'default',
      solution: List.generate(9, (_) => List.filled(9, 0)),
      initialBoard: List.generate(9, (_) => List.filled(9, 0)),
      difficulty: Difficulty.easy,
      mode: GameMode.classic,
    ),
    board: [],
    notes: [],
    undoStack: [],
    redoStack: [],
  );

  GameState get state => _state;
  bool get isLoading => _isLoading;

  void newGame(Difficulty difficulty, GameMode mode, {int? pixelArtIndex, int? level}) {
    _currentLevel = 0;
    _hasMadeMove = false;
    _isLoading = true;
    notifyListeners();

    List<List<int>> solution;
    List<List<int>> puzzle;

    if (level != null) {
      final seed = difficulty.index * 10000 + level - 1;
      final gen = SudokuGenerator(seed: seed);
      solution = gen.generateSolution();
      puzzle = gen.generatePuzzle(difficulty, solution: solution);
    } else {
      solution = _generator.generateSolution();
      puzzle = _generator.generatePuzzle(difficulty, solution: solution);
    }

    if (mode == GameMode.debug) {
      puzzle = _injectErrors(solution, difficulty);
    }

    final effectivePixelArtIndex = pixelArtIndex ?? (mode == GameMode.portal ? Random().nextInt(PaletteData.palettes.length) : null);
    final id = level != null
        ? '${mode.name}_${difficulty.name}_level$level'
        : '${mode.name}_${difficulty.name}_${DateTime.now().millisecondsSinceEpoch}';
    final p = Puzzle(
      id: id,
      solution: solution,
      initialBoard: puzzle,
      difficulty: difficulty,
      mode: mode,
      pixelArtIndex: effectivePixelArtIndex,
    );

    _state = GameState.fromPuzzle(p);
    _isLoading = false;
    notifyListeners();
  }

  void selectCell(int row, int col) {
    _state = _state.copyWith(selectedRow: row, selectedCol: col);
    notifyListeners();
  }

  void inputNumber(int number) {
    if (_state.isCompleted) return;
    final r = _state.selectedRow;
    final c = _state.selectedCol;
    if (r < 0 || c < 0) return;
    if (_state.board[r][c].state == CellState.initial) return;

    _hasMadeMove = true;
    _saveToUndo();

    if (_state.isNoteMode) {
      final newNotes = List<List<Set<int>>>.from(_state.notes);
      newNotes[r] = List<Set<int>>.from(_state.notes[r]);
      if (newNotes[r][c].contains(number)) {
        newNotes[r][c].remove(number);
      } else {
        newNotes[r][c].add(number);
      }
      _state = _state.copyWith(notes: newNotes, redoStack: []);
      notifyListeners();
      return;
    }

    final newBoard = List<List<CellData>>.from(_state.board);
    newBoard[r] = List<CellData>.from(_state.board[r]);

    newBoard[r][c] = CellData(
      row: r,
      col: c,
      value: number,
      state: CellState.userInput,
    );

    final newNotes = List<List<Set<int>>>.from(_state.notes);
    newNotes[r] = List<Set<int>>.from(_state.notes[r]);
    newNotes[r][c] = <int>{};

    _state = _state.copyWith(
      board: newBoard,
      notes: newNotes,
      redoStack: [],
    );

    _updateConflicts();

    if (_isBoardFullAndCorrect()) {
      _complete();
      return;
    }

    notifyListeners();
  }

  List<List<int>> _injectErrors(List<List<int>> solution, Difficulty difficulty) {
    final grid = solution.map((row) => List<int>.from(row)).toList();
    final n = difficulty.errorCount;
    final rng = Random();
    final cells = List.generate(81, (i) => i)..shuffle(rng);
    for (int i = 0; i < n; i++) {
      final pos = cells[i];
      final r = pos ~/ 9;
      final c = pos % 9;
      final correct = grid[r][c];
      int wrong;
      do {
        wrong = rng.nextInt(9) + 1;
      } while (wrong == correct);
      grid[r][c] = wrong;
    }
    return grid;
  }

  bool _isBoardFullAndCorrect() {
    final solution = _state.puzzle.solution;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (_state.board[r][c].value != solution[r][c]) return false;
      }
    }
    return true;
  }

  void eraseCell() {
    if (_state.isCompleted) return;
    final r = _state.selectedRow;
    final c = _state.selectedCol;
    if (r < 0 || c < 0) return;
    if (_state.board[r][c].state == CellState.initial) return;

    _hasMadeMove = true;
    _saveToUndo();

    final newBoard = List<List<CellData>>.from(_state.board);
    newBoard[r] = List<CellData>.from(_state.board[r]);
    newBoard[r][c] = CellData(row: r, col: c, value: 0, state: CellState.userInput);

    _state = _state.copyWith(board: newBoard, redoStack: []);
    _updateConflicts();
    notifyListeners();
  }

  void toggleNoteMode() {
    _state = _state.copyWith(isNoteMode: !_state.isNoteMode);
    notifyListeners();
  }

  void useHint() {
    if (_state.isCompleted) return;
    if (_state.hintsUsed >= _state.maxHints) return;

    final current = _state.board.map((row) =>
      row.map((c) => c.value).toList()
    ).toList();

    final hint = _solver.findHint(
      _state.puzzle.initialBoard.map((r) => List<int>.from(r)).toList(),
      current,
    );

    if (hint == null) return;

    _saveToUndo();

    final newBoard = List<List<CellData>>.from(_state.board);
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (newBoard[r][c].value == 0 &&
            _state.puzzle.solution[r][c] == hint) {
          newBoard[r] = List<CellData>.from(_state.board[r]);
          newBoard[r][c] = CellData(
            row: r,
            col: c,
            value: hint,
            state: CellState.hint,
          );
          _state = _state.copyWith(
            board: newBoard,
            hintsUsed: _state.hintsUsed + 1,
            score: (_state.score - 15).clamp(0, _state.score),
            redoStack: [],
          );

          if (_isBoardFullAndCorrect()) {
            _complete();
            return;
          }
          notifyListeners();
          return;
        }
      }
    }
  }

  void undo() {
    if (_state.undoStack.isEmpty) return;
    final last = _state.undoStack.last;
    _state = _state.copyWith(
      board: last,
      undoStack: _state.undoStack.sublist(0, _state.undoStack.length - 1),
      redoStack: [..._state.redoStack, _state.board],
    );
    _updateConflicts();
    notifyListeners();
  }

  void redo() {
    if (_state.redoStack.isEmpty) return;
    final next = _state.redoStack.last;
    _state = _state.copyWith(
      board: next,
      redoStack: _state.redoStack.sublist(0, _state.redoStack.length - 1),
      undoStack: [..._state.undoStack, _state.board],
    );
    _updateConflicts();
    notifyListeners();
  }

  void tick() {
    if (!_state.isCompleted) {
      _state = _state.copyWith(elapsedSeconds: _state.elapsedSeconds + 1);
      notifyListeners();
    }
  }

  List<int> getCandidates(int row, int col) {
    final grid = _state.board.map((r) =>
      r.map((c) => c.value).toList()
    ).toList();
    return _solver.getCandidates(grid, row, col);
  }

  void checkBoard() {
    if (_state.isCompleted) return;

    final isDebug = _state.puzzle.mode == GameMode.debug;

    if (isDebug && _state.remainingChecks <= 0) return;

    final newBoard = GameState.cloneBoard(_state.board);
    bool hasError = false;
    bool allFilled = true;

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final cell = newBoard[r][c];
        if (!isDebug && cell.state == CellState.initial) continue;
        if (cell.value == 0) {
          allFilled = false;
          continue;
        }
        if (cell.value != _state.puzzle.solution[r][c]) {
          newBoard[r][c] = cell.copyWith(state: CellState.error);
          hasError = true;
        } else {
          newBoard[r][c] = cell.copyWith(state: CellState.userInput);
        }
      }
    }

    int? remaining;
    if (isDebug) {
      remaining = _state.remainingChecks - 1;
    }

    _state = _state.copyWith(board: newBoard, remainingChecks: remaining);

    if (!hasError && allFilled) {
      _complete();
    } else {
      notifyListeners();
    }
  }

  void _complete() {
    final timeBonus = (300 - _state.elapsedSeconds).clamp(0, 300);
    final hintPenalty = _state.hintsUsed * 50;
    final score = (500 - hintPenalty + timeBonus).clamp(100, 800);
    _state = _state.copyWith(isCompleted: true, score: score);

    if (_hasMadeMove) {
      _recordGamePlayed(_state.puzzle.difficulty, _state.puzzle.mode);
      _recordGameComplete(score);
      _checkAchievements();
    }

    if (_currentLevel > 0) {
      final current = _levelProgress[_state.puzzle.difficulty] ?? 0;
      final newLevel = _currentLevel > current ? _currentLevel : current;
      if (newLevel > current) {
        _levelProgress = Map.from(_levelProgress)..[_state.puzzle.difficulty] = newLevel;
        saveLevelProgress(_state.puzzle.difficulty, newLevel);
      }
    }
    notifyListeners();
  }

  String get _gameTypeKey {
    final name = _state.puzzle.mode == GameMode.portal ? 'color' : _state.puzzle.mode.name;
    return '${name}_${_state.puzzle.difficulty.name}';
  }

  Future<Map<String, dynamic>?> findSavedGame(String modeName, String diffName) async {
    final keyName = modeName == 'portal' ? 'color' : modeName;
    final prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('savedGame_${keyName}_$diffName');
    if (data == null && modeName == 'portal') {
      data = prefs.getString('savedGame_portal_$diffName');
    }
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  Future<void> saveCurrentGame() async {
    if (_state.isCompleted) return;
    final prefs = await SharedPreferences.getInstance();
    final boardData = _state.board.map((row) =>
      row.map((c) => {'v': c.value, 's': c.state.index}).toList()
    ).toList();
    final notesData = _state.notes.map((row) =>
      row.map((s) => s.toList()).toList()
    ).toList();
    final data = {
      'puzzle': _state.puzzle.toJson(),
      'board': boardData,
      'notes': notesData,
      'elapsed': _state.elapsedSeconds,
      'hintsUsed': _state.hintsUsed,
      'score': _state.score,
      'level': _currentLevel,
      'remainingChecks': _state.remainingChecks,
    };
    await prefs.setString('savedGame_$_gameTypeKey', jsonEncode(data));
  }

  Future<void> deleteSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('savedGame_$_gameTypeKey');
    if (_state.puzzle.mode == GameMode.portal) {
      await prefs.remove('savedGame_portal_${_state.puzzle.difficulty.name}');
    }
  }

  void restoreGame(Map<String, dynamic> data) {
    final puzzle = Puzzle.fromJson(data['puzzle'] as Map<String, dynamic>);
    final boardList = (data['board'] as List).map((row) =>
      (row as List).map((c) {
        final m = c as Map<String, dynamic>;
        return CellData(row: 0, col: 0, value: m['v'] as int? ?? 0, state: CellState.values[m['s'] as int? ?? 0]);
      }).toList()
    ).toList();
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final old = boardList[r][c];
        boardList[r][c] = CellData(row: r, col: c, value: old.value, state: old.state);
      }
    }
    final notesList = (data['notes'] as List?)?.map((row) =>
      (row as List).map((s) => Set<int>.from((s as List).cast<int>())).toList()
    ).toList() ?? [];
    _state = GameState(
      puzzle: puzzle,
      board: boardList,
      elapsedSeconds: data['elapsed'] as int? ?? 0,
      hintsUsed: data['hintsUsed'] as int? ?? 0,
      score: data['score'] as int? ?? 0,
      notes: notesList.isEmpty
          ? List.generate(9, (_) => List.generate(9, (_) => <int>{}))
          : notesList,
      undoStack: [],
      redoStack: [],
      remainingChecks: data['remainingChecks'] as int? ?? 0,
    );
    _currentLevel = data['level'] as int? ?? 0;
    notifyListeners();
  }

  void _updateConflicts() {
    if (_state.puzzle.mode == GameMode.debug) return;
    _conflictTimer?.cancel();
    _conflictTimer = null;
    _conflictFlashCells = {};
    _conflictVisible = false;
    _conflictSourceRow = null;
    _conflictSourceCol = null;

    final sr = _state.selectedRow;
    final sc = _state.selectedCol;
    final board = _state.board;
    final conflictSet = <String>{};

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c].value == 0) continue;

        for (int i = 0; i < 9; i++) {
          if (i != c && board[r][i].value == board[r][c].value) {
            conflictSet.add('${r}_$c');
            conflictSet.add('${r}_$i');
          }
          if (i != r && board[i][c].value == board[r][c].value) {
            conflictSet.add('${r}_$c');
            conflictSet.add('${i}_$c');
          }
        }

        final br = (r ~/ 3) * 3;
        final bc = (c ~/ 3) * 3;
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            final rr = br + i, cc = bc + j;
            if ((rr != r || cc != c) && board[rr][cc].value == board[r][c].value) {
              conflictSet.add('${r}_$c');
              conflictSet.add('${rr}_$cc');
            }
          }
        }
      }
    }

    if (conflictSet.isEmpty) return;

    final sourceKey = '${sr}_$sc';
    if (conflictSet.contains(sourceKey)) {
      _conflictSourceRow = sr;
      _conflictSourceCol = sc;
      conflictSet.remove(sourceKey);
    }

    if (conflictSet.isNotEmpty) {
      _conflictFlashCells = conflictSet;
      _conflictVisible = true;

      int tick = 0;
      _conflictTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
        tick++;
        _conflictVisible = tick % 2 == 0;
        if (tick >= 5) {
          timer.cancel();
          _conflictTimer = null;
          _conflictFlashCells = {};
          _conflictVisible = false;
        }
        notifyListeners();
      });
    }
  }

  void _saveToUndo() {
    final boardCopy = GameState.cloneBoard(_state.board);
    _state = _state.copyWith(
      undoStack: [..._state.undoStack, boardCopy],
    );
    if (_state.undoStack.length > 50) {
      _state = _state.copyWith(
        undoStack: _state.undoStack.sublist(1),
      );
    }
  }

  void _recordGamePlayed(Difficulty difficulty, GameMode mode) {
    final diffKey = difficulty.name;
    final prev = _stats.perDifficulty[diffKey] ?? const PerDifficultyStats();
    _stats = _stats.copyWith(
      totalGames: _stats.totalGames + 1,
      totalPortalGames: mode == GameMode.portal ? _stats.totalPortalGames + 1 : _stats.totalPortalGames,
      totalDebugGames: mode == GameMode.debug ? _stats.totalDebugGames + 1 : _stats.totalDebugGames,
      perDifficulty: Map.from(_stats.perDifficulty)..[diffKey] = prev.copyWith(gamesPlayed: prev.gamesPlayed + 1),
    );
    _saveStats();
  }

  void _recordGameComplete(int score) {
    final diffKey = _state.puzzle.difficulty.name;
    final isPortal = _state.puzzle.mode == GameMode.portal;
    final isDebug = _state.puzzle.mode == GameMode.debug;
    final prev = _stats.perDifficulty[diffKey] ?? const PerDifficultyStats();

    int totalTime = _stats.totalTimeSec + _state.elapsedSeconds;
    int totalHints = _stats.totalHints + _state.hintsUsed;

    _stats = _stats.copyWith(
      completedGames: _stats.completedGames + 1,
      totalScore: _stats.totalScore + score,
      totalHints: totalHints,
      totalTimeSec: totalTime,
      completedPortalGames: isPortal ? _stats.completedPortalGames + 1 : _stats.completedPortalGames,
      completedDebugGames: isDebug ? _stats.completedDebugGames + 1 : _stats.completedDebugGames,
      perDifficulty: Map.from(_stats.perDifficulty)..[diffKey] = prev.copyWith(
        gamesCompleted: prev.gamesCompleted + 1,
        totalScore: prev.totalScore + score,
        bestScore: score > prev.bestScore ? score : prev.bestScore,
        bestTimeSec: prev.bestTimeSec == 0 || _state.elapsedSeconds < prev.bestTimeSec
            ? _state.elapsedSeconds : prev.bestTimeSec,
        totalTimeSec: prev.totalTimeSec + _state.elapsedSeconds,
      ),
    );
    _saveStats();
  }

  void _checkAchievements() {
    final unlocked = List<String>.from(_stats.unlockedAchievements);
    bool changed = false;

    void unlock(String id) {
      if (!unlocked.contains(id)) {
        unlocked.add(id);
        changed = true;
      }
    }

    if (_stats.completedGames >= 1) unlock('first_blood');
    if (_state.elapsedSeconds <= 120) unlock('speed_demon');
    if (_state.hintsUsed == 0) unlock('no_hints');
    if (_state.puzzle.mode == GameMode.portal) unlock('portal_master');
    if (_state.puzzle.mode == GameMode.debug) unlock('debug_master');
    if (_state.score >= 800) unlock('max_score');
    if (_stats.totalHints >= 100) unlock('heavy_hints');
    if (_stats.totalTimeSec >= 3600) unlock('one_hour');
    if (_stats.totalScore >= 5000) unlock('score_5000');

    final allDiffComplete = Difficulty.values.every((d) =>
      (_levelProgress[d] ?? 0) >= 1000);
    if (allDiffComplete) unlock('all_levels');

    if ((_levelProgress[Difficulty.easy] ?? 0) >= 1000) unlock('easy_complete');

    // streak check: hard to track streak precisely without session history,
    // so use a simple proxy - completed more than total/2
    if (_stats.completedGames >= 3 && _stats.completedGames > _stats.totalGames / 2) {
      unlock('streak_3');
    }

    if (changed) {
      _stats = _stats.copyWith(unlockedAchievements: unlocked);
      _saveStats();
    }
  }
}
