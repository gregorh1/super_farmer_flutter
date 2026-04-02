import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_farmer/main.dart';
import 'package:super_farmer/models/animal.dart';
import 'package:super_farmer/providers/game_provider.dart';
import 'package:super_farmer/theme.dart';

void main() {
  group('SuperFarmerApp', () {
    testWidgets('renders app with title', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: SuperFarmerApp()));
      await tester.pumpAndSettle();

      expect(find.text('Super Farmer'), findsWidgets);
    });

    testWidgets('shows bottom navigation', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: SuperFarmerApp()));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Game'), findsOneWidget);
      expect(find.text('Rules'), findsOneWidget);
    });

    testWidgets('navigates to game screen', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: SuperFarmerApp()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Game'));
      await tester.pumpAndSettle();

      expect(find.text('New Game'), findsOneWidget);
    });

    testWidgets('navigates to rules screen', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: SuperFarmerApp()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rules'));
      await tester.pumpAndSettle();

      expect(find.text('How to Play'), findsOneWidget);
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
    test('produces a valid ThemeData', () {
      final theme = SuperFarmerTheme.theme;
      expect(theme, isA<ThemeData>());
      expect(theme.colorScheme.primary, isNotNull);
      expect(theme.scaffoldBackgroundColor, const Color(0xFFF1F8E9));
    });
  });
}
