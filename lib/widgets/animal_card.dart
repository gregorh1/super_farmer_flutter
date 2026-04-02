import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/animal.dart';

class AnimalCard extends StatelessWidget {
  const AnimalCard({
    super.key,
    required this.animal,
    this.count,
    this.size = 80,
  });

  final Animal animal;
  final int? count;
  final double size;

  static const _animalEmoji = {
    Animal.rabbit: '🐇',
    Animal.lamb: '🐑',
    Animal.pig: '🐷',
    Animal.cow: '🐄',
    Animal.horse: '🐴',
    Animal.smallDog: '🐕',
    Animal.bigDog: '🦮',
  };

  static const _animalBgColor = {
    Animal.rabbit: Color(0xFFF5F5F5),
    Animal.lamb: Color(0xFFFFF8E1),
    Animal.pig: Color(0xFFFCE4EC),
    Animal.cow: Color(0xFFEFEBE9),
    Animal.horse: Color(0xFFFFF3E0),
    Animal.smallDog: Color(0xFFFFF3E0),
    Animal.bigDog: Color(0xFFE8EAF6),
  };

  @override
  Widget build(BuildContext context) {
    final bgColor = _animalBgColor[animal] ?? Colors.grey.shade100;

    return Card(
      color: bgColor,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            // Faint emoji background accent
            Positioned(
              right: -2,
              bottom: -2,
              child: Text(
                _animalEmoji[animal] ?? '',
                style: TextStyle(
                  fontSize: size * 0.32,
                  color: Colors.black.withValues(alpha: 0.07),
                ),
              ),
            ),
            // SVG icon
            Center(
              child: SizedBox(
                width: size * 0.55,
                height: size * 0.55,
                child: SvgPicture.asset(
                  animal.assetPath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Label
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Text(
                animal.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: size * 0.12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Count badge
            if (count != null)
              Positioned(
                top: 2,
                right: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
