import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MiniRacingGameApp());
}

/// The root widget of the Mini Racing Game.
/// Configures global styling, fonts, and dark theme.
class MiniRacingGameApp extends StatelessWidget {
  const MiniRacingGameApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Racing Game',
      debugShowCheckedModeBanner: false,
      
      // Cyber Dark Theme config
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.purpleAccent,
        scaffoldBackgroundColor: Colors.black,
        
        // High fidelity text styling
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        
        // Color Scheme configuration
        colorScheme: ColorScheme.dark(
          primary: Colors.purpleAccent,
          secondary: Colors.amberAccent,
          surface: Colors.grey[900]!,
        ),

        // Universal styling for input decorations
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Colors.grey),
          floatingLabelStyle: const TextStyle(color: Colors.purpleAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.purpleAccent, width: 2),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
