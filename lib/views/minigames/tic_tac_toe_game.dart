import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../services/audio_service.dart';
import '../../services/minigame_storage.dart';
import 'minigame_scaffold.dart';

/// Cờ caro 3x3: bạn là X, máy là O.
/// Chế độ Dễ: máy đi ngẫu nhiên xen kẽ. Chế độ Khó: máy dùng minimax (không bao giờ thua).
class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  static const _lines = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // hàng
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // cột
    [0, 4, 8], [2, 4, 6], // chéo
  ];

  final _random = Random();
  List<String> _board = List.filled(9, '');
  int _gameId = 0; // đổi mỗi ván để bỏ nước đi máy còn treo của ván cũ
  bool _hard = false;
  bool _playerTurn = true;
  bool _playerStartsNext = false; // luân phiên ai đi trước
  List<int>? _winLine;
  String? _result; // 'X' | 'O' | 'draw'

  int _wins = 0;
  int _losses = 0;
  int _draws = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final w = await MiniGameStorage.getInt('ttt_wins');
    final l = await MiniGameStorage.getInt('ttt_losses');
    final d = await MiniGameStorage.getInt('ttt_draws');
    if (!mounted) return;
    setState(() {
      _wins = w ?? 0;
      _losses = l ?? 0;
      _draws = d ?? 0;
    });
  }

  void _newGame() {
    setState(() {
      _gameId++;
      _board = List.filled(9, '');
      _winLine = null;
      _result = null;
      _playerTurn = _playerStartsNext;
      _playerStartsNext = !_playerStartsNext;
    });
    if (!_playerTurn) _aiMove();
  }

  /// Trả về 'X' / 'O' nếu có người thắng, 'draw' nếu hòa, null nếu chưa xong.
  static String? _winnerOf(List<String> b) {
    for (final l in _lines) {
      if (b[l[0]] != '' && b[l[0]] == b[l[1]] && b[l[1]] == b[l[2]]) return b[l[0]];
    }
    return b.contains('') ? null : 'draw';
  }

  List<int>? _findWinLine() {
    for (final l in _lines) {
      if (_board[l[0]] != '' && _board[l[0]] == _board[l[1]] && _board[l[1]] == _board[l[2]]) return l;
    }
    return null;
  }

  /// Minimax: O muốn điểm cao, X muốn điểm thấp. Thắng sớm được điểm cao hơn.
  static int _minimax(List<String> b, bool oTurn, int depth) {
    final w = _winnerOf(b);
    if (w == 'O') return 10 - depth;
    if (w == 'X') return depth - 10;
    if (w == 'draw') return 0;

    int best = oTurn ? -1000 : 1000;
    for (int i = 0; i < 9; i++) {
      if (b[i] != '') continue;
      b[i] = oTurn ? 'O' : 'X';
      final score = _minimax(b, !oTurn, depth + 1);
      b[i] = '';
      best = oTurn ? max(best, score) : min(best, score);
    }
    return best;
  }

  int _chooseAiMove() {
    final empty = [for (int i = 0; i < 9; i++) if (_board[i] == '') i];

    // Dễ: 60% đi ngẫu nhiên
    if (!_hard && _random.nextDouble() < 0.6) {
      return empty[_random.nextInt(empty.length)];
    }

    int bestScore = -1000;
    final bestMoves = <int>[];
    final b = List<String>.from(_board);
    for (final i in empty) {
      b[i] = 'O';
      final score = _minimax(b, false, 1);
      b[i] = '';
      if (score > bestScore) {
        bestScore = score;
        bestMoves
          ..clear()
          ..add(i);
      } else if (score == bestScore) {
        bestMoves.add(i);
      }
    }
    return bestMoves[_random.nextInt(bestMoves.length)];
  }

  void _aiMove() {
    final gameId = _gameId;
    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted || _result != null || gameId != _gameId) return;
      final move = _chooseAiMove();
      AudioService.playTap();
      setState(() {
        _board[move] = 'O';
        _playerTurn = true;
      });
      _checkEnd();
    });
  }

  void _tap(int i) {
    if (!_playerTurn || _board[i] != '' || _result != null) return;
    AudioService.playPlaceNumber();
    setState(() {
      _board[i] = 'X';
      _playerTurn = false;
    });
    if (!_checkEnd()) _aiMove();
  }

  /// Trả về true nếu ván đã kết thúc.
  bool _checkEnd() {
    final w = _winnerOf(_board);
    if (w == null) return false;

    setState(() {
      _result = w;
      _winLine = _findWinLine();
      if (w == 'X') {
        _wins++;
      } else if (w == 'O') {
        _losses++;
      } else {
        _draws++;
      }
    });
    MiniGameStorage.setInt('ttt_wins', _wins);
    MiniGameStorage.setInt('ttt_losses', _losses);
    MiniGameStorage.setInt('ttt_draws', _draws);
    if (w == 'X') {
      AudioService.playVictory();
    } else if (w == 'O') {
      AudioService.playMistake();
    }
    return true;
  }

  String get _statusText {
    if (_result == 'X') return '🎉 Bạn thắng rồi!';
    if (_result == 'O') return '🤖 Máy thắng! Thử lại nhé';
    if (_result == 'draw') return '🤝 Hòa!';
    return _playerTurn ? 'Lượt của bạn (X)' : 'Máy đang nghĩ...';
  }

  @override
  Widget build(BuildContext context) {
    return MiniGameScaffold(
      title: '❌ Cờ caro 3x3',
      gradient: const LinearGradient(colors: [Color(0xFF34D399), Color(0xFF059669)]),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MiniStatChip(label: 'THẮNG', value: '$_wins', color: AppColors.mintDark),
                MiniStatChip(label: 'HÒA', value: '$_draws', color: AppColors.amber),
                MiniStatChip(label: 'THUA', value: '$_losses', color: AppColors.error),
              ],
            ),
            const SizedBox(height: 12),
            // Chọn chế độ
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _modeButton('😊 Dễ', !_hard, () => setState(() => _hard = false)),
                  _modeButton('😈 Khó', _hard, () => setState(() => _hard = true)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _statusText,
              style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, i) {
                      final v = _board[i];
                      final inWinLine = _winLine?.contains(i) ?? false;
                      return GestureDetector(
                        onTap: () => _tap(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: inWinLine
                                ? (v == 'X' ? AppColors.mintContainer : AppColors.errorContainer)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: inWinLine ? (v == 'X' ? AppColors.mint : AppColors.error) : AppColors.borderMedium,
                              width: inWinLine ? 3 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.08),
                                offset: const Offset(0, 4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: AnimatedScale(
                            scale: v == '' ? 0.3 : 1,
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutBack,
                            child: Text(
                              v,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                color: v == 'X' ? AppColors.primary : AppColors.pink,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: () {
                  AudioService.playTap();
                  _newGame();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.mintDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  _result == null ? 'Chơi lại từ đầu' : 'Ván mới',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeButton(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        AudioService.playTap();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.mintDark : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
