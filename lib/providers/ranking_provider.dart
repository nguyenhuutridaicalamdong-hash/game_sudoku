import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LeaderboardPlayer {
  final int rank;
  final String name;
  final int score;
  final int gamesWon;
  final int streak;
  final bool isCurrentUser;

  LeaderboardPlayer({
    required this.rank,
    required this.name,
    required this.score,
    required this.gamesWon,
    required this.streak,
    this.isCurrentUser = false,
  });

  factory LeaderboardPlayer.fromJson(Map<String, dynamic> json) {
    return LeaderboardPlayer(
      rank: (json['rank'] as num).toInt(),
      name: json['displayName'] as String? ?? 'Người chơi',
      score: (json['score'] as num).toInt(),
      gamesWon: (json['gamesWon'] as num).toInt(),
      streak: (json['streakDays'] as num?)?.toInt() ?? 0,
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
    );
  }
}

/// Bảng xếp hạng lấy từ SQL Server (tổng điểm các ván trong tuần / tháng / mọi lúc).
class RankingProvider extends ChangeNotifier {
  String _activeTab = 'week'; // 'week' | 'month' | 'all'
  final Map<String, List<LeaderboardPlayer>> _cache = {};
  bool _isLoading = false;
  String? _error;

  String get activeTab => _activeTab;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _cache.containsKey(_activeTab);
  List<LeaderboardPlayer> get players => _cache[_activeTab] ?? [];

  void setActiveTab(String tab) {
    _activeTab = tab;
    notifyListeners();
    if (!_cache.containsKey(tab)) refresh();
  }

  Future<void> refresh() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    final tab = _activeTab;
    try {
      final data = await ApiService.leaderboard(period: tab);
      _cache[tab] = data.map(LeaderboardPlayer.fromJson).toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Không tải được bảng xếp hạng';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Xóa dữ liệu cũ (vd. sau khi chơi xong 1 ván hoặc đổi tài khoản).
  void invalidate() {
    _cache.clear();
    notifyListeners();
  }
}
