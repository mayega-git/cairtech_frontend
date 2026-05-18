import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/api/api_config.dart';
import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/tag.dart';
import '../../members/data/member_repository.dart';
import '../../members/data/member_with_profile_dto.dart';
import '../data/bible_clubs_admin_repository.dart';

class BibleClubAdminDetailPage extends StatefulWidget {
  final String bibleClubId;
  const BibleClubAdminDetailPage({super.key, required this.bibleClubId});

  @override
  State<BibleClubAdminDetailPage> createState() =>
      _BibleClubAdminDetailPageState();
}

class _BibleClubAdminDetailPageState extends State<BibleClubAdminDetailPage> {
  late final BibleClubsAdminRepository _repo =
      BibleClubsAdminRepository(sl());
  late final LevelsAdminRepository _levelRepo = LevelsAdminRepository(sl());
  late final MemberRepository _memberRepo = MemberRepository(sl());

  Future<_Bundle>? _future;
  bool _changed = false;

  bool get _canEdit {
    final s = sl<AuthBloc>().state;
    if (s is! AuthAuthenticated) return false;
    return s.user.hasPermission('bbcms:bible-club:update') ||
        s.user.hasPermission('bbcms:bible-club:set-goal');
  }

  bool get _canReset {
    final s = sl<AuthBloc>().state;
    if (s is! AuthAuthenticated) return false;
    return s.user.hasPermission('bbcms:bible-club:reset');
  }

  bool get _canManageLevels {
    final s = sl<AuthBloc>().state;
    if (s is! AuthAuthenticated) return false;
    return s.user.hasPermission('bbcms:level:create');
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = _load();
    setState(() {});
  }

  Future<_Bundle> _load() async {
    final results = await Future.wait([
      _repo.findById(widget.bibleClubId),
      _levelRepo.listByBibleClub(widget.bibleClubId),
      _memberRepo.listByBibleClubWithProfile(widget.bibleClubId),
    ]);
    return _Bundle(
      bibleClub: results[0] as BibleClubFullDto,
      levels: results[1] as List<LevelDto>,
      members: results[2] as List<MemberWithProfileDto>,
    );
  }

  Future<void> _showSetGoalDialog(BibleClubFullDto b) async {
    final goal = TextEditingController(text: '${b.goalNbFaithful ?? 100}');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Objectif fidèles',
            style: AppTypography.serif(size: 22)),
        content: TextField(
          controller: goal,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '100'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final v = int.tryParse(goal.text) ?? 0;
              if (v <= 0) return;
              try {
                await _repo.setGoal(b.id, v);
                Navigator.pop(ctx, true);
              } catch (_) {
                Navigator.pop(ctx, false);
              }
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
    if (ok == true) {
      _changed = true;
      _reload();
    }
  }

  Future<void> _showCreateLevelDialog(BibleClubFullDto b) async {
    final name = TextEditingController();
    String type = 'L1';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg)),
          title:
              Text('Nouveau niveau', style: AppTypography.serif(size: 22)),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TYPE', style: AppTypography.eyebrow()),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: ['L1', 'L2', 'L3', 'L4', 'L5', 'L6', 'L7']
                      .map((t) => InkWell(
                            onTap: () => setS(() => type = t),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: type == t
                                    ? AppColors.ink
                                    : AppColors.surface,
                                border: Border.all(
                                    color: type == t
                                        ? AppColors.ink
                                        : AppColors.hair),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(t,
                                  style: AppTypography.mono(
                                      size: 11,
                                      color: type == t
                                          ? Colors.white
                                          : AppColors.ink,
                                      letterSpacing: 0.6)),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 10),
                Text('NOM', style: AppTypography.eyebrow()),
                const SizedBox(height: 4),
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                      hintText: 'L1 · Initiation, L2 · Affermissement…'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                if (name.text.trim().isEmpty) return;
                try {
                  await _levelRepo.create(
                    bibleClubId: b.id,
                    name: name.text.trim(),
                    type: type,
                  );
                  Navigator.pop(ctx, true);
                } catch (_) {
                  Navigator.pop(ctx, false);
                }
              },
              child: const Text('Créer'),
            ),
          ],
        );
      }),
    );
    if (ok == true) _reload();
  }

  Future<void> _deleteLevel(BibleClubFullDto b, LevelDto l) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Supprimer ${l.name} ?',
            style: AppTypography.serif(size: 22)),
        content: Text(
            'Tous les membres rattachés à ce niveau devront être réaffectés.',
            style: AppTypography.sans(size: 13, color: AppColors.muted)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _levelRepo.delete(bibleClubId: b.id, levelId: l.id);
      _reload();
    } catch (e) {
      _toast('Erreur: $e');
    }
  }

  Future<void> _showTriumvirateDialog(
      BibleClubFullDto b, List<MemberWithProfileDto> members) async {
    final eligibles = members
        .where((m) =>
            m.kind == 'STUDENT' && m.status == 'ACTIVE')
        .toList();
    String? presId = b.presidentMemberId;
    String? vpId = b.vicePresidentMemberId;
    String? secId = b.secretaryMemberId;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg)),
          title:
              Text('Triumvirat', style: AppTypography.serif(size: 22)),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _memberDropdown(
                    label: 'PRÉSIDENT',
                    value: presId,
                    members: eligibles,
                    onChanged: (id) => setS(() => presId = id),
                  ),
                  const SizedBox(height: 10),
                  _memberDropdown(
                    label: 'VICE-PRÉSIDENT',
                    value: vpId,
                    members: eligibles,
                    onChanged: (id) => setS(() => vpId = id),
                  ),
                  const SizedBox(height: 10),
                  _memberDropdown(
                    label: 'SECRÉTAIRE',
                    value: secId,
                    members: eligibles,
                    onChanged: (id) => setS(() => secId = id),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _repo.assignTriumvirate(
                    id: b.id,
                    presidentId: presId,
                    vicePresidentId: vpId,
                    secretaryId: secId,
                  );
                  Navigator.pop(ctx, true);
                } catch (e) {
                  _toast('Erreur: $e');
                }
              },
              child: const Text('Sauvegarder'),
            ),
          ],
        );
      }),
    );
    if (ok == true) {
      _changed = true;
      _reload();
    }
  }

  Widget _memberDropdown({
    required String label,
    required String? value,
    required List<MemberWithProfileDto> members,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.eyebrow()),
        const SizedBox(height: 4),
        DropdownButtonFormField<String?>(
          value: value,
          isExpanded: true,
          decoration: const InputDecoration(),
          items: [
            const DropdownMenuItem<String?>(value: null, child: Text('—')),
            ...members.map((m) => DropdownMenuItem<String?>(
                  value: m.id,
                  child: Text(m.displayName,
                      overflow: TextOverflow.ellipsis),
                )),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<void> _showResetDialog(BibleClubFullDto b) async {
    final year = TextEditingController(
        text: '${DateTime.now().month >= 9 ? DateTime.now().year : DateTime.now().year - 1}');
    String? err;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg)),
          title: Text('Reset annuel',
              style: AppTypography.serif(size: 22)),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8EEDF),
                    border: Border.all(color: const Color(0xFFECDFC7)),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 18, color: AppColors.warn),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cette opération va :\n'
                          '1. Geler les écritures (UNDER_RESET) — RM-07\n'
                          '2. Générer le snapshot annuel\n'
                          '3. Transférer les membres (L1→L2…L7→TRANSFERRED)\n'
                          '4. Remettre à zéro les scores de fidélité\n'
                          '5. Rouvrir le BBC en ACTIVE pour la nouvelle année',
                          style: AppTypography.sans(
                              size: 12,
                              color: AppColors.warn,
                              height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text('ANNÉE ACADÉMIQUE À CLÔTURER',
                    style: AppTypography.eyebrow()),
                const SizedBox(height: 4),
                TextField(
                  controller: year,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: '2025'),
                ),
                if (err != null) ...[
                  const SizedBox(height: 10),
                  Text(err!,
                      style: AppTypography.sans(
                          size: 12, color: AppColors.danger)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler')),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () async {
                final y = int.tryParse(year.text) ?? 0;
                if (y < 2024) {
                  setS(() => err = 'Année invalide (>= 2024)');
                  return;
                }
                try {
                  final snapshot =
                      await _repo.reset(id: b.id, academicYear: y);
                  Navigator.pop(ctx, true);
                  _showSnapshotResult(snapshot);
                } catch (e) {
                  setS(() => err = '$e');
                }
              },
              child: const Text('Lancer le reset'),
            ),
          ],
        );
      }),
    );
    if (ok == true) {
      _changed = true;
      _reload();
    }
  }

  void _showSnapshotResult(ResetSnapshotDto s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.positive),
            const SizedBox(width: 8),
            Text('Reset terminé', style: AppTypography.serif(size: 22)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SNAPSHOT ANNUEL ${s.academicYear}',
                  style: AppTypography.eyebrow()),
              const SizedBox(height: 8),
              _resultRow('Membres au reset', '${s.nbMembersBefore}'),
              _resultRow('Fidèles au reset', '${s.nbFaithfulBefore}'),
              _resultRow('Réunions tenues', '${s.nbMeetings}'),
              _resultRow('% objectif atteint',
                  '${s.percentageReached.toStringAsFixed(2)}%'),
              if (s.archivedAt != null)
                _resultRow('Archivé le',
                    '${s.archivedAt!.day}/${s.archivedAt!.month}/${s.archivedAt!.year}'),
              if (s.archiveFileId != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Archive PDF générée : ${s.archiveFileId!.substring(0, 8)}…',
                  style: AppTypography.mono(
                      size: 10,
                      color: AppColors.muted,
                      letterSpacing: 0.6),
                ),
              ],
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(
                child: Text(k,
                    style: AppTypography.sans(
                        size: 13, color: AppColors.muted))),
            Text(v,
                style: AppTypography.serif(size: 16, letterSpacing: -0.2)),
          ],
        ),
      );

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: FutureBuilder<_Bundle>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Erreur: ${snap.error}',
                      textAlign: TextAlign.center,
                      style: AppTypography.sans(
                          size: 13, color: AppColors.danger)),
                ),
              );
            }
            return _content(snap.data!);
          },
        ),
      ),
    );
  }

  Widget _content(_Bundle b) {
    final bbc = b.bibleClub;
    return Column(
      children: [
        _hero(bbc),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                _statsCard(bbc, b),
                const SizedBox(height: 12),
                _levelsCard(bbc, b.levels),
                const SizedBox(height: 12),
                _triumvirateCard(bbc, b.members),
                if (_canReset) ...[
                  const SizedBox(height: 12),
                  _resetCard(bbc),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _hero(BibleClubFullDto bbc) {
    final statusBadge = switch (bbc.status) {
      'ACTIVE' => const TagX('ACTIF', kind: TagKind.success),
      'UNDER_RESET' => const TagX('RESET EN COURS', kind: TagKind.warn),
      'ARCHIVED' => const TagX('ARCHIVÉ'),
      _ => TagX(bbc.status),
    };
    return Container(
      color: AppColors.ink,
      child: Column(
        children: [
          if (bbc.imageFileId != null)
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl:
                        '${ApiConfig.apiBase}/files/${bbc.imageFileId}/url',
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: Colors.white.withOpacity(0.04)),
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.white.withOpacity(0.04),
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image_outlined,
                          size: 40, color: Colors.white24),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.ink.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 20,
                    child: RoundIconButton(
                      dark: true,
                      onTap: () => Navigator.pop(context, _changed),
                      child: const Icon(Icons.arrow_back, size: 16),
                    ),
                  ),
                  Positioned(top: 20, right: 20, child: statusBadge),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, bbc.imageFileId == null ? 14 : 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (bbc.imageFileId == null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RoundIconButton(
                        dark: true,
                        onTap: () => Navigator.pop(context, _changed),
                        child: const Icon(Icons.arrow_back, size: 16),
                      ),
                      statusBadge,
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
                Text('BIBLE CLUB',
                    style: AppTypography.eyebrow(
                        color: Colors.white.withOpacity(0.55))),
                const SizedBox(height: 4),
                Text(bbc.name,
                    style: AppTypography.serif(
                        size: 26,
                        color: Colors.white,
                        letterSpacing: -0.4,
                        height: 1.1)),
                if (bbc.schoolName != null) ...[
                  const SizedBox(height: 4),
                  Text(bbc.schoolName!,
                      style: AppTypography.sans(
                          size: 12.5,
                          color: Colors.white.withOpacity(0.65))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsCard(BibleClubFullDto bbc, _Bundle b) {
    final activeMembers = b.members
        .where((m) => m.kind == 'STUDENT' && m.status == 'ACTIVE')
        .length;
    final faithful =
        b.members.where((m) => m.kind == 'STUDENT' && m.isFaithful).length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.hair),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('STATISTIQUES', style: AppTypography.eyebrow()),
              const Spacer(),
              if (_canEdit && bbc.isActive)
                TextButton.icon(
                  onPressed: () => _showSetGoalDialog(bbc),
                  icon: const Icon(Icons.edit, size: 12),
                  label: Text('OBJECTIF',
                      style: AppTypography.mono(
                          size: 10,
                          weight: FontWeight.w600,
                          letterSpacing: 1.4,
                          color: AppColors.ink)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _stat('MEMBRES ACT.', '$activeMembers')),
              Expanded(child: _stat('FIDÈLES', '$faithful')),
              Expanded(
                child: _stat(
                    'OBJECTIF', '${bbc.goalNbFaithful ?? "—"}'),
              ),
            ],
          ),
        ],
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
              style: AppTypography.serif(size: 22, letterSpacing: -0.3)),
        ],
      );

  Widget _levelsCard(BibleClubFullDto bbc, List<LevelDto> levels) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.hair),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Text('NIVEAUX (${levels.length})',
                    style: AppTypography.eyebrow()),
                const Spacer(),
                if (_canManageLevels && bbc.isActive)
                  TextButton.icon(
                    onPressed: () => _showCreateLevelDialog(bbc),
                    icon: const Icon(Icons.add, size: 12),
                    label: Text('AJOUTER',
                        style: AppTypography.mono(
                            size: 10,
                            weight: FontWeight.w600,
                            letterSpacing: 1.4,
                            color: AppColors.ink)),
                  ),
              ],
            ),
          ),
          if (levels.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Text('Aucun niveau configuré.',
                  style: AppTypography.sans(
                      size: 12, color: AppColors.muted)),
            )
          else
            for (int i = 0; i < levels.length; i++) ...[
              ListTile(
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    border: Border.all(color: AppColors.hair),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  alignment: Alignment.center,
                  child: Text(levels[i].type,
                      style: AppTypography.mono(
                          size: 10,
                          weight: FontWeight.w600,
                          color: AppColors.ink,
                          letterSpacing: 0.6)),
                ),
                title: Text(levels[i].name,
                    style: AppTypography.sans(
                        size: 13.5, weight: FontWeight.w500)),
                trailing: _canManageLevels && bbc.isActive
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: AppColors.muted),
                        onPressed: () => _deleteLevel(bbc, levels[i]),
                      )
                    : null,
              ),
              if (i < levels.length - 1)
                const Divider(height: 1, color: AppColors.hair2),
            ],
        ],
      ),
    );
  }

  Widget _triumvirateCard(
      BibleClubFullDto bbc, List<MemberWithProfileDto> members) {
    Map<String, MemberWithProfileDto> byId = {
      for (final m in members) m.id: m,
    };

    String nameOf(String? id) {
      if (id == null) return '—';
      final m = byId[id];
      return m == null ? id.substring(0, 8) : m.displayName;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.hair),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('TRIUMVIRAT BBC', style: AppTypography.eyebrow()),
              const Spacer(),
              if (_canEdit && bbc.isActive)
                TextButton.icon(
                  onPressed: () => _showTriumvirateDialog(bbc, members),
                  icon: const Icon(Icons.edit, size: 12),
                  label: Text('MODIFIER',
                      style: AppTypography.mono(
                          size: 10,
                          weight: FontWeight.w600,
                          letterSpacing: 1.4,
                          color: AppColors.ink)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _kv('Président', nameOf(bbc.presidentMemberId)),
          _kv('Vice-Président', nameOf(bbc.vicePresidentMemberId)),
          _kv('Secrétaire', nameOf(bbc.secretaryMemberId)),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 130,
              child: Text(k.toUpperCase(),
                  style: AppTypography.mono(
                      size: 10,
                      color: AppColors.muted,
                      letterSpacing: 1.2)),
            ),
            Expanded(
              child: Text(v,
                  style: AppTypography.sans(
                      size: 13, weight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );

  Widget _resetCard(BibleClubFullDto bbc) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        border: Border.all(color: AppColors.hair),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RESET ANNUEL · UC-BBC-01',
              style: AppTypography.eyebrow()),
          const SizedBox(height: 8),
          Text(
            'Clôture l\'année académique : snapshot annuel, transferts de '
            'niveaux (L1→L2…L7→TRANSFERRED), remise à zéro des scores, '
            'archive PDF.',
            style: AppTypography.sans(
                size: 12, color: AppColors.muted, height: 1.5),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: bbc.isActive
                    ? AppColors.warn
                    : AppColors.muted2,
              ),
              onPressed: bbc.isActive ? () => _showResetDialog(bbc) : null,
              icon: const Icon(Icons.restart_alt, size: 14),
              label: Text(bbc.isActive
                  ? 'Lancer le reset annuel'
                  : 'Reset indisponible (statut: ${bbc.status})'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bundle {
  final BibleClubFullDto bibleClub;
  final List<LevelDto> levels;
  final List<MemberWithProfileDto> members;
  _Bundle({
    required this.bibleClub,
    required this.levels,
    required this.members,
  });
}
