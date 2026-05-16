import 'package:flutter/material.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/bar_progress.dart';
import '../../../core/widgets/donut.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/tag.dart';
import '../../members/data/member_repository.dart';
import '../../members/data/member_models.dart';
import '../data/intercession_repository.dart';

class PrayerChainDetailPage extends StatefulWidget {
  final String chainId;
  const PrayerChainDetailPage({super.key, required this.chainId});

  @override
  State<PrayerChainDetailPage> createState() => _PrayerChainDetailPageState();
}

class _PrayerChainDetailPageState extends State<PrayerChainDetailPage> {
  late final IntercessionRepository _repo = IntercessionRepository(sl());
  late final MemberRepository _memberRepo = MemberRepository(sl());

  Future<_Bundle>? _future;
  MemberDto? _me;

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
    _future = _load();
    setState(() {});
  }

  Future<_Bundle> _load() async {
    final results = await Future.wait([
      _repo.listChainsByBibleClub(_bibleClubId() ?? ''),
      _repo.listSlotsByChain(widget.chainId),
      _memberRepo.me(),
    ]);
    final chains = results[0] as List<PrayerChainDto>;
    final slots = results[1] as List<PrayerSlotDto>;
    _me = results[2] as MemberDto?;
    final chain = chains.firstWhere(
      (c) => c.id == widget.chainId,
      orElse: () => throw Exception('Chaîne introuvable'),
    );
    slots.sort((a, b) => a.dtStart.compareTo(b.dtStart));
    return _Bundle(chain: chain, slots: slots);
  }

  String? _bibleClubId() {
    final s = sl<AuthBloc>().state;
    if (s is AuthAuthenticated) return s.user.bibleClubId;
    return null;
  }

  Future<void> _coverSlot(PrayerSlotDto slot) async {
    if (_me == null) {
      _toast('Vous devez être membre BBC pour réserver un créneau');
      return;
    }
    final note = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Réserver le créneau',
            style: AppTypography.serif(size: 22)),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_formatTime(slot.dtStart)} → ${_formatTime(slot.dtEnd)}',
                style: AppTypography.serif(size: 20, letterSpacing: -0.3),
              ),
              Text('Soit ${slot.duration.inMinutes} min',
                  style: AppTypography.mono(
                      size: 11, color: AppColors.muted)),
              const SizedBox(height: 14),
              Text('SUJET DE PRIÈRE (OPTIONNEL)',
                  style: AppTypography.eyebrow()),
              const SizedBox(height: 4),
              TextField(
                controller: note,
                maxLines: 2,
                decoration: const InputDecoration(
                    hintText: 'Le réveil de la jeunesse…'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Réserver'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _repo.coverSlot(
        slotId: slot.id,
        intercessorMemberId: _me!.id,
        note: note.text.trim().isEmpty ? null : note.text.trim(),
      );
      _reload();
    } catch (e) {
      _toast('Erreur : $e');
    }
  }

  Future<void> _uncoverSlot(PrayerSlotDto slot) async {
    try {
      await _repo.uncoverSlot(slot.id);
      _reload();
    } catch (e) {
      _toast('Erreur : $e');
    }
  }

  Future<void> _startChain() async {
    try {
      await _repo.startChain(widget.chainId);
      _reload();
    } catch (e) {
      _toast('Erreur : $e');
    }
  }

  Future<void> _closeChain() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Clôturer la chaîne ?',
            style: AppTypography.serif(size: 22)),
        content: Text(
          'Aucun nouveau créneau ne pourra plus être réservé.',
          style: AppTypography.sans(size: 13, color: AppColors.muted),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clôturer'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _repo.closeChain(widget.chainId);
      _reload();
    } catch (e) {
      _toast('Erreur : $e');
    }
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: FutureBuilder<_Bundle>(
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
            final bundle = snap.data!;
            return _content(bundle);
          },
        ),
      ),
    );
  }

  Widget _content(_Bundle b) {
    final covered = b.slots.where((s) => s.covered).length;
    final total = b.slots.length;
    final ratio = total == 0 ? 0.0 : covered / total;

    return Column(
      children: [
        _hero(b.chain, covered, total, ratio),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                if (b.slots.isEmpty)
                  _emptySlots(b.chain)
                else ...[
                  _grid(b.slots),
                  const SizedBox(height: 16),
                  Text('CRÉNEAUX', style: AppTypography.eyebrow()),
                  const SizedBox(height: 8),
                  ...b.slots.map(_slotRow),
                ],
                if (_canManage) ...[
                  const SizedBox(height: 16),
                  _adminActions(b.chain),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _hero(PrayerChainDto c, int covered, int total, double ratio) {
    return Container(
      color: AppColors.ink,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
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
              switch (c.status) {
                'RUNNING' =>
                  const TagX('EN COURS', kind: TagKind.success),
                'DRAFT' => const TagX('BROUILLON'),
                _ => const TagX('CLÔTURÉE'),
              },
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CHAÎNE DE PRIÈRE',
                      style: AppTypography.eyebrow(
                          color: Colors.white.withOpacity(0.55)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c.title,
                      style: AppTypography.serif(
                          size: 26,
                          color: Colors.white,
                          letterSpacing: -0.4,
                          height: 1.1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Du ${c.dateStart.day}/${c.dateStart.month}'
                      '${c.dateEnd == null ? "" : " au ${c.dateEnd!.day}/${c.dateEnd!.month}"}',
                      style: AppTypography.sans(
                          size: 11.5, color: Colors.white.withOpacity(0.65)),
                    ),
                  ],
                ),
              ),
              Donut(
                value: ratio,
                size: 70,
                stroke: 4,
                color: Colors.white,
                track: Colors.white.withOpacity(0.14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$covered',
                        style: AppTypography.serif(
                            size: 18, color: Colors.white)),
                    Text('/$total',
                        style: AppTypography.mono(
                            size: 9, color: Colors.white.withOpacity(0.55))),
                  ],
                ),
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
          const SizedBox(height: 6),
          Text(
            '$covered / $total créneaux couverts',
            style: AppTypography.mono(
                size: 10,
                color: Colors.white.withOpacity(0.65),
                letterSpacing: 1.0),
          ),
        ],
      ),
    );
  }

  Widget _emptySlots(PrayerChainDto c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.hair),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          const Icon(Icons.access_time,
              size: 24, color: AppColors.muted),
          const SizedBox(height: 8),
          Text(
            'Aucun créneau configuré pour cette chaîne.',
            textAlign: TextAlign.center,
            style: AppTypography.sans(
                size: 13, color: AppColors.muted),
          ),
          if (_canManage) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _showAddSlotDialog(c),
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Ajouter des créneaux 1h sur 24h'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _grid(List<PrayerSlotDto> slots) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1.0,
      ),
      itemCount: slots.length,
      itemBuilder: (_, i) {
        final s = slots[i];
        final mine = _me != null && s.intercessorMemberId == _me!.id;
        return InkWell(
          onTap: () {
            if (s.covered && mine) {
              _uncoverSlot(s);
            } else if (!s.covered) {
              _coverSlot(s);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: mine
                  ? AppColors.ink
                  : (s.covered ? AppColors.surface2 : Colors.transparent),
              border: Border.all(
                  color: mine ? AppColors.ink : AppColors.hair),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              '${s.dtStart.hour.toString().padLeft(2, '0')}h',
              style: AppTypography.mono(
                  size: 9,
                  color: mine
                      ? Colors.white
                      : (s.covered ? AppColors.ink : AppColors.muted),
                  letterSpacing: 0.5),
            ),
          ),
        );
      },
    );
  }

  Widget _slotRow(PrayerSlotDto s) {
    final mine = _me != null && s.intercessorMemberId == _me!.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
            color: mine ? AppColors.ink : AppColors.hair,
            width: mine ? 1.5 : 1),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: s.covered
                  ? (mine ? AppColors.positive : AppColors.gold)
                  : AppColors.hair,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_formatTime(s.dtStart)} → ${_formatTime(s.dtEnd)}',
                  style: AppTypography.sans(
                      size: 13, weight: FontWeight.w500),
                ),
                if (s.note != null && s.note!.isNotEmpty)
                  Text(
                    s.note!,
                    style: AppTypography.sans(
                        size: 11.5, color: AppColors.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (mine)
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.hair),
                minimumSize: const Size(60, 32),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              onPressed: () => _uncoverSlot(s),
              child: const Text('Libérer'),
            )
          else if (s.covered)
            const TagX('PRIS', kind: TagKind.success)
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(70, 32),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              onPressed: () => _coverSlot(s),
              child: const Text('Réserver'),
            ),
        ],
      ),
    );
  }

  Widget _adminActions(PrayerChainDto c) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        border: Border.all(color: AppColors.hair),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ACTIONS LEADER', style: AppTypography.eyebrow()),
          const SizedBox(height: 10),
          if (c.isDraft) ...[
            OutlinedButton.icon(
              onPressed: () => _showAddSlotDialog(c),
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Générer 24 créneaux de 1h'),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startChain,
                icon: const Icon(Icons.play_arrow, size: 14),
                label: const Text('Démarrer la chaîne'),
              ),
            ),
          ],
          if (c.isRunning)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.hair),
              ),
              onPressed: _closeChain,
              icon: const Icon(Icons.stop_circle, size: 14),
              label: const Text('Clôturer la chaîne'),
            ),
        ],
      ),
    );
  }

  Future<void> _showAddSlotDialog(PrayerChainDto c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Générer 24 créneaux',
            style: AppTypography.serif(size: 22)),
        content: Text(
          'Crée 24 créneaux d\'une heure couvrant les prochaines 24h, '
          'à partir de maintenant.',
          style: AppTypography.sans(size: 13, color: AppColors.muted),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Générer'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final base = DateTime.now().toUtc();
      for (int i = 0; i < 24; i++) {
        final start = base.add(Duration(hours: i));
        final end = base.add(Duration(hours: i + 1));
        await _repo.addSlot(
          chainId: widget.chainId,
          start: start.toIso8601String(),
          end: end.toIso8601String(),
        );
      }
      _reload();
    } catch (e) {
      _toast('Erreur : $e');
    }
  }

  String _formatTime(DateTime d) {
    final local = d.toLocal();
    return '${local.day}/${local.month} ${local.hour.toString().padLeft(2, '0')}h${local.minute.toString().padLeft(2, '0')}';
  }
}

class _Bundle {
  final PrayerChainDto chain;
  final List<PrayerSlotDto> slots;
  _Bundle({required this.chain, required this.slots});
}
