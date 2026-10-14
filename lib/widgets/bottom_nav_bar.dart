import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../services/audio_service.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.cottage_rounded, 'label': 'Home'},
      {'icon': Icons.play_circle_rounded, 'label': 'Play'},
      {'icon': Icons.emoji_events_rounded, 'label': 'Ranking'},
      {'icon': Icons.account_circle_rounded, 'label': 'Profile'},
    ];

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: AppColors.borderMedium.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            offset: const Offset(0, 10),
            blurRadius: 30,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = (currentIndex == index);
          final item = items[index];

          return GestureDetector(
            onTap: () {
              AudioService.playTap();
              onTabSelected(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryLight : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryLight.withOpacity(0.4),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: 22,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['label'] as String,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
