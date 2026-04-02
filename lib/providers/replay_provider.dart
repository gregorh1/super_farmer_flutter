import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/animal.dart';
import '../models/exchange.dart';
import '../models/game_replay.dart';
import 'game_provider.dart';

const _storageKey = 'game_replays';
const _maxReplays = 50;

// ---------------------------------------------------------------------------
// Replay storage provider — persists replays to SharedPreferences
// ---------------------------------------------------------------------------

class ReplayStorageNotifier extends StateNotifier<List<GameReplay>> {
  ReplayStorageNotifier() : super(const []) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data != null && data.isNotEmpty) {
      try {
        state = GameReplay.decode(data);
      } catch (_) {
        // Corrupted data — start fresh
        state = const [];
      }
    }
  }

  Future<void> addReplay(GameReplay replay) async {
    // Keep most recent replays, evict oldest if over limit
    final updated = [...state, replay];
    if (updated.length > _maxReplays) {
      updated.removeRange(0, updated.length - _maxReplays);
    }
    state = updated;
    await _save();
  }

  Future<void> deleteReplay(String id) async {
    state = state.where((r) => r.id != id).toList();
    await _save();
  }

  Future<void> importReplay(GameReplay replay) async {
    // Avoid duplicates by id
    if (state.any((r) => r.id == replay.id)) return;
    await addReplay(replay);
  }

  Future<void> clearAll() async {
    state = const [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, GameReplay.encode(state));
  }
}

final replayStorageProvider =
    StateNotifierProvider<ReplayStorageNotifier, List<GameReplay>>(
  (ref) => ReplayStorageNotifier(),
);

// ---------------------------------------------------------------------------
// Replay recorder — collects turn data during active gameplay
// ---------------------------------------------------------------------------

class ReplayRecorder {
  final List<TurnRecord> _turns = [];
  final List<TradeRecord> _currentTurnTrades = [];
  List<String> _playerNames = [];
  List<int> _playerColors = [];
  int _currentTurnNumber = 0;
  int _currentPlayerIndex = 0;
  String _currentPlayerName = '';
  String _greenDie = '';
  String _redDie = '';
  Map<String, int> _bred = {};
  Map<String, int> _lostAnimals = {};
  bool _foxAttack = false;
  bool _wolfAttack = false;
  bool _smallDogSacrificed = false;
  bool _bigDogSacrificed = false;
  bool _isRecording = false;

  bool get isRecording => _isRecording;
  List<TurnRecord> get turns => List.unmodifiable(_turns);

  void startRecording(List<String> playerNames, List<Color> playerColors) {
    _turns.clear();
    _currentTurnTrades.clear();
    _playerNames = playerNames;
    _playerColors = playerColors.map((c) => c.toARGB32()).toList();
    _isRecording = true;
  }

  void recordDiceRoll(TurnEvent event, int turnNumber, int playerIndex,
      String playerName) {
    if (!_isRecording) return;
    _currentTurnNumber = turnNumber;
    _currentPlayerIndex = playerIndex;
    _currentPlayerName = playerName;
    _greenDie = event.roll.green.name;
    _redDie = event.roll.red.name;
    _bred = event.bred.map((k, v) => MapEntry(k.name, v));
    _lostAnimals = event.lostAnimals.map((k, v) => MapEntry(k.name, v));
    _foxAttack = event.foxAttack;
    _wolfAttack = event.wolfAttack;
    _smallDogSacrificed = event.smallDogSacrificed;
    _bigDogSacrificed = event.bigDogSacrificed;
    _currentTurnTrades.clear();
  }

  void recordTrade(ExchangeRate rate) {
    if (!_isRecording) return;
    _currentTurnTrades.add(TradeRecord(
      fromAnimal: rate.from.name,
      fromCount: rate.fromCount,
      toAnimal: rate.to.name,
      toCount: rate.toCount,
    ));
  }

  void finalizeTurn(GameState gameState) {
    if (!_isRecording) return;
    final playerAnimalsAfter = <String, Map<String, int>>{};
    for (final player in gameState.players) {
      playerAnimalsAfter[player.name] = player.animals.map(
        (k, v) => MapEntry(k.name, v),
      );
    }
    _turns.add(TurnRecord(
      turnNumber: _currentTurnNumber,
      playerIndex: _currentPlayerIndex,
      playerName: _currentPlayerName,
      greenDie: _greenDie,
      redDie: _redDie,
      bred: Map.from(_bred),
      lostAnimals: Map.from(_lostAnimals),
      foxAttack: _foxAttack,
      wolfAttack: _wolfAttack,
      smallDogSacrificed: _smallDogSacrificed,
      bigDogSacrificed: _bigDogSacrificed,
      trades: List.from(_currentTurnTrades),
      playerAnimalsAfter: playerAnimalsAfter,
    ));
    _currentTurnTrades.clear();
  }

  GameReplay? buildReplay(String winnerName, int totalTurns) {
    if (!_isRecording || _turns.isEmpty) return null;
    _isRecording = false;
    return GameReplay(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      playerNames: List.from(_playerNames),
      playerColors: List.from(_playerColors),
      winnerName: winnerName,
      totalTurns: totalTurns,
      turns: List.from(_turns),
    );
  }

  void stopRecording() {
    _isRecording = false;
    _turns.clear();
    _currentTurnTrades.clear();
  }
}

/// Global recorder instance — used by the game screen.
final replayRecorderProvider = Provider<ReplayRecorder>((ref) {
  return ReplayRecorder();
});

// ---------------------------------------------------------------------------
// Replay playback state — used by the replay viewer
// ---------------------------------------------------------------------------

class ReplayPlaybackState {
  const ReplayPlaybackState({
    this.replay,
    this.currentTurnIndex = 0,
    this.isPlaying = false,
    this.playbackSpeed = 1.0,
  });

  final GameReplay? replay;
  final int currentTurnIndex;
  final bool isPlaying;
  final double playbackSpeed;

  TurnRecord? get currentTurn =>
      replay != null && currentTurnIndex < replay!.turns.length
          ? replay!.turns[currentTurnIndex]
          : null;

  bool get isAtStart => currentTurnIndex == 0;
  bool get isAtEnd =>
      replay == null || currentTurnIndex >= replay!.turns.length - 1;

  int get totalTurns => replay?.turns.length ?? 0;

  ReplayPlaybackState copyWith({
    GameReplay? replay,
    bool clearReplay = false,
    int? currentTurnIndex,
    bool? isPlaying,
    double? playbackSpeed,
  }) {
    return ReplayPlaybackState(
      replay: clearReplay ? null : (replay ?? this.replay),
      currentTurnIndex: currentTurnIndex ?? this.currentTurnIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
    );
  }
}

class ReplayPlaybackNotifier extends StateNotifier<ReplayPlaybackState> {
  ReplayPlaybackNotifier() : super(const ReplayPlaybackState());

  void loadReplay(GameReplay replay) {
    state = ReplayPlaybackState(replay: replay);
  }

  void stepForward() {
    if (state.isAtEnd) {
      state = state.copyWith(isPlaying: false);
      return;
    }
    state = state.copyWith(currentTurnIndex: state.currentTurnIndex + 1);
  }

  void stepBackward() {
    if (state.isAtStart) return;
    state = state.copyWith(currentTurnIndex: state.currentTurnIndex - 1);
  }

  void jumpToTurn(int index) {
    if (state.replay == null) return;
    final clamped = index.clamp(0, state.replay!.turns.length - 1);
    state = state.copyWith(currentTurnIndex: clamped);
  }

  void play() {
    if (state.isAtEnd) return;
    state = state.copyWith(isPlaying: true);
  }

  void pause() {
    state = state.copyWith(isPlaying: false);
  }

  void togglePlayPause() {
    if (state.isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void setSpeed(double speed) {
    state = state.copyWith(playbackSpeed: speed);
  }

  void reset() {
    state = const ReplayPlaybackState();
  }
}

final replayPlaybackProvider =
    StateNotifierProvider<ReplayPlaybackNotifier, ReplayPlaybackState>(
  (ref) => ReplayPlaybackNotifier(),
);
