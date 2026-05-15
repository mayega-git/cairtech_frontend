import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../shell/presentation/app_shell.dart';

/// Onglet Accueil — affiche le dashboard adapté au rôle de l'utilisateur.
///
/// Phase 2 : page d'accueil unifiée avec greeting + accès aux outils leader
/// via le drawer. Les dashboards spécifiques (member / leader / national)
/// seront branchés en Phase 3.
class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      bloc: sl<AuthBloc>(),
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        final isNational = user?.hasPermission('bbcms:dashboard:national') ?? false;
        final isLeader = user?.hasPermission('bbcms:dashboard:bbc') ?? false;
        return Column(
          children: [
            HomeGreetingHeader(
              actions: [
                RoundIconButton(
                    onTap: () {}, child: const Icon(Icons.search, size: 15)),
                const SizedBox(width: 6),
                RoundIconButton(
                  onTap: () {},
                  hasBadge: true,
                  child: const Icon(Icons.notifications_outlined, size: 15),
                ),
              ],
            ),
            Expanded(
              child: _PlaceholderDashboard(
                kind: isNational
                    ? _Kind.national
                    : isLeader
                        ? _Kind.leader
                        : _Kind.member,
              ),
            ),
          ],
        );
      },
    );
  }
}

enum _Kind { member, leader, national }

class _PlaceholderDashboard extends StatelessWidget {
  final _Kind kind;
  const _PlaceholderDashboard({required this.kind});

  ({String title, String subtitle, IconData icon}) get _info => switch (kind) {
        _Kind.member => (
            title: 'Mon parcours de fidélité',
            subtitle:
                'Score de fidélité, prochaine réunion, actions rapides — branché en Phase 3.',
            icon: Icons.trending_up,
          ),
        _Kind.leader => (
            title: 'Tableau de bord BBC',
            subtitle:
                'KPI membres actifs, fidélité, réunions, veille d\'inactivité — Phase 3.',
            icon: Icons.dashboard_outlined,
          ),
        _Kind.national => (
            title: 'Pilotage national CHF',
            subtitle:
                'Total membres, classement BBC, carte des provinces — Phase 3.',
            icon: Icons.public,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final i = _info;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.hair),
                shape: BoxShape.circle,
              ),
              child: Icon(i.icon, size: 28, color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            Text(i.title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              i.subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
