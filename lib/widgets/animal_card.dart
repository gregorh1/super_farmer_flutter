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
                style: TextStyle(
                  fontSize: size * 0.12,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
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
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF2E7D32)
                        : Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                    border: Theme.of(context).brightness == Brightness.dark
                        ? Border.all(
                            color: const Color(0xFF81C784),
                            width: 1,
                          )
                        : null,
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFFE0E0E0)
                          : Colors.white,
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
