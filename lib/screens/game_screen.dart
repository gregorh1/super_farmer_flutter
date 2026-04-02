import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/animal.dart';
import '../models/exchange.dart';
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
        child: _buildBoard(context, game),
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

  Widget _buildBoard(BuildContext context, GameState game) {
    return Column(
      children: [
        // Compact strips for non-active players at the top
        _buildCompactPlayerStrips(context, game),

        // Center dice area — expanded to fill middle
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: DiceCenter(
                gameState: game,
                onRoll: () => ref.read(gameProvider.notifier).rollDice(),
                onEndTurn: () => ref.read(gameProvider.notifier).nextTurn(),
              ),
            ),
          ),
        ),

        // Active player's full panel at the bottom
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: PlayerArea(
            player: game.players[game.currentPlayerIndex],
            playerIndex: game.currentPlayerIndex,
            isCurrentPlayer: true,
            gameState: game,
            onTrade: (rate) => ref.read(gameProvider.notifier).trade(rate),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactPlayerStrips(BuildContext context, GameState game) {
    final otherPlayers = <int>[];
    for (int i = 0; i < game.players.length; i++) {
      if (i != game.currentPlayerIndex) otherPlayers.add(i);
    }
    if (otherPlayers.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          for (int i = 0; i < otherPlayers.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: _CompactPlayerStrip(
                player: game.players[otherPlayers[i]],
                playerIndex: otherPlayers[i],
                gameState: game,
                onTrade: (rate) => ref.read(gameProvider.notifier).trade(rate),
              ),
            ),
          ],
        ],
      ),
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
          elevation: 12,
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

/// Compact strip showing a non-active player's summary.
/// Tapping opens a detail popup.
class _CompactPlayerStrip extends StatelessWidget {
  const _CompactPlayerStrip({
    required this.player,
    required this.playerIndex,
    required this.gameState,
    required this.onTrade,
  });

  final PlayerHerd player;
  final int playerIndex;
  final GameState gameState;
  final void Function(ExchangeRate rate) onTrade;

  double get _winProgress {
    int collected = 0;
    for (final a in PlayerArea.farmAnimals) {
      if (player.countOf(a) >= 1) collected++;
    }
    return collected / 5.0;
  }

  @override
  Widget build(BuildContext context) {
    final color =
        PlayerArea.playerColors[playerIndex % PlayerArea.playerColors.length];
    final theme = Theme.of(context);
    final progressPercent = (_winProgress * 100).round();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showPlayerDetail(context),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(10),
            color: color.withValues(alpha: 0.05),
          ),
          child: Row(
            children: [
              // Color dot
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              // Name
              Expanded(
                child: Text(
                  player.name,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Progress
              Text(
                '$progressPercent%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              // Tiny animal summary
              ...PlayerArea.farmAnimals.map((a) => Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: SizedBox(
                      width: 12,
                      height: 12,
                      child: Opacity(
                        opacity: player.countOf(a) > 0 ? 1.0 : 0.25,
                        child: SvgPicture.asset(a.assetPath,
                            fit: BoxFit.contain),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlayerDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final color = PlayerArea
            .playerColors[playerIndex % PlayerArea.playerColors.length];
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              // Player name header
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    player.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(_winProgress * 100).round()}% complete',
                    style: theme.textTheme.bodySmall?.copyWith(color: color),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Animal grid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: PlayerArea.farmAnimals.map((animal) {
                  final count = player.countOf(animal);
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Opacity(
                          opacity: count > 0 ? 1.0 : 0.3,
                          child: SvgPicture.asset(animal.assetPath,
                              fit: BoxFit.contain),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        animal.label,
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              // Dogs row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dogInfo(Animal.smallDog, theme),
                  const SizedBox(width: 24),
                  _dogInfo(Animal.bigDog, theme),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dogInfo(Animal dog, ThemeData theme) {
    final count = player.countOf(dog);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Opacity(
            opacity: count > 0 ? 1.0 : 0.3,
            child: SvgPicture.asset(dog.assetPath, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'x$count',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(dog.label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
