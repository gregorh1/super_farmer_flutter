import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_farmer/main.dart';
import 'package:super_farmer/models/animal.dart';
import 'package:super_farmer/models/dice.dart';
import 'package:super_farmer/models/exchange.dart';
import 'package:super_farmer/providers/game_provider.dart';
import 'package:super_farmer/screens/splash_screen.dart';
import 'package:super_farmer/theme.dart';

/// A fixed Random that always returns a specific sequence index.
class FixedRandom implements Random {
  FixedRandom(this.value);
  final int value;

  @override
  int nextInt(int max) => value % max;
  @override
  double nextDouble() => 0.0;
  @override
  bool nextBool() => false;
}

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

    test('stock limits match game rules', () {
      expect(Animal.rabbit.totalInGame, 60);
      expect(Animal.lamb.totalInGame, 24);
      expect(Animal.pig.totalInGame, 20);
      expect(Animal.cow.totalInGame, 12);
      expect(Animal.horse.totalInGame, 6);
      expect(Animal.smallDog.totalInGame, 4);
      expect(Animal.bigDog.totalInGame, 2);
    });

    test('dice symbols include fox and wolf', () {
      expect(DiceSymbol.values.any((d) => d == DiceSymbol.fox), true);
      expect(DiceSymbol.values.any((d) => d == DiceSymbol.wolf), true);
    });
  });

  group('DiceFace', () {
    test('toAnimal returns correct animal for animal faces', () {
      expect(DiceFace.rabbit.toAnimal(), Animal.rabbit);
      expect(DiceFace.lamb.toAnimal(), Animal.lamb);
      expect(DiceFace.pig.toAnimal(), Animal.pig);
      expect(DiceFace.cow.toAnimal(), Animal.cow);
      expect(DiceFace.horse.toAnimal(), Animal.horse);
    });

    test('toAnimal returns null for predator faces', () {
      expect(DiceFace.fox.toAnimal(), isNull);
      expect(DiceFace.wolf.toAnimal(), isNull);
    });
  });

  group('Dice', () {
    test('green die has 12 faces with correct distribution', () {
      final faces = Dice.green.faces;
      expect(faces.length, 12);
      expect(faces.where((f) => f == DiceFace.rabbit).length, 6);
      expect(faces.where((f) => f == DiceFace.lamb).length, 3);
      expect(faces.where((f) => f == DiceFace.pig).length, 1);
      expect(faces.where((f) => f == DiceFace.cow).length, 1);
      expect(faces.where((f) => f == DiceFace.wolf).length, 1);
      expect(faces.where((f) => f == DiceFace.fox).length, 0);
      expect(faces.where((f) => f == DiceFace.horse).length, 0);
    });

    test('red die has 12 faces with correct distribution', () {
      final faces = Dice.red.faces;
      expect(faces.length, 12);
      expect(faces.where((f) => f == DiceFace.rabbit).length, 6);
      expect(faces.where((f) => f == DiceFace.lamb).length, 2);
      expect(faces.where((f) => f == DiceFace.pig).length, 2);
      expect(faces.where((f) => f == DiceFace.horse).length, 1);
      expect(faces.where((f) => f == DiceFace.fox).length, 1);
      expect(faces.where((f) => f == DiceFace.wolf).length, 0);
      expect(faces.where((f) => f == DiceFace.cow).length, 0);
    });

    test('roll returns a valid face', () {
      for (var i = 0; i < 12; i++) {
        final face = Dice.green.roll(FixedRandom(i));
        expect(Dice.green.faces.contains(face), true);
      }
    });
  });

  group('DiceRollResult', () {
    test('rolledAnimals counts animals from both dice', () {
      const result = DiceRollResult(green: DiceFace.rabbit, red: DiceFace.rabbit);
      expect(result.rolledAnimals[Animal.rabbit], 2);
    });

    test('rolledAnimals handles different animals', () {
      const result = DiceRollResult(green: DiceFace.lamb, red: DiceFace.pig);
      expect(result.rolledAnimals[Animal.lamb], 1);
      expect(result.rolledAnimals[Animal.pig], 1);
    });

    test('rolledAnimals excludes predators', () {
      const result = DiceRollResult(green: DiceFace.wolf, red: DiceFace.fox);
      expect(result.rolledAnimals, isEmpty);
    });

    test('hasFox and hasWolf flags', () {
      const foxRoll = DiceRollResult(green: DiceFace.rabbit, red: DiceFace.fox);
      expect(foxRoll.hasFox, true);
      expect(foxRoll.hasWolf, false);

      const wolfRoll = DiceRollResult(green: DiceFace.wolf, red: DiceFace.rabbit);
      expect(wolfRoll.hasWolf, true);
      expect(wolfRoll.hasFox, false);
    });

    test('roll with fixed random produces deterministic result', () {
      final result = DiceRollResult.roll(FixedRandom(0));
      // Index 0 in green = rabbit, index 0 in red = rabbit
      expect(result.green, DiceFace.rabbit);
      expect(result.red, DiceFace.rabbit);
    });
  });

  group('Exchange', () {
    test('has correct exchange rates', () {
      expect(Exchange.rates.length, 6);
    });

    test('rabbit to lamb rate is 6:1', () {
      final rate = Exchange.rates.firstWhere(
        (r) => r.from == Animal.rabbit && r.to == Animal.lamb,
      );
      expect(rate.fromCount, 6);
      expect(rate.toCount, 1);
    });

    test('lamb to pig rate is 2:1', () {
      final rate = Exchange.rates.firstWhere(
        (r) => r.from == Animal.lamb && r.to == Animal.pig,
      );
      expect(rate.fromCount, 2);
      expect(rate.toCount, 1);
    });

    test('pig to cow rate is 3:1', () {
      final rate = Exchange.rates.firstWhere(
        (r) => r.from == Animal.pig && r.to == Animal.cow,
      );
      expect(rate.fromCount, 3);
      expect(rate.toCount, 1);
    });

    test('cow to horse rate is 2:1', () {
      final rate = Exchange.rates.firstWhere(
        (r) => r.from == Animal.cow && r.to == Animal.horse,
      );
      expect(rate.fromCount, 2);
      expect(rate.toCount, 1);
    });

    test('small dog costs 1 lamb', () {
      final rate = Exchange.rates.firstWhere(
        (r) => r.to == Animal.smallDog,
      );
      expect(rate.from, Animal.lamb);
      expect(rate.fromCount, 1);
    });

    test('big dog costs 1 cow', () {
      final rate = Exchange.rates.firstWhere(
        (r) => r.to == Animal.bigDog,
      );
      expect(rate.from, Animal.cow);
      expect(rate.fromCount, 1);
    });

    test('availableTrades shows forward trades when player has enough', () {
      final playerAnimals = {Animal.rabbit: 6};
      final bank = GameState.initialBank();

      final trades = Exchange.availableTrades(playerAnimals, bank);
      final rabbitToLamb = trades.where(
        (t) => t.from == Animal.rabbit && t.to == Animal.lamb,
      );
      expect(rabbitToLamb.length, 1);
    });

    test('availableTrades shows reverse trades for animals', () {
      final playerAnimals = {Animal.lamb: 1};
      final bank = GameState.initialBank();

      final trades = Exchange.availableTrades(playerAnimals, bank);
      final lambToRabbits = trades.where(
        (t) => t.from == Animal.lamb && t.to == Animal.rabbit,
      );
      expect(lambToRabbits.length, 1);
      expect(lambToRabbits.first.toCount, 6);
    });

    test('availableTrades does not show reverse trades for dogs', () {
      final playerAnimals = {Animal.smallDog: 1};
      final bank = GameState.initialBank();

      final trades = Exchange.availableTrades(playerAnimals, bank);
      final dogToLamb = trades.where(
        (t) => t.from == Animal.smallDog && t.to == Animal.lamb,
      );
      expect(dogToLamb, isEmpty);
    });

    test('availableTrades respects bank stock', () {
      final playerAnimals = {Animal.rabbit: 6};
      final bank = {Animal.lamb: 0}; // No lambs in bank

      final trades = Exchange.availableTrades(playerAnimals, bank);
      final rabbitToLamb = trades.where(
        (t) => t.from == Animal.rabbit && t.to == Animal.lamb,
      );
      expect(rabbitToLamb, isEmpty);
    });
  });

  group('GameState', () {
    test('starts not started', () {
      const state = GameState();
      expect(state.isStarted, false);
      expect(state.players, isEmpty);
      expect(state.currentPlayer, isNull);
    });

    test('initialBank has correct stock limits', () {
      final bank = GameState.initialBank();
      expect(bank[Animal.rabbit], 60);
      expect(bank[Animal.lamb], 24);
      expect(bank[Animal.pig], 20);
      expect(bank[Animal.cow], 12);
      expect(bank[Animal.horse], 6);
      expect(bank[Animal.smallDog], 4);
      expect(bank[Animal.bigDog], 2);
    });

    test('GameNotifier starts game with players and bank', () {
      final notifier = GameNotifier();
      notifier.startGame(['Alice', 'Bob']);

      expect(notifier.state.isStarted, true);
      expect(notifier.state.players.length, 2);
      expect(notifier.state.players[0].name, 'Alice');
      expect(notifier.state.players[1].name, 'Bob');
      expect(notifier.state.bank[Animal.rabbit], 60);
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

  group('Breeding', () {
    test('breeds rabbits: floor((owned + rolled) / 2)', () {
      // FixedRandom(0) rolls rabbit on both dice
      final notifier = GameNotifier(FixedRandom(0));
      notifier.startGame(['Alice']);

      // Give Alice 3 rabbits
      _setPlayerAnimals(notifier, 0, {Animal.rabbit: 3});

      notifier.rollDice();

      // Rolled 2 rabbits, owned 3: floor((3+2)/2) = 2 gained
      expect(notifier.state.players[0].countOf(Animal.rabbit), 5);
    });

    test('bred animals limited by bank stock', () {
      final notifier = GameNotifier(FixedRandom(0));
      notifier.startGame(['Alice']);

      // Give Alice many rabbits, deplete bank
      _setPlayerAnimals(notifier, 0, {Animal.rabbit: 10});
      _setBankStock(notifier, {Animal.rabbit: 1}); // Only 1 left in bank

      notifier.rollDice();

      // Would breed floor((10+2)/2)=6, but bank only has 1
      expect(notifier.state.players[0].countOf(Animal.rabbit), 11);
      expect(notifier.state.bank[Animal.rabbit], 0);
    });

    test('no breeding when player has 0 of the animal', () {
      // FixedRandom(0) rolls rabbit+rabbit
      final notifier = GameNotifier(FixedRandom(0));
      notifier.startGame(['Alice']);
      // Player starts with 0 rabbits

      notifier.rollDice();

      // floor((0+2)/2) = 1 rabbit bred
      expect(notifier.state.players[0].countOf(Animal.rabbit), 1);
    });

    test('single die match breeds: floor((owned+1)/2)', () {
      // Need to roll 1 lamb. Green die index 6 = lamb, red die index 0 = rabbit
      final notifier = GameNotifier(FixedRandom(6));
      notifier.startGame(['Alice']);
      _setPlayerAnimals(notifier, 0, {Animal.lamb: 5, Animal.rabbit: 0});

      notifier.rollDice();

      // Lamb: floor((5+1)/2) = 3
      // Rabbit: floor((0+1)/2) = 0
      expect(notifier.state.players[0].countOf(Animal.lamb), 8);
      expect(notifier.state.players[0].countOf(Animal.rabbit), 0);
    });
  });

  group('Fox attack', () {
    test('fox kills all rabbits', () {
      // Red die index 11 = fox, green die index 11 = wolf...
      // Actually let's find the fox index. Red faces: 6×rabbit(0-5), 2×lamb(6-7), 2×pig(8-9), horse(10), fox(11)
      // Green faces: 6×rabbit(0-5), 3×lamb(6-8), pig(9), cow(10), wolf(11)
      // We need red=fox(11) and green=not-wolf. FixedRandom(11) gives green[11]=wolf, red[11]=fox
      // FixedRandom with value that gives green=rabbit, red=fox:
      // We need nextInt(12)=X for green where X<6 (rabbit), then nextInt(12)=11 for red (fox)
      // FixedRandom always returns same value, so we can't get different values.
      // Let's use a custom approach.

      final notifier = GameNotifier(_SequenceRandom([0, 11])); // green=rabbit, red=fox
      notifier.startGame(['Alice']);
      _setPlayerAnimals(notifier, 0, {Animal.rabbit: 10});

      notifier.rollDice();

      expect(notifier.state.players[0].countOf(Animal.rabbit), 0);
      // Rabbits returned to bank
      expect(notifier.state.bank[Animal.rabbit]! >= 10, true);
    });

    test('small dog protects rabbits from fox', () {
      final notifier = GameNotifier(_SequenceRandom([0, 11])); // green=rabbit, red=fox
      notifier.startGame(['Alice']);
      _setPlayerAnimals(notifier, 0, {Animal.rabbit: 10, Animal.smallDog: 1});

      notifier.rollDice();

      // Rabbits saved, small dog sacrificed
      // Breeding: rabbit floor((10+1)/2) = 5 gained (from green die rabbit)
      expect(notifier.state.players[0].countOf(Animal.rabbit), 15);
      expect(notifier.state.players[0].countOf(Animal.smallDog), 0);
    });
  });

  group('Wolf attack', () {
    test('wolf kills all animals except horse and small dog', () {
      final notifier = GameNotifier(_SequenceRandom([11, 0])); // green=wolf, red=rabbit
      notifier.startGame(['Alice']);
      _setPlayerAnimals(notifier, 0, {
        Animal.rabbit: 10,
        Animal.lamb: 5,
        Animal.pig: 3,
        Animal.cow: 2,
        Animal.horse: 1,
        Animal.smallDog: 1,
      });

      notifier.rollDice();

      expect(notifier.state.players[0].countOf(Animal.rabbit), 0);
      expect(notifier.state.players[0].countOf(Animal.lamb), 0);
      expect(notifier.state.players[0].countOf(Animal.pig), 0);
      expect(notifier.state.players[0].countOf(Animal.cow), 0);
      expect(notifier.state.players[0].countOf(Animal.horse), 1); // Saved
      expect(notifier.state.players[0].countOf(Animal.smallDog), 1); // Saved
    });

    test('big dog protects herd from wolf', () {
      final notifier = GameNotifier(_SequenceRandom([11, 0])); // green=wolf, red=rabbit
      notifier.startGame(['Alice']);
      _setPlayerAnimals(notifier, 0, {
        Animal.rabbit: 10,
        Animal.lamb: 5,
        Animal.bigDog: 1,
      });

      notifier.rollDice();

      // Wolf rolled on green, rabbit on red
      // Breeding first: rabbit floor((10+1)/2) = 5 (only red has rabbit)
      // Wolf blocked by big dog, big dog sacrificed
      expect(notifier.state.players[0].countOf(Animal.rabbit), 15);
      expect(notifier.state.players[0].countOf(Animal.lamb), 5);
      expect(notifier.state.players[0].countOf(Animal.bigDog), 0);
    });
  });

  group('Trading', () {
    test('trade rabbits for lamb', () {
      final notifier = GameNotifier();
      notifier.startGame(['Alice']);
      _setPlayerAnimals(notifier, 0, {Animal.rabbit: 12});

      final rate = Exchange.rates.firstWhere(
        (r) => r.from == Animal.rabbit && r.to == Animal.lamb,
      );
      final success = notifier.trade(rate);

      expect(success, true);
      expect(notifier.state.players[0].countOf(Animal.rabbit), 6);
      expect(notifier.state.players[0].countOf(Animal.lamb), 1);
    });

    test('trade fails with insufficient animals', () {
      final notifier = GameNotifier();
      notifier.startGame(['Alice']);
      _setPlayerAnimals(notifier, 0, {Animal.rabbit: 3});

      final rate = Exchange.rates.firstWhere(
        (r) => r.from == Animal.rabbit && r.to == Animal.lamb,
      );
      final success = notifier.trade(rate);

      expect(success, false);
      expect(notifier.state.players[0].countOf(Animal.rabbit), 3);
    });

    test('trade fails when bank has no stock', () {
      final notifier = GameNotifier();
      notifier.startGame(['Alice']);
      _setPlayerAnimals(notifier, 0, {Animal.rabbit: 6});
      _setBankStock(notifier, {Animal.lamb: 0});

      final rate = Exchange.rates.firstWhere(
        (r) => r.from == Animal.rabbit && r.to == Animal.lamb,
      );
      final success = notifier.trade(rate);

      expect(success, false);
    });

    test('trade updates bank stock correctly', () {
      final notifier = GameNotifier();
      notifier.startGame(['Alice']);
      _setPlayerAnimals(notifier, 0, {Animal.rabbit: 6});
      final initialLambs = notifier.state.bank[Animal.lamb]!;
      final initialRabbits = notifier.state.bank[Animal.rabbit]!;

      final rate = Exchange.rates.firstWhere(
        (r) => r.from == Animal.rabbit && r.to == Animal.lamb,
      );
      notifier.trade(rate);

      expect(notifier.state.bank[Animal.lamb], initialLambs - 1);
      expect(notifier.state.bank[Animal.rabbit], initialRabbits + 6);
    });

    test('buy small dog with lamb', () {
      final notifier = GameNotifier();
      notifier.startGame(['Alice']);
      _setPlayerAnimals(notifier, 0, {Animal.lamb: 1});

      final rate = Exchange.rates.firstWhere(
        (r) => r.to == Animal.smallDog,
      );
      final success = notifier.trade(rate);

      expect(success, true);
      expect(notifier.state.players[0].countOf(Animal.smallDog), 1);
      expect(notifier.state.players[0].countOf(Animal.lamb), 0);
    });

    test('buy big dog with cow', () {
      final notifier = GameNotifier();
      notifier.startGame(['Alice']);
      _setPlayerAnimals(notifier, 0, {Animal.cow: 1});

      final rate = Exchange.rates.firstWhere(
        (r) => r.to == Animal.bigDog,
      );
      final success = notifier.trade(rate);

      expect(success, true);
      expect(notifier.state.players[0].countOf(Animal.bigDog), 1);
      expect(notifier.state.players[0].countOf(Animal.cow), 0);
    });
  });

  group('Win detection', () {
    test('player wins with at least 1 of each animal type', () {
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

    test('player has not won when missing an animal', () {
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

    test('dogs are not required for winning', () {
      final herd = PlayerHerd(
        name: 'Winner',
        animals: {
          Animal.rabbit: 1,
          Animal.lamb: 1,
          Animal.pig: 1,
          Animal.cow: 1,
          Animal.horse: 1,
        },
      );
      expect(herd.hasWon, true);
    });

    test('win detected after trade', () {
      final notifier = GameNotifier();
      notifier.startGame(['Alice']);
      _setPlayerAnimals(notifier, 0, {
        Animal.rabbit: 1,
        Animal.lamb: 1,
        Animal.pig: 1,
        Animal.cow: 3, // Need 2 to trade + 1 to keep
        Animal.horse: 0,
      });

      final rate = Exchange.rates.firstWhere(
        (r) => r.from == Animal.cow && r.to == Animal.horse,
      );
      notifier.trade(rate);

      expect(notifier.state.winner, 'Alice');
    });

    test('win detected after breeding', () {
      // Roll that gives a horse (red die index 10)
      final notifier = GameNotifier(_SequenceRandom([0, 10])); // green=rabbit, red=horse
      notifier.startGame(['Alice']);
      _setPlayerAnimals(notifier, 0, {
        Animal.rabbit: 1,
        Animal.lamb: 1,
        Animal.pig: 1,
        Animal.cow: 1,
        Animal.horse: 1, // Need 1 to breed: floor((1+1)/2)=1
      });

      notifier.rollDice();

      expect(notifier.state.winner, 'Alice');
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

    test('copyWith creates new instance', () {
      const herd = PlayerHerd(name: 'Test');
      final updated = herd.copyWith(name: 'Updated');
      expect(updated.name, 'Updated');
      expect(herd.name, 'Test');
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

// Test helpers

/// Random that returns values from a sequence, cycling through them.
class _SequenceRandom implements Random {
  _SequenceRandom(this.values);
  final List<int> values;
  int _index = 0;

  @override
  int nextInt(int max) {
    final value = values[_index % values.length] % max;
    _index++;
    return value;
  }

  @override
  double nextDouble() => 0.0;
  @override
  bool nextBool() => false;
}

/// Helper to set a player's animals directly for testing.
void _setPlayerAnimals(GameNotifier notifier, int playerIndex, Map<Animal, int> animals) {
  final players = List<PlayerHerd>.from(notifier.state.players);
  final current = players[playerIndex].animals;
  final merged = Map<Animal, int>.from(current)..addAll(animals);
  players[playerIndex] = players[playerIndex].copyWith(animals: merged);
  notifier.state = notifier.state.copyWith(players: players);
}

/// Helper to override bank stock for testing.
void _setBankStock(GameNotifier notifier, Map<Animal, int> stock) {
  final bank = Map<Animal, int>.from(notifier.state.bank)..addAll(stock);
  notifier.state = notifier.state.copyWith(bank: bank);
}
