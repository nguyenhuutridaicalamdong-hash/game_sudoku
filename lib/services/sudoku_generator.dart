import 'dart:math';
import '../models/difficulty.dart';
import '../models/sudoku_cell.dart';

class SudokuGenerator {
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

  /// Điền đầy bảng ngẫu nhiên bằng backtracking.
  static bool solveSudoku(List<List<int>> board, [Random? random]) {
    final rnd = random ?? Random();
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] == 0) {
          final nums = [1, 2, 3, 4, 5, 6, 7, 8, 9]..shuffle(rnd);
          for (final num in nums) {
            if (isValidPlacement(board, r, c, num)) {
              board[r][c] = num;
              if (solveSudoku(board, rnd)) return true;
              board[r][c] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  /// Đếm số lời giải của đề (dừng khi đạt [limit]). Dùng bitmask + chọn ô ít
  /// ứng viên nhất trước (MRV) nên chạy rất nhanh.
  /// [board] là mảng 81 phần tử, 0 = ô trống.
  static int countSolutions(List<int> board, {int limit = 2}) {
    final b = List<int>.from(board);
    final rows = List<int>.filled(9, 0);
    final cols = List<int>.filled(9, 0);
    final boxes = List<int>.filled(9, 0);
    final empties = <int>[];

    for (int i = 0; i < 81; i++) {
      final v = b[i];
      final r = i ~/ 9, c = i % 9, bx = (r ~/ 3) * 3 + c ~/ 3;
      if (v != 0) {
        final m = 1 << v;
        if ((rows[r] | cols[c] | boxes[bx]) & m != 0) return 0; // đề sai luật
        rows[r] |= m;
        cols[c] |= m;
        boxes[bx] |= m;
      } else {
        empties.add(i);
      }
    }

    int found = 0;

    int bitCount(int m) {
      int n = 0;
      while (m != 0) {
        m &= m - 1;
        n++;
      }
      return n;
    }

    void search() {
      if (found >= limit) return;
      int best = -1, bestMask = 0, bestCount = 10;
      for (final i in empties) {
        if (b[i] != 0) continue;
        final r = i ~/ 9, c = i % 9, bx = (r ~/ 3) * 3 + c ~/ 3;
        final mask = ~(rows[r] | cols[c] | boxes[bx]) & 0x3FE;
        final cnt = bitCount(mask);
        if (cnt < bestCount) {
          bestCount = cnt;
          best = i;
          bestMask = mask;
          if (cnt == 0) return; // ngõ cụt
        }
      }
      if (best == -1) {
        found++; // đã điền hết
        return;
      }
      final r = best ~/ 9, c = best % 9, bx = (r ~/ 3) * 3 + c ~/ 3;
      for (int d = 1; d <= 9; d++) {
        if (bestMask & (1 << d) == 0) continue;
        final m = 1 << d;
        b[best] = d;
        rows[r] |= m;
        cols[c] |= m;
        boxes[bx] |= m;
        search();
        b[best] = 0;
        rows[r] &= ~m;
        cols[c] &= ~m;
        boxes[bx] &= ~m;
        if (found >= limit) return;
      }
    }

    search();
    return found;
  }

  /// Sinh 1 đề có duy nhất 1 lời giải, cố gắng xóa còn khoảng [targetGivens] ô.
  /// Trả về (đề, lời giải, số ô cho sẵn thực tế).
  static (List<int>, List<int>, int) _generateOnce(int targetGivens, Random random) {
    final full = List.generate(9, (_) => List.filled(9, 0));
    solveSudoku(full, random);
    final solution = [for (final row in full) ...row];
    final puzzle = List<int>.from(solution);

    final positions = List<int>.generate(81, (i) => i)..shuffle(random);
    int givens = 81;
    for (final p in positions) {
      if (givens <= targetGivens) break;
      final backup = puzzle[p];
      puzzle[p] = 0;
      if (countSolutions(puzzle) != 1) {
        puzzle[p] = backup; // xóa ô này thì đề có nhiều lời giải → giữ lại
      } else {
        givens--;
      }
    }
    return (puzzle, solution, givens);
  }

  static List<SudokuCell> generatePuzzle(Difficulty difficulty) {
    // Thử thách ngày: cùng 1 ngày thì mọi người chơi cùng 1 đề
    final now = DateTime.now();
    final random = difficulty == Difficulty.daily
        ? Random(now.year * 10000 + now.month * 100 + now.day)
        : Random();

    final (minGivens, maxGivens) = difficulty.givensRange;
    final target = minGivens + random.nextInt(maxGivens - minGivens + 1);

    // Cấp càng khó càng khó xóa đủ ô → thử nhiều lần, lấy đề tốt nhất
    List<int>? bestPuzzle;
    List<int>? bestSolution;
    int bestGivens = 82;
    for (int attempt = 0; attempt < 30; attempt++) {
      final (puzzle, solution, givens) = _generateOnce(target, random);
      if (givens < bestGivens) {
        bestPuzzle = puzzle;
        bestSolution = solution;
        bestGivens = givens;
      }
      if (givens <= maxGivens) break;
    }

    final cells = <SudokuCell>[];
    for (int i = 0; i < 81; i++) {
      final r = i ~/ 9, c = i % 9;
      final val = bestPuzzle![i];
      final isGiven = val != 0;
      cells.add(SudokuCell(
        row: r,
        col: c,
        box: (r ~/ 3) * 3 + (c ~/ 3),
        value: isGiven ? val : null,
        solution: bestSolution![i],
        isGiven: isGiven,
        isError: false,
      ));
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
