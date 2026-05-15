import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/round_icon_button.dart';

/// Barre supérieure: bouton retour, indicateur "ÉTAPE X / N", bouton fermeture.
class OnboardingTopBar extends StatelessWidget {
  final int step;
  final int total;
  final VoidCallback? onBack;
  final VoidCallback? onClose;

  const OnboardingTopBar({
    super.key,
    required this.step,
    required this.total,
    this.onBack,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RoundIconButton(
            onTap: onBack,
            child: const Icon(Icons.arrow_back, size: 16),
          ),
          Text(
            'ÉTAPE ${step.toString().padLeft(2, '0')} / ${total.toString().padLeft(2, '0')}',
            style: AppTypography.mono(
              size: 10,
              letterSpacing: 1.6,
              color: AppColors.muted,
            ),
          ),
          RoundIconButton(
            onTap: onClose,
            child: const Icon(Icons.close, size: 14),
          ),
        ],
      ),
    );
  }
}

/// 4 segments horizontaux représentant la progression du wizard.
class StepProgress extends StatelessWidget {
  final int step;
  final int total;
  const StepProgress({super.key, required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Row(
        children: List.generate(total, (i) {
          final filled = i < step;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i == total - 1 ? 0 : 4),
              height: 3,
              decoration: BoxDecoration(
                color: filled ? AppColors.ink : AppColors.hair,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
