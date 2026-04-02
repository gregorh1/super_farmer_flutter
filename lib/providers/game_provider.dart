import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/animal.dart';
import '../models/dice.dart';
import '../models/exchange.dart';

class PlayerHerd {
  const PlayerHerd({
    this.animals = const {},
    this.name = '',
  });

  final Map<Animal, int> animals;
  final String name;

  PlayerHerd copyWith({Map<Animal, int>? animals, String? name}) {
    return PlayerHerd(
      animals: animals ?? this.animals,
      name: name ?? this.name,
    );
  }

  int countOf(Animal animal) => animals[animal] ?? 0;

  bool get hasWon => Animal.values
      .where((a) => a != Animal.smallDog && a != Animal.bigDog)
      .every((a) => countOf(a) >= 1);
}

class GameState {
  const GameState({
    this.players = const [],
    this.currentPlayerIndex = 0,
    this.isStarted = false,
    this.bank = const {},
    this.lastRoll,
    this.winner,
  });

  final List<PlayerHerd> players;
  final int currentPlayerIndex;
  final bool isStarted;
  final Map<Animal, int> bank;
  final DiceRollResult? lastRoll;
  final String? winner;

  PlayerHerd? get currentPlayer =>
      players.isEmpty ? null : players[currentPlayerIndex];

  GameState copyWith({
    List<PlayerHerd>? players,
    int? currentPlayerIndex,
    bool? isStarted,
    Map<Animal, int>? bank,
    DiceRollResult? lastRoll,
    bool clearLastRoll = false,
    String? winner,
    bool clearWinner = false,
  }) {
    return GameState(
      players: players ?? this.players,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      isStarted: isStarted ?? this.isStarted,
      bank: bank ?? this.bank,
      lastRoll: clearLastRoll ? null : (lastRoll ?? this.lastRoll),
      winner: clearWinner ? null : (winner ?? this.winner),
    );
  }

  static Map<Animal, int> initialBank() => {
        Animal.rabbit: 60,
        Animal.lamb: 24,
        Animal.pig: 20,
        Animal.cow: 12,
        Animal.horse: 6,
        Animal.smallDog: 4,
        Animal.bigDog: 2,
      };
}

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier([Random? random]) : _random = random, super(const GameState());

  final Random? _random;

  void startGame(List<String> playerNames) {
    state = GameState(
      players: playerNames
          .map((name) => PlayerHerd(
                name: name,
                animals: {for (final a in Animal.values) a: 0},
              ))
          .toList(),
      currentPlayerIndex: 0,
      isStarted: true,
      bank: GameState.initialBank(),
    );
  }

  void resetGame() {
    state = const GameState();
  }

  void nextTurn() {
    if (state.players.isEmpty) return;
    state = state.copyWith(
      currentPlayerIndex:
          (state.currentPlayerIndex + 1) % state.players.length,
      clearLastRoll: true,
    );
  }

  /// Rolls dice, applies breeding, then applies predator attacks.
  /// Returns the dice roll result.
  DiceRollResult rollDice() {
    final roll = DiceRollResult.roll(_random);
    state = state.copyWith(lastRoll: roll);

    final playerIndex = state.currentPlayerIndex;
    var playerAnimals = Map<Animal, int>.from(state.players[playerIndex].animals);
    var bank = Map<Animal, int>.from(state.bank);

    // Apply breeding: for each animal on the dice, gain floor((owned + rolled) / 2)
    for (final entry in roll.rolledAnimals.entries) {
      final animal = entry.key;
      final rolledCount = entry.value;
      final owned = playerAnimals[animal] ?? 0;
      final bred = (owned + rolledCount) ~/ 2;
      if (bred > 0) {
        // Limited by bank stock
        final available = bank[animal] ?? 0;
        final gained = bred < available ? bred : available;
        playerAnimals[animal] = owned + gained;
        bank[animal] = available - gained;
      }
    }

    // Apply fox attack: lose all rabbits (unless small dog protects)
    if (roll.hasFox) {
      if ((playerAnimals[Animal.smallDog] ?? 0) > 0) {
        // Small dog is sacrificed back to bank
        playerAnimals[Animal.smallDog] = (playerAnimals[Animal.smallDog] ?? 0) - 1;
        bank[Animal.smallDog] = (bank[Animal.smallDog] ?? 0) + 1;
      } else {
        // Lose all rabbits back to bank
        final rabbits = playerAnimals[Animal.rabbit] ?? 0;
        bank[Animal.rabbit] = (bank[Animal.rabbit] ?? 0) + rabbits;
        playerAnimals[Animal.rabbit] = 0;
      }
    }

    // Apply wolf attack: lose all animals except horse and small dog (unless big dog protects)
    if (roll.hasWolf) {
      if ((playerAnimals[Animal.bigDog] ?? 0) > 0) {
        // Big dog is sacrificed back to bank
        playerAnimals[Animal.bigDog] = (playerAnimals[Animal.bigDog] ?? 0) - 1;
        bank[Animal.bigDog] = (bank[Animal.bigDog] ?? 0) + 1;
      } else {
        // Lose all animals except horse and small dog
        for (final animal in Animal.values) {
          if (animal == Animal.horse || animal == Animal.smallDog) continue;
          final count = playerAnimals[animal] ?? 0;
          bank[animal] = (bank[animal] ?? 0) + count;
          playerAnimals[animal] = 0;
        }
      }
    }

    // Update state
    final updatedPlayers = List<PlayerHerd>.from(state.players);
    updatedPlayers[playerIndex] = updatedPlayers[playerIndex].copyWith(
      animals: playerAnimals,
    );

    // Check win condition
    final updatedHerd = updatedPlayers[playerIndex];
    String? winner;
    if (updatedHerd.hasWon) {
      winner = updatedHerd.name;
    }

    state = state.copyWith(
      players: updatedPlayers,
      bank: bank,
      winner: winner,
    );

    return roll;
  }

  /// Execute a trade: player gives [rate.fromCount] of [rate.from],
  /// receives [rate.toCount] of [rate.to] from the bank.
  bool trade(ExchangeRate rate) {
    final playerIndex = state.currentPlayerIndex;
    final playerAnimals = Map<Animal, int>.from(state.players[playerIndex].animals);
    final bank = Map<Animal, int>.from(state.bank);

    // Validate player has enough
    if ((playerAnimals[rate.from] ?? 0) < rate.fromCount) return false;
    // Validate bank has enough
    if ((bank[rate.to] ?? 0) < rate.toCount) return false;

    // Execute trade
    playerAnimals[rate.from] = (playerAnimals[rate.from] ?? 0) - rate.fromCount;
    playerAnimals[rate.to] = (playerAnimals[rate.to] ?? 0) + rate.toCount;
    bank[rate.from] = (bank[rate.from] ?? 0) + rate.fromCount;
    bank[rate.to] = (bank[rate.to] ?? 0) - rate.toCount;

    final updatedPlayers = List<PlayerHerd>.from(state.players);
    updatedPlayers[playerIndex] = updatedPlayers[playerIndex].copyWith(
      animals: playerAnimals,
    );

    // Check win after trade
    String? winner;
    if (updatedPlayers[playerIndex].hasWon) {
      winner = updatedPlayers[playerIndex].name;
    }

    state = state.copyWith(
      players: updatedPlayers,
      bank: bank,
      winner: winner,
    );

    return true;
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>(
  (ref) => GameNotifier(),
);
