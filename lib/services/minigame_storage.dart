import 'package:shared_preferences/shared_preferences.dart';

/// Lưu kỷ lục các mini game trên máy.
class MiniGameStorage {
  static const _prefix = 'minigame_';

  static Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_prefix$key');
  }

  static Future<void> setInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_prefix$key', value);
  }

  /// Lưu nếu [value] tốt hơn kỷ lục cũ. [lowerIsBetter] = true cho thời gian / số lượt.
  /// Trả về true nếu là kỷ lục mới.
  static Future<bool> saveBest(String key, int value, {bool lowerIsBetter = true}) async {
    final old = await getInt(key);
    final isBetter = old == null || (lowerIsBetter ? value < old : value > old);
    if (isBetter) await setInt(key, value);
    return isBetter;
  }
}
