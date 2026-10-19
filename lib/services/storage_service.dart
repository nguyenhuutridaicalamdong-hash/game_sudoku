import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/board_state.dart';
import '../models/game_record.dart';
import '../models/user_stats.dart';
import 'firebase_service.dart';

class StorageService {
  static const String _userStatsKey = 'sudoku_mindful_user_stats';
  static const String _savedGameKey = 'sudoku_mindful_saved_game';
  static const String _gameHistoryKey = 'sudoku_mindful_game_history';

  static Future<UserStats> loadUserStats() async {
    UserStats stats = UserStats();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_userStatsKey);
      if (raw != null) {
        stats = UserStats.fromJson(raw);
      }
    } catch (_) {}

    // Đồng bộ từ Firebase Cloud Firestore nếu có dữ liệu mới trên cloud
    try {
      if (FirebaseService.isInitialized) {
        final cloudStats = await FirebaseService.fetchUserStats(stats.id);
        if (cloudStats != null) {
          stats = cloudStats;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userStatsKey, stats.toJson());
        } else {
          // Lưu dữ liệu ban đầu lên Firestore
          await FirebaseService.syncUserStats(stats);
        }
      }
    } catch (_) {}

    return stats;
  }

  static Future<void> saveUserStats(UserStats stats) async {
    // 1. Lưu cục bộ trước (Local-first) để UI phản hồi tức thì
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userStatsKey, stats.toJson());
    } catch (_) {}

    // 2. Đồng bộ lên Firebase Cloud Firestore
    try {
      await FirebaseService.syncUserStats(stats);
    } catch (_) {}
  }

  static Future<BoardState?> loadSavedGame([String? userId]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_savedGameKey);
      if (raw != null) {
        return BoardState.fromJson(raw);
      }
      if (userId != null && FirebaseService.isInitialized) {
        return await FirebaseService.fetchSavedGame(userId);
      }
      return null;
    } catch (_) {
      return null;
    }
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

    if (userId != null) {
      try {
        await FirebaseService.saveCurrentGame(userId, state);
      } catch (_) {}
    }
  }

  static Future<List<GameRecord>> loadGameHistory([String? userId]) async {
    List<GameRecord> localList = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_gameHistoryKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        localList = list.map((e) => GameRecord.fromMap(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    if (localList.isEmpty && userId != null && FirebaseService.isInitialized) {
      final cloudList = await FirebaseService.fetchGameHistory(userId);
      if (cloudList.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final encoded = jsonEncode(cloudList.map((h) => h.toMap()).toList());
        await prefs.setString(_gameHistoryKey, encoded);
        return cloudList;
      }
    }

    return localList;
  }

  static Future<void> saveGameHistory(List<GameRecord> history, [String? userId, GameRecord? latestRecord]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(history.map((h) => h.toMap()).toList());
      await prefs.setString(_gameHistoryKey, encoded);
    } catch (_) {}

    if (userId != null && latestRecord != null) {
      try {
        await FirebaseService.addGameRecord(userId, latestRecord);
      } catch (_) {}
    }
  }
}
