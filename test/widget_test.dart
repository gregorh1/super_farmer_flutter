import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_farmer/main.dart';
import 'package:super_farmer/models/animal.dart';
import 'package:super_farmer/providers/game_provider.dart';
import 'package:super_farmer/screens/splash_screen.dart';
import 'package:super_farmer/theme.dart';

void main() {
  group('SuperFarmerApp', () {
    testWidgets('renders splash screen initially', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: SuperFarmerApp()));
      await tester.pump();

      // Splash screen should show app name and loading indicator
      expect(find.text('Super Farmer'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Drain the pending splash timer
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('transitions from splash to home after delay', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: SuperFarmerApp()));
      await tester.pump();

      // Initially on splash
      expect(find.byType(SplashScreen), findsOneWidget);

      // Advance past splash duration (3 seconds)
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Should now show bottom navigation (home screen)
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Game'), findsOneWidget);
      expect(find.text('Rules'), findsOneWidget);
    });

    testWidgets('shows bottom navigation after splash', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: SuperFarmerApp()));
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Game'), findsOneWidget);
      expect(find.text('Rules'), findsOneWidget);
    });

    testWidgets('navigates to game screen', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: SuperFarmerApp()));
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Game'));
      await tester.pumpAndSettle();

      expect(find.text('New Game'), findsOneWidget);
    });

    testWidgets('navigates to rules screen', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: SuperFarmerApp()));
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rules'));
      await tester.pumpAndSettle();

      expect(find.text('How to Play'), findsOneWidget);
    });
  });

  group('SplashScreen', () {
    testWidgets('displays app name and tractor emoji', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(onComplete: () {}),
        ),
      );
      await tester.pump();

      expect(find.text('Super Farmer'), findsOneWidget);
      expect(find.text('Collect your animals!'), findsOneWidget);
      expect(find.text('\u{1F69C}'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Drain the pending timer
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('calls onComplete after delay', (tester) async {
      bool completed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(onComplete: () => completed = true),
        ),
      );
      await tester.pump();
      expect(completed, false);

      await tester.pump(const Duration(seconds: 4));
      expect(completed, true);
    });

    testWidgets('has green background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SuperFarmerTheme.lightTheme,
          home: SplashScreen(onComplete: () {}),
        ),
      );
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF2E7D32));

      // Drain the pending timer
      await tester.pump(const Duration(seconds: 4));
    });
  });

  group('Animal model', () {
    test('has correct number of animal types', () {
      expect(Animal.values.length, 7);
    });

    test('each animal has a label and color', () {
      for (final animal in Animal.values) {
        expect(animal.label.isNotEmpty, true);
        expect(animal.totalInGame, greaterThan(0));
      }
    });

    test('each animal has a valid SVG asset path', () {
      for (final animal in Animal.values) {
        expect(animal.assetPath, startsWith('assets/images/'));
        expect(animal.assetPath, endsWith('.svg'));
      }
    });

    test('dice symbols include fox and wolf', () {
      expect(DiceSymbol.values.any((d) => d == DiceSymbol.fox), true);
      expect(DiceSymbol.values.any((d) => d == DiceSymbol.wolf), true);
    });
  });

  group('GameState', () {
    test('starts not started', () {
      const state = GameState();
      expect(state.isStarted, false);
      expect(state.players, isEmpty);
      expect(state.currentPlayer, isNull);
    });

    test('GameNotifier starts game with players', () {
      final notifier = GameNotifier();
      notifier.startGame(['Alice', 'Bob']);

      expect(notifier.state.isStarted, true);
      expect(notifier.state.players.length, 2);
      expect(notifier.state.players[0].name, 'Alice');
      expect(notifier.state.players[1].name, 'Bob');
    });

    test('GameNotifier advances turns', () {
      final notifier = GameNotifier();
      notifier.startGame(['Alice', 'Bob']);
      expect(notifier.state.currentPlayerIndex, 0);

      notifier.nextTurn();
      expect(notifier.state.currentPlayerIndex, 1);

      notifier.nextTurn();
      expect(notifier.state.currentPlayerIndex, 0);
    });

    test('GameNotifier resets game', () {
      final notifier = GameNotifier();
      notifier.startGame(['Alice', 'Bob']);
      notifier.resetGame();

      expect(notifier.state.isStarted, false);
      expect(notifier.state.players, isEmpty);
    });
  });

  group('PlayerHerd', () {
    test('counts animals correctly', () {
      const herd = PlayerHerd(
        name: 'Test',
        animals: {Animal.rabbit: 3, Animal.cow: 1},
      );
      expect(herd.countOf(Animal.rabbit), 3);
      expect(herd.countOf(Animal.cow), 1);
      expect(herd.countOf(Animal.horse), 0);
    });

    test('hasWon returns true when all non-dog animals collected', () {
      final herd = PlayerHerd(
        name: 'Winner',
        animals: {
          Animal.rabbit: 1,
          Animal.lamb: 1,
          Animal.pig: 1,
          Animal.cow: 1,
          Animal.horse: 1,
          Animal.smallDog: 0,
          Animal.bigDog: 0,
        },
      );
      expect(herd.hasWon, true);
    });

    test('hasWon returns false when missing an animal', () {
      final herd = PlayerHerd(
        name: 'NotYet',
        animals: {
          Animal.rabbit: 1,
          Animal.lamb: 1,
          Animal.pig: 1,
          Animal.cow: 1,
          Animal.horse: 0,
        },
      );
      expect(herd.hasWon, false);
    });
  });

  group('SuperFarmerTheme', () {
    test('light theme produces a valid ThemeData', () {
      final theme = SuperFarmerTheme.lightTheme;
      expect(theme, isA<ThemeData>());
      expect(theme.colorScheme.primary, isNotNull);
      expect(theme.scaffoldBackgroundColor, const Color(0xFFF1F8E9));
      expect(theme.colorScheme.brightness, Brightness.light);
    });

    test('dark theme produces a valid ThemeData', () {
      final theme = SuperFarmerTheme.darkTheme;
      expect(theme, isA<ThemeData>());
      expect(theme.colorScheme.primary, isNotNull);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF121212));
      expect(theme.colorScheme.brightness, Brightness.dark);
    });

    test('dark theme has lighter primary than light theme', () {
      final lightPrimary = SuperFarmerTheme.lightTheme.colorScheme.primary;
      final darkPrimary = SuperFarmerTheme.darkTheme.colorScheme.primary;
      // Dark theme primary should be lighter (higher luminance)
      expect(
        HSLColor.fromColor(darkPrimary).lightness,
        greaterThan(HSLColor.fromColor(lightPrimary).lightness),
      );
    });

    test('dark theme surfaces are dark', () {
      final theme = SuperFarmerTheme.darkTheme;
      final surfaceLuminance =
          HSLColor.fromColor(theme.scaffoldBackgroundColor).lightness;
      // Should be very dark (low luminance)
      expect(surfaceLuminance, lessThan(0.15));
    });

    test('dark theme text is light on dark backgrounds', () {
      final theme = SuperFarmerTheme.darkTheme;
      final onSurface = theme.colorScheme.onSurface;
      final surfaceLuminance =
          HSLColor.fromColor(onSurface).lightness;
      // onSurface should be light (high luminance)
      expect(surfaceLuminance, greaterThan(0.7));
    });

    test('legacy theme getter returns light theme', () {
      expect(SuperFarmerTheme.theme, SuperFarmerTheme.lightTheme);
    });
  });
}
