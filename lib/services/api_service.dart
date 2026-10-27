import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  bool get isUnauthorized => statusCode == 401;
  bool get isNetworkError => statusCode == null;

  @override
  String toString() => message;
}

/// Gọi Web API ASP.NET Core (SQL Server). Token JWT được gắn tự động.
class ApiService {
  static String? token;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        // Bỏ qua trang cảnh báo của Dev Tunnels khi gọi qua link https://...devtunnels.ms
        'X-Tunnel-Skip-AntiPhishing-Page': 'true',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  static Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: query);
    http.Response res;
    try {
      switch (method) {
        case 'GET':
          res = await http.get(uri, headers: _headers).timeout(ApiConfig.timeout);
          break;
        case 'PUT':
          res = await http.put(uri, headers: _headers, body: jsonEncode(body)).timeout(ApiConfig.timeout);
          break;
        default:
          res = await http.post(uri, headers: _headers, body: jsonEncode(body)).timeout(ApiConfig.timeout);
      }
    } on TimeoutException {
      throw ApiException('Máy chủ không phản hồi. Kiểm tra Web API đã chạy chưa.');
    } on http.ClientException {
      throw ApiException('Không kết nối được máy chủ (${ApiConfig.baseUrl}).');
    } on FormatException {
      throw ApiException('Địa chỉ máy chủ không hợp lệ: ${ApiConfig.baseUrl}');
    }

    final text = utf8.decode(res.bodyBytes);
    dynamic data;
    if (text.isNotEmpty) {
      try {
        data = jsonDecode(text);
      } catch (_) {
        data = text;
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data;
    }
    throw ApiException(_extractError(data, res.statusCode), res.statusCode);
  }

  static String _extractError(dynamic data, int status) {
    if (data is Map) {
      if (data['message'] is String) return data['message'] as String;
      // Lỗi validate của ASP.NET: { errors: { Password: ["..."] } }
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
      if (data['title'] is String) return data['title'] as String;
    }
    if (status == 401) return 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.';
    return 'Lỗi máy chủ ($status)';
  }

  /// Kiểm tra máy chủ có chạy không (GET /api/health). Trả về null nếu OK.
  static Future<String?> checkHealth() async {
    try {
      await _send('GET', '/health');
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  // ===== Auth =====
  static Future<Map<String, dynamic>> register(String username, String password, String displayName) async {
    final data = await _send('POST', '/auth/register', body: {
      'username': username,
      'password': password,
      'displayName': displayName,
    });
    return Map<String, dynamic>.from(data as Map);
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    final data = await _send('POST', '/auth/login', body: {
      'username': username,
      'password': password,
    });
    return Map<String, dynamic>.from(data as Map);
  }

  static Future<Map<String, dynamic>> me() async {
    final data = await _send('GET', '/auth/me');
    return Map<String, dynamic>.from(data as Map);
  }

  static Future<Map<String, dynamic>> updateDisplayName(String displayName) async {
    final data = await _send('PUT', '/auth/me', body: {'displayName': displayName});
    return Map<String, dynamic>.from(data as Map);
  }

  // ===== Games =====
  /// Trả về { record, user, isNewBestTime }
  static Future<Map<String, dynamic>> submitGame({
    required String difficulty,
    required int timeSeconds,
    required int mistakes,
    required int hintsUsed,
    required bool isCompleted,
  }) async {
    final data = await _send('POST', '/games', body: {
      'difficulty': difficulty,
      'timeSeconds': timeSeconds,
      'mistakes': mistakes,
      'hintsUsed': hintsUsed,
      'isCompleted': isCompleted,
    });
    return Map<String, dynamic>.from(data as Map);
  }

  static Future<List<Map<String, dynamic>>> myGames({int take = 50}) async {
    final data = await _send('GET', '/games/me', query: {'take': '$take'});
    return (data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ===== Leaderboard =====
  /// period: week | month | all
  static Future<List<Map<String, dynamic>>> leaderboard({String period = 'week', String? difficulty}) async {
    final data = await _send('GET', '/leaderboard', query: {
      'period': period,
      if (difficulty != null) 'difficulty': difficulty,
    });
    return (data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
