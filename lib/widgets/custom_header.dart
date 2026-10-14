import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../providers/game_provider.dart';
import '../providers/user_provider.dart';
import '../services/audio_service.dart';

class CustomHeader extends StatelessWidget {
  final int currentTabIndex;
  final Function(int) onTabSelected;

  const CustomHeader({
    super.key,
    required this.currentTabIndex,
    required this.onTabSelected,
  });

  String _getTabName(int index) {
    switch (index) {
      case 0:
        return 'HOME';
      case 1:
        return 'PLAY';
      case 2:
        return 'RANKING';
      case 3:
        return 'PROFILE';
      default:
        return 'HOME';
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final userProvider = context.watch<UserProvider>();
    final inGame = gameProvider.inGame;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.92),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left section: Back button or Logo + Title
          Row(
            children: [
              if (inGame)
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                  splashRadius: 22,
                  onPressed: () {
                    AudioService.playTap();
                    gameProvider.quitGame();
                  },
                )
              else
                Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        offset: const Offset(0, 3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'S',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inGame ? 'Game Board' : 'Sudoku',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (!inGame)
                    Text(
                      _getTabName(currentTabIndex),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Right section: Sound Toggle & Profile Button
          Row(
            children: [
              IconButton(
                icon: Icon(
                  userProvider.stats.soundEnabled
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceVariant,
                ),
                onPressed: () {
                  AudioService.playTap();
                  userProvider.toggleSound();
                },
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  AudioService.playTap();
                  onTabSelected(3); // Profile tab
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
