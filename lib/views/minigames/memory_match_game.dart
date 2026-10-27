import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../services/audio_service.dart';
import '../../services/minigame_storage.dart';
import '../../services/sudoku_generator.dart';
import 'minigame_scaffold.dart';

/// Lật thẻ trí nhớ: 16 thẻ úp, tìm 8 cặp giống nhau.
class MemoryMatchGame extends StatefulWidget {
  const MemoryMatchGame({super.key});

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame> {
  static const _emojiPool = ['🍓', '🍋', '🍉', '🍇', '🥝', '🍑', '🍒', '🍍', '🥥', '🫐', '🌸', '🌈', '⭐', '🐱', '🐶', '🦊'];
  static const _bestKey = 'memory_best_moves';

  final _random = Random();
  List<String> _cards = [];
  final Set<int> _matched = {};
  final List<int> _open = [];
  bool _busy = false;
  int _moves = 0;
  int _seconds = 0;
  int? _bestMoves;
  Timer? _timer;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    MiniGameStorage.getInt(_bestKey).then((v) {
      if (mounted) setState(() => _bestMoves = v);
    });
    _newGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _newGame() {
    _timer?.cancel();
    final picked = (List<String>.from(_emojiPool)..shuffle(_random)).take(8).toList();
    setState(() {
      _cards = [...picked, ...picked]..shuffle(_random);
      _matched.clear();
      _open.clear();
      _busy = false;
      _moves = 0;
      _seconds = 0;
      _started = false;
    });
  }

  void _startTimer() {
    _started = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  void _tap(int i) {
    if (_busy || _matched.contains(i) || _open.contains(i)) return;
    if (!_started) _startTimer();
    AudioService.playTap();

    setState(() => _open.add(i));
    if (_open.length < 2) return;

    _moves++;
    final a = _open[0];
    final b = _open[1];
    if (_cards[a] == _cards[b]) {
      AudioService.playHint();
      setState(() {
        _matched.addAll([a, b]);
        _open.clear();
      });
      if (_matched.length == _cards.length) _win();
    } else {
      _busy = true;
      Future.delayed(const Duration(milliseconds: 750), () {
        if (!mounted) return;
        setState(() {
          _open.clear();
          _busy = false;
        });
      });
    }
  }

  Future<void> _win() async {
    _timer?.cancel();
    AudioService.playVictory();
    final isRecord = await MiniGameStorage.saveBest(_bestKey, _moves);
    if (isRecord) _bestMoves = _moves;
    if (!mounted) return;
    setState(() {});
    await showMiniGameResult(
      context,
      emoji: isRecord ? '🏆' : '🎉',
      title: isRecord ? 'Kỷ lục mới!' : 'Hoàn thành!',
      message: 'Bạn tìm đủ 8 cặp sau $_moves lượt trong ${SudokuGenerator.formatTime(_seconds)}.',
      onPlayAgain: _newGame,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MiniGameScaffold(
      title: '🃏 Lật thẻ trí nhớ',
      gradient: const LinearGradient(colors: [Color(0xFFC084FC), Color(0xFFEC4899)]),
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
                MiniStatChip(label: 'LƯỢT', value: '$_moves', color: AppColors.primary),
                MiniStatChip(label: 'THỜI GIAN', value: SudokuGenerator.formatTime(_seconds), color: AppColors.sky),
                MiniStatChip(label: 'KỶ LỤC', value: _bestMoves == null ? '--' : '$_bestMoves lượt', color: AppColors.amber),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Đã tìm ${_matched.length ~/ 2}/8 cặp',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: _cards.length,
                    itemBuilder: (context, i) {
                      final faceUp = _open.contains(i) || _matched.contains(i);
                      return GestureDetector(
                        onTap: () => _tap(i),
                        child: _MemoryCard(
                          emoji: _cards[i],
                          faceUp: faceUp,
                          matched: _matched.contains(i),
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

class _MemoryCard extends StatelessWidget {
  final String emoji;
  final bool faceUp;
  final bool matched;

  const _MemoryCard({required this.emoji, required this.faceUp, required this.matched});

  @override
  Widget build(BuildContext context) {
    // Lật thẻ: xoay quanh trục dọc, nửa đầu hiện mặt sau, nửa sau hiện mặt trước
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: faceUp ? 1 : 0),
      duration: const Duration(milliseconds: 280),
      builder: (context, value, _) {
        final showFront = value > 0.5;
        final angle = value * pi;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: showFront
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(pi),
                  child: _front(),
                )
              : _back(),
        );
      },
    );
  }

  Widget _front() {
    return Container(
      decoration: BoxDecoration(
        color: matched ? AppColors.mintContainer : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: matched ? AppColors.mint : AppColors.borderMedium, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 32)),
    );
  }

  Widget _back() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFC084FC), Color(0xFFEC4899)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text('?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
    );
  }
}
