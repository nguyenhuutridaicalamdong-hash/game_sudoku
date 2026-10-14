import 'dart:math';
import '../models/difficulty.dart';
import '../models/sudoku_cell.dart';

class SudokuGenerator {
  // Pre-crafted master puzzle matching the exact Google Stitch mockup
  static const List<List<int>> screenshotGivens = [
    [5, 3, 0, 0, 7, 0, 0, 0, 0],
    [6, 0, 0, 1, 9, 5, 0, 0, 0],
    [0, 9, 8, 0, 0, 0, 0, 6, 0],
    [8, 0, 0, 0, 6, 0, 0, 0, 3],
    [4, 0, 0, 8, 0, 3, 0, 0, 1],
    [7, 0, 0, 0, 2, 0, 0, 0, 6],
    [0, 6, 0, 0, 0, 0, 2, 8, 0],
    [0, 0, 0, 4, 1, 9, 0, 0, 5],
    [0, 0, 0, 0, 8, 0, 0, 7, 9],
  ];

  static const List<List<int>> screenshotSolution = [
    [5, 3, 4, 6, 7, 8, 9, 1, 2],
    [6, 7, 2, 1, 9, 5, 3, 4, 8],
    [1, 9, 8, 3, 4, 2, 5, 6, 7],
    [8, 5, 9, 7, 6, 1, 4, 2, 3],
    [4, 2, 6, 8, 5, 3, 7, 9, 1],
    [7, 1, 3, 9, 2, 4, 8, 5, 6],
    [9, 6, 1, 5, 3, 7, 2, 8, 4],
    [2, 8, 7, 4, 1, 9, 6, 3, 5],
    [3, 4, 5, 2, 8, 6, 1, 7, 9],
  ];

  static bool isValidPlacement(List<List<int>> board, int row, int col, int num) {
    for (int c = 0; c < 9; c++) {
      if (board[row][c] == num) return false;
    }
    for (int r = 0; r < 9; r++) {
      if (board[r][col] == num) return false;
    }
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        if (board[boxRow + r][boxCol + c] == num) return false;
      }
    }
    return true;
  }

  static bool solveSudoku(List<List<int>> board) {
    final random = Random();
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] == 0) {
          final nums = [1, 2, 3, 4, 5, 6, 7, 8, 9]..shuffle(random);
          for (final num in nums) {
            if (isValidPlacement(board, r, c, num)) {
              board[r][c] = num;
              if (solveSudoku(board)) return true;
              board[r][c] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  static List<SudokuCell> generatePuzzle(Difficulty difficulty) {
    final random = Random();

    // 40% chance on expert to use the exact screenshot puzzle
    if (difficulty == Difficulty.expert && random.nextDouble() < 0.4) {
      final cells = <SudokuCell>[];
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          final val = screenshotGivens[r][c];
          final isGiven = val != 0;
          cells.add(SudokuCell(
            row: r,
            col: c,
            box: (r ~/ 3) * 3 + (c ~/ 3),
            value: isGiven ? val : null,
            solution: screenshotSolution[r][c],
            isGiven: isGiven,
            isError: false,
          ));
        }
      }
      return cells;
    }

    // 1. Create fully solved 9x9 board
    final fullBoard = List.generate(9, (_) => List.filled(9, 0));
    solveSudoku(fullBoard);

    final solutionCopy = List.generate(9, (r) => List<int>.from(fullBoard[r]));
    final puzzleBoard = List.generate(9, (r) => List<int>.from(fullBoard[r]));

    // 2. Determine number of clues to remove based on difficulty
    int cluesToRemove;
    switch (difficulty) {
      case Difficulty.easy:
        cluesToRemove = 36 + random.nextInt(4); // 36-39
        break;
      case Difficulty.medium:
        cluesToRemove = 46 + random.nextInt(4); // 46-49
        break;
      case Difficulty.hard:
        cluesToRemove = 52 + random.nextInt(3); // 52-54
        break;
      case Difficulty.expert:
        cluesToRemove = 56 + random.nextInt(2); // 56-57
        break;
      case Difficulty.daily:
        cluesToRemove = 45;
        break;
    }

    // 3. Shuffle all (r, c) positions
    final positions = <Point<int>>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        positions.add(Point(r, c));
      }
    }
    positions.shuffle(random);

    for (int i = 0; i < cluesToRemove && i < positions.length; i++) {
      final p = positions[i];
      puzzleBoard[p.x][p.y] = 0;
    }

    // 4. Construct cell list
    final cells = <SudokuCell>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final val = puzzleBoard[r][c];
        final isGiven = val != 0;
        cells.add(SudokuCell(
          row: r,
          col: c,
          box: (r ~/ 3) * 3 + (c ~/ 3),
          value: isGiven ? val : null,
          solution: solutionCopy[r][c],
          isGiven: isGiven,
          isError: false,
        ));
      }
    }
    return cells;
  }

  static List<int> getPeerIndices(int cellIndex) {
    final row = cellIndex ~/ 9;
    final col = cellIndex % 9;
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;

    final peers = <int>{};

    for (int c = 0; c < 9; c++) {
      peers.add(row * 9 + c);
    }
    for (int r = 0; r < 9; r++) {
      peers.add(r * 9 + col);
    }
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        peers.add((boxRow + r) * 9 + (boxCol + c));
      }
    }

    peers.remove(cellIndex);
    return peers.toList();
  }

  static Map<int, int> getRemainingDigitCounts(List<SudokuCell> cells) {
    final counts = <int, int>{
      1: 9, 2: 9, 3: 9, 4: 9, 5: 9, 6: 9, 7: 9, 8: 9, 9: 9,
    };

    for (final cell in cells) {
      if (cell.value != null &&
          cell.value! >= 1 &&
          cell.value! <= 9 &&
          !cell.isError) {
        counts[cell.value!] = max(0, counts[cell.value!]! - 1);
      }
    }

    return counts;
  }

  static bool isPuzzleSolved(List<SudokuCell> cells) {
    return cells.every((cell) =>
        cell.value != null &&
        cell.value == cell.solution &&
        !cell.isError);
  }

  static String formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
