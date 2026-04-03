import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n_helpers.dart';
import '../models/animal.dart';
import '../models/exchange.dart';
import '../providers/game_provider.dart';
import 'farm_decorations.dart';

class PlayerArea extends StatefulWidget {
  const PlayerArea({
    super.key,
    required this.player,
    required this.playerIndex,
    required this.isCurrentPlayer,
    required this.gameState,
    required this.onTrade,
    this.isAiTurn = false,
  });

  final PlayerHerd player;
  final int playerIndex;
  final bool isCurrentPlayer;
  final GameState gameState;
  final void Function(ExchangeRate rate) onTrade;
  final bool isAiTurn;

  static const farmAnimals = [
    Animal.rabbit,
    Animal.lamb,
    Animal.pig,
    Animal.cow,
    Animal.horse,
  ];

  static const exchangeRateValues = [6, 2, 3, 2];

  static const exchangeRateLabels = [
    '6 Rabbits = 1 Sheep',
    '2 Sheep = 1 Pig',
    '3 Pigs = 1 Cow',
    '2 Cows = 1 Horse',
  ];

  static const playerColors = [
    Color(0xFF2E7D32),
    Color(0xFF1565C0),
    Color(0xFFE65100),
    Color(0xFF6A1B9A),
  ];

  @override
  State<PlayerArea> createState() => PlayerAreaState();
}

class PlayerAreaState extends State<PlayerArea> with TickerProviderStateMixin {
  // Attack shake animation
  late final AnimationController _attackShakeController;

  // Attack flash overlay
  late final AnimationController _attackFlashController;

  // Dog sacrifice flash
  late final AnimationController _dogSacrificeController;

  // Per-animal count pop animations
  final Map<Animal, AnimationController> _countPopControllers = {};
  final Map<Animal, Animation<double>> _countPopAnimations = {};

  // Track previous counts to detect changes
  Map<Animal, int> _previousCounts = {};

  // Track the last event we animated so we don't re-trigger
  TurnEvent? _lastAnimatedEvent;

  double get _winProgress {
    int collected = 0;
    for (final a in PlayerArea.farmAnimals) {
      if (widget.player.countOf(a) >= 1) collected++;
    }
    return collected / 5.0;
  }

  @override
  void initState() {
    super.initState();

    _attackShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _attackFlashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _dogSacrificeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    for (final animal in Animal.values) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
      _countPopControllers[animal] = controller;
      _countPopAnimations[animal] = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }

    _previousCounts = {
      for (final a in Animal.values) a: widget.player.countOf(a),
    };
  }

  @override
  void didUpdateWidget(PlayerArea oldWidget) {
    super.didUpdateWidget(oldWidget);

    for (final animal in Animal.values) {
      final oldCount = _previousCounts[animal] ?? 0;
      final newCount = widget.player.countOf(animal);
      if (newCount != oldCount) {
        _countPopControllers[animal]?.forward(from: 0);
      }
    }
    _previousCounts = {
      for (final a in Animal.values) a: widget.player.countOf(a),
    };

    final event = widget.gameState.lastEvent;
    if (event != null &&
        event != _lastAnimatedEvent &&
        widget.isCurrentPlayer) {
      _lastAnimatedEvent = event;

      if (event.foxAttack || event.wolfAttack) {
        if (event.smallDogSacrificed || event.bigDogSacrificed) {
          _dogSacrificeController.forward(from: 0);
        }
        if (event.lostAnimals.isNotEmpty) {
          _attackFlashController.forward(from: 0);
          _attackShakeController.forward(from: 0);
        }
      }
    }

    if (widget.gameState.lastEvent == null) {
      _lastAnimatedEvent = null;
    }
  }

  @override
  void dispose() {
    _attackShakeController.dispose();
    _attackFlashController.dispose();
    _dogSacrificeController.dispose();
    for (final c in _countPopControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.player.color;
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge(
          [_attackShakeController, _attackFlashController, _dogSacrificeController]),
      builder: (context, child) {
        final t = _attackShakeController.value;
        final shakeOffset =
            t == 0 ? 0.0 : math.sin(t * math.pi * 4) * 6 * (1 - t);
        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: Stack(
            children: [
              WoodenFrame(
                borderWidth: widget.isCurrentPlayer ? 4.0 : 2.5,
                cornerRadius: 12,
                woodColor: widget.isCurrentPlayer
                    ? const Color(0xFF8D6E63)
                    : const Color(0xFFBCAAA4),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: widget.isCurrentPlayer
                        ? color.withValues(alpha: 0.08)
                        : theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: widget.isCurrentPlayer
                            ? color.withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.08),
                        blurRadius: widget.isCurrentPlayer ? 8 : 4,
                        spreadRadius: widget.isCurrentPlayer ? 1 : 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    children: [
                      // Fence texture at bottom
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 14,
                        child: CustomPaint(
                          painter: FencePainter(
                            fenceColor: color.withValues(alpha: 0.08),
                            picketSpacing: 10,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHeader(color, theme),
                            const SizedBox(height: 4),
                            _buildAnimalRow(color, theme),
                            const SizedBox(height: 4),
                            _buildDogRow(color, theme),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Red flash overlay for attacks
              if (_attackFlashController.isAnimating)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.red.withValues(
                          alpha: (_attackFlashController.value *
                                  0.35 *
                                  (1 - _attackFlashController.value) *
                                  4)
                              .clamp(0, 0.35),
                        ),
                      ),
                    ),
                  ),
                ),
              // Amber flash overlay for dog sacrifice
              if (_dogSacrificeController.isAnimating)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.amber.withValues(
                          alpha: (_dogSacrificeController.value *
                                  0.4 *
                                  (1 - _dogSacrificeController.value) *
                                  4)
                              .clamp(0, 0.4),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(Color color, ThemeData theme) {
    final progressPercent = (_winProgress * 100).round();
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: widget.isCurrentPlayer
                ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4)]
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          widget.player.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: widget.isCurrentPlayer ? color : null,
          ),
        ),
        const Spacer(),
        Text(
          '$progressPercent%',
          style: theme.textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          height: 8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _winProgress,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimalRow(Color color, ThemeData theme) {
    final widgets = <Widget>[];
    for (int i = 0; i < PlayerArea.farmAnimals.length; i++) {
      widgets.add(
        Expanded(child: _buildAnimalCell(PlayerArea.farmAnimals[i], theme)),
      );
      if (i < PlayerArea.farmAnimals.length - 1) {
        widgets.add(_buildExchangeControl(i, color, theme));
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: widgets,
    );
  }

  Widget _buildAnimalCell(Animal animal, ThemeData theme) {
    final count = widget.player.countOf(animal);
    final hasOne = count >= 1;
    final popAnim = _countPopAnimations[animal]!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: Opacity(
            opacity: hasOne ? 1.0 : 0.4,
            child: SvgPicture.asset(animal.assetPath, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 2),
        AnimatedBuilder(
          animation: popAnim,
          builder: (context, child) {
            final t = popAnim.value;
            final scale = t == 0 ? 1.0 : 1.0 + 0.4 * math.sin(t * math.pi);
            return Transform.scale(
              scale: scale,
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: hasOne
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            );
          },
        ),
        Text(
          localizedAnimalName(context, animal),
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 9,
            color: theme.colorScheme.onSurface
                .withValues(alpha: theme.brightness == Brightness.dark ? 0.9 : 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildExchangeControl(int index, Color color, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final exchangeLabels = [
      l10n.exchangeRabbitsForSheep,
      l10n.exchangeSheepForPig,
      l10n.exchangePigsForCow,
      l10n.exchangeCowsForHorse,
    ];

    final rate = PlayerArea.exchangeRateValues[index];
    final lowerAnimal = PlayerArea.farmAnimals[index];
    final higherAnimal = PlayerArea.farmAnimals[index + 1];

    final forwardRate = Exchange.rates[index];
    final reverseRate = ExchangeRate(
      from: higherAnimal,
      fromCount: 1,
      to: lowerAnimal,
      toCount: rate,
    );

    final canTradeUp = widget.isCurrentPlayer &&
        !widget.isAiTurn &&
        widget.player.countOf(lowerAnimal) >= forwardRate.fromCount &&
        (widget.gameState.bank[higherAnimal] ?? 0) >= 1;

    final canTradeDown = widget.isCurrentPlayer &&
        !widget.isAiTurn &&
        widget.player.countOf(higherAnimal) >= 1 &&
        (widget.gameState.bank[lowerAnimal] ?? 0) >= rate;

    return Tooltip(
      message: exchangeLabels[index],
      child: SizedBox(
        width: 48,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                onPressed: canTradeUp ? () => widget.onTrade(forwardRate) : null,
                icon: Icon(Icons.arrow_upward, size: 24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),
                color: color,
                disabledColor: color.withValues(alpha: 0.2),
                tooltip: canTradeUp ? '$rate:1' : l10n.notEnoughAnimals,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$rate:1',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFFB0D8B0)
                      : color,
                ),
              ),
            ),
            SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                onPressed:
                    canTradeDown ? () => widget.onTrade(reverseRate) : null,
                icon: Icon(Icons.arrow_downward, size: 24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),
                color: color,
                disabledColor: color.withValues(alpha: 0.2),
                tooltip: canTradeDown ? '1:$rate' : l10n.notEnoughAnimals,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDogRow(Color color, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final canBuySmallDog = widget.isCurrentPlayer &&
        !widget.isAiTurn &&
        widget.player.countOf(Animal.lamb) >= 1 &&
        (widget.gameState.bank[Animal.smallDog] ?? 0) >= 1;

    final canBuyBigDog = widget.isCurrentPlayer &&
        !widget.isAiTurn &&
        widget.player.countOf(Animal.cow) >= 1 &&
        (widget.gameState.bank[Animal.bigDog] ?? 0) >= 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDogCell(
          Animal.smallDog,
          l10n.buyWithLamb,
          canBuySmallDog,
          Exchange.rates[4],
          color,
          theme,
        ),
        const SizedBox(width: 24),
        _buildDogCell(
          Animal.bigDog,
          l10n.buyWithCow,
          canBuyBigDog,
          Exchange.rates[5],
          color,
          theme,
        ),
      ],
    );
  }

  Widget _buildDogCell(
    Animal dog,
    String label,
    bool canBuy,
    ExchangeRate rate,
    Color color,
    ThemeData theme,
  ) {
    final count = widget.player.countOf(dog);
    final popAnim = _countPopAnimations[dog]!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Opacity(
            opacity: count > 0 ? 1.0 : 0.4,
            child: SvgPicture.asset(dog.assetPath, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(width: 4),
        AnimatedBuilder(
          animation: popAnim,
          builder: (context, child) {
            final t = popAnim.value;
            final scale = t == 0 ? 1.0 : 1.0 + 0.4 * math.sin(t * math.pi);
            return Transform.scale(
              scale: scale,
              child: Text(
                'x$count',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 6),
        SizedBox(
          height: 48,
          child: TextButton(
            onPressed: canBuy ? () => widget.onTrade(rate) : null,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(48, 48),
              textStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              foregroundColor: color,
              disabledForegroundColor: theme.colorScheme.onSurface
                  .withValues(alpha: theme.brightness == Brightness.dark ? 0.8 : 0.38),
            ),
            child: Text(label),
          ),
        ),
      ],
    );
  }
}
