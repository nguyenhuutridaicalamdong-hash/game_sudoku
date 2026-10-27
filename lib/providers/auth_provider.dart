import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'game_provider.dart';
import 'user_provider.dart';

enum AuthStatus { checking, loggedOut, loggedIn }

/// Đăng ký / đăng nhập / đăng xuất bằng JWT từ Web API.
class AuthProvider extends ChangeNotifier {
  final UserProvider userProvider;
  final GameProvider gameProvider;

  AuthStatus _status = AuthStatus.checking;
  bool _isBusy = false;

  AuthStatus get status => _status;
  bool get isBusy => _isBusy;

  AuthProvider({required this.userProvider, required this.gameProvider}) {
    _restoreSession();
  }

  /// Mở app: nếu còn token thì vào thẳng game.
  Future<void> _restoreSession() async {
    final token = await StorageService.loadToken();
    if (token == null) {
      _setStatus(AuthStatus.loggedOut);
      return;
    }

    ApiService.token = token;
    try {
      final user = await ApiService.me();
      await userProvider.onLoggedIn(user);
      _setStatus(AuthStatus.loggedIn);
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await logout();
      } else {
        // Mất mạng: vẫn cho chơi bằng dữ liệu cache, điểm sẽ gửi sau
        _setStatus(AuthStatus.loggedIn);
      }
    } catch (_) {
      _setStatus(AuthStatus.loggedIn);
    }
  }

  /// Trả về null nếu thành công, ngược lại là thông báo lỗi.
  Future<String?> login(String username, String password) {
    return _authenticate(() => ApiService.login(username.trim(), password));
  }

  Future<String?> register(String username, String password, String displayName) {
    return _authenticate(() => ApiService.register(username.trim(), password, displayName.trim()));
  }

  Future<String?> _authenticate(Future<Map<String, dynamic>> Function() call) async {
    _isBusy = true;
    notifyListeners();
    try {
      final res = await call();
      final token = res['token'] as String;
      ApiService.token = token;
      await StorageService.saveToken(token);
      await userProvider.onLoggedIn(Map<String, dynamic>.from(res['user'] as Map));
      _status = AuthStatus.loggedIn;
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (e) {
      return 'Có lỗi xảy ra: $e';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    ApiService.token = null;
    await StorageService.saveToken(null);
    gameProvider.clearSavedGame();
    await userProvider.onLoggedOut();
    _setStatus(AuthStatus.loggedOut);
  }

  void _setStatus(AuthStatus s) {
    _status = s;
    notifyListeners();
  }
}
