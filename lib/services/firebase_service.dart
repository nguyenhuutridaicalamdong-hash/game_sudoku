import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/board_state.dart';
import '../models/game_record.dart';
import '../models/user_stats.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  /// Khởi tạo Firebase
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _initialized = true;
      debugPrint('[FirebaseService] Firebase initialized successfully.');
    } catch (e) {
      debugPrint('[FirebaseService] Firebase initialization failed: $e');
    }
  }

  // ==========================================
  // USERS / STATS COLLECTION
  // ==========================================

  /// Lưu hoặc cập nhật thông tin người chơi lên Cloud Firestore
  static Future<void> syncUserStats(UserStats stats) async {
    if (!_initialized) return;
    try {
      final docRef = _firestore.collection('users').doc(stats.id);
      final data = stats.toMap();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await docRef.set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[FirebaseService] Error syncing user stats: $e');
    }
  }

  /// Lấy thông tin người chơi từ Cloud Firestore
  static Future<UserStats?> fetchUserStats(String userId) async {
    if (!_initialized) return null;
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserStats.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('[FirebaseService] Error fetching user stats: $e');
    }
    return null;
  }

  // ==========================================
  // GAME HISTORY COLLECTION
  // ==========================================

  /// Lưu lịch sử ván cờ vào Cloud Firestore
  static Future<void> addGameRecord(String userId, GameRecord record) async {
    if (!_initialized) return;
    try {
      final docRef = _firestore.collection('game_history').doc(record.id);
      final data = record.toMap();
      data['userId'] = userId;
      data['createdAt'] = FieldValue.serverTimestamp();
      await docRef.set(data);
    } catch (e) {
      debugPrint('[FirebaseService] Error adding game record: $e');
    }
  }

  /// Lấy danh sách lịch sử ván cờ của người chơi từ Cloud Firestore
  static Future<List<GameRecord>> fetchGameHistory(String userId) async {
    if (!_initialized) return [];
    try {
      final snapshot = await _firestore
          .collection('game_history')
          .where('userId', isEqualTo: userId)
          .orderBy('dateTime', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => GameRecord.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('[FirebaseService] Error fetching game history: $e');
      return [];
    }
  }

  // ==========================================
  // SAVED GAME (Ván cờ chơi dở)
  // ==========================================

  /// Lưu ván cờ đang chơi dở lên Cloud Firestore
  static Future<void> saveCurrentGame(String userId, BoardState? state) async {
    if (!_initialized) return;
    try {
      final docRef = _firestore.collection('saved_games').doc(userId);
      if (state == null || state.isCompleted) {
        await docRef.delete();
      } else {
        final data = state.toMap();
        data['userId'] = userId;
        data['updatedAt'] = FieldValue.serverTimestamp();
        await docRef.set(data);
      }
    } catch (e) {
      debugPrint('[FirebaseService] Error saving current game: $e');
    }
  }

  /// Tải ván cờ đang chơi dở từ Cloud Firestore
  static Future<BoardState?> fetchSavedGame(String userId) async {
    if (!_initialized) return null;
    try {
      final doc = await _firestore.collection('saved_games').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return BoardState.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('[FirebaseService] Error fetching saved game: $e');
    }
    return null;
  }

  // ==========================================
  // ONLINE LEADERBOARD (BẢNG XẾP HẠNG THỜI GIAN THỰC)
  // ==========================================

  /// Lắng nghe dữ liệu Bảng xếp hạng online realtime từ Firestore
  static Stream<List<Map<String, dynamic>>> streamLeaderboard({int limit = 20}) {
    if (!_initialized) {
      return Stream.value([]);
    }
    return _firestore
        .collection('users')
        .orderBy('totalExp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Lấy danh sách Bảng xếp hạng online một lần
  static Future<List<Map<String, dynamic>>> fetchLeaderboard({int limit = 20}) async {
    if (!_initialized) return [];
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('totalExp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('[FirebaseService] Error fetching leaderboard: $e');
      return [];
    }
  }
}
