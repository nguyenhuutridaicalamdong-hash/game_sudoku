import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../services/sudoku_generator.dart';
import '../../widgets/colorful_background.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final history = userProvider.history;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.berryGradient)),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Lịch sử ván chơi 📜',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ColorfulBackground(
        child: RefreshIndicator(
        onRefresh: userProvider.refreshHistory,
        child: history.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
              const SizedBox(height: 120),
              Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history_rounded, size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text(
                    'Chưa có ván nào',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Chơi xong 1 ván để xem lịch sử ở đây nhé!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final record = history[index];
                final dateStr =
                    '${record.dateTime.day}/${record.dateTime.month}/${record.dateTime.year} • ${record.dateTime.hour.toString().padLeft(2, '0')}:${record.dateTime.minute.toString().padLeft(2, '0')}';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(20),
                    border: Border(left: BorderSide(color: record.difficulty.mainColor, width: 6)),
                    boxShadow: [
                      BoxShadow(
                        color: record.difficulty.mainColor.withOpacity(0.25),
                        offset: const Offset(0, 4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: record.isCompleted
                                  ? AppColors.mintContainer
                                  : AppColors.errorContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              record.isCompleted
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              color: record.isCompleted
                                  ? AppColors.mintDark
                                  : AppColors.error,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    record.difficulty.label,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: record.difficulty.mainColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      gradient: record.difficulty.gradient,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      record.isCompleted ? 'Thắng' : 'Thua',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dateStr,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '+${record.score} điểm',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.pink,
                            ),
                          ),
                          Text(
                            '⏱ ${SudokuGenerator.formatTime(record.timeSeconds)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      ),
      ),
    );
  }
}
