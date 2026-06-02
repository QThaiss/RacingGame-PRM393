/// Model đại diện cho thông tin tài khoản người chơi
class UserAccount {
  final String username;
  final String password;
  double balance;

  UserAccount({
    required this.username,
    required this.password,
    this.balance = 100.0, // Mặc định mỗi tài khoản mới có $100
  });

  /// Factory constructor để phục vụ việc chuyển đổi cấu trúc lưu trữ sau này (nếu cần)
  factory UserAccount.create({
    required String username,
    required String password,
  }) {
    return UserAccount(username: username, password: password);
  }
}
