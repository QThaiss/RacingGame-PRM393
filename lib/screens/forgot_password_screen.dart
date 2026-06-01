import 'package:flutter/material.dart';
import '../theme/f1_theme.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _authRepo = AuthRepository();
  bool _isLoading = false;

  void _handleReset() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      bool success = await _authRepo.resetPassword(
        _usernameController.text,
        _newPasswordController.text,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đặt lại mật khẩu thành công!'),
              backgroundColor: F1Colors.signalGreen,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không tìm thấy tên tài khoản này!'),
              backgroundColor: F1Colors.racingRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: F1Colors.carbonBlack,
      appBar: AppBar(title: const Text('RESET PASSWORD')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'YOUR USERNAME',
                  style: TextStyle(
                    color: F1Colors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _usernameController,
                  style: const TextStyle(color: F1Colors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Nhập chính xác username của bạn',
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Vui lòng nhập thông tin'
                      : null,
                ),
                const SizedBox(height: 24),
                const Text(
                  'NEW PASSWORD',
                  style: TextStyle(
                    color: F1Colors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: F1Colors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Nhập mật khẩu mới',
                  ),
                  validator: (value) => (value == null || value.length < 6)
                      ? 'Yêu cầu tối thiểu 6 kí tự'
                      : null,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleReset,
                  child: const Text('UPDATE PASSWORD'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
