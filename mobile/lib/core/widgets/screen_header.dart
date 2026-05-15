import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Header type plate-forme (cf design ScreenHeader).
class ScreenHeader extends StatelessWidget {
  final String? eyebrow;
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool dense;
  final bool dark;
  final EdgeInsets? padding;

  const ScreenHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.actions = const [],
    this.dense = false,
    this.dark = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : AppColors.ink;
    final fgMuted = dark ? Colors.white.withOpacity(0.55) : AppColors.muted;

    return Container(
      color: dark ? AppColors.ink : Colors.transparent,
      padding: padding ??
          EdgeInsets.fromLTRB(
            20,
            dense ? 14 : 18,
            20,
            dense ? 10 : 14,
          ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      eyebrow!.toUpperCase(),
                      style: AppTypography.eyebrow(color: fgMuted),
                    ),
                  ),
                Text(
                  title,
                  style: AppTypography.sans(
                    size: dense ? 17 : 22,
                    weight: dense ? FontWeight.w600 : FontWeight.w500,
                    color: fg,
                    letterSpacing: -0.33,
                    height: 1.15,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTypography.sans(size: 12, color: fgMuted),
                  ),
                ],
              ],
            ),
          ),
          if (actions.isNotEmpty)
            Row(
              children: [
                for (final a in actions) ...[
                  a,
                  const SizedBox(width: 6),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
