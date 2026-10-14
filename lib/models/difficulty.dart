import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum Difficulty {
  easy,
  medium,
  hard,
  expert,
  daily;

  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
      case Difficulty.expert:
        return 'Expert';
      case Difficulty.daily:
        return 'Daily Quest';
    }
  }

  String get badgeText {
    switch (this) {
      case Difficulty.easy:
        return 'Relax';
      case Difficulty.medium:
        return 'Normal';
      case Difficulty.hard:
        return 'Challenge';
      case Difficulty.expert:
        return 'Master';
      case Difficulty.daily:
        return 'Special';
    }
  }

  Color get cardBgColor {
    switch (this) {
      case Difficulty.easy:
        return const Color(0xFF6FFBBE);
      case Difficulty.medium:
        return const Color(0xFFDAE2FD);
      case Difficulty.hard:
        return const Color(0xFFFFDDB8);
      case Difficulty.expert:
        return const Color(0xFFE1E0FF);
      case Difficulty.daily:
        return const Color(0xFFF2F3FF);
    }
  }

  Color get textColor {
    switch (this) {
      case Difficulty.easy:
        return const Color(0xFF002113);
      case Difficulty.medium:
        return const Color(0xFF131B2E);
      case Difficulty.hard:
        return const Color(0xFF2A1700);
      case Difficulty.expert:
        return const Color(0xFF03006D);
      case Difficulty.daily:
        return const Color(0xFF131B2E);
    }
  }

  Color get badgeBgColor {
    switch (this) {
      case Difficulty.easy:
        return const Color(0xFF006847);
      case Difficulty.medium:
        return AppColors.primary;
      case Difficulty.hard:
        return const Color(0xFF855300);
      case Difficulty.expert:
        return const Color(0xFF5B61F4);
      case Difficulty.daily:
        return AppColors.amber;
    }
  }

  Color get iconColor {
    switch (this) {
      case Difficulty.easy:
        return const Color(0xFF006847);
      case Difficulty.medium:
        return AppColors.primary;
      case Difficulty.hard:
        return const Color(0xFF855300);
      case Difficulty.expert:
        return const Color(0xFF5B61F4);
      case Difficulty.daily:
        return AppColors.amber;
    }
  }

  IconData get icon {
    switch (this) {
      case Difficulty.easy:
        return Icons.eco_rounded;
      case Difficulty.medium:
        return Icons.yard_rounded;
      case Difficulty.hard:
        return Icons.local_fire_department_rounded;
      case Difficulty.expert:
        return Icons.hotel_class_rounded;
      case Difficulty.daily:
        return Icons.calendar_today_rounded;
    }
  }
}
