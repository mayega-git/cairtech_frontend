import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/bar_progress.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/tag.dart';
import '../data/evangelism_repository.dart';

class EvangelismPage extends StatefulWidget {
  const EvangelismPage({super.key});

  @override
  State<EvangelismPage> createState() => _EvangelismPageState();
}

class _EvangelismPageState extends State<EvangelismPage> {
  late final EvangelismRepository _repo = EvangelismRepository(sl());
  Future<List<EvangelismProgramDto>>? _future;

  bool get _canCreate {
    final s = sl<AuthBloc>().state;
    if (s is! AuthAuthenticated) return false;
    return s.user.hasPermission('bbcms:evangelism:program-create');
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = _repo.listPrograms();
    setState(() {});
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
                      if (_canCreate)
                        RoundIconButton(
                          onTap: () async {
                            final ok = await _showCreateDialog();
                            if (ok == true) _reload();
                          },
                          child: const Icon(Icons.add, size: 16),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const ScreenHeader(
              eyebrow: 'MISSION',
              title: 'Évangélisation',
              subtitle: 'Programmes et campagnes de la CHF',
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _reload(),
                child: FutureBuilder<List<EvangelismProgramDto>>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return _err(snap.error);
                    }
                    final all = snap.data ?? const [];
                    if (all.isEmpty) {
                      return _empty();
                    }
                    final active =
                        all.where((p) => p.isActive).toList();
                    final draft = all.where((p) => p.isDraft).toList();
                    final closed = all.where((p) => p.isClosed).toList();
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      children: [
                        if (active.isNotEmpty) ...[
                          _heroActive(active.first),
                          if (active.length > 1) ...[
                            const SizedBox(height: 12),
                            _section('AUTRES PROGRAMMES ACTIFS'),
                            for (final p in active.skip(1)) _programCard(p),
                          ],
                        ],
                        if (draft.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _section('BROUILLONS'),
                          for (final p in draft) _programCard(p),
                        ],
                        if (closed.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _section('CLÔTURÉS'),
                          for (final p in closed) _programCard(p),
                        ],
                      ],
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

  Widget _heroActive(EvangelismProgramDto p) {
    final ratio = p.ratio;
    final totalDates = p.dates.length;
    final pastDates =
        p.dates.where((d) => d.isBefore(DateTime.now())).length;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      onTap: () async {
        await context.push('${AppRoutes.evangelismBase}/${p.id}');
        _reload();
      },
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TagX('EN COURS', kind: TagKind.success),
                Text('J+$pastDates / $totalDates',
                    style: AppTypography.mono(
                        size: 10,
                        color: Colors.white.withOpacity(0.55),
                        letterSpacing: 1.2)),
              ],
            ),
            const SizedBox(height: 14),
            Text(p.title,
                style: AppTypography.serif(
                    size: 28,
                    color: Colors.white,
                    height: 1.1,
                    letterSpacing: -0.5)),
            const SizedBox(height: 6),
            Text(
              '${p.type == "INTERNAL_BBC" ? "Programme BBC" : "Programme inter-BBC"} · '
              '${p.bibleClubIds.length} club${p.bibleClubIds.length > 1 ? "s" : ""}',
              style: AppTypography.sans(
                  size: 12.5, color: Colors.white.withOpacity(0.65)),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _heroStat('OBJECTIF', '${p.objectiveBelievers}', 'âmes')),
                Expanded(child: _heroStat('CRUS', '${p.totalSaved}', '')),
                Expanded(
                  child: _heroStat('%',
                      Fmt.amount(ratio * 100), '/100'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            BarProgress(
              value: ratio,
              color: Colors.white,
              track: Colors.white.withOpacity(0.14),
              height: 3,
            ),
          ],
        ),
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
                      size: 24,
                      color: Colors.white,
                      height: 1,
                      letterSpacing: -0.3)),
              if (sub.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 3, left: 3),
                  child: Text(sub,
                      style: AppTypography.sans(
                          size: 10, color: Colors.white.withOpacity(0.55))),
                ),
            ],
          ),
        ],
      );

  Widget _section(String s) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
        child: Text(s, style: AppTypography.eyebrow()),
      );

  Widget _programCard(EvangelismProgramDto p) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: () async {
        await context.push('${AppRoutes.evangelismBase}/${p.id}');
        _reload();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
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
                Expanded(
                  child: Text(p.title,
                      style: AppTypography.sans(
                          size: 14, weight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                _statusBadge(p.status),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '${p.totalSaved} / ${p.objectiveBelievers} âmes',
                  style: AppTypography.serif(
                      size: 16, letterSpacing: -0.2),
                ),
                const Spacer(),
                Text(Fmt.percent(p.ratio),
                    style: AppTypography.mono(
                        size: 11, color: AppColors.muted)),
              ],
            ),
            const SizedBox(height: 8),
            BarProgress(
                value: p.ratio,
                color: p.isClosed ? AppColors.muted : AppColors.ink),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String s) => switch (s) {
        'DRAFT' => const TagX('BROUILLON'),
        'ACTIVE' => const TagX('EN COURS', kind: TagKind.success),
        'CLOSED' => const TagX('CLÔTURÉ'),
        _ => TagX(s),
      };

  Widget _err(Object? e) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Text('Erreur: $e',
                style:
                    AppTypography.sans(size: 12, color: AppColors.danger)),
          ),
        ],
      );

  Widget _empty() => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(Icons.send_outlined,
                      size: 32, color: AppColors.muted),
                  const SizedBox(height: 12),
                  Text(
                    'Aucun programme d\'évangélisation.',
                    style: AppTypography.sans(
                        size: 13, color: AppColors.muted),
                  ),
                  if (_canCreate) ...[
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final ok = await _showCreateDialog();
                        if (ok == true) _reload();
                      },
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text('Démarrer un programme'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );

  Future<bool?> _showCreateDialog() async {
    final title = TextEditingController();
    final objective = TextEditingController(text: '100');
    String type = 'INTERNAL_BBC';
    String? err;

    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setS) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg)),
            title:
                Text('Nouveau programme', style: AppTypography.serif(size: 22)),
            content: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TITRE', style: AppTypography.eyebrow()),
                  const SizedBox(height: 4),
                  TextField(
                    controller: title,
                    decoration: const InputDecoration(
                        hintText: 'Campus en feu — Mai 2026'),
                  ),
                  const SizedBox(height: 10),
                  Text('TYPE', style: AppTypography.eyebrow()),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: _typeBtn('INTERNAL_BBC', 'BBC seul', type,
                            (v) => setS(() => type = v)),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _typeBtn('JOINT', 'Inter-BBC', type,
                            (v) => setS(() => type = v)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('OBJECTIF (ÂMES)', style: AppTypography.eyebrow()),
                  const SizedBox(height: 4),
                  TextField(
                    controller: objective,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '100'),
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
                onPressed: () async {
                  if (title.text.trim().isEmpty) {
                    setS(() => err = 'Titre requis');
                    return;
                  }
                  final obj = int.tryParse(objective.text) ?? 0;
                  if (obj <= 0) {
                    setS(() => err = 'Objectif > 0 requis');
                    return;
                  }
                  try {
                    await _repo.draftProgram(
                        title: title.text.trim(),
                        type: type,
                        objective: obj);
                    Navigator.pop(ctx, true);
                  } catch (e) {
                    setS(() => err = '$e');
                  }
                },
                child: const Text('Créer'),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _typeBtn(String value, String label, String selected,
      ValueChanged<String> onTap) {
    final isSel = value == selected;
    return InkWell(
      onTap: () => onTap(value),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSel ? AppColors.ink : AppColors.surface,
          border:
              Border.all(color: isSel ? AppColors.ink : AppColors.hair),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text(label,
            style: AppTypography.sans(
                size: 12.5,
                weight: FontWeight.w500,
                color: isSel ? Colors.white : AppColors.ink)),
      ),
    );
  }
}
