import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Lớp xử lý logic lưu trữ dữ liệu và xác thực tài khoản bền vững (Persistent Storage)
class AuthRepository {
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;
  AuthRepository._internal();

  // Mock cơ sở dữ liệu tài khoản chạy trong Runtime
  final Map<String, UserAccount> _localUsers = {};
  UserAccount? _currentUser;

  UserAccount? get currentUser => _currentUser;

  /// Đăng ký tài khoản mới (Bất đồng bộ)
  Future<bool> register(String username, String password) async {
    if (_localUsers.containsKey(username) || username.trim().isEmpty) {
      return false; // Tài khoản đã tồn tại hoặc không hợp lệ
    }

    final newUser = UserAccount.create(username: username, password: password);
    _localUsers[username] = newUser;

    // Lưu trạng thái đăng ký xuống thiết bị
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pwd_$username', password);
    await prefs.setDouble('bal_$username', 100.0);
    return true;
  }

  /// Đăng nhập tài khoản (Kiểm tra dữ liệu local hoặc SharedPreferences)
  Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();

    // Lấy mật khẩu và số tiền đã lưu từ thiết bị
    String? savedPassword = prefs.getString('pwd_$username');
    double? savedBalance = prefs.getDouble('bal_$username');

    if (savedPassword != null && savedPassword == password) {
      _currentUser = UserAccount(
        username: username,
        password: password,
        balance: savedBalance ?? 100.0,
      );
      _localUsers[username] = _currentUser!;
      return true;
    }
    return false;
  }

  /// Cập nhật và lưu lại số tiền riêng biệt của tài khoản hiện tại sau mỗi trận đua
  Future<void> updateCurrentBalance(double newBalance) async {
    if (_currentUser == null) return;

    _currentUser!.balance = newBalance;
    _localUsers[_currentUser!.username]?.balance = newBalance;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bal_${_currentUser!.username}', newBalance);
  }

  /// Đổi mật khẩu (Tính năng Quên mật khẩu)
  Future<bool> resetPassword(String username, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('pwd_$username')) {
      await prefs.setString('pwd_$username', newPassword);
      if (_localUsers.containsKey(username)) {
        _localUsers[username] = UserAccount(
          username: username,
          password: newPassword,
          balance: _localUsers[username]?.balance ?? 100.0,
        );
      }
      return true;
    }
    return false;
  }

  /// Đăng xuất - Xóa session hiện tại
  void logout() {
    _currentUser = null;
  }
}
