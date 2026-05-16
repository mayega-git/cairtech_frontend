import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/chip_x.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/tag.dart';
import '../data/meeting_models.dart';
import '../data/meeting_repository.dart';

enum _Filter { all, upcoming, ongoing, recorded }

class MeetingsTabPage extends StatefulWidget {
  const MeetingsTabPage({super.key});

  @override
  State<MeetingsTabPage> createState() => _MeetingsTabPageState();
}

class _MeetingsTabPageState extends State<MeetingsTabPage> {
  late final MeetingRepository _repo = MeetingRepository(sl());
  Future<List<MeetingDto>>? _future;
  _Filter _filter = _Filter.all;

  String? get _bibleClubId {
    final state = sl<AuthBloc>().state;
    if (state is AuthAuthenticated) return state.user.bibleClubId;
    return null;
  }

  bool get _canPlan {
    final state = sl<AuthBloc>().state;
    if (state is! AuthAuthenticated) return false;
    return state.user.hasPermission('bbcms:meeting:plan');
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
      _future = _repo.listByBibleClub(id);
    }
    setState(() {});
  }

  List<MeetingDto> _apply(List<MeetingDto> list) {
    final filtered = switch (_filter) {
      _Filter.all => list,
      _Filter.upcoming => list.where((m) => m.status == MeetingStatus.planned),
      _Filter.ongoing => list.where((m) => m.status == MeetingStatus.ongoing),
      _Filter.recorded =>
        list.where((m) => m.status == MeetingStatus.recorded || m.status == MeetingStatus.ended),
    }
        .toList()
      ..sort((a, b) => b.plannedStart.compareTo(a.plannedStart));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScreenHeader(
          eyebrow: 'BBC · RÉUNIONS',
          title: 'Mes réunions',
          actions: [
            RoundIconButton(
              onTap: _reload,
              child: const Icon(Icons.refresh, size: 15),
            ),
            const SizedBox(width: 6),
            if (_canPlan)
              RoundIconButton(
                onTap: () async {
                  final created = await context.push(AppRoutes.meetingCreate);
                  if (created == true) _reload();
                },
                child: const Icon(Icons.add, size: 16),
              ),
          ],
        ),
        // Chips filtres
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
            children: [
              ChipX('Toutes',
                  active: _filter == _Filter.all,
                  onTap: () => setState(() => _filter = _Filter.all)),
              const SizedBox(width: 6),
              ChipX('À venir',
                  active: _filter == _Filter.upcoming,
                  onTap: () => setState(() => _filter = _Filter.upcoming)),
              const SizedBox(width: 6),
              ChipX('En cours',
                  active: _filter == _Filter.ongoing,
                  onTap: () => setState(() => _filter = _Filter.ongoing)),
              const SizedBox(width: 6),
              ChipX('Tenues',
                  active: _filter == _Filter.recorded,
                  onTap: () => setState(() => _filter = _Filter.recorded)),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _reload(),
            child: FutureBuilder<List<MeetingDto>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      Center(
                        child: Text(
                          'Erreur: ${snap.error}',
                          style: AppTypography.sans(
                              size: 12, color: AppColors.danger),
                        ),
                      ),
                    ],
                  );
                }
                final all = snap.data ?? const [];
                final filtered = _apply(all);
                if (filtered.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      Center(
                        child: Text(
                          'Aucune réunion dans cette catégorie.',
                          style: AppTypography.sans(
                              size: 13, color: AppColors.muted),
                        ),
                      ),
                    ],
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _MeetingCard(
                    meeting: filtered[i],
                    onTap: () async {
                      final changed = await context.push(
                        '${AppRoutes.meetingsBase}/${filtered[i].id}',
                      );
                      if (changed == true) _reload();
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final MeetingDto meeting;
  final VoidCallback onTap;

  const _MeetingCard({required this.meeting, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final time = meeting.plannedStartTime.substring(0, 5);
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.hair),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            _dateBlock(meeting.plannedDate),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          meeting.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.sans(
                              size: 14, weight: FontWeight.w500),
                        ),
                      ),
                      _statusBadge(meeting.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 12, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Text(time,
                          style: AppTypography.sans(
                              size: 11.5, color: AppColors.muted)),
                      const SizedBox(width: 10),
                      TagX(_typeLabel(meeting.type)),
                    ],
                  ),
                  if (meeting.status == MeetingStatus.recorded &&
                      meeting.nbBelievers > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${meeting.nbBelievers} croyant${meeting.nbBelievers > 1 ? "s" : ""}',
                      style: AppTypography.sans(
                          size: 11, color: AppColors.positive),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: AppColors.muted2),
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
      width: 50,
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
              style:
                  AppTypography.serif(size: 22, height: 1, letterSpacing: -0.3)),
          const SizedBox(height: 2),
          Text(months[d.month - 1],
              style: AppTypography.mono(
                  size: 8, color: AppColors.muted2, letterSpacing: 1.4)),
        ],
      ),
    );
  }

  Widget _statusBadge(MeetingStatus s) {
    return switch (s) {
      MeetingStatus.planned => const TagX('À VENIR'),
      MeetingStatus.ongoing => const TagX('EN COURS', kind: TagKind.danger),
      MeetingStatus.ended => const TagX('TERMINÉE', kind: TagKind.warn),
      MeetingStatus.recorded => const TagX('CLÔTURÉE', kind: TagKind.success),
      MeetingStatus.cancelled =>
        const TagX('ANNULÉE', kind: TagKind.defaultKind),
    };
  }

  String _typeLabel(String t) => switch (t) {
        'CLASS_MEETING' => 'ÉTUDE',
        'JOINT_CLASS_MEETING' => 'JOINTE',
        'JOINT_BBC_MEETING' => 'INTER-BBC',
        'DEPARTMENTAL_MEETING' => 'DÉPT.',
        'LEADERS_MEETING' => 'LEADERS',
        'GENERAL_MEETING' => 'CULTE',
        'ACADEMIC_MEETING' => 'ACADÉM.',
        'SPIRITUAL_RETREAT' => 'RETRAITE',
        'PRAYER_MEETING' => 'PRIÈRE',
        'WELCOME_PARTY' => 'ACCUEIL',
        'CONFERENCE' => 'CONF.',
        'FEAST' => 'FÊTE',
        _ => t,
      };
}
