import 'package:flutter/material.dart';

class SuperFarmerTheme {
  static const _farmGreen = Color(0xFF2E7D32);
  static const _farmGreenDark = Color(0xFF81C784); // Desaturated green for dark mode
  static const _fieldGreen = Color(0xFF4CAF50);
  static const _earthBrown = Color(0xFF5D4037);
  static const _skyBlue = Color(0xFF81D4FA);

  // Dark mode surface colors
  static const _darkBase = Color(0xFF121212);
  static const _darkSurface = Color(0xFF1E1E1E);
  static const _darkOnSurface = Color(0xFFE0E0E0);

  // Light theme color scheme
  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: _farmGreen,
    primary: _farmGreen,
    secondary: _earthBrown,
    tertiary: _skyBlue,
    surface: const Color(0xFFF1F8E9),
    brightness: Brightness.light,
  );

  // Dark theme color scheme — desaturated green, high-contrast text
  static final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: _farmGreen,
    primary: _farmGreenDark,
    secondary: const Color(0xFFBCAAA4),
    tertiary: _skyBlue,
    surface: _darkSurface,
    onSurface: _darkOnSurface,
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
        scaffoldBackgroundColor: _darkBase,
        appBarTheme: AppBarTheme(
          backgroundColor: _darkSurface,
          foregroundColor: _darkOnSurface,
          elevation: 0,
          surfaceTintColor: _farmGreenDark.withValues(alpha: 0.1),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _darkSurface,
          indicatorColor: _farmGreenDark.withValues(alpha: 0.5),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFF81C784));
            }
            return const IconThemeData(color: Color(0xFF9E9E9E));
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: Color(0xFF81C784),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              );
            }
            return const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12);
          }),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: _darkSurface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _darkOnSurface,
            side: BorderSide(color: _farmGreenDark.withValues(alpha: 0.6)),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: _farmGreenDark,
          foregroundColor: Colors.black,
        ),
      );

  /// Legacy getter for backwards compatibility.
  static ThemeData get theme => lightTheme;
}
