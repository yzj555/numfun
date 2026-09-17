import 'dart:math';
import '../model/puzzle.dart';

class DLXNode {
  DLXNode? left;
  DLXNode? right;
  DLXNode? up;
  DLXNode? down;
  ColumnNode? column;
  int rowId;

  DLXNode() : rowId = -1;
}

class ColumnNode extends DLXNode {
  int size;
  final String name;

  ColumnNode(this.name) : size = 0, super();
}

class SudokuGenerator {
  final Random _random;

  SudokuGenerator({int? seed}) : _random = Random(seed);

  List<List<int>> generateSolution() {
    final cover = _buildExactCover();
    final root = _buildDLX(cover);
    final solution = <int>[];
    _search(root, solution, 0);

    if (solution.length < 81) {
      return _fallbackGenerate();
    }

    final grid = List.generate(9, (_) => List.filled(9, 0));
    for (final val in solution) {
      final r = (val ~/ 9) ~/ 9;
      final c = (val ~/ 9) % 9;
      final v = val % 9 + 1;
      grid[r][c] = v;
    }
    return grid;
  }

  List<List<int>> generatePuzzle(Difficulty difficulty, {List<List<int>>? solution}) {
    final sol = solution ?? generateSolution();
    final puzzle = sol.map((row) => List<int>.from(row)).toList();
    final cells = <int>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        cells.add(r * 9 + c);
      }
    }
    cells.shuffle(_random);

    final targetClues = difficulty.clues;
    int clues = 81;

    for (final cell in cells) {
      if (clues <= targetClues) break;
      final r = cell ~/ 9;
      final c = cell % 9;
      final backup = puzzle[r][c];
      puzzle[r][c] = 0;

      if (_hasUniqueSolution(puzzle)) {
        clues--;
      } else {
        puzzle[r][c] = backup;
      }
    }
    return puzzle;
  }

  bool validate(List<List<int>> grid) {
    for (int i = 0; i < 9; i++) {
      final rowSet = <int>{};
      final colSet = <int>{};
      final boxSet = <int>{};
      for (int j = 0; j < 9; j++) {
        if (grid[i][j] != 0) {
          if (rowSet.contains(grid[i][j])) return false;
          rowSet.add(grid[i][j]);
        }
        if (grid[j][i] != 0) {
          if (colSet.contains(grid[j][i])) return false;
          colSet.add(grid[j][i]);
        }
        final br = (i ~/ 3) * 3 + j ~/ 3;
        final bc = (i % 3) * 3 + j % 3;
        if (grid[br][bc] != 0) {
          if (boxSet.contains(grid[br][bc])) return false;
          boxSet.add(grid[br][bc]);
        }
      }
    }
    return true;
  }

  int countSolutions(List<List<int>> puzzle, {int limit = 2}) {
    final grid = puzzle.map((r) => List<int>.from(r)).toList();
    int count = 0;

    void solve(int pos) {
      if (count >= limit) return;
      if (pos == 81) {
        count++;
        return;
      }
      final r = pos ~/ 9;
      final c = pos % 9;
      if (grid[r][c] != 0) {
        solve(pos + 1);
        return;
      }
      for (int v = 1; v <= 9; v++) {
        if (_isValid(grid, r, c, v)) {
          grid[r][c] = v;
          solve(pos + 1);
          grid[r][c] = 0;
          if (count >= limit) return;
        }
      }
    }

    solve(0);
    return count;
  }

  bool _hasUniqueSolution(List<List<int>> puzzle) {
    return countSolutions(puzzle, limit: 2) == 1;
  }

  bool _isValid(List<List<int>> grid, int row, int col, int val) {
    for (int i = 0; i < 9; i++) {
      if (grid[row][i] == val) return false;
      if (grid[i][col] == val) return false;
    }
    final br = (row ~/ 3) * 3;
    final bc = (col ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (grid[br + i][bc + j] == val) return false;
      }
    }
    return true;
  }

  List<List<int>> _buildExactCover() {
    final cover = <List<int>>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        for (int v = 0; v < 9; v++) {
          final row = List.filled(324, 0);
          final cell = r * 9 + c;
          final rowC = r * 9 + v;
          final colC = c * 9 + v + 81;
          final box = (r ~/ 3) * 3 + (c ~/ 3);
          final boxC = box * 9 + v + 162;
          row[cell] = 1;
          row[rowC] = 1;
          row[colC] = 1;
          row[boxC] = 1;
          cover.add(row);
        }
      }
    }
    return cover;
  }

  ColumnNode _buildDLX(List<List<int>> cover) {
    final header = ColumnNode('root');
    final columns = <ColumnNode>[];

    for (int i = 0; i < 324; i++) {
      final col = ColumnNode('col$i');
      columns.add(col);
    }

    ColumnNode? prev = header;
    for (final col in columns) {
      prev!.right = col;
      col.left = prev;
      prev = col;
    }
    prev!.right = header;
    header.left = prev;

    for (int i = 0; i < cover.length; i++) {
      DLXNode? firstNode;
      DLXNode? prevNode;
      for (int j = 0; j < 324; j++) {
        if (cover[i][j] == 1) {
          final node = DLXNode();
          node.rowId = i;
          node.column = columns[j];
          columns[j].size++;

          final last = columns[j].up ?? columns[j];
          node.down = columns[j];
          node.up = last;
          last.down = node;
          columns[j].up = node;

          if (firstNode == null) {
            firstNode = node;
            prevNode = node;
          } else {
            prevNode!.right = node;
            node.left = prevNode;
            prevNode = node;
          }
        }
      }
      if (firstNode != null && prevNode != null) {
        prevNode.right = firstNode;
        firstNode.left = prevNode;
      }
    }

    for (final col in columns) {
      if (col.up == null) {
        col.up = col;
        col.down = col;
      }
    }

    return header;
  }

  void _search(ColumnNode root, List<int> solution, int depth) {
    if (root.right == root) return;

    ColumnNode? best;
    int minSize = 1000;
    var col = root.right as ColumnNode?;
    while (col != null && col != root) {
      if (col.size < minSize) {
        minSize = col.size;
        best = col;
      }
      col = col.right as ColumnNode?;
    }
    if (best == null || minSize == 0) return;

    _cover(best);
    var node = best.down as DLXNode?;
    while (node != null && node != best) {
      solution.add(node.rowId);
      var right = node.right;
      while (right != null && right != node) {
        _cover(right.column!);
        right = right.right;
      }
      _search(root, solution, depth + 1);
      if (solution.length == 81) return;
      solution.removeLast();
      var left = node.left;
      while (left != null && left != node) {
        _uncover(left.column!);
        left = left.left;
      }
      node = node.down as DLXNode?;
    }
    _uncover(best);
  }

  void _cover(ColumnNode col) {
    col.right!.left = col.left;
    col.left!.right = col.right;
    var node = col.down as DLXNode?;
    while (node != null && node != col) {
      var right = node.right;
      while (right != null && right != node) {
        right.down!.up = right.up;
        right.up!.down = right.down;
        right.column!.size--;
        right = right.right;
      }
      node = node.down as DLXNode?;
    }
  }

  void _uncover(ColumnNode col) {
    var node = col.up as DLXNode?;
    while (node != null && node != col) {
      var left = node.left;
      while (left != null && left != node) {
        left.column!.size++;
        left.down!.up = left;
        left.up!.down = left;
        left = left.left;
      }
      node = node.up as DLXNode?;
    }
    col.right!.left = col;
    col.left!.right = col;
  }

  List<List<int>> _fallbackGenerate() {
    final grid = List.generate(9, (_) => List.filled(9, 0));
    _fillGrid(grid);
    return grid;
  }

  bool _fillGrid(List<List<int>> grid) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c] == 0) {
          final nums = List.generate(9, (i) => i + 1)..shuffle(_random);
          for (final v in nums) {
            if (_isValid(grid, r, c, v)) {
              grid[r][c] = v;
              if (_fillGrid(grid)) return true;
              grid[r][c] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }
}
