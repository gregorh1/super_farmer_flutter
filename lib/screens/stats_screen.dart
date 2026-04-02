import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';
import '../models/game_record.dart';
import '../providers/achievement_provider.dart';
import '../providers/stats_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(statsProvider);
    final stats = ref.watch(gameStatsProvider);

    final achievementStates = ref.watch(achievementProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Statistics'),
          centerTitle: true,
          actions: [
            if (records.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Clear all stats',
                onPressed: () => _confirmClear(context, ref),
              ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'History'),
              Tab(text: 'Leaderboard'),
              Tab(text: 'Achievements'),
            ],
          ),
        ),
        body: records.isEmpty
            ? TabBarView(
                children: [
                  const _EmptyState(),
                  const _EmptyState(),
                  const _EmptyState(),
                  _AchievementsTab(states: achievementStates),
                ],
              )
            : TabBarView(
                children: [
                  _OverviewTab(stats: stats),
                  _HistoryTab(records: records),
                  _LeaderboardTab(stats: stats),
                  _AchievementsTab(states: achievementStates),
                ],
              ),
      ),
    );
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Statistics'),
        content: const Text(
            'This will permanently delete all game history. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(statsProvider.notifier).clearAll();
              Navigator.pop(ctx);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart,
                size: 64,
                color: theme.colorScheme.primary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              'No games played yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete a game to see your statistics here.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.stats});
  final GameStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Games summary
        _SectionHeader(title: 'Games Summary'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Played',
                value: '${stats.gamesPlayed}',
                icon: Icons.casino,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                label: 'Won',
                value: '${stats.gamesWon}',
                icon: Icons.emoji_events,
                color: Colors.amber.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                label: 'Lost',
                value: '${stats.gamesLost}',
                icon: Icons.close,
                color: Colors.red.shade400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Win rate by player count
        if (stats.winRateByPlayerCount.isNotEmpty) ...[
          _SectionHeader(title: 'Win Rate by Player Count'),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final pc in [2, 3, 4]) ...[
                if (stats.winRateByPlayerCount.containsKey(pc))
                  Expanded(
                    child: _WinRateCard(
                      playerCount: pc,
                      winRate: stats.winRateByPlayerCount[pc]!,
                    ),
                  ),
                if (stats.winRateByPlayerCount.containsKey(pc) && pc < 4)
                  const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 20),
        ],

        // Game length stats
        _SectionHeader(title: 'Game Length'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _LabeledStat(
                    label: 'Avg. Turns',
                    value: stats.averageTurns.toStringAsFixed(1),
                    icon: Icons.straighten,
                  ),
                ),
                if (stats.fastestWin != null) ...[
                  Container(
                    width: 1,
                    height: 40,
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  Expanded(
                    child: _LabeledStat(
                      label: 'Fastest Win',
                      value: '${stats.fastestWin} turns',
                      icon: Icons.bolt,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Strategy
        if (stats.mostCommonLastAnimal != null) ...[
          _SectionHeader(title: 'Winning Strategy'),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.pets, color: theme.colorScheme.primary),
              title: const Text('Most common final animal'),
              subtitle: Text(stats.mostCommonLastAnimal!),
            ),
          ),
        ],
      ],
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.records});
  final List<GameRecord> records;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sorted = List<GameRecord>.from(records)
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final r = sorted[index];
        final dateStr =
            '${r.date.day}/${r.date.month}/${r.date.year}';
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                '${r.playerCount}P',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            title: Row(
              children: [
                Icon(Icons.emoji_events,
                    size: 16, color: Colors.amber.shade700),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    r.winnerName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              '${r.playerNames.join(", ")} \u2022 ${r.totalTurns} turns',
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              dateStr,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LeaderboardTab extends StatelessWidget {
  const _LeaderboardTab({required this.stats});
  final GameStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = stats.leaderboard;

    if (entries.length < 2) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Play with at least 2 named players to see leaderboard rankings.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final e = entries[index];
        final rank = index + 1;
        final medalColor = switch (rank) {
          1 => Colors.amber.shade700,
          2 => Colors.grey.shade400,
          3 => Colors.brown.shade300,
          _ => null,
        };

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  medalColor ?? theme.colorScheme.surfaceContainerHighest,
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: medalColor != null
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            title: Text(
              e.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${e.gamesPlayed} games played'),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${e.wins} wins',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  '${(e.winRate * 100).round()}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Helper widgets

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WinRateCard extends StatelessWidget {
  const _WinRateCard({
    required this.playerCount,
    required this.winRate,
  });
  final int playerCount;
  final double winRate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (winRate * 100).round();
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                playerCount,
                (_) => const Icon(Icons.person, size: 14),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$pct%',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              '$playerCount players',
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledStat extends StatelessWidget {
  const _LabeledStat({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _AchievementsTab extends StatelessWidget {
  const _AchievementsTab({required this.states});
  final List<AchievementState> states;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlockedCount = states.where((s) => s.unlocked).length;
    final totalCount = AchievementDefinition.all.length;
    final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Progress summary
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Achievements',
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
                        theme.colorScheme.primary.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Achievement list
        for (final def in AchievementDefinition.all) ...[
          _AchievementListTile(
            definition: def,
            state: states.firstWhere((s) => s.id == def.id),
          ),
        ],
      ],
    );
  }
}

class _AchievementListTile extends StatelessWidget {
  const _AchievementListTile({
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

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      color: unlocked ? null : theme.colorScheme.surfaceContainerHighest,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: unlocked
                ? Colors.amber.shade100
                : theme.colorScheme.outline.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            unlocked ? definition.icon : Icons.lock,
            color: unlocked
                ? Colors.amber.shade700
                : theme.colorScheme.outline.withValues(alpha: 0.4),
            size: 20,
          ),
        ),
        title: Text(
          definition.name,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: unlocked
                ? null
                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              definition.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface
                    .withValues(alpha: unlocked ? 0.7 : 0.4),
              ),
            ),
            if (hasProgress && !unlocked) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: state.progress / definition.targetProgress!,
                        minHeight: 4,
                        backgroundColor:
                            theme.colorScheme.outline.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${state.progress}/${definition.targetProgress}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: unlocked && state.unlockedAt != null
            ? Text(
                '${state.unlockedAt!.day}/${state.unlockedAt!.month}/${state.unlockedAt!.year}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              )
            : null,
      ),
    );
  }
}
