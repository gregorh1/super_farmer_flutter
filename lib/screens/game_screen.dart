import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/animal.dart';
import '../models/exchange.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';
import '../widgets/dice_center.dart';
import '../widgets/player_area.dart';
import '../widgets/player_setup_card.dart';
import '../widgets/settings_sheet.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _transitionController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  void _startGame() {
    final setup = ref.read(playerSetupProvider);
    final names = List.generate(
      setup.playerCount,
      (i) => setup.displayName(i),
    );
    final colors = List.generate(
      setup.playerCount,
      (i) => setup.playerColor(i),
    );

    ref.read(gameProvider.notifier).startGame(names, colors);
    _transitionController.forward(from: 0.0);
  }

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

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Super Farmer'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => SettingsSheet.show(context),
                tooltip: 'Settings',
              ),
              IconButton(
                icon: const Icon(Icons.restart_alt),
                onPressed: () {
                  ref.read(gameProvider.notifier).resetGame();
                  _transitionController.forward(from: 0.0);
                },
                tooltip: 'New Game',
              ),
            ],
          ),
          body: SafeArea(
            child: _buildBoard(context, game),
          ),
        ),
      ),
    );
  }

  Widget _buildSetupScreen(BuildContext context) {
    final theme = Theme.of(context);
    final setup = ref.watch(playerSetupProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New Game')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          children: [
            // Header
            Icon(
              Icons.agriculture,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              'Super Farmer',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Collect one of each animal to win!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 28),

            // Player count selector
            Text(
              'Number of Players',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _PlayerCountSelector(
              count: setup.playerCount,
              onChanged: (count) {
                ref.read(playerSetupProvider.notifier).setPlayerCount(count);
              },
            ),
            const SizedBox(height: 24),

            // Player cards
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Column(
                key: ValueKey(setup.playerCount),
                children: List.generate(setup.playerCount, (i) {
                  final usedColors = <int>{};
                  for (int j = 0; j < setup.playerCount; j++) {
                    if (j != i) usedColors.add(setup.playerColorIndices[j]);
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PlayerSetupCard(
                      playerIndex: i,
                      name: setup.playerNames[i],
                      selectedColorIndex: setup.playerColorIndices[i],
                      usedColorIndices: usedColors,
                      onNameChanged: (name) {
                        ref
                            .read(playerSetupProvider.notifier)
                            .setPlayerName(i, name);
                      },
                      onColorChanged: (colorIndex) {
                        ref
                            .read(playerSetupProvider.notifier)
                            .setPlayerColor(i, colorIndex);
                      },
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),

            // Start button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _startGame,
                icon: const Icon(Icons.play_arrow, size: 28),
                label: const Text(
                  'Start Game',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
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

/// Card-style player count selector.
class _PlayerCountSelector extends StatelessWidget {
  const _PlayerCountSelector({
    required this.count,
    required this.onChanged,
  });

  final int count;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: List.generate(
        AppConstants.maxPlayers - AppConstants.minPlayers + 1,
        (i) {
          final value = AppConstants.minPlayers + i;
          final isSelected = value == count;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => onChanged(value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          value,
                          (_) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 1),
                            child: Icon(
                              Icons.person,
                              size: 16,
                              color: isSelected
                                  ? Colors.white
                                  : theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$value',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
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
    final color = player.color;
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
        final color = player.color;
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
