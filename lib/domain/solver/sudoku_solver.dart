class SudokuSolver {
  bool solve(List<List<int>> grid) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c] == 0) {
          for (int v = 1; v <= 9; v++) {
            if (_isValid(grid, r, c, v)) {
              grid[r][c] = v;
              if (solve(grid)) return true;
              grid[r][c] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  int? findHint(List<List<int>> puzzle, List<List<int>> current) {
    final solution = puzzle.map((r) => List<int>.from(r)).toList();
    solve(solution);

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (current[r][c] == 0) {
          final candidates = getCandidates(current, r, c);
          if (candidates.length == 1) {
            return solution[r][c];
          }
        }
      }
    }

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (current[r][c] == 0) {
          return solution[r][c];
        }
      }
    }
    return null;
  }

  List<int> getCandidates(List<List<int>> grid, int row, int col) {
    if (grid[row][col] != 0) return [];
    final used = <int>{};
    for (int i = 0; i < 9; i++) {
      used.add(grid[row][i]);
      used.add(grid[i][col]);
    }
    final br = (row ~/ 3) * 3;
    final bc = (col ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        used.add(grid[br + i][bc + j]);
      }
    }
    return [for (int v = 1; v <= 9; v++) if (!used.contains(v)) v];
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

  bool isComplete(List<List<int>> grid) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c] == 0) return false;
      }
    }
    return validate(grid);
  }

  bool validate(List<List<int>> grid) {
    for (int i = 0; i < 9; i++) {
      final rowSet = <int>{};
      final colSet = <int>{};
      for (int j = 0; j < 9; j++) {
        if (grid[i][j] == 0 || rowSet.contains(grid[i][j])) return false;
        if (grid[j][i] == 0 || colSet.contains(grid[j][i])) return false;
        rowSet.add(grid[i][j]);
        colSet.add(grid[j][i]);
      }
    }
    for (int br = 0; br < 9; br += 3) {
      for (int bc = 0; bc < 9; bc += 3) {
        final boxSet = <int>{};
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            final v = grid[br + i][bc + j];
            if (v == 0 || boxSet.contains(v)) return false;
            boxSet.add(v);
          }
        }
      }
    }
    return true;
  }
}
