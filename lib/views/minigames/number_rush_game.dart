import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../services/audio_service.dart';
import '../../services/minigame_storage.dart';
import 'minigame_scaffold.dart';

/// Bấm số thần tốc: bảng 5x5 các số 1-25 xáo trộn, bấm lần lượt từ 1 đến 25.
/// Bấm sai bị cộng 1 giây.
class NumberRushGame extends StatefulWidget {
  const NumberRushGame({super.key});

  @override
  State<NumberRushGame> createState() => _NumberRushGameState();
}

class _NumberRushGameState extends State<NumberRushGame> {
  static const int _size = 5;
  static const int _total = _size * _size;
  static const _bestKey = 'number_rush_best_ms';

  final _random = Random();
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;

  List<int> _numbers = [];
  int _next = 1;
  int _penaltyMs = 0;
  int? _wrongIndex;
  int? _bestMs;

  int get _elapsedMs => _stopwatch.elapsedMilliseconds + _penaltyMs;

  @override
  void initState() {
    super.initState();
    MiniGameStorage.getInt(_bestKey).then((v) {
      if (mounted) setState(() => _bestMs = v);
    });
    _newGame();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _newGame() {
    _ticker?.cancel();
    _stopwatch
      ..stop()
      ..reset();
    setState(() {
      _numbers = List.generate(_total, (i) => i + 1)..shuffle(_random);
      _next = 1;
      _penaltyMs = 0;
      _wrongIndex = null;
    });
  }

  String _fmt(int ms) => '${(ms / 1000).toStringAsFixed(1)}s';

  void _tap(int index) {
    final n = _numbers[index];
    if (n < _next) return; // đã bấm rồi

    if (n == _next) {
      if (_next == 1) {
        _stopwatch.start();
        _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
          if (mounted) setState(() {});
        });
      }
      AudioService.playPlaceNumber();
      setState(() => _next++);
      if (_next > _total) _finish();
    } else {
      // Sai: rung + cộng 1 giây (chỉ khi đã bắt đầu)
      AudioService.playMistake();
      setState(() {
        _wrongIndex = index;
        if (_stopwatch.isRunning) _penaltyMs += 1000;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _wrongIndex == index) setState(() => _wrongIndex = null);
      });
    }
  }

  Future<void> _finish() async {
    _stopwatch.stop();
    _ticker?.cancel();
    AudioService.playVictory();
    final ms = _elapsedMs;
    final isRecord = await MiniGameStorage.saveBest(_bestKey, ms);
    if (isRecord) _bestMs = ms;
    if (!mounted) return;
    setState(() {});
    await showMiniGameResult(
      context,
      emoji: isRecord ? '🏆' : '⚡',
      title: isRecord ? 'Kỷ lục mới!' : 'Xong rồi!',
      message: 'Bạn bấm hết 1 → 25 trong ${_fmt(ms)}'
          '${_penaltyMs > 0 ? ' (gồm ${_penaltyMs ~/ 1000}s phạt bấm sai)' : ''}.',
      onPlayAgain: _newGame,
    );
  }

  @override
  Widget build(BuildContext context) {
    final started = _next > 1;

    return MiniGameScaffold(
      title: '⚡ Bấm số thần tốc',
      gradient: const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFFF6B5B)]),
      actions: [
        IconButton(tooltip: 'Ván mới', icon: const Icon(Icons.refresh_rounded), onPressed: _newGame),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MiniStatChip(label: 'SỐ TIẾP THEO', value: _next > _total ? '✓' : '$_next', color: AppColors.pink),
                MiniStatChip(label: 'THỜI GIAN', value: _fmt(_elapsedMs), color: AppColors.primary),
                MiniStatChip(label: 'KỶ LỤC', value: _bestMs == null ? '--' : _fmt(_bestMs!), color: AppColors.amber),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              started ? 'Nhanh lên! Bấm sai bị cộng 1 giây' : 'Bấm số 1 để bắt đầu tính giờ',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _size,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: _total,
                    itemBuilder: (context, i) {
                      final n = _numbers[i];
                      final done = n < _next;
                      final wrong = _wrongIndex == i;
                      final color = AppColors.digitColor((n - 1) % 9 + 1);
                      return GestureDetector(
                        onTapDown: (_) => _tap(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: wrong
                                ? AppColors.error
                                : done
                                    ? AppColors.surfaceVariant
                                    : color,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: done
                                ? []
                                : [
                                    BoxShadow(
                                      color: color.withOpacity(0.35),
                                      offset: const Offset(0, 4),
                                      blurRadius: 8,
                                    ),
                                  ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            done ? '✓' : '$n',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: done ? AppColors.mintDark : Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
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
