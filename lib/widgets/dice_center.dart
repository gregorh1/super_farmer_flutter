import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/animal.dart';
import '../models/dice.dart';
import '../providers/game_provider.dart';
import 'player_area.dart';

class DiceCenter extends StatefulWidget {
  const DiceCenter({
    super.key,
    required this.gameState,
    required this.onRoll,
    required this.onEndTurn,
  });

  final GameState gameState;
  final VoidCallback onRoll;
  final VoidCallback onEndTurn;

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

  // Shuffled faces for the rolling animation
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

    // Shake animation: rapid oscillation during roll
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

    // Reveal animation: bounce in after roll completes
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
    // When lastRoll is cleared (new turn), reset display
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
    // Start shaking
    setState(() {
      _isRolling = true;
      _displayedRoll = null;
      _shuffleIndex = 0;
    });
    _revealController.reset();
    _shakeController.forward();

    // Let the dice shake for a bit
    await Future.delayed(const Duration(milliseconds: 600));

    // Execute the actual roll
    widget.onRoll();

    // Stop shaking
    setState(() {
      _isRolling = false;
    });
    _shakeController.stop();
    _shakeController.reset();

    // Reveal the result with bounce
    setState(() {
      _displayedRoll = widget.gameState.lastRoll;
    });
    _revealController.forward();
  }

  bool get _canRoll => widget.gameState.lastRoll == null && !_isRolling;
  bool get _canEndTurn => widget.gameState.lastRoll != null && !_isRolling;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playerColor = PlayerArea
        .playerColors[widget.gameState.currentPlayerIndex % PlayerArea.playerColors.length];
    final currentPlayer = widget.gameState.currentPlayer!;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current player indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: playerColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: playerColor, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: playerColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      "${currentPlayer.name}'s Turn",
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: playerColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Dice area: rolling or results
            if (_isRolling) _buildRollingDice(),
            if (!_isRolling && _displayedRoll != null)
              _buildRevealedDice(_displayedRoll!),

            if (_isRolling || _displayedRoll != null) const SizedBox(height: 12),

            // Roll button
            FilledButton.icon(
              onPressed: _canRoll ? _handleRoll : null,
              icon: const Icon(Icons.casino, size: 20),
              label: const Text('Roll Dice'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // End turn button
            OutlinedButton.icon(
              onPressed: _canEndTurn ? widget.onEndTurn : null,
              icon: const Icon(Icons.skip_next, size: 18),
              label: const Text('End Turn'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
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
              const SizedBox(width: 12),
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
                const SizedBox(width: 12),
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
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: _isDanger
                ? Border.all(color: Colors.red.shade300, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              _assetPath,
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
