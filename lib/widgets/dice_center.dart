import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/animal.dart';
import '../models/dice.dart';
import '../providers/game_provider.dart';

class DiceCenter extends StatefulWidget {
  const DiceCenter({
    super.key,
    required this.gameState,
    required this.onRoll,
    required this.onEndTurn,
    this.isAiTurn = false,
  });

  final GameState gameState;
  final VoidCallback onRoll;
  final VoidCallback onEndTurn;
  final bool isAiTurn;

  @override
  State<DiceCenter> createState() => DiceCenterState();
}

class DiceCenterState extends State<DiceCenter> with TickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final AnimationController _revealController;
  late final Animation<double> _shakeAnimation;
  late final Animation<double> _revealScale;
  late final Animation<double> _revealOpacity;

  bool _isRolling = false;
  DiceRollResult? _displayedRoll;

  static const _greenFaces = [
    DiceFace.rabbit,
    DiceFace.lamb,
    DiceFace.pig,
    DiceFace.cow,
    DiceFace.wolf,
  ];
  static const _redFaces = [
    DiceFace.rabbit,
    DiceFace.lamb,
    DiceFace.pig,
    DiceFace.horse,
    DiceFace.fox,
  ];

  int _shuffleIndex = 0;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _shakeAnimation = Tween<double>(begin: -0.08, end: 0.08).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
    _shakeController.addStatusListener((status) {
      if (_isRolling) {
        if (status == AnimationStatus.completed) {
          _shakeController.reverse();
          _advanceShuffle();
        } else if (status == AnimationStatus.dismissed) {
          _shakeController.forward();
          _advanceShuffle();
        }
      }
    });

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _revealScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeOutBack),
    );
    _revealOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _displayedRoll = widget.gameState.lastRoll;
    if (_displayedRoll != null) {
      _revealController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(DiceCenter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gameState.lastRoll == null && _displayedRoll != null) {
      _displayedRoll = null;
      _revealController.reset();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _advanceShuffle() {
    if (!_isRolling) return;
    setState(() {
      _shuffleIndex++;
    });
  }

  Future<void> _handleRoll() async {
    setState(() {
      _isRolling = true;
      _displayedRoll = null;
      _shuffleIndex = 0;
    });
    _revealController.reset();
    _shakeController.forward();

    await Future.delayed(const Duration(milliseconds: 600));

    widget.onRoll();

    setState(() {
      _isRolling = false;
    });
    _shakeController.stop();
    _shakeController.reset();

    setState(() {
      _displayedRoll = widget.gameState.lastRoll;
    });
    _revealController.forward();
  }

  bool get _canRoll =>
      widget.gameState.lastRoll == null && !_isRolling && !widget.isAiTurn;
  bool get _canEndTurn =>
      widget.gameState.lastRoll != null && !_isRolling && !widget.isAiTurn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentPlayer = widget.gameState.currentPlayer!;
    final playerColor = currentPlayer.color;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current player indicator — prominent with color + name
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: playerColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: playerColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: playerColor.withValues(alpha: 0.15),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isAiTurn)
                    Icon(Icons.smart_toy, size: 18, color: playerColor)
                  else
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: playerColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "${currentPlayer.name}'s Turn",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: playerColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // AI thinking indicator
            if (widget.isAiTurn && widget.gameState.isAiThinking) ...[
              const SizedBox(height: 8),
              _AiThinkingIndicator(color: playerColor),
            ],
            const SizedBox(height: 16),

            // Dice display area
            if (_isRolling) _buildRollingDice(),
            if (!_isRolling && _displayedRoll != null)
              _buildRevealedDice(_displayedRoll!),

            if (!_isRolling && _displayedRoll == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Tap to roll the dice!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFFE0E0E0)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ),

            // Result label showing what was gained
            if (!_isRolling && _displayedRoll != null) ...[
              const SizedBox(height: 12),
              _buildResultLabel(theme),
            ],

            const SizedBox(height: 16),

            // Big Roll Dice button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _canRoll ? _handleRoll : null,
                icon: const Icon(Icons.casino, size: 24),
                label: Text(
                  'Roll Dice',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // End turn button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _canEndTurn ? widget.onEndTurn : null,
                icon: const Icon(Icons.skip_next, size: 22),
                label: const Text('End Turn', style: TextStyle(fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  disabledForegroundColor: theme.colorScheme.onSurface
                      .withValues(alpha: theme.brightness == Brightness.dark ? 0.6 : 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultLabel(ThemeData theme) {
    final event = widget.gameState.lastEvent;
    final roll = _displayedRoll!;

    final parts = <Widget>[];

    // Show what was bred
    if (event != null && event.bred.isNotEmpty) {
      for (final entry in event.bred.entries) {
        parts.add(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle, size: 16, color: Colors.green.shade700),
            const SizedBox(width: 2),
            Text(
              '${entry.value} ${entry.key.label}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ));
      }
    }

    // Show attacks
    if (roll.hasFox) {
      parts.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: SvgPicture.asset('assets/images/fox.svg', fit: BoxFit.contain),
          ),
          const SizedBox(width: 4),
          Text(
            event?.smallDogSacrificed == true ? 'Fox! Dog saved you' : 'Fox attack!',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ));
    }
    if (roll.hasWolf) {
      parts.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: SvgPicture.asset('assets/images/wolf.svg', fit: BoxFit.contain),
          ),
          const SizedBox(width: 4),
          Text(
            event?.bigDogSacrificed == true ? 'Wolf! Dog saved you' : 'Wolf attack!',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ));
    }

    if (parts.isEmpty) {
      // No breeding, no attacks
      parts.add(Text(
        'No match — nothing bred',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Result:',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: parts,
          ),
        ],
      ),
    );
  }

  Widget _buildRollingDice() {
    final greenFace = _greenFaces[_shuffleIndex % _greenFaces.length];
    final redFace = _redFaces[_shuffleIndex % _redFaces.length];

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _shakeAnimation.value,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DieResult(
                face: greenFace,
                color: const Color(0xFF2E7D32),
                label: 'Green',
              ),
              const SizedBox(width: 20),
              _DieResult(
                face: redFace,
                color: const Color(0xFFC62828),
                label: 'Red',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRevealedDice(DiceRollResult roll) {
    return AnimatedBuilder(
      animation: _revealController,
      builder: (context, child) {
        return Opacity(
          opacity: _revealOpacity.value,
          child: Transform.scale(
            scale: _revealScale.value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _DieResult(
                  face: roll.green,
                  color: const Color(0xFF2E7D32),
                  label: 'Green',
                ),
                const SizedBox(width: 20),
                _DieResult(
                  face: roll.red,
                  color: const Color(0xFFC62828),
                  label: 'Red',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DieResult extends StatelessWidget {
  const _DieResult({
    required this.face,
    required this.color,
    required this.label,
  });

  final DiceFace face;
  final Color color;
  final String label;

  String get _assetPath => switch (face) {
        DiceFace.rabbit => Animal.rabbit.assetPath,
        DiceFace.lamb => Animal.lamb.assetPath,
        DiceFace.pig => Animal.pig.assetPath,
        DiceFace.cow => Animal.cow.assetPath,
        DiceFace.horse => Animal.horse.assetPath,
        DiceFace.fox => 'assets/images/fox.svg',
        DiceFace.wolf => 'assets/images/wolf.svg',
      };

  bool get _isDanger => face == DiceFace.fox || face == DiceFace.wolf;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            border: _isDanger
                ? Border.all(color: Colors.red.shade300, width: 3)
                : null,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              _assetPath,
              width: 44,
              height: 44,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          face.name[0].toUpperCase() + face.name.substring(1),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Animated "AI is thinking..." indicator with pulsing dots.
class _AiThinkingIndicator extends StatefulWidget {
  const _AiThinkingIndicator({required this.color});

  final Color color;

  @override
  State<_AiThinkingIndicator> createState() => _AiThinkingIndicatorState();
}

class _AiThinkingIndicatorState extends State<_AiThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smart_toy, size: 16, color: widget.color),
            const SizedBox(width: 6),
            Text(
              'Thinking',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: widget.color,
              ),
            ),
            const SizedBox(width: 2),
            ...List.generate(3, (i) {
              final delay = i * 0.3;
              final phase = ((_controller.value + delay) % 1.0);
              final opacity = (0.3 + 0.7 * (phase < 0.5 ? phase * 2 : 2.0 - phase * 2)).clamp(0.3, 1.0);
              return Opacity(
                opacity: opacity,
                child: Text(
                  '.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

