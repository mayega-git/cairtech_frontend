import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/tag.dart';
import '../../members/data/member_repository.dart';
import '../../members/data/member_models.dart';
import '../data/discipleship_repository.dart';

class DiscipleshipPage extends StatefulWidget {
  const DiscipleshipPage({super.key});

  @override
  State<DiscipleshipPage> createState() => _DiscipleshipPageState();
}

class _DiscipleshipPageState extends State<DiscipleshipPage> {
  late final DiscipleshipRepository _repo = DiscipleshipRepository(sl());
  late final MemberRepository _memberRepo = MemberRepository(sl());

  Future<_Bundle>? _future;
  MemberDto? _me;

  bool get _canAssign {
    final s = sl<AuthBloc>().state;
    if (s is! AuthAuthenticated) return false;
    return s.user.hasPermission('bbcms:discipleship:assign');
  }

  bool get _canRecord {
    final s = sl<AuthBloc>().state;
    if (s is! AuthAuthenticated) return false;
    return s.user.hasPermission('bbcms:discipleship:record-create');
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
    final me = await _memberRepo.me();
    _me = me;
    if (me == null) {
      return _Bundle(disciples: const [], records: const []);
    }
    final results = await Future.wait([
      _repo.listDisciples(me.id),
      _repo.listRecords(me.id),
    ]);
    return _Bundle(
      disciples: results[0] as List<DiscipleLinkDto>,
      records: results[1] as List<DiscipleshipRecordDto>,
    );
  }

  Future<void> _addRecord() async {
    if (_me == null) return;
    final theme = TextEditingController();
    final location = TextEditingController();
    final description = TextEditingController();
    DateTime date = DateTime.now();
    final selectedDisciples = <String>{};
    String? err;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setS) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg)),
            title: Text('Compte rendu de session',
                style: AppTypography.serif(size: 22)),
            content: SizedBox(
              width: 380,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DATE', style: AppTypography.eyebrow()),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: date,
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 60)),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) setS(() => date = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(),
                        child: Text('${date.day}/${date.month}/${date.year}'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('THÈME (OPTIONNEL)',
                        style: AppTypography.eyebrow()),
                    const SizedBox(height: 4),
                    TextField(
                      controller: theme,
                      decoration: const InputDecoration(
                          hintText: 'Module 8 — Témoigner du Christ'),
                    ),
                    const SizedBox(height: 10),
                    Text('LIEU (OPTIONNEL)',
                        style: AppTypography.eyebrow()),
                    const SizedBox(height: 4),
                    TextField(
                      controller: location,
                      decoration: const InputDecoration(
                          hintText: 'Salle 4 · Bibliothèque centrale'),
                    ),
                    const SizedBox(height: 10),
                    Text('DESCRIPTION (OPTIONNEL)',
                        style: AppTypography.eyebrow()),
                    const SizedBox(height: 4),
                    TextField(
                      controller: description,
                      maxLines: 2,
                      decoration: const InputDecoration(
                          hintText: 'Résumé de la séance…'),
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
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Annuler')),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await _repo.recordSession(
                      makerId: _me!.id,
                      dateOccurred:
                          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                      theme: theme.text.trim().isEmpty
                          ? null
                          : theme.text.trim(),
                      location: location.text.trim().isEmpty
                          ? null
                          : location.text.trim(),
                      description: description.text.trim().isEmpty
                          ? null
                          : description.text.trim(),
                      presentDiscipleIds: selectedDisciples.toList(),
                    );
                    Navigator.pop(ctx, true);
                  } catch (e) {
                    setS(() => err = '$e');
                  }
                },
                child: const Text('Enregistrer'),
              ),
            ],
          );
        });
      },
    );
    if (ok == true) _reload();
  }

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RoundIconButton(
                    onTap: () => context.canPop()
                        ? context.pop()
                        : context.go('/home'),
                    child: const Icon(Icons.arrow_back, size: 16),
                  ),
                  Row(
                    children: [
                      RoundIconButton(
                        onTap: _reload,
                        child: const Icon(Icons.refresh, size: 15),
                      ),
                      const SizedBox(width: 6),
                      if (_canRecord)
                        RoundIconButton(
                          onTap: _addRecord,
                          child: const Icon(Icons.add, size: 16),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const ScreenHeader(
              eyebrow: 'MISSION',
              title: 'Discipulat',
              subtitle: 'Suivi des disciples et comptes rendus',
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _reload(),
                child: FutureBuilder<_Bundle>(
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
                    return _content(snap.data!);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(_Bundle b) {
    if (_me == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Vous devez être membre BBC pour accéder au discipulat.',
                style: AppTypography.sans(
                    size: 13, color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        _hero(b),
        const SizedBox(height: 14),
        _disciplesSection(b.disciples),
        const SizedBox(height: 14),
        _recordsSection(b.records),
      ],
    );
  }

  Widget _hero(_Bundle b) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MENTOR · DISCIPLE MAKER',
              style: AppTypography.eyebrow(
                  color: Colors.white.withOpacity(0.55))),
          const SizedBox(height: 4),
          Text(
            _me?.id.substring(0, 8) ?? 'Vous',
            style: AppTypography.serif(
                size: 22,
                color: Colors.white,
                letterSpacing: -0.3),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _heroStat(
                      'DISCIPLES', '${b.disciples.length}', 'actifs')),
              Expanded(
                  child: _heroStat(
                      'SESSIONS', '${b.records.length}', 'au total')),
              Expanded(
                child: _heroStat(
                    'DEPT.',
                    _me?.departments.contains('DISCIPLE_MAKER') == true
                        ? '✓'
                        : '·',
                    'maker'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String label, String value, String sub) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTypography.mono(
                  size: 9,
                  color: Colors.white.withOpacity(0.5),
                  letterSpacing: 1.4)),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: AppTypography.serif(
                      size: 22,
                      color: Colors.white,
                      height: 1,
                      letterSpacing: -0.3)),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(sub,
                    style: AppTypography.sans(
                        size: 9, color: Colors.white.withOpacity(0.55))),
              ),
            ],
          ),
        ],
      );

  Widget _disciplesSection(List<DiscipleLinkDto> disciples) {
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
            child: Text('MES DISCIPLES (${disciples.length})',
                style: AppTypography.eyebrow()),
          ),
          if (disciples.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Text(
                'Aucun disciple actif pour le moment. À la clôture d\'un programme '
                'd\'évangélisation, les nouveaux croyants vous seront affectés '
                'automatiquement.',
                style: AppTypography.sans(
                    size: 12, color: AppColors.muted, height: 1.5),
              ),
            )
          else
            for (int i = 0; i < disciples.length; i++) ...[
              _discipleRow(disciples[i]),
              if (i < disciples.length - 1)
                const Divider(height: 1, color: AppColors.hair2),
            ],
        ],
      ),
    );
  }

  Widget _discipleRow(DiscipleLinkDto d) => ListTile(
        leading: Avatar(name: d.discipleId.substring(0, 2)),
        title: Text('Disciple ${d.discipleId.substring(0, 6)}',
            style: AppTypography.sans(
                size: 13.5, weight: FontWeight.w500)),
        subtitle: Text(
          d.dateAssigned == null
              ? 'En cours'
              : 'Depuis ${d.dateAssigned!.day}/${d.dateAssigned!.month}/${d.dateAssigned!.year}',
          style: AppTypography.sans(
              size: 11.5, color: AppColors.muted),
        ),
        trailing: d.active
            ? const TagX('ACTIF', kind: TagKind.success)
            : const TagX('TERMINÉ'),
      );

  Widget _recordsSection(List<DiscipleshipRecordDto> records) {
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
                Text('SESSIONS RÉCENTES (${records.length})',
                    style: AppTypography.eyebrow()),
                const Spacer(),
                if (_canRecord)
                  TextButton.icon(
                    onPressed: _addRecord,
                    icon: const Icon(Icons.add, size: 12),
                    label: Text('NOUVELLE',
                        style: AppTypography.mono(
                            size: 10,
                            weight: FontWeight.w600,
                            letterSpacing: 1.4,
                            color: AppColors.ink)),
                  ),
              ],
            ),
          ),
          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Text('Aucune session enregistrée.',
                  style: AppTypography.sans(
                      size: 12, color: AppColors.muted)),
            )
          else
            for (int i = 0; i < records.length; i++) ...[
              ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    border: Border.all(color: AppColors.hair),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text('${records[i].dateOccurred.day}',
                      style: AppTypography.serif(
                          size: 14, letterSpacing: -0.2)),
                ),
                title: Text(records[i].theme ?? 'Session de discipulat',
                    style: AppTypography.sans(
                        size: 13.5, weight: FontWeight.w500)),
                subtitle: Text(
                    '${records[i].dateOccurred.day}/${records[i].dateOccurred.month}/${records[i].dateOccurred.year} · '
                    '${records[i].presentDiscipleIds.length} présents',
                    style: AppTypography.sans(
                        size: 11.5, color: AppColors.muted)),
              ),
              if (i < records.length - 1)
                const Divider(height: 1, color: AppColors.hair2),
            ],
        ],
      ),
    );
  }
}

class _Bundle {
  final List<DiscipleLinkDto> disciples;
  final List<DiscipleshipRecordDto> records;
  _Bundle({required this.disciples, required this.records});
}
