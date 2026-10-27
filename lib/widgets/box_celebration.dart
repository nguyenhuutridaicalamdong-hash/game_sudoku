import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Loại vùng vừa hoàn thành.
enum CelebrationKind { box, row, column }

/// Hiệu ứng khi hoàn thành 1 khối 3x3 / 1 hàng ngang / 1 cột dọc:
/// vùng đó sáng lên, sao bung ra, chữ khen nảy lên rồi mờ dần.
/// Đặt chồng lên đúng vị trí vùng trên bàn cờ.
class BoxCelebration extends StatefulWidget {
  final String message; // rỗng = không hiện chữ
  final CelebrationKind kind;

  const BoxCelebration({super.key, required this.message, this.kind = CelebrationKind.box});

  @override
  State<BoxCelebration> createState() => _BoxCelebrationState();
}

class _BoxCelebrationState extends State<BoxCelebration> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _sparkles = ['✨', '⭐', '🌟', '💫', '✨', '⭐', '🌟', '💖', '✨'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBox = widget.kind == CelebrationKind.box;
    final isRow = widget.kind == CelebrationKind.row;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          if (t >= 1) return const SizedBox.shrink();

          // Độ sáng: bùng lên nhanh rồi tắt dần
          final glow = t < 0.15 ? t / 0.15 : (1 - (t - 0.15) / 0.85);
          // Chữ nảy: phóng to vượt mức rồi về 1
          final textScale = Curves.elasticOut.transform((t * 1.6).clamp(0.0, 1.0));
          final textOpacity = t < 0.75 ? 1.0 : (1 - (t - 0.75) / 0.25);
          final spread = Curves.easeOut.transform(t);

          return LayoutBuilder(
            builder: (context, size) {
              final w = size.maxWidth;
              final h = size.maxHeight;

              // Nền phát sáng: khối dùng vòng xoay cầu vồng, hàng/cột dùng dải quét
              final Gradient glowGradient = isBox
                  ? SweepGradient(
                      colors: [...AppColors.rainbow, AppColors.rainbow.first],
                      transform: GradientRotation(t * 2 * pi),
                    )
                  : LinearGradient(
                      begin: isRow ? Alignment.centerLeft : Alignment.topCenter,
                      end: isRow ? Alignment.centerRight : Alignment.bottomCenter,
                      colors: [
                        AppColors.rainbow[0].withOpacity(0.0),
                        ...AppColors.rainbow,
                        AppColors.rainbow[3].withOpacity(0.0),
                      ],
                      // Dải sáng chạy từ đầu này sang đầu kia
                      transform: _SlideGradient(t, isRow),
                    );

              final n = isBox ? 8 : _sparkles.length;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: (glow * (isBox ? 0.75 : 0.85)).clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: glowGradient,
                          border: Border.all(color: Colors.white, width: isBox ? 3 : 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.yellow.withOpacity((0.8 * glow).clamp(0.0, 1.0)),
                              blurRadius: isBox ? 24 : 14,
                              spreadRadius: isBox ? 4 : 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Sao: khối thì bung tròn từ tâm, hàng/cột thì bay ra 2 bên dọc theo đường
                  for (int i = 0; i < n; i++)
                    Positioned(
                      left: isBox
                          ? w / 2 - 10 + cos(i * 2 * pi / n) * w * 0.55 * spread
                          : isRow
                              ? (i + 0.5) / n * w - 10
                              : w / 2 - 10 + (i.isEven ? -1 : 1) * w * 1.1 * spread,
                      top: isBox
                          ? h / 2 - 10 + sin(i * 2 * pi / n) * h * 0.55 * spread
                          : isRow
                              ? h / 2 - 10 + (i.isEven ? -1 : 1) * h * 1.1 * spread
                              : (i + 0.5) / n * h - 10,
                      child: Opacity(
                        opacity: (1 - t).clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: 0.6 + t,
                          child: Text(_sparkles[i], style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),

                  // Chữ khen
                  if (widget.message.isNotEmpty)
                    Center(
                      child: Opacity(
                        opacity: textOpacity.clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: textScale,
                          // Cột dọc hẹp → xoay chữ theo chiều dọc cho vừa
                          child: RotatedBox(
                            quarterTurns: widget.kind == CelebrationKind.column ? 3 : 0,
                            child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.pink.withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Text(
                              widget.message,
                              maxLines: 1,
                              softWrap: false,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.pink,
                              ),
                            ),
                          ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Dịch gradient theo thời gian để tạo dải sáng chạy dọc hàng/cột.
class _SlideGradient extends GradientTransform {
  final double t;
  final bool horizontal;

  const _SlideGradient(this.t, this.horizontal);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final shift = (t * 2 - 1) * (horizontal ? bounds.width : bounds.height);
    return horizontal ? Matrix4.translationValues(shift, 0, 0) : Matrix4.translationValues(0, shift, 0);
  }
}
