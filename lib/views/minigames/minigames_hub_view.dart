import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../services/audio_service.dart';
import '../../widgets/colorful_background.dart';
import 'bubble_pop_game.dart';
import 'memory_match_game.dart';
import 'minigame_scaffold.dart';
import 'number_rush_game.dart';
import 'tic_tac_toe_game.dart';

/// Màn hình "Góc giải trí": danh sách các mini game xả stress.
class MiniGamesHubView extends StatelessWidget {
  const MiniGamesHubView({super.key});

  @override
  Widget build(BuildContext context) {
    final games = <_GameInfo>[
      _GameInfo(
        emoji: '🫧',
        title: 'Bóp bóng khí',
        subtitle: 'Bóp tách tách cho đã tay, không thắng không thua',
        gradient: const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF6366F1)]),
        builder: (_) => const BubblePopGame(),
      ),
      _GameInfo(
        emoji: '🃏',
        title: 'Lật thẻ trí nhớ',
        subtitle: 'Tìm 8 cặp hình giống nhau, càng ít lượt càng giỏi',
        gradient: const LinearGradient(colors: [Color(0xFFC084FC), Color(0xFFEC4899)]),
        builder: (_) => const MemoryMatchGame(),
      ),
      _GameInfo(
        emoji: '⚡',
        title: 'Bấm số thần tốc',
        subtitle: 'Bấm lần lượt 1 → 25 nhanh nhất có thể',
        gradient: const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFFF6B5B)]),
        builder: (_) => const NumberRushGame(),
      ),
      _GameInfo(
        emoji: '❌',
        title: 'Cờ caro 3x3',
        subtitle: 'Đấu trí với máy, chế độ Dễ hoặc Khó',
        gradient: const LinearGradient(colors: [Color(0xFF34D399), Color(0xFF059669)]),
        builder: (_) => const TicTacToeGame(),
      ),
    ];

    return MiniGameScaffold(
      title: '🎮 Góc giải trí',
      gradient: AppColors.berryGradient,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: RainbowText(
              'Thư giãn chút nhé!',
              style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Mấy trò nhỏ để xả stress giữa các ván Sudoku',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 18),
          for (final g in games) ...[
            _buildGameCard(context, g),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, _GameInfo g) {
    return GestureDetector(
      onTap: () {
        AudioService.playTap();
        Navigator.of(context).push(MaterialPageRoute(builder: g.builder));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: g.gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: g.gradient.colors.last.withOpacity(0.35),
              offset: const Offset(0, 8),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Text(g.emoji, style: const TextStyle(fontSize: 32)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    g.title,
                    style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    g.subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.92),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 34),
          ],
        ),
      ),
    );
  }
}

class _GameInfo {
  final String emoji;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final WidgetBuilder builder;

  _GameInfo({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.builder,
  });
}
