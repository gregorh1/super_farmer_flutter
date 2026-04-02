import 'package:flutter/material.dart';

class SuperFarmerTheme {
  static const _farmGreen = Color(0xFF2E7D32);
  static const _fieldGreen = Color(0xFF4CAF50);
  static const _earthBrown = Color(0xFF5D4037);
  static const _skyBlue = Color(0xFF81D4FA);

  static final ColorScheme _colorScheme = ColorScheme.fromSeed(
    seedColor: _farmGreen,
    primary: _farmGreen,
    secondary: _earthBrown,
    tertiary: _skyBlue,
    surface: const Color(0xFFF1F8E9),
    brightness: Brightness.light,
  );

  static ThemeData get theme => ThemeData(
        colorScheme: _colorScheme,
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
}
