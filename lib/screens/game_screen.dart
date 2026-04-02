import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/animal.dart';
import '../providers/game_provider.dart';
import '../widgets/animal_card.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final theme = Theme.of(context);

    if (!game.isStarted) {
      return Scaffold(
        appBar: AppBar(title: const Text('New Game')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.groups,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Start a New Game',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    ref
                        .read(gameProvider.notifier)
                        .startGame(['Player 1', 'Player 2']);
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start 2-Player Game'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 24),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final player = game.currentPlayer!;
    return Scaffold(
      appBar: AppBar(
        title: Text("${player.name}'s Turn"),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: () => ref.read(gameProvider.notifier).resetGame(),
            tooltip: 'Reset Game',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      player.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Turn ${game.currentPlayerIndex + 1} of ${game.players.length}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your Herd',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Animal.values
                  .map((a) => AnimalCard(
                        animal: a,
                        count: player.countOf(a),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.read(gameProvider.notifier).nextTurn(),
              icon: const Icon(Icons.skip_next),
              label: const Text('End Turn'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
