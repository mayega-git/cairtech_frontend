import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/screen_header.dart';

/// Page placeholder pour les modules pas encore implémentés (Phase 5+).
class FeatureStubPage extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;
  final String? roadmap;

  const FeatureStubPage({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.roadmap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  RoundIconButton(
                    onTap: () => context.canPop()
                        ? context.pop()
                        : context.go('/home'),
                    child: const Icon(Icons.arrow_back, size: 16),
                  ),
                ],
              ),
            ),
            ScreenHeader(eyebrow: eyebrow, title: title),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.hair),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 32, color: AppColors.muted),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: AppTypography.sans(
                          size: 14,
                          color: AppColors.muted,
                          height: 1.5,
                        ),
                      ),
                      if (roadmap != null) ...[
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surface2,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(color: AppColors.hair),
                          ),
                          child: Text(
                            roadmap!.toUpperCase(),
                            style: AppTypography.mono(
                              size: 10,
                              letterSpacing: 1.4,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
