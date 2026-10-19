import 'dart:convert';
import 'difficulty.dart';
import 'sudoku_cell.dart';

class HistorySnapshot {
  final List<SudokuCell> cells;
  final int mistakes;

  HistorySnapshot({
    required this.cells,
    required this.mistakes,
  });

  Map<String, dynamic> toMap() {
    return {
      'cells': cells.map((c) => c.toMap()).toList(),
      'mistakes': mistakes,
    };
  }

  factory HistorySnapshot.fromMap(Map<String, dynamic> map) {
    return HistorySnapshot(
      cells: (map['cells'] as List<dynamic>)
          .map((c) => SudokuCell.fromMap(c as Map<String, dynamic>))
          .toList(),
      mistakes: map['mistakes'] as int,
    );
  }
}

class BoardState {
  List<SudokuCell> cells;
  final Difficulty difficulty;
  int timeSeconds;
  int mistakes;
  final int maxMistakes;
  int hintsRemaining;
  bool isCompleted;
  bool isPaused;
  bool notesMode;
  int? selectedCellIndex;
  List<HistorySnapshot> history;

  BoardState({
    required this.cells,
    required this.difficulty,
    this.timeSeconds = 0,
    this.mistakes = 0,
    this.maxMistakes = 3,
    this.hintsRemaining = 3,
    this.isCompleted = false,
    this.isPaused = false,
    this.notesMode = false,
    this.selectedCellIndex,
    List<HistorySnapshot>? history,
  }) : history = history ?? [];

  Map<String, dynamic> toMap() {
    return {
      'cells': cells.map((c) => c.toMap()).toList(),
      'difficulty': difficulty.name,
      'timeSeconds': timeSeconds,
      'mistakes': mistakes,
      'maxMistakes': maxMistakes,
      'hintsRemaining': hintsRemaining,
      'isCompleted': isCompleted,
      'isPaused': isPaused,
      'notesMode': notesMode,
      'selectedCellIndex': selectedCellIndex,
      'history': history.map((h) => h.toMap()).toList(),
    };
  }

  factory BoardState.fromMap(Map<String, dynamic> map) {
    return BoardState(
      cells: (map['cells'] as List<dynamic>)
          .map((c) => SudokuCell.fromMap(c as Map<String, dynamic>))
          .toList(),
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == map['difficulty'],
        orElse: () => Difficulty.medium,
      ),
      timeSeconds: map['timeSeconds'] as int? ?? 0,
      mistakes: map['mistakes'] as int? ?? 0,
      maxMistakes: map['maxMistakes'] as int? ?? 3,
      hintsRemaining: map['hintsRemaining'] as int? ?? 3,
      isCompleted: map['isCompleted'] as bool? ?? false,
      isPaused: map['isPaused'] as bool? ?? false,
      notesMode: map['notesMode'] as bool? ?? false,
      selectedCellIndex: map['selectedCellIndex'] as int?,
      history: (map['history'] as List<dynamic>?)
              ?.map((h) => HistorySnapshot.fromMap(h as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String toJson() => jsonEncode(toMap());

  factory BoardState.fromJson(String source) =>
      BoardState.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
