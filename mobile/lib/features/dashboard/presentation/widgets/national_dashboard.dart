import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/bar_progress.dart';
import '../../../../core/widgets/sparkline.dart';
import '../../../../core/widgets/tag.dart';
import '../../data/dashboard_models.dart';

/// NationalDashboard — total membres, sparkline, classement, carte simulée.
class NationalDashboardBody extends StatelessWidget {
  final NationalDashboard data;

  const NationalDashboardBody({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _heroNational(),
        _sectionHeader('Classement Bible Clubs', action: 'Fidélité'),
        _bbcRanking(),
        _sectionHeader('Carte des Bible Clubs'),
        _provinceMap(),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _heroNational() {
    // Génère une série symbolique à partir du total actuel.
    final total = data.nbMembersTotal;
    final faithful = data.nbFaithfulTotal;
    final faithfulRatio = total == 0 ? 0.0 : faithful / total;

    final series = List<double>.generate(
      11,
      (i) {
        final t = (i + 1) / 11;
        return (total * (0.7 + 0.3 * t)).toDouble();
      },
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.hair),
        borderRadius: BorderRadius.circular(AppRadius.xl - 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TOTAL MEMBRES ACTIFS · ${data.academicYear}',
              style: AppTypography.eyebrow()),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatNumber(data.nbMembersTotal),
                style: AppTypography.serif(
                    size: 56, height: 0.95, letterSpacing: -1.6),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${data.nbFaithfulTotal} fidèles (${(faithfulRatio * 100).round()}%)',
                  style: AppTypography.sans(
                      size: 12, color: AppColors.positive),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Sparkline(data: series, height: 56),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.hair)),
            ),
            child: Row(
              children: [
                Expanded(child: _stat('BBC', '${data.nbBibleClubs}')),
                Expanded(
                    child: _stat(
                        'Réunions', _formatNumber(data.nbMeetingsRecordedTotal))),
                Expanded(
                    child: _stat(
                        'Contrib.', _formatMoney(data.totalContributedTotal))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: AppTypography.serif(size: 22, letterSpacing: -0.4)),
        const SizedBox(height: 2),
        Text(label.toUpperCase(),
            style: AppTypography.mono(
                size: 9, color: AppColors.muted, letterSpacing: 1.3)),
      ],
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
                    size: 10, color: AppColors.muted, letterSpacing: 1.3)),
        ],
      ),
    );
  }

  Widget _bbcRanking() {
    final list = [...data.perBibleClub];
    list.sort((a, b) => b.faithfulRatio.compareTo(a.faithfulRatio));
    if (list.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.hair),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Text(
          'Aucun Bible Club configuré.',
          style: AppTypography.sans(size: 13, color: AppColors.muted),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.hair),
        borderRadius: BorderRadius.circular(AppRadius.lg - 2),
      ),
      child: Column(
        children: [
          for (int i = 0; i < list.length; i++) ...[
            _bbcRow(rank: i + 1, b: list[i]),
            if (i < list.length - 1)
              const Divider(height: 1, color: AppColors.hair2),
          ],
        ],
      ),
    );
  }

  Widget _bbcRow({required int rank, required BibleClubDashboard b}) {
    final pct = (b.faithfulRatio * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              rank.toString().padLeft(2, '0'),
              style: AppTypography.mono(
                  size: 11, color: AppColors.muted2),
            ),
          ),
          Expanded(
            child: Text(b.name,
                style: AppTypography.sans(
                    size: 13, weight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${b.nbMembers}M',
              textAlign: TextAlign.right,
              style:
                  AppTypography.mono(size: 11, color: AppColors.muted),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
              width: 60,
              child: BarProgress(
                  value: b.faithfulRatio.clamp(0.0, 1.0).toDouble(),
                  height: 3)),
          const SizedBox(width: 10),
          SizedBox(
            width: 32,
            child: Text(
              '$pct',
              textAlign: TextAlign.right,
              style: AppTypography.serif(size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _provinceMap() {
    // Représentation abstraite — proportionnelle au nb_membres par BBC.
    final list = data.perBibleClub;
    if (list.isEmpty) return const SizedBox.shrink();
    final maxMembers =
        list.fold<int>(0, (m, b) => b.nbMembers > m ? b.nbMembers : m);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.hair),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 160,
            child: CustomPaint(
              size: Size.infinite,
              painter: _BBCBubblePainter(list: list, maxMembers: maxMembers),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: AppColors.ink, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text('Membres actifs',
                      style: AppTypography.mono(
                          size: 10, color: AppColors.muted)),
                ],
              ),
              TagX('${list.length} BBC', kind: TagKind.defaultKind),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(num n) {
    final s = n.toString();
    final reversed = s.split('').reversed.toList();
    final chunks = <String>[];
    for (int i = 0; i < reversed.length; i += 3) {
      chunks.add(reversed.skip(i).take(3).toList().reversed.join());
    }
    return chunks.reversed.join(' ');
  }

  String _formatMoney(double v) {
    if (v >= 1000000) {
      return '${(v / 1000000).toStringAsFixed(1)}M';
    }
    if (v >= 1000) {
      return '${(v / 1000).toStringAsFixed(1)}K';
    }
    return v.toStringAsFixed(0);
  }
}

class _BBCBubblePainter extends CustomPainter {
  final List<BibleClubDashboard> list;
  final int maxMembers;

  _BBCBubblePainter({required this.list, required this.maxMembers});

  @override
  void paint(Canvas canvas, Size size) {
    final paintInk = Paint()..color = AppColors.ink;
    final paintGhost = Paint()..color = AppColors.ink.withOpacity(0.08);

    // Distribution simulée — répartit les BBC dans une grille pseudo-géographique.
    final cols = (list.length <= 4) ? 2 : 3;
    final rows = (list.length / cols).ceil();
    for (int i = 0; i < list.length; i++) {
      final col = i % cols;
      final row = i ~/ cols;
      final x = (col + 0.5) * size.width / cols;
      final y = (row + 0.5) * size.height / rows;
      final ratio =
          maxMembers == 0 ? 0.4 : (list[i].nbMembers / maxMembers).clamp(0.2, 1.0);
      final radius = 8 + ratio * 18;
      canvas.drawCircle(Offset(x, y), radius + 6, paintGhost);
      canvas.drawCircle(Offset(x, y), radius * 0.6, paintInk);

      // Petit label texte
      final tp = TextPainter(
        text: TextSpan(
          text: list[i].name.replaceAll('BBC · ', ''),
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 9,
            fontFamily: 'JetBrains Mono',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y + radius + 4));
    }
  }

  @override
  bool shouldRepaint(_BBCBubblePainter oldDelegate) =>
      oldDelegate.list != list;
}
