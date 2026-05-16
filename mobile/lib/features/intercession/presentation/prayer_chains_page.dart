import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/tag.dart';
import '../data/intercession_repository.dart';

class PrayerChainsPage extends StatefulWidget {
  const PrayerChainsPage({super.key});

  @override
  State<PrayerChainsPage> createState() => _PrayerChainsPageState();
}

class _PrayerChainsPageState extends State<PrayerChainsPage> {
  late final IntercessionRepository _repo = IntercessionRepository(sl());
  Future<List<PrayerChainDto>>? _future;

  String? get _bibleClubId {
    final s = sl<AuthBloc>().state;
    if (s is AuthAuthenticated) return s.user.bibleClubId;
    return null;
  }

  bool get _canManage {
    final s = sl<AuthBloc>().state;
    if (s is! AuthAuthenticated) return false;
    return s.user.hasPermission('bbcms:intercession:chain-manage');
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final id = _bibleClubId;
    if (id == null) {
      _future = Future.value([]);
    } else {
      _future = _repo.listChainsByBibleClub(id);
    }
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
                  if (_canManage)
                    RoundIconButton(
                      onTap: () async {
                        final created = await _showCreateDialog();
                        if (created == true) _reload();
                      },
                      child: const Icon(Icons.add, size: 16),
                    ),
                ],
              ),
            ),
            const ScreenHeader(
              eyebrow: 'INTERCESSION',
              title: 'Chaînes de prière',
              subtitle: 'Couvrir un créneau ou organiser une nouvelle chaîne',
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _reload(),
                child: FutureBuilder<List<PrayerChainDto>>(
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
                                'Aucune chaîne de prière pour le moment.',
                                style: AppTypography.sans(
                                    size: 13, color: AppColors.muted),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    list.sort((a, b) {
                      // Active first, then by start date desc
                      if (a.isRunning != b.isRunning) {
                        return a.isRunning ? -1 : 1;
                      }
                      return b.dateStart.compareTo(a.dateStart);
                    });
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _chainCard(list[i]),
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

  Widget _chainCard(PrayerChainDto c) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: () async {
        await context.push('${AppRoutes.prayerChainsBase}/${c.id}');
        _reload();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.isRunning ? AppColors.ink : AppColors.surface,
          border: Border.all(
              color: c.isRunning ? AppColors.ink : AppColors.hair),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _statusBadge(c.status),
                const Spacer(),
                Text(
                  _formatRange(c.dateStart, c.dateEnd),
                  style: AppTypography.mono(
                    size: 10,
                    color: c.isRunning
                        ? Colors.white.withOpacity(0.6)
                        : AppColors.muted,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              c.title,
              style: AppTypography.serif(
                size: 22,
                color: c.isRunning ? Colors.white : AppColors.ink,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.access_time,
                    size: 12,
                    color: c.isRunning
                        ? Colors.white.withOpacity(0.6)
                        : AppColors.muted),
                const SizedBox(width: 4),
                Text(
                  c.isRunning
                      ? 'En cours — touche pour couvrir un créneau'
                      : (c.isDraft
                          ? 'En préparation'
                          : 'Clôturée'),
                  style: AppTypography.sans(
                    size: 11.5,
                    color: c.isRunning
                        ? Colors.white.withOpacity(0.7)
                        : AppColors.muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String s) => switch (s) {
        'DRAFT' => const TagX('BROUILLON'),
        'RUNNING' => const TagX('EN COURS', kind: TagKind.success),
        'CLOSED' => const TagX('CLÔTURÉE', kind: TagKind.defaultKind),
        _ => TagX(s),
      };

  String _formatRange(DateTime s, DateTime? e) {
    if (e == null) return '${s.day}/${s.month}';
    return '${s.day}/${s.month} → ${e.day}/${e.month}';
  }

  Future<bool?> _showCreateDialog() async {
    final title = TextEditingController();
    DateTime start = DateTime.now();
    DateTime? end = DateTime.now().add(const Duration(days: 1));
    String? err;

    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setS) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg)),
              title: Text('Nouvelle chaîne',
                  style: AppTypography.serif(size: 22)),
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
                          hintText: 'Réveil de Pentecôte…'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('DÉBUT', style: AppTypography.eyebrow()),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () async {
                                  final p = await showDatePicker(
                                    context: ctx,
                                    initialDate: start,
                                    firstDate: DateTime.now()
                                        .subtract(const Duration(days: 30)),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 365)),
                                  );
                                  if (p != null) setS(() => start = p);
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(),
                                  child: Text(
                                      '${start.day}/${start.month}/${start.year}'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('FIN', style: AppTypography.eyebrow()),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () async {
                                  final p = await showDatePicker(
                                    context: ctx,
                                    initialDate: end ?? start,
                                    firstDate: start,
                                    lastDate: start
                                        .add(const Duration(days: 365)),
                                  );
                                  if (p != null) setS(() => end = p);
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(),
                                  child: Text(end == null
                                      ? '—'
                                      : '${end!.day}/${end!.month}/${end!.year}'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                    try {
                      await _repo.draftChain(
                        bibleClubId: _bibleClubId!,
                        title: title.text.trim(),
                        dateStart:
                            '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}',
                        dateEnd: end == null
                            ? null
                            : '${end!.year}-${end!.month.toString().padLeft(2, '0')}-${end!.day.toString().padLeft(2, '0')}',
                      );
                      Navigator.pop(ctx, true);
                    } catch (e) {
                      setS(() => err = '$e');
                    }
                  },
                  child: const Text('Créer'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
