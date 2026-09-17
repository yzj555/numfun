import 'dart:io';
import 'package:numfun/domain/model/puzzle.dart';
import 'package:numfun/domain/generator/sudoku_generator.dart';

String gridToString(List<List<int>> grid) {
  return grid.map((r) => r.join(',')).join('|');
}

void main() {
  final buffer = StringBuffer();
  buffer.writeln("class LevelPuzzle {");
  buffer.writeln("  final List<List<int>> solution;");
  buffer.writeln("  final List<List<int>> initialBoard;");
  buffer.writeln("  const LevelPuzzle({required this.solution, required this.initialBoard});");
  buffer.writeln("}");
  buffer.writeln();
  buffer.writeln("class LevelData {");
  buffer.writeln("  static final Map<String, Map<int, LevelPuzzle>> puzzles = {");

  for (final diff in Difficulty.values) {
    buffer.writeln("    '${diff.name}': {");
    for (int level = 1; level <= 15; level++) {
      final seed = diff.index * 10000 + level;
      stdout.write('Generating ${diff.name} level $level (seed=$seed)...');
      final generator = SudokuGenerator(seed: seed);
      final solution = generator.generateSolution();
      final puzzle = generator.generatePuzzle(diff, solution: solution);
      final solStr = gridToString(solution);
      final puzStr = gridToString(puzzle);
      buffer.writeln("      $level: LevelPuzzle(");
      buffer.writeln("        solution: _parse('$solStr'),");
      buffer.writeln("        initialBoard: _parse('$puzStr'),");
      buffer.writeln("      ),");
      stdout.writeln(' done');
    }
    buffer.writeln("    },");
  }

  buffer.writeln("  };");
  buffer.writeln();
  buffer.writeln("  static List<List<int>> _parse(String raw) {");
  buffer.writeln("    return raw.split('|').map((r) =>");
  buffer.writeln("      r.split(',').map(int.parse).toList()");
  buffer.writeln("    ).toList();");
  buffer.writeln("  }");
  buffer.writeln("}");

  final path = 'lib/data/level_data.dart';
  File(path).writeAsStringSync(buffer.toString());
  print('\nWritten $path');
}
