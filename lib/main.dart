import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/f1_theme.dart';

void main() {
  runApp(const MiniRacingGameApp());
}

/// Root widget — applies the F1 motorsport dark theme globally.
class MiniRacingGameApp extends StatelessWidget {
  const MiniRacingGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Racing Game',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: buildF1Theme(),
      home: const HomeScreen(),
    );
  }
}
