import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'providers/auth_provider.dart';
import 'providers/game_provider.dart';
import 'providers/ranking_provider.dart';
import 'providers/user_provider.dart';
import 'services/api_config.dart';
import 'views/auth/auth_view.dart';
import 'views/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.load(); // địa chỉ máy chủ đã lưu

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final userProvider = UserProvider();
  final gameProvider = GameProvider();
  final authProvider = AuthProvider(userProvider: userProvider, gameProvider: gameProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider.value(value: gameProvider),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => RankingProvider()),
      ],
      child: const SudokuApp(),
    ),
  );
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku Sắc Màu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          primary: AppColors.primary,
          secondary: AppColors.amber,
          surface: AppColors.surface,
        ),
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      ),
      home: const AuthGate(),
    );
  }
}

/// Chưa đăng nhập → màn hình Đăng nhập; đã đăng nhập → vào game.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;
    switch (status) {
      case AuthStatus.checking:
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(child: CircularProgressIndicator()),
        );
      case AuthStatus.loggedOut:
        return const AuthView();
      case AuthStatus.loggedIn:
        return const MainNavigation();
    }
  }
}
