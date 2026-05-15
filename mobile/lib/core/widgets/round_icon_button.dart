import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Cercle 36px avec icon, bordure hairline. Variante dark = sur fond ink.
class RoundIconButton extends StatelessWidget {
  final Widget child;
  final bool dark;
  final double size;
  final VoidCallback? onTap;
  final bool hasBadge;

  const RoundIconButton({
    super.key,
    required this.child,
    this.dark = false,
    this.size = 36,
    this.onTap,
    this.hasBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: dark ? Colors.white.withOpacity(0.04) : AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: dark ? Colors.white.withOpacity(0.16) : AppColors.hair,
                width: 1,
              ),
            ),
            child: IconTheme(
              data: IconThemeData(
                color: dark
                    ? Colors.white.withOpacity(0.85)
                    : AppColors.ink,
                size: 16,
              ),
              child: Center(child: child),
            ),
          ),
          if (hasBadge)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
