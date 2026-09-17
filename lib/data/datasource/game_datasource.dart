import '../../domain/model/puzzle.dart';
import '../../domain/model/game_state.dart';

abstract class GameDataSource {
  Future<void> savePuzzle(Puzzle puzzle);
  Future<Puzzle?> loadPuzzle(String id);
  Future<void> saveProgress(GameState state);
  Future<GameState?> loadProgress(String puzzleId);
  Future<void> saveStats(Map<String, dynamic> stats);
  Future<Map<String, dynamic>?> loadStats();
  Future<List<GameState>> getAllProgress();
}
