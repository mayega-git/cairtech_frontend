import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

/// Chip filtre (cf design `.chip` / `.chip.active`).
class ChipX extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const ChipX(
    this.label, {
    super.key,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.ink : AppColors.surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: active ? AppColors.ink : AppColors.hair,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            label,
            style: AppTypography.sans(
              size: 12,
              weight: FontWeight.w500,
              color: active ? Colors.white : AppColors.ink2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Section header avec titre + lien droite (cf design `.section-h`).
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.sans(
                size: 13,
                weight: FontWeight.w600,
                color: AppColors.ink,
                letterSpacing: -0.07,
              ),
            ),
          ),
          if (actionLabel != null)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  actionLabel!.toUpperCase(),
                  style: AppTypography.mono(
                    size: 10,
                    weight: FontWeight.w500,
                    color: AppColors.muted,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
