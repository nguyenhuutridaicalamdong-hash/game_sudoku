import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../services/audio_service.dart';
import '../../services/minigame_storage.dart';
import 'minigame_scaffold.dart';

/// Bóp bóng khí: bấm vào từng bong bóng để bóp. Bóp hết thì có tấm mới.
class BubblePopGame extends StatefulWidget {
  const BubblePopGame({super.key});

  @override
  State<BubblePopGame> createState() => _BubblePopGameState();
}

class _BubblePopGameState extends State<BubblePopGame> {
  static const int _cols = 6;
  static const int _rows = 8;
  static const _sheetColors = [
    Color(0xFF38BDF8),
    Color(0xFFC084FC),
    Color(0xFF34D399),
    Color(0xFFFBBF24),
    Color(0xFFFB7185),
  ];

  final _random = Random();
  late List<bool> _popped;
  int _sheet = 0;
  int _sessionPops = 0;
  int _totalPops = 0;

  Color get _color => _sheetColors[_sheet % _sheetColors.length];

  @override
  void initState() {
    super.initState();
    _popped = List.filled(_cols * _rows, false);
    MiniGameStorage.getInt('bubble_total').then((v) {
      if (mounted) setState(() => _totalPops = v ?? 0);
    });
  }

  void _pop(int i) {
    if (_popped[i]) return;
    if (AudioService.hapticsEnabled) {
      // Rung ngẫu nhiên nhẹ / vừa cho cảm giác thật
      _random.nextBool() ? HapticFeedback.lightImpact() : HapticFeedback.mediumImpact();
    }
    if (AudioService.soundEnabled) SystemSound.play(SystemSoundType.click);

    setState(() {
      _popped[i] = true;
      _sessionPops++;
      _totalPops++;
    });
    MiniGameStorage.setInt('bubble_total', _totalPops);

    if (_popped.every((p) => p)) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          _sheet++;
          _popped = List.filled(_cols * _rows, false);
        });
      });
    }
  }

  void _newSheet() {
    AudioService.playTap();
    setState(() {
      _sheet++;
      _popped = List.filled(_cols * _rows, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _popped.where((p) => !p).length;

    return MiniGameScaffold(
      title: '🫧 Bóp bóng khí',
      gradient: const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF6366F1)]),
      actions: [
        IconButton(
          tooltip: 'Tấm mới',
          icon: const Icon(Icons.refresh_rounded),
          onPressed: _newSheet,
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MiniStatChip(label: 'LẦN NÀY', value: '$_sessionPops', color: AppColors.primary),
                MiniStatChip(label: 'CÒN LẠI', value: '$remaining', color: AppColors.pink),
                MiniStatChip(label: 'TỔNG ĐÃ BÓP', value: '$_totalPops', color: AppColors.mintDark),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Chạm vào bong bóng để bóp 😌',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: _cols / _rows,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _color.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _color.withOpacity(0.5), width: 2),
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _cols,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                      ),
                      itemCount: _cols * _rows,
                      itemBuilder: (context, i) => GestureDetector(
                        onTapDown: (_) => _pop(i),
                        child: _Bubble(popped: _popped[i], color: _color),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final bool popped;
  final Color color;

  const _Bubble({required this.popped, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: popped ? 0.82 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: popped
              ? null
              : RadialGradient(
                  center: const Alignment(-0.35, -0.4),
                  radius: 0.9,
                  colors: [Colors.white, color.withOpacity(0.55), color],
                  stops: const [0.0, 0.45, 1.0],
                ),
          color: popped ? color.withOpacity(0.12) : null,
          border: Border.all(color: color.withOpacity(popped ? 0.25 : 0.6), width: 1.5),
          boxShadow: popped
              ? []
              : [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    offset: const Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
        ),
        child: popped
            ? Center(
                child: Icon(Icons.close_rounded, size: 14, color: color.withOpacity(0.35)),
              )
            : null,
      ),
    );
  }
}
