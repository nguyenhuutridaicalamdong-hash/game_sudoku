class SudokuCell {
  final int row;
  final int col;
  final int box;
  int? value;
  final int solution;
  final bool isGiven;
  bool isError;
  Set<int> notes;

  SudokuCell({
    required this.row,
    required this.col,
    required this.box,
    this.value,
    required this.solution,
    required this.isGiven,
    this.isError = false,
    Set<int>? notes,
  }) : notes = notes ?? <int>{};

  SudokuCell copyWith({
    int? value,
    bool? isError,
    Set<int>? notes,
  }) {
    return SudokuCell(
      row: row,
      col: col,
      box: box,
      value: value ?? this.value,
      solution: solution,
      isGiven: isGiven,
      isError: isError ?? this.isError,
      notes: notes != null ? Set<int>.from(notes) : Set<int>.from(this.notes),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'row': row,
      'col': col,
      'box': box,
      'value': value,
      'solution': solution,
      'isGiven': isGiven,
      'isError': isError,
      'notes': notes.toList(),
    };
  }

  factory SudokuCell.fromMap(Map<String, dynamic> map) {
    return SudokuCell(
      row: map['row'] as int,
      col: map['col'] as int,
      box: map['box'] as int,
      value: map['value'] as int?,
      solution: map['solution'] as int,
      isGiven: map['isGiven'] as bool,
      isError: map['isError'] as bool? ?? false,
      notes: (map['notes'] as List<dynamic>?)?.map((e) => e as int).toSet() ?? {},
    );
  }
}
