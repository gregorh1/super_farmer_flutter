import 'dart:convert';

import 'animal.dart';

/// A single completed game record for statistics tracking.
class GameRecord {
  const GameRecord({
    required this.date,
    required this.playerNames,
    required this.winnerName,
    required this.playerCount,
    required this.totalTurns,
    required this.lastAnimalAcquired,
    required this.winnerIsAi,
  });

  final DateTime date;
  final List<String> playerNames;
  final String winnerName;
  final int playerCount;
  final int totalTurns;
  final String lastAnimalAcquired; // Animal.name value
  final bool winnerIsAi;

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'playerNames': playerNames,
        'winnerName': winnerName,
        'playerCount': playerCount,
        'totalTurns': totalTurns,
        'lastAnimalAcquired': lastAnimalAcquired,
        'winnerIsAi': winnerIsAi,
      };

  factory GameRecord.fromJson(Map<String, dynamic> json) => GameRecord(
        date: DateTime.parse(json['date'] as String),
        playerNames: (json['playerNames'] as List).cast<String>(),
        winnerName: json['winnerName'] as String,
        playerCount: json['playerCount'] as int,
        totalTurns: json['totalTurns'] as int,
        lastAnimalAcquired: json['lastAnimalAcquired'] as String,
        winnerIsAi: json['winnerIsAi'] as bool? ?? false,
      );

  static String encode(List<GameRecord> records) =>
      jsonEncode(records.map((r) => r.toJson()).toList());

  static List<GameRecord> decode(String source) =>
      (jsonDecode(source) as List)
          .map((e) => GameRecord.fromJson(e as Map<String, dynamic>))
          .toList();
}

/// Computed statistics from a list of game records.
class GameStats {
  const GameStats({
    required this.gamesPlayed,
    required this.gamesWon,
    required this.gamesLost,
    required this.winRateByPlayerCount,
    required this.averageTurns,
    required this.fastestWin,
    required this.mostCommonLastAnimal,
    required this.leaderboard,
  });

  final int gamesPlayed;
  final int gamesWon;
  final int gamesLost;
  final Map<int, double> winRateByPlayerCount; // playerCount -> winRate
  final double averageTurns;
  final int? fastestWin; // in turns, null if no games
  final String? mostCommonLastAnimal; // Animal label, null if no games
  final List<LeaderboardEntry> leaderboard;

  factory GameStats.fromRecords(List<GameRecord> records) {
    if (records.isEmpty) {
      return const GameStats(
        gamesPlayed: 0,
        gamesWon: 0,
        gamesLost: 0,
        winRateByPlayerCount: {},
        averageTurns: 0,
        fastestWin: null,
        mostCommonLastAnimal: null,
        leaderboard: [],
      );
    }

    // Human wins (non-AI winners)
    final humanWins = records.where((r) => !r.winnerIsAi).length;
    final humanLosses = records.length - humanWins;

    // Win rate by player count (human wins only)
    final winRateByPlayerCount = <int, double>{};
    for (final pc in [2, 3, 4]) {
      final gamesAtCount = records.where((r) => r.playerCount == pc).toList();
      if (gamesAtCount.isNotEmpty) {
        final wins = gamesAtCount.where((r) => !r.winnerIsAi).length;
        winRateByPlayerCount[pc] = wins / gamesAtCount.length;
      }
    }

    // Average game length
    final totalTurns = records.fold<int>(0, (sum, r) => sum + r.totalTurns);
    final averageTurns = totalTurns / records.length;

    // Fastest win
    final fastestWin = records
        .map((r) => r.totalTurns)
        .reduce((a, b) => a < b ? a : b);

    // Most common last animal
    final animalCounts = <String, int>{};
    for (final r in records) {
      animalCounts[r.lastAnimalAcquired] =
          (animalCounts[r.lastAnimalAcquired] ?? 0) + 1;
    }
    String? mostCommonLastAnimal;
    int maxCount = 0;
    for (final entry in animalCounts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostCommonLastAnimal = entry.key;
      }
    }
    // Convert enum name to label
    if (mostCommonLastAnimal != null) {
      try {
        final animal = Animal.values.firstWhere(
          (a) => a.name == mostCommonLastAnimal,
        );
        mostCommonLastAnimal = animal.label;
      } catch (_) {
        // Keep raw name if enum not found
      }
    }

    // Leaderboard: count wins per unique player name
    final playerWins = <String, int>{};
    final playerGames = <String, int>{};
    for (final r in records) {
      for (final name in r.playerNames) {
        playerGames[name] = (playerGames[name] ?? 0) + 1;
      }
      playerWins[r.winnerName] = (playerWins[r.winnerName] ?? 0) + 1;
    }
    final leaderboard = playerGames.entries.map((e) {
      final wins = playerWins[e.key] ?? 0;
      return LeaderboardEntry(
        name: e.key,
        gamesPlayed: e.value,
        wins: wins,
        winRate: wins / e.value,
      );
    }).toList()
      ..sort((a, b) => b.wins.compareTo(a.wins));

    return GameStats(
      gamesPlayed: records.length,
      gamesWon: humanWins,
      gamesLost: humanLosses,
      winRateByPlayerCount: winRateByPlayerCount,
      averageTurns: averageTurns,
      fastestWin: fastestWin,
      mostCommonLastAnimal: mostCommonLastAnimal,
      leaderboard: leaderboard,
    );
  }
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.name,
    required this.gamesPlayed,
    required this.wins,
    required this.winRate,
  });

  final String name;
  final int gamesPlayed;
  final int wins;
  final double winRate;
}
