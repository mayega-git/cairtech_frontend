import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/bar_progress.dart';
import '../../../core/widgets/chip_x.dart';
import '../../../core/widgets/donut.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/sparkline.dart';
import '../../../core/widgets/tag.dart';

/// Galerie des composants atomiques implémentés en Phase 0.
///
/// Sert :
///   1. de page d'accueil temporaire post-login,
///   2. de référence visuelle pour valider le rendu vs le design,
///   3. de smoke test des fonts Google Fonts (Cormorant Garamond / Inter / JetBrains Mono).
class WidgetGalleryPage extends StatelessWidget {
  const WidgetGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ScreenHeader(
                eyebrow: 'BBCMS · GALLERIE',
                title: 'Composants atomiques',
                subtitle: 'Phase 0 — validation visuelle',
                actions: [
                  RoundIconButton(
                    onTap: () => sl<AuthBloc>().add(const AuthLogoutRequested()),
                    child: const Icon(Icons.logout, size: 16),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  _section('Tags'),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: const [
                      TagX('default'),
                      TagX('success', kind: TagKind.success),
                      TagX('warn', kind: TagKind.warn),
                      TagX('accent', kind: TagKind.accent),
                      TagX('ink', kind: TagKind.ink),
                      TagX('danger', kind: TagKind.danger),
                      TagX('avec icône', kind: TagKind.success, icon: Icons.trending_up),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _section('Avatars'),
                  Row(
                    children: const [
                      Avatar(name: 'Jean Kabongo', size: AvatarSize.sm),
                      SizedBox(width: 12),
                      Avatar(name: 'Marie Lukombo', color: AppColors.gold),
                      SizedBox(width: 12),
                      Avatar(name: 'Pasteur Mwamba', size: AvatarSize.lg, color: AppColors.accent),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _section('Round icon buttons'),
                  Row(
                    children: [
                      RoundIconButton(child: const Icon(Icons.search, size: 15), onTap: () {}),
                      const SizedBox(width: 6),
                      RoundIconButton(
                          child: const Icon(Icons.notifications_outlined, size: 15),
                          hasBadge: true,
                          onTap: () {}),
                      const SizedBox(width: 6),
                      RoundIconButton(
                          child: const Icon(Icons.filter_list, size: 14), onTap: () {}),
                      const SizedBox(width: 6),
                      RoundIconButton(child: const Icon(Icons.add, size: 16), onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _section('Donut & barres'),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Donut(
                        value: 0.87,
                        size: 82,
                        stroke: 8,
                        child: Text('87%', style: AppTypography.mono(size: 11)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('L1 · Initiation', style: AppTypography.sans(size: 13)),
                            const SizedBox(height: 6),
                            const BarProgress(value: 0.85),
                            const SizedBox(height: 14),
                            Text('L2 · Affermissement', style: AppTypography.sans(size: 13)),
                            const SizedBox(height: 6),
                            const BarProgress(value: 0.72, color: AppColors.accent),
                            const SizedBox(height: 14),
                            Text('L3 · Engagement', style: AppTypography.sans(size: 13)),
                            const SizedBox(height: 6),
                            const BarProgress(value: 0.81, color: AppColors.gold),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _section('KPI grid'),
                  Row(
                    children: const [
                      Expanded(
                        child: KpiCard(
                          label: 'Membres actifs',
                          value: '142',
                          subtitle: '+6 ce mois',
                          icon: Icons.group_outlined,
                          accent: AppColors.positive,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: KpiCard(
                          label: 'Fidélité moy.',
                          value: '78%',
                          subtitle: 'Cible 80',
                          icon: Icons.trending_up,
                          accent: AppColors.warn,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Expanded(
                        child: KpiCard(
                          label: 'Réunions tenues',
                          value: '42',
                          subtitle: 'sur 48 prévues',
                          icon: Icons.event_outlined,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: KpiCard(
                          label: 'Inactifs (>4 sem.)',
                          value: '11',
                          subtitle: 'Suivi requis',
                          icon: Icons.access_time,
                          accent: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _section('Sparkline'),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.hair),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('MOY. 12 SEM.', style: AppTypography.mono(size: 9, letterSpacing: 1.3)),
                                const SizedBox(height: 2),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text('87%', style: AppTypography.serif(size: 28)),
                                    const SizedBox(width: 6),
                                    Text('+12 pts',
                                        style: AppTypography.sans(
                                            size: 11, color: AppColors.positive)),
                                  ],
                                ),
                              ],
                            ),
                            const TagX('HEBDO'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Sparkline(
                          data: [62, 64, 70, 68, 73, 78, 82, 80, 84, 87, 91, 88],
                          height: 64,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _section('Chips filtre'),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: const [
                      ChipX('Toutes', active: true),
                      ChipX('À venir'),
                      ChipX('En cours'),
                      ChipX('Tenues'),
                      ChipX('Études'),
                      ChipX('Prière'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _section('Boutons'),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Text('Se connecter'), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 14)],
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthBloc, AuthState>(
                    bloc: sl<AuthBloc>(),
                    builder: (context, state) {
                      if (state is AuthAuthenticated) {
                        final u = state.user;
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.ink,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SESSION JWT',
                                  style: AppTypography.eyebrow(color: Colors.white.withOpacity(0.55))),
                              const SizedBox(height: 6),
                              Text(u.email, style: AppTypography.sans(size: 15, color: Colors.white)),
                              const SizedBox(height: 4),
                              Text('Type: ${u.userType}',
                                  style: AppTypography.mono(size: 11, color: Colors.white.withOpacity(0.7))),
                              Text('${u.permissions.length} permissions',
                                  style: AppTypography.mono(size: 11, color: Colors.white.withOpacity(0.7))),
                              Text('${u.roles.length} rôles',
                                  style: AppTypography.mono(size: 11, color: Colors.white.withOpacity(0.7))),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String label) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: Text(
          label.toUpperCase(),
          style: AppTypography.mono(size: 10, letterSpacing: 1.4),
        ),
      );
}
