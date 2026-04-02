import 'package:flutter/material.dart';

enum Animal {
  rabbit('Rabbit', Colors.grey, 'assets/images/rabbit.svg', 60),
  lamb('Lamb', Colors.white, 'assets/images/lamb.svg', 24),
  pig('Pig', Colors.pink, 'assets/images/pig.svg', 20),
  cow('Cow', Colors.brown, 'assets/images/cow.svg', 12),
  horse('Horse', Colors.amber, 'assets/images/horse.svg', 6),
  smallDog('Small Dog', Colors.orange, 'assets/images/small_dog.svg', 4),
  bigDog('Big Dog', Colors.indigo, 'assets/images/big_dog.svg', 2);

  const Animal(this.label, this.color, this.assetPath, this.totalInGame);

  final String label;
  final Color color;
  final String assetPath;
  final int totalInGame;
}

enum DiceSymbol {
  rabbit('Rabbit', Colors.grey),
  lamb('Lamb', Colors.white),
  pig('Pig', Colors.pink),
  cow('Cow', Colors.brown),
  horse('Horse', Colors.amber),
  fox('Fox', Colors.red),
  wolf('Wolf', Colors.blueGrey);

  const DiceSymbol(this.label, this.color);

  final String label;
  final Color color;
}
