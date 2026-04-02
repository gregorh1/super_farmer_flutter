import 'package:flutter/material.dart';
import '../providers/settings_provider.dart';

/// A card for configuring a single player's name and color.
class PlayerSetupCard extends StatelessWidget {
  const PlayerSetupCard({
    super.key,
    required this.playerIndex,
    required this.name,
    required this.selectedColorIndex,
    required this.usedColorIndices,
    required this.onNameChanged,
    required this.onColorChanged,
  });

  final int playerIndex;
  final String name;
  final int selectedColorIndex;
  final Set<int> usedColorIndices;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<int> onColorChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final playerColor = availablePlayerColors[selectedColorIndex].color;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: playerColor.withValues(alpha: isDark ? 0.6 : 0.4),
          width: isDark ? 2.5 : 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: playerColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: playerColor.withValues(alpha: 0.4),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${playerIndex + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Player ${playerIndex + 1}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: playerColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Name input
            TextField(
              onChanged: onNameChanged,
              decoration: InputDecoration(
                hintText: 'Player ${playerIndex + 1}',
                hintStyle: isDark
                    ? TextStyle(color: Colors.grey[500])
                    : null,
                labelText: 'Name (optional)',
                labelStyle: isDark
                    ? TextStyle(color: Colors.grey[400])
                    : null,
                prefixIcon: Icon(Icons.person_outline, color: playerColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: playerColor, width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            // Color picker
            Text(
              'Color',
              style: theme.textTheme.labelMedium?.copyWith(
                color: isDark
                    ? Colors.grey[400]
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(availablePlayerColors.length, (i) {
                final color = availablePlayerColors[i];
                final isSelected = i == selectedColorIndex;
                final isUsedByOther =
                    usedColorIndices.contains(i) && !isSelected;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onColorChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.color,
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected
                            ? Border.all(
                                color: theme.colorScheme.onSurface, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.color.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : isUsedByOther
                              ? Icon(Icons.person,
                                  color: Colors.white.withValues(alpha: 0.5),
                                  size: 16)
                              : null,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
