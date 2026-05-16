import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/chip_x.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/tag.dart';
import '../data/member_repository.dart';
import '../data/member_with_profile_dto.dart';

enum _Filter { all, active, students, pros, inactive, leaders }

class MembersTabPage extends StatefulWidget {
  const MembersTabPage({super.key});

  @override
  State<MembersTabPage> createState() => _MembersTabPageState();
}

class _MembersTabPageState extends State<MembersTabPage> {
  late final MemberRepository _repo = MemberRepository(sl());
  Future<List<MemberWithProfileDto>>? _future;
  _Filter _filter = _Filter.all;
  String _search = '';

  String? get _bibleClubId {
    final s = sl<AuthBloc>().state;
    if (s is AuthAuthenticated) return s.user.bibleClubId;
    return null;
  }

  bool get _canSeeRequests {
    final s = sl<AuthBloc>().state;
    if (s is! AuthAuthenticated) return false;
    return s.user.hasPermission('bbcms:membership-request:read');
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
      _future = _repo.listByBibleClubWithProfile(id);
    }
    setState(() {});
  }

  Iterable<MemberWithProfileDto> _applyFilter(List<MemberWithProfileDto> list) {
    final filtered = switch (_filter) {
      _Filter.all => list,
      _Filter.active => list.where((m) => m.isActive),
      _Filter.students => list.where((m) => m.kind == 'STUDENT'),
      _Filter.pros => list.where(
          (m) => m.kind == 'PROFESSIONAL' || m.kind == 'MENTOR'),
      _Filter.inactive => list.where((m) => m.isInactive),
      _Filter.leaders => list.where((m) => m.kind == 'NATIONAL_LEADER'),
    };
    if (_search.isEmpty) return filtered;
    final q = _search.toLowerCase();
    return filtered.where(
      (m) =>
          m.displayName.toLowerCase().contains(q) ||
          m.email.toLowerCase().contains(q) ||
          (m.profession?.toLowerCase().contains(q) ?? false),
    );
  }

  /// Groupe la liste par initiale de prénom (ordre alphabétique).
  Map<String, List<MemberWithProfileDto>> _groupByLetter(
      Iterable<MemberWithProfileDto> list) {
    final groups = <String, List<MemberWithProfileDto>>{};
    for (final m in list) {
      final letter = m.firstLetter;
      groups.putIfAbsent(letter, () => []).add(m);
    }
    final keys = groups.keys.toList()..sort();
    return {for (final k in keys) k: groups[k]!};
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScreenHeader(
          eyebrow: 'BBC · ANNUAIRE',
          title: 'Membres',
          actions: [
            RoundIconButton(
              onTap: _reload,
              child: const Icon(Icons.refresh, size: 15),
            ),
            const SizedBox(width: 6),
            if (_canSeeRequests)
              RoundIconButton(
                onTap: () => context.push(AppRoutes.membershipRequests),
                child: const Icon(Icons.how_to_reg_outlined, size: 16),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Rechercher un membre, une faculté…',
              prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Icon(Icons.search, size: 16, color: AppColors.muted),
              ),
              prefixIconConstraints:
                  BoxConstraints(minWidth: 40, minHeight: 40),
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            children: [
              for (final f in _Filter.values) ...[
                ChipX(_filterLabel(f),
                    active: _filter == f,
                    onTap: () => setState(() => _filter = f)),
                const SizedBox(width: 6),
              ],
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _reload(),
            child: FutureBuilder<List<MemberWithProfileDto>>(
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
                        child: Text('Erreur: ${snap.error}',
                            style: AppTypography.sans(
                                size: 12, color: AppColors.danger)),
                      ),
                    ],
                  );
                }
                final all = snap.data ?? const [];
                final filtered = _applyFilter(all).toList();
                if (filtered.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      Center(
                        child: Text(
                          all.isEmpty
                              ? 'Aucun membre rattaché à votre BBC.'
                              : 'Aucun membre ne correspond à cette recherche.',
                          style: AppTypography.sans(
                              size: 13, color: AppColors.muted),
                        ),
                      ),
                    ],
                  );
                }
                final groups = _groupByLetter(filtered);
                return ListView(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
                  children: [
                    for (final entry in groups.entries) ...[
                      _letterDivider(entry.key, entry.value.length),
                      for (final m in entry.value)
                        _MemberRow(
                          member: m,
                          onTap: () async {
                            await context.push(
                                '${AppRoutes.membersBase}/${m.id}');
                            _reload();
                          },
                        ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  String _filterLabel(_Filter f) => switch (f) {
        _Filter.all => 'Tous',
        _Filter.active => 'Actifs',
        _Filter.students => 'Étudiants',
        _Filter.pros => 'Pros',
        _Filter.inactive => 'Inactifs',
        _Filter.leaders => 'Leaders',
      };

  Widget _letterDivider(String letter, int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.hair),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(letter,
                style: AppTypography.mono(
                    size: 11,
                    weight: FontWeight.w600,
                    color: AppColors.ink)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.hair2,
            ),
          ),
          const SizedBox(width: 8),
          Text('$count',
              style: AppTypography.mono(
                  size: 10,
                  color: AppColors.muted2,
                  letterSpacing: 1.2)),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  final MemberWithProfileDto member;
  final VoidCallback onTap;
  const _MemberRow({required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scoreColor = member.isFaithful
        ? AppColors.ink
        : (member.faithfulPercentage > 0
            ? AppColors.warn
            : AppColors.danger);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border:
              Border(bottom: BorderSide(color: AppColors.hair2, width: 1)),
        ),
        child: Row(
          children: [
            Avatar(
              name: member.displayName,
              size: AvatarSize.sm,
              color: _colorFor(member),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.displayName,
                      style: AppTypography.sans(
                          size: 13.5, weight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle(member),
                    style: AppTypography.sans(
                        size: 11.5, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (member.kind == 'STUDENT')
              Text(
                '${member.faithfulPercentage.round()}',
                style: AppTypography.serif(
                    size: 18, letterSpacing: -0.3, color: scoreColor),
              )
            else
              TagX(member.kind == 'MENTOR' ? 'MENTOR' : 'PRO',
                  kind: TagKind.accent),
          ],
        ),
      ),
    );
  }

  Color _colorFor(MemberWithProfileDto m) {
    final hash = m.id.hashCode;
    const palette = [AppColors.ink, AppColors.accent, AppColors.gold];
    return palette[hash.abs() % palette.length];
  }

  String _subtitle(MemberWithProfileDto m) {
    final parts = <String>[];
    if (m.kind == 'STUDENT') {
      parts.add('Étudiant${m.gender == 'FEMALE' ? 'e' : ''}');
    } else if (m.kind == 'MENTOR') {
      parts.add('Mentor');
    } else if (m.kind == 'PROFESSIONAL') {
      parts.add('Professionnel');
    } else {
      parts.add('Leader national');
    }
    if (m.profession != null && m.profession!.isNotEmpty) {
      parts.add(m.profession!);
    }
    return parts.join(' · ');
  }
}
