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

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                width: size * 0.65,
                height: size * 0.65,
                child: SvgPicture.asset(
                  animal.assetPath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Text(
                animal.label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: size * 0.12),
              ),
            ),
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
