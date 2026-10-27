import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../models/difficulty.dart';
import '../../providers/game_provider.dart';
import '../../services/audio_service.dart';
import '../../services/sudoku_generator.dart';
import '../../widgets/colorful_background.dart';

class PlayView extends StatelessWidget {
  const PlayView({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final savedGame = gameProvider.savedGame;

    const difficulties = Difficulty.playable;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header Intro Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surfaceTint,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderMedium.withOpacity(0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back_ios_new_rounded, size: 12, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'CHẾ ĐỘ CỔ ĐIỂN',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          RainbowText(
            'Chọn cấp độ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            '6 cấp độ từ Dễ đến Cực khó',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 16),

          // Dải "Chơi tiếp" khi đang có ván dở
          if (savedGame != null) ...[
            GestureDetector(
              onTap: () {
                AudioService.playTap();
                gameProvider.resumeGame();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.mintDark,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.mint, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mintDark.withOpacity(0.4),
                      offset: const Offset(0, 6),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 34),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CHƠI TIẾP VÁN ĐANG DỞ',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Cấp ${savedGame.difficulty.label} • ⏱ ${SudokuGenerator.formatTime(savedGame.timeSeconds)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'hoặc chọn cấp độ để chơi ván mới:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
          ] else
            const SizedBox(height: 4),

          // Difficulty Cards Vertical Stack
          Column(
            children: difficulties.map((diff) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildDifficultyCard(context, diff, () {
                  AudioService.playTap();
                  if (gameProvider.savedGame != null) {
                    _confirmNewGame(context, gameProvider, diff);
                  } else {
                    gameProvider.startGame(diff);
                  }
                }),
              );
            }).toList(),
          ),

          const SizedBox(height: 10),

          // Subtle Bottom Reminder
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_rounded, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                'Điểm được lưu vào tài khoản của bạn',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Đang có ván dở mà bấm chơi cấp khác → hỏi lại cho chắc.
  void _confirmNewGame(BuildContext context, GameProvider gameProvider, Difficulty diff) {
    final saved = gameProvider.savedGame!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Bạn đang có ván dở', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
        content: Text(
          'Ván "${saved.difficulty.label}" chưa chơi xong. Bắt đầu ván "${diff.label}" mới thì ván cũ sẽ bị bỏ.',
          style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.mintDark),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              gameProvider.resumeGame();
            },
            child: const Text('Chơi tiếp ván cũ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              gameProvider.startGame(diff);
            },
            child: Text('Chơi ${diff.label}', style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyCard(BuildContext context, Difficulty diff, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 108,
        decoration: BoxDecoration(
          gradient: diff.gradient,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.glossEdge, width: 2),
          boxShadow: [
            BoxShadow(
              color: diff.mainColor.withOpacity(0.45),
              offset: const Offset(0, 8),
              blurRadius: 18,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Watermark Big Icon in Background
            Positioned(
              right: -10,
              top: -15,
              child: Opacity(
                opacity: 0.18,
                child: Icon(
                  diff.icon,
                  size: 130,
                  color: Colors.white,
                ),
              ),
            ),

            // Card Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Rounded Square Icon Container
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              offset: const Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          diff.icon,
                          color: diff.iconColor,
                          size: 30,
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Badge & Title
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              diff.badgeText,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: diff.mainColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            diff.label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${diff.givensRange.$1}-${diff.givensRange.$2} ô gợi ý • ${diff.baseScore} điểm',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.92),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Circle Play Button
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: diff.mainColor,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
