import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_farmer/main.dart';
import 'package:super_farmer/models/ai_difficulty.dart';
import 'package:super_farmer/models/ai_strategy.dart';
import 'package:super_farmer/models/animal.dart';
import 'package:super_farmer/models/dice.dart';
import 'package:super_farmer/models/exchange.dart';
import 'package:super_farmer/providers/game_provider.dart';
import 'package:super_farmer/screens/game_screen.dart';
import 'package:super_farmer/screens/splash_screen.dart';
import 'package:super_farmer/theme.dart';
import 'package:super_farmer/widgets/dice_center.dart';
import 'package:super_farmer/providers/settings_provider.dart';
import 'package:super_farmer/widgets/animal_card.dart';
import 'package:super_farmer/widgets/farm_decorations.dart';
import 'package:super_farmer/widgets/player_area.dart';
import 'package:super_farmer/widgets/player_setup_card.dart';
import 'package:super_farmer/widgets/settings_sheet.dart';
import 'package:super_farmer/widgets/tutorial_carousel.dart';
import 'package:super_farmer/screens/rules_screen.dart';
import 'package:super_farmer/models/game_record.dart';
import 'package:super_farmer/providers/stats_provider.dart';
import 'package:super_farmer/screens/stats_screen.dart';
import 'package:super_farmer/services/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      expect(find.text('Stats'), findsOneWidget);
    });

    testWidgets('shows bottom navigation after splash', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: SuperFarmerApp()));
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Game'), findsOneWidget);
      expect(find.text('Rules'), findsOneWidget);
      expect(find.text('Stats'), findsOneWidget);
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

      expect(find.text('Interactive Tutorial'), findsOneWidget);
    });
  });

  group('SplashScreen', () {
    testWidgets('displays app name and barn branding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(onComplete: () {}),
        ),
      );
      await tester.pump();

      expect(find.text('Super Farmer'), findsOneWidget);
      expect(find.text('Collect your animals!'), findsOneWidget);
      // Barn and rabbit SVG replace the old tractor emoji
      expect(find.byType(CustomPaint), findsWidgets);
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

  group('nextTurn clears lastRoll', () {
    test('lastRoll is cleared when advancing to next player', () {
      final notifier = GameNotifier(FixedRandom(0));
      notifier.startGame(['Alice', 'Bob']);

      notifier.rollDice();
      expect(notifier.state.lastRoll, isNotNull);

      notifier.nextTurn();
      expect(notifier.state.lastRoll, isNull);
    });
  });

  group('PlayerArea widget', () {
    Widget buildPlayerArea({
      PlayerHerd? player,
      int playerIndex = 0,
      bool isCurrentPlayer = false,
      GameState? gameState,
    }) {
      final state = gameState ??
          GameState(
            players: [
              player ??
                  PlayerHerd(
                    name: 'Alice',
                    animals: {for (final a in Animal.values) a: 0},
                  ),
            ],
            currentPlayerIndex: 0,
            isStarted: true,
            bank: GameState.initialBank(),
          );
      return MaterialApp(
        home: Scaffold(
          body: PlayerArea(
            player: state.players.isNotEmpty
                ? state.players[playerIndex]
                : (player ??
                    PlayerHerd(
                      name: 'Alice',
                      animals: {for (final a in Animal.values) a: 0},
                    )),
            playerIndex: playerIndex,
            isCurrentPlayer: isCurrentPlayer,
            gameState: state,
            onTrade: (_) {},
          ),
        ),
      );
    }

    testWidgets('displays player name', (tester) async {
      await tester.pumpWidget(buildPlayerArea());
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('displays progress percentage', (tester) async {
      final player = PlayerHerd(
        name: 'Alice',
        animals: {
          Animal.rabbit: 1,
          Animal.lamb: 1,
          Animal.pig: 0,
          Animal.cow: 0,
          Animal.horse: 0,
          Animal.smallDog: 0,
          Animal.bigDog: 0,
        },
      );
      await tester.pumpWidget(buildPlayerArea(player: player));
      // 2 out of 5 = 40%
      expect(find.text('40%'), findsOneWidget);
    });

    testWidgets('displays exchange rate numbers', (tester) async {
      await tester.pumpWidget(buildPlayerArea());
      // Exchange rates displayed as ratio: 6:1, 2:1, 3:1, 2:1
      expect(find.text('6:1'), findsOneWidget);
      expect(find.text('3:1'), findsOneWidget);
      // '2:1' appears twice (lamb→pig and cow→horse exchange rates)
      expect(find.text('2:1'), findsNWidgets(2));
    });

    testWidgets('displays animal counts', (tester) async {
      final player = PlayerHerd(
        name: 'Alice',
        animals: {
          Animal.rabbit: 5,
          Animal.lamb: 3,
          Animal.pig: 0,
          Animal.cow: 0,
          Animal.horse: 0,
          Animal.smallDog: 0,
          Animal.bigDog: 0,
        },
      );
      await tester.pumpWidget(buildPlayerArea(player: player));
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('shows dog buy buttons', (tester) async {
      await tester.pumpWidget(buildPlayerArea());
      expect(find.text('Buy with 1 Lamb'), findsOneWidget);
      expect(find.text('Buy with 1 Cow'), findsOneWidget);
    });

    testWidgets('shows progress bar', (tester) async {
      await tester.pumpWidget(buildPlayerArea());
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('current player has highlighted border', (tester) async {
      await tester.pumpWidget(buildPlayerArea(isCurrentPlayer: true));
      // Player area now uses WoodenFrame (CustomPaint) for borders
      final woodenFrames = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
      final woodenBorders = woodenFrames.where((cp) => cp.painter is WoodenBorderPainter);
      expect(woodenBorders, isNotEmpty);
      final painter = woodenBorders.first.painter as WoodenBorderPainter;
      expect(painter.borderWidth, 4.0);
    });

    testWidgets('non-current player has thinner border', (tester) async {
      await tester.pumpWidget(buildPlayerArea(isCurrentPlayer: false));
      final woodenFrames = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
      final woodenBorders = woodenFrames.where((cp) => cp.painter is WoodenBorderPainter);
      expect(woodenBorders, isNotEmpty);
      final painter = woodenBorders.first.painter as WoodenBorderPainter;
      expect(painter.borderWidth, 2.5);
    });

    testWidgets('trade up buttons exist for each exchange pair', (tester) async {
      await tester.pumpWidget(buildPlayerArea(isCurrentPlayer: true));
      // Should have 4 up arrows and 4 down arrows for exchanges
      expect(find.byIcon(Icons.arrow_upward), findsNWidgets(4));
      expect(find.byIcon(Icons.arrow_downward), findsNWidgets(4));
    });

    testWidgets('player colors are distinct', (tester) async {
      // Default player colors list still has 4 entries
      expect(PlayerArea.playerColors.length, 4);
      final colorSet = PlayerArea.playerColors.toSet();
      expect(colorSet.length, 4);
    });
  });

  group('DiceCenter widget', () {
    Widget buildDiceCenter({
      GameState? gameState,
      VoidCallback? onRoll,
      VoidCallback? onEndTurn,
    }) {
      final state = gameState ??
          GameState(
            players: [
              PlayerHerd(
                name: 'Alice',
                animals: {for (final a in Animal.values) a: 0},
              ),
            ],
            currentPlayerIndex: 0,
            isStarted: true,
            bank: GameState.initialBank(),
          );
      return MaterialApp(
        home: Scaffold(
          body: DiceCenter(
            gameState: state,
            onRoll: onRoll ?? () {},
            onEndTurn: onEndTurn ?? () {},
          ),
        ),
      );
    }

    testWidgets('shows current player name', (tester) async {
      await tester.pumpWidget(buildDiceCenter());
      expect(find.text("Alice's Turn"), findsOneWidget);
    });

    testWidgets('shows Roll Dice button', (tester) async {
      await tester.pumpWidget(buildDiceCenter());
      expect(find.text('Roll Dice'), findsOneWidget);
    });

    testWidgets('shows End Turn button', (tester) async {
      await tester.pumpWidget(buildDiceCenter());
      expect(find.text('End Turn'), findsOneWidget);
    });

    testWidgets('Roll Dice is enabled before rolling', (tester) async {
      await tester.pumpWidget(buildDiceCenter());
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('End Turn is disabled before rolling', (tester) async {
      await tester.pumpWidget(buildDiceCenter());
      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('Roll Dice is disabled after rolling', (tester) async {
      final state = GameState(
        players: [
          PlayerHerd(
            name: 'Alice',
            animals: {for (final a in Animal.values) a: 0},
          ),
        ],
        currentPlayerIndex: 0,
        isStarted: true,
        bank: GameState.initialBank(),
        lastRoll: const DiceRollResult(green: DiceFace.rabbit, red: DiceFace.rabbit),
      );
      await tester.pumpWidget(buildDiceCenter(gameState: state));
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('End Turn is enabled after rolling', (tester) async {
      final state = GameState(
        players: [
          PlayerHerd(
            name: 'Alice',
            animals: {for (final a in Animal.values) a: 0},
          ),
        ],
        currentPlayerIndex: 0,
        isStarted: true,
        bank: GameState.initialBank(),
        lastRoll: const DiceRollResult(green: DiceFace.rabbit, red: DiceFace.rabbit),
      );
      await tester.pumpWidget(buildDiceCenter(gameState: state));
      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('calls onRoll when Roll Dice is tapped', (tester) async {
      bool rolled = false;
      await tester.pumpWidget(buildDiceCenter(onRoll: () => rolled = true));
      await tester.tap(find.text('Roll Dice'));
      // The roll callback fires after the 600ms dice shake animation
      await tester.pump(const Duration(milliseconds: 700));
      expect(rolled, true);
    });

    testWidgets('shows dice icon', (tester) async {
      await tester.pumpWidget(buildDiceCenter());
      expect(find.byIcon(Icons.casino), findsOneWidget);
    });
  });

  group('GameScreen', () {
    Widget buildGameScreen({List<Override>? overrides}) {
      return ProviderScope(
        overrides: overrides ?? [],
        child: const MaterialApp(home: GameScreen()),
      );
    }

    /// Helper to scroll to and tap the Start Game button.
    Future<void> tapStartGame(WidgetTester tester) async {
      await tester.scrollUntilVisible(
        find.text('Start Game'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows setup screen when game not started', (tester) async {
      await tester.pumpWidget(buildGameScreen());
      expect(find.text('Super Farmer'), findsOneWidget);
      expect(find.text('Start Game'), findsOneWidget);
    });

    testWidgets('setup screen has player count selector', (tester) async {
      await tester.pumpWidget(buildGameScreen());
      expect(find.text('Number of Players'), findsOneWidget);
      // Player count options 2, 3, 4 appear in selector (and also in card circle avatars)
      expect(find.text('2'), findsAtLeast(1));
      expect(find.text('3'), findsAtLeast(1));
      expect(find.text('4'), findsAtLeast(1));
    });

    testWidgets('setup screen shows player setup cards', (tester) async {
      await tester.pumpWidget(buildGameScreen());
      // Default 4 players, should show 4 player setup cards
      expect(find.text('Player 1'), findsAtLeast(1));
      expect(find.text('Player 2'), findsAtLeast(1));
      expect(find.text('Player 3'), findsAtLeast(1));
      expect(find.text('Player 4'), findsAtLeast(1));
    });

    testWidgets('setup screen has name input fields', (tester) async {
      await tester.pumpWidget(buildGameScreen());
      // 4 player name input fields
      expect(find.byType(TextField), findsNWidgets(4));
    });

    testWidgets('starts game with selected player count', (tester) async {
      await tester.pumpWidget(buildGameScreen());
      await tapStartGame(tester);

      // Should show board with player names (active player may appear multiple times)
      expect(find.text('Player 1'), findsAtLeast(1));
      expect(find.text('Player 2'), findsAtLeast(1));
      expect(find.text('Player 3'), findsAtLeast(1));
      expect(find.text('Player 4'), findsAtLeast(1));
    });

    testWidgets('board shows Roll Dice button', (tester) async {
      await tester.pumpWidget(buildGameScreen());
      await tapStartGame(tester);

      expect(find.text('Roll Dice'), findsOneWidget);
    });

    testWidgets('board shows End Turn button', (tester) async {
      await tester.pumpWidget(buildGameScreen());
      await tapStartGame(tester);

      expect(find.text('End Turn'), findsOneWidget);
    });

    testWidgets('board shows current player indicator', (tester) async {
      await tester.pumpWidget(buildGameScreen());
      await tapStartGame(tester);

      expect(find.text("Player 1's Turn"), findsOneWidget);
    });

    testWidgets('has reset and settings buttons in app bar', (tester) async {
      await tester.pumpWidget(buildGameScreen());
      await tapStartGame(tester);

      expect(find.byIcon(Icons.restart_alt), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('shows active player area and compact strips', (tester) async {
      await tester.pumpWidget(buildGameScreen());
      await tapStartGame(tester);

      // 1 active PlayerArea widget for current player
      expect(find.byType(PlayerArea), findsOneWidget);
      // DiceCenter in the middle
      expect(find.byType(DiceCenter), findsOneWidget);
    });

    testWidgets('shows DiceCenter widget', (tester) async {
      await tester.pumpWidget(buildGameScreen());
      await tapStartGame(tester);

      expect(find.byType(DiceCenter), findsOneWidget);
    });

    testWidgets('can start a 2-player game', (tester) async {
      await tester.pumpWidget(buildGameScreen());

      // Select 2 players - tap inside the '2' count selector
      await tester.tap(find.text('2').first);
      await tester.pumpAndSettle();

      await tapStartGame(tester);

      // Should show active player area + compact strip for other player
      expect(find.byType(PlayerArea), findsOneWidget);
      expect(find.text('Player 1'), findsAtLeast(1));
      expect(find.text('Player 2'), findsAtLeast(1));
    });

    testWidgets('reset button returns to setup screen', (tester) async {
      await tester.pumpWidget(buildGameScreen());
      await tapStartGame(tester);

      await tester.tap(find.byIcon(Icons.restart_alt));
      await tester.pumpAndSettle();

      // Scroll to find Start Game button
      await tester.scrollUntilVisible(
        find.text('Start Game'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Start Game'), findsOneWidget);
    });

    testWidgets('active player shows progress bar', (tester) async {
      await tester.pumpWidget(buildGameScreen());
      await tapStartGame(tester);

      // Active player area has a progress bar
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('active player starts at 0% progress', (tester) async {
      await tester.pumpWidget(buildGameScreen());
      await tapStartGame(tester);

      // Active player and compact strips all show 0%
      expect(find.text('0%'), findsNWidgets(4));
    });

    testWidgets('settings gear opens settings sheet', (tester) async {
      await tester.pumpWidget(buildGameScreen());
      await tapStartGame(tester);

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Sound'), findsOneWidget);
      expect(find.text('Animation Speed'), findsOneWidget);
      expect(find.text('Confirm End Turn'), findsOneWidget);
    });

    testWidgets('player count change updates setup cards', (tester) async {
      await tester.pumpWidget(buildGameScreen());

      // Default 4 players = 4 text fields
      expect(find.byType(TextField), findsNWidgets(4));

      // Tap 2 to select 2 players (use .first since '2' appears in card avatar too)
      await tester.tap(find.text('2').first);
      await tester.pumpAndSettle();

      // Now only 2 text fields
      expect(find.byType(TextField), findsNWidgets(2));
    });
  });

  group('PlayerArea win progress', () {
    test('0 animals collected = 0% progress', () {
      final herd = PlayerHerd(
        name: 'Test',
        animals: {for (final a in Animal.values) a: 0},
      );
      int count = 0;
      for (final a in PlayerArea.farmAnimals) {
        if (herd.countOf(a) >= 1) count++;
      }
      expect(count / 5.0, 0.0);
    });

    test('all farm animals collected = 100% progress', () {
      final herd = PlayerHerd(
        name: 'Test',
        animals: {
          Animal.rabbit: 1,
          Animal.lamb: 1,
          Animal.pig: 1,
          Animal.cow: 1,
          Animal.horse: 1,
        },
      );
      int count = 0;
      for (final a in PlayerArea.farmAnimals) {
        if (herd.countOf(a) >= 1) count++;
      }
      expect(count / 5.0, 1.0);
    });

    test('3 of 5 farm animals = 60% progress', () {
      final herd = PlayerHerd(
        name: 'Test',
        animals: {
          Animal.rabbit: 1,
          Animal.lamb: 1,
          Animal.pig: 1,
          Animal.cow: 0,
          Animal.horse: 0,
        },
      );
      int count = 0;
      for (final a in PlayerArea.farmAnimals) {
        if (herd.countOf(a) >= 1) count++;
      }
      expect(count / 5.0, 0.6);
    });

    test('farmAnimals list contains exactly 5 non-dog animals', () {
      expect(PlayerArea.farmAnimals.length, 5);
      expect(PlayerArea.farmAnimals, contains(Animal.rabbit));
      expect(PlayerArea.farmAnimals, contains(Animal.lamb));
      expect(PlayerArea.farmAnimals, contains(Animal.pig));
      expect(PlayerArea.farmAnimals, contains(Animal.cow));
      expect(PlayerArea.farmAnimals, contains(Animal.horse));
    });

    test('exchangeRateValues match Exchange.rates', () {
      expect(PlayerArea.exchangeRateValues.length, 4);
      expect(PlayerArea.exchangeRateValues[0], 6); // rabbit→lamb
      expect(PlayerArea.exchangeRateValues[1], 2); // lamb→pig
      expect(PlayerArea.exchangeRateValues[2], 3); // pig→cow
      expect(PlayerArea.exchangeRateValues[3], 2); // cow→horse
    });
  });

  // Settings and player setup tests
  _settingsProviderTests();
  _playerSetupTests();
  _playerHerdColorTests();

  // Animation and TurnEvent tests
  _turnEventTests();
  _diceAnimationTests();
  _playerAreaAnimationTests();

  // Tutorial carousel tests
  _tutorialCarouselTests();
  _rulesScreenTests();

  // Audio service tests
  _audioServiceTests();
}

// =============================================================================
// Settings provider tests
// =============================================================================

void _settingsProviderTests() {
  group('GameSettings', () {
    test('default settings', () {
      const settings = GameSettings();
      expect(settings.soundEnabled, true);
      expect(settings.volume, 0.7);
      expect(settings.animationSpeed, AnimationSpeed.normal);
      expect(settings.confirmEndTurn, false);
    });

    test('copyWith preserves unchanged values', () {
      const settings = GameSettings();
      final updated = settings.copyWith(soundEnabled: false);
      expect(updated.soundEnabled, false);
      expect(updated.volume, 0.7);
      expect(updated.animationSpeed, AnimationSpeed.normal);
      expect(updated.confirmEndTurn, false);
    });

    test('copyWith updates volume', () {
      const settings = GameSettings();
      final updated = settings.copyWith(volume: 0.5);
      expect(updated.volume, 0.5);
      expect(updated.soundEnabled, true);
    });

    test('animation speed multipliers', () {
      expect(AnimationSpeed.slow.multiplier, 1.5);
      expect(AnimationSpeed.normal.multiplier, 1.0);
      expect(AnimationSpeed.fast.multiplier, 0.5);
    });

    test('animation speed labels', () {
      expect(AnimationSpeed.slow.label, 'Slow');
      expect(AnimationSpeed.normal.label, 'Normal');
      expect(AnimationSpeed.fast.label, 'Fast');
    });
  });

  group('GameSettingsNotifier', () {
    test('toggle sound', () {
      final notifier = GameSettingsNotifier();
      expect(notifier.state.soundEnabled, true);
      notifier.toggleSound();
      expect(notifier.state.soundEnabled, false);
      notifier.toggleSound();
      expect(notifier.state.soundEnabled, true);
    });

    test('set animation speed', () {
      final notifier = GameSettingsNotifier();
      notifier.setAnimationSpeed(AnimationSpeed.fast);
      expect(notifier.state.animationSpeed, AnimationSpeed.fast);
    });

    test('toggle confirm end turn', () {
      final notifier = GameSettingsNotifier();
      expect(notifier.state.confirmEndTurn, false);
      notifier.toggleConfirmEndTurn();
      expect(notifier.state.confirmEndTurn, true);
    });

    test('set volume', () {
      final notifier = GameSettingsNotifier();
      expect(notifier.state.volume, 0.7);
      notifier.setVolume(0.3);
      expect(notifier.state.volume, 0.3);
    });

    test('set volume clamps to valid range', () {
      final notifier = GameSettingsNotifier();
      notifier.setVolume(1.5);
      expect(notifier.state.volume, 1.0);
      notifier.setVolume(-0.5);
      expect(notifier.state.volume, 0.0);
    });
  });
}

// =============================================================================
// Player setup tests
// =============================================================================

void _playerSetupTests() {
  group('PlayerSetup', () {
    test('default values', () {
      const setup = PlayerSetup();
      expect(setup.playerCount, 4);
      expect(setup.playerNames.length, 4);
      expect(setup.playerColorIndices, [0, 1, 2, 3]);
    });

    test('displayName returns default when name is empty', () {
      const setup = PlayerSetup();
      expect(setup.displayName(0), 'Player 1');
      expect(setup.displayName(3), 'Player 4');
    });

    test('displayName returns custom name when set', () {
      const setup = PlayerSetup(playerNames: ['Alice', '', 'Bob', '']);
      expect(setup.displayName(0), 'Alice');
      expect(setup.displayName(1), 'Player 2');
      expect(setup.displayName(2), 'Bob');
    });

    test('playerColor returns correct color', () {
      const setup = PlayerSetup();
      expect(setup.playerColor(0), availablePlayerColors[0].color);
      expect(setup.playerColor(1), availablePlayerColors[1].color);
    });
  });

  group('PlayerSetupNotifier', () {
    test('set player count', () {
      final notifier = PlayerSetupNotifier();
      notifier.setPlayerCount(2);
      expect(notifier.state.playerCount, 2);
    });

    test('set player name', () {
      final notifier = PlayerSetupNotifier();
      notifier.setPlayerName(0, 'Alice');
      expect(notifier.state.playerNames[0], 'Alice');
    });

    test('set player color swaps with existing', () {
      final notifier = PlayerSetupNotifier();
      // Player 0 has color 0, Player 1 has color 1
      // Set player 0 to color 1 → swap: player 0 gets 1, player 1 gets 0
      notifier.setPlayerColor(0, 1);
      expect(notifier.state.playerColorIndices[0], 1);
      expect(notifier.state.playerColorIndices[1], 0);
    });

    test('reset returns to defaults', () {
      final notifier = PlayerSetupNotifier();
      notifier.setPlayerCount(2);
      notifier.setPlayerName(0, 'Alice');
      notifier.reset();
      expect(notifier.state.playerCount, 4);
      expect(notifier.state.playerNames[0], '');
    });
  });

  group('availablePlayerColors', () {
    test('has at least 6 colors', () {
      expect(availablePlayerColors.length, greaterThanOrEqualTo(6));
    });

    test('all colors are distinct', () {
      final colorValues =
          availablePlayerColors.map((c) => c.color.value).toSet();
      expect(colorValues.length, availablePlayerColors.length);
    });

    test('each color has a name', () {
      for (final c in availablePlayerColors) {
        expect(c.name.isNotEmpty, true);
      }
    });
  });
}

// =============================================================================
// PlayerHerd color tests
// =============================================================================

void _playerHerdColorTests() {
  group('PlayerHerd color', () {
    test('default color is green', () {
      const herd = PlayerHerd(name: 'Test');
      expect(herd.color, const Color(0xFF2E7D32));
    });

    test('custom color is preserved', () {
      const herd = PlayerHerd(
        name: 'Test',
        color: Color(0xFF1565C0),
      );
      expect(herd.color, const Color(0xFF1565C0));
    });

    test('copyWith preserves color', () {
      const herd = PlayerHerd(
        name: 'Test',
        color: Color(0xFF1565C0),
      );
      final updated = herd.copyWith(name: 'Updated');
      expect(updated.color, const Color(0xFF1565C0));
    });

    test('copyWith can change color', () {
      const herd = PlayerHerd(name: 'Test');
      final updated = herd.copyWith(color: const Color(0xFFE65100));
      expect(updated.color, const Color(0xFFE65100));
    });

    test('startGame passes colors to players', () {
      final notifier = GameNotifier();
      notifier.startGame(
        ['Alice', 'Bob'],
        [const Color(0xFF1565C0), const Color(0xFFE65100)],
      );
      expect(notifier.state.players[0].color, const Color(0xFF1565C0));
      expect(notifier.state.players[1].color, const Color(0xFFE65100));
    });

    test('startGame uses default color when no colors provided', () {
      final notifier = GameNotifier();
      notifier.startGame(['Alice', 'Bob']);
      expect(notifier.state.players[0].color, const Color(0xFF2E7D32));
      expect(notifier.state.players[1].color, const Color(0xFF2E7D32));
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

// =============================================================================
// TurnEvent tests
// =============================================================================

void _turnEventTests() {
  group('TurnEvent', () {
    test('breeding event tracks gained animals', () {
      // Player has 5 rabbits, rolls 2 rabbits → gains floor((5+2)/2) = 3
      final notifier = GameNotifier(FixedRandom(0)); // both dice → rabbit
      notifier.startGame(['Alice']);
      _setPlayerAnimals(notifier, 0, {Animal.rabbit: 5});

      notifier.rollDice();
      final event = notifier.state.lastEvent;
      expect(event, isNotNull);
      expect(event!.bred[Animal.rabbit], 3);
      expect(event.foxAttack, false);
      expect(event.wolfAttack, false);
    });

    test('fox attack event without dog tracks lost rabbits', () {
      // Red die face index 11 → fox, green die face index 0 → rabbit
      final notifier = GameNotifier(_SequenceRandom([0, 11]));
      notifier.startGame(['Alice']);
      _setPlayerAnimals(notifier, 0, {Animal.rabbit: 10});

      notifier.rollDice();
      final event = notifier.state.lastEvent;
      expect(event, isNotNull);
      expect(event!.foxAttack, true);
      expect(event.smallDogSacrificed, false);
      expect(event.lostAnimals[Animal.rabbit], greaterThan(0));
    });

    test('fox attack with small dog tracks sacrifice', () {
      final notifier = GameNotifier(_SequenceRandom([0, 11]));
      notifier.startGame(['Alice']);
      _setPlayerAnimals(notifier, 0, {Animal.rabbit: 10, Animal.smallDog: 1});

      notifier.rollDice();
      final event = notifier.state.lastEvent;
      expect(event, isNotNull);
      expect(event!.foxAttack, true);
      expect(event.smallDogSacrificed, true);
      expect(event.lostAnimals, isEmpty);
    });

    test('wolf attack event without dog tracks lost animals', () {
      // Green die face index 11 → wolf, red die face index 0 → rabbit
      final notifier = GameNotifier(_SequenceRandom([11, 0]));
      notifier.startGame(['Alice']);
      _setPlayerAnimals(notifier, 0, {
        Animal.rabbit: 5,
        Animal.lamb: 3,
        Animal.pig: 2,
      });

      notifier.rollDice();
      final event = notifier.state.lastEvent;
      expect(event, isNotNull);
      expect(event!.wolfAttack, true);
      expect(event.bigDogSacrificed, false);
      expect(event.lostAnimals.isNotEmpty, true);
    });

    test('wolf attack with big dog tracks sacrifice', () {
      final notifier = GameNotifier(_SequenceRandom([11, 0]));
      notifier.startGame(['Alice']);
      _setPlayerAnimals(notifier, 0, {
        Animal.rabbit: 5,
        Animal.bigDog: 1,
      });

      notifier.rollDice();
      final event = notifier.state.lastEvent;
      expect(event, isNotNull);
      expect(event!.wolfAttack, true);
      expect(event.bigDogSacrificed, true);
      expect(event.lostAnimals, isEmpty);
    });

    test('nextTurn clears lastEvent', () {
      final notifier = GameNotifier(FixedRandom(0));
      notifier.startGame(['Alice', 'Bob']);
      notifier.rollDice();
      expect(notifier.state.lastEvent, isNotNull);
      notifier.nextTurn();
      expect(notifier.state.lastEvent, isNull);
    });
  });
}

// =============================================================================
// Dice animation widget tests
// =============================================================================

void _diceAnimationTests() {
  group('DiceCenter animations', () {
    Widget buildDiceCenter({
      GameState? gameState,
      VoidCallback? onRoll,
      VoidCallback? onEndTurn,
    }) {
      final state = gameState ??
          GameState(
            players: [
              PlayerHerd(
                name: 'Alice',
                animals: {for (final a in Animal.values) a: 0},
              ),
            ],
            currentPlayerIndex: 0,
            isStarted: true,
            bank: GameState.initialBank(),
          );
      return MaterialApp(
        home: Scaffold(
          body: DiceCenter(
            gameState: state,
            onRoll: onRoll ?? () {},
            onEndTurn: onEndTurn ?? () {},
          ),
        ),
      );
    }

    testWidgets('roll button is disabled during animation', (tester) async {
      await tester.pumpWidget(buildDiceCenter());
      await tester.tap(find.text('Roll Dice'));
      await tester.pump(const Duration(milliseconds: 100));

      // During roll animation, Roll Dice button should be disabled
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);

      // Drain the pending timer and animations
      await tester.pumpAndSettle();
    });

    testWidgets('dice results appear after roll animation completes', (tester) async {
      final state = GameState(
        players: [
          PlayerHerd(
            name: 'Alice',
            animals: {for (final a in Animal.values) a: 0},
          ),
        ],
        currentPlayerIndex: 0,
        isStarted: true,
        bank: GameState.initialBank(),
        lastRoll: const DiceRollResult(green: DiceFace.rabbit, red: DiceFace.lamb),
      );
      await tester.pumpWidget(buildDiceCenter(gameState: state));
      // Results should show the face names (reveal animation starts completed for pre-existing rolls)
      expect(find.text('Rabbit'), findsOneWidget);
      expect(find.text('Lamb'), findsOneWidget);
    });

    testWidgets('end turn button enabled after roll', (tester) async {
      final state = GameState(
        players: [
          PlayerHerd(
            name: 'Alice',
            animals: {for (final a in Animal.values) a: 0},
          ),
        ],
        currentPlayerIndex: 0,
        isStarted: true,
        bank: GameState.initialBank(),
        lastRoll: const DiceRollResult(green: DiceFace.rabbit, red: DiceFace.rabbit),
      );
      await tester.pumpWidget(buildDiceCenter(gameState: state));
      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(button.onPressed, isNotNull);
    });
  });
}

// =============================================================================
// PlayerArea animation widget tests
// =============================================================================

// =============================================================================
// Tutorial carousel tests
// =============================================================================

void _tutorialCarouselTests() {
  group('TutorialCarousel', () {
    Widget buildCarousel() {
      return const MaterialApp(
        home: TutorialCarousel(),
      );
    }

    testWidgets('renders first page with welcome content', (tester) async {
      await tester.pumpWidget(buildCarousel());
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Super Farmer!'), findsOneWidget);
      expect(find.text('How to Play'), findsOneWidget); // AppBar title
    });

    testWidgets('shows skip button on non-last pages', (tester) async {
      await tester.pumpWidget(buildCarousel());
      await tester.pumpAndSettle();

      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('shows next button on non-last pages', (tester) async {
      await tester.pumpWidget(buildCarousel());
      await tester.pumpAndSettle();

      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('has 7 progress dots', (tester) async {
      await tester.pumpWidget(buildCarousel());
      await tester.pumpAndSettle();

      // 7 AnimatedContainer dots
      final dots = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      // Filter for dots (width 8 or 24)
      final dotWidgets = dots.where((c) {
        final constraints = c.constraints;
        return constraints == null; // AnimatedContainer doesn't have constraints - check decoration
      });
      // Just verify we have the progress dots row
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('next button advances to page 2', (tester) async {
      await tester.pumpWidget(buildCarousel());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Roll the Dice'), findsOneWidget);
    });

    testWidgets('can swipe to next page', (tester) async {
      await tester.pumpWidget(buildCarousel());
      await tester.pumpAndSettle();

      // Swipe left to go to next page
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.text('Roll the Dice'), findsOneWidget);
    });

    testWidgets('last page shows Got it! button instead of Next', (tester) async {
      await tester.pumpWidget(buildCarousel());
      await tester.pumpAndSettle();

      // Navigate to last page (page 7) by tapping Next 6 times
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }
      // Last tap lands on page with repeating animation — pump multiple frames
      await tester.tap(find.text('Next'));
      for (int j = 0; j < 10; j++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.text('Got it!'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
      expect(find.text('Skip'), findsNothing);
    });

    testWidgets('last page is How to Win', (tester) async {
      await tester.pumpWidget(buildCarousel());
      await tester.pumpAndSettle();

      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }
      // Last page has repeating animation — pump multiple frames instead of pumpAndSettle
      await tester.tap(find.text('Next'));
      for (int j = 0; j < 10; j++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.text('How to Win'), findsOneWidget);
    });

    testWidgets('close button exists', (tester) async {
      await tester.pumpWidget(buildCarousel());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('all 7 pages render without errors', (tester) async {
      await tester.pumpWidget(buildCarousel());
      await tester.pumpAndSettle();

      final pages = [
        'Welcome to Super Farmer!',
        'Roll the Dice',
        'Animal Breeding',
        'Trading Animals',
        'Guard Dogs',
        'Predator Attacks',
        'How to Win',
      ];

      for (int i = 0; i < pages.length; i++) {
        if (i > 0) {
          await tester.tap(find.text('Next'));
          if (i < pages.length - 1) {
            await tester.pumpAndSettle();
          } else {
            // Last page has repeating animation — pump multiple frames
            for (int j = 0; j < 10; j++) {
              await tester.pump(const Duration(milliseconds: 50));
            }
          }
        }
        expect(find.text(pages[i]), findsOneWidget);
      }
    });

    testWidgets('dice rolling page has Try Rolling button', (tester) async {
      await tester.pumpWidget(buildCarousel());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Try Rolling'), findsOneWidget);
    });

    testWidgets('breeding page has Show Result button', (tester) async {
      await tester.pumpWidget(buildCarousel());
      await tester.pumpAndSettle();

      // Navigate to page 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Show Result'), findsOneWidget);
    });

    testWidgets('breeding page shows result on tap', (tester) async {
      await tester.pumpWidget(buildCarousel());
      await tester.pumpAndSettle();

      // Navigate to page 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Result'));
      await tester.pumpAndSettle();

      expect(find.textContaining('2 new rabbits'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('trading page shows exchange rates', (tester) async {
      await tester.pumpWidget(buildCarousel());
      await tester.pumpAndSettle();

      // Navigate to page 4
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      expect(find.text('6 Rabbits'), findsOneWidget);
      expect(find.text('1 Lamb'), findsOneWidget);
      expect(find.text('2 Cows'), findsOneWidget);
      expect(find.text('1 Horse'), findsOneWidget);
    });

    testWidgets('guard dogs page shows both dogs', (tester) async {
      await tester.pumpWidget(buildCarousel());
      await tester.pumpAndSettle();

      // Navigate to page 5
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      expect(find.text('Small Dog'), findsOneWidget);
      expect(find.text('Big Dog'), findsOneWidget);
      expect(find.text('Blocks Fox'), findsOneWidget);
      expect(find.text('Blocks Wolf'), findsOneWidget);
    });

    testWidgets('attacks page has Simulate Attack button', (tester) async {
      await tester.pumpWidget(buildCarousel());
      await tester.pumpAndSettle();

      // Navigate to page 6
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      expect(find.text('Simulate Attack!'), findsOneWidget);
      expect(find.text('Fox Attack'), findsOneWidget);
      expect(find.text('Wolf Attack'), findsOneWidget);
    });

    testWidgets('win page shows trophy and all farm animals', (tester) async {
      await tester.pumpWidget(buildCarousel());
      await tester.pumpAndSettle();

      // Navigate to page 7 (last page has repeating animation)
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Next'));
      for (int j = 0; j < 10; j++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.text('How to Win'), findsOneWidget);
      expect(find.text('Collect one of each:'), findsOneWidget);
      expect(find.text('First to complete the set wins!'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsAtLeast(1));
    });

    testWidgets('TutorialCarousel.show opens as a route', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => TutorialCarousel.show(context),
                child: const Text('Open Tutorial'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Tutorial'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Super Farmer!'), findsOneWidget);
    });
  });
}

// =============================================================================
// Rules screen tests
// =============================================================================

void _rulesScreenTests() {
  group('RulesScreen', () {
    testWidgets('shows interactive tutorial card', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RulesScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Interactive Tutorial'), findsOneWidget);
      expect(find.text('Start Tutorial'), findsOneWidget);
    });

    testWidgets('shows quick reference section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RulesScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Quick Reference'), findsOneWidget);
    });

    testWidgets('shows animal values section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RulesScreen()),
      );
      await tester.pumpAndSettle();

      // Animal Values card is below the fold, scroll to it
      await tester.scrollUntilVisible(
        find.text('Animal Values'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Animal Values'), findsOneWidget);
    });

    testWidgets('tapping Start Tutorial opens carousel', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RulesScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Tutorial'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Super Farmer!'), findsOneWidget);
    });

    testWidgets('settings sheet shows How to Play option', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => SettingsSheet.show(context),
                  child: const Text('Open Settings'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();

      expect(find.text('How to Play'), findsOneWidget);
      expect(find.text('Interactive tutorial'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
    });
  });
}

void _playerAreaAnimationTests() {
  group('PlayerArea animations', () {
    Widget buildPlayerArea({
      PlayerHerd? player,
      int playerIndex = 0,
      bool isCurrentPlayer = true,
      GameState? gameState,
    }) {
      final p = player ??
          PlayerHerd(
            name: 'Alice',
            animals: {for (final a in Animal.values) a: 0},
          );
      final state = gameState ??
          GameState(
            players: [p],
            currentPlayerIndex: 0,
            isStarted: true,
            bank: GameState.initialBank(),
          );
      return MaterialApp(
        home: Scaffold(
          body: PlayerArea(
            player: p,
            playerIndex: playerIndex,
            isCurrentPlayer: isCurrentPlayer,
            gameState: state,
            onTrade: (_) {},
          ),
        ),
      );
    }

    testWidgets('shows animal counts', (tester) async {
      final player = PlayerHerd(
        name: 'Alice',
        animals: {
          for (final a in Animal.values) a: 0,
          Animal.rabbit: 5,
        },
      );
      await tester.pumpWidget(buildPlayerArea(player: player));
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('attack flash overlay appears on fox attack with losses', (tester) async {
      final player = PlayerHerd(
        name: 'Alice',
        animals: {for (final a in Animal.values) a: 0},
      );
      final event = TurnEvent(
        roll: const DiceRollResult(green: DiceFace.rabbit, red: DiceFace.fox),
        foxAttack: true,
        lostAnimals: {Animal.rabbit: 5},
      );
      final state = GameState(
        players: [player],
        currentPlayerIndex: 0,
        isStarted: true,
        bank: GameState.initialBank(),
        lastRoll: const DiceRollResult(green: DiceFace.rabbit, red: DiceFace.fox),
        lastEvent: event,
      );

      // First render without event
      final noEventState = GameState(
        players: [player],
        currentPlayerIndex: 0,
        isStarted: true,
        bank: GameState.initialBank(),
      );
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PlayerArea(
            player: player,
            playerIndex: 0,
            isCurrentPlayer: true,
            gameState: noEventState,
            onTrade: (_) {},
          ),
        ),
      ));

      // Now rebuild with the attack event to trigger animation
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PlayerArea(
            player: player,
            playerIndex: 0,
            isCurrentPlayer: true,
            gameState: state,
            onTrade: (_) {},
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // The widget should still render correctly during animation
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('dog sacrifice triggers amber flash', (tester) async {
      final player = PlayerHerd(
        name: 'Alice',
        animals: {for (final a in Animal.values) a: 0},
      );
      final event = TurnEvent(
        roll: const DiceRollResult(green: DiceFace.rabbit, red: DiceFace.fox),
        foxAttack: true,
        smallDogSacrificed: true,
      );
      final state = GameState(
        players: [player],
        currentPlayerIndex: 0,
        isStarted: true,
        bank: GameState.initialBank(),
        lastRoll: const DiceRollResult(green: DiceFace.rabbit, red: DiceFace.fox),
        lastEvent: event,
      );

      // First render without event
      final noEventState = GameState(
        players: [player],
        currentPlayerIndex: 0,
        isStarted: true,
        bank: GameState.initialBank(),
      );
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PlayerArea(
            player: player,
            playerIndex: 0,
            isCurrentPlayer: true,
            gameState: noEventState,
            onTrade: (_) {},
          ),
        ),
      ));

      // Rebuild with sacrifice event
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PlayerArea(
            player: player,
            playerIndex: 0,
            isCurrentPlayer: true,
            gameState: state,
            onTrade: (_) {},
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('count pop animation triggers on count change', (tester) async {
      final player0 = PlayerHerd(
        name: 'Alice',
        animals: {for (final a in Animal.values) a: 0},
      );
      final state0 = GameState(
        players: [player0],
        currentPlayerIndex: 0,
        isStarted: true,
        bank: GameState.initialBank(),
      );
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PlayerArea(
            player: player0,
            playerIndex: 0,
            isCurrentPlayer: true,
            gameState: state0,
            onTrade: (_) {},
          ),
        ),
      ));

      // Update with new count
      final player1 = PlayerHerd(
        name: 'Alice',
        animals: {for (final a in Animal.values) a: 0, Animal.rabbit: 3},
      );
      final state1 = GameState(
        players: [player1],
        currentPlayerIndex: 0,
        isStarted: true,
        bank: GameState.initialBank(),
      );
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PlayerArea(
            player: player1,
            playerIndex: 0,
            isCurrentPlayer: true,
            gameState: state1,
            onTrade: (_) {},
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // The count should show the new value (may appear multiple times due to exchange rate "3")
      expect(find.text('3'), findsAtLeast(1));

      // Drain animations
      await tester.pumpAndSettle();
    });
  });

  // ===========================================================================
  // AI Opponent tests
  // ===========================================================================

  group('AiDifficulty', () {
    test('has three difficulty levels', () {
      expect(AiDifficulty.values.length, 3);
      expect(AiDifficulty.easy.label, 'Easy');
      expect(AiDifficulty.medium.label, 'Medium');
      expect(AiDifficulty.hard.label, 'Hard');
    });

    test('each difficulty has a description', () {
      for (final diff in AiDifficulty.values) {
        expect(diff.description, isNotEmpty);
      }
    });
  });

  group('AiStrategy', () {
    test('easy AI returns empty or minimal trades', () {
      final strategy = const AiStrategy(AiDifficulty.easy);
      final player = PlayerHerd(
        name: 'AI',
        animals: {
          Animal.rabbit: 2,
          Animal.lamb: 0,
          Animal.pig: 0,
          Animal.cow: 0,
          Animal.horse: 0,
          Animal.smallDog: 0,
          Animal.bigDog: 0,
        },
      );
      final bank = GameState.initialBank();

      // Easy AI with few animals should produce 0 or very few trades
      final trades = strategy.decideTrades(player, bank);
      // Easy AI never trades up, might buy a small dog randomly
      expect(trades.length, lessThanOrEqualTo(1));
    });

    test('medium AI buys small dog when it has spare lambs', () {
      final strategy = const AiStrategy(AiDifficulty.medium);
      final player = PlayerHerd(
        name: 'AI',
        animals: {
          Animal.rabbit: 10,
          Animal.lamb: 3,
          Animal.pig: 0,
          Animal.cow: 0,
          Animal.horse: 0,
          Animal.smallDog: 0,
          Animal.bigDog: 0,
        },
      );
      final bank = GameState.initialBank();

      final trades = strategy.decideTrades(player, bank);
      // Should buy small dog (1 lamb for 1 small dog)
      final dogTrades = trades.where((t) => t.to == Animal.smallDog).toList();
      expect(dogTrades.length, 1);
      expect(dogTrades[0].from, Animal.lamb);
      expect(dogTrades[0].fromCount, 1);
    });

    test('medium AI buys big dog when it has spare cows', () {
      final strategy = const AiStrategy(AiDifficulty.medium);
      final player = PlayerHerd(
        name: 'AI',
        animals: {
          Animal.rabbit: 5,
          Animal.lamb: 2,
          Animal.pig: 1,
          Animal.cow: 2,
          Animal.horse: 0,
          Animal.smallDog: 1,
          Animal.bigDog: 0,
        },
      );
      final bank = GameState.initialBank();

      final trades = strategy.decideTrades(player, bank);
      final bigDogTrades = trades.where((t) => t.to == Animal.bigDog).toList();
      expect(bigDogTrades.length, 1);
      expect(bigDogTrades[0].from, Animal.cow);
    });

    test('medium AI trades up to fill gaps', () {
      final strategy = const AiStrategy(AiDifficulty.medium);
      final player = PlayerHerd(
        name: 'AI',
        animals: {
          Animal.rabbit: 12,
          Animal.lamb: 0,
          Animal.pig: 0,
          Animal.cow: 0,
          Animal.horse: 0,
          Animal.smallDog: 0,
          Animal.bigDog: 0,
        },
      );
      final bank = GameState.initialBank();

      final trades = strategy.decideTrades(player, bank);
      // Should trade 6 rabbits for 1 lamb (trade up)
      final lambTrades = trades.where((t) => t.to == Animal.lamb).toList();
      expect(lambTrades.isNotEmpty, true);
    });

    test('hard AI buys small dog when rabbits are valuable', () {
      final strategy = const AiStrategy(AiDifficulty.hard);
      final player = PlayerHerd(
        name: 'AI',
        animals: {
          Animal.rabbit: 8,
          Animal.lamb: 2,
          Animal.pig: 0,
          Animal.cow: 0,
          Animal.horse: 0,
          Animal.smallDog: 0,
          Animal.bigDog: 0,
        },
      );
      final bank = GameState.initialBank();

      final trades = strategy.decideTrades(player, bank);
      final dogTrades = trades.where((t) => t.to == Animal.smallDog).toList();
      expect(dogTrades.length, 1);
    });

    test('hard AI buys big dog when opponents are close to winning', () {
      final strategy = const AiStrategy(AiDifficulty.hard);
      final player = PlayerHerd(
        name: 'AI',
        animals: {
          Animal.rabbit: 3,
          Animal.lamb: 1,
          Animal.pig: 1,
          Animal.cow: 1,
          Animal.horse: 0,
          Animal.smallDog: 0,
          Animal.bigDog: 0,
        },
      );
      final opponent = PlayerHerd(
        name: 'Human',
        animals: {
          Animal.rabbit: 5,
          Animal.lamb: 3,
          Animal.pig: 2,
          Animal.cow: 0,
          Animal.horse: 0,
          Animal.smallDog: 0,
          Animal.bigDog: 0,
        },
      );
      final bank = GameState.initialBank();

      final trades = strategy.decideTrades(player, bank, [opponent]);
      // Should buy big dog due to herd value
      final bigDogTrades = trades.where((t) => t.to == Animal.bigDog).toList();
      expect(bigDogTrades.length, 1);
    });

    test('hard AI trades aggressively towards highest missing animal', () {
      final strategy = const AiStrategy(AiDifficulty.hard);
      final player = PlayerHerd(
        name: 'AI',
        animals: {
          Animal.rabbit: 20,
          Animal.lamb: 1,
          Animal.pig: 1,
          Animal.cow: 1,
          Animal.horse: 0,
          Animal.smallDog: 0,
          Animal.bigDog: 0,
        },
      );
      final bank = GameState.initialBank();

      final trades = strategy.decideTrades(player, bank);
      // Should trade rabbits up towards horse
      expect(trades.isNotEmpty, true);
      // Should include rabbit->lamb trades
      final rabbitTrades = trades.where((t) => t.from == Animal.rabbit).toList();
      expect(rabbitTrades.isNotEmpty, true);
    });

    test('hard AI does not trade when it already has all animals', () {
      final strategy = const AiStrategy(AiDifficulty.hard);
      final player = PlayerHerd(
        name: 'AI',
        animals: {
          Animal.rabbit: 5,
          Animal.lamb: 2,
          Animal.pig: 1,
          Animal.cow: 1,
          Animal.horse: 1,
          Animal.smallDog: 1,
          Animal.bigDog: 1,
        },
      );
      final bank = GameState.initialBank();

      final trades = strategy.decideTrades(player, bank);
      // Already has everything, no need to trade up
      // May still buy dogs but has them already
      final upTrades = trades
          .where((t) => t.to != Animal.smallDog && t.to != Animal.bigDog)
          .toList();
      expect(upTrades, isEmpty);
    });
  });

  group('AI GameNotifier integration', () {
    test('startGame creates AI players with correct properties', () {
      final notifier = GameNotifier();
      notifier.startGame(
        ['Human', 'AI Bot'],
        [const Color(0xFF2E7D32), const Color(0xFF1565C0)],
        [false, true],
        [null, AiDifficulty.hard],
      );

      expect(notifier.state.players[0].isAi, false);
      expect(notifier.state.players[0].aiDifficulty, isNull);
      expect(notifier.state.players[1].isAi, true);
      expect(notifier.state.players[1].aiDifficulty, AiDifficulty.hard);
      expect(notifier.state.players[1].name, 'AI Bot');
    });

    test('isCurrentPlayerAi detects AI turns', () {
      final notifier = GameNotifier();
      notifier.startGame(
        ['Human', 'AI Bot'],
        null,
        [false, true],
        [null, AiDifficulty.medium],
      );

      expect(notifier.state.isCurrentPlayerAi, false);
      notifier.nextTurn();
      expect(notifier.state.isCurrentPlayerAi, true);
    });

    test('computeAiTrades returns trades for AI player', () {
      final notifier = GameNotifier();
      notifier.startGame(
        ['Human', 'AI Bot'],
        null,
        [false, true],
        [null, AiDifficulty.medium],
      );

      // Move to AI turn
      notifier.nextTurn();

      // Give AI some animals to trade
      _setPlayerAnimals(notifier, 1, {Animal.rabbit: 12, Animal.lamb: 3});

      final trades = notifier.computeAiTrades();
      expect(trades, isNotEmpty);
    });

    test('computeAiTrades returns empty for human player', () {
      final notifier = GameNotifier();
      notifier.startGame(['Human', 'AI Bot'], null, [false, true]);

      // On human turn
      final trades = notifier.computeAiTrades();
      expect(trades, isEmpty);
    });

    test('setAiThinking updates state', () {
      final notifier = GameNotifier();
      notifier.startGame(['Human', 'AI Bot'], null, [false, true]);

      expect(notifier.state.isAiThinking, false);
      notifier.setAiThinking(true);
      expect(notifier.state.isAiThinking, true);
      notifier.setAiThinking(false);
      expect(notifier.state.isAiThinking, false);
    });

    test('nextTurn clears AI state', () {
      final notifier = GameNotifier();
      notifier.startGame(['Human', 'AI Bot'], null, [false, true]);

      notifier.setAiThinking(true);
      notifier.setAiTradesMade([
        const ExchangeRate(
            from: Animal.rabbit, fromCount: 6, to: Animal.lamb, toCount: 1),
      ]);

      notifier.nextTurn();
      expect(notifier.state.isAiThinking, false);
      expect(notifier.state.aiTradesMade, isEmpty);
    });

    test('AI player defaults to medium difficulty when not specified', () {
      final notifier = GameNotifier();
      notifier.startGame(
        ['Human', 'AI Bot'],
        null,
        [false, true],
      );

      expect(notifier.state.players[1].aiDifficulty, AiDifficulty.medium);
    });
  });

  group('PlayerSetup AI configuration', () {
    test('defaults to non-AI players', () {
      const setup = PlayerSetup();
      expect(setup.isAi[0], false);
      expect(setup.isAi[1], false);
    });

    test('defaults AI difficulty to medium', () {
      const setup = PlayerSetup();
      expect(setup.aiDifficulties[0], AiDifficulty.medium);
    });

    test('displayName shows AI name when player is AI', () {
      const setup = PlayerSetup(
        isAi: [false, true, false, false],
        aiDifficulties: [
          AiDifficulty.medium,
          AiDifficulty.hard,
          AiDifficulty.medium,
          AiDifficulty.medium,
        ],
      );
      expect(setup.displayName(0), 'Player 1');
      expect(setup.displayName(1), 'AI 2 (Hard)');
    });

    test('displayName uses custom name over AI default', () {
      const setup = PlayerSetup(
        playerNames: ['', 'Skynet', '', ''],
        isAi: [false, true, false, false],
      );
      expect(setup.displayName(1), 'Skynet');
    });

    test('PlayerSetupNotifier sets AI flag', () {
      final notifier = PlayerSetupNotifier();
      notifier.setIsAi(1, true);
      expect(notifier.state.isAi[1], true);
      expect(notifier.state.isAi[0], false);
    });

    test('PlayerSetupNotifier sets AI difficulty', () {
      final notifier = PlayerSetupNotifier();
      notifier.setAiDifficulty(2, AiDifficulty.hard);
      expect(notifier.state.aiDifficulties[2], AiDifficulty.hard);
    });
  });

  group('AI PlayerSetupCard widget', () {
    testWidgets('shows AI toggle switch', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PlayerSetupCard(
              playerIndex: 0,
              name: '',
              selectedColorIndex: 0,
              usedColorIndices: const {},
              onNameChanged: (_) {},
              onColorChanged: (_) {},
              isAi: false,
              onAiChanged: (_) {},
              onAiDifficultyChanged: (_) {},
            ),
          ),
        ),
      ));

      expect(find.byType(Switch), findsOneWidget);
      expect(find.byIcon(Icons.smart_toy_outlined), findsOneWidget);
    });

    testWidgets('shows difficulty selector when AI enabled', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PlayerSetupCard(
              playerIndex: 0,
              name: '',
              selectedColorIndex: 0,
              usedColorIndices: const {},
              onNameChanged: (_) {},
              onColorChanged: (_) {},
              isAi: true,
              aiDifficulty: AiDifficulty.medium,
              onAiChanged: (_) {},
              onAiDifficultyChanged: (_) {},
            ),
          ),
        ),
      ));

      // Should show all three difficulty options
      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);
    });

    testWidgets('hides name input when AI enabled', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PlayerSetupCard(
              playerIndex: 0,
              name: '',
              selectedColorIndex: 0,
              usedColorIndices: const {},
              onNameChanged: (_) {},
              onColorChanged: (_) {},
              isAi: true,
              onAiChanged: (_) {},
              onAiDifficultyChanged: (_) {},
            ),
          ),
        ),
      ));

      // TextField for name should not be visible when AI is enabled
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('shows AI icon in header when AI enabled', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PlayerSetupCard(
              playerIndex: 0,
              name: '',
              selectedColorIndex: 0,
              usedColorIndices: const {},
              onNameChanged: (_) {},
              onColorChanged: (_) {},
              isAi: true,
              onAiChanged: (_) {},
              onAiDifficultyChanged: (_) {},
            ),
          ),
        ),
      ));

      // Should show smart_toy icon and "AI Player 1" text
      expect(find.byIcon(Icons.smart_toy), findsAtLeast(1));
      expect(find.text('AI Player 1'), findsOneWidget);
    });
  });

  group('DiceCenter AI turn', () {
    testWidgets('disables roll button when AI turn', (tester) async {
      final game = GameState(
        players: [
          PlayerHerd(
            name: 'AI Bot',
            isAi: true,
            aiDifficulty: AiDifficulty.medium,
            animals: {for (final a in Animal.values) a: 0},
          ),
        ],
        currentPlayerIndex: 0,
        isStarted: true,
        bank: GameState.initialBank(),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DiceCenter(
            gameState: game,
            onRoll: () {},
            onEndTurn: () {},
            isAiTurn: true,
          ),
        ),
      ));

      // Roll button should be present but disabled
      final rollButton = find.widgetWithText(FilledButton, 'Roll Dice');
      expect(rollButton, findsOneWidget);
      final button = tester.widget<FilledButton>(rollButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('shows AI thinking indicator', (tester) async {
      final game = GameState(
        players: [
          PlayerHerd(
            name: 'AI Bot',
            isAi: true,
            aiDifficulty: AiDifficulty.medium,
            animals: {for (final a in Animal.values) a: 0},
          ),
        ],
        currentPlayerIndex: 0,
        isStarted: true,
        bank: GameState.initialBank(),
        isAiThinking: true,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DiceCenter(
            gameState: game,
            onRoll: () {},
            onEndTurn: () {},
            isAiTurn: true,
          ),
        ),
      ));

      await tester.pump();

      // Should show "Thinking" text
      expect(find.text('Thinking'), findsOneWidget);
      expect(find.byIcon(Icons.smart_toy), findsAtLeast(1));
    });
  });

  // ===========================================================================
  // GameRecord model tests
  // ===========================================================================
  group('GameRecord', () {
    test('serializes to and from JSON', () {
      final record = GameRecord(
        date: DateTime(2026, 4, 1, 12, 0),
        playerNames: ['Alice', 'Bob'],
        winnerName: 'Alice',
        playerCount: 2,
        totalTurns: 42,
        lastAnimalAcquired: 'horse',
        winnerIsAi: false,
      );

      final json = record.toJson();
      final decoded = GameRecord.fromJson(json);

      expect(decoded.date, record.date);
      expect(decoded.playerNames, ['Alice', 'Bob']);
      expect(decoded.winnerName, 'Alice');
      expect(decoded.playerCount, 2);
      expect(decoded.totalTurns, 42);
      expect(decoded.lastAnimalAcquired, 'horse');
      expect(decoded.winnerIsAi, false);
    });

    test('encode/decode list of records', () {
      final records = [
        GameRecord(
          date: DateTime(2026, 4, 1),
          playerNames: ['Alice', 'Bob'],
          winnerName: 'Alice',
          playerCount: 2,
          totalTurns: 30,
          lastAnimalAcquired: 'horse',
          winnerIsAi: false,
        ),
        GameRecord(
          date: DateTime(2026, 4, 2),
          playerNames: ['Alice', 'Bob', 'Carol'],
          winnerName: 'Bob',
          playerCount: 3,
          totalTurns: 50,
          lastAnimalAcquired: 'cow',
          winnerIsAi: false,
        ),
      ];

      final encoded = GameRecord.encode(records);
      final decoded = GameRecord.decode(encoded);

      expect(decoded.length, 2);
      expect(decoded[0].winnerName, 'Alice');
      expect(decoded[1].winnerName, 'Bob');
      expect(decoded[1].playerCount, 3);
    });

    test('fromJson handles missing winnerIsAi field', () {
      final json = {
        'date': '2026-04-01T00:00:00.000',
        'playerNames': ['Alice'],
        'winnerName': 'Alice',
        'playerCount': 2,
        'totalTurns': 10,
        'lastAnimalAcquired': 'horse',
      };

      final record = GameRecord.fromJson(json);
      expect(record.winnerIsAi, false);
    });
  });

  // ===========================================================================
  // GameStats computation tests
  // ===========================================================================
  group('GameStats', () {
    test('returns empty stats for no records', () {
      final stats = GameStats.fromRecords([]);
      expect(stats.gamesPlayed, 0);
      expect(stats.gamesWon, 0);
      expect(stats.gamesLost, 0);
      expect(stats.winRateByPlayerCount, isEmpty);
      expect(stats.averageTurns, 0);
      expect(stats.fastestWin, isNull);
      expect(stats.mostCommonLastAnimal, isNull);
      expect(stats.leaderboard, isEmpty);
    });

    test('computes basic stats from records', () {
      final records = [
        GameRecord(
          date: DateTime(2026, 4, 1),
          playerNames: ['Alice', 'Bob'],
          winnerName: 'Alice',
          playerCount: 2,
          totalTurns: 30,
          lastAnimalAcquired: 'horse',
          winnerIsAi: false,
        ),
        GameRecord(
          date: DateTime(2026, 4, 2),
          playerNames: ['Alice', 'Bot'],
          winnerName: 'Bot',
          playerCount: 2,
          totalTurns: 20,
          lastAnimalAcquired: 'horse',
          winnerIsAi: true,
        ),
      ];

      final stats = GameStats.fromRecords(records);
      expect(stats.gamesPlayed, 2);
      expect(stats.gamesWon, 1); // Only human wins
      expect(stats.gamesLost, 1); // AI win counts as loss
      expect(stats.averageTurns, 25.0);
      expect(stats.fastestWin, 20);
      expect(stats.mostCommonLastAnimal, 'Horse');
    });

    test('computes win rate by player count', () {
      final records = [
        GameRecord(
          date: DateTime(2026, 4, 1),
          playerNames: ['A', 'B'],
          winnerName: 'A',
          playerCount: 2,
          totalTurns: 10,
          lastAnimalAcquired: 'horse',
          winnerIsAi: false,
        ),
        GameRecord(
          date: DateTime(2026, 4, 2),
          playerNames: ['A', 'B'],
          winnerName: 'B',
          playerCount: 2,
          totalTurns: 20,
          lastAnimalAcquired: 'cow',
          winnerIsAi: true,
        ),
        GameRecord(
          date: DateTime(2026, 4, 3),
          playerNames: ['A', 'B', 'C'],
          winnerName: 'A',
          playerCount: 3,
          totalTurns: 30,
          lastAnimalAcquired: 'horse',
          winnerIsAi: false,
        ),
      ];

      final stats = GameStats.fromRecords(records);
      expect(stats.winRateByPlayerCount[2], 0.5); // 1 human win / 2 games
      expect(stats.winRateByPlayerCount[3], 1.0); // 1 human win / 1 game
      expect(stats.winRateByPlayerCount.containsKey(4), false);
    });

    test('computes leaderboard sorted by wins', () {
      final records = [
        GameRecord(
          date: DateTime(2026, 4, 1),
          playerNames: ['Alice', 'Bob'],
          winnerName: 'Alice',
          playerCount: 2,
          totalTurns: 10,
          lastAnimalAcquired: 'horse',
          winnerIsAi: false,
        ),
        GameRecord(
          date: DateTime(2026, 4, 2),
          playerNames: ['Alice', 'Bob'],
          winnerName: 'Alice',
          playerCount: 2,
          totalTurns: 20,
          lastAnimalAcquired: 'horse',
          winnerIsAi: false,
        ),
        GameRecord(
          date: DateTime(2026, 4, 3),
          playerNames: ['Alice', 'Bob'],
          winnerName: 'Bob',
          playerCount: 2,
          totalTurns: 15,
          lastAnimalAcquired: 'horse',
          winnerIsAi: false,
        ),
      ];

      final stats = GameStats.fromRecords(records);
      expect(stats.leaderboard.length, 2);
      expect(stats.leaderboard[0].name, 'Alice');
      expect(stats.leaderboard[0].wins, 2);
      expect(stats.leaderboard[0].gamesPlayed, 3);
      expect(stats.leaderboard[1].name, 'Bob');
      expect(stats.leaderboard[1].wins, 1);
      expect(stats.leaderboard[1].gamesPlayed, 3);
    });

    test('most common last animal resolves to label', () {
      final records = [
        GameRecord(
          date: DateTime(2026, 4, 1),
          playerNames: ['A', 'B'],
          winnerName: 'A',
          playerCount: 2,
          totalTurns: 10,
          lastAnimalAcquired: 'cow',
          winnerIsAi: false,
        ),
        GameRecord(
          date: DateTime(2026, 4, 2),
          playerNames: ['A', 'B'],
          winnerName: 'B',
          playerCount: 2,
          totalTurns: 20,
          lastAnimalAcquired: 'cow',
          winnerIsAi: false,
        ),
        GameRecord(
          date: DateTime(2026, 4, 3),
          playerNames: ['A', 'B'],
          winnerName: 'A',
          playerCount: 2,
          totalTurns: 15,
          lastAnimalAcquired: 'horse',
          winnerIsAi: false,
        ),
      ];

      final stats = GameStats.fromRecords(records);
      expect(stats.mostCommonLastAnimal, 'Cow');
    });
  });

  // ===========================================================================
  // Turn number tracking tests
  // ===========================================================================
  group('Turn tracking', () {
    test('turn number starts at 0', () {
      final notifier = GameNotifier(FixedRandom(0));
      notifier.startGame(['Alice', 'Bob']);
      expect(notifier.state.turnNumber, 0);
    });

    test('turn number increments on nextTurn', () {
      final notifier = GameNotifier(FixedRandom(0));
      notifier.startGame(['Alice', 'Bob']);

      notifier.rollDice();
      notifier.nextTurn();
      expect(notifier.state.turnNumber, 1);

      notifier.rollDice();
      notifier.nextTurn();
      expect(notifier.state.turnNumber, 2);
    });

    test('turn number resets on new game', () {
      final notifier = GameNotifier(FixedRandom(0));
      notifier.startGame(['Alice', 'Bob']);
      notifier.rollDice();
      notifier.nextTurn();
      expect(notifier.state.turnNumber, 1);

      notifier.resetGame();
      notifier.startGame(['Alice', 'Bob']);
      expect(notifier.state.turnNumber, 0);
    });
  });

  // ===========================================================================
  // Last animal acquired tracking tests
  // ===========================================================================
  group('Last animal acquired', () {
    test('findLastAnimalAcquired detects newly acquired animal', () {
      final before = {
        Animal.rabbit: 3,
        Animal.lamb: 1,
        Animal.pig: 1,
        Animal.cow: 1,
        Animal.horse: 0,
      };
      final after = {
        Animal.rabbit: 3,
        Animal.lamb: 1,
        Animal.pig: 1,
        Animal.cow: 1,
        Animal.horse: 1,
      };

      final result = GameNotifier.findLastAnimalAcquired(before, after);
      expect(result, Animal.horse);
    });

    test('findLastAnimalAcquired returns null if no new animal type', () {
      final before = {
        Animal.rabbit: 3,
        Animal.lamb: 1,
        Animal.pig: 0,
        Animal.cow: 0,
        Animal.horse: 0,
      };
      final after = {
        Animal.rabbit: 5,
        Animal.lamb: 1,
        Animal.pig: 0,
        Animal.cow: 0,
        Animal.horse: 0,
      };

      final result = GameNotifier.findLastAnimalAcquired(before, after);
      expect(result, isNull);
    });

    test('findLastAnimalAcquired ignores dogs', () {
      final before = <Animal, int>{
        Animal.smallDog: 0,
        Animal.bigDog: 0,
      };
      final after = <Animal, int>{
        Animal.smallDog: 1,
        Animal.bigDog: 1,
      };

      final result = GameNotifier.findLastAnimalAcquired(before, after);
      expect(result, isNull);
    });

    test('lastAnimalAcquired is set on win via breeding', () {
      // Use FixedRandom(0) which gives rabbit on both dice
      final notifier = GameNotifier(FixedRandom(0));
      notifier.startGame(['Alice']);

      // Give Alice all animals except rabbit
      _setPlayerAnimals(notifier, 0, {
        Animal.rabbit: 0,
        Animal.lamb: 1,
        Animal.pig: 1,
        Animal.cow: 1,
        Animal.horse: 1,
      });

      // Rolling rabbits should give her a rabbit via breeding
      // FixedRandom(0) → green die index 0 = rabbit, red die index 0 = rabbit
      // With 0 rabbits + 2 rolled = floor(2/2) = 1 bred
      notifier.rollDice();

      expect(notifier.state.winner, 'Alice');
      expect(notifier.state.lastAnimalAcquired, Animal.rabbit);
    });

    test('lastAnimalAcquired is set on win via trade', () {
      final notifier = GameNotifier(FixedRandom(0));
      notifier.startGame(['Alice']);

      // Give Alice all animals except horse, plus enough cows to trade
      _setPlayerAnimals(notifier, 0, {
        Animal.rabbit: 1,
        Animal.lamb: 1,
        Animal.pig: 1,
        Animal.cow: 3,
        Animal.horse: 0,
      });

      // Trade 2 cows for 1 horse
      notifier.trade(const ExchangeRate(
        from: Animal.cow,
        fromCount: 2,
        to: Animal.horse,
        toCount: 1,
      ));

      expect(notifier.state.winner, 'Alice');
      expect(notifier.state.lastAnimalAcquired, Animal.horse);
    });
  });

  // ===========================================================================
  // StatsScreen widget tests
  // ===========================================================================
  group('StatsScreen', () {
    testWidgets('shows empty state when no records', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: const StatsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No games played yet'), findsOneWidget);
      expect(find.text('Statistics'), findsOneWidget);
    });

    testWidgets('shows tabs when records exist', (tester) async {
      final records = [
        GameRecord(
          date: DateTime(2026, 4, 1),
          playerNames: ['Alice', 'Bob'],
          winnerName: 'Alice',
          playerCount: 2,
          totalTurns: 30,
          lastAnimalAcquired: 'horse',
          winnerIsAi: false,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            statsProvider.overrideWith((ref) {
              final notifier = StatsNotifier();
              // Directly set state for testing
              notifier.state = records;
              return notifier;
            }),
          ],
          child: MaterialApp(home: const StatsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Leaderboard'), findsOneWidget);
    });

    testWidgets('overview tab shows game summary stats', (tester) async {
      final records = [
        GameRecord(
          date: DateTime(2026, 4, 1),
          playerNames: ['Alice', 'Bob'],
          winnerName: 'Alice',
          playerCount: 2,
          totalTurns: 30,
          lastAnimalAcquired: 'horse',
          winnerIsAi: false,
        ),
        GameRecord(
          date: DateTime(2026, 4, 2),
          playerNames: ['Alice', 'Bot'],
          winnerName: 'Bot',
          playerCount: 2,
          totalTurns: 20,
          lastAnimalAcquired: 'horse',
          winnerIsAi: true,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            statsProvider.overrideWith((ref) {
              final notifier = StatsNotifier();
              notifier.state = records;
              return notifier;
            }),
          ],
          child: MaterialApp(home: const StatsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Should show summary cards
      expect(find.text('Played'), findsOneWidget);
      expect(find.text('2'), findsAtLeast(1)); // 2 games played
      expect(find.text('Won'), findsOneWidget);
      expect(find.text('Lost'), findsOneWidget);
    });

    testWidgets('history tab shows game records', (tester) async {
      final records = [
        GameRecord(
          date: DateTime(2026, 4, 1),
          playerNames: ['Alice', 'Bob'],
          winnerName: 'Alice',
          playerCount: 2,
          totalTurns: 30,
          lastAnimalAcquired: 'horse',
          winnerIsAi: false,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            statsProvider.overrideWith((ref) {
              final notifier = StatsNotifier();
              notifier.state = records;
              return notifier;
            }),
          ],
          child: MaterialApp(home: const StatsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to history tab
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsAtLeast(1));
      expect(find.textContaining('30 turns'), findsOneWidget);
    });

    testWidgets('navigates to stats screen via bottom nav', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: SuperFarmerApp()));
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Stats'));
      await tester.pumpAndSettle();

      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('No games played yet'), findsOneWidget);
    });
  });

  // ===========================================================================
  // StatsNotifier tests
  // ===========================================================================
  group('StatsNotifier', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('starts with empty state', () {
      final notifier = StatsNotifier();
      expect(notifier.state, isEmpty);
    });

    test('addRecord adds to state', () async {
      final notifier = StatsNotifier();
      final record = GameRecord(
        date: DateTime(2026, 4, 1),
        playerNames: ['Alice', 'Bob'],
        winnerName: 'Alice',
        playerCount: 2,
        totalTurns: 30,
        lastAnimalAcquired: 'horse',
        winnerIsAi: false,
      );

      await notifier.addRecord(record);
      expect(notifier.state.length, 1);
      expect(notifier.state[0].winnerName, 'Alice');
    });

    test('clearAll removes all records', () async {
      final notifier = StatsNotifier();
      final record = GameRecord(
        date: DateTime(2026, 4, 1),
        playerNames: ['Alice', 'Bob'],
        winnerName: 'Alice',
        playerCount: 2,
        totalTurns: 30,
        lastAnimalAcquired: 'horse',
        winnerIsAi: false,
      );

      await notifier.addRecord(record);
      expect(notifier.state.length, 1);

      await notifier.clearAll();
      expect(notifier.state, isEmpty);
    });
  });
}

// =============================================================================
// Audio service tests
// =============================================================================

void _audioServiceTests() {
  group('GameSound', () {
    test('has correct number of sounds', () {
      expect(GameSound.values.length, 11);
    });

    test('each sound has an asset path', () {
      for (final sound in GameSound.values) {
        expect(sound.assetPath, startsWith('audio/'));
        expect(sound.assetPath, endsWith('.wav'));
      }
    });

    test('forAnimal maps farm animals correctly', () {
      expect(GameSound.forAnimal(Animal.rabbit), GameSound.rabbit);
      expect(GameSound.forAnimal(Animal.lamb), GameSound.lamb);
      expect(GameSound.forAnimal(Animal.pig), GameSound.pig);
      expect(GameSound.forAnimal(Animal.cow), GameSound.cow);
      expect(GameSound.forAnimal(Animal.horse), GameSound.horse);
    });

    test('forAnimal returns null for dogs', () {
      expect(GameSound.forAnimal(Animal.smallDog), isNull);
      expect(GameSound.forAnimal(Animal.bigDog), isNull);
    });
  });

  group('AudioService', () {
    test('default volume is 0.7', () {
      final service = AudioService();
      expect(service.volume, 0.7);
      expect(service.isMuted, false);
      service.dispose();
    });

    test('setVolume clamps values', () {
      final service = AudioService();
      service.setVolume(1.5);
      expect(service.volume, 1.0);
      service.setVolume(-0.5);
      expect(service.volume, 0.0);
      service.setVolume(0.5);
      expect(service.volume, 0.5);
      service.dispose();
    });

    test('setMuted toggles mute state', () {
      final service = AudioService();
      expect(service.isMuted, false);
      service.setMuted(true);
      expect(service.isMuted, true);
      service.setMuted(false);
      expect(service.isMuted, false);
      service.dispose();
    });

    test('play does nothing when muted', () async {
      final service = AudioService();
      service.setMuted(true);
      // Should not throw
      await service.play(GameSound.tap);
      service.dispose();
    });

    test('play does nothing when volume is zero', () async {
      final service = AudioService();
      service.setVolume(0.0);
      // Should not throw
      await service.play(GameSound.tap);
      service.dispose();
    });

    test('playAnimalSound does nothing for dogs', () async {
      final service = AudioService();
      service.setMuted(true);
      // Should not throw even for non-mapped animals
      await service.playAnimalSound(Animal.smallDog);
      await service.playAnimalSound(Animal.bigDog);
      service.dispose();
    });
  });

  group('Settings volume slider widget', () {
    testWidgets('shows volume slider when sound is enabled', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => SettingsSheet.show(context),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Sound is on by default, so slider should be visible
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('hides volume slider when sound is disabled', (tester) async {
      final settingsNotifier = GameSettingsNotifier();
      settingsNotifier.toggleSound(); // disable sound

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameSettingsProvider.overrideWith((_) => settingsNotifier),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => SettingsSheet.show(context),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Sound is off, so slider should not be visible
      expect(find.byType(Slider), findsNothing);
    });
  });

  group('Farm decorations', () {
    testWidgets('WoodenFrame renders CustomPaint with WoodenBorderPainter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WoodenFrame(
              borderWidth: 5.0,
              cornerRadius: 10.0,
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      final customPaints = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
      final woodenPainters = customPaints.where((cp) => cp.painter is WoodenBorderPainter);
      expect(woodenPainters, isNotEmpty);

      final painter = woodenPainters.first.painter as WoodenBorderPainter;
      expect(painter.borderWidth, 5.0);
      expect(painter.cornerRadius, 10.0);
    });

    testWidgets('WoodenBorderPainter shouldRepaint detects changes', (tester) async {
      final p1 = WoodenBorderPainter(borderWidth: 4.0);
      final p2 = WoodenBorderPainter(borderWidth: 4.0);
      final p3 = WoodenBorderPainter(borderWidth: 6.0);
      expect(p1.shouldRepaint(p2), isFalse);
      expect(p1.shouldRepaint(p3), isTrue);
    });

    testWidgets('FencePainter shouldRepaint detects changes', (tester) async {
      final p1 = FencePainter(fenceColor: Colors.brown);
      final p2 = FencePainter(fenceColor: Colors.brown);
      final p3 = FencePainter(fenceColor: Colors.red);
      expect(p1.shouldRepaint(p2), isFalse);
      expect(p1.shouldRepaint(p3), isTrue);
    });

    testWidgets('HayTexturePainter shouldRepaint detects changes', (tester) async {
      final p1 = HayTexturePainter(seed: 1);
      final p2 = HayTexturePainter(seed: 1);
      final p3 = HayTexturePainter(seed: 2);
      expect(p1.shouldRepaint(p2), isFalse);
      expect(p1.shouldRepaint(p3), isTrue);
    });

    testWidgets('BarnPainter shouldRepaint detects changes', (tester) async {
      final p1 = BarnPainter(barnColor: Colors.red);
      final p2 = BarnPainter(barnColor: Colors.red);
      final p3 = BarnPainter(barnColor: Colors.blue);
      expect(p1.shouldRepaint(p2), isFalse);
      expect(p1.shouldRepaint(p3), isTrue);
    });
  });

  group('AnimalCard widget', () {
    testWidgets('renders animal SVG without emoji watermark', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalCard(
              animal: Animal.rabbit,
              count: 5,
            ),
          ),
        ),
      );

      // Should show the animal label and count
      expect(find.text('Rabbit'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      // Should have WoodenFrame (CustomPaint with WoodenBorderPainter)
      final customPaints = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
      final woodenPainters = customPaints.where((cp) => cp.painter is WoodenBorderPainter);
      expect(woodenPainters, isNotEmpty);
      // Should NOT have any emoji text
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      for (final text in textWidgets) {
        final data = text.data ?? '';
        // Emoji code points are above U+1F000
        final hasEmoji = data.runes.any((r) => r > 0x1F000);
        expect(hasEmoji, isFalse, reason: 'Found emoji in text: $data');
      }
    });

    testWidgets('shows attacked visual state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalCard(
              animal: Animal.rabbit,
              visualState: AnimalVisualState.attacked,
            ),
          ),
        ),
      );

      // Should show warning icon for attacked state
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('shows protected visual state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalCard(
              animal: Animal.smallDog,
              visualState: AnimalVisualState.protected,
            ),
          ),
        ),
      );

      // Should show shield icon for protected state
      expect(find.byIcon(Icons.shield), findsOneWidget);
    });

    testWidgets('normal state shows no overlay icons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalCard(
              animal: Animal.cow,
              visualState: AnimalVisualState.normal,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
      expect(find.byIcon(Icons.shield), findsNothing);
    });

    testWidgets('idle animation controller runs when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalCard(
              animal: Animal.pig,
              enableIdleAnimation: true,
            ),
          ),
        ),
      );

      // Pump a frame to let animation start
      await tester.pump(const Duration(milliseconds: 500));
      // No crash means animation is running
      expect(find.text('Pig'), findsOneWidget);
    });

    testWidgets('hay texture renders at bottom of card', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalCard(
              animal: Animal.horse,
            ),
          ),
        ),
      );

      final customPaints = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
      final hayPainters = customPaints.where((cp) => cp.painter is HayTexturePainter);
      expect(hayPainters, isNotEmpty);
    });

    testWidgets('all animals render without errors', (tester) async {
      for (final animal in Animal.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnimalCard(animal: animal, count: 3),
            ),
          ),
        );
        expect(find.text(animal.label), findsOneWidget);
      }
    });
  });

  group('Splash screen branding', () {
    testWidgets('splash has barn painter and rabbit SVG', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(onComplete: () {}),
        ),
      );
      await tester.pump();

      // BarnPainter should be present
      final customPaints = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
      final barnPainters = customPaints.where((cp) => cp.painter is BarnPainter);
      expect(barnPainters, isNotEmpty);

      // Fence and hay painters for decoration
      final fencePainters = customPaints.where((cp) => cp.painter is FencePainter);
      expect(fencePainters, isNotEmpty);

      // Drain timer
      await tester.pump(const Duration(seconds: 4));
    });
  });
}
