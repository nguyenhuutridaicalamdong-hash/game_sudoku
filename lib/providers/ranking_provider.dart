import 'dart:async';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'user_provider.dart';

class LeaderboardPlayer {
  final int rank;
  final String name;
  final String avatar;
  final int exp;
  final int streak;
  final String badge;
  final bool isCurrentUser;

  LeaderboardPlayer({
    required this.rank,
    required this.name,
    required this.avatar,
    required this.exp,
    required this.streak,
    required this.badge,
    this.isCurrentUser = false,
  });
}

class RankingProvider extends ChangeNotifier {
  String _activeTab = 'weekly'; // 'weekly', 'allTime', 'friends'
  List<Map<String, dynamic>> _cloudPlayers = [];
  StreamSubscription? _leaderboardSub;

  String get activeTab => _activeTab;

  RankingProvider() {
    _initLeaderboardStream();
  }

  void _initLeaderboardStream() {
    try {
      _leaderboardSub = FirebaseService.streamLeaderboard(limit: 20).listen(
        (players) {
          _cloudPlayers = players;
          notifyListeners();
        },
        onError: (err) {
          debugPrint('[RankingProvider] Leaderboard stream error: $err');
        },
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _leaderboardSub?.cancel();
    super.dispose();
  }

  void setActiveTab(String tab) {
    _activeTab = tab;
    notifyListeners();
  }

  List<LeaderboardPlayer> getLeaderboard(UserProvider userProvider) {
    final userStats = userProvider.stats;
    final multiplier = _activeTab == 'weekly' ? 1.0 : _activeTab == 'allTime' ? 2.5 : 0.8;

    // Nếu đã có dữ liệu người chơi thật từ Cloud Firestore
    if (_cloudPlayers.isNotEmpty) {
      final list = <LeaderboardPlayer>[];
      bool userIncluded = false;

      for (int i = 0; i < _cloudPlayers.length; i++) {
        final p = _cloudPlayers[i];
        final id = p['id'] as String? ?? '';
        final isMe = id == userStats.id;
        if (isMe) userIncluded = true;

        final rawExp = (p['totalExp'] as num?)?.toInt() ?? 0;
        final exp = isMe ? userStats.totalExp : (rawExp * multiplier).round();
        final streak = isMe ? userStats.streakDays : ((p['streakDays'] as num?)?.toInt() ?? 1);

        list.add(
          LeaderboardPlayer(
            rank: i + 1,
            name: isMe ? '${userStats.playerName} (You)' : (p['playerName'] as String? ?? 'Player ${i + 1}'),
            avatar: isMe ? userStats.avatarUrl : (p['avatarUrl'] as String? ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=120&q=80'),
            exp: exp,
            streak: streak,
            badge: (i < 2) ? 'Diamond League' : (i < 6) ? 'Master League' : 'Gold League',
            isCurrentUser: isMe,
          ),
        );
      }

      // Nếu người dùng hiện tại chưa có trong danh sách (chưa đạt top), chèn vào vị trí phù hợp
      if (!userIncluded) {
        list.add(
          LeaderboardPlayer(
            rank: list.length + 1,
            name: '${userStats.playerName} (You)',
            avatar: userStats.avatarUrl,
            exp: userStats.totalExp,
            streak: userStats.streakDays,
            badge: 'Master League',
            isCurrentUser: true,
          ),
        );
      }

      return list;
    }

    // Dữ liệu mẫu ban đầu (khi chưa có kết nối mạng hoặc server mới tạo)
    final mockPlayers = [
      LeaderboardPlayer(
        rank: 1,
        name: 'Sophia K.',
        avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=120&q=80',
        exp: (5120 * multiplier).round(),
        streak: 18,
        badge: 'Diamond League',
      ),
      LeaderboardPlayer(
        rank: 2,
        name: 'Kenji Sato',
        avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&q=80',
        exp: (4890 * multiplier).round(),
        streak: 14,
        badge: 'Diamond League',
      ),
      LeaderboardPlayer(
        rank: 3,
        name: 'Elena Rostova',
        avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=120&q=80',
        exp: (4310 * multiplier).round(),
        streak: 12,
        badge: 'Master League',
      ),
      LeaderboardPlayer(
        rank: 4,
        name: '${userStats.playerName} (You)',
        avatar: userStats.avatarUrl,
        exp: userStats.totalExp,
        streak: userStats.streakDays,
        badge: 'Master League',
        isCurrentUser: true,
      ),
      LeaderboardPlayer(
        rank: 5,
        name: 'Liam Chen',
        avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=120&q=80',
        exp: (3280 * multiplier).round(),
        streak: 7,
        badge: 'Master League',
      ),
      LeaderboardPlayer(
        rank: 6,
        name: 'Maya Patel',
        avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=120&q=80',
        exp: (3110 * multiplier).round(),
        streak: 9,
        badge: 'Master League',
      ),
      LeaderboardPlayer(
        rank: 7,
        name: 'Marcus Vance',
        avatar: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&w=120&q=80',
        exp: (2940 * multiplier).round(),
        streak: 4,
        badge: 'Gold League',
      ),
    ];

    return mockPlayers;
  }
}
