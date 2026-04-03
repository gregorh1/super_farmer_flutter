import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_difficulty.dart';

/// Language preference for the app.
enum LanguagePreference { system, polish, english }

extension LanguagePreferenceExtension on LanguagePreference {
  Locale? get locale {
    switch (this) {
      case LanguagePreference.system:
        return null; // Use system locale
      case LanguagePreference.polish:
        return const Locale('pl');
      case LanguagePreference.english:
        return const Locale('en');
    }
  }

  IconData get icon {
    switch (this) {
      case LanguagePreference.system:
        return Icons.language;
      case LanguagePreference.polish:
        return Icons.language;
      case LanguagePreference.english:
        return Icons.language;
    }
  }
}

const _languagePreferenceKey = 'language_preference';

class LanguageNotifier extends StateNotifier<LanguagePreference> {
  LanguageNotifier() : super(LanguagePreference.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_languagePreferenceKey);
    if (stored != null && mounted) {
      for (final pref in LanguagePreference.values) {
        if (pref.name == stored) {
          state = pref;
          return;
        }
      }
    }
  }

  Future<void> setLanguage(LanguagePreference preference) async {
    state = preference;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languagePreferenceKey, preference.name);
  }
}

final languageProvider =
    StateNotifierProvider<LanguageNotifier, LanguagePreference>(
  (ref) => LanguageNotifier(),
);

/// Theme preference that maps to [ThemeMode].
enum ThemePreference { system, light, dark }

extension ThemePreferenceExtension on ThemePreference {
  String get label {
    switch (this) {
      case ThemePreference.system:
        return 'System';
      case ThemePreference.light:
        return 'Light';
      case ThemePreference.dark:
        return 'Dark';
    }
  }

  IconData get icon {
    switch (this) {
      case ThemePreference.system:
        return Icons.brightness_auto;
      case ThemePreference.light:
        return Icons.light_mode;
      case ThemePreference.dark:
        return Icons.dark_mode;
    }
  }

  ThemeMode get themeMode {
    switch (this) {
      case ThemePreference.system:
        return ThemeMode.system;
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
    }
  }
}

const _themePreferenceKey = 'theme_preference';

class ThemeNotifier extends StateNotifier<ThemePreference> {
  ThemeNotifier() : super(ThemePreference.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_themePreferenceKey);
    if (stored != null && mounted) {
      for (final pref in ThemePreference.values) {
        if (pref.name == stored) {
          state = pref;
          return;
        }
      }
    }
  }

  Future<void> setTheme(ThemePreference preference) async {
    state = preference;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, preference.name);
  }
}

final themeProvider =
    StateNotifierProvider<ThemeNotifier, ThemePreference>(
  (ref) => ThemeNotifier(),
);

/// Available player colors for selection.
class PlayerColor {
  const PlayerColor({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  bool operator ==(Object other) =>
      other is PlayerColor && other.color.value == color.value;

  @override
  int get hashCode => color.value.hashCode;
}

const availablePlayerColors = [
  PlayerColor(name: 'Green', color: Color(0xFF2E7D32)),
  PlayerColor(name: 'Blue', color: Color(0xFF1565C0)),
  PlayerColor(name: 'Orange', color: Color(0xFFE65100)),
  PlayerColor(name: 'Purple', color: Color(0xFF6A1B9A)),
  PlayerColor(name: 'Red', color: Color(0xFFC62828)),
  PlayerColor(name: 'Teal', color: Color(0xFF00695C)),
];

/// Default color assignments for players 0-3.
const defaultPlayerColorIndices = [0, 1, 2, 3];

enum AnimationSpeed { slow, normal, fast }

extension AnimationSpeedExtension on AnimationSpeed {
  String get label {
    switch (this) {
      case AnimationSpeed.slow:
        return 'Slow';
      case AnimationSpeed.normal:
        return 'Normal';
      case AnimationSpeed.fast:
        return 'Fast';
    }
  }

  double get multiplier {
    switch (this) {
      case AnimationSpeed.slow:
        return 1.5;
      case AnimationSpeed.normal:
        return 1.0;
      case AnimationSpeed.fast:
        return 0.5;
    }
  }
}

class GameSettings {
  const GameSettings({
    this.soundEnabled = true,
    this.volume = 0.7,
    this.animationSpeed = AnimationSpeed.normal,
    this.confirmEndTurn = false,
  });

  final bool soundEnabled;
  final double volume;
  final AnimationSpeed animationSpeed;
  final bool confirmEndTurn;

  GameSettings copyWith({
    bool? soundEnabled,
    double? volume,
    AnimationSpeed? animationSpeed,
    bool? confirmEndTurn,
  }) {
    return GameSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      volume: volume ?? this.volume,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      confirmEndTurn: confirmEndTurn ?? this.confirmEndTurn,
    );
  }
}

class GameSettingsNotifier extends StateNotifier<GameSettings> {
  GameSettingsNotifier() : super(const GameSettings());

  void toggleSound() {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
  }

  void setVolume(double volume) {
    state = state.copyWith(volume: volume.clamp(0.0, 1.0));
  }

  void setAnimationSpeed(AnimationSpeed speed) {
    state = state.copyWith(animationSpeed: speed);
  }

  void toggleConfirmEndTurn() {
    state = state.copyWith(confirmEndTurn: !state.confirmEndTurn);
  }
}

final gameSettingsProvider =
    StateNotifierProvider<GameSettingsNotifier, GameSettings>(
  (ref) => GameSettingsNotifier(),
);

/// Tracks player setup configuration before game starts.
class PlayerSetup {
  const PlayerSetup({
    this.playerCount = 4,
    this.playerNames = const ['', '', '', ''],
    this.playerColorIndices = const [0, 1, 2, 3],
    this.isAi = const [false, false, false, false],
    this.aiDifficulties = const [
      AiDifficulty.medium,
      AiDifficulty.medium,
      AiDifficulty.medium,
      AiDifficulty.medium,
    ],
  });

  final int playerCount;
  final List<String> playerNames;
  final List<int> playerColorIndices;
  final List<bool> isAi;
  final List<AiDifficulty> aiDifficulties;

  PlayerSetup copyWith({
    int? playerCount,
    List<String>? playerNames,
    List<int>? playerColorIndices,
    List<bool>? isAi,
    List<AiDifficulty>? aiDifficulties,
  }) {
    return PlayerSetup(
      playerCount: playerCount ?? this.playerCount,
      playerNames: playerNames ?? this.playerNames,
      playerColorIndices: playerColorIndices ?? this.playerColorIndices,
      isAi: isAi ?? this.isAi,
      aiDifficulties: aiDifficulties ?? this.aiDifficulties,
    );
  }

  String displayName(int index) {
    if (index < playerNames.length && playerNames[index].isNotEmpty) {
      return playerNames[index];
    }
    if (index < isAi.length && isAi[index]) {
      final diff = index < aiDifficulties.length
          ? aiDifficulties[index]
          : AiDifficulty.medium;
      return 'AI ${index + 1} (${diff.label})';
    }
    return 'Player ${index + 1}';
  }

  Color playerColor(int index) {
    if (index < playerColorIndices.length) {
      return availablePlayerColors[playerColorIndices[index]].color;
    }
    return availablePlayerColors[index % availablePlayerColors.length].color;
  }
}

class PlayerSetupNotifier extends StateNotifier<PlayerSetup> {
  PlayerSetupNotifier() : super(const PlayerSetup());

  void setPlayerCount(int count) {
    state = state.copyWith(playerCount: count);
  }

  void setPlayerName(int index, String name) {
    final names = List<String>.from(state.playerNames);
    while (names.length <= index) {
      names.add('');
    }
    names[index] = name;
    state = state.copyWith(playerNames: names);
  }

  void setPlayerColor(int playerIndex, int colorIndex) {
    final indices = List<int>.from(state.playerColorIndices);
    // If another player already has this color, swap
    final existingPlayer = indices.indexOf(colorIndex);
    if (existingPlayer != -1 && existingPlayer != playerIndex) {
      indices[existingPlayer] = indices[playerIndex];
    }
    indices[playerIndex] = colorIndex;
    state = state.copyWith(playerColorIndices: indices);
  }

  void setIsAi(int index, bool value) {
    final list = List<bool>.from(state.isAi);
    while (list.length <= index) {
      list.add(false);
    }
    list[index] = value;
    state = state.copyWith(isAi: list);
  }

  void setAiDifficulty(int index, AiDifficulty difficulty) {
    final list = List<AiDifficulty>.from(state.aiDifficulties);
    while (list.length <= index) {
      list.add(AiDifficulty.medium);
    }
    list[index] = difficulty;
    state = state.copyWith(aiDifficulties: list);
  }

  void reset() {
    state = const PlayerSetup();
  }
}

final playerSetupProvider =
    StateNotifierProvider<PlayerSetupNotifier, PlayerSetup>(
  (ref) => PlayerSetupNotifier(),
);
