import 'package:flutter/material.dart';
import '../theme/f1_theme.dart';
import 'home_screen.dart';

/// F1-themed Login Screen.
/// Provides a professional entry point for the racing game.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      // Simulate a login process
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome to Race Control!'),
          backgroundColor: F1Colors.signalGreen,
        ),
      );
      
      // Navigate to HomeScreen and remove login from history
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: F1Colors.carbonBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Logo or Hero Icon
                const Icon(
                  Icons.speed,
                  color: F1Colors.racingRed,
                  size: 80,
                ),
                const SizedBox(height: 16),
                
                // 2. App Title
                const Text(
                  'MINI RACING',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: F1Colors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4.0,
                  ),
                ),
                const Text(
                  'PIT WALL ACCESS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: F1Colors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 48),

                // 3. Username Field
                const Text(
                  'USERNAME',
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
                    prefixIcon: Icon(Icons.person_outline, color: F1Colors.textMuted),
                    hintText: 'Enter driver name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // 4. Password Field
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
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: F1Colors.textPrimary),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline, color: F1Colors.textMuted),
                    hintText: '••••••••',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: F1Colors.textMuted,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // 5. Login Button
                Container(
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      colors: [F1Colors.racingRed, Color(0xFFB00500)],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text(
                      'AUTHORIZE ACCESS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 6. Guest access / Sign up hint
                TextButton(
                  onPressed: () {
                    // Quick guest access for testing
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  },
                  child: const Text(
                    'ACCESS AS GUEST STEWARD',
                    style: TextStyle(
                      color: F1Colors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
