import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Donut SVG (CustomPainter) avec slot central.
class Donut extends StatelessWidget {
  final double value;
  final double size;
  final double stroke;
  final Color color;
  final Color track;
  final Widget? child;

  const Donut({
    super.key,
    required this.value,
    this.size = 120,
    this.stroke = 8,
    this.color = AppColors.ink,
    this.track = AppColors.hair,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _DonutPainter(
              value: value.clamp(0.0, 1.0),
              stroke: stroke,
              color: color,
              track: track,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double value;
  final double stroke;
  final Color color;
  final Color track;

  _DonutPainter({
    required this.value,
    required this.stroke,
    required this.color,
    required this.track,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = (size.width - stroke) / 2;
    final center = Offset(size.width / 2, size.height / 2);

    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, r, trackPaint);

    if (value > 0) {
      final arcPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;

      final sweep = 2 * math.pi * value;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        -math.pi / 2,
        sweep,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.value != value ||
      old.color != color ||
      old.track != track ||
      old.stroke != stroke;
}
