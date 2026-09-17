import 'package:flutter_test/flutter_test.dart';
import 'package:numfun/domain/model/puzzle.dart';
import 'package:numfun/domain/generator/sudoku_generator.dart';

void main() {
  group('SudokuGenerator', () {
    test('generates valid solution', () {
      final gen = SudokuGenerator();
      final solution = gen.generateSolution();

      expect(solution.length, 9);
      for (final row in solution) {
        expect(row.length, 9);
        expect(row.toSet().length, 9, reason: 'each row must have unique values');
      }
    });

    test('generates valid puzzle', () {
      final gen = SudokuGenerator();
      final puzzle = gen.generatePuzzle(Difficulty.easy);

      expect(puzzle.length, 9);
      expect(gen.validate(puzzle), true);
    });

    test('difficulty labels are correct', () {
      expect(Difficulty.easy.label, '简单');
      expect(Difficulty.medium.label, '普通');
      expect(Difficulty.hard.label, '困难');
      expect(Difficulty.expert.label, '专家');
    });

    test('puzzle has unique solution', () {
      final gen = SudokuGenerator();
      final puzzle = gen.generatePuzzle(Difficulty.easy);
      final count = gen.countSolutions(puzzle, limit: 2);
      expect(count, 1, reason: 'puzzle must have unique solution');
    });

    test('puzzle toJson/fromJson roundtrip', () {
      final gen = SudokuGenerator();
      final puzzle = Puzzle(
        id: 'test_1',
        solution: gen.generateSolution(),
        initialBoard: gen.generatePuzzle(Difficulty.medium),
        difficulty: Difficulty.medium,
        mode: GameMode.classic,
      );

      final json = puzzle.toJson();
      final restored = Puzzle.fromJson(json);

      expect(restored.id, puzzle.id);
      expect(restored.difficulty, puzzle.difficulty);
      expect(restored.mode, puzzle.mode);
    });
  });
}
