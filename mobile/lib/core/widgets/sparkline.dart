import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Mini courbe de tendance (path + fill + dernier point).
class Sparkline extends StatelessWidget {
  final List<double> data;
  final double height;
  final Color color;
  final Color fill;
  final double strokeWidth;

  const Sparkline({
    super.key,
    required this.data,
    this.height = 80,
    this.color = AppColors.ink,
    this.fill = const Color(0x0F0B0E1A),
    this.strokeWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(
          data: data,
          color: color,
          fill: fill,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final Color fill;
  final double strokeWidth;

  _SparklinePainter({
    required this.data,
    required this.color,
    required this.fill,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final max = data.reduce((a, b) => a > b ? a : b);
    final min = data.reduce((a, b) => a < b ? a : b);
    final range = (max - min) == 0 ? 1.0 : (max - min);
    final step = size.width / (data.length - 1);

    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i * step;
      final y = size.height - ((data[i] - min) / range) * (size.height - 8) - 4;
      points.add(Offset(x, y));
    }

    // Fill path
    final fillPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()..color = fill,
    );

    // Stroke path
    final strokePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      strokePath.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      strokePath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeJoin = StrokeJoin.round,
    );

    // Last point dot
    canvas.drawCircle(
      points.last,
      3,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.data != data || old.color != color || old.fill != fill;
}
