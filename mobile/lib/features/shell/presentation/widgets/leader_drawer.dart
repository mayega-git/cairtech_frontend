import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_bloc.dart';
import '../../../../core/auth/current_user.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/avatar.dart';
import '../../../../core/widgets/tag.dart';

/// Drawer latéral exposé aux leaders / admins.
///
/// Chaque entrée vérifie la permission correspondante (RBAC backend) avant
/// d'être affichée. Les routes pointent vers des pages qui pourront ne pas
/// encore exister à ce stade (Phase 2) — un placeholder s'affiche en attendant.
class LeaderDrawer extends StatelessWidget {
  final CurrentUser user;
  const LeaderDrawer({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    const items = <_LeaderEntry>[
      _LeaderEntry(
        icon: Icons.how_to_reg_outlined,
        label: 'Demandes d\'adhésion',
        route: AppRoutes.membershipRequests,
        permission: 'bbcms:membership-request:read',
      ),
      _LeaderEntry(
        icon: Icons.school_outlined,
        label: 'Gestion des Bible Clubs',
        route: AppRoutes.adminBibleClubs,
        permission: 'bbcms:bible-club:create',
      ),
      _LeaderEntry(
        icon: Icons.restart_alt_outlined,
        label: 'Reset annuel',
        route: AppRoutes.adminBibleClubs,
        permission: 'bbcms:bible-club:reset',
        tag: 'NATIONAL',
      ),
      _LeaderEntry(
        icon: Icons.event_outlined,
        label: 'Événements nationaux',
        route: AppRoutes.events,
        permission: 'bbcms:event:plan',
      ),
      _LeaderEntry(
        icon: Icons.send_outlined,
        label: 'Évangélisation',
        route: AppRoutes.evangelism,
        permission: 'bbcms:evangelism:program-create',
      ),
      _LeaderEntry(
        icon: Icons.menu_book,
        label: 'Discipulat',
        route: AppRoutes.discipleship,
        permission: 'bbcms:discipleship:assign',
      ),
      _LeaderEntry(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Finance',
        route: AppRoutes.finance,
        permission: 'bbcms:financial:contribution-create',
      ),
      _LeaderEntry(
        icon: Icons.campaign_outlined,
        label: 'Publications',
        route: AppRoutes.publications,
        permission: 'bbcms:publication:daily-verse',
      ),
      _LeaderEntry(
        icon: Icons.dashboard_outlined,
        label: 'Pilotage national',
        route: AppRoutes.nationalDashboard,
        permission: 'bbcms:dashboard:national',
      ),
    ];
    final visible =
        items.where((e) => user.hasPermission(e.permission)).toList();

    return Drawer(
      backgroundColor: AppColors.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── User card (dark hero) ─────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
            color: AppColors.ink,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Avatar(
                      name: user.displayName,
                      color: AppColors.gold,
                      size: AvatarSize.md,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('OUTILS DE LEADER',
                              style: AppTypography.eyebrow(
                                  color: Colors.white.withOpacity(0.55))),
                          const SizedBox(height: 2),
                          Text(
                            user.displayName,
                            style: AppTypography.sans(
                              size: 14,
                              weight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: user.roles
                      .take(3)
                      .map((r) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.15)),
                            ),
                            child: Text(
                              r.replaceAll('_', ' '),
                              style: AppTypography.mono(
                                size: 9,
                                color: Colors.white.withOpacity(0.8),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: visible.map((e) => _drawerItem(context, e)).toList(),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.lock_outline, size: 20, color: AppColors.muted),
            title: Text('Changer mon mot de passe',
                style: AppTypography.sans(size: 13)),
            onTap: () {
              Navigator.of(context).pop();
              context.push(AppRoutes.changePassword);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, size: 20, color: AppColors.danger),
            title: Text('Se déconnecter',
                style: AppTypography.sans(size: 13, color: AppColors.danger)),
            onTap: () {
              Navigator.of(context).pop();
              sl<AuthBloc>().add(const AuthLogoutRequested());
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, _LeaderEntry e) {
    return ListTile(
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.hair),
        ),
        child: Icon(e.icon, size: 16, color: AppColors.ink),
      ),
      title: Text(e.label,
          style: AppTypography.sans(size: 13.5, weight: FontWeight.w500)),
      trailing: e.tag == null
          ? const Icon(Icons.chevron_right, size: 18, color: AppColors.muted2)
          : TagX(e.tag!, kind: TagKind.accent),
      onTap: () {
        Navigator.of(context).pop();
        context.push(e.route);
      },
    );
  }
}

class _LeaderEntry {
  final IconData icon;
  final String label;
  final String route;
  final String permission;
  final String? tag;

  const _LeaderEntry({
    required this.icon,
    required this.label,
    required this.route,
    required this.permission,
    this.tag,
  });
}
