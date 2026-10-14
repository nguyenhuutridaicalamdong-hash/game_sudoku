import 'dart:convert';
import 'difficulty.dart';

class UserStats {
  String playerName;
  String avatarUrl;
  int streakDays;
  int totalExp;
  int puzzlesCompleted;
  int zeroMistakeGames;
  Map<Difficulty, int?> bestTimes;
  bool soundEnabled;
  bool hapticsEnabled;
  bool autoRemoveNotes;
  bool highlightPeers;
  bool highlightMatchingNumbers;

  UserStats({
    this.playerName = 'Alex',
    this.avatarUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
    this.streakDays = 5,
    this.totalExp = 3420,
    this.puzzlesCompleted = 28,
    this.zeroMistakeGames = 19,
    Map<Difficulty, int?>? bestTimes,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.autoRemoveNotes = true,
    this.highlightPeers = true,
    this.highlightMatchingNumbers = true,
  }) : bestTimes = bestTimes ?? {
          Difficulty.easy: 185,
          Difficulty.medium: 272,
          Difficulty.hard: 410,
          Difficulty.expert: 580,
          Difficulty.daily: 295,
        };

  int get level => (totalExp / 250).floor() + 1;
  int get currentLevelExp => totalExp % 250;
  double get levelProgress => (currentLevelExp / 250).clamp(0.0, 1.0);

  Map<String, dynamic> toMap() {
    return {
      'playerName': playerName,
      'avatarUrl': avatarUrl,
      'streakDays': streakDays,
      'totalExp': totalExp,
      'puzzlesCompleted': puzzlesCompleted,
      'zeroMistakeGames': zeroMistakeGames,
      'bestTimes': bestTimes.map((k, v) => MapEntry(k.name, v)),
      'soundEnabled': soundEnabled,
      'hapticsEnabled': hapticsEnabled,
      'autoRemoveNotes': autoRemoveNotes,
      'highlightPeers': highlightPeers,
      'highlightMatchingNumbers': highlightMatchingNumbers,
    };
  }

  factory UserStats.fromMap(Map<String, dynamic> map) {
    final rawBestTimes = map['bestTimes'] as Map<String, dynamic>? ?? {};
    final parsedBestTimes = <Difficulty, int?>{};
    for (final diff in Difficulty.values) {
      parsedBestTimes[diff] = rawBestTimes[diff.name] as int?;
    }

    return UserStats(
      playerName: map['playerName'] as String? ?? 'Alex',
      avatarUrl: map['avatarUrl'] as String? ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      streakDays: map['streakDays'] as int? ?? 1,
      totalExp: map['totalExp'] as int? ?? 0,
      puzzlesCompleted: map['puzzlesCompleted'] as int? ?? 0,
      zeroMistakeGames: map['zeroMistakeGames'] as int? ?? 0,
      bestTimes: parsedBestTimes,
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      hapticsEnabled: map['hapticsEnabled'] as bool? ?? true,
      autoRemoveNotes: map['autoRemoveNotes'] as bool? ?? true,
      highlightPeers: map['highlightPeers'] as bool? ?? true,
      highlightMatchingNumbers: map['highlightMatchingNumbers'] as bool? ?? true,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory UserStats.fromJson(String source) =>
      UserStats.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
