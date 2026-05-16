import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/avatar.dart';
import '../../../../core/widgets/bar_progress.dart';
import '../../../../core/widgets/kpi_card.dart';
import '../../../../core/widgets/tag.dart';
import '../../../meetings/data/meeting_models.dart';
import '../../../members/data/member_models.dart';
import '../../data/dashboard_models.dart';

/// LeaderDashboard — KPI BBC + répartition par niveau + watchlist inactifs.
class LeaderDashboardBody extends StatelessWidget {
  final BibleClubDashboard dashboard;
  final List<MemberDto> members;
  final List<MeetingDto> meetings;

  const LeaderDashboardBody({
    super.key,
    required this.dashboard,
    required this.members,
    required this.meetings,
  });

  int get _nbActiveMembers =>
      members.where((m) => m.status == 'ACTIVE').length;

  int get _nbFaithful => members.where((m) => m.isFaithful).length;

  double get _avgFaithfulness {
    final active = members.where((m) => m.status == 'ACTIVE').toList();
    if (active.isEmpty) return 0;
    final sum = active.fold<double>(0, (s, m) => s + m.faithfulPercentage);
    return sum / active.length;
  }

  int get _nbMeetingsRecorded =>
      meetings.where((m) => m.status == MeetingStatus.recorded).length;

  int get _nbMeetingsPlanned => meetings
      .where((m) => m.status != MeetingStatus.cancelled)
      .length;

  int get _nbInactives =>
      members.where((m) => m.status == 'INACTIVE').length;

  /// Membres avec score faible — utilisés pour la veille d'inactivité.
  List<MemberDto> get _watchlist {
    final list = members
        .where((m) =>
            m.status == 'ACTIVE' &&
            m.kind == 'STUDENT' &&
            m.faithfulPercentage < 50)
        .toList()
      ..sort((a, b) => a.faithfulPercentage.compareTo(b.faithfulPercentage));
    return list.take(8).toList();
  }

  Map<String, _LevelStat> get _byLevel {
    final map = <String, _LevelStat>{};
    for (final m in members) {
      if (m.kind != 'STUDENT' || m.status != 'ACTIVE') continue;
      final key = m.levelId ?? '—';
      final st = map.putIfAbsent(key, () => _LevelStat());
      st.total++;
      if (m.isFaithful) st.faithful++;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // KPI grid 2x2
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: KpiCard(
                      label: 'Membres actifs',
                      value: '$_nbActiveMembers',
                      subtitle: '${members.length} au total',
                      icon: Icons.group_outlined,
                      accent: AppColors.positive,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: KpiCard(
                      label: 'Fidélité moy.',
                      value: '${_avgFaithfulness.round()}%',
                      subtitle: dashboard.goalNbFaithful == null
                          ? 'Sans objectif'
                          : 'Cible ${dashboard.goalNbFaithful}',
                      icon: Icons.trending_up,
                      accent: _avgFaithfulness >= 60
                          ? AppColors.positive
                          : AppColors.warn,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: KpiCard(
                      label: 'Réunions tenues',
                      value: '$_nbMeetingsRecorded',
                      subtitle: 'sur $_nbMeetingsPlanned planifiées',
                      icon: Icons.event_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: KpiCard(
                      label: 'Inactifs',
                      value: '$_nbInactives',
                      subtitle: 'Suivi requis',
                      icon: Icons.access_time,
                      accent: _nbInactives > 0
                          ? AppColors.danger
                          : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Objectif annuel
        if (dashboard.goalNbFaithful != null && dashboard.goalNbFaithful! > 0)
          _goalCard(),

        // Répartition par niveau
        _sectionHeader('Répartition par niveau'),
        _levelBreakdown(),

        // Veille d'inactivité
        _sectionHeader('Veille d\'inactivité',
            action: '${_watchlist.length} personne(s)'),
        _watchlistCard(),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _goalCard() {
    final goal = dashboard.goalNbFaithful!;
    final pct = goal == 0
        ? 0.0
        : (_nbFaithful / goal).clamp(0.0, 1.0).toDouble();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OBJECTIF FIDÈLES · ${dashboard.academicYear}',
            style: AppTypography.eyebrow(
                color: Colors.white.withOpacity(0.55)),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$_nbFaithful',
                style: AppTypography.serif(
                    size: 38,
                    color: Colors.white,
                    height: 1,
                    letterSpacing: -0.8),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '/ $goal',
                  style: AppTypography.mono(
                      size: 12,
                      color: Colors.white.withOpacity(0.55)),
                ),
              ),
              const Spacer(),
              Text(
                '${(pct * 100).toStringAsFixed(0)}%',
                style: AppTypography.serif(
                    size: 22, color: Colors.white, letterSpacing: -0.3),
              ),
            ],
          ),
          const SizedBox(height: 10),
          BarProgress(
            value: pct,
            color: Colors.white,
            track: Colors.white.withOpacity(0.18),
            height: 4,
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, {String? action}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        children: [
          Expanded(
              child: Text(title,
                  style: AppTypography.sans(
                      size: 13, weight: FontWeight.w600))),
          if (action != null)
            Text(action.toUpperCase(),
                style: AppTypography.mono(
                    size: 10,
                    letterSpacing: 1.3,
                    color: AppColors.muted)),
        ],
      ),
    );
  }

  Widget _levelBreakdown() {
    final byLevel = _byLevel;
    if (byLevel.isEmpty) {
      return _emptyCard('Aucun étudiant rattaché à un niveau.');
    }
    final entries = byLevel.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final palette = [
      AppColors.ink,
      AppColors.accent,
      AppColors.gold,
      AppColors.positive,
      AppColors.muted,
      AppColors.warn,
      AppColors.danger,
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.hair),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          for (int i = 0; i < entries.length; i++) ...[
            _levelRow(
              label: 'Niveau ${i + 1}',
              count: entries[i].value.total,
              faithful: entries[i].value.faithful,
              color: palette[i % palette.length],
            ),
            if (i < entries.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Widget _levelRow({
    required String label,
    required int count,
    required int faithful,
    required Color color,
  }) {
    final ratio = count == 0 ? 0.0 : faithful / count;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style: AppTypography.sans(
                      size: 12.5, weight: FontWeight.w500)),
            ),
            Text('${(ratio * 100).round()}%',
                style: AppTypography.mono(
                    size: 10.5, color: AppColors.muted)),
            const SizedBox(width: 10),
            Text(
              '$count',
              style: AppTypography.serif(
                  size: 16, letterSpacing: -0.2),
            ),
          ],
        ),
        const SizedBox(height: 6),
        BarProgress(value: ratio, color: color),
      ],
    );
  }

  Widget _watchlistCard() {
    final list = _watchlist;
    if (list.isEmpty) {
      return _emptyCard(
          'Tous les membres actifs sont au-dessus du seuil de fidélité.');
    }
    final colors = [AppColors.ink, AppColors.gold, AppColors.accent];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.hair),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          for (int i = 0; i < list.length; i++) ...[
            ListTile(
              leading: Avatar(
                name: list[i].id.substring(0, 2),
                size: AvatarSize.sm,
                color: colors[i % colors.length],
              ),
              title: Text(
                'Membre ${list[i].id.substring(0, 6)}',
                style:
                    AppTypography.sans(size: 13.5, weight: FontWeight.w500),
              ),
              subtitle: Text(
                'Fidélité ${list[i].faithfulPercentage.round()}% · '
                'score ${list[i].participationScore}',
                style: AppTypography.sans(size: 12, color: AppColors.muted),
              ),
              trailing: const TagX('À CONTACTER', kind: TagKind.warn),
            ),
            if (i < list.length - 1)
              const Divider(height: 1, color: AppColors.hair2),
          ],
        ],
      ),
    );
  }

  Widget _emptyCard(String msg) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.hair),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.muted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(msg,
                style:
                    AppTypography.sans(size: 12.5, color: AppColors.muted)),
          ),
        ],
      ),
    );
  }
}

class _LevelStat {
  int total = 0;
  int faithful = 0;
}
