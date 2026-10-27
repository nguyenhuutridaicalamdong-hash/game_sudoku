import 'dart:convert';
import 'difficulty.dart';

class GameRecord {
  final String id;
  final DateTime dateTime;
  final Difficulty difficulty;
  final int timeSeconds;
  final int mistakes;
  final int score;
  final bool isCompleted;

  GameRecord({
    required this.id,
    required this.dateTime,
    required this.difficulty,
    required this.timeSeconds,
    required this.mistakes,
    required this.score,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'difficulty': difficulty.name,
      'timeSeconds': timeSeconds,
      'mistakes': mistakes,
      'score': score,
      'isCompleted': isCompleted,
    };
  }

  factory GameRecord.fromMap(Map<String, dynamic> map) {
    return GameRecord(
      id: map['id'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String),
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == map['difficulty'],
        orElse: () => Difficulty.medium,
      ),
      timeSeconds: map['timeSeconds'] as int,
      mistakes: map['mistakes'] as int,
      score: map['score'] as int,
      isCompleted: map['isCompleted'] as bool,
    );
  }

  /// Tạo từ JSON GameRecordDto của Web API.
  factory GameRecord.fromServer(Map<String, dynamic> map) {
    return GameRecord(
      id: map['id'].toString(),
      dateTime: DateTime.parse(map['playedAt'] as String).toLocal(),
      difficulty: Difficulty.fromName(map['difficulty'] as String?),
      timeSeconds: (map['timeSeconds'] as num).toInt(),
      mistakes: (map['mistakes'] as num).toInt(),
      score: (map['score'] as num).toInt(),
      isCompleted: map['isCompleted'] as bool,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory GameRecord.fromJson(String source) =>
      GameRecord.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
