import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/animal.dart';
import '../models/dice.dart';
import '../providers/game_provider.dart';
import 'player_area.dart';

class DiceCenter extends StatelessWidget {
  const DiceCenter({
    super.key,
    required this.gameState,
    required this.onRoll,
    required this.onEndTurn,
  });

  final GameState gameState;
  final VoidCallback onRoll;
  final VoidCallback onEndTurn;

  bool get _canRoll => gameState.lastRoll == null;
  bool get _canEndTurn => gameState.lastRoll != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final playerColor =
        PlayerArea.playerColors[gameState.currentPlayerIndex % PlayerArea.playerColors.length];
    final currentPlayer = gameState.currentPlayer!;

    return Card(
      elevation: isDark ? 0 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDark
            ? BorderSide(color: Colors.white.withValues(alpha: 0.12))
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current player indicator — no text truncation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: playerColor.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: playerColor, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: playerColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${currentPlayer.name}'s Turn",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? playerColor.withValues(alpha: 0.9)
                          : playerColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Dice results
            if (gameState.lastRoll != null) ...[
              _buildDiceResults(context, gameState.lastRoll!),
              const SizedBox(height: 12),
            ],

            // Roll button
            FilledButton.icon(
              onPressed: _canRoll ? onRoll : null,
              icon: const Icon(Icons.casino, size: 20),
              label: const Text('Roll Dice'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // End turn button — explicit styling for dark mode visibility
            OutlinedButton.icon(
              onPressed: _canEndTurn ? onEndTurn : null,
              icon: const Icon(Icons.skip_next, size: 20),
              label: const Text('End Turn'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: isDark
                    ? const Color(0xFFE0E0E0)
                    : theme.colorScheme.primary,
                side: BorderSide(
                  color: isDark
                      ? const Color(0xFF81C784).withValues(alpha: 0.6)
                      : theme.colorScheme.primary,
                  width: isDark ? 1.5 : 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiceResults(BuildContext context, DiceRollResult roll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _DieResult(
          face: roll.green,
          color: const Color(0xFF2E7D32),
          label: 'Green',
        ),
        const SizedBox(width: 16),
        _DieResult(
          face: roll.red,
          color: const Color(0xFFC62828),
          label: 'Red',
        ),
      ],
    );
  }
}

class _DieResult extends StatelessWidget {
  const _DieResult({
    required this.face,
    required this.color,
    required this.label,
  });

  final DiceFace face;
  final Color color;
  final String label;

  String get _assetPath => switch (face) {
        DiceFace.rabbit => Animal.rabbit.assetPath,
        DiceFace.lamb => Animal.lamb.assetPath,
        DiceFace.pig => Animal.pig.assetPath,
        DiceFace.cow => Animal.cow.assetPath,
        DiceFace.horse => Animal.horse.assetPath,
        DiceFace.fox => 'assets/images/fox.svg',
        DiceFace.wolf => 'assets/images/wolf.svg',
      };

  bool get _isDanger => face == DiceFace.fox || face == DiceFace.wolf;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: _isDanger
                ? Border.all(color: Colors.red.shade300, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              _assetPath,
              width: 34,
              height: 34,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
