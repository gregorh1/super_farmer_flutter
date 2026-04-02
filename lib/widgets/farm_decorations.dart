import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A CustomPainter that draws a wooden plank border/frame around its child.
class WoodenBorderPainter extends CustomPainter {
  WoodenBorderPainter({
    this.borderWidth = 4.0,
    this.cornerRadius = 12.0,
    this.woodColor,
    this.darkWoodColor,
  });

  final double borderWidth;
  final double cornerRadius;
  final Color? woodColor;
  final Color? darkWoodColor;

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = woodColor ?? const Color(0xFF8D6E63);
    final darkColor = darkWoodColor ?? const Color(0xFF5D4037);

    final outerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(cornerRadius),
    );
    final innerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        borderWidth,
        borderWidth,
        size.width - borderWidth * 2,
        size.height - borderWidth * 2,
      ),
      Radius.circular(math.max(0, cornerRadius - borderWidth)),
    );

    // Base wood color
    final borderPaint = Paint()..color = baseColor;
    canvas.drawDRRect(outerRect, innerRect, borderPaint);

    // Wood grain lines
    final grainPaint = Paint()
      ..color = darkColor.withValues(alpha: 0.3)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Horizontal grain on top and bottom
    for (double y = 1; y < borderWidth - 1; y += 1.5) {
      canvas.drawLine(
        Offset(cornerRadius, y),
        Offset(size.width - cornerRadius, y),
        grainPaint,
      );
      canvas.drawLine(
        Offset(cornerRadius, size.height - y),
        Offset(size.width - cornerRadius, size.height - y),
        grainPaint,
      );
    }

    // Vertical grain on left and right
    for (double x = 1; x < borderWidth - 1; x += 1.5) {
      canvas.drawLine(
        Offset(x, cornerRadius),
        Offset(x, size.height - cornerRadius),
        grainPaint,
      );
      canvas.drawLine(
        Offset(size.width - x, cornerRadius),
        Offset(size.width - x, size.height - cornerRadius),
        grainPaint,
      );
    }

    // Corner nail dots
    final nailPaint = Paint()..color = const Color(0xFF3E2723);
    const nailRadius = 1.5;
    final nailOffset = cornerRadius * 0.6;
    canvas.drawCircle(Offset(nailOffset, nailOffset), nailRadius, nailPaint);
    canvas.drawCircle(
        Offset(size.width - nailOffset, nailOffset), nailRadius, nailPaint);
    canvas.drawCircle(Offset(nailOffset, size.height - nailOffset), nailRadius,
        nailPaint);
    canvas.drawCircle(
        Offset(size.width - nailOffset, size.height - nailOffset),
        nailRadius,
        nailPaint);
  }

  @override
  bool shouldRepaint(covariant WoodenBorderPainter oldDelegate) =>
      borderWidth != oldDelegate.borderWidth ||
      cornerRadius != oldDelegate.cornerRadius ||
      woodColor != oldDelegate.woodColor;
}

/// A widget that wraps its child in a wooden frame.
class WoodenFrame extends StatelessWidget {
  const WoodenFrame({
    super.key,
    required this.child,
    this.borderWidth = 4.0,
    this.cornerRadius = 12.0,
    this.woodColor,
    this.darkWoodColor,
  });

  final Widget child;
  final double borderWidth;
  final double cornerRadius;
  final Color? woodColor;
  final Color? darkWoodColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WoodenBorderPainter(
        borderWidth: borderWidth,
        cornerRadius: cornerRadius,
        woodColor: woodColor,
        darkWoodColor: darkWoodColor,
      ),
      child: Padding(
        padding: EdgeInsets.all(borderWidth),
        child: child,
      ),
    );
  }
}

/// A CustomPainter that draws a simple fence along the bottom.
class FencePainter extends CustomPainter {
  FencePainter({this.fenceColor, this.picketSpacing = 12.0});

  final Color? fenceColor;
  final double picketSpacing;

  @override
  void paint(Canvas canvas, Size size) {
    final color = fenceColor ?? const Color(0xFFBCAAA4);
    final paint = Paint()..color = color;
    final darkPaint = Paint()..color = color.withValues(alpha: 0.6);

    final fenceHeight = 16.0;
    final bottom = size.height;
    final top = bottom - fenceHeight;

    // Horizontal rails
    canvas.drawRect(
      Rect.fromLTWH(0, top + 3, size.width, 2.5),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, top + 10, size.width, 2.5),
      paint,
    );

    // Vertical pickets
    for (double x = 4; x < size.width; x += picketSpacing) {
      final picketRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, top, 3, fenceHeight),
        const Radius.circular(1),
      );
      canvas.drawRRect(picketRect, darkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant FencePainter oldDelegate) =>
      fenceColor != oldDelegate.fenceColor;
}

/// Subtle hay/grass texture along the bottom of a container.
class HayTexturePainter extends CustomPainter {
  HayTexturePainter({this.color, this.seed = 42});

  final Color? color;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = color ?? const Color(0xFFDCE775);
    final rng = math.Random(seed);
    final paint = Paint()
      ..color = baseColor.withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final bottom = size.height;
    for (double x = 2; x < size.width; x += 4 + rng.nextDouble() * 3) {
      final height = 4 + rng.nextDouble() * 6;
      final lean = (rng.nextDouble() - 0.5) * 4;
      canvas.drawLine(
        Offset(x, bottom),
        Offset(x + lean, bottom - height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant HayTexturePainter oldDelegate) =>
      color != oldDelegate.color || seed != oldDelegate.seed;
}

/// A splash screen barn SVG as a CustomPainter (simple geometric barn shape).
class BarnPainter extends CustomPainter {
  BarnPainter({this.barnColor, this.roofColor});

  final Color? barnColor;
  final Color? roofColor;

  @override
  void paint(Canvas canvas, Size size) {
    final barn = barnColor ?? const Color(0xFFC62828);
    final roof = roofColor ?? const Color(0xFF5D4037);
    final white = const Color(0xFFF5F5F5);
    final cx = size.width / 2;

    // Barn body
    final bodyRect = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.4,
      size.width * 0.7,
      size.height * 0.55,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(4)),
      Paint()..color = barn,
    );

    // Roof (triangle)
    final roofPath = Path()
      ..moveTo(cx, size.height * 0.1)
      ..lineTo(size.width * 0.08, size.height * 0.42)
      ..lineTo(size.width * 0.92, size.height * 0.42)
      ..close();
    canvas.drawPath(roofPath, Paint()..color = roof);

    // Cross boards on barn
    final crossPaint = Paint()
      ..color = barn.withValues(alpha: 0.7)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(bodyRect.left + 4, bodyRect.top + 4),
      Offset(bodyRect.right - 4, bodyRect.bottom - 4),
      crossPaint,
    );
    canvas.drawLine(
      Offset(bodyRect.right - 4, bodyRect.top + 4),
      Offset(bodyRect.left + 4, bodyRect.bottom - 4),
      crossPaint,
    );

    // Barn door (double doors)
    final doorWidth = size.width * 0.22;
    final doorHeight = size.height * 0.34;
    final doorLeft = cx - doorWidth;
    final doorTop = size.height * 0.61;
    // Left door
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(doorLeft, doorTop, doorWidth - 1, doorHeight),
        topLeft: Radius.circular(doorWidth),
      ),
      Paint()..color = white,
    );
    // Right door
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(cx + 1, doorTop, doorWidth - 1, doorHeight),
        topRight: Radius.circular(doorWidth),
      ),
      Paint()..color = white,
    );

    // Hay loft window
    final loftCenter = Offset(cx, size.height * 0.32);
    canvas.drawCircle(loftCenter, size.width * 0.06, Paint()..color = white);
    // Window cross
    canvas.drawLine(
      Offset(loftCenter.dx - size.width * 0.05, loftCenter.dy),
      Offset(loftCenter.dx + size.width * 0.05, loftCenter.dy),
      Paint()
        ..color = roof
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(loftCenter.dx, loftCenter.dy - size.width * 0.05),
      Offset(loftCenter.dx, loftCenter.dy + size.width * 0.05),
      Paint()
        ..color = roof
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant BarnPainter oldDelegate) =>
      barnColor != oldDelegate.barnColor || roofColor != oldDelegate.roofColor;
}
