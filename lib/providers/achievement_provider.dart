import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';

const _storageKey = 'achievements';

class AchievementNotifier extends StateNotifier<List<AchievementState>> {
  AchievementNotifier() : super(_defaultStates()) {
    _load();
  }

  static List<AchievementState> _defaultStates() =>
      AchievementId.values.map((id) => AchievementState(id: id)).toList();

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data != null && data.isNotEmpty) {
      try {
        final loaded = AchievementState.decode(data);
        // Merge loaded states with defaults to handle new achievements added later
        final map = {for (final s in loaded) s.id: s};
        state = AchievementId.values
            .map((id) => map[id] ?? AchievementState(id: id))
            .toList();
      } catch (_) {
        // Corrupted data — keep defaults
      }
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, AchievementState.encode(state));
  }

  AchievementState getState(AchievementId id) =>
      state.firstWhere((s) => s.id == id);

  bool isUnlocked(AchievementId id) => getState(id).unlocked;

  /// Unlock a single-step achievement. Returns true if newly unlocked.
  bool unlock(AchievementId id) {
    final current = getState(id);
    if (current.unlocked) return false;

    state = [
      for (final s in state)
        if (s.id == id)
          s.copyWith(unlocked: true, unlockedAt: DateTime.now())
        else
          s,
    ];
    _save();
    return true;
  }

  /// Increment progress for a multi-step achievement. Returns true if newly unlocked.
  bool incrementProgress(AchievementId id, {int amount = 1}) {
    final current = getState(id);
    if (current.unlocked) return false;

    final def = AchievementDefinition.getById(id);
    final target = def.targetProgress ?? 1;
    final newProgress = current.progress + amount;

    if (newProgress >= target) {
      state = [
        for (final s in state)
          if (s.id == id)
            s.copyWith(
              unlocked: true,
              unlockedAt: DateTime.now(),
              progress: newProgress,
            )
          else
            s,
      ];
      _save();
      return true;
    } else {
      state = [
        for (final s in state)
          if (s.id == id)
            s.copyWith(progress: newProgress)
          else
            s,
      ];
      _save();
      return false;
    }
  }

  /// Reset all achievements (for testing/debug).
  Future<void> clearAll() async {
    state = _defaultStates();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

final achievementProvider =
    StateNotifierProvider<AchievementNotifier, List<AchievementState>>(
  (ref) => AchievementNotifier(),
);
