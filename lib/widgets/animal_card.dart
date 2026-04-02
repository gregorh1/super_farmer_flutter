import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/animal.dart';
import 'farm_decorations.dart';

/// Visual state of an animal card for attack/protection overlays.
enum AnimalVisualState {
  normal,
  attacked,
  protected,
}

class AnimalCard extends StatefulWidget {
  const AnimalCard({
    super.key,
    required this.animal,
    this.count,
    this.size = 80,
    this.visualState = AnimalVisualState.normal,
    this.enableIdleAnimation = false,
  });

  final Animal animal;
  final int? count;
  final double size;
  final AnimalVisualState visualState;
  final bool enableIdleAnimation;

  static const _animalBgColor = {
    Animal.rabbit: Color(0xFFF5F5F5),
    Animal.lamb: Color(0xFFFFF8E1),
    Animal.pig: Color(0xFFFCE4EC),
    Animal.cow: Color(0xFFEFEBE9),
    Animal.horse: Color(0xFFFFF3E0),
    Animal.smallDog: Color(0xFFFFF3E0),
    Animal.bigDog: Color(0xFFE8EAF6),
  };

  @override
  State<AnimalCard> createState() => _AnimalCardState();
}

class _AnimalCardState extends State<AnimalCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idleController;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 2000 + (widget.animal.index * 300),
      ),
    );
    if (widget.enableIdleAnimation) {
      _idleController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enableIdleAnimation && !_idleController.isAnimating) {
      _idleController.repeat(reverse: true);
    } else if (!widget.enableIdleAnimation && _idleController.isAnimating) {
      _idleController.stop();
      _idleController.value = 0;
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        AnimalCard._animalBgColor[widget.animal] ?? Colors.grey.shade100;
    final isAttacked = widget.visualState == AnimalVisualState.attacked;
    final isProtected = widget.visualState == AnimalVisualState.protected;

    return WoodenFrame(
      borderWidth: 3.0,
      cornerRadius: 10.0,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: isAttacked
              ? Color.lerp(bgColor, Colors.red.shade100, 0.4)
              : bgColor,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Stack(
          children: [
            // Hay texture at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 12,
              child: CustomPaint(
                painter: HayTexturePainter(
                  color: const Color(0xFFA5D6A7),
                  seed: widget.animal.index,
                ),
              ),
            ),
            // SVG icon with idle animation
            Center(
              child: AnimatedBuilder(
                animation: _idleController,
                builder: (context, child) {
                  final t = _idleController.value;
                  final bobOffset = widget.enableIdleAnimation
                      ? math.sin(t * math.pi) * 2.0
                      : 0.0;
                  final scaleBreath = widget.enableIdleAnimation
                      ? 1.0 + math.sin(t * math.pi) * 0.03
                      : 1.0;
                  return Transform.translate(
                    offset: Offset(0, -bobOffset),
                    child: Transform.scale(
                      scale: scaleBreath,
                      child: child,
                    ),
                  );
                },
                child: SizedBox(
                  width: widget.size * 0.55,
                  height: widget.size * 0.55,
                  child: SvgPicture.asset(
                    widget.animal.assetPath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Label
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Text(
                widget.animal.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: widget.size * 0.12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5D4037),
                ),
              ),
            ),
            // Count badge
            if (widget.count != null)
              Positioned(
                top: 2,
                right: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${widget.count}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            // Attack overlay (red tint + danger icon)
            if (isAttacked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: Colors.red.withValues(alpha: 0.15),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red.shade700.withValues(alpha: 0.6),
                      size: widget.size * 0.3,
                    ),
                  ),
                ),
              ),
            // Protected overlay (shield icon)
            if (isProtected)
              Positioned(
                top: 2,
                left: 4,
                child: Icon(
                  Icons.shield,
                  color: Colors.blue.shade600.withValues(alpha: 0.7),
                  size: widget.size * 0.22,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
