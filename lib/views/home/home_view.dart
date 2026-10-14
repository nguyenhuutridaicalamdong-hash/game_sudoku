import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../models/difficulty.dart';
import '../../providers/game_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/audio_service.dart';
import '../../widgets/tactile_button.dart';

class HomeView extends StatefulWidget {
  final VoidCallback onNavigateToPlay;

  const HomeView({super.key, required this.onNavigateToPlay});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _tipIndex = 0;

  static const _proTips = [
    "Scanning rows with 7+ solved numbers speeds up pencil notes.",
    "Cross-hatching 3x3 blocks is the fastest way to spot hidden singles.",
    "Turn Notes ON to track candidate numbers when two possibilities remain.",
    "Check columns where only two digits are missing to eliminate guesses.",
    "Look for pairs of candidates in the same block to lock numbers in place.",
  ];

  void _cycleTip() {
    AudioService.playTap();
    setState(() {
      _tipIndex = (_tipIndex + 1) % _proTips.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final gameProvider = context.watch<GameProvider>();
    final stats = userProvider.stats;
    final savedGame = gameProvider.savedGame;

    final resumeProgress = savedGame != null
        ? ((savedGame.cells.where((c) => c.value != null && !c.isError).length / 81) * 100).round()
        : 65;

    final resumeDiffLabel = savedGame != null ? savedGame.difficulty.label : 'Medium';

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Greeting & Streak Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primarySoft,
                    backgroundImage: NetworkImage(stats.avatarUrl),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Hi, ${stats.playerName} 👋',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Streak Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.amberContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.amberBorder.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.amber.withOpacity(0.25),
                      offset: const Offset(0, 3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '${stats.streakDays} DAYS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.amberText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Warm Hero Card Sanctuary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.borderMedium.withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  offset: const Offset(0, 16),
                  blurRadius: 36,
                ),
              ],
            ),
            child: Column(
              children: [
                // Mindful Logic badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderMedium.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.spa_rounded, color: AppColors.mintDark, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'MINDFUL LOGIC',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.mintDark,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3D Sudoku Puzzle Tile Showcase (3x3 grid)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.12),
                        offset: const Offset(0, 12),
                        blurRadius: 28,
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: 156,
                    height: 156,
                    child: GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildHeroTile('3', const Color(0xFFE2E7FF), AppColors.primary),
                        _buildHeroTile('7', AppColors.amber, Colors.white, isAccent: true),
                        _buildHeroTile('9', const Color(0xFFE2E7FF), AppColors.textSecondary),
                        _buildHeroIconTile(Icons.extension_rounded, AppColors.primaryLight),
                        _buildHeroTile('5', const Color(0xFFEAEDFF), AppColors.primary),
                        _buildHeroTile('1', const Color(0xFFE2E7FF), AppColors.textSecondary),
                        _buildHeroTile('4', const Color(0xFFE2E7FF), AppColors.textSecondary),
                        _buildHeroTile('8', const Color(0xFFEAEDFF), AppColors.primary),
                        _buildHeroTile('2', AppColors.mint, AppColors.mintDeep),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Ready for a puzzle?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Relax your mind, one number at a time',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 20),

                // Giant 3D 'PLAY NOW' Button
                TactileButton(
                  onPressed: () {
                    gameProvider.startGame(Difficulty.medium);
                  },
                  backgroundColor: AppColors.primary,
                  shadowColor: AppColors.primaryDark,
                  height: 60,
                  depth: 6,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'PLAY NOW',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Two Quick Action Cards: Daily Challenge & Continue
          Row(
            children: [
              // Daily Quest Card
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    AudioService.playTap();
                    gameProvider.startGame(Difficulty.daily);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    height: 146,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.06),
                          offset: const Offset(0, 8),
                          blurRadius: 20,
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
                              decoration: const BoxDecoration(
                                color: AppColors.amberContainer,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.calendar_today_rounded, color: AppColors.amberDark, size: 18),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.amber.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'TODAY',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.amberDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Quest',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Special Challenge',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'EARN TROPHY',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.amberDark,
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.amberDark, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Continue / Resume Card
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    AudioService.playTap();
                    if (savedGame != null) {
                      gameProvider.resumeGame();
                    } else {
                      gameProvider.startGame(Difficulty.medium);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    height: 146,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.06),
                          offset: const Offset(0, 8),
                          blurRadius: 20,
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
                              decoration: const BoxDecoration(
                                color: AppColors.primarySoft,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.fast_forward_rounded, color: AppColors.primary, size: 18),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'RESUME',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Continue',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Classic • $resumeDiffLabel',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'PROGRESS',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  '$resumeProgress%',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: resumeProgress / 100,
                                minHeight: 6,
                                backgroundColor: AppColors.primarySoft,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Pro Tip Pill (Interactive)
          GestureDetector(
            onTap: _cycleTip,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.04),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.mint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lightbulb_rounded, color: AppColors.mintDeep, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PRO TIP (TAP TO CYCLE)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.mintDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          _proTips[_tipIndex],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
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

          const SizedBox(height: 12),

          // Browse All Difficulties Button
          ElevatedButton.icon(
            onPressed: () {
              AudioService.playTap();
              widget.onNavigateToPlay();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            icon: const Icon(Icons.tune_rounded, size: 18),
            label: Text(
              'Browse All Difficulty Levels',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroTile(String text, Color bg, Color textColor, {bool isAccent = false}) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isAccent
            ? [
                BoxShadow(
                  color: bg.withOpacity(0.4),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroIconTile(IconData icon, Color bg) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: bg.withOpacity(0.4),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
