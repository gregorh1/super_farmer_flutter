import 'dart:convert';

import 'animal.dart';
import 'dice.dart';

/// Records a single trade made during a turn.
class TradeRecord {
  const TradeRecord({
    required this.fromAnimal,
    required this.fromCount,
    required this.toAnimal,
    required this.toCount,
  });

  final String fromAnimal; // Animal.name
  final int fromCount;
  final String toAnimal; // Animal.name
  final int toCount;

  Map<String, dynamic> toJson() => {
        'fromAnimal': fromAnimal,
        'fromCount': fromCount,
        'toAnimal': toAnimal,
        'toCount': toCount,
      };

  factory TradeRecord.fromJson(Map<String, dynamic> json) => TradeRecord(
        fromAnimal: json['fromAnimal'] as String,
        fromCount: json['fromCount'] as int,
        toAnimal: json['toAnimal'] as String,
        toCount: json['toCount'] as int,
      );
}

/// Records everything that happened in a single turn.
class TurnRecord {
  const TurnRecord({
    required this.turnNumber,
    required this.playerIndex,
    required this.playerName,
    required this.greenDie,
    required this.redDie,
    this.bred = const {},
    this.lostAnimals = const {},
    this.foxAttack = false,
    this.wolfAttack = false,
    this.smallDogSacrificed = false,
    this.bigDogSacrificed = false,
    this.trades = const [],
    required this.playerAnimalsAfter,
  });

  final int turnNumber;
  final int playerIndex;
  final String playerName;
  final String greenDie; // DiceFace.name
  final String redDie; // DiceFace.name
  final Map<String, int> bred; // Animal.name -> count gained
  final Map<String, int> lostAnimals; // Animal.name -> count lost
  final bool foxAttack;
  final bool wolfAttack;
  final bool smallDogSacrificed;
  final bool bigDogSacrificed;
  final List<TradeRecord> trades;
  final Map<String, Map<String, int>> playerAnimalsAfter; // playerName -> {animal.name -> count}

  Map<String, dynamic> toJson() => {
        'turnNumber': turnNumber,
        'playerIndex': playerIndex,
        'playerName': playerName,
        'greenDie': greenDie,
        'redDie': redDie,
        'bred': bred,
        'lostAnimals': lostAnimals,
        'foxAttack': foxAttack,
        'wolfAttack': wolfAttack,
        'smallDogSacrificed': smallDogSacrificed,
        'bigDogSacrificed': bigDogSacrificed,
        'trades': trades.map((t) => t.toJson()).toList(),
        'playerAnimalsAfter': playerAnimalsAfter,
      };

  factory TurnRecord.fromJson(Map<String, dynamic> json) => TurnRecord(
        turnNumber: json['turnNumber'] as int,
        playerIndex: json['playerIndex'] as int,
        playerName: json['playerName'] as String,
        greenDie: json['greenDie'] as String,
        redDie: json['redDie'] as String,
        bred: (json['bred'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v as int)) ??
            const {},
        lostAnimals: (json['lostAnimals'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v as int)) ??
            const {},
        foxAttack: json['foxAttack'] as bool? ?? false,
        wolfAttack: json['wolfAttack'] as bool? ?? false,
        smallDogSacrificed: json['smallDogSacrificed'] as bool? ?? false,
        bigDogSacrificed: json['bigDogSacrificed'] as bool? ?? false,
        trades: (json['trades'] as List?)
                ?.map(
                    (e) => TradeRecord.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        playerAnimalsAfter:
            (json['playerAnimalsAfter'] as Map<String, dynamic>?)?.map(
                  (k, v) => MapEntry(
                    k,
                    (v as Map<String, dynamic>)
                        .map((ak, av) => MapEntry(ak, av as int)),
                  ),
                ) ??
                const {},
      );

  /// Helper to get typed DiceFace values.
  DiceFace get greenDiceFace =>
      DiceFace.values.firstWhere((f) => f.name == greenDie);
  DiceFace get redDiceFace =>
      DiceFace.values.firstWhere((f) => f.name == redDie);

  /// Helper to get typed bred animals map.
  Map<Animal, int> get bredAnimals => bred.map(
        (k, v) => MapEntry(Animal.values.firstWhere((a) => a.name == k), v),
      );

  /// Helper to get typed lost animals map.
  Map<Animal, int> get lostAnimalsTyped => lostAnimals.map(
        (k, v) => MapEntry(Animal.values.firstWhere((a) => a.name == k), v),
      );
}

/// A complete game replay containing metadata and all turns.
class GameReplay {
  const GameReplay({
    required this.id,
    required this.date,
    required this.playerNames,
    required this.playerColors,
    required this.winnerName,
    required this.totalTurns,
    required this.turns,
  });

  final String id;
  final DateTime date;
  final List<String> playerNames;
  final List<int> playerColors; // Color values as ints
  final String winnerName;
  final int totalTurns;
  final List<TurnRecord> turns;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'playerNames': playerNames,
        'playerColors': playerColors,
        'winnerName': winnerName,
        'totalTurns': totalTurns,
        'turns': turns.map((t) => t.toJson()).toList(),
      };

  factory GameReplay.fromJson(Map<String, dynamic> json) => GameReplay(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        playerNames: (json['playerNames'] as List).cast<String>(),
        playerColors: (json['playerColors'] as List).cast<int>(),
        winnerName: json['winnerName'] as String,
        totalTurns: json['totalTurns'] as int,
        turns: (json['turns'] as List)
            .map((e) => TurnRecord.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  static String encode(List<GameReplay> replays) =>
      jsonEncode(replays.map((r) => r.toJson()).toList());

  static List<GameReplay> decode(String source) => (jsonDecode(source) as List)
      .map((e) => GameReplay.fromJson(e as Map<String, dynamic>))
      .toList();

  /// Export a single replay as JSON string for sharing.
  String exportJson() => jsonEncode(toJson());

  /// Import a single replay from JSON string.
  static GameReplay importJson(String source) =>
      GameReplay.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
