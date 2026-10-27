import 'package:shared_preferences/shared_preferences.dart';

/// Địa chỉ Web API (backend/SudokuApi).
///
/// Đổi được ngay trong app: màn hình Đăng nhập → bấm dòng "Máy chủ: ..." ở dưới cùng.
/// - Máy ảo trên chính máy chạy API:  http://10.0.2.2:5260/api
/// - Máy khác cùng Wi-Fi:             http://<IP LAN máy chủ>:5260/api   (vd http://192.168.1.5:5260/api)
/// - Qua Internet (Dev Tunnel/ngrok): https://xxxx.devtunnels.ms/api
class ApiConfig {
  /// Địa chỉ mặc định. Khi build APK có thể gắn sẵn địa chỉ máy chủ:
  ///   flutter build apk --release --dart-define=API_URL=https://xxxx.devtunnels.ms/api
  /// Không truyền gì thì dùng địa chỉ cho máy ảo (10.0.2.2).
  static const String defaultBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:5260/api',
  );
  static const Duration timeout = Duration(seconds: 12);
  static const String _prefsKey = 'sudoku_api_base_url';

  static String baseUrl = defaultBaseUrl;

  /// Gọi 1 lần lúc mở app.
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    baseUrl = prefs.getString(_prefsKey) ?? defaultBaseUrl;
  }

  /// Chuẩn hóa và lưu địa chỉ máy chủ. Người dùng có thể nhập "192.168.1.5"
  /// hoặc "http://192.168.1.5:5260" – hàm này tự thêm phần còn thiếu.
  static Future<String> save(String input) async {
    var url = input.trim();
    if (url.isEmpty) url = defaultBaseUrl;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    final uri = Uri.parse(url);
    if (uri.scheme == 'http' && !uri.hasPort) {
      url = uri.replace(port: 5260).toString();
      while (url.endsWith('/')) {
        url = url.substring(0, url.length - 1);
      }
    }
    if (!url.endsWith('/api')) url = '$url/api';

    baseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, url);
    return url;
  }
}
