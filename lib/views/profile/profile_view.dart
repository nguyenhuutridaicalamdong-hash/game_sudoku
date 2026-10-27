import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../models/difficulty.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ranking_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/audio_service.dart';
import '../../services/sudoku_generator.dart';
import '../history/history_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  static const List<Difficulty> _bestTimeLevels = Difficulty.playable;

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final stats = userProvider.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.berryGradient,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.glossEdge, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.06),
                  offset: const Offset(0, 8),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.surfaceVariant,
                  child: Text(
                    stats.playerName.isNotEmpty ? stats.playerName[0].toUpperCase() : '?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.pink,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => _showEditNameDialog(context, userProvider),
                            child: Row(
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 150),
                                  child: Text(
                                    stats.playerName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.yellow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'CẤP ${stats.level}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: AppColors.amberDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${stats.username} • ${stats.totalScore} điểm',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: stats.levelProgress,
                          minHeight: 6,
                          backgroundColor: Colors.white.withOpacity(0.35),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.yellow),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'EXP ${stats.totalExp}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'CẤP TIẾP: ${(stats.level * 250)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Highlights 3 Cards Grid: Solved, Flawless, Streak
          Row(
            children: [
              _buildStatHighlightCard('${stats.puzzlesCompleted}', 'ĐÃ GIẢI', AppColors.oceanGradient),
              const SizedBox(width: 10),
              _buildStatHighlightCard('${stats.zeroMistakeGames}', 'KHÔNG LỖI', AppColors.limeGradient),
              const SizedBox(width: 10),
              _buildStatHighlightCard('🔥 ${stats.streakDays}', 'CHUỖI NGÀY', AppColors.sunsetGradient),
            ],
          ),

          const SizedBox(height: 14),

          // Personal Best Times Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.04),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Thời gian tốt nhất',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (int i = 0; i < _bestTimeLevels.length; i += 2) ...[
                  if (i > 0) const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildBestTimeTile(_bestTimeLevels[i].label, stats.bestTimes[_bestTimeLevels[i]],
                          _bestTimeLevels[i].gradient),
                      const SizedBox(width: 8),
                      _buildBestTimeTile(_bestTimeLevels[i + 1].label, stats.bestTimes[_bestTimeLevels[i + 1]],
                          _bestTimeLevels[i + 1].gradient),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Navigation to Match History (Student Requirement)
          ElevatedButton.icon(
            onPressed: () {
              AudioService.playTap();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HistoryView()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceVariant,
              foregroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.borderMedium),
              ),
            ),
            icon: const Icon(Icons.history_rounded, size: 20),
            label: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Xem lịch sử ván chơi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 20),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Gameplay Preferences
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.04),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Cài đặt chơi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildPreferenceSwitch(
                  title: 'Âm thanh',
                  subtitle: 'Tiếng click khi bấm',
                  value: stats.soundEnabled,
                  onChanged: (_) => userProvider.toggleSound(),
                ),
                _buildPreferenceSwitch(
                  title: 'Rung',
                  subtitle: 'Rung nhẹ khi chạm (nếu máy hỗ trợ)',
                  value: stats.hapticsEnabled,
                  onChanged: (_) => userProvider.toggleHaptics(),
                ),
                _buildPreferenceSwitch(
                  title: 'Tự xóa ghi chú',
                  subtitle: 'Xóa ghi chú trùng khi điền đúng số',
                  value: stats.autoRemoveNotes,
                  onChanged: (_) => userProvider.toggleAutoRemoveNotes(),
                ),
                _buildPreferenceSwitch(
                  title: 'Tô sáng hàng, cột, khối',
                  subtitle: 'Tô màu các ô liên quan đến ô đang chọn',
                  value: stats.highlightPeers,
                  onChanged: (_) => userProvider.toggleHighlightPeers(),
                ),
                _buildPreferenceSwitch(
                  title: 'Tô sáng số giống nhau',
                  subtitle: 'Tô tất cả ô có cùng số với ô đang chọn',
                  value: stats.highlightMatchingNumbers,
                  onChanged: (_) => userProvider.toggleHighlightMatchingNumbers(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Reset Data Button
          Center(
            child: TextButton(
              onPressed: () => _showLogoutDialog(context),
              child: Text(
                'Đăng xuất',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatHighlightCard(String value, String label, LinearGradient gradient) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.4),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestTimeTile(String label, int? seconds, LinearGradient gradient) {
    const textColor = Colors.white;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            Text(
              seconds != null ? SudokuGenerator.formatTime(seconds) : '--:--',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.pink,
            onChanged: (v) {
              AudioService.playTap();
              onChanged(v);
            },
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, UserProvider provider) {
    final controller = TextEditingController(text: provider.stats.playerName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Đổi tên hiển thị',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Nhập tên của bạn',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                final error = await provider.setPlayerName(controller.text);
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text(error ?? 'Đã lưu tên mới')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Đăng xuất?',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          ),
          content: Text(
            'Điểm của bạn đã được lưu trên máy chủ. Ván đang chơi dở sẽ bị xóa.',
            style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<RankingProvider>().invalidate();
                context.read<AuthProvider>().logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
    );
  }
}
