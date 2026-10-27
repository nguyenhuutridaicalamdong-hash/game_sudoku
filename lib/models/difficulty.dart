import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 6 cấp độ giống sudoku.com: Dễ → Cực khó (+ Thử thách hằng ngày).
///
/// LƯU Ý: baseScore / parTimeSeconds / computeScore / computeExp phải GIỐNG
/// với backend/SudokuApi/Services/ScoreCalculator.cs
enum Difficulty {
  easy,
  medium,
  hard,
  expert,
  master,
  extreme,
  daily;

  /// Các cấp độ hiển thị ở màn hình chọn cấp độ (không gồm daily).
  static const List<Difficulty> playable = [
    Difficulty.easy,
    Difficulty.medium,
    Difficulty.hard,
    Difficulty.expert,
    Difficulty.master,
    Difficulty.extreme,
  ];

  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'Dễ';
      case Difficulty.medium:
        return 'Trung bình';
      case Difficulty.hard:
        return 'Khó';
      case Difficulty.expert:
        return 'Chuyên gia';
      case Difficulty.master:
        return 'Bậc thầy';
      case Difficulty.extreme:
        return 'Cực khó';
      case Difficulty.daily:
        return 'Thử thách ngày';
    }
  }

  String get badgeText {
    switch (this) {
      case Difficulty.easy:
        return 'Thư giãn';
      case Difficulty.medium:
        return 'Bình thường';
      case Difficulty.hard:
        return 'Thử thách';
      case Difficulty.expert:
        return 'Cao thủ';
      case Difficulty.master:
        return 'Đỉnh cao';
      case Difficulty.extreme:
        return 'Huyền thoại';
      case Difficulty.daily:
        return 'Đặc biệt';
    }
  }

  /// Khoảng số ô cho sẵn (min, max). Càng ít ô cho sẵn càng khó.
  /// Đề luôn được kiểm tra để chỉ có DUY NHẤT 1 lời giải.
  (int, int) get givensRange {
    switch (this) {
      case Difficulty.easy:
        return (38, 40);
      case Difficulty.medium:
        return (32, 34);
      case Difficulty.hard:
        return (28, 30);
      case Difficulty.expert:
        return (26, 27);
      case Difficulty.master:
        return (24, 25);
      case Difficulty.extreme:
        return (22, 23);
      case Difficulty.daily:
        return (30, 32);
    }
  }

  int get baseScore {
    switch (this) {
      case Difficulty.easy:
        return 400;
      case Difficulty.medium:
        return 650;
      case Difficulty.hard:
        return 900;
      case Difficulty.expert:
        return 1200;
      case Difficulty.master:
        return 1500;
      case Difficulty.extreme:
        return 1800;
      case Difficulty.daily:
        return 800;
    }
  }

  /// Thời gian chuẩn (giây): giải nhanh hơn thì được cộng điểm thưởng.
  int get parTimeSeconds {
    switch (this) {
      case Difficulty.easy:
        return 300;
      case Difficulty.medium:
        return 480;
      case Difficulty.hard:
        return 720;
      case Difficulty.expert:
        return 900;
      case Difficulty.master:
        return 1200;
      case Difficulty.extreme:
        return 1500;
      case Difficulty.daily:
        return 600;
    }
  }

  int computeScore({
    required int timeSeconds,
    required int mistakes,
    required int hintsUsed,
    required bool isCompleted,
  }) {
    if (!isCompleted) return 0;
    final timeBonus = (parTimeSeconds - timeSeconds).clamp(0, parTimeSeconds);
    final score = baseScore + timeBonus - mistakes * 80 - hintsUsed * 50;
    return score.clamp(100, 5000);
  }

  static int computeExp({required int mistakes, required bool isCompleted}) {
    if (!isCompleted) return 20;
    return mistakes == 0 ? 150 : 100;
  }

  static Difficulty fromName(String? name) {
    return Difficulty.values.firstWhere(
      (d) => d.name == name,
      orElse: () => Difficulty.medium,
    );
  }

  /// Gradient tươi sáng cho thẻ cấp độ.
  LinearGradient get gradient {
    List<Color> colors;
    switch (this) {
      case Difficulty.easy:
        colors = const [Color(0xFF34D399), Color(0xFF059669)];
        break;
      case Difficulty.medium:
        colors = const [Color(0xFF38BDF8), Color(0xFF2563EB)];
        break;
      case Difficulty.hard:
        colors = const [Color(0xFFFBBF24), Color(0xFFF97316)];
        break;
      case Difficulty.expert:
        colors = const [Color(0xFF818CF8), Color(0xFF4F46E5)];
        break;
      case Difficulty.master:
        colors = const [Color(0xFFC084FC), Color(0xFF9333EA)];
        break;
      case Difficulty.extreme:
        colors = const [Color(0xFFFB7185), Color(0xFFE11D48)];
        break;
      case Difficulty.daily:
        colors = const [Color(0xFFFFC145), Color(0xFFFF8A3D)];
        break;
    }
    return LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight);
  }

  /// Màu nhấn đậm của cấp độ (chữ / viền / icon trên nền sáng).
  Color get mainColor {
    switch (this) {
      case Difficulty.easy:
        return const Color(0xFF059669);
      case Difficulty.medium:
        return const Color(0xFF2563EB);
      case Difficulty.hard:
        return const Color(0xFFEA580C);
      case Difficulty.expert:
        return const Color(0xFF4F46E5);
      case Difficulty.master:
        return const Color(0xFF9333EA);
      case Difficulty.extreme:
        return const Color(0xFFE11D48);
      case Difficulty.daily:
        return const Color(0xFFEA580C);
    }
  }

  Color get cardBgColor => gradient.colors.last;
  Color get textColor => AppColors.textPrimary;
  Color get badgeBgColor => mainColor;
  Color get iconColor => mainColor;

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
      case Difficulty.master:
        return Icons.workspace_premium_rounded;
      case Difficulty.extreme:
        return Icons.bolt_rounded;
      case Difficulty.daily:
        return Icons.calendar_today_rounded;
    }
  }
}
