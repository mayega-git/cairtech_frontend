import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_config.dart';
import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/tag.dart';
import '../data/events_repository.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late final EventsRepository _repo = EventsRepository(sl());
  Future<List<EventDto>>? _future;

  bool get _canPlan {
    final s = sl<AuthBloc>().state;
    if (s is! AuthAuthenticated) return false;
    return s.user.hasPermission('bbcms:event:plan');
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = _repo.list();
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
                      if (_canPlan)
                        RoundIconButton(
                          onTap: () async {
                            final ok =
                                await context.push(AppRoutes.eventCreate);
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
              eyebrow: 'NATIONAL · CHF',
              title: 'Événements',
              subtitle: 'Congrès, sommets, conférences',
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _reload(),
                child: FutureBuilder<List<EventDto>>(
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
                    final upcoming = all
                        .where((e) =>
                            e.status == EventStatus.planned ||
                            e.status == EventStatus.registrationOpen)
                        .toList()
                      ..sort((a, b) =>
                          a.plannedStart.compareTo(b.plannedStart));
                    final ongoing = all
                        .where((e) => e.status == EventStatus.ongoing)
                        .toList();
                    final past = all
                        .where((e) =>
                            e.status == EventStatus.ended ||
                            e.status == EventStatus.cancelled)
                        .toList()
                      ..sort((a, b) =>
                          b.plannedStart.compareTo(a.plannedStart));
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      children: [
                        if (ongoing.isNotEmpty) ...[
                          _heroEvent(ongoing.first),
                          if (ongoing.length > 1)
                            for (final e in ongoing.skip(1))
                              _eventCard(e),
                          const SizedBox(height: 8),
                        ] else if (upcoming.isNotEmpty)
                          _heroEvent(upcoming.first),
                        if (upcoming.isNotEmpty &&
                            ongoing.isEmpty) ...[
                          if (upcoming.length > 1) ...[
                            const SizedBox(height: 14),
                            _section('AUTRES ÉVÉNEMENTS À VENIR'),
                            for (final e in upcoming.skip(1)) _eventCard(e),
                          ],
                        ] else if (upcoming.isNotEmpty)
                          ...[
                            const SizedBox(height: 14),
                            _section('À VENIR'),
                            for (final e in upcoming) _eventCard(e),
                          ],
                        if (past.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _section('PASSÉS'),
                          for (final e in past) _eventCard(e),
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

  Widget _section(String s) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        child: Text(s, style: AppTypography.eyebrow()),
      );

  Widget _heroEvent(EventDto e) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      onTap: () async {
        await context.push('${AppRoutes.eventsBase}/${e.id}');
        _reload();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (e.imageFileId != null)
              SizedBox(
                height: 140,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl:
                      '${ApiConfig.apiBase}/files/${e.imageFileId}/url',
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: Colors.white.withOpacity(0.04)),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.white.withOpacity(0.04),
                    alignment: Alignment.center,
                    child: const Icon(Icons.event_outlined,
                        size: 40, color: Colors.white24),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _statusBadgeLight(e.status),
                      Text(_formatDate(e.plannedStart),
                          style: AppTypography.mono(
                              size: 11,
                              color: Colors.white.withOpacity(0.6),
                              letterSpacing: 1.0)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(e.title,
                      style: AppTypography.serif(
                          size: 28,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.1)),
                  const SizedBox(height: 6),
                  Text(e.typeLabel,
                      style: AppTypography.sans(
                          size: 12.5,
                          color: Colors.white.withOpacity(0.65))),
                  if (e.location != null && e.location!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 13,
                            color: Colors.white.withOpacity(0.6)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(e.location!,
                              style: AppTypography.sans(
                                  size: 12,
                                  color: Colors.white.withOpacity(0.65))),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadgeLight(EventStatus s) {
    return switch (s) {
      EventStatus.planned => const TagX('PLANIFIÉ'),
      EventStatus.registrationOpen =>
        const TagX('INSCRIPTIONS', kind: TagKind.success),
      EventStatus.ongoing => const TagX('EN COURS', kind: TagKind.danger),
      EventStatus.ended => const TagX('TERMINÉ'),
      EventStatus.cancelled => const TagX('ANNULÉ'),
    };
  }

  Widget _eventCard(EventDto e) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: () async {
        await context.push('${AppRoutes.eventsBase}/${e.id}');
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
        child: Row(
          children: [
            _dateBlock(e.plannedStart),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(e.title,
                            style: AppTypography.sans(
                                size: 14, weight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      _statusBadgeLight(e.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${e.typeLabel}${e.location == null ? "" : " · ${e.location}"}',
                    style: AppTypography.sans(
                        size: 11.5, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 16, color: AppColors.muted2),
          ],
        ),
      ),
    );
  }

  Widget _dateBlock(DateTime d) {
    const days = ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM'];
    const months = [
      'JAN', 'FÉV', 'MAR', 'AVR', 'MAI', 'JUI',
      'JUL', 'AOÛ', 'SEP', 'OCT', 'NOV', 'DÉC'
    ];
    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        border: Border.all(color: AppColors.hair),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(days[d.weekday - 1],
              style: AppTypography.mono(
                  size: 9, color: AppColors.muted, letterSpacing: 1.4)),
          const SizedBox(height: 2),
          Text(d.day.toString(),
              style: AppTypography.serif(
                  size: 20, height: 1, letterSpacing: -0.3)),
          const SizedBox(height: 2),
          Text(months[d.month - 1],
              style: AppTypography.mono(
                  size: 8, color: AppColors.muted2, letterSpacing: 1.4)),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

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
                  const Icon(Icons.event_outlined,
                      size: 32, color: AppColors.muted),
                  const SizedBox(height: 12),
                  Text(
                    'Aucun événement programmé.',
                    style: AppTypography.sans(
                        size: 13, color: AppColors.muted),
                  ),
                  if (_canPlan) ...[
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final ok = await context.push(AppRoutes.eventCreate);
                        if (ok == true) _reload();
                      },
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text('Programmer un événement'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
}
