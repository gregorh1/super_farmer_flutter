import 'dart:math';

import 'ai_difficulty.dart';
import 'animal.dart';
import 'exchange.dart';
import '../providers/game_provider.dart';

/// Decides which trades an AI player should make after rolling dice.
class AiStrategy {
  const AiStrategy(this.difficulty);

  final AiDifficulty difficulty;

  /// Returns a list of trades the AI should execute, in order.
  List<ExchangeRate> decideTrades(PlayerHerd player, Map<Animal, int> bank,
      [List<PlayerHerd> opponents = const []]) {
    switch (difficulty) {
      case AiDifficulty.easy:
        return _easyTrades(player, bank);
      case AiDifficulty.medium:
        return _mediumTrades(player, bank);
      case AiDifficulty.hard:
        return _hardTrades(player, bank, opponents);
    }
  }

  // ---------------------------------------------------------------------------
  // Easy: never trades strategically (random chance to do nothing or buy a dog)
  // ---------------------------------------------------------------------------
  List<ExchangeRate> _easyTrades(PlayerHerd player, Map<Animal, int> bank) {
    // Easy AI occasionally buys a small dog if it has spare lambs (30% chance)
    final rng = Random();
    final trades = <ExchangeRate>[];
    if (rng.nextDouble() < 0.3 &&
        player.countOf(Animal.lamb) >= 2 &&
        (bank[Animal.smallDog] ?? 0) >= 1) {
      trades.add(const ExchangeRate(
        from: Animal.lamb,
        fromCount: 1,
        to: Animal.smallDog,
        toCount: 1,
      ));
    }
    return trades;
  }

  // ---------------------------------------------------------------------------
  // Medium: always trades up when possible, buys dogs when herds are valuable
  // ---------------------------------------------------------------------------
  List<ExchangeRate> _mediumTrades(PlayerHerd player, Map<Animal, int> bank) {
    final trades = <ExchangeRate>[];
    var animals = Map<Animal, int>.from(player.animals);
    var bankStock = Map<Animal, int>.from(bank);

    // Buy small dog when rabbits >= 6 and no small dog
    if (animals[Animal.smallDog] == 0 || (animals[Animal.smallDog] ?? 0) == 0) {
      if ((animals[Animal.lamb] ?? 0) >= 2 &&
          (bankStock[Animal.smallDog] ?? 0) >= 1) {
        trades.add(const ExchangeRate(
          from: Animal.lamb,
          fromCount: 1,
          to: Animal.smallDog,
          toCount: 1,
        ));
        animals[Animal.lamb] = (animals[Animal.lamb] ?? 0) - 1;
        bankStock[Animal.smallDog] = (bankStock[Animal.smallDog] ?? 0) - 1;
      }
    }

    // Buy big dog when we have cows to spare and don't have one
    if ((animals[Animal.bigDog] ?? 0) == 0 &&
        (animals[Animal.cow] ?? 0) >= 2 &&
        (bankStock[Animal.bigDog] ?? 0) >= 1) {
      trades.add(const ExchangeRate(
        from: Animal.cow,
        fromCount: 1,
        to: Animal.bigDog,
        toCount: 1,
      ));
      animals[Animal.cow] = (animals[Animal.cow] ?? 0) - 1;
      bankStock[Animal.bigDog] = (bankStock[Animal.bigDog] ?? 0) - 1;
    }

    // Trade up: convert excess animals to fill gaps
    _tradeUpToFillGaps(animals, bankStock, trades);

    return trades;
  }

  // ---------------------------------------------------------------------------
  // Hard: calculates optimal trading path, times dog purchases, considers
  // opponent progress
  // ---------------------------------------------------------------------------
  List<ExchangeRate> _hardTrades(
      PlayerHerd player, Map<Animal, int> bank, List<PlayerHerd> opponents) {
    final trades = <ExchangeRate>[];
    var animals = Map<Animal, int>.from(player.animals);
    var bankStock = Map<Animal, int>.from(bank);

    // Assess threat level — if any opponent is close to winning, prioritize
    final maxOpponentProgress = opponents.isEmpty
        ? 0.0
        : opponents
            .map((o) => _winProgress(o))
            .reduce((a, b) => a > b ? a : b);

    // Dog purchase logic — strategic timing
    // Buy small dog if we have rabbits worth protecting (>= 4)
    if ((animals[Animal.smallDog] ?? 0) == 0 &&
        (animals[Animal.rabbit] ?? 0) >= 4 &&
        (animals[Animal.lamb] ?? 0) >= 1 &&
        (bankStock[Animal.smallDog] ?? 0) >= 1) {
      trades.add(const ExchangeRate(
        from: Animal.lamb,
        fromCount: 1,
        to: Animal.smallDog,
        toCount: 1,
      ));
      animals[Animal.lamb] = (animals[Animal.lamb] ?? 0) - 1;
      bankStock[Animal.smallDog] = (bankStock[Animal.smallDog] ?? 0) - 1;
    }

    // Buy big dog when we have significant herd value or opponents are close
    final herdValue = _herdValue(animals);
    final needBigDog = (animals[Animal.bigDog] ?? 0) == 0 &&
        (bankStock[Animal.bigDog] ?? 0) >= 1 &&
        (animals[Animal.cow] ?? 0) >= 1;
    if (needBigDog && (herdValue >= 10 || maxOpponentProgress >= 0.6)) {
      trades.add(const ExchangeRate(
        from: Animal.cow,
        fromCount: 1,
        to: Animal.bigDog,
        toCount: 1,
      ));
      animals[Animal.cow] = (animals[Animal.cow] ?? 0) - 1;
      bankStock[Animal.bigDog] = (bankStock[Animal.bigDog] ?? 0) - 1;
    }

    // Optimal trading: find the cheapest path to fill missing animals
    _optimalTradeUp(animals, bankStock, trades);

    return trades;
  }

  /// Trade up excess lower animals to get missing higher animals.
  void _tradeUpToFillGaps(
      Map<Animal, int> animals, Map<Animal, int> bank, List<ExchangeRate> trades) {
    const chain = [Animal.rabbit, Animal.lamb, Animal.pig, Animal.cow, Animal.horse];
    const rates = [
      ExchangeRate(from: Animal.rabbit, fromCount: 6, to: Animal.lamb, toCount: 1),
      ExchangeRate(from: Animal.lamb, fromCount: 2, to: Animal.pig, toCount: 1),
      ExchangeRate(from: Animal.pig, fromCount: 3, to: Animal.cow, toCount: 1),
      ExchangeRate(from: Animal.cow, fromCount: 2, to: Animal.horse, toCount: 1),
    ];

    // Go through the chain and trade up when we have enough and need the next
    for (int i = 0; i < rates.length; i++) {
      final rate = rates[i];
      final higher = chain[i + 1];

      // Only trade up if we need the higher animal (count == 0) or have excess
      while ((animals[rate.from] ?? 0) >= rate.fromCount &&
          (bank[rate.to] ?? 0) >= rate.toCount) {
        // Don't trade if we'd lose our only one of the lower animal (need 1 to win)
        final afterTrade = (animals[rate.from] ?? 0) - rate.fromCount;
        if (afterTrade < 1 && (animals[higher] ?? 0) >= 1) break;
        if ((animals[higher] ?? 0) >= 1 && afterTrade < 1) break;

        trades.add(rate);
        animals[rate.from] = (animals[rate.from] ?? 0) - rate.fromCount;
        animals[rate.to] = (animals[rate.to] ?? 0) + rate.toCount;
        bank[rate.from] = (bank[rate.from] ?? 0) + rate.fromCount;
        bank[rate.to] = (bank[rate.to] ?? 0) - rate.toCount;

        // Stop after one trade up per level for medium (avoid over-trading)
        break;
      }
    }
  }

  /// Hard mode optimal trading — considers what's missing and trades aggressively.
  void _optimalTradeUp(
      Map<Animal, int> animals, Map<Animal, int> bank, List<ExchangeRate> trades) {
    const chain = [Animal.rabbit, Animal.lamb, Animal.pig, Animal.cow, Animal.horse];
    const rates = [
      ExchangeRate(from: Animal.rabbit, fromCount: 6, to: Animal.lamb, toCount: 1),
      ExchangeRate(from: Animal.lamb, fromCount: 2, to: Animal.pig, toCount: 1),
      ExchangeRate(from: Animal.pig, fromCount: 3, to: Animal.cow, toCount: 1),
      ExchangeRate(from: Animal.cow, fromCount: 2, to: Animal.horse, toCount: 1),
    ];

    // Find the highest missing animal and work towards it
    int? highestMissing;
    for (int i = chain.length - 1; i >= 0; i--) {
      if ((animals[chain[i]] ?? 0) == 0) {
        highestMissing = i;
        break;
      }
    }
    if (highestMissing == null) return; // Already have everything

    // Trade up aggressively towards the missing animal
    for (int i = 0; i < rates.length && i < highestMissing; i++) {
      final rate = rates[i];

      // Keep trading up as long as we can and maintain at least 1 of the source
      while ((animals[rate.from] ?? 0) >= rate.fromCount &&
          (bank[rate.to] ?? 0) >= rate.toCount) {
        // Preserve at least 1 of each animal we already have for winning
        final afterTrade = (animals[rate.from] ?? 0) - rate.fromCount;
        if (afterTrade < 1 && i > 0) break; // Keep 1 of non-rabbits

        trades.add(rate);
        animals[rate.from] = (animals[rate.from] ?? 0) - rate.fromCount;
        animals[rate.to] = (animals[rate.to] ?? 0) + rate.toCount;
        bank[rate.from] = (bank[rate.from] ?? 0) + rate.fromCount;
        bank[rate.to] = (bank[rate.to] ?? 0) - rate.toCount;
      }
    }
  }

  double _winProgress(PlayerHerd player) {
    int collected = 0;
    const farm = [Animal.rabbit, Animal.lamb, Animal.pig, Animal.cow, Animal.horse];
    for (final a in farm) {
      if (player.countOf(a) >= 1) collected++;
    }
    return collected / 5.0;
  }

  int _herdValue(Map<Animal, int> animals) {
    // Approximate value in rabbit-equivalents
    int value = 0;
    value += animals[Animal.rabbit] ?? 0;
    value += (animals[Animal.lamb] ?? 0) * 6;
    value += (animals[Animal.pig] ?? 0) * 12;
    value += (animals[Animal.cow] ?? 0) * 36;
    value += (animals[Animal.horse] ?? 0) * 72;
    return value;
  }
}
