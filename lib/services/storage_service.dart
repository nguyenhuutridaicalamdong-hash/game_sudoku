import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/board_state.dart';
import '../models/game_record.dart';
import '../models/user_stats.dart';

/// Lưu cache trên máy (SharedPreferences): cài đặt, ván đang chơi dở,
/// token đăng nhập và các ván chưa gửi được lên server (khi mất mạng).
/// Dữ liệu chính (tài khoản, điểm, lịch sử) nằm trong SQL Server qua Web API.
class StorageService {
  static const String _userStatsKey = 'sudoku_mindful_user_stats';
  static const String _savedGameKey = 'sudoku_mindful_saved_game';
  static const String _gameHistoryKey = 'sudoku_mindful_game_history';
  static const String _tokenKey = 'sudoku_auth_token';
  static const String _pendingGamesKey = 'sudoku_pending_games';

  // ===== Token =====
  static Future<String?> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove(_tokenKey);
    } else {
      await prefs.setString(_tokenKey, token);
    }
  }

  // ===== User stats (cache) =====
  static Future<UserStats> loadUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_userStatsKey);
      if (raw != null) return UserStats.fromJson(raw);
    } catch (_) {}
    return UserStats();
  }

  static Future<void> saveUserStats(UserStats stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userStatsKey, stats.toJson());
    } catch (_) {}
  }

  // ===== Ván đang chơi dở =====
  static Future<BoardState?> loadSavedGame([String? userId]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_savedGameKey);
      if (raw != null) return BoardState.fromJson(raw);
    } catch (_) {}
    return null;
  }

  static Future<void> saveCurrentGame(BoardState? state, [String? userId]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (state == null || state.isCompleted) {
        await prefs.remove(_savedGameKey);
      } else {
        await prefs.setString(_savedGameKey, state.toJson());
      }
    } catch (_) {}
  }

  // ===== Lịch sử (cache) =====
  static Future<List<GameRecord>> loadGameHistory([String? userId]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_gameHistoryKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        return list.map((e) => GameRecord.fromMap(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<void> saveGameHistory(List<GameRecord> history, [String? userId, GameRecord? latestRecord]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(history.map((h) => h.toMap()).toList());
      await prefs.setString(_gameHistoryKey, encoded);
    } catch (_) {}
  }

  // ===== Ván chưa gửi được lên server =====
  static Future<List<Map<String, dynamic>>> loadPendingGames() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_pendingGamesKey);
      if (raw != null) {
        return (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<void> savePendingGames(List<Map<String, dynamic>> games) async {
    final prefs = await SharedPreferences.getInstance();
    if (games.isEmpty) {
      await prefs.remove(_pendingGamesKey);
    } else {
      await prefs.setString(_pendingGamesKey, jsonEncode(games));
    }
  }
}
