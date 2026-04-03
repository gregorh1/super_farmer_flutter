import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_farmer/models/animal.dart';
import 'package:super_farmer/models/dice.dart';
import 'package:super_farmer/models/exchange.dart';
import 'package:super_farmer/models/game_replay.dart';
import 'package:super_farmer/providers/game_provider.dart';
import 'package:super_farmer/providers/replay_provider.dart';

void main() {
  group('TradeRecord', () {
    test('serializes to and from JSON', () {
      const trade = TradeRecord(
        fromAnimal: 'rabbit',
        fromCount: 6,
        toAnimal: 'lamb',
        toCount: 1,
      );

      final json = trade.toJson();
      final restored = TradeRecord.fromJson(json);

      expect(restored.fromAnimal, 'rabbit');
      expect(restored.fromCount, 6);
      expect(restored.toAnimal, 'lamb');
      expect(restored.toCount, 1);
    });
  });

  group('TurnRecord', () {
    test('serializes to and from JSON', () {
      const turn = TurnRecord(
        turnNumber: 5,
        playerIndex: 0,
        playerName: 'Alice',
        greenDie: 'rabbit',
        redDie: 'lamb',
        bred: {'rabbit': 3},
        lostAnimals: {},
        foxAttack: false,
        wolfAttack: false,
        trades: [
          TradeRecord(
            fromAnimal: 'rabbit',
            fromCount: 6,
            toAnimal: 'lamb',
            toCount: 1,
          ),
        ],
        playerAnimalsAfter: {
          'Alice': {'rabbit': 10, 'lamb': 2, 'pig': 0, 'cow': 0, 'horse': 0},
          'Bob': {'rabbit': 5, 'lamb': 1, 'pig': 0, 'cow': 0, 'horse': 0},
        },
      );

      final json = turn.toJson();
      final restored = TurnRecord.fromJson(json);

      expect(restored.turnNumber, 5);
      expect(restored.playerIndex, 0);
      expect(restored.playerName, 'Alice');
      expect(restored.greenDie, 'rabbit');
      expect(restored.redDie, 'lamb');
      expect(restored.bred, {'rabbit': 3});
      expect(restored.lostAnimals, isEmpty);
      expect(restored.foxAttack, false);
      expect(restored.wolfAttack, false);
      expect(restored.trades.length, 1);
      expect(restored.trades[0].fromAnimal, 'rabbit');
      expect(restored.playerAnimalsAfter['Alice']?['rabbit'], 10);
      expect(restored.playerAnimalsAfter['Bob']?['rabbit'], 5);
    });

    test('helper getters return correct typed values', () {
      const turn = TurnRecord(
        turnNumber: 0,
        playerIndex: 0,
        playerName: 'Test',
        greenDie: 'rabbit',
        redDie: 'fox',
        bred: {'rabbit': 2, 'lamb': 1},
        lostAnimals: {'cow': 1},
        playerAnimalsAfter: {},
      );

      expect(turn.greenDiceFace, DiceFace.rabbit);
      expect(turn.redDiceFace, DiceFace.fox);
      expect(turn.bredAnimals, {Animal.rabbit: 2, Animal.lamb: 1});
      expect(turn.lostAnimalsTyped, {Animal.cow: 1});
    });

    test('handles fox and wolf attacks in serialization', () {
      const turn = TurnRecord(
        turnNumber: 3,
        playerIndex: 1,
        playerName: 'Bob',
        greenDie: 'wolf',
        redDie: 'fox',
        foxAttack: true,
        wolfAttack: true,
        smallDogSacrificed: true,
        bigDogSacrificed: true,
        lostAnimals: {'rabbit': 10},
        playerAnimalsAfter: {},
      );

      final json = turn.toJson();
      final restored = TurnRecord.fromJson(json);

      expect(restored.foxAttack, true);
      expect(restored.wolfAttack, true);
      expect(restored.smallDogSacrificed, true);
      expect(restored.bigDogSacrificed, true);
      expect(restored.lostAnimals['rabbit'], 10);
    });
  });

  group('GameReplay', () {
    GameReplay _sampleReplay() {
      return GameReplay(
        id: '12345',
        date: DateTime(2026, 4, 1),
        playerNames: ['Alice', 'Bob'],
        playerColors: [0xFF4CAF50, 0xFF2196F3],
        winnerName: 'Alice',
        totalTurns: 20,
        turns: const [
          TurnRecord(
            turnNumber: 0,
            playerIndex: 0,
            playerName: 'Alice',
            greenDie: 'rabbit',
            redDie: 'rabbit',
            bred: {'rabbit': 1},
            playerAnimalsAfter: {
              'Alice': {'rabbit': 1},
              'Bob': {'rabbit': 0},
            },
          ),
          TurnRecord(
            turnNumber: 1,
            playerIndex: 1,
            playerName: 'Bob',
            greenDie: 'lamb',
            redDie: 'pig',
            playerAnimalsAfter: {
              'Alice': {'rabbit': 1},
              'Bob': {'rabbit': 0},
            },
          ),
        ],
      );
    }

    test('serializes to and from JSON', () {
      final replay = _sampleReplay();
      final json = replay.toJson();
      final restored = GameReplay.fromJson(json);

      expect(restored.id, '12345');
      expect(restored.date, DateTime(2026, 4, 1));
      expect(restored.playerNames, ['Alice', 'Bob']);
      expect(restored.playerColors, [0xFF4CAF50, 0xFF2196F3]);
      expect(restored.winnerName, 'Alice');
      expect(restored.totalTurns, 20);
      expect(restored.turns.length, 2);
      expect(restored.turns[0].playerName, 'Alice');
      expect(restored.turns[1].playerName, 'Bob');
    });

    test('encode and decode list of replays', () {
      final replays = [_sampleReplay()];
      final encoded = GameReplay.encode(replays);
      final decoded = GameReplay.decode(encoded);

      expect(decoded.length, 1);
      expect(decoded[0].id, '12345');
      expect(decoded[0].turns.length, 2);
    });

    test('export and import single replay as JSON', () {
      final replay = _sampleReplay();
      final json = replay.exportJson();
      final imported = GameReplay.importJson(json);

      expect(imported.id, replay.id);
      expect(imported.winnerName, replay.winnerName);
      expect(imported.turns.length, replay.turns.length);
    });

    test('import rejects invalid JSON', () {
      expect(() => GameReplay.importJson('not json'), throwsA(anything));
      expect(
          () => GameReplay.importJson('{"id": 123}'), throwsA(anything));
    });
  });

  group('ReplayRecorder', () {
    test('records a complete game with dice rolls, trades, and turns', () {
      final recorder = ReplayRecorder();

      // Start recording
      recorder.startRecording(
        ['Alice', 'Bob'],
        [const Color(0xFF4CAF50), const Color(0xFF2196F3)],
      );
      expect(recorder.isRecording, true);

      // Simulate Alice's turn: dice roll
      final event1 = TurnEvent(
        roll: const DiceRollResult(
            green: DiceFace.rabbit, red: DiceFace.rabbit),
        bred: {Animal.rabbit: 1},
      );
      recorder.recordDiceRoll(event1, 0, 0, 'Alice');

      // Alice trades
      recorder.recordTrade(const ExchangeRate(
        from: Animal.rabbit,
        fromCount: 6,
        to: Animal.lamb,
        toCount: 1,
      ));

      // Finalize Alice's turn
      final aliceState = GameState(
        players: [
          PlayerHerd(
            name: 'Alice',
            animals: {Animal.rabbit: 4, Animal.lamb: 1},
          ),
          PlayerHerd(
            name: 'Bob',
            animals: {Animal.rabbit: 0},
          ),
        ],
      );
      recorder.finalizeTurn(aliceState);

      // Simulate Bob's turn: dice roll with fox
      final event2 = TurnEvent(
        roll:
            const DiceRollResult(green: DiceFace.rabbit, red: DiceFace.fox),
        foxAttack: true,
        lostAnimals: {Animal.rabbit: 5},
      );
      recorder.recordDiceRoll(event2, 1, 1, 'Bob');

      // Finalize Bob's turn
      final bobState = GameState(
        players: [
          PlayerHerd(
            name: 'Alice',
            animals: {Animal.rabbit: 4, Animal.lamb: 1},
          ),
          PlayerHerd(
            name: 'Bob',
            animals: {Animal.rabbit: 0},
          ),
        ],
      );
      recorder.finalizeTurn(bobState);

      // Build the replay
      final replay = recorder.buildReplay('Alice', 2);

      expect(replay, isNotNull);
      expect(replay!.turns.length, 2);
      expect(replay.winnerName, 'Alice');
      expect(replay.totalTurns, 2);
      expect(replay.playerNames, ['Alice', 'Bob']);

      // Verify first turn details
      final turn1 = replay.turns[0];
      expect(turn1.playerName, 'Alice');
      expect(turn1.greenDie, 'rabbit');
      expect(turn1.redDie, 'rabbit');
      expect(turn1.bred, {'rabbit': 1});
      expect(turn1.trades.length, 1);
      expect(turn1.trades[0].fromAnimal, 'rabbit');
      expect(turn1.trades[0].toAnimal, 'lamb');

      // Verify second turn details
      final turn2 = replay.turns[1];
      expect(turn2.playerName, 'Bob');
      expect(turn2.foxAttack, true);
      expect(turn2.lostAnimals, {'rabbit': 5});

      // Player animals snapshot
      expect(turn1.playerAnimalsAfter['Alice']?['rabbit'], 4);
      expect(turn1.playerAnimalsAfter['Alice']?['lamb'], 1);
    });

    test('stopRecording clears state', () {
      final recorder = ReplayRecorder();
      recorder.startRecording(['Alice'], [const Color(0xFF4CAF50)]);
      expect(recorder.isRecording, true);

      recorder.stopRecording();
      expect(recorder.isRecording, false);
      expect(recorder.turns, isEmpty);
    });

    test('buildReplay returns null when no turns recorded', () {
      final recorder = ReplayRecorder();
      recorder.startRecording(['Alice'], [const Color(0xFF4CAF50)]);

      final replay = recorder.buildReplay('Alice', 0);
      expect(replay, isNull);
    });

    test('buildReplay stops recording', () {
      final recorder = ReplayRecorder();
      recorder.startRecording(['Alice'], [const Color(0xFF4CAF50)]);

      final event = TurnEvent(
        roll: const DiceRollResult(
            green: DiceFace.rabbit, red: DiceFace.rabbit),
      );
      recorder.recordDiceRoll(event, 0, 0, 'Alice');
      recorder.finalizeTurn(const GameState(
        players: [PlayerHerd(name: 'Alice')],
      ));

      final replay = recorder.buildReplay('Alice', 1);
      expect(replay, isNotNull);
      expect(recorder.isRecording, false);
    });

    test('does not record when not recording', () {
      final recorder = ReplayRecorder();

      // These should be no-ops
      final event = TurnEvent(
        roll: const DiceRollResult(
            green: DiceFace.rabbit, red: DiceFace.rabbit),
      );
      recorder.recordDiceRoll(event, 0, 0, 'Alice');
      recorder.recordTrade(const ExchangeRate(
        from: Animal.rabbit,
        fromCount: 6,
        to: Animal.lamb,
        toCount: 1,
      ));
      recorder.finalizeTurn(const GameState());

      expect(recorder.turns, isEmpty);
    });
  });

  group('ReplayPlaybackNotifier', () {
    late ReplayPlaybackNotifier notifier;

    final sampleReplay = GameReplay(
      id: '1',
      date: DateTime(2026, 1, 1),
      playerNames: ['Alice', 'Bob'],
      playerColors: [0xFF4CAF50, 0xFF2196F3],
      winnerName: 'Alice',
      totalTurns: 10,
      turns: List.generate(
        5,
        (i) => TurnRecord(
          turnNumber: i,
          playerIndex: i % 2,
          playerName: i % 2 == 0 ? 'Alice' : 'Bob',
          greenDie: 'rabbit',
          redDie: 'rabbit',
          playerAnimalsAfter: const {},
        ),
      ),
    );

    setUp(() {
      notifier = ReplayPlaybackNotifier();
    });

    test('initial state has no replay', () {
      expect(notifier.state.replay, isNull);
      expect(notifier.state.currentTurnIndex, 0);
      expect(notifier.state.isPlaying, false);
    });

    test('loadReplay sets replay and resets index', () {
      notifier.loadReplay(sampleReplay);

      expect(notifier.state.replay, isNotNull);
      expect(notifier.state.currentTurnIndex, 0);
      expect(notifier.state.totalTurns, 5);
    });

    test('stepForward advances turn index', () {
      notifier.loadReplay(sampleReplay);

      notifier.stepForward();
      expect(notifier.state.currentTurnIndex, 1);

      notifier.stepForward();
      expect(notifier.state.currentTurnIndex, 2);
    });

    test('stepForward stops at end', () {
      notifier.loadReplay(sampleReplay);

      for (int i = 0; i < 10; i++) {
        notifier.stepForward();
      }
      // Should be at index 4 (last turn, 5 turns total)
      expect(notifier.state.currentTurnIndex, 4);
      expect(notifier.state.isAtEnd, true);
    });

    test('stepBackward decrements turn index', () {
      notifier.loadReplay(sampleReplay);
      notifier.stepForward();
      notifier.stepForward();
      expect(notifier.state.currentTurnIndex, 2);

      notifier.stepBackward();
      expect(notifier.state.currentTurnIndex, 1);
    });

    test('stepBackward stops at start', () {
      notifier.loadReplay(sampleReplay);
      notifier.stepBackward();
      expect(notifier.state.currentTurnIndex, 0);
      expect(notifier.state.isAtStart, true);
    });

    test('jumpToTurn clamps within bounds', () {
      notifier.loadReplay(sampleReplay);

      notifier.jumpToTurn(3);
      expect(notifier.state.currentTurnIndex, 3);

      notifier.jumpToTurn(-1);
      expect(notifier.state.currentTurnIndex, 0);

      notifier.jumpToTurn(100);
      expect(notifier.state.currentTurnIndex, 4);
    });

    test('play and pause toggle isPlaying', () {
      notifier.loadReplay(sampleReplay);

      notifier.play();
      expect(notifier.state.isPlaying, true);

      notifier.pause();
      expect(notifier.state.isPlaying, false);
    });

    test('togglePlayPause works correctly', () {
      notifier.loadReplay(sampleReplay);

      notifier.togglePlayPause();
      expect(notifier.state.isPlaying, true);

      notifier.togglePlayPause();
      expect(notifier.state.isPlaying, false);
    });

    test('setSpeed updates playback speed', () {
      notifier.setSpeed(2.0);
      expect(notifier.state.playbackSpeed, 2.0);

      notifier.setSpeed(0.5);
      expect(notifier.state.playbackSpeed, 0.5);
    });

    test('reset clears all state', () {
      notifier.loadReplay(sampleReplay);
      notifier.stepForward();
      notifier.play();

      notifier.reset();
      expect(notifier.state.replay, isNull);
      expect(notifier.state.currentTurnIndex, 0);
      expect(notifier.state.isPlaying, false);
    });

    test('currentTurn returns correct turn', () {
      notifier.loadReplay(sampleReplay);

      expect(notifier.state.currentTurn?.playerName, 'Alice');

      notifier.stepForward();
      expect(notifier.state.currentTurn?.playerName, 'Bob');
    });

    test('play does nothing when at end', () {
      notifier.loadReplay(sampleReplay);
      // Go to the end
      for (int i = 0; i < 5; i++) {
        notifier.stepForward();
      }
      notifier.play();
      expect(notifier.state.isPlaying, false);
    });
  });

  group('ReplayPlaybackState', () {
    test('isAtStart and isAtEnd properties', () {
      const state = ReplayPlaybackState();
      expect(state.isAtStart, true);
      expect(state.isAtEnd, true); // No replay loaded

      final replay = GameReplay(
        id: '1',
        date: DateTime(2026, 1, 1),
        playerNames: ['A'],
        playerColors: [0xFF000000],
        winnerName: 'A',
        totalTurns: 1,
        turns: const [
          TurnRecord(
            turnNumber: 0,
            playerIndex: 0,
            playerName: 'A',
            greenDie: 'rabbit',
            redDie: 'rabbit',
            playerAnimalsAfter: {},
          ),
        ],
      );

      final loaded = ReplayPlaybackState(replay: replay);
      expect(loaded.isAtStart, true);
      expect(loaded.isAtEnd, true); // Only 1 turn, index 0 is the end
    });

    test('totalTurns is 0 when no replay', () {
      const state = ReplayPlaybackState();
      expect(state.totalTurns, 0);
    });
  });

  group('GameReplay JSON round-trip integration', () {
    test('full replay survives encode/decode cycle', () {
      final original = GameReplay(
        id: 'integration-test',
        date: DateTime(2026, 3, 15, 14, 30),
        playerNames: ['Player 1', 'AI Bot'],
        playerColors: [0xFF4CAF50, 0xFFFF5722],
        winnerName: 'Player 1',
        totalTurns: 42,
        turns: [
          const TurnRecord(
            turnNumber: 0,
            playerIndex: 0,
            playerName: 'Player 1',
            greenDie: 'rabbit',
            redDie: 'lamb',
            bred: {'rabbit': 1},
            trades: [
              TradeRecord(
                fromAnimal: 'rabbit',
                fromCount: 6,
                toAnimal: 'lamb',
                toCount: 1,
              ),
            ],
            playerAnimalsAfter: {
              'Player 1': {
                'rabbit': 4,
                'lamb': 2,
                'pig': 0,
                'cow': 0,
                'horse': 0,
                'smallDog': 0,
                'bigDog': 0,
              },
              'AI Bot': {
                'rabbit': 0,
                'lamb': 0,
                'pig': 0,
                'cow': 0,
                'horse': 0,
                'smallDog': 0,
                'bigDog': 0,
              },
            },
          ),
          const TurnRecord(
            turnNumber: 1,
            playerIndex: 1,
            playerName: 'AI Bot',
            greenDie: 'wolf',
            redDie: 'fox',
            foxAttack: true,
            wolfAttack: true,
            smallDogSacrificed: true,
            bigDogSacrificed: false,
            lostAnimals: {'rabbit': 3, 'lamb': 2},
            playerAnimalsAfter: {
              'Player 1': {
                'rabbit': 4,
                'lamb': 2,
              },
              'AI Bot': {
                'rabbit': 0,
                'lamb': 0,
              },
            },
          ),
        ],
      );

      // Encode as list → decode
      final listEncoded = GameReplay.encode([original]);
      final listDecoded = GameReplay.decode(listEncoded);
      expect(listDecoded.length, 1);

      final decoded = listDecoded[0];
      expect(decoded.id, original.id);
      expect(decoded.date, original.date);
      expect(decoded.playerNames, original.playerNames);
      expect(decoded.playerColors, original.playerColors);
      expect(decoded.winnerName, original.winnerName);
      expect(decoded.totalTurns, original.totalTurns);
      expect(decoded.turns.length, original.turns.length);

      // Verify turn 0 details
      final t0 = decoded.turns[0];
      expect(t0.bred, {'rabbit': 1});
      expect(t0.trades.length, 1);
      expect(t0.trades[0].fromAnimal, 'rabbit');
      expect(t0.playerAnimalsAfter['Player 1']?['rabbit'], 4);

      // Verify turn 1 details
      final t1 = decoded.turns[1];
      expect(t1.foxAttack, true);
      expect(t1.wolfAttack, true);
      expect(t1.smallDogSacrificed, true);
      expect(t1.bigDogSacrificed, false);
      expect(t1.lostAnimals, {'rabbit': 3, 'lamb': 2});

      // Export/import single
      final exported = original.exportJson();
      final imported = GameReplay.importJson(exported);
      expect(imported.id, original.id);
      expect(imported.turns.length, 2);
    });
  });
}
