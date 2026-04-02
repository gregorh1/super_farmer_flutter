import 'package:flutter/material.dart';

class SuperFarmerTheme {
  static const _farmGreen = Color(0xFF2E7D32);
  static const _farmGreenLight = Color(0xFF66BB6A);
  static const _fieldGreen = Color(0xFF4CAF50);
  static const _earthBrown = Color(0xFF5D4037);
  static const _skyBlue = Color(0xFF81D4FA);

  // Night farm palette
  static const _nightForestGreen = Color(0xFF1B2E1B);
  static const _moonlitBlue = Color(0xFF2C3E50);
  static const _nightSkyBlue = Color(0xFF34495E);
  static const _starAmber = Color(0xFFFFB74D);
  static const _nightGreenLight = Color(0xFF4E7A4E);
  static const _nightSurface = Color(0xFF162016);
  static const _nightCard = Color(0xFF1E2E1E);

  // Light theme color scheme
  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: _farmGreen,
    primary: _farmGreen,
    secondary: _earthBrown,
    tertiary: _skyBlue,
    surface: const Color(0xFFF1F8E9),
    brightness: Brightness.light,
  );

  // Dark theme color scheme — night farm
  static final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: _nightForestGreen,
    primary: _nightGreenLight,
    secondary: _starAmber,
    tertiary: _moonlitBlue,
    surface: _nightCard,
    onSurface: const Color(0xFFD5DDD5),
    onPrimary: Colors.white,
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
        scaffoldBackgroundColor: _nightSurface,
        appBarTheme: AppBarTheme(
          backgroundColor: _nightForestGreen,
          foregroundColor: const Color(0xFFD5DDD5),
          elevation: 0,
          surfaceTintColor: _nightGreenLight.withValues(alpha: 0.1),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _nightForestGreen,
          indicatorColor: _nightGreenLight.withValues(alpha: 0.3),
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          color: _nightCard,
          surfaceTintColor: _nightGreenLight.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: _starAmber,
          foregroundColor: _nightForestGreen,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return _starAmber;
            return null;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return _starAmber.withValues(alpha: 0.4);
            }
            return null;
          }),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: _starAmber,
          thumbColor: _starAmber,
        ),
        dividerTheme: DividerThemeData(
          color: _nightGreenLight.withValues(alpha: 0.2),
        ),
      );

  /// Legacy getter for backwards compatibility.
  static ThemeData get theme => lightTheme;
}
