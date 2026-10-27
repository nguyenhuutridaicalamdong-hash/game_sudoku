import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Nền sáng (trước là tối nhám): đen than chuyển nhẹ sang xanh rêu, vài quầng sáng xanh/đồng mờ,
/// một lớp "bóng" chéo rất nhẹ và chữ số chìm.
class ColorfulBackground extends StatefulWidget {
  final Widget child;

  const ColorfulBackground({super.key, required this.child});

  @override
  State<ColorfulBackground> createState() => _ColorfulBackgroundState();
}

class _ColorfulBackgroundState extends State<ColorfulBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _bubbles = [
    // (x, y, bán kính, màu)
    (0.05, 0.08, 150.0, Color(0xFF818CF8)),
    (0.95, 0.20, 160.0, Color(0xFFFF6B5B)),
    (0.85, 0.65, 130.0, Color(0xFFFFC145)),
    (0.10, 0.70, 160.0, Color(0xFF38BDF8)),
    (0.55, 1.00, 180.0, Color(0xFF34D399)),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value * 2 * pi;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(cos(t), sin(t)),
                    end: Alignment(-cos(t), -sin(t)),
                    colors: const [
                      Color(0xFFF5F7FF),
                      Color(0xFFFFF4EE),
                      Color(0xFFF0F9FF),
                      Color(0xFFF5F0FF),
                      Color(0xFFF5F7FF),
                    ],
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, size) {
                    return Stack(
                      children: [
                        for (int i = 0; i < _bubbles.length; i++)
                          Positioned(
                            left: _bubbles[i].$1 * size.maxWidth - _bubbles[i].$3 + sin(t + i) * 18,
                            top: _bubbles[i].$2 * size.maxHeight - _bubbles[i].$3 + cos(t + i * 1.7) * 18,
                            child: Container(
                              width: _bubbles[i].$3 * 2,
                              height: _bubbles[i].$3 * 2,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    _bubbles[i].$4.withOpacity(0.20),
                                    _bubbles[i].$4.withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        // Chữ số trang trí bay lơ lửng
                        for (int d = 1; d <= 9; d++)
                          Positioned(
                            left: ((d * 37) % 100) / 100 * size.maxWidth,
                            top: ((d * 61 + 13) % 100) / 100 * size.maxHeight + sin(t * 2 + d) * 10,
                            child: Transform.rotate(
                              angle: sin(t + d) * 0.3,
                              child: Text(
                                '$d',
                                style: TextStyle(
                                  fontSize: 28.0 + (d % 3) * 10,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary.withOpacity(0.06),
                                ),
                              ),
                            ),
                          ),
                        // Lớp bóng chéo rất nhẹ (cảm giác mặt kính trên nền nhám)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  stops: const [0.0, 0.35, 0.5, 1.0],
                                  colors: [
                                    Colors.white.withOpacity(0.0),
                                    Colors.white.withOpacity(0.0),
                                    Colors.white.withOpacity(0.30),
                                    Colors.white.withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

/// Chữ tô màu cầu vồng.
class RainbowText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const RainbowText(
    this.text, {
    super.key,
    required this.style,
    this.gradient = AppColors.rainbowGradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(text, style: style),
    );
  }
}
