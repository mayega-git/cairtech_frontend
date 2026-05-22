import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/api/api_config.dart';
import '../../../core/auth/auth_bloc.dart';
import '../../../core/auth/current_user.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/tag.dart';
import '../../members/data/member_repository.dart';
import '../../members/data/member_with_profile_dto.dart';

/// Profil utilisateur enrichi (Phase 10) :
/// - Carte identité avec photo réelle (si pictureFileId)
/// - Carte membre digitale au format QR (style design)
/// - Stats personnelles (score fidélité, présences, déparTements)
/// - Liste de paramètres (langue, notifications, sync, sécurité, mot de passe)
/// - Logout
class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({super.key});

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  late final MemberRepository _memberRepo = MemberRepository(sl());
  Future<MemberWithProfileDto?>? _meFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final auth = sl<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      _meFuture = Future.value(null);
    } else {
      // findByUserAccount → on a memberId via /members/me … et /members/{id}/with-profile pour PII
      _meFuture = _loadMe();
    }
    setState(() {});
  }

  Future<MemberWithProfileDto?> _loadMe() async {
    try {
      final m = await _memberRepo.me();
      if (m == null) return null;
      return await _memberRepo.findByIdWithProfile(m.id);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      bloc: sl<AuthBloc>(),
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Center(child: CircularProgressIndicator());
        }
        return FutureBuilder<MemberWithProfileDto?>(
          future: _meFuture,
          builder: (context, snap) {
            return RefreshIndicator(
              onRefresh: () async => _reload(),
              child: ListView(
                children: [
                  const ScreenHeader(eyebrow: 'MON COMPTE', title: 'Profil'),
                  _identityCard(state.user, snap.data),
                  const SizedBox(height: 16),
                  _memberCard(state.user, snap.data),
                  const SizedBox(height: 16),
                  if (snap.data != null) _statsCard(snap.data!),
                  if (snap.data != null) const SizedBox(height: 16),
                  _settingsList(context),
                  const SizedBox(height: 20),
                  _logoutButton(),
                  const SizedBox(height: 16),
                  _footer(),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _identityCard(CurrentUser u, MemberWithProfileDto? me) {
    final pictureUrl = me?.pictureFileId != null
        ? '${ApiConfig.apiBase}/files/${me!.pictureFileId}/url'
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.hair),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          children: [
            _AvatarLarge(name: u.displayName, imageUrl: pictureUrl),
            const SizedBox(height: 12),
            Text(
              u.displayName,
              style: AppTypography.serif(size: 26, letterSpacing: -0.5),
              textAlign: TextAlign.center,
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
                TagX(_userTypeLabel(u.userType), kind: TagKind.ink),
                if (me?.kind == 'STUDENT' && me!.faithfulPercentage >= 50)
                  TagX('FIDÈLE · ${me.faithfulPercentage.round()}%',
                      kind: TagKind.success),
                if (me?.bibleClubId != null) const TagX('BBC ✓', kind: TagKind.accent),
                ...u.roles
                    .where((r) =>
                        r != 'STUDENT' &&
                        r != 'PROFESSIONAL' &&
                        r != 'VISITOR')
                    .take(2)
                    .map((r) =>
                        TagX(r.replaceAll('_', ' '), kind: TagKind.accent)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Carte membre style QR — reproduit le visuel "CARTE DE MEMBRE 2025/26"
  /// du design (screens-mission.jsx ProfileScreen).
  Widget _memberCard(CurrentUser u, MemberWithProfileDto? me) {
    if (me == null && u.userType != 'NATIONAL_LEADER') {
      // Pour un utilisateur sans member rattaché (visiteur en attente)
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface2,
            border: Border.all(color: AppColors.hair),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              const Icon(Icons.hourglass_empty,
                  size: 20, color: AppColors.muted),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Votre carte de membre sera disponible après validation '
                  'de votre demande d\'adhésion par un leader.',
                  style: AppTypography.sans(
                      size: 12, color: AppColors.muted, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final cardCode = _cardCode(u, me);
    final year = DateTime.now().month >= 9
        ? '${DateTime.now().year}/${(DateTime.now().year + 1).toString().substring(2)}'
        : '${DateTime.now().year - 1}/${DateTime.now().year.toString().substring(2)}';
    final validUntil = me?.kind == 'STUDENT'
        ? '30/09/${(DateTime.now().year + 1).toString().substring(2)}'
        : '—';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(AppRadius.xl - 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('CARTE DE MEMBRE',
                    style: AppTypography.eyebrow(
                        color: Colors.white.withOpacity(0.55))),
                Text(year,
                    style: AppTypography.mono(
                        size: 11,
                        color: Colors.white.withOpacity(0.55),
                        letterSpacing: 1.0)),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: QrImageView(
                    data: cardCode,
                    version: QrVersions.auto,
                    size: 96,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.ink,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u.displayName,
                        style: AppTypography.serif(
                            size: 18,
                            color: Colors.white,
                            letterSpacing: -0.3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cardCode,
                        style: AppTypography.mono(
                            size: 10,
                            color: Colors.white.withOpacity(0.7),
                            letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 10),
                      Text('VALIDE JUSQU\'AU',
                          style: AppTypography.mono(
                              size: 8,
                              color: Colors.white.withOpacity(0.5),
                              letterSpacing: 1.2)),
                      const SizedBox(height: 1),
                      Text(validUntil,
                          style: AppTypography.serif(
                              size: 16,
                              color: Colors.white,
                              letterSpacing: -0.2)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('CHF · BBCMS',
                      style: AppTypography.mono(
                          size: 9,
                          color: Colors.white.withOpacity(0.45),
                          letterSpacing: 1.6)),
                  Text(_userTypeLabel(u.userType).toUpperCase(),
                      style: AppTypography.mono(
                          size: 9,
                          color: Colors.white.withOpacity(0.7),
                          letterSpacing: 1.6)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsCard(MemberWithProfileDto me) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.hair),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Expanded(
                child:
                    _stat('FIDÉLITÉ', '${me.faithfulPercentage.round()}%')),
            Expanded(child: _stat('SCORE', '${me.participationScore}')),
            Expanded(child: _stat('DÉPT.', '${me.departments.length}')),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTypography.mono(
                  size: 9, color: AppColors.muted, letterSpacing: 1.3)),
          const SizedBox(height: 2),
          Text(value,
              style: AppTypography.serif(size: 20, letterSpacing: -0.3)),
        ],
      );

  Widget _settingsList(BuildContext context) {
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
        onTap: () => _toast(context, 'Disponible en Phase 12'),
      ),
      _SettingItem(
        icon: Icons.translate,
        label: 'Langue',
        trailing: 'Français',
        onTap: () => _toast(context, 'Disponible en Phase 12'),
      ),
      _SettingItem(
        icon: Icons.sync,
        label: 'Synchronisation hors-ligne',
        trailing: 'V2',
        onTap: () => _toast(context, 'Sync offline disponible en V2'),
      ),
      _SettingItem(
        icon: Icons.policy_outlined,
        label: 'Données & confidentialité',
        trailing: 'RGPD',
        onTap: () => _toast(context, 'Anonymisation à 24 mois après suppression'),
      ),
      _SettingItem(
        icon: Icons.dashboard_customize_outlined,
        label: 'Galerie de composants',
        trailing: 'DEV',
        onTap: () => context.push(AppRoutes.gallery),
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

  Widget _logoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
    );
  }

  Widget _footer() {
    return Center(
      child: Text(
        'BBCMS · v1.0 · CHF',
        style: AppTypography.mono(
            size: 9, color: AppColors.muted2, letterSpacing: 1.6),
      ),
    );
  }

  String _cardCode(CurrentUser u, MemberWithProfileDto? me) {
    const prefix = 'BBCMS';
    final ref = me?.bibleClubId == null
        ? 'CHF'
        : me!.bibleClubId!.substring(0, 3).toUpperCase();
    final suffix = u.userId.substring(0, 4).toUpperCase();
    return '$prefix-$ref-$suffix';
  }

  String _userTypeLabel(String type) => switch (type) {
        'STUDENT' => 'Étudiant',
        'PROFESSIONAL' => 'Professionnel',
        'NATIONAL_LEADER' => 'Leader national',
        'VISITOR' => 'Visiteur',
        _ => type,
      };

  void _toast(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

class _AvatarLarge extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const _AvatarLarge({required this.name, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: const BoxDecoration(
        color: AppColors.ink,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null
          ? Avatar(name: name, size: AvatarSize.lg, color: AppColors.ink)
          : CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Avatar(name: name, size: AvatarSize.lg, color: AppColors.ink),
              errorWidget: (_, __, ___) =>
                  Avatar(name: name, size: AvatarSize.lg, color: AppColors.ink),
            ),
    );
  }
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
                const Icon(Icons.chevron_right,
                    size: 18, color: AppColors.muted2),
              ],
            ),
    );
  }
}
