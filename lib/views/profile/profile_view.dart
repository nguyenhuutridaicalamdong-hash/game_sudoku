import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../models/difficulty.dart';
import '../../providers/user_provider.dart';
import '../../services/audio_service.dart';
import '../../services/sudoku_generator.dart';
import '../history/history_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

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
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderLight),
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
                  backgroundColor: AppColors.primarySoft,
                  backgroundImage: NetworkImage(stats.avatarUrl),
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
                                Text(
                                  stats.playerName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.edit_rounded, size: 14, color: AppColors.primary),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.amberContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'LVL ${stats.level}',
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
                        'Mindful Logic Enthusiast',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: stats.levelProgress,
                          minHeight: 6,
                          backgroundColor: AppColors.borderLight,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
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
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            'NEXT LVL: ${(stats.level * 250)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
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
              _buildStatHighlightCard('${stats.puzzlesCompleted}', 'SOLVED', AppColors.primary),
              const SizedBox(width: 10),
              _buildStatHighlightCard('${stats.zeroMistakeGames}', 'FLAWLESS', AppColors.mintDark),
              const SizedBox(width: 10),
              _buildStatHighlightCard('🔥 ${stats.streakDays}d', 'STREAK', AppColors.amber),
            ],
          ),

          const SizedBox(height: 14),

          // Personal Best Times Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
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
                      'Personal Best Times',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildBestTimeTile('Easy', stats.bestTimes[Difficulty.easy], AppColors.mintContainer, AppColors.mintDark),
                    const SizedBox(width: 8),
                    _buildBestTimeTile('Medium', stats.bestTimes[Difficulty.medium], AppColors.primarySoft, AppColors.primary),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildBestTimeTile('Hard', stats.bestTimes[Difficulty.hard], AppColors.amberContainer, AppColors.amberDark),
                    const SizedBox(width: 8),
                    _buildBestTimeTile('Expert', stats.bestTimes[Difficulty.expert], AppColors.surfaceTint, const Color(0xFF03006D)),
                  ],
                ),
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
              backgroundColor: Colors.white,
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
                  'View Match History',
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
              color: Colors.white,
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
                      'Gameplay Preferences',
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
                  title: 'Tactile Sound FX',
                  subtitle: 'Soothing audio chime clicks',
                  value: stats.soundEnabled,
                  onChanged: (_) => userProvider.toggleSound(),
                ),
                _buildPreferenceSwitch(
                  title: 'Haptic Vibration',
                  subtitle: 'Tactile tap pushback on supported devices',
                  value: stats.hapticsEnabled,
                  onChanged: (_) => userProvider.toggleHaptics(),
                ),
                _buildPreferenceSwitch(
                  title: 'Auto-remove Pencil Notes',
                  subtitle: 'Erase peer candidates when solved',
                  value: stats.autoRemoveNotes,
                  onChanged: (_) => userProvider.toggleAutoRemoveNotes(),
                ),
                _buildPreferenceSwitch(
                  title: 'Highlight Row, Column & Block',
                  subtitle: 'Soft periwinkle peer wash',
                  value: stats.highlightPeers,
                  onChanged: (_) => userProvider.toggleHighlightPeers(),
                ),
                _buildPreferenceSwitch(
                  title: 'Highlight Matching Digits',
                  subtitle: 'Highlight all occurrences of active number',
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
              onPressed: () => _showResetDialog(context, userProvider),
              child: Text(
                'Reset Statistics & Game Data',
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

  Widget _buildStatHighlightCard(String value, String label, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.04),
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
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestTimeTile(String label, int? seconds, Color bg, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
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
            activeColor: AppColors.primary,
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
            'Edit Player Name',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter your name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                provider.setPlayerName(controller.text);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showResetDialog(BuildContext context, UserProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Reset Data?',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              color: AppColors.error,
            ),
          ),
          content: Text(
            'This will clear your puzzles solved, EXP, best times, and game history. Are you sure?',
            style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                provider.resetAllData();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Reset Everything'),
            ),
          ],
        );
      },
    );
  }
}
