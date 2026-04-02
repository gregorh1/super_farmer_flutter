import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/animal.dart';

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
  });

  final List<PlayerHerd> players;
  final int currentPlayerIndex;
  final bool isStarted;

  PlayerHerd? get currentPlayer =>
      players.isEmpty ? null : players[currentPlayerIndex];

  GameState copyWith({
    List<PlayerHerd>? players,
    int? currentPlayerIndex,
    bool? isStarted,
  }) {
    return GameState(
      players: players ?? this.players,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      isStarted: isStarted ?? this.isStarted,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier() : super(const GameState());

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
    );
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>(
  (ref) => GameNotifier(),
);
