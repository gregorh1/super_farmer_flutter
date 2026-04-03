import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/ai_difficulty.dart';
import '../providers/settings_provider.dart';
import 'premium_upgrade_dialog.dart';

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
    this.isPremium = false,
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
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final playerColor = availablePlayerColors[selectedColorIndex].color;
    final l10n = AppLocalizations.of(context)!;

    String aiDiffLabel(AiDifficulty diff) {
      switch (diff) {
        case AiDifficulty.easy: return l10n.aiEasy;
        case AiDifficulty.medium: return l10n.aiMedium;
        case AiDifficulty.hard: return l10n.aiHard;
      }
    }
    String aiDiffDesc(AiDifficulty diff) {
      switch (diff) {
        case AiDifficulty.easy: return l10n.aiEasyDesc;
        case AiDifficulty.medium: return l10n.aiMediumDesc;
        case AiDifficulty.hard: return l10n.aiHardDesc;
      }
    }

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
                    isAi ? l10n.aiPlayerN(playerIndex + 1) : l10n.playerN(playerIndex + 1),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? const Color(0xFFC8C4BC)
                          : playerColor,
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
                  final isLockedDiff = !isPremium && diff != AiDifficulty.easy;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        onTap: () {
                          if (isLockedDiff) {
                            showPremiumRequiredDialog(context);
                          } else {
                            onAiDifficultyChanged!(diff);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      aiDiffLabel(diff),
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : isLockedDiff
                                                ? theme.colorScheme.onSurface
                                                    .withValues(alpha: isDark ? 0.6 : 0.4)
                                                : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  if (isLockedDiff)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 3),
                                      child: Icon(
                                        Icons.lock,
                                        size: 12,
                                        color: Colors.amber.shade700,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                aiDiffDesc(diff),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.8)
                                      : isLockedDiff
                                          ? theme.colorScheme.onSurface
                                              .withValues(alpha: isDark ? 0.5 : 0.3)
                                          : theme.colorScheme.onSurface
                                              .withValues(alpha: isDark ? 0.7 : 0.5),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 3,
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
                hintText: l10n.playerN(playerIndex + 1),
                hintStyle: isDark
                    ? const TextStyle(color: Color(0xFF8A8A8A))
                    : null,
                labelText: l10n.nameOptional,
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
              l10n.color,
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
