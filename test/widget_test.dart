import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_flutter/models/difficulty.dart';
import 'package:sudoku_flutter/services/sudoku_generator.dart';

void main() {
  group('Sinh đề theo cấp độ', () {
    for (final diff in Difficulty.values) {
      test('${diff.label}: đề hợp lệ, duy nhất 1 lời giải', () {
        final cells = SudokuGenerator.generatePuzzle(diff);
        expect(cells.length, 81);

        final board = cells.map((c) => c.value ?? 0).toList();
        expect(SudokuGenerator.countSolutions(board), 1);

        // Ô cho sẵn phải khớp với lời giải
        for (final c in cells.where((c) => c.isGiven)) {
          expect(c.value, c.solution);
        }

        final givens = cells.where((c) => c.isGiven).length;
        final (minG, maxG) = diff.givensRange;
        // Cấp khó có thể dư vài ô nếu không xóa được thêm mà vẫn giữ 1 lời giải
        expect(givens, inInclusiveRange(minG - 1, maxG + 3));
      });
    }
  });

  test('Tính điểm giống ScoreCalculator.cs', () {
    expect(Difficulty.hard.computeScore(timeSeconds: 600, mistakes: 1, hintsUsed: 1, isCompleted: true),
        900 + 120 - 80 - 50);
    expect(Difficulty.easy.computeScore(timeSeconds: 10000, mistakes: 3, hintsUsed: 3, isCompleted: true), 100);
    expect(Difficulty.extreme.computeScore(timeSeconds: 0, mistakes: 0, hintsUsed: 0, isCompleted: false), 0);
    expect(Difficulty.computeExp(mistakes: 0, isCompleted: true), 150);
  });
}
