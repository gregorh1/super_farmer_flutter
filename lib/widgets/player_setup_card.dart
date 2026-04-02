import 'package:flutter/material.dart';
import '../models/ai_difficulty.dart';
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
    this.isAi = false,
    this.aiDifficulty = AiDifficulty.medium,
    this.onAiChanged,
    this.onAiDifficultyChanged,
  });

  final int playerIndex;
  final String name;
  final int selectedColorIndex;
  final Set<int> usedColorIndices;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<int> onColorChanged;
  final bool isAi;
  final AiDifficulty aiDifficulty;
  final ValueChanged<bool>? onAiChanged;
  final ValueChanged<AiDifficulty>? onAiDifficultyChanged;

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
                    child: Icon(
                      isAi ? Icons.smart_toy : Icons.person,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isAi ? 'AI Player ${playerIndex + 1}' : 'Player ${playerIndex + 1}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: playerColor,
                    ),
                  ),
                ),
                // AI toggle
                if (onAiChanged != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.smart_toy_outlined,
                        size: 18,
                        color: isAi
                            ? playerColor
                            : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        height: 28,
                        child: Switch(
                          value: isAi,
                          onChanged: onAiChanged,
                          activeTrackColor: playerColor,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // AI difficulty selector (shown when AI is enabled)
            if (isAi && onAiDifficultyChanged != null) ...[
              Row(
                children: AiDifficulty.values.map((diff) {
                  final isSelected = diff == aiDifficulty;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        onTap: () => onAiDifficultyChanged!(diff),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? playerColor
                                : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? playerColor
                                  : theme.colorScheme.outline.withValues(alpha: 0.3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                diff.label,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                diff.description,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 9,
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.8)
                                      : theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Name input (hidden for AI players)
            if (!isAi)
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
