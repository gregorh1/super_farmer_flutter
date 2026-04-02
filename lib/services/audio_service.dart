import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/animal.dart';
import '../providers/settings_provider.dart';

enum GameSound {
  diceRoll('audio/dice_roll.wav'),
  rabbit('audio/rabbit.wav'),
  lamb('audio/lamb.wav'),
  pig('audio/pig.wav'),
  cow('audio/cow.wav'),
  horse('audio/horse.wav'),
  wolfHowl('audio/wolf.wav'),
  foxBark('audio/fox.wav'),
  dogBark('audio/dog_bark.wav'),
  victory('audio/victory.wav'),
  tap('audio/tap.wav');

  const GameSound(this.assetPath);
  final String assetPath;

  static GameSound? forAnimal(Animal animal) => switch (animal) {
        Animal.rabbit => GameSound.rabbit,
        Animal.lamb => GameSound.lamb,
        Animal.pig => GameSound.pig,
        Animal.cow => GameSound.cow,
        Animal.horse => GameSound.horse,
        _ => null,
      };
}

class AudioService {
  AudioService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;
  double _volume = 0.7;
  bool _muted = false;

  double get volume => _volume;
  bool get isMuted => _muted;

  void setVolume(double vol) {
    _volume = vol.clamp(0.0, 1.0);
  }

  void setMuted(bool muted) {
    _muted = muted;
    if (muted) {
      _player.stop();
    }
  }

  Future<void> play(GameSound sound) async {
    if (_muted || _volume <= 0) return;
    try {
      await _player.stop();
      await _player.setVolume(_volume);
      await _player.play(AssetSource(sound.assetPath));
    } catch (_) {
      // Silently ignore audio errors — sound is non-critical
    }
  }

  Future<void> playAnimalSound(Animal animal) async {
    final sound = GameSound.forAnimal(animal);
    if (sound != null) await play(sound);
  }

  /// Trigger haptic feedback for impactful events.
  static void hapticLight() {
    HapticFeedback.lightImpact();
  }

  static void hapticHeavy() {
    HapticFeedback.heavyImpact();
  }

  void dispose() {
    _player.dispose();
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();

  // Sync with settings
  ref.listen<GameSettings>(gameSettingsProvider, (prev, next) {
    service.setMuted(!next.soundEnabled);
    service.setVolume(next.volume);
  });

  // Initialize from current settings
  final settings = ref.read(gameSettingsProvider);
  service.setMuted(!settings.soundEnabled);
  service.setVolume(settings.volume);

  ref.onDispose(() => service.dispose());
  return service;
});
