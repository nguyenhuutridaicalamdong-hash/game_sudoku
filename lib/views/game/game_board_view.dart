import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../models/difficulty.dart';
import '../../models/sudoku_cell.dart';
import '../../providers/game_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/audio_service.dart';
import '../../services/sudoku_generator.dart';
import '../../widgets/box_celebration.dart';

class GameBoardView extends StatelessWidget {
  const GameBoardView({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final userProvider = context.watch<UserProvider>();
    final gameState = gameProvider.gameState;

    if (gameState == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final cells = gameState.cells;
    final selectedIdx = gameState.selectedCellIndex;
    final selectedCell = (selectedIdx != null && selectedIdx >= 0 && selectedIdx < cells.length)
        ? cells[selectedIdx]
        : null;
    final selectedValue = selectedCell?.value;

    final peerIndices = (selectedIdx != null && userProvider.stats.highlightPeers)
        ? SudokuGenerator.getPeerIndices(selectedIdx)
        : <int>[];

    final remainingCounts = SudokuGenerator.getRemainingDigitCounts(cells);

    // If game over (mistakes >= maxMistakes)
    if (gameState.mistakes >= gameState.maxMistakes) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGameOverDialog(context, gameProvider);
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Thanh chọn độ khó (giống sudoku.com): bấm để chơi ván mới ở cấp đó
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Center(
                  child: Text(
                    'Độ khó: ',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                for (final diff in Difficulty.playable)
                  GestureDetector(
                    onTap: () {
                      if (diff == gameState.difficulty) return;
                      AudioService.playTap();
                      _confirmChangeDifficulty(context, gameProvider, diff);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: diff == gameState.difficulty ? diff.gradient : null,
                        color: diff == gameState.difficulty ? null : Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: diff.mainColor.withOpacity(0.6), width: 1.2),
                      ),
                      child: Text(
                        diff.label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: diff == gameState.difficulty ? Colors.white : diff.mainColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // HUD Top Bar: Difficulty, Mistakes, Timer, Pause
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.88),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glossEdge, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.04),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Difficulty Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: gameState.difficulty.gradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    gameState.difficulty.label.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Mistakes Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: gameState.mistakes > 0 ? AppColors.errorContainer : AppColors.pinkSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        size: 14,
                        color: gameState.mistakes > 0 ? AppColors.error : AppColors.pink,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Lỗi: ${gameState.mistakes}/${gameState.maxMistakes}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: gameState.mistakes > 0 ? AppColors.error : AppColors.pink,
                        ),
                      ),
                    ],
                  ),
                ),

                // Timer & Pause Button
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: AppColors.sky),
                    const SizedBox(width: 4),
                    Text(
                      SudokuGenerator.formatTime(gameState.timeSeconds),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.pause_circle_rounded, color: AppColors.amber, size: 26),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 18,
                      onPressed: () {
                        AudioService.playTap();
                        _showPauseDialog(context, gameProvider);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 9x9 Sudoku Grid Board
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: AppColors.rainbowGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.pink.withOpacity(0.3),
                    offset: const Offset(0, 10),
                    blurRadius: 28,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: LayoutBuilder(
                  builder: (context, boardSize) {
                    final boxW = boardSize.maxWidth / 3;
                    final boxH = boardSize.maxHeight / 3;
                    final cellW = boardSize.maxWidth / 9;
                    final cellH = boardSize.maxHeight / 9;
                    return Stack(
                      children: [
                        GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 9,
                      ),
                      itemCount: 81,
                      itemBuilder: (context, index) {
                        final cell = cells[index];
                        final isSelected = (index == selectedIdx);
                        final isPeer = peerIndices.contains(index);
                        final isSameNumber = (userProvider.stats.highlightMatchingNumbers &&
                            selectedValue != null &&
                            cell.value == selectedValue);

                        return _buildCell(
                          cell: cell,
                          index: index,
                          isSelected: isSelected,
                          isPeer: isPeer,
                          isSameNumber: isSameNumber,
                          onTap: () => gameProvider.selectCell(index),
                        );
                      },
                    ),
                        // Hiệu ứng khi hoàn thành khối 3x3 / hàng ngang / cột dọc
                        for (final c in gameProvider.celebrations)
                          Positioned(
                            left: c.kind == CelebrationKind.box
                                ? (c.index % 3) * boxW
                                : c.kind == CelebrationKind.column
                                    ? c.index * cellW
                                    : 0,
                            top: c.kind == CelebrationKind.box
                                ? (c.index ~/ 3) * boxH
                                : c.kind == CelebrationKind.row
                                    ? c.index * cellH
                                    : 0,
                            width: c.kind == CelebrationKind.box
                                ? boxW
                                : c.kind == CelebrationKind.column
                                    ? cellW
                                    : boardSize.maxWidth,
                            height: c.kind == CelebrationKind.box
                                ? boxH
                                : c.kind == CelebrationKind.row
                                    ? cellH
                                    : boardSize.maxHeight,
                            child: BoxCelebration(
                              key: ValueKey(c.id),
                              kind: c.kind,
                              message: c.message,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Control Actions: Undo, Erase, Notes, Hint
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.88),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glossEdge, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.04),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.undo_rounded,
                  label: 'Hoàn tác',
                  color: AppColors.sky,
                  onTap: () => gameProvider.undo(),
                ),
                _buildActionButton(
                  icon: Icons.backspace_outlined,
                  label: 'Xóa',
                  color: AppColors.pink,
                  onTap: () => gameProvider.erase(),
                ),
                _buildActionButton(
                  icon: Icons.edit_note_rounded,
                  label: 'Ghi chú',
                  color: AppColors.primary,
                  isActive: gameState.notesMode,
                  badge: gameState.notesMode ? 'BẬT' : 'TẮT',
                  onTap: () => gameProvider.toggleNotesMode(),
                ),
                _buildActionButton(
                  icon: Icons.lightbulb_rounded,
                  label: 'Gợi ý',
                  color: AppColors.amber,
                  badge: '${gameState.hintsRemaining}',
                  onTap: () => gameProvider.hint(userProvider),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Numpad 1 to 9
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(9, (i) {
              final digit = i + 1;
              final remaining = remainingCounts[digit] ?? 0;
              final isExhausted = (remaining == 0);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: GestureDetector(
                    onTap: isExhausted
                        ? null
                        : () => gameProvider.inputDigit(digit, userProvider),
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: isExhausted
                            ? null
                            : LinearGradient(
                                colors: [AppColors.digitColor(digit), AppColors.digitColor(digit).withOpacity(0.75)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                        color: isExhausted ? AppColors.surfaceVariant : null,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isExhausted ? Colors.transparent : Colors.white,
                          width: 1.5,
                        ),
                        boxShadow: isExhausted
                            ? []
                            : [
                                BoxShadow(
                                  color: AppColors.digitColor(digit).withOpacity(0.45),
                                  offset: const Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                      ),
                      child: Center(
                        child: Text(
                          '$digit',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: isExhausted ? AppColors.textMuted : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCell({
    required SudokuCell cell,
    required int index,
    required bool isSelected,
    required bool isPeer,
    required bool isSameNumber,
    required VoidCallback onTap,
  }) {
    final row = cell.row;
    final col = cell.col;

    // Border styling for 3x3 blocks
    final borderTop = (row % 3 == 0 && row != 0)
        ? const BorderSide(color: AppColors.boardThickBorder, width: 2.0)
        : const BorderSide(color: AppColors.borderLight, width: 0.6);

    final borderLeft = (col % 3 == 0 && col != 0)
        ? const BorderSide(color: AppColors.boardThickBorder, width: 2.0)
        : const BorderSide(color: AppColors.borderLight, width: 0.6);

    // Cell background color
    Color bgColor = AppColors.boxPastels[cell.box];
    if (cell.isError) {
      bgColor = AppColors.cellErrorBg;
    } else if (isSelected) {
      bgColor = AppColors.cellSelectedBg;
    } else if (isSameNumber) {
      bgColor = AppColors.cellSameNumberBg;
    } else if (isPeer) {
      bgColor = AppColors.cellPeerBg;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            top: borderTop,
            left: borderLeft,
            right: (col == 8)
                ? BorderSide.none
                : const BorderSide(color: AppColors.borderLight, width: 0.6),
            bottom: (row == 8)
                ? BorderSide.none
                : const BorderSide(color: AppColors.borderLight, width: 0.6),
          ),
        ),
        child: Center(
          child: cell.value != null
              ? Text(
                  '${cell.value}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: cell.isGiven ? FontWeight.w800 : FontWeight.w900,
                    // Số đề cho sẵn: tím đậm • Bạn điền ĐÚNG: xanh lá • Bạn điền SAI: đỏ
                    color: cell.isError
                        ? AppColors.cellErrorText
                        : cell.isGiven
                            ? AppColors.cellGivenText
                            : AppColors.cellCorrectText,
                  ),
                )
              : (cell.notes.isNotEmpty)
                  ? _buildNotesGrid(cell.notes)
                  : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildNotesGrid(Set<int> notes) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: GridView.count(
        crossAxisCount: 3,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(9, (i) {
          final n = i + 1;
          final hasNote = notes.contains(n);
          return Center(
            child: Text(
              hasNote ? '$n' : '',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: AppColors.digitColor(n),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    bool isActive = false,
    String? badge,
  }) {
    return GestureDetector(
      onTap: () {
        AudioService.playTap();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.45),
                        offset: const Offset(0, 3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 20, color: Colors.white),
                ),
                if (badge != null)
                  Positioned(
                    right: -10,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.mintDark : AppColors.pink,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmChangeDifficulty(BuildContext context, GameProvider gameProvider, Difficulty diff) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Chơi cấp "${diff.label}"?'),
        content: const Text('Ván hiện tại sẽ bị bỏ và bắt đầu ván mới.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              gameProvider.startGame(diff);
            },
            child: const Text('Chơi mới'),
          ),
        ],
      ),
    );
  }

  void _showPauseDialog(BuildContext context, GameProvider gameProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Tạm dừng ⏸️',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          ),
          content: Text(
            'Nghỉ chút nhé! Tiến độ đã được lưu tự động.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Chơi tiếp'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                gameProvider.quitGame();
              },
              child: const Text('Về trang chủ'),
            ),
          ],
        );
      },
    );
  }

  void _showGameOverDialog(BuildContext context, GameProvider gameProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Thua rồi 😢',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              color: AppColors.error,
            ),
          ),
          content: Text(
            'Bạn đã sai 3 lần ở ván này. Đừng bỏ cuộc nhé!',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                gameProvider.startGame(gameProvider.gameState!.difficulty);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Chơi lại'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                gameProvider.quitGame();
              },
              child: const Text('Về trang chủ'),
            ),
          ],
        );
      },
    );
  }
}
