import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../models/difficulty.dart';
import '../../providers/game_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/audio_service.dart';
import '../../services/sudoku_generator.dart';
import '../../widgets/colorful_background.dart';
import '../../widgets/tactile_button.dart';
import '../minigames/minigames_hub_view.dart';

class HomeView extends StatefulWidget {
  final VoidCallback onNavigateToPlay;

  const HomeView({super.key, required this.onNavigateToPlay});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _tipIndex = 0;

  static const _proTips = [
    'Quét các hàng đã có từ 7 số trở lên để điền nhanh hơn.',
    'Dò chéo từng khối 3x3 là cách nhanh nhất tìm ô chỉ có 1 khả năng.',
    'Bật Ghi chú để đánh dấu các số có thể điền khi còn phân vân.',
    'Xem các cột chỉ còn thiếu 2 số để loại trừ, khỏi phải đoán.',
    'Tìm cặp số ứng viên trong cùng 1 khối để khóa vị trí của chúng.',
  ];

  void _cycleTip() {
    AudioService.playTap();
    setState(() => _tipIndex = (_tipIndex + 1) % _proTips.length);
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Chào buổi sáng ☀️';
    if (h < 14) return 'Chào buổi trưa 🌤️';
    if (h < 18) return 'Chào buổi chiều 🌈';
    return 'Chào buổi tối 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final gameProvider = context.watch<GameProvider>();
    final stats = userProvider.stats;
    final savedGame = gameProvider.savedGame;

    final resumeProgress = savedGame != null
        ? ((savedGame.cells.where((c) => c.value != null && !c.isError).length / 81) * 100).round()
        : 0;
    final resumeDiffLabel = savedGame != null ? savedGame.difficulty.label : 'Trung bình';

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ===== Lời chào + chuỗi ngày =====
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  gradient: AppColors.rainbowGradient,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.surfaceVariant,
                  child: Text(
                    stats.playerName.isNotEmpty ? stats.playerName[0].toUpperCase() : '?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.pink,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Xin chào, ${stats.playerName} 👋',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  gradient: AppColors.sunsetGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.amber.withOpacity(0.45),
                      offset: const Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Text(
                  '🔥 ${stats.streakDays} NGÀY',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ===== 3 ô thống kê nhanh =====
          Row(
            children: [
              _buildMiniStat('⭐', '${stats.totalScore}', 'Điểm', AppColors.primaryGradient),
              const SizedBox(width: 8),
              _buildMiniStat('🏆', '${stats.puzzlesCompleted}', 'Đã giải', AppColors.oceanGradient),
              const SizedBox(width: 8),
              _buildMiniStat('🎯', 'Lv ${stats.level}', 'Cấp độ', AppColors.limeGradient),
            ],
          ),

          const SizedBox(height: 14),

          // ===== Thẻ chính cầu vồng =====
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: AppColors.rainbowGradient,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  offset: const Offset(0, 14),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.93),
                borderRadius: BorderRadius.circular(29),
              ),
              child: Column(
                children: [
                  // Bàn cờ mini 3x3 nhiều màu
                  SizedBox(
                    width: 168,
                    height: 168,
                    child: GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (final d in const [3, 7, 9, 0, 5, 1, 4, 8, 2])
                          d == 0
                              ? _buildHeroIconTile()
                              : _buildHeroTile(d),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  RainbowText(
                    savedGame != null ? 'Ván đang chờ bạn!' : 'Sẵn sàng giải đố chưa?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    savedGame != null
                        ? 'Bạn đang giải dở 1 ván, chơi tiếp nhé 💪'
                        : 'Thư giãn đầu óc, từng con số một ✨',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 18),

                  if (savedGame != null) ...[
                    // ===== CÓ VÁN DỞ: nút CHƠI TIẾP là nút chính =====
                    TactileButton(
                      onPressed: () => gameProvider.resumeGame(),
                      backgroundColor: AppColors.mintDark,
                      shadowColor: const Color(0xFF047857),
                      height: 76,
                      depth: 6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 36),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CHƠI TIẾP',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '$resumeDiffLabel • $resumeProgress% • ⏱ ${SudokuGenerator.formatTime(savedGame.timeSeconds)}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withOpacity(0.95),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: resumeProgress / 100,
                        minHeight: 8,
                        backgroundColor: AppColors.mintContainer,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.mint),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Nút ván mới: nhỏ, viền, tách riêng + hỏi lại trước khi bỏ ván dở
                    OutlinedButton.icon(
                      onPressed: () {
                        AudioService.playTap();
                        _confirmDiscardThen(context, () {
                          gameProvider.clearSavedGame();
                          widget.onNavigateToPlay();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.pink,
                        side: const BorderSide(color: AppColors.pink, width: 1.5),
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: Text(
                        'Bỏ ván này, chơi ván mới',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ] else
                    // ===== KHÔNG CÓ VÁN DỞ: nút CHƠI NGAY =====
                    TactileButton(
                      onPressed: () => gameProvider.startGame(Difficulty.medium),
                      backgroundColor: AppColors.pink,
                      shadowColor: AppColors.pinkDark,
                      height: 60,
                      depth: 6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
                          const SizedBox(width: 6),
                          Text(
                            'CHƠI NGAY',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('🎮', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ===== Thử thách ngày + Ván mới =====
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  gradient: Difficulty.daily.gradient,
                  shadowColor: AppColors.amber,
                  icon: Icons.calendar_today_rounded,
                  tag: 'HÔM NAY',
                  title: 'Thử thách ngày',
                  subtitle: 'Cả server chung 1 đề',
                  footer: Text(
                    'NHẬN CÚP 🏆',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    AudioService.playTap();
                    if (savedGame != null) {
                      _confirmDiscardThen(context, () => gameProvider.startGame(Difficulty.daily));
                    } else {
                      gameProvider.startGame(Difficulty.daily);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  gradient: AppColors.primaryGradient,
                  shadowColor: AppColors.primary,
                  icon: Icons.grid_view_rounded,
                  tag: '6 CẤP',
                  title: 'Ván mới',
                  subtitle: 'Chọn từ Dễ đến Cực khó',
                  footer: Text(
                    'CHỌN CẤP ĐỘ ➜',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    AudioService.playTap();
                    widget.onNavigateToPlay();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ===== Góc giải trí (mini game) =====
          GestureDetector(
            onTap: () {
              AudioService.playTap();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MiniGamesHubView()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF38BDF8), Color(0xFFC084FC), Color(0xFFFF6B5B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC084FC).withOpacity(0.4),
                    offset: const Offset(0, 8),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('🎮', style: TextStyle(fontSize: 38)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Góc giải trí',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '4 mini game xả stress: bóp bóng, lật thẻ, bấm số, cờ caro',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.92),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text('🫧🃏⚡', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ===== Mẹo chơi =====
          GestureDetector(
            onTap: _cycleTip,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: AppColors.limeGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mint.withOpacity(0.4),
                    offset: const Offset(0, 6),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Text('💡', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MẸO HAY (CHẠM ĐỂ XEM TIẾP)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.mintDeep,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _proTips[_tipIndex],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mintDeep,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ===== Xem tất cả cấp độ =====
          GestureDetector(
            onTap: () {
              AudioService.playTap();
              widget.onNavigateToPlay();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    offset: const Offset(0, 6),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.tune_rounded, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Xem tất cả 6 cấp độ',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hỏi lại trước khi bỏ ván đang chơi dở.
  void _confirmDiscardThen(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Bỏ ván đang chơi?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
        content: Text(
          'Ván đang chơi dở sẽ bị xóa và không được tính điểm.',
          style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.mintDark),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<GameProvider>().resumeGame();
            },
            child: const Text('Chơi tiếp ván cũ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onConfirm();
            },
            child: const Text('Bỏ, chơi mới', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String emoji, String value, String label, Gradient gradient) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.35),
              offset: const Offset(0, 5),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required Gradient gradient,
    required Color shadowColor,
    required IconData icon,
    required String tag,
    required String title,
    required String subtitle,
    required Widget footer,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 156,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.4),
              offset: const Offset(0, 8),
              blurRadius: 18,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: shadowColor,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.92),
                  ),
                ),
              ],
            ),
            footer,
          ],
        ),
      ),
    );
  }

  Widget _buildHeroTile(int digit) {
    final color = AppColors.digitColor(digit);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.45),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$digit',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroIconTile() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.rainbowGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(child: Text('🧩', style: TextStyle(fontSize: 24))),
    );
  }
}
