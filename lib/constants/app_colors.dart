import 'package:flutter/material.dart';

/// Bộ màu "Bình minh": nền sáng, chủ đạo xanh chàm (indigo),
/// nhấn cam san hô + vàng nắng, xanh ngọc = đúng, đỏ hồng = sai.
///
/// Tên biến giữ như cũ để không phải sửa các màn hình (vd `pink` = cam san hô).
class AppColors {
  // Nền & bề mặt
  static const Color background = Color(0xFFF5F7FF);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFEEF2FF);
  static const Color surfaceTint = Color(0xFFE0E7FF);

  /// Viền mảnh tạo khối cho thẻ trên nền sáng.
  static const Color glossEdge = Color(0x1F4F46E5);

  // Chữ
  static const Color textPrimary = Color(0xFF1E1B4B);
  static const Color textSecondary = Color(0xFF4B5070);
  static const Color textMuted = Color(0xFF8A8FB0);
  static const Color textWhite = Colors.white;

  // Màu chính: xanh chàm
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primarySoft = Color(0xFFEEF2FF);
  static const Color primaryContainer = Color(0xFFE0E7FF);

  // Điểm nhấn: cam san hô
  static const Color pink = Color(0xFFFF6B5B);
  static const Color pinkDark = Color(0xFFD94A3D);
  static const Color pinkSoft = Color(0xFFFFE8E4);

  // Vàng nắng
  static const Color amber = Color(0xFFFFB020);
  static const Color amberDark = Color(0xFFB7791F);
  static const Color amberContainer = Color(0xFFFFF4DB);
  static const Color amberBorder = Color(0xFFFFD27A);
  static const Color amberText = Color(0xFF5C3D00);
  static const Color yellow = Color(0xFFFFC145);

  // Xanh ngọc
  static const Color mint = Color(0xFF10B981);
  static const Color mintDark = Color(0xFF059669);
  static const Color mintDeep = Colors.white; // chữ trên nền xanh ngọc
  static const Color mintContainer = Color(0xFFD1FAE5);

  // Xanh da trời
  static const Color sky = Color(0xFF0EA5E9);
  static const Color skyDark = Color(0xFF0369A1);

  // Lỗi
  static const Color error = Color(0xFFE11D48);
  static const Color errorContainer = Color(0xFFFFE4E6);

  // Ô bàn cờ
  static const Color cellGivenText = Color(0xFF1E1B4B);
  static const Color cellUserText = Color(0xFF059669);
  static const Color cellCorrectText = Color(0xFF059669); // số bạn điền đúng
  static const Color cellSelectedBg = Color(0xFFC7D2FE);
  static const Color cellPeerBg = Color(0xFFEEF2FF);
  static const Color cellSameNumberBg = Color(0xFFFFE9B0);
  static const Color cellErrorBg = Color(0xFFFFE4E6);
  static const Color cellErrorText = Color(0xFFE11D48); // số bạn điền sai
  static const Color cellNotesText = Color(0xFF6366F1);

  // Viền
  static const Color borderLight = Color(0xFFE5E7F5);
  static const Color borderMedium = Color(0xFFCBD2F0);
  static const Color boardThickBorder = Color(0xFF4F46E5);

  // ===== Gradient =====
  /// Chàm → tím → san hô → vàng (chữ tiêu đề, viền bàn cờ, logo).
  static const List<Color> rainbow = [
    Color(0xFF4F46E5),
    Color(0xFF8B5CF6),
    Color(0xFFFF6B5B),
    Color(0xFFFFB020),
  ];

  static const LinearGradient rainbowGradient = LinearGradient(
    colors: rainbow,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Vàng nắng → san hô.
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFFB020), Color(0xFFFF6B5B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Xanh trời → chàm.
  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Xanh ngọc.
  static const LinearGradient limeGradient = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Chàm → tím (thẻ hồ sơ, bảng xếp hạng, thanh tiêu đề lịch sử).
  static const LinearGradient berryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Nền 9 khối 3x3: xen kẽ trắng và xanh chàm rất nhạt.
  static const List<Color> boxPastels = [
    Color(0xFFFFFFFF),
    Color(0xFFF1F3FF),
    Color(0xFFFFFFFF),
    Color(0xFFF1F3FF),
    Color(0xFFFFFFFF),
    Color(0xFFF1F3FF),
    Color(0xFFFFFFFF),
    Color(0xFFF1F3FF),
    Color(0xFFFFFFFF),
  ];

  /// Màu nút số 1-9.
  static const List<Color> digitColors = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFFFF6B5B),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFF14B8A6),
    Color(0xFF0EA5E9),
    Color(0xFF3B82F6),
  ];

  static Color digitColor(int digit) => digitColors[(digit - 1).clamp(0, 8)];
}
