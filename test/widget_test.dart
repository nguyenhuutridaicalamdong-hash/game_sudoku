import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_flutter/main.dart';

void main() {
  testWidgets('SudokuApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SudokuApp());
    expect(find.byType(SudokuApp), findsOneWidget);
  });
}
