import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../widgets/colorful_background.dart';

/// Khung chung cho mọi mini game: thanh tiêu đề gradient + nền màu.
class MiniGameScaffold extends StatelessWidget {
  final String title;
  final Gradient gradient;
  final Widget child;
  final List<Widget>? actions;

  const MiniGameScaffold({
    super.key,
    required this.title,
    required this.gradient,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(decoration: BoxDecoration(gradient: gradient)),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: actions,
      ),
      body: ColorfulBackground(
        child: SafeArea(child: child),
      ),
    );
  }
}

/// Ô hiển thị 1 chỉ số nhỏ (thời gian, lượt, kỷ lục...).
class MiniStatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const MiniStatChip({super.key, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.35), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }
}

/// Hộp thoại kết quả dùng chung.
Future<void> showMiniGameResult(
  BuildContext context, {
  required String emoji,
  required String title,
  required String message,
  required VoidCallback onPlayAgain,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 6),
          Text(title, textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
        ],
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            Navigator.of(context).pop();
          },
          child: const Text('Thoát'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            onPlayAgain();
          },
          child: const Text('Chơi lại'),
        ),
      ],
    ),
  );
}
