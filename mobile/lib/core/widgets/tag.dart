import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

/// Variantes du Tag (cf design Tag kinds: default/success/warn/accent/ink).
enum TagKind { defaultKind, success, warn, accent, ink, danger }

/// Pill mono-uppercase 10px utilisée pour les statuts et étiquettes.
class TagX extends StatelessWidget {
  final String label;
  final TagKind kind;
  final IconData? icon;

  const TagX(
    this.label, {
    super.key,
    this.kind = TagKind.defaultKind,
    this.icon,
  });

  ({Color bg, Color fg, Color border}) get _colors {
    return switch (kind) {
      TagKind.success => (
          bg: const Color(0xFFECF3EE),
          fg: AppColors.positive,
          border: const Color(0xFFD6E4DC),
        ),
      TagKind.warn => (
          bg: const Color(0xFFF8EEDF),
          fg: AppColors.warn,
          border: const Color(0xFFECDFC7),
        ),
      TagKind.accent => (
          bg: AppColors.accentSoft,
          fg: AppColors.accent,
          border: const Color(0xFFD2DFFE),
        ),
      TagKind.ink => (bg: AppColors.ink, fg: Colors.white, border: AppColors.ink),
      TagKind.danger => (
          bg: const Color(0xFFFCEAE7),
          fg: AppColors.danger,
          border: const Color(0xFFF1CDC8),
        ),
      TagKind.defaultKind => (
          bg: AppColors.hair2,
          fg: AppColors.ink2,
          border: AppColors.hair,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final c = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: c.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: c.fg),
            const SizedBox(width: 5),
          ],
          Text(
            label.toUpperCase(),
            style: AppTypography.mono(
                size: 10, weight: FontWeight.w500, color: c.fg, letterSpacing: 0.6),
          ),
        ],
      ),
    );
  }
}
