import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../providers/game_provider.dart';

class PlayerArea extends StatelessWidget {
  const PlayerArea({
    super.key,
    required this.player,
    required this.playerIndex,
    required this.isCurrentPlayer,
    this.onTap,
  });

  final PlayerHerd player;
  final int playerIndex;
  final bool isCurrentPlayer;
  final VoidCallback? onTap;

  static const farmAnimals = [
    Animal.rabbit,
    Animal.lamb,
    Animal.pig,
    Animal.cow,
    Animal.horse,
  ];

  static const animalEmojis = {
    Animal.rabbit: '\u{1F407}',
    Animal.lamb: '\u{1F411}',
    Animal.pig: '\u{1F437}',
    Animal.cow: '\u{1F404}',
    Animal.horse: '\u{1F40E}',
    Animal.smallDog: '\u{1F436}',
    Animal.bigDog: '\u{1F415}',
  };

  static const playerColors = [
    Color(0xFF2E7D32),
    Color(0xFF1565C0),
    Color(0xFFE65100),
    Color(0xFF6A1B9A),
  ];

  double get _winProgress {
    int collected = 0;
    for (final a in farmAnimals) {
      if (player.countOf(a) >= 1) collected++;
    }
    return collected / 5.0;
  }

  @override
  Widget build(BuildContext context) {
    final color = playerColors[playerIndex % playerColors.length];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = isCurrentPlayer
        ? color
        : isDark
            ? color.withValues(alpha: 0.15)
            : color.withValues(alpha: 0.3);
    final bgColor = isCurrentPlayer
        ? color.withValues(alpha: isDark ? 0.12 : 0.08)
        : theme.colorScheme.surface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor,
            width: isCurrentPlayer ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: bgColor,
          boxShadow: isCurrentPlayer
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        clipBehavior: Clip.hardEdge,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: SizedBox(
              width: 340,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(color, theme),
                  const SizedBox(height: 2),
                  _buildAnimalRow(theme),
                  const SizedBox(height: 2),
                  _buildDogRow(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color color, ThemeData theme) {
    final progressPercent = (_winProgress * 100).round();
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: isCurrentPlayer
                ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4)]
                : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          player.name,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isCurrentPlayer ? color : theme.colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        Text(
          '$progressPercent%',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? color.withValues(alpha: 0.9) : color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 50,
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: _winProgress,
              backgroundColor: color.withValues(alpha: isDark ? 0.2 : 0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimalRow(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: farmAnimals.map((animal) {
        final count = player.countOf(animal);
        final hasOne = count >= 1;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              animalEmojis[animal]!,
              style: TextStyle(
                fontSize: 22,
                color: hasOne ? null : theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: hasOne
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDogRow(ThemeData theme) {
    final smallDogCount = player.countOf(Animal.smallDog);
    final bigDogCount = player.countOf(Animal.bigDog);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${animalEmojis[Animal.smallDog]}$smallDogCount',
          style: TextStyle(
            fontSize: 12,
            color: smallDogCount > 0
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${animalEmojis[Animal.bigDog]}$bigDogCount',
          style: TextStyle(
            fontSize: 12,
            color: bigDogCount > 0
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}
