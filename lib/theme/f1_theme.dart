import 'package:flutter/material.dart';

/// F1-inspired semantic color constants and theme configuration.
/// Racing broadcast / pit wall dashboard aesthetic.
class F1Colors {
  // Primary backgrounds
  static const Color carbonBlack = Color(0xFF0D0D0D);
  static const Color asphaltDark = Color(0xFF141414);
  static const Color pitWallGray = Color(0xFF1A1A1E);
  static const Color panelGray = Color(0xFF222226);
  static const Color borderGray = Color(0xFF333338);

  // Accent colors
  static const Color racingRed = Color(0xFFE10600);
  static const Color telemetryCyan = Color(0xFF00D2FF);
  static const Color signalGreen = Color(0xFF00E676);
  static const Color warningAmber = Color(0xFFFFAB00);

  // Text
  static const Color textPrimary = Color(0xFFF0F0F0);
  static const Color textSecondary = Color(0xFFB0B0B4);
  static const Color textMuted = Color(0xFF707078);
}

/// Builds the global Material dark theme with F1 motorsport aesthetic.
ThemeData buildF1Theme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: F1Colors.carbonBlack,
    primaryColor: F1Colors.racingRed,

    colorScheme: const ColorScheme.dark(
      primary: F1Colors.racingRed,
      secondary: F1Colors.telemetryCyan,
      surface: F1Colors.pitWallGray,
      error: F1Colors.racingRed,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: F1Colors.asphaltDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: F1Colors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.0,
      ),
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: F1Colors.textPrimary, letterSpacing: 1.0),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: F1Colors.textPrimary),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: F1Colors.textPrimary, letterSpacing: 0.5),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: F1Colors.textSecondary, letterSpacing: 1.5),
      bodyLarge: TextStyle(fontSize: 15, color: F1Colors.textPrimary),
      bodyMedium: TextStyle(fontSize: 13, color: F1Colors.textSecondary),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.2),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: F1Colors.racingRed,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        elevation: 0,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: F1Colors.textPrimary,
        side: const BorderSide(color: F1Colors.borderGray, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: F1Colors.asphaltDark,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: F1Colors.borderGray, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: F1Colors.telemetryCyan, width: 1.5),
      ),
    ),

    dividerColor: F1Colors.borderGray,
  );
}
