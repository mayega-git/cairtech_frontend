import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/chip_x.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/tag.dart';
import '../../onboarding/data/public_registry_repository.dart';
import '../data/membership_request_repository.dart';

class MembershipRequestsPage extends StatefulWidget {
  const MembershipRequestsPage({super.key});

  @override
  State<MembershipRequestsPage> createState() => _MembershipRequestsPageState();
}

class _MembershipRequestsPageState extends State<MembershipRequestsPage> {
  late final MembershipRequestRepository _repo =
      MembershipRequestRepository(sl());
  late final PublicRegistryRepository _publicRepo =
      PublicRegistryRepository(sl());

  Future<List<MembershipRequestDto>>? _future;
  String _status = 'PENDING';

  // Maps id → nom pour BBC et niveaux
  Map<String, String> _bbcNames = {};
  Map<String, String> _levelNames = {};

  @override
  void initState() {
    super.initState();
    _loadReferentials().then((_) => _reload());
  }

  Future<void> _loadReferentials() async {
    try {
      final bbcs = await _publicRepo.listBibleClubs();
      final bbcMap = <String, String>{};
      final levelMap = <String, String>{};
      for (final bbc in bbcs) {
        bbcMap[bbc.id] = bbc.name;
        try {
          final levels = await _publicRepo.listLevels(bbc.id);
          for (final l in levels) {
            levelMap[l.id] = '${l.type} — ${l.name}';
          }
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _bbcNames = bbcMap;
          _levelNames = levelMap;
        });
      }
    } catch (_) {}
  }

  void _reload() {
    _future = _repo.listWithProfile(status: _status);
    setState(() {});
  }

  Future<void> _approve(MembershipRequestDto r) async {
    final bbcId = r.bibleClubId;
    final levelId = r.levelId;
    if (r.requestedType == 'STUDENT' && (bbcId == null || levelId == null)) {
      _toast('Demande incomplète: BBC ou niveau manquant');
      return;
    }
    final result = await showDialog<_ApprovalResult>(
      context: context,
      builder: (_) => _ApproveDialog(
        request: r,
        publicRepo: _publicRepo,
      ),
    );
    if (result == null) return;
    try {
      await _repo.approve(
        requestId: r.id,
        assignedBibleClubId: result.bbcId,
        assignedLevelId: result.levelId,
        comment: result.comment,
      );
      _toast('Demande approuvée ✓');
      _reload();
    } catch (e) {
      _toast('Erreur: $e');
    }
  }

  Future<void> _reject(MembershipRequestDto r) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Rejeter la demande ?',
            style: AppTypography.serif(size: 22)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'L\'utilisateur pourra soumettre une nouvelle demande.',
              style: AppTypography.sans(
                  size: 12, color: AppColors.muted, height: 1.5),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 2,
              decoration: const InputDecoration(hintText: 'Motif (optionnel)…'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _repo.reject(
        requestId: r.id,
        comment: ctrl.text.trim().isEmpty ? null : ctrl.text.trim(),
      );
      _toast('Demande rejetée');
      _reload();
    } catch (e) {
      _toast('Erreur: $e');
    }
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

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
            const ScreenHeader(
              eyebrow: 'COMPTES & INSCRIPTIONS',
              title: "Demandes d'adhésion",
              subtitle: 'Approuver ou rejeter chaque demande individuellement',
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                children: [
                  ChipX('En attente',
                      active: _status == 'PENDING',
                      onTap: () {
                        setState(() => _status = 'PENDING');
                        _reload();
                      }),
                  const SizedBox(width: 6),
                  ChipX('Approuvées',
                      active: _status == 'APPROVED',
                      onTap: () {
                        setState(() => _status = 'APPROVED');
                        _reload();
                      }),
                  const SizedBox(width: 6),
                  ChipX('Rejetées',
                      active: _status == 'REJECTED',
                      onTap: () {
                        setState(() => _status = 'REJECTED');
                        _reload();
                      }),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _loadReferentials();
                  _reload();
                },
                child: FutureBuilder<List<MembershipRequestDto>>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Text('Erreur: ${snap.error}',
                                style: AppTypography.sans(
                                    size: 12, color: AppColors.danger)),
                          ),
                        ],
                      );
                    }
                    final list = snap.data ?? const [];
                    if (list.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                _status == 'PENDING'
                                    ? 'Aucune demande en attente.'
                                    : 'Aucune demande dans ce filtre.',
                                style: AppTypography.sans(
                                    size: 13, color: AppColors.muted),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _RequestCard(
                        r: list[i],
                        bbcNames: _bbcNames,
                        levelNames: _levelNames,
                        canApprove: _status == 'PENDING',
                        onApprove: () => _approve(list[i]),
                        onReject: () => _reject(list[i]),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _RequestCard extends StatelessWidget {
  final MembershipRequestDto r;
  final Map<String, String> bbcNames;
  final Map<String, String> levelNames;
  final bool canApprove;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _RequestCard({
    required this.r,
    required this.bbcNames,
    required this.levelNames,
    required this.canApprove,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
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
              Avatar(name: r.displayName, color: AppColors.gold),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.displayName,
                        style: AppTypography.sans(
                            size: 14, weight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(r.email,
                        style: AppTypography.sans(
                            size: 11.5, color: AppColors.muted)),
                  ],
                ),
              ),
              _statusBadge(r.status),
            ],
          ),
          const SizedBox(height: 10),
          _kv('Type demandé', _typeLabel(r.requestedType)),
          if (r.profession != null && r.profession!.isNotEmpty)
            _kv('Profession', r.profession!),
          if (r.bibleClubId != null)
            _kv('BBC visé',
                bbcNames[r.bibleClubId!] ?? r.bibleClubId!.substring(0, 8)),
          if (r.levelId != null)
            _kv('Niveau visé',
                levelNames[r.levelId!] ?? r.levelId!.substring(0, 8)),
          if (r.phone != null && r.phone!.isNotEmpty)
            _kv('Téléphone', r.phone!),
          if (r.decisionComment != null && r.decisionComment!.isNotEmpty)
            _kv('Commentaire', r.decisionComment!),
          if (canApprove && r.status == 'PENDING') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.hair),
                    ),
                    onPressed: onReject,
                    child: const Text('Rejeter'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check, size: 14),
                    label: const Text('Approuver'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge(String status) => switch (status) {
        'PENDING' => const TagX('EN ATTENTE', kind: TagKind.warn),
        'APPROVED' => const TagX('APPROUVÉE', kind: TagKind.success),
        'REJECTED' => const TagX('REJETÉE', kind: TagKind.danger),
        'CANCELLED' =>
          const TagX('ANNULÉE', kind: TagKind.defaultKind),
        _ => TagX(status),
      };

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(k.toUpperCase(),
                style: AppTypography.mono(
                    size: 9,
                    color: AppColors.muted,
                    letterSpacing: 1.2)),
          ),
          Expanded(
            child: Text(v,
                style: AppTypography.sans(size: 12, height: 1.4)),
          ),
        ],
      ),
    );
  }

  String _typeLabel(String t) => switch (t) {
        'STUDENT' => 'Étudiant',
        'PROFESSIONAL' => 'Professionnel',
        'VISITOR' => 'Visiteur',
        _ => t,
      };
}

class _ApprovalResult {
  final String bbcId;
  final String levelId;
  final String? comment;
  _ApprovalResult({
    required this.bbcId,
    required this.levelId,
    this.comment,
  });
}

class _ApproveDialog extends StatefulWidget {
  final MembershipRequestDto request;
  final PublicRegistryRepository publicRepo;

  const _ApproveDialog({
    required this.request,
    required this.publicRepo,
  });

  @override
  State<_ApproveDialog> createState() => _ApproveDialogState();
}

class _ApproveDialogState extends State<_ApproveDialog> {
  List<BibleClubLite> _bbcs = const [];
  List<LevelLite> _levels = const [];
  BibleClubLite? _bbc;
  LevelLite? _level;
  final _comment = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final list = await widget.publicRepo.listBibleClubs();
    setState(() {
      _bbcs = list;
      _bbc = list.firstWhere(
        (b) => b.id == widget.request.bibleClubId,
        orElse: () => list.first,
      );
    });
    await _loadLevels(_bbc!.id);
  }

  Future<void> _loadLevels(String bbcId) async {
    setState(() => _loading = true);
    final list = await widget.publicRepo.listLevels(bbcId);
    setState(() {
      _levels = list;
      _level = list.firstWhere(
        (l) => l.id == widget.request.levelId,
        orElse: () => list.isEmpty
            ? const LevelLite(id: '', name: '', type: '')
            : list.first,
      );
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = widget.request.requestedType == 'STUDENT';
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg)),
      title:
          Text('Approuver la demande', style: AppTypography.serif(size: 22)),
      content: SizedBox(
        width: 360,
        child: _loading
            ? const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()))
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.request.displayName,
                      style: AppTypography.sans(
                          size: 14, weight: FontWeight.w500)),
                  Text(widget.request.email,
                      style: AppTypography.sans(
                          size: 11.5, color: AppColors.muted)),
                  const SizedBox(height: 14),
                  if (isStudent) ...[
                    Text('BIBLE CLUB ASSIGNÉ',
                        style: AppTypography.eyebrow()),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _bbc?.id,
                      isExpanded: true,
                      decoration: const InputDecoration(),
                      items: _bbcs
                          .map((b) => DropdownMenuItem<String>(
                                value: b.id,
                                child: Text(b.name,
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (id) async {
                        final picked = _bbcs.firstWhere((b) => b.id == id);
                        setState(() => _bbc = picked);
                        await _loadLevels(picked.id);
                      },
                    ),
                    const SizedBox(height: 10),
                    Text('NIVEAU ASSIGNÉ',
                        style: AppTypography.eyebrow()),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _level?.id.isEmpty == true ? null : _level?.id,
                      isExpanded: true,
                      decoration: const InputDecoration(),
                      items: _levels
                          .map((l) => DropdownMenuItem<String>(
                                value: l.id,
                                child: Text('${l.type} — ${l.name}'),
                              ))
                          .toList(),
                      onChanged: (id) => setState(() =>
                          _level = _levels.firstWhere((l) => l.id == id)),
                    ),
                  ] else
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        border: Border.all(color: AppColors.hair),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Le compte sera approuvé en tant que ${widget.request.requestedType}. '
                        'Pas de BBC/Niveau à assigner.',
                        style: AppTypography.sans(
                            size: 12, color: AppColors.muted),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text('COMMENTAIRE (OPTIONNEL)',
                      style: AppTypography.eyebrow()),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _comment,
                    maxLines: 2,
                    decoration: const InputDecoration(
                        hintText: 'Bienvenue dans la maison…'),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Annuler')),
        ElevatedButton(
          onPressed: _loading
              ? null
              : () {
                  final isStudent = widget.request.requestedType == 'STUDENT';
                  if (isStudent && (_bbc == null || _level == null || _level!.id.isEmpty)) {
                    return;
                  }
                  Navigator.pop(
                    context,
                    _ApprovalResult(
                      bbcId: _bbc?.id ?? widget.request.bibleClubId ?? '',
                      levelId: _level?.id ?? widget.request.levelId ?? '',
                      comment: _comment.text.trim().isEmpty
                          ? null
                          : _comment.text.trim(),
                    ),
                  );
                },
          child: const Text('Approuver'),
        ),
      ],
    );
  }
}
