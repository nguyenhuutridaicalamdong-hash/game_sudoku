import 'package:flutter/material.dart';
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

  String get activeTab => _activeTab;

  void setActiveTab(String tab) {
    _activeTab = tab;
    notifyListeners();
  }

  List<LeaderboardPlayer> getLeaderboard(UserProvider userProvider) {
    final userStats = userProvider.stats;

    // Multipliers for different tabs to create realistic variation
    final multiplier = _activeTab == 'weekly' ? 1.0 : _activeTab == 'allTime' ? 2.5 : 0.8;

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
