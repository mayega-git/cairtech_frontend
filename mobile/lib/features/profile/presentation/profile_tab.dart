import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/tag.dart';

/// Onglet Profil — version Phase 2 : identité, sessions, paramètres rapides,
/// déconnexion. La carte de membre QR + paramètres avancés seront ajoutés en
/// Phase 10.
class ProfileTabPage extends StatelessWidget {
  const ProfileTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      bloc: sl<AuthBloc>(),
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Center(child: CircularProgressIndicator());
        }
        final u = state.user;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ScreenHeader(
                eyebrow: 'MON COMPTE',
                title: 'Profil',
              ),
              // Identity card
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.hair),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Column(
                    children: [
                      Avatar(
                        name: u.displayName,
                        color: AppColors.ink,
                        size: AvatarSize.lg,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        u.displayName,
                        style: AppTypography.serif(size: 26, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        u.email,
                        style: AppTypography.mono(
                            size: 11, color: AppColors.muted, letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: [
                          TagX(u.userType, kind: TagKind.ink),
                          ...u.roles
                              .where((r) => r != 'STUDENT' && r != 'PROFESSIONAL')
                              .take(3)
                              .map((r) => TagX(r.replaceAll('_', ' '),
                                  kind: TagKind.accent)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Statistiques rapides
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _stat('Permissions', '${u.permissions.length}'),
                      _stat('Rôles', '${u.roles.length}'),
                      if (u.bibleClubId != null) _stat('BBC', '✓') else _stat('BBC', '—'),
                    ],
                  ),
                ),
              ),

              // Settings list
              _settingsList(context, u.email),

              const SizedBox(height: 20),

              // Logout
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.hair),
                    ),
                    onPressed: () =>
                        sl<AuthBloc>().add(const AuthLogoutRequested()),
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Se déconnecter'),
                  ),
                ),
              ),

              Center(
                child: Text(
                  'BBCMS · v1.0 · CHF',
                  style: AppTypography.mono(
                      size: 9,
                      color: AppColors.muted2,
                      letterSpacing: 1.6),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.serif(
              size: 22, color: Colors.white, letterSpacing: -0.4),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: AppTypography.mono(
              size: 9, color: Colors.white.withOpacity(0.55), letterSpacing: 1.4),
        ),
      ],
    );
  }

  Widget _settingsList(BuildContext context, String email) {
    final items = <_SettingItem>[
      _SettingItem(
        icon: Icons.lock_outline,
        label: 'Changer mon mot de passe',
        onTap: () => context.push(AppRoutes.changePassword),
      ),
      _SettingItem(
        icon: Icons.notifications_outlined,
        label: 'Notifications',
        trailing: 'À VENIR',
        onTap: () => _toast(context, 'Disponible en Phase 10'),
      ),
      _SettingItem(
        icon: Icons.translate,
        label: 'Langue',
        trailing: 'Français',
        onTap: () => _toast(context, 'Disponible en Phase 12'),
      ),
      _SettingItem(
        icon: Icons.sync,
        label: 'Synchronisation',
        trailing: 'À VENIR',
        onTap: () => _toast(context, 'Mode hors-ligne V2'),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.hair),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              _SettingRow(item: items[i]),
              if (i < items.length - 1)
                const Divider(height: 1, color: AppColors.hair2),
            ],
          ],
        ),
      ),
    );
  }

  void _toast(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

class _SettingItem {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;
  const _SettingItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });
}

class _SettingRow extends StatelessWidget {
  final _SettingItem item;
  const _SettingRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: item.onTap,
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.hair),
        ),
        child: Icon(item.icon, size: 16, color: AppColors.ink),
      ),
      title: Text(item.label,
          style: AppTypography.sans(size: 13.5, weight: FontWeight.w500)),
      trailing: item.trailing == null
          ? const Icon(Icons.chevron_right, size: 18, color: AppColors.muted2)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item.trailing!,
                    style: AppTypography.mono(
                        size: 10,
                        color: AppColors.muted,
                        letterSpacing: 1.2)),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, size: 18, color: AppColors.muted2),
              ],
            ),
    );
  }
}
