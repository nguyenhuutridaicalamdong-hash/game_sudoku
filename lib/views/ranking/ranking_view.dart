import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../providers/ranking_provider.dart';
import '../../services/audio_service.dart';

class RankingView extends StatelessWidget {
  const RankingView({super.key});

  @override
  Widget build(BuildContext context) {
    final rankingProvider = context.watch<RankingProvider>();
    final players = rankingProvider.players;
    final activeTab = rankingProvider.activeTab;

    // Lần đầu mở tab thì tải dữ liệu
    if (!rankingProvider.hasData && !rankingProvider.isLoading && rankingProvider.error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => rankingProvider.refresh());
    }

    return RefreshIndicator(
      onRefresh: rankingProvider.refresh,
      child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // League Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.berryGradient,
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
                        const Icon(Icons.emoji_events_rounded, color: AppColors.yellow, size: 30),
                        const SizedBox(width: 8),
                        Text(
                          'Bảng xếp hạng',
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
                        color: AppColors.surface.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Kéo xuống để làm mới',
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
                  'Xếp theo tổng điểm các ván đã giải. Cấp càng khó, giải càng nhanh, càng ít lỗi thì càng nhiều điểm!',
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
              color: AppColors.surface.withOpacity(0.7),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                _buildTabButton('week', 'Tuần này', activeTab, rankingProvider),
                _buildTabButton('month', 'Tháng này', activeTab, rankingProvider),
                _buildTabButton('all', 'Mọi lúc', activeTab, rankingProvider),
              ],
            ),
          ),

          const SizedBox(height: 14),

          if (rankingProvider.isLoading && players.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (rankingProvider.error != null && players.isEmpty)
            _buildMessage(rankingProvider.error!, onRetry: rankingProvider.refresh)
          else if (players.isEmpty)
            _buildMessage('Chưa có ai ghi điểm trong khoảng thời gian này. Hãy là người đầu tiên!')
          else
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
      ),
    );
  }

  Widget _buildMessage(String text, {Future<void> Function()? onRetry}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
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
            gradient: isSelected ? AppColors.sunsetGradient : null,
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
                color: isSelected ? Colors.white : AppColors.textSecondary,
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
      rankColor = const Color(0xFF8A8FB0);
    } else if (player.rank == 3) {
      rankColor = AppColors.amberDark;
    } else {
      rankColor = AppColors.textSecondary;
    }

    const podium = [
      LinearGradient(colors: [Color(0xFFFFF6D6), Color(0xFFFFD86B)]), // vàng
      LinearGradient(colors: [Color(0xFFF4F6FA), Color(0xFFD5DBE6)]), // bạc
      LinearGradient(colors: [Color(0xFFFFEBDD), Color(0xFFF5B489)]), // đồng
    ];
    final rowGradient = player.rank <= 3 ? podium[player.rank - 1] : null;
    final medal = player.rank == 1
        ? '🥇'
        : player.rank == 2
            ? '🥈'
            : player.rank == 3
                ? '🥉'
                : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: rowGradient,
        color: rowGradient != null ? null : (player.isCurrentUser ? AppColors.primarySoft : AppColors.surface.withOpacity(0.92)),
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
                  medal ?? '${player.rank}',
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
                backgroundColor: player.isCurrentUser ? AppColors.primary : AppColors.primarySoft,
                child: Text(
                  player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    color: player.isCurrentUser ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.isCurrentUser ? '${player.name} (Bạn)' : player.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '🔥 ${player.streak} ngày • ${player.gamesWon} ván thắng',
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
                '${player.score}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'ĐIỂM',
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
