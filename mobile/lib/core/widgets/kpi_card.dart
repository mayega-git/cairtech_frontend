import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

/// Card de KPI utilisée dans Dashboard Leader BBC.
class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color accent;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.subtitle,
    this.accent = AppColors.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.hair, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.lg - 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTypography.mono(
                  size: 9,
                  weight: FontWeight.w500,
                  color: AppColors.muted,
                  letterSpacing: 1.3,
                ),
              ),
              Icon(icon, size: 14, color: accent),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.serif(
                size: 32, weight: FontWeight.w400, height: 1, letterSpacing: -0.6),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppTypography.sans(size: 10.5, color: accent, weight: FontWeight.w400),
            ),
          ],
        ],
      ),
    );
  }
}
