import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_farmer/providers/settings_provider.dart';
import 'package:super_farmer/theme.dart';
import 'package:super_farmer/main.dart';
import 'package:super_farmer/widgets/settings_sheet.dart';

void main() {
  group('SuperFarmerTheme', () {
    test('lightTheme has correct brightness', () {
      final theme = SuperFarmerTheme.lightTheme;
      expect(theme.brightness, Brightness.light);
    });

    test('darkTheme has correct brightness', () {
      final theme = SuperFarmerTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
    });

    test('darkTheme uses night farm palette', () {
      final theme = SuperFarmerTheme.darkTheme;
      // Night forest green scaffold background
      expect(theme.scaffoldBackgroundColor, const Color(0xFF162016));
      // App bar uses night forest green
      expect(theme.appBarTheme.backgroundColor, const Color(0xFF1B2E1B));
      // Cards use night card color
      expect(theme.cardTheme.color, const Color(0xFF1E2E1E));
    });

    test('darkTheme has warm amber accents', () {
      final theme = SuperFarmerTheme.darkTheme;
      // FAB uses star amber
      expect(
        theme.floatingActionButtonTheme.backgroundColor,
        const Color(0xFFFFB74D),
      );
      // Secondary color is star amber
      expect(theme.colorScheme.secondary, const Color(0xFFFFB74D));
    });

    test('legacy theme getter returns light theme', () {
      expect(SuperFarmerTheme.theme.brightness, Brightness.light);
    });
  });

  group('ThemePreference', () {
    test('has correct labels', () {
      expect(ThemePreference.system.label, 'System');
      expect(ThemePreference.light.label, 'Light');
      expect(ThemePreference.dark.label, 'Dark');
    });

    test('has correct icons', () {
      expect(ThemePreference.system.icon, Icons.brightness_auto);
      expect(ThemePreference.light.icon, Icons.light_mode);
      expect(ThemePreference.dark.icon, Icons.dark_mode);
    });

    test('maps to correct ThemeMode', () {
      expect(ThemePreference.system.themeMode, ThemeMode.system);
      expect(ThemePreference.light.themeMode, ThemeMode.light);
      expect(ThemePreference.dark.themeMode, ThemeMode.dark);
    });
  });

  group('ThemeNotifier', () {
    test('defaults to system theme', () {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(themeProvider), ThemePreference.system);
    });

    test('setTheme changes state to dark', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(themeProvider.notifier).setTheme(ThemePreference.dark);
      expect(container.read(themeProvider), ThemePreference.dark);
    });

    test('setTheme changes state to light', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(themeProvider.notifier).setTheme(ThemePreference.light);
      expect(container.read(themeProvider), ThemePreference.light);
    });

    test('persists theme preference when set', () async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(themeProvider.notifier).setTheme(ThemePreference.dark);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_preference'), 'dark');
      expect(container.read(themeProvider), ThemePreference.dark);
    });

    test('handles invalid stored value gracefully', () async {
      SharedPreferences.setMockInitialValues({
        'theme_preference': 'invalid_value',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);

      // Should remain at default (system) when stored value is invalid
      expect(container.read(themeProvider), ThemePreference.system);
    });
  });

  group('SuperFarmerApp theme integration', () {
    testWidgets('uses system theme mode by default', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const ProviderScope(child: SuperFarmerApp()));
      await tester.pump();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.system);

      // Drain splash timer
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('applies dark theme when preference is dark', (tester) async {
      SharedPreferences.setMockInitialValues({
        'theme_preference': 'dark',
      });

      await tester.pumpWidget(const ProviderScope(child: SuperFarmerApp()));
      // Allow SharedPreferences load
      await tester.pump();
      await tester.pump();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);

      // Drain splash timer
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('applies light theme when preference is light', (tester) async {
      SharedPreferences.setMockInitialValues({
        'theme_preference': 'light',
      });

      await tester.pumpWidget(const ProviderScope(child: SuperFarmerApp()));
      await tester.pump();
      await tester.pump();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.light);

      // Drain splash timer
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });
  });

  group('Home screen settings button', () {
    testWidgets('shows settings icon in app bar', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const ProviderScope(child: SuperFarmerApp()));
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Settings icon should be in the app bar
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('opens settings sheet when tapped', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const ProviderScope(child: SuperFarmerApp()));
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Settings sheet should show the Theme section
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });

  group('Settings sheet theme toggle', () {
    testWidgets('shows theme selector with three options', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const ProviderScope(child: SuperFarmerApp()));
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // All three theme options should be visible in the segmented button
      // "System" may appear in both the subtitle and the button label
      expect(find.text('System'), findsWidgets);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('can switch to dark theme', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const ProviderScope(child: SuperFarmerApp()));
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Tap "Dark" in the segmented button
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      // The MaterialApp should now use dark theme mode
      final app = tester.widget<MaterialApp>(
        find.byType(MaterialApp).last,
      );
      expect(app.themeMode, ThemeMode.dark);
    });
  });
}
