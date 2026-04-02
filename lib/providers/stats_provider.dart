import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_record.dart';

const _storageKey = 'game_records';

class StatsNotifier extends StateNotifier<List<GameRecord>> {
  StatsNotifier() : super(const []) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data != null && data.isNotEmpty) {
      state = GameRecord.decode(data);
    }
  }

  Future<void> addRecord(GameRecord record) async {
    state = [...state, record];
    await _save();
  }

  Future<void> clearAll() async {
    state = const [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, GameRecord.encode(state));
  }
}

final statsProvider =
    StateNotifierProvider<StatsNotifier, List<GameRecord>>(
  (ref) => StatsNotifier(),
);

final gameStatsProvider = Provider<GameStats>((ref) {
  final records = ref.watch(statsProvider);
  return GameStats.fromRecords(records);
});
