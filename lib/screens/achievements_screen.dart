import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';
import '../providers/achievement_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final states = ref.watch(achievementProvider);
    final unlockedCount = states.where((s) => s.unlocked).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _ProgressHeader(
            unlockedCount: unlockedCount,
            totalCount: AchievementDefinition.all.length,
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: AchievementDefinition.all.length,
              itemBuilder: (context, index) {
                final def = AchievementDefinition.all[index];
                final state = states.firstWhere((s) => s.id == def.id);
                return _AchievementTile(definition: def, state: state);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.unlockedCount,
    required this.totalCount,
  });

  final int unlockedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$unlockedCount / $totalCount',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$unlockedCount of $totalCount unlocked',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    required this.definition,
    required this.state,
  });

  final AchievementDefinition definition;
  final AchievementState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocked = state.unlocked;
    final hasProgress = definition.targetProgress != null;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: unlocked ? null : theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: unlocked
                    ? Colors.amber.shade100
                    : theme.colorScheme.outline.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                definition.icon,
                color: unlocked
                    ? Colors.amber.shade700
                    : isDark
                        ? const Color(0xFF9E9E9E)
                        : theme.colorScheme.outline.withValues(alpha: 0.4),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Name, description, progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    definition.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: unlocked
                          ? null
                          : theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    definition.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: unlocked
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.8)
                          : isDark
                              ? const Color(0xFFB0B0B0)
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                    ),
                  ),
                  if (hasProgress && !unlocked) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: state.progress /
                                  definition.targetProgress!,
                              minHeight: 6,
                              backgroundColor: isDark
                                  ? Colors.white.withValues(alpha: 0.15)
                                  : theme.colorScheme.outline
                                      .withValues(alpha: 0.15),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${state.progress}/${definition.targetProgress}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Unlock date or lock indicator
            if (unlocked && state.unlockedAt != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  '${state.unlockedAt!.day}/${state.unlockedAt!.month}/${state.unlockedAt!.year}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.4),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
