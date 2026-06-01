import 'package:flutter/material.dart';
import '../theme/f1_theme.dart';
import '../repositories/auth_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepo = AuthRepository();
  bool _isLoading = false;

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      bool success = await _authRepo.register(
        _usernameController.text,
        _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký tài khoản thành công! Hãy đăng nhập.'),
              backgroundColor: F1Colors.signalGreen,
            ),
          );
          Navigator.pop(context); // Quay lại màn hình Đăng nhập
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tên tài khoản đã tồn tại trên hệ thống!'),
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
      appBar: AppBar(title: const Text('CREATE TEAM ACCOUNT')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'NEW USERNAME',
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
                    hintText: 'Nhập tên đăng ký mới',
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Vui lòng điền trường này'
                      : null,
                ),
                const SizedBox(height: 24),
                const Text(
                  'PASSWORD',
                  style: TextStyle(
                    color: F1Colors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: F1Colors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Mật khẩu tối thiểu 6 ký tự',
                  ),
                  validator: (value) => (value == null || value.length < 6)
                      ? 'Mật khẩu quá ngắn'
                      : null,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text('CREATE ACCOUNT'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
