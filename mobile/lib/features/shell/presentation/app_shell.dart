import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/auth/current_user.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/avatar.dart';
import 'widgets/leader_drawer.dart';

/// Coquille de l'application authentifiée — Scaffold avec TabBar bas (5 onglets)
/// et drawer latéral pour les leaders.
///
/// Le contenu de chaque onglet est déterminé par [StatefulShellRoute] qui
/// préserve l'état de chaque tab (lazy + indexedStack).
class AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const AppShell({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      bloc: sl<AuthBloc>(),
      builder: (context, authState) {
        final CurrentUser? user =
            authState is AuthAuthenticated ? authState.user : null;
        final hasLeaderTools = user != null && _hasAnyLeaderPermission(user);

        return Scaffold(
          backgroundColor: AppColors.bg,
          drawer: hasLeaderTools ? LeaderDrawer(user: user) : null,
          body: SafeArea(
            top: false,
            child: shell,
          ),
          bottomNavigationBar: _BottomNav(
            currentIndex: shell.currentIndex,
            onSelect: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
          ),
        );
      },
    );
  }

  bool _hasAnyLeaderPermission(CurrentUser u) {
    return u.hasAnyPermission(const [
      'bbcms:bible-club:create',
      'bbcms:bible-club:reset',
      'bbcms:membership-request:approve',
      'bbcms:meeting:plan',
      'bbcms:financial:contribution-create',
      'bbcms:evangelism:program-create',
      'bbcms:discipleship:assign',
      'bbcms:intercession:chain-manage',
      'bbcms:publication:daily-verse',
      'bbcms:publication:announcement',
      'bbcms:event:plan',
      'bbcms:dashboard:bbc',
      'bbcms:dashboard:national',
    ]);
  }
}

/// Bottom navigation bar — 5 onglets fixes (Accueil / Réunions / Membres /
/// Spirituel / Profil) — cf design styles.css `.tabbar`.
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const _BottomNav({required this.currentIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Tab(icon: Icons.home_outlined, label: 'Accueil'),
      _Tab(icon: Icons.calendar_today_outlined, label: 'Réunions'),
      _Tab(icon: Icons.group_outlined, label: 'Membres'),
      _Tab(icon: Icons.menu_book_outlined, label: 'Spirituel'),
      _Tab(icon: Icons.person_outline, label: 'Profil'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.hair)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < items.length; i++)
                Expanded(
                  child: _NavItem(
                    tab: items[i],
                    active: i == currentIndex,
                    onTap: () => onSelect(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab {
  final IconData icon;
  final String label;
  _Tab({required this.icon, required this.label});
}

class _NavItem extends StatelessWidget {
  final _Tab tab;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.ink : AppColors.muted2;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(tab.icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              tab.label,
              style: AppTypography.sans(
                size: 10,
                color: color,
                weight: FontWeight.w500,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Header personnel utilisé en haut des onglets — avatar + greeting + bell.
/// Utilisé par défaut dans les pages stub mais peut être surchargé par les
/// phases ultérieures (dashboards customisés).
class HomeGreetingHeader extends StatelessWidget {
  final String? subtitleOverride;
  final List<Widget> actions;
  final bool showMenu;

  const HomeGreetingHeader({
    super.key,
    this.subtitleOverride,
    this.actions = const [],
    this.showMenu = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      bloc: sl<AuthBloc>(),
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        final firstName = user?.firstNames ?? '';
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (showMenu && (Scaffold.maybeOf(context)?.hasDrawer ?? false))
                    IconButton(
                      icon: const Icon(Icons.menu, size: 20),
                      color: AppColors.ink,
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    )
                  else
                    Avatar(
                      name: user?.displayName ?? '?',
                      size: AvatarSize.md,
                    ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subtitleOverride ?? _greeting(),
                        style: AppTypography.eyebrow(),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Bonjour, $firstName',
                        style: AppTypography.sans(
                          size: 15,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(children: actions),
            ],
          ),
        );
      },
    );
  }

  String _greeting() {
    final now = DateTime.now();
    const days = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi',
      'Vendredi', 'Samedi', 'Dimanche'
    ];
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return '$dayName ${now.day} $monthName · $time';
  }
}

/// Utilitaire — wrapper de fallback pour les pages encore non-implémentées.
class PlaceholderTab extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget>? actions;
  const PlaceholderTab({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HomeGreetingHeader(actions: actions ?? const []),
        Expanded(
          child: Center(
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
                    child: Icon(icon, size: 28, color: AppColors.muted),
                  ),
                  const SizedBox(height: 16),
                  Text(title,
                      style: AppTypography.serif(size: 26, letterSpacing: -0.5),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: AppTypography.sans(
                        size: 13, color: AppColors.muted, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.hair2,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'À VENIR — PHASE ULTÉRIEURE',
                      style: AppTypography.mono(
                          size: 10,
                          letterSpacing: 1.4,
                          color: AppColors.muted),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
