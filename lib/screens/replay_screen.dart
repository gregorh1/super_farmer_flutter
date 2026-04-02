import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n_helpers.dart';
import '../models/animal.dart';
import '../models/game_replay.dart';
import '../providers/replay_provider.dart';

class ReplayScreen extends ConsumerStatefulWidget {
  const ReplayScreen({super.key, required this.replayId});

  final String replayId;

  @override
  ConsumerState<ReplayScreen> createState() => _ReplayScreenState();
}

class _ReplayScreenState extends ConsumerState<ReplayScreen>
    with TickerProviderStateMixin {
  Timer? _autoPlayTimer;
  late AnimationController _turnTransitionController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _turnTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _turnTransitionController,
      curve: Curves.easeInOut,
    );
    _turnTransitionController.value = 1.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final replays = ref.read(replayStorageProvider);
      final replay = replays.where((r) => r.id == widget.replayId).firstOrNull;
      if (replay != null) {
        ref.read(replayPlaybackProvider.notifier).loadReplay(replay);
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _turnTransitionController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    final playback = ref.read(replayPlaybackProvider);
    if (playback.isAtEnd) return;
    ref.read(replayPlaybackProvider.notifier).play();
    _scheduleNextStep();
  }

  void _scheduleNextStep() {
    _autoPlayTimer?.cancel();
    final playback = ref.read(replayPlaybackProvider);
    if (!playback.isPlaying) return;

    final delayMs = (2000 / playback.playbackSpeed).round();
    _autoPlayTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!mounted) return;
      final current = ref.read(replayPlaybackProvider);
      if (!current.isPlaying) return;
      _animateStepForward();
      if (!ref.read(replayPlaybackProvider).isAtEnd) {
        _scheduleNextStep();
      } else {
        ref.read(replayPlaybackProvider.notifier).pause();
      }
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    ref.read(replayPlaybackProvider.notifier).pause();
  }

  void _animateStepForward() {
    _turnTransitionController.forward(from: 0.0);
    ref.read(replayPlaybackProvider.notifier).stepForward();
  }

  void _animateStepBackward() {
    _turnTransitionController.forward(from: 0.0);
    ref.read(replayPlaybackProvider.notifier).stepBackward();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final playback = ref.watch(replayPlaybackProvider);
    final replay = playback.replay;

    if (replay == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.replayViewer)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final turn = playback.currentTurn;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.replayViewer),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: l10n.exportReplay,
            onPressed: () => _exportReplay(replay),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Game info header
            _GameInfoHeader(replay: replay),

            // Player animal counts
            Expanded(
              child: turn != null
                  ? FadeTransition(
                      opacity: _fadeAnimation,
                      child: _TurnDetail(
                        turn: turn,
                        replay: replay,
                        turnIndex: playback.currentTurnIndex,
                      ),
                    )
                  : Center(
                      child: Text(
                        l10n.noReplaysYet,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
            ),

            // Turn slider
            if (replay.turns.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      l10n.turnOfTotal(
                          playback.currentTurnIndex + 1, replay.turns.length),
                      style: theme.textTheme.labelMedium,
                    ),
                    Expanded(
                      child: Slider(
                        value: playback.currentTurnIndex.toDouble(),
                        min: 0,
                        max: (replay.turns.length - 1).toDouble(),
                        divisions: replay.turns.length > 1
                            ? replay.turns.length - 1
                            : 1,
                        onChanged: (v) {
                          _stopAutoPlay();
                          _turnTransitionController.forward(from: 0.0);
                          ref
                              .read(replayPlaybackProvider.notifier)
                              .jumpToTurn(v.round());
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Playback controls
            _PlaybackControls(
              playback: playback,
              onStepBack: () {
                _stopAutoPlay();
                _animateStepBackward();
              },
              onPlayPause: () {
                if (playback.isPlaying) {
                  _stopAutoPlay();
                } else {
                  _startAutoPlay();
                }
              },
              onStepForward: () {
                _stopAutoPlay();
                _animateStepForward();
              },
              onSpeedChanged: (speed) {
                ref.read(replayPlaybackProvider.notifier).setSpeed(speed);
                if (playback.isPlaying) {
                  _scheduleNextStep(); // Reschedule with new speed
                }
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _exportReplay(GameReplay replay) {
    final json = replay.exportJson();
    Clipboard.setData(ClipboardData(text: json));
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.replayCopied),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Game Info Header
// ---------------------------------------------------------------------------

class _GameInfoHeader extends StatelessWidget {
  const _GameInfoHeader({required this.replay});
  final GameReplay replay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dateStr =
        '${replay.date.day}/${replay.date.month}/${replay.date.year}';

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.winnerMessage(replay.winnerName),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${replay.playerNames.join(", ")} - $dateStr - ${l10n.nTurns(replay.totalTurns)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Turn Detail — shows what happened in a single turn
// ---------------------------------------------------------------------------

class _TurnDetail extends StatelessWidget {
  const _TurnDetail({
    required this.turn,
    required this.replay,
    required this.turnIndex,
  });

  final TurnRecord turn;
  final GameReplay replay;
  final int turnIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Get player color
    final colorValue = turn.playerIndex < replay.playerColors.length
        ? replay.playerColors[turn.playerIndex]
        : 0xFF2E7D32;
    final playerColor = Color(colorValue);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Player turn header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: playerColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: playerColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: playerColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.playerTurn(turn.playerName),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: playerColor,
                ),
              ),
              const Spacer(),
              Text(
                l10n.turnN(turn.turnNumber + 1),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: playerColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Dice result
        _DiceResultRow(turn: turn),
        const SizedBox(height: 12),

        // Events (fox/wolf attacks)
        if (turn.foxAttack) ...[
          _EventChip(
            icon: Icons.warning_amber,
            label: turn.smallDogSacrificed
                ? l10n.foxDogSaved
                : l10n.foxAttack,
            color: Colors.orange,
          ),
          const SizedBox(height: 6),
        ],
        if (turn.wolfAttack) ...[
          _EventChip(
            icon: Icons.warning,
            label:
                turn.bigDogSacrificed ? l10n.wolfDogSaved : l10n.wolfAttack,
            color: Colors.red,
          ),
          const SizedBox(height: 6),
        ],

        // Bred animals
        if (turn.bred.isNotEmpty) ...[
          _AnimalChangeSection(
            title: l10n.bred,
            animals: turn.bred,
            color: Colors.green,
            icon: Icons.add_circle_outline,
          ),
          const SizedBox(height: 6),
        ],

        // Lost animals
        if (turn.lostAnimals.isNotEmpty) ...[
          _AnimalChangeSection(
            title: l10n.lostLabel,
            animals: turn.lostAnimals,
            color: Colors.red,
            icon: Icons.remove_circle_outline,
          ),
          const SizedBox(height: 6),
        ],

        // Trades
        if (turn.trades.isNotEmpty) ...[
          _TradesSection(trades: turn.trades),
          const SizedBox(height: 6),
        ],

        const SizedBox(height: 12),

        // Player animal snapshots
        Text(
          l10n.animals,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...replay.playerNames.map((name) {
          final animals = turn.playerAnimalsAfter[name] ?? {};
          final pIndex = replay.playerNames.indexOf(name);
          final pColor = pIndex < replay.playerColors.length
              ? Color(replay.playerColors[pIndex])
              : theme.colorScheme.primary;
          return _PlayerAnimalSnapshot(
            playerName: name,
            animals: animals,
            playerColor: pColor,
            isCurrentTurnPlayer: name == turn.playerName,
          );
        }),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Dice Result Row
// ---------------------------------------------------------------------------

class _DiceResultRow extends StatelessWidget {
  const _DiceResultRow({required this.turn});
  final TurnRecord turn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _DieDisplay(
          label: l10n.greenDie,
          face: turn.greenDie,
          color: Colors.green.shade700,
        ),
        const SizedBox(width: 24),
        _DieDisplay(
          label: l10n.redDie,
          face: turn.redDie,
          color: Colors.red.shade700,
        ),
      ],
    );
  }
}

class _DieDisplay extends StatelessWidget {
  const _DieDisplay({
    required this.label,
    required this.face,
    required this.color,
  });

  final String label;
  final String face;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get the SVG for the die face if it's an animal
    Widget faceWidget;
    final animal = _faceToAnimal(face);
    if (animal != null) {
      faceWidget = SvgPicture.asset(
        animal.assetPath,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
      );
    } else {
      // Fox or wolf — use icon
      faceWidget = Icon(
        face == 'fox' ? Icons.pest_control : Icons.pets,
        size: 32,
        color: face == 'fox' ? Colors.orange : Colors.blueGrey,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: color),
        ),
        const SizedBox(height: 4),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
          ),
          child: Center(child: faceWidget),
        ),
        const SizedBox(height: 2),
        Text(
          _faceDisplayName(context, face),
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Animal? _faceToAnimal(String face) {
    try {
      return Animal.values.firstWhere((a) => a.name == face);
    } catch (_) {
      return null;
    }
  }

  String _faceDisplayName(BuildContext context, String face) {
    final animal = _faceToAnimal(face);
    if (animal != null) return localizedAnimalName(context, animal);
    final l10n = AppLocalizations.of(context)!;
    if (face == 'fox') return l10n.animalFox;
    if (face == 'wolf') return l10n.animalWolf;
    return face;
  }
}

// ---------------------------------------------------------------------------
// Event chip
// ---------------------------------------------------------------------------

class _EventChip extends StatelessWidget {
  const _EventChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animal change section (bred / lost)
// ---------------------------------------------------------------------------

class _AnimalChangeSection extends StatelessWidget {
  const _AnimalChangeSection({
    required this.title,
    required this.animals,
    required this.color,
    required this.icon,
  });

  final String title;
  final Map<String, int> animals;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$title: ',
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 6,
              children: animals.entries.map((e) {
                final animal = _tryGetAnimal(e.key);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (animal != null)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: SvgPicture.asset(animal.assetPath,
                            fit: BoxFit.contain),
                      ),
                    const SizedBox(width: 2),
                    Text(
                      '${e.value}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Animal? _tryGetAnimal(String name) {
    try {
      return Animal.values.firstWhere((a) => a.name == name);
    } catch (_) {
      return null;
    }
  }
}

// ---------------------------------------------------------------------------
// Trades section
// ---------------------------------------------------------------------------

class _TradesSection extends StatelessWidget {
  const _TradesSection({required this.trades});
  final List<TradeRecord> trades;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.swap_horiz, size: 16, color: Colors.blue.shade700),
              const SizedBox(width: 6),
              Text(
                l10n.traded,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...trades.map((t) => Padding(
                padding: const EdgeInsets.only(left: 22, top: 2),
                child: Text(
                  '${t.fromCount} ${_animalLabel(context, t.fromAnimal)} → ${t.toCount} ${_animalLabel(context, t.toAnimal)}',
                  style: theme.textTheme.bodySmall,
                ),
              )),
        ],
      ),
    );
  }

  String _animalLabel(BuildContext context, String name) {
    try {
      final animal = Animal.values.firstWhere((a) => a.name == name);
      return localizedAnimalName(context, animal);
    } catch (_) {
      return name;
    }
  }
}

// ---------------------------------------------------------------------------
// Player animal snapshot
// ---------------------------------------------------------------------------

class _PlayerAnimalSnapshot extends StatelessWidget {
  const _PlayerAnimalSnapshot({
    required this.playerName,
    required this.animals,
    required this.playerColor,
    required this.isCurrentTurnPlayer,
  });

  final String playerName;
  final Map<String, int> animals;
  final Color playerColor;
  final bool isCurrentTurnPlayer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final farmAnimals = [
      Animal.rabbit,
      Animal.lamb,
      Animal.pig,
      Animal.cow,
      Animal.horse,
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrentTurnPlayer
            ? playerColor.withValues(alpha: 0.08)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: isCurrentTurnPlayer
            ? Border.all(color: playerColor.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: playerColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 60,
            child: Text(
              playerName,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          ...farmAnimals.map((animal) {
            final count = animals[animal.name] ?? 0;
            return Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: Opacity(
                      opacity: count > 0 ? 1.0 : 0.25,
                      child: SvgPicture.asset(animal.assetPath,
                          fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(width: 1),
                  Text(
                    '$count',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: count > 0
                          ? null
                          : theme.colorScheme.onSurface
                              .withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            );
          }),
          // Dogs
          ...[Animal.smallDog, Animal.bigDog].map((dog) {
            final count = animals[dog.name] ?? 0;
            if (count == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: SvgPicture.asset(dog.assetPath,
                        fit: BoxFit.contain),
                  ),
                  Text(
                    '$count',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Playback Controls
// ---------------------------------------------------------------------------

class _PlaybackControls extends StatelessWidget {
  const _PlaybackControls({
    required this.playback,
    required this.onStepBack,
    required this.onPlayPause,
    required this.onStepForward,
    required this.onSpeedChanged,
  });

  final ReplayPlaybackState playback;
  final VoidCallback onStepBack;
  final VoidCallback onPlayPause;
  final VoidCallback onStepForward;
  final ValueChanged<double> onSpeedChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Transport controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                iconSize: 32,
                onPressed: playback.isAtStart ? null : onStepBack,
                tooltip: 'Previous turn',
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: playback.isAtEnd && !playback.isPlaying
                    ? null
                    : onPlayPause,
                style: FilledButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                ),
                child: Icon(
                  playback.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 32,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.skip_next),
                iconSize: 32,
                onPressed: playback.isAtEnd ? null : onStepForward,
                tooltip: 'Next turn',
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Speed control
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${l10n.speed}: ',
                style: theme.textTheme.labelSmall,
              ),
              for (final speed in [0.5, 1.0, 2.0, 4.0]) ...[
                _SpeedButton(
                  label: '${speed}x',
                  isSelected: playback.playbackSpeed == speed,
                  onTap: () => onSpeedChanged(speed),
                ),
                if (speed != 4.0) const SizedBox(width: 4),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SpeedButton extends StatelessWidget {
  const _SpeedButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : null,
          ),
        ),
      ),
    );
  }
}
