import 'package:flutter/material.dart';
import '../models/difficulty.dart';
import '../models/game_record.dart';
import '../models/user_stats.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';

/// Thông tin người chơi + điểm. Nguồn dữ liệu chính là SQL Server (qua Web API),
/// SharedPreferences chỉ dùng làm cache để mở app nhanh / chơi khi mất mạng.
class UserProvider extends ChangeNotifier {
  UserStats _stats = UserStats();
  List<GameRecord> _history = [];
  bool _isLoaded = false;
  bool _isSyncing = false;

  UserStats get stats => _stats;
  List<GameRecord> get history => _history;
  bool get isLoaded => _isLoaded;
  bool get isSyncing => _isSyncing;

  late final Future<void> _ready;

  UserProvider() {
    _ready = loadData();
  }

  Future<void> loadData() async {
    _stats = await StorageService.loadUserStats();
    _history = await StorageService.loadGameHistory();
    _syncAudio();
    _isLoaded = true;
    notifyListeners();
  }

  void _syncAudio() {
    AudioService.soundEnabled = _stats.soundEnabled;
    AudioService.hapticsEnabled = _stats.hapticsEnabled;
  }

  // ==========================================
  // ĐĂNG NHẬP / ĐĂNG XUẤT
  // ==========================================

  /// Gọi sau khi đăng nhập/đăng ký thành công hoặc khi mở app còn token.
  Future<void> onLoggedIn(Map<String, dynamic> serverUser) async {
    await _ready; // đợi đọc cache xong để không bị ghi đè
    final newId = serverUser['id'].toString();
    if (_stats.id != newId) {
      // Tài khoản khác → bỏ cache của tài khoản cũ
      _stats = _stats.copySettingsOnly();
      _history = [];
      await StorageService.savePendingGames([]);
      await StorageService.saveGameHistory(_history);
    }
    _stats.applyServerUser(serverUser);
    _save();

    await flushPendingGames();
    await refreshHistory();
  }

  Future<void> onLoggedOut() async {
    await _ready;
    _stats = _stats.copySettingsOnly();
    _history = [];
    await StorageService.savePendingGames([]);
    await StorageService.saveGameHistory(_history);
    _save();
  }

  /// Tải lại thông tin + điểm từ server.
  Future<void> refreshProfile() async {
    try {
      final user = await ApiService.me();
      _stats.applyServerUser(user);
      _save();
    } catch (e) {
      debugPrint('[UserProvider] refreshProfile: $e');
    }
  }

  /// Tải lịch sử ván chơi từ server.
  Future<void> refreshHistory() async {
    try {
      final list = await ApiService.myGames(take: 50);
      _history = list.map(GameRecord.fromServer).toList();
      await StorageService.saveGameHistory(_history);
      notifyListeners();
    } catch (e) {
      debugPrint('[UserProvider] refreshHistory: $e');
    }
  }

  /// Đổi tên hiển thị (lưu vào SQL). Trả về thông báo lỗi nếu có.
  Future<String?> setPlayerName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Tên không được để trống';
    try {
      final user = await ApiService.updateDisplayName(trimmed);
      _stats.applyServerUser(user);
      _save();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  // ==========================================
  // CÀI ĐẶT (chỉ lưu trên máy)
  // ==========================================

  void toggleSound() {
    _stats.soundEnabled = !_stats.soundEnabled;
    _syncAudio();
    _save();
  }

  void toggleHaptics() {
    _stats.hapticsEnabled = !_stats.hapticsEnabled;
    _syncAudio();
    _save();
  }

  void toggleAutoRemoveNotes() {
    _stats.autoRemoveNotes = !_stats.autoRemoveNotes;
    _save();
  }

  void toggleHighlightPeers() {
    _stats.highlightPeers = !_stats.highlightPeers;
    _save();
  }

  void toggleHighlightMatchingNumbers() {
    _stats.highlightMatchingNumbers = !_stats.highlightMatchingNumbers;
    _save();
  }

  // ==========================================
  // LƯU KẾT QUẢ VÁN CHƠI
  // ==========================================

  /// Cập nhật ngay trên máy cho mượt, rồi gửi lên SQL Server.
  /// Nếu mất mạng thì để vào hàng chờ, lần sau gửi lại.
  /// Trả về điểm của ván.
  int recordGameResult({
    required Difficulty difficulty,
    required int timeSeconds,
    required int mistakes,
    int hintsUsed = 0,
    required bool isVictory,
  }) {
    final score = difficulty.computeScore(
      timeSeconds: timeSeconds,
      mistakes: mistakes,
      hintsUsed: hintsUsed,
      isCompleted: isVictory,
    );
    final exp = Difficulty.computeExp(mistakes: mistakes, isCompleted: isVictory);

    // 1. Cập nhật tạm trên máy
    _stats.gamesPlayed += 1;
    _stats.totalExp += exp;
    _stats.totalScore += score;
    if (isVictory) {
      _stats.puzzlesCompleted += 1;
      if (mistakes == 0) _stats.zeroMistakeGames += 1;
      final prevBest = _stats.bestTimes[difficulty];
      if (prevBest == null || timeSeconds < prevBest) {
        _stats.bestTimes[difficulty] = timeSeconds;
      }
    }

    final localRecord = GameRecord(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      dateTime: DateTime.now(),
      difficulty: difficulty,
      timeSeconds: timeSeconds,
      mistakes: mistakes,
      score: score,
      isCompleted: isVictory,
    );
    _history.insert(0, localRecord);
    if (_history.length > 50) _history = _history.sublist(0, 50);
    StorageService.saveGameHistory(_history);
    _save();

    // 2. Gửi lên server
    _submitToServer({
      'difficulty': difficulty.name,
      'timeSeconds': timeSeconds,
      'mistakes': mistakes,
      'hintsUsed': hintsUsed,
      'isCompleted': isVictory,
    }, localRecord.id);

    return score;
  }

  Future<bool> _sendGame(Map<String, dynamic> payload, {String? localRecordId}) async {
    final res = await ApiService.submitGame(
      difficulty: payload['difficulty'] as String,
      timeSeconds: payload['timeSeconds'] as int,
      mistakes: payload['mistakes'] as int,
      hintsUsed: payload['hintsUsed'] as int,
      isCompleted: payload['isCompleted'] as bool,
    );

    _stats.applyServerUser(Map<String, dynamic>.from(res['user'] as Map));
    final serverRecord = GameRecord.fromServer(Map<String, dynamic>.from(res['record'] as Map));
    final idx = localRecordId == null ? -1 : _history.indexWhere((r) => r.id == localRecordId);
    if (idx >= 0) {
      _history[idx] = serverRecord;
      StorageService.saveGameHistory(_history);
    }
    _save();
    return true;
  }

  Future<void> _submitToServer(Map<String, dynamic> payload, String localRecordId) async {
    try {
      await _sendGame(payload, localRecordId: localRecordId);
    } on ApiException catch (e) {
      debugPrint('[UserProvider] submit game failed: $e');
      // Mất mạng / máy chủ lỗi / hết phiên → giữ lại để gửi sau, không để mất điểm
      if (e.isNetworkError || e.isUnauthorized || (e.statusCode ?? 0) >= 500) {
        final pending = await StorageService.loadPendingGames();
        pending.add(payload);
        await StorageService.savePendingGames(pending);
      }
    } catch (e) {
      debugPrint('[UserProvider] submit game error: $e');
    }
  }

  /// Gửi lại các ván chơi lúc mất mạng.
  Future<void> flushPendingGames() async {
    if (_isSyncing) return;
    final pending = await StorageService.loadPendingGames();
    if (pending.isEmpty) return;

    _isSyncing = true;
    final remaining = List<Map<String, dynamic>>.from(pending);
    try {
      while (remaining.isNotEmpty) {
        await _sendGame(remaining.first);
        remaining.removeAt(0);
        await StorageService.savePendingGames(remaining);
      }
    } on ApiException catch (e) {
      debugPrint('[UserProvider] flush pending stopped: $e');
      if (e.statusCode == 400) {
        // Dữ liệu ván bị sai (400) → bỏ ván đó để không kẹt hàng chờ
        if (remaining.isNotEmpty) remaining.removeAt(0);
        await StorageService.savePendingGames(remaining);
      }
    } catch (e) {
      debugPrint('[UserProvider] flush pending error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  void _save() {
    StorageService.saveUserStats(_stats);
    notifyListeners();
  }
}
