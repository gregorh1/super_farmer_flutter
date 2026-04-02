import 'animal.dart';

class ExchangeRate {
  const ExchangeRate({
    required this.from,
    required this.fromCount,
    required this.to,
    required this.toCount,
  });

  final Animal from;
  final int fromCount;
  final Animal to;
  final int toCount;
}

class Exchange {
  Exchange._();

  static const List<ExchangeRate> rates = [
    ExchangeRate(from: Animal.rabbit, fromCount: 6, to: Animal.lamb, toCount: 1),
    ExchangeRate(from: Animal.lamb, fromCount: 2, to: Animal.pig, toCount: 1),
    ExchangeRate(from: Animal.pig, fromCount: 3, to: Animal.cow, toCount: 1),
    ExchangeRate(from: Animal.cow, fromCount: 2, to: Animal.horse, toCount: 1),
    // Dogs
    ExchangeRate(from: Animal.lamb, fromCount: 1, to: Animal.smallDog, toCount: 1),
    ExchangeRate(from: Animal.cow, fromCount: 1, to: Animal.bigDog, toCount: 1),
  ];

  /// Returns all valid trades a player can make (both directions for animal-animal,
  /// one direction for dog purchases).
  static List<ExchangeRate> availableTrades(
    Map<Animal, int> playerAnimals,
    Map<Animal, int> bankStock,
  ) {
    final trades = <ExchangeRate>[];
    for (final rate in rates) {
      // Forward: from -> to
      if ((playerAnimals[rate.from] ?? 0) >= rate.fromCount &&
          (bankStock[rate.to] ?? 0) >= rate.toCount) {
        trades.add(rate);
      }
      // Reverse: to -> from (not for dogs)
      if (rate.to != Animal.smallDog && rate.to != Animal.bigDog) {
        if ((playerAnimals[rate.to] ?? 0) >= rate.toCount &&
            (bankStock[rate.from] ?? 0) >= rate.fromCount) {
          trades.add(ExchangeRate(
            from: rate.to,
            fromCount: rate.toCount,
            to: rate.from,
            toCount: rate.fromCount,
          ));
        }
      }
    }
    return trades;
  }
}
