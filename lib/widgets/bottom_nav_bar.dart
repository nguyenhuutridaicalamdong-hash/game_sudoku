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

  static const _items = [
    (Icons.cottage_rounded, 'Trang chủ', AppColors.primary),
    (Icons.play_circle_rounded, 'Chơi', AppColors.pink),
    (Icons.emoji_events_rounded, 'Xếp hạng', AppColors.amber),
    (Icons.account_circle_rounded, 'Hồ sơ', AppColors.mint),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 14),
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: AppColors.glossEdge, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            offset: const Offset(0, 10),
            blurRadius: 26,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final isSelected = (currentIndex == index);
          final (icon, label, color) = _items[index];

          return GestureDetector(
            onTap: () {
              AudioService.playTap();
              onTabSelected(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut, // không dùng easeOutBack: chạy lố làm bóng đổ âm → lỗi đỏ
              padding: EdgeInsets.symmetric(horizontal: isSelected ? 14 : 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.14) : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.0),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: isSelected ? 26 : 22, color: isSelected ? color : AppColors.textSecondary),
                  const SizedBox(height: 1),
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? color : AppColors.textSecondary,
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
