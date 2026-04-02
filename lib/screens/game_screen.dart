import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../utils/constants.dart';
import '../widgets/dice_center.dart';
import '../widgets/player_area.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  int _playerCount = 4;

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);

    ref.listen<GameState>(gameProvider, (prev, next) {
      if (next.winner != null && (prev?.winner == null)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showWinnerDialog(next.winner!);
        });
      }
    });

    if (!game.isStarted) {
      return _buildSetupScreen(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Farmer'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: () => ref.read(gameProvider.notifier).resetGame(),
            tooltip: 'Reset Game',
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _buildBoard(context, game, constraints);
          },
        ),
      ),
    );
  }

  Widget _buildSetupScreen(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('New Game')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.groups,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Super Farmer',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Collect one of each animal to win!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Number of Players',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              SegmentedButton<int>(
                segments: List.generate(
                  AppConstants.maxPlayers - AppConstants.minPlayers + 1,
                  (i) {
                    final count = AppConstants.minPlayers + i;
                    return ButtonSegment(
                      value: count,
                      label: Text('$count'),
                      icon: const Icon(Icons.person, size: 16),
                    );
                  },
                ),
                selected: {_playerCount},
                onSelectionChanged: (selected) {
                  setState(() => _playerCount = selected.first);
                },
              ),
              const SizedBox(height: 8),
              // Player color preview
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_playerCount, (i) {
                  final color = PlayerArea.playerColors[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Chip(
                      avatar: CircleAvatar(
                        backgroundColor: color,
                        radius: 8,
                      ),
                      label: Text('P${i + 1}'),
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  final names = List.generate(
                    _playerCount,
                    (i) => 'Player ${i + 1}',
                  );
                  ref.read(gameProvider.notifier).startGame(names);
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Game'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoard(
      BuildContext context, GameState game, BoxConstraints constraints) {
    final playerCount = game.players.length;
    final hasTopPlayer = playerCount >= 3;
    final hasLeftPlayer = playerCount >= 4;
    final hasRightPlayer = playerCount >= 2;

    // Responsive sizing
    final isCompact = constraints.maxHeight < 500;
    final playerAreaHeight = isCompact ? 100.0 : 120.0;
    final sidePlayerWidth = isCompact ? 110.0 : 130.0;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          // Top player (Player 3, rotated 180°)
          if (hasTopPlayer)
            SizedBox(
              height: playerAreaHeight,
              width: double.infinity,
              child: RotatedBox(
                quarterTurns: 2,
                child: _buildPlayerArea(game, 2),
              ),
            ),
          if (hasTopPlayer) const SizedBox(height: 4),

          // Middle row: left player, center, right player
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left player (Player 4, rotated 90°)
                if (hasLeftPlayer) ...[
                  SizedBox(
                    width: sidePlayerWidth,
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: _buildPlayerArea(game, 3),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],

                // Center dice area
                Expanded(
                  child: Center(
                    child: DiceCenter(
                      gameState: game,
                      onRoll: () =>
                          ref.read(gameProvider.notifier).rollDice(),
                      onEndTurn: () =>
                          ref.read(gameProvider.notifier).nextTurn(),
                    ),
                  ),
                ),

                // Right player (Player 2, rotated -90° = 3 quarter turns)
                if (hasRightPlayer) ...[
                  const SizedBox(width: 4),
                  SizedBox(
                    width: sidePlayerWidth,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: _buildPlayerArea(game, 1),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 4),
          // Bottom player (Player 1, no rotation)
          SizedBox(
            height: playerAreaHeight,
            width: double.infinity,
            child: _buildPlayerArea(game, 0),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerArea(GameState game, int playerIndex) {
    return PlayerArea(
      player: game.players[playerIndex],
      playerIndex: playerIndex,
      isCurrentPlayer: game.currentPlayerIndex == playerIndex,
      gameState: game,
      onTrade: (rate) => ref.read(gameProvider.notifier).trade(rate),
    );
  }

  void _showWinnerDialog(String winnerName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
              const SizedBox(width: 8),
              const Text('Winner!'),
            ],
          ),
          content: Text(
            '$winnerName has collected one of each animal and wins the game!',
            style: theme.textTheme.bodyLarge,
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ref.read(gameProvider.notifier).resetGame();
              },
              child: const Text('New Game'),
            ),
          ],
        );
      },
    );
  }
}
