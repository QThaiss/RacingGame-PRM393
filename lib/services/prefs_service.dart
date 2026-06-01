import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences for persisting player balance.
class PrefsService {
  static const String _keyMoney = 'total_money';
  static const double _defaultMoney = 100.0;

  static Future<double> loadMoney() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_keyMoney) ?? _defaultMoney;
    } catch (_) {
      return _defaultMoney;
    }
  }

  static Future<void> saveMoney(double amount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyMoney, amount);
    } catch (_) {}
  }

  static Future<void> resetMoney() async {
    await saveMoney(_defaultMoney);
  }
}
