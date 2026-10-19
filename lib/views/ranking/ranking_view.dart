import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../providers/ranking_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/audio_service.dart';

class RankingView extends StatelessWidget {
  const RankingView({super.key});

  @override
  Widget build(BuildContext context) {
    final rankingProvider = context.watch<RankingProvider>();
    final userProvider = context.watch<UserProvider>();
    final players = rankingProvider.getLeaderboard(userProvider);
    final activeTab = rankingProvider.activeTab;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // League Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  offset: const Offset(0, 10),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.emoji_events_rounded, color: AppColors.amber, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          'Master League',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Ends in 2d 14h',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Top 3 players advance to Diamond League and earn rare golden avatars!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3 Filter Tabs: This Week, All Time, Friends
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                _buildTabButton('weekly', 'This Week', activeTab, rankingProvider),
                _buildTabButton('allTime', 'All Time', activeTab, rankingProvider),
                _buildTabButton('friends', 'Friends', activeTab, rankingProvider),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Leaderboard Players List
          Column(
            children: players.map((player) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildPlayerRow(player),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tabId, String label, String currentTab, RankingProvider provider) {
    final isSelected = (currentTab == tabId);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          AudioService.playTap();
          provider.setActiveTab(tabId);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      offset: const Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerRow(LeaderboardPlayer player) {
    Color rankColor;
    if (player.rank == 1) {
      rankColor = AppColors.amber;
    } else if (player.rank == 2) {
      rankColor = const Color(0xFF767586);
    } else if (player.rank == 3) {
      rankColor = AppColors.amberDark;
    } else {
      rankColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: player.isCurrentUser ? AppColors.primarySoft : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: player.isCurrentUser ? AppColors.primary : AppColors.borderLight,
          width: player.isCurrentUser ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(player.isCurrentUser ? 0.08 : 0.03),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '${player.rank}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: rankColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(player.avatar),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '🔥 ${player.streak}d streak • ${player.badge}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${player.exp}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'EXP',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
