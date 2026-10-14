import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/board_state.dart';
import '../models/game_record.dart';
import '../models/user_stats.dart';

class StorageService {
  static const String _userStatsKey = 'sudoku_mindful_user_stats';
  static const String _savedGameKey = 'sudoku_mindful_saved_game';
  static const String _gameHistoryKey = 'sudoku_mindful_game_history';

  static Future<UserStats> loadUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_userStatsKey);
      if (raw == null) return UserStats();
      return UserStats.fromJson(raw);
    } catch (_) {
      return UserStats();
    }
  }

  static Future<void> saveUserStats(UserStats stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userStatsKey, stats.toJson());
    } catch (_) {}
  }

  static Future<BoardState?> loadSavedGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_savedGameKey);
      if (raw == null) return null;
      return BoardState.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveCurrentGame(BoardState? state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (state == null || state.isCompleted) {
        await prefs.remove(_savedGameKey);
      } else {
        await prefs.setString(_savedGameKey, state.toJson());
      }
    } catch (_) {}
  }

  static Future<List<GameRecord>> loadGameHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_gameHistoryKey);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => GameRecord.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveGameHistory(List<GameRecord> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(history.map((h) => h.toMap()).toList());
      await prefs.setString(_gameHistoryKey, encoded);
    } catch (_) {}
  }
}
