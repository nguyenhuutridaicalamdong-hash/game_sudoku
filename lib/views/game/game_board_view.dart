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
          // HUD Top Bar: Difficulty, Mistakes, Timer, Pause
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
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
                    color: gameState.difficulty.cardBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    gameState.difficulty.label.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: gameState.difficulty.textColor,
                    ),
                  ),
                ),

                // Mistakes Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: gameState.mistakes > 0 ? AppColors.errorContainer : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        size: 14,
                        color: gameState.mistakes > 0 ? AppColors.error : AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Mistakes: ${gameState.mistakes}/${gameState.maxMistakes}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: gameState.mistakes > 0 ? AppColors.error : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Timer & Pause Button
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: AppColors.textSecondary),
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
                      icon: const Icon(Icons.pause_circle_rounded, color: AppColors.primary, size: 24),
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.boardThickBorder, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.12),
                    offset: const Offset(0, 10),
                    blurRadius: 28,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13.5),
                child: GridView.builder(
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
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Control Actions: Undo, Erase, Notes, Hint
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
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
                  label: 'Undo',
                  onTap: () => gameProvider.undo(),
                ),
                _buildActionButton(
                  icon: Icons.backspace_outlined,
                  label: 'Erase',
                  onTap: () => gameProvider.erase(),
                ),
                _buildActionButton(
                  icon: Icons.edit_note_rounded,
                  label: 'Notes',
                  isActive: gameState.notesMode,
                  badge: gameState.notesMode ? 'ON' : 'OFF',
                  onTap: () => gameProvider.toggleNotesMode(),
                ),
                _buildActionButton(
                  icon: Icons.lightbulb_rounded,
                  label: 'Hint',
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
                        color: isExhausted
                            ? const Color(0xFFF0F0F5)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isExhausted
                              ? Colors.transparent
                              : AppColors.borderMedium,
                        ),
                        boxShadow: isExhausted
                            ? []
                            : [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.06),
                                  offset: const Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$digit',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: isExhausted
                                  ? const Color(0xFFC0C0D0)
                                  : AppColors.primary,
                            ),
                          ),
                          Text(
                            isExhausted ? '✓' : '$remaining',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: isExhausted
                                  ? AppColors.mintDark
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
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
    Color bgColor = Colors.white;
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
                    fontWeight: FontWeight.w800,
                    color: cell.isError
                        ? AppColors.cellErrorText
                        : cell.isGiven
                            ? AppColors.cellGivenText
                            : AppColors.cellUserText,
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
                fontWeight: FontWeight.w700,
                color: AppColors.cellNotesText,
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
    bool isActive = false,
    String? badge,
  }) {
    return GestureDetector(
      onTap: () {
        AudioService.playTap();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isActive ? AppColors.primary : AppColors.textPrimary,
                ),
                if (badge != null)
                  Positioned(
                    right: -10,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : AppColors.amber,
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
                fontWeight: FontWeight.w700,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
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
            'Game Paused',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          ),
          content: Text(
            'Take a breath. Your progress is saved automatically.',
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
              child: const Text('Resume Game'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                gameProvider.quitGame();
              },
              child: const Text('Back to Home'),
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
            'Game Over',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              color: AppColors.error,
            ),
          ),
          content: Text(
            'You made 3 mistakes in this puzzle. Don\'t give up!',
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
              child: const Text('Try Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                gameProvider.quitGame();
              },
              child: const Text('Back to Home'),
            ),
          ],
        );
      },
    );
  }
}
