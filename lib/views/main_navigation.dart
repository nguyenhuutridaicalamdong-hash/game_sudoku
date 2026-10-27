import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/game_provider.dart';
import '../providers/ranking_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/colorful_background.dart';
import '../widgets/custom_header.dart';
import 'game/game_board_view.dart';
import 'home/home_view.dart';
import 'play/play_view.dart';
import 'profile/profile_view.dart';
import 'ranking/ranking_view.dart';
import 'victory/victory_view.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentTabIndex = 0;

  void _selectTab(int index) {
    setState(() => _currentTabIndex = index);
    // Mở tab Xếp hạng / Hồ sơ thì tải lại dữ liệu mới nhất từ SQL Server
    if (index == 2) context.read<RankingProvider>().refresh();
    if (index == 3) context.read<UserProvider>().refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final inGame = gameProvider.inGame;
    final showVictory = gameProvider.showVictory;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ColorfulBackground(
        child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Stack(
              children: [
                Column(
                  children: [
                    // Persistent Top Header (Hidden on Victory screen)
                    if (!showVictory)
                      CustomHeader(
                        currentTabIndex: _currentTabIndex,
                        onTabSelected: _selectTab,
                      ),

                    // Main Content Area
                    Expanded(
                      child: showVictory
                          ? const VictoryView()
                          : inGame
                              ? const GameBoardView()
                              : IndexedStack(
                                  index: _currentTabIndex,
                                  children: [
                                    HomeView(
                                      onNavigateToPlay: () {
                                        setState(() => _currentTabIndex = 1);
                                      },
                                    ),
                                    const PlayView(),
                                    const RankingView(),
                                    const ProfileView(),
                                  ],
                                ),
                    ),
                  ],
                ),

                // Floating Bottom Nav Bar (Hidden when in-game or in victory)
                if (!inGame && !showVictory)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: BottomNavBar(
                      currentIndex: _currentTabIndex,
                      onTabSelected: _selectTab,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
