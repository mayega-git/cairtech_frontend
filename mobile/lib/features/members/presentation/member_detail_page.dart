import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/tag.dart';
import '../data/member_repository.dart';
import '../data/member_with_profile_dto.dart';

class MemberDetailPage extends StatefulWidget {
  final String memberId;
  const MemberDetailPage({super.key, required this.memberId});

  @override
  State<MemberDetailPage> createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends State<MemberDetailPage> {
  late final MemberRepository _repo = MemberRepository(sl());
  Future<MemberWithProfileDto>? _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.findByIdWithProfile(widget.memberId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: FutureBuilder<MemberWithProfileDto>(
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
            final m = snap.data!;
            return _content(m);
          },
        ),
      ),
    );
  }

  Widget _content(MemberWithProfileDto m) {
    return Column(
      children: [
        _hero(m),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              _section('Coordonnées', _coordinates(m)),
              const SizedBox(height: 12),
              _section('Engagements', _engagements(m)),
              const SizedBox(height: 12),
              _section('Participation', _participation(m)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _hero(MemberWithProfileDto m) {
    return Container(
      color: AppColors.ink,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RoundIconButton(
                dark: true,
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, size: 16),
              ),
              Row(
                children: [
                  if (m.userType != 'VISITOR') ...[
                    RoundIconButton(
                      dark: true,
                      onTap: () {},
                      child: const Icon(Icons.phone_outlined, size: 14),
                    ),
                    const SizedBox(width: 6),
                  ],
                  RoundIconButton(
                    dark: true,
                    onTap: () {},
                    child: const Icon(Icons.mail_outline, size: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: Avatar(
              name: m.displayName,
              size: AvatarSize.lg,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              m.kind == 'STUDENT'
                  ? 'ÉTUDIANT${m.gender == 'FEMALE' ? 'E' : ''}'
                  : (m.kind == 'MENTOR' ? 'MENTOR' : m.userType),
              style: AppTypography.eyebrow(
                  color: Colors.white.withOpacity(0.55)),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              m.displayName,
              style: AppTypography.serif(
                  size: 26,
                  color: Colors.white,
                  letterSpacing: -0.4),
            ),
          ),
          const SizedBox(height: 4),
          if (m.profession != null && m.profession!.isNotEmpty)
            Center(
              child: Text(
                m.profession!,
                style: AppTypography.sans(
                    size: 12, color: Colors.white.withOpacity(0.7)),
              ),
            ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                  child: _heroStat('FIDÉLITÉ',
                      '${m.faithfulPercentage.round()}', '%')),
              Expanded(
                  child: _heroStat(
                      'PRÉSENCES', '${m.participationScore}', '')),
              Expanded(
                  child: _heroStat(
                      'DÉPT.', '${m.departments.length}', '')),
              Expanded(
                child: _heroStat(
                    'STATUT',
                    m.isActive
                        ? '✓'
                        : (m.isInactive ? '!' : '·'),
                    m.status.toLowerCase()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String label, String value, String sub) {
    return Column(
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
                    size: 20,
                    color: Colors.white,
                    height: 1,
                    letterSpacing: -0.3)),
            if (sub.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 3, left: 3),
                child: Text(sub,
                    style: AppTypography.sans(
                        size: 9, color: Colors.white.withOpacity(0.55))),
              ),
          ],
        ),
      ],
    );
  }

  Widget _section(String title, Widget body) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.hair),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: AppTypography.eyebrow()),
          const SizedBox(height: 10),
          body,
        ],
      ),
    );
  }

  Widget _coordinates(MemberWithProfileDto m) {
    return Column(
      children: [
        _kv(Icons.mail_outline, 'Email', m.email),
        if (m.gender != null)
          _kv(Icons.person_outline, 'Genre',
              m.gender == 'FEMALE' ? 'Féminin' : 'Masculin'),
        if (m.dateOfBirth != null)
          _kv(Icons.cake_outlined, 'Né(e) le',
              _formatDate(m.dateOfBirth!)),
        _kv(Icons.badge_outlined, 'Compte', m.accountStatus),
      ],
    );
  }

  Widget _engagements(MemberWithProfileDto m) {
    if (m.departments.isEmpty) {
      return Text(
        'Aucun département assigné à ce membre.',
        style: AppTypography.sans(size: 12.5, color: AppColors.muted),
      );
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: m.departments
          .map((d) => TagX(_deptLabel(d), kind: TagKind.accent))
          .toList(),
    );
  }

  Widget _participation(MemberWithProfileDto m) {
    return Column(
      children: [
        _kv(Icons.trending_up, 'Score',
            '${m.participationScore} présences'),
        _kv(Icons.checklist_outlined, 'Fidélité',
            Fmt.percentBase100(m.faithfulPercentage, decimals: 1)),
        _kv(Icons.school_outlined, 'Type', m.kind),
        if (m.professionalPosition != null)
          _kv(Icons.workspace_premium_outlined, 'Rôle pro',
              m.professionalPosition!),
      ],
    );
  }

  Widget _kv(IconData icon, String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.hair),
              ),
              child: Icon(icon, size: 14, color: AppColors.ink),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    k.toUpperCase(),
                    style: AppTypography.mono(
                        size: 9,
                        color: AppColors.muted,
                        letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 1),
                  Text(v,
                      style: AppTypography.sans(
                          size: 13, weight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      );

  String _deptLabel(String dept) => switch (dept) {
        'INTERCESSOR' => 'Intercession',
        'DISCIPLE_MAKER' => 'Disciple maker',
        'CHARIS' => 'Charis',
        'DIVINE_SHAKERS' => 'Divine Shakers',
        'ACT_OF_CHRIST' => 'Act of Christ',
        'ACADEMICS' => 'Académie',
        'MIGHTY_MEN_OF_VALOR' => 'Mighty Men',
        'LADIES' => 'Ladies',
        _ => dept,
      };

  String _formatDate(DateTime d) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
