import '../../domain/model/puzzle.dart';
import '../../domain/model/game_state.dart';
import '../datasource/game_datasource.dart';

class GameRepository {
  final GameDataSource _dataSource;

  GameRepository(this._dataSource);

  Future<void> savePuzzle(Puzzle puzzle) => _dataSource.savePuzzle(puzzle);
  Future<Puzzle?> loadPuzzle(String id) => _dataSource.loadPuzzle(id);
  Future<void> saveProgress(GameState state) => _dataSource.saveProgress(state);
  Future<void> saveStats(Map<String, dynamic> stats) => _dataSource.saveStats(stats);
  Future<Map<String, dynamic>?> loadStats() => _dataSource.loadStats();
  Future<List<GameState>> getAllProgress() => _dataSource.getAllProgress();
}
