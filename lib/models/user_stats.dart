import 'dart:convert';
import 'difficulty.dart';

class UserStats {
  /// Id người chơi trong SQL Server ('' = chưa đăng nhập).
  String id;
  String username;
  String playerName;
  String avatarUrl;
  int streakDays;
  int totalExp;
  int totalScore;
  int gamesPlayed;
  int puzzlesCompleted;
  int zeroMistakeGames;
  Map<Difficulty, int?> bestTimes;

  // Cài đặt (lưu trên máy, không lưu lên server)
  bool soundEnabled;
  bool hapticsEnabled;
  bool autoRemoveNotes;
  bool highlightPeers;
  bool highlightMatchingNumbers;

  static const String defaultAvatar =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80';

  UserStats({
    this.id = '',
    this.username = '',
    this.playerName = 'Người chơi',
    this.avatarUrl = defaultAvatar,
    this.streakDays = 0,
    this.totalExp = 0,
    this.totalScore = 0,
    this.gamesPlayed = 0,
    this.puzzlesCompleted = 0,
    this.zeroMistakeGames = 0,
    Map<Difficulty, int?>? bestTimes,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.autoRemoveNotes = true,
    this.highlightPeers = true,
    this.highlightMatchingNumbers = true,
  }) : bestTimes = bestTimes ?? {};

  int get level => (totalExp / 250).floor() + 1;
  int get currentLevelExp => totalExp % 250;
  double get levelProgress => (currentLevelExp / 250).clamp(0.0, 1.0);

  /// Cập nhật số liệu từ JSON UserDto của API (giữ nguyên phần cài đặt).
  void applyServerUser(Map<String, dynamic> u) {
    id = u['id'].toString();
    username = u['username'] as String? ?? '';
    playerName = u['displayName'] as String? ?? username;
    totalExp = (u['totalExp'] as num?)?.toInt() ?? 0;
    totalScore = (u['totalScore'] as num?)?.toInt() ?? 0;
    gamesPlayed = (u['gamesPlayed'] as num?)?.toInt() ?? 0;
    puzzlesCompleted = (u['puzzlesCompleted'] as num?)?.toInt() ?? 0;
    zeroMistakeGames = (u['zeroMistakeGames'] as num?)?.toInt() ?? 0;
    streakDays = (u['streakDays'] as num?)?.toInt() ?? 0;

    final raw = u['bestTimes'];
    bestTimes = {};
    if (raw is Map) {
      raw.forEach((key, value) {
        bestTimes[Difficulty.fromName(key.toString())] = (value as num?)?.toInt();
      });
    }
  }

  /// Xóa dữ liệu tài khoản (khi đăng xuất), giữ cài đặt.
  UserStats copySettingsOnly() {
    return UserStats(
      soundEnabled: soundEnabled,
      hapticsEnabled: hapticsEnabled,
      autoRemoveNotes: autoRemoveNotes,
      highlightPeers: highlightPeers,
      highlightMatchingNumbers: highlightMatchingNumbers,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'playerName': playerName,
      'avatarUrl': avatarUrl,
      'streakDays': streakDays,
      'totalExp': totalExp,
      'totalScore': totalScore,
      'gamesPlayed': gamesPlayed,
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
      id: map['id']?.toString() ?? '',
      username: map['username'] as String? ?? '',
      playerName: map['playerName'] as String? ?? 'Người chơi',
      avatarUrl: map['avatarUrl'] as String? ?? defaultAvatar,
      streakDays: map['streakDays'] as int? ?? 0,
      totalExp: map['totalExp'] as int? ?? 0,
      totalScore: map['totalScore'] as int? ?? 0,
      gamesPlayed: map['gamesPlayed'] as int? ?? 0,
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
