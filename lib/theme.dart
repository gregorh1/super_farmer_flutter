import 'package:flutter/material.dart';

class SuperFarmerTheme {
  static const _farmGreen = Color(0xFF2E7D32);
  static const _farmGreenLight = Color(0xFF66BB6A);
  static const _fieldGreen = Color(0xFF4CAF50);
  static const _earthBrown = Color(0xFF5D4037);
  static const _skyBlue = Color(0xFF81D4FA);

  // Light theme color scheme
  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: _farmGreen,
    primary: _farmGreen,
    secondary: _earthBrown,
    tertiary: _skyBlue,
    surface: const Color(0xFFF1F8E9),
    brightness: Brightness.light,
  );

  // Dark theme color scheme
  static final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: _farmGreen,
    primary: _farmGreenLight,
    secondary: const Color(0xFFBCAAA4),
    tertiary: _skyBlue,
    surface: const Color(0xFF1E1E1E),
    onSurface: const Color(0xFFE0E0E0),
    onPrimary: Colors.black,
    brightness: Brightness.dark,
  );

  static ThemeData get lightTheme => ThemeData(
        colorScheme: _lightColorScheme,
        scaffoldBackgroundColor: const Color(0xFFF1F8E9),
        appBarTheme: AppBarTheme(
          backgroundColor: _farmGreen,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _fieldGreen.withValues(alpha: 0.1),
          indicatorColor: _farmGreen.withValues(alpha: 0.2),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _farmGreen,
          foregroundColor: Colors.white,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        colorScheme: _darkColorScheme,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1E1E1E),
          foregroundColor: const Color(0xFFE0E0E0),
          elevation: 0,
          surfaceTintColor: _farmGreenLight.withValues(alpha: 0.1),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF1E1E1E),
          indicatorColor: _farmGreenLight.withValues(alpha: 0.3),
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          color: const Color(0xFF1E1E1E),
          surfaceTintColor: _farmGreenLight.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: _farmGreenLight,
          foregroundColor: Colors.black,
        ),
      );

  /// Legacy getter for backwards compatibility.
  static ThemeData get theme => lightTheme;
}
