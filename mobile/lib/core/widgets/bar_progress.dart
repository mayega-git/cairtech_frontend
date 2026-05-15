import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Barre de progression linéaire (default height 4).
class BarProgress extends StatelessWidget {
  final double value;
  final Color color;
  final Color track;
  final double height;
  final double radius;

  const BarProgress({
    super.key,
    required this.value,
    this.color = AppColors.ink,
    this.track = AppColors.hair,
    this.height = 4,
    this.radius = 2,
  });

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: double.infinity,
        height: height,
        color: track,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: v,
            child: Container(color: color),
          ),
        ),
      ),
    );
  }
}
