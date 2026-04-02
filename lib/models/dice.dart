import 'dart:math';

import 'animal.dart';

enum DiceFace {
  rabbit,
  lamb,
  pig,
  cow,
  horse,
  fox,
  wolf;

  Animal? toAnimal() => switch (this) {
        DiceFace.rabbit => Animal.rabbit,
        DiceFace.lamb => Animal.lamb,
        DiceFace.pig => Animal.pig,
        DiceFace.cow => Animal.cow,
        DiceFace.horse => Animal.horse,
        DiceFace.fox => null,
        DiceFace.wolf => null,
      };
}

enum Dice {
  green([
    DiceFace.rabbit,
    DiceFace.rabbit,
    DiceFace.rabbit,
    DiceFace.rabbit,
    DiceFace.rabbit,
    DiceFace.rabbit,
    DiceFace.lamb,
    DiceFace.lamb,
    DiceFace.lamb,
    DiceFace.pig,
    DiceFace.cow,
    DiceFace.wolf,
  ]),
  red([
    DiceFace.rabbit,
    DiceFace.rabbit,
    DiceFace.rabbit,
    DiceFace.rabbit,
    DiceFace.rabbit,
    DiceFace.rabbit,
    DiceFace.lamb,
    DiceFace.lamb,
    DiceFace.pig,
    DiceFace.pig,
    DiceFace.horse,
    DiceFace.fox,
  ]);

  const Dice(this.faces);

  final List<DiceFace> faces;

  DiceFace roll([Random? random]) {
    final rng = random ?? Random();
    return faces[rng.nextInt(faces.length)];
  }
}

class DiceRollResult {
  const DiceRollResult({required this.green, required this.red});

  final DiceFace green;
  final DiceFace red;

  Map<Animal, int> get rolledAnimals {
    final counts = <Animal, int>{};
    final greenAnimal = green.toAnimal();
    final redAnimal = red.toAnimal();
    if (greenAnimal != null) {
      counts[greenAnimal] = (counts[greenAnimal] ?? 0) + 1;
    }
    if (redAnimal != null) {
      counts[redAnimal] = (counts[redAnimal] ?? 0) + 1;
    }
    return counts;
  }

  bool get hasFox => red == DiceFace.fox;
  bool get hasWolf => green == DiceFace.wolf;

  static DiceRollResult roll([Random? random]) {
    final rng = random ?? Random();
    return DiceRollResult(
      green: Dice.green.roll(rng),
      red: Dice.red.roll(rng),
    );
  }
}
