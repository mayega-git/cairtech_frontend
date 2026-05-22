import 'package:flutter/material.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/bar_progress.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/tag.dart';
import '../../onboarding/data/public_registry_repository.dart';
import '../data/evangelism_repository.dart';

class EvangelismProgramDetailPage extends StatefulWidget {
  final String programId;
  const EvangelismProgramDetailPage({super.key, required this.programId});

  @override
  State<EvangelismProgramDetailPage> createState() =>
      _EvangelismProgramDetailPageState();
}

class _EvangelismProgramDetailPageState
    extends State<EvangelismProgramDetailPage> {
  late final EvangelismRepository _repo = EvangelismRepository(sl());
  late final PublicRegistryRepository _publicRepo =
      PublicRegistryRepository(sl());

  Future<_Bundle>? _future;
  bool _changed = false;
  List<BibleClubLite> _allBbcs = const [];

  bool get _canCreate {
    final s = sl<AuthBloc>().state;
    if (s is! AuthAuthenticated) return false;
    return s.user.hasPermission('bbcms:evangelism:program-create');
  }

  bool get _canRecord {
    final s = sl<AuthBloc>().state;
    if (s is! AuthAuthenticated) return false;
    return s.user.hasPermission('bbcms:evangelism:record-create');
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
    final program = await _repo.findById(widget.programId);
    final records = await _repo.listRecords(widget.programId);
    if (_allBbcs.isEmpty) {
      try {
        _allBbcs = await _publicRepo.listBibleClubs();
      } catch (_) {}
    }
    return _Bundle(program: program, records: records);
  }

  Future<void> _addDate(EvangelismProgramDto p) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    try {
      await _repo.addDate(
        programId: p.id,
        date: _formatApi(picked),
      );
      _changed = true;
      _reload();
    } catch (e) {
      _toast('$e');
    }
  }

  Future<void> _addBbc(EvangelismProgramDto p) async {
    final available =
        _allBbcs.where((b) => !p.bibleClubIds.contains(b.id)).toList();
    if (available.isEmpty) {
      _toast('Tous les BBC sont déjà ajoutés');
      return;
    }
    final picked = await showDialog<BibleClubLite>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text('Ajouter un BBC',
            style: AppTypography.serif(size: 22)),
        children: [
          for (final b in available)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, b),
              child: Text(b.name),
            ),
        ],
      ),
    );
    if (picked == null) return;
    try {
      await _repo.addBibleClub(programId: p.id, bibleClubId: picked.id);
      _changed = true;
      _reload();
    } catch (e) {
      _toast('$e');
    }
  }

  Future<void> _activate(EvangelismProgramDto p) async {
    if (p.dates.isEmpty) {
      _toast('Ajoute au moins une date avant d\'activer');
      return;
    }
    try {
      await _repo.activate(p.id);
      _changed = true;
      _reload();
    } catch (e) {
      _toast('$e');
    }
  }

  Future<void> _close(EvangelismProgramDto p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Clôturer le programme ?',
            style: AppTypography.serif(size: 22)),
        content: Text(
          'Les nouveaux croyants seront automatiquement liés à un disciple maker. '
          'Aucun nouveau compte rendu ne pourra plus être saisi.',
          style: AppTypography.sans(size: 13, color: AppColors.muted, height: 1.5),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clôturer'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _repo.close(p.id);
      _changed = true;
      _reload();
    } catch (e) {
      _toast('$e');
    }
  }

  Future<void> _addRecord(EvangelismProgramDto p) async {
    final preached = TextEditingController(text: '0');
    final believed = TextEditingController(text: '0');
    final encouraged = TextEditingController(text: '0');
    final tracts = TextEditingController(text: '0');
    final savedContacts = TextEditingController();
    final notes = TextEditingController();
    DateTime selectedDate = p.dates.firstWhere(
      (d) => !d.isAfter(DateTime.now()),
      orElse: () => p.dates.isEmpty ? DateTime.now() : p.dates.first,
    );
    String? err;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setS) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg)),
            title:
                Text('Compte rendu', style: AppTypography.serif(size: 22)),
            content: SizedBox(
              width: 380,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DATE (DOIT FIGURER DANS LE PROGRAMME)',
                        style: AppTypography.eyebrow()),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: p.dates
                          .map((d) => InkWell(
                                onTap: () => setS(() => selectedDate = d),
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: d == selectedDate
                                        ? AppColors.ink
                                        : AppColors.surface,
                                    border: Border.all(
                                        color: d == selectedDate
                                            ? AppColors.ink
                                            : AppColors.hair),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '${d.day}/${d.month}',
                                    style: AppTypography.mono(
                                        size: 11,
                                        color: d == selectedDate
                                            ? Colors.white
                                            : AppColors.ink,
                                        letterSpacing: 0.4),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    if (p.dates.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          'Aucune date n\'est encore planifiée pour ce programme.',
                          style: AppTypography.sans(
                              size: 12, color: AppColors.danger),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _numField('Prêchés', preached)),
                        const SizedBox(width: 6),
                        Expanded(child: _numField('Ont cru', believed)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _numField('Encouragés', encouraged)),
                        const SizedBox(width: 6),
                        Expanded(child: _numField('Tracts', tracts)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('NOTES (OPTIONNEL)',
                        style: AppTypography.eyebrow()),
                    const SizedBox(height: 4),
                    TextField(
                      controller: notes,
                      maxLines: 2,
                      decoration: const InputDecoration(
                          hintText: 'Lieu, contexte, retour…'),
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
                onPressed: p.dates.isEmpty
                    ? null
                    : () async {
                        try {
                          await _repo.record(
                            programId: p.id,
                            date: _formatApi(selectedDate),
                            preached: int.tryParse(preached.text) ?? 0,
                            believed: int.tryParse(believed.text) ?? 0,
                            encouraged: int.tryParse(encouraged.text) ?? 0,
                            tracts: int.tryParse(tracts.text) ?? 0,
                            notes: notes.text.trim().isEmpty
                                ? null
                                : notes.text.trim(),
                            savedContacts:
                                savedContacts.text.trim().isEmpty
                                    ? null
                                    : savedContacts.text.trim(),
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
    if (ok == true) {
      _changed = true;
      _reload();
    }
  }

  Widget _numField(String label, TextEditingController c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTypography.eyebrow()),
          const SizedBox(height: 4),
          TextField(
            controller: c,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: '0'),
          ),
        ],
      );

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  String _formatApi(DateTime d) => Fmt.isoDate(d);

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
            return _content(snap.data!);
          },
        ),
      ),
    );
  }

  Widget _content(_Bundle b) {
    final p = b.program;
    return Column(
      children: [
        _hero(p),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                _statsCard(p),
                const SizedBox(height: 14),
                _datesCard(p),
                const SizedBox(height: 14),
                _bbcsCard(p),
                const SizedBox(height: 14),
                _recordsSection(p, b.records),
                if (_canCreate) ...[
                  const SizedBox(height: 16),
                  _adminActions(p),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _hero(EvangelismProgramDto p) {
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
                onTap: () => Navigator.pop(context, _changed),
                child: const Icon(Icons.arrow_back, size: 16),
              ),
              switch (p.status) {
                'DRAFT' => const TagX('BROUILLON'),
                'ACTIVE' =>
                  const TagX('EN COURS', kind: TagKind.success),
                _ => const TagX('CLÔTURÉ'),
              },
            ],
          ),
          const SizedBox(height: 14),
          Text('PROGRAMME D\'ÉVANGÉLISATION',
              style:
                  AppTypography.eyebrow(color: Colors.white.withOpacity(0.55))),
          const SizedBox(height: 6),
          Text(
            p.title,
            style: AppTypography.serif(
                size: 26,
                color: Colors.white,
                letterSpacing: -0.4,
                height: 1.15),
          ),
          const SizedBox(height: 4),
          Text(
            p.type == 'INTERNAL_BBC' ? 'Programme interne BBC' : 'Programme joint',
            style: AppTypography.sans(
                size: 12, color: Colors.white.withOpacity(0.65)),
          ),
          const SizedBox(height: 14),
          BarProgress(
            value: p.ratio,
            color: Colors.white,
            track: Colors.white.withOpacity(0.14),
            height: 3,
          ),
        ],
      ),
    );
  }

  Widget _statsCard(EvangelismProgramDto p) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.hair),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(child: _stat('OBJECTIF', '${p.objectiveBelievers}')),
          Expanded(child: _stat('CRUS', '${p.totalSaved}')),
          Expanded(
            child: _stat('%', Fmt.amount(p.ratio * 100)),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTypography.mono(
                  size: 9,
                  color: AppColors.muted,
                  letterSpacing: 1.3)),
          const SizedBox(height: 2),
          Text(value,
              style: AppTypography.serif(
                  size: 22, letterSpacing: -0.3)),
        ],
      );

  Widget _datesCard(EvangelismProgramDto p) {
    return Container(
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
              Text('DATES PLANIFIÉES (${p.dates.length})',
                  style: AppTypography.eyebrow()),
              const Spacer(),
              if (_canCreate && !p.isClosed)
                TextButton.icon(
                  onPressed: () => _addDate(p),
                  icon: const Icon(Icons.add, size: 12),
                  label: Text('AJOUTER',
                      style: AppTypography.mono(
                          size: 10,
                          weight: FontWeight.w600,
                          letterSpacing: 1.4,
                          color: AppColors.ink)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (p.dates.isEmpty)
            Text('Aucune date planifiée.',
                style: AppTypography.sans(
                    size: 12, color: AppColors.muted))
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: p.dates
                  .map((d) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          border: Border.all(color: AppColors.hair),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${d.day}/${d.month}',
                          style: AppTypography.mono(
                              size: 11,
                              letterSpacing: 0.5,
                              color: AppColors.ink),
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _bbcsCard(EvangelismProgramDto p) {
    final bbcNames = p.bibleClubIds
        .map((id) => _allBbcs
            .firstWhere(
              (b) => b.id == id,
              orElse: () => BibleClubLite(id: id, name: id.substring(0, 8)),
            )
            .name)
        .toList();
    return Container(
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
              Text('BBC PARTICIPANTS (${p.bibleClubIds.length})',
                  style: AppTypography.eyebrow()),
              const Spacer(),
              if (_canCreate && !p.isClosed)
                TextButton.icon(
                  onPressed: () => _addBbc(p),
                  icon: const Icon(Icons.add, size: 12),
                  label: Text('AJOUTER',
                      style: AppTypography.mono(
                          size: 10,
                          weight: FontWeight.w600,
                          letterSpacing: 1.4,
                          color: AppColors.ink)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (bbcNames.isEmpty)
            Text('Aucun BBC associé.',
                style: AppTypography.sans(
                    size: 12, color: AppColors.muted))
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: bbcNames.map((n) => TagX(n)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _recordsSection(EvangelismProgramDto p, List<EvangelismRecordDto> records) {
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
                Text('COMPTES RENDUS (${records.length})',
                    style: AppTypography.eyebrow()),
                const Spacer(),
                if (_canRecord && p.isActive)
                  TextButton.icon(
                    onPressed: () => _addRecord(p),
                    icon: const Icon(Icons.add, size: 12),
                    label: Text('SAISIR',
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
              child: Text('Aucun compte rendu enregistré.',
                  style: AppTypography.sans(
                      size: 12, color: AppColors.muted)),
            )
          else
            for (int i = 0; i < records.length; i++) ...[
              _recordRow(records[i]),
              if (i < records.length - 1)
                const Divider(height: 1, color: AppColors.hair2),
            ],
        ],
      ),
    );
  }

  Widget _recordRow(EvangelismRecordDto r) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surface2,
                border: Border.all(color: AppColors.hair),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${r.date.day}',
                      style: AppTypography.serif(
                          size: 14, letterSpacing: -0.2)),
                  Text(_monthShort(r.date.month),
                      style: AppTypography.mono(
                          size: 7, color: AppColors.muted)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  TagX('${r.preached} PRÊCHÉS'),
                  TagX('${r.believed} CRUS', kind: TagKind.success),
                  TagX('${r.encouraged} ENC.', kind: TagKind.accent),
                  if (r.tracts > 0) TagX('${r.tracts} TRACTS'),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _adminActions(EvangelismProgramDto p) {
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
          if (p.isDraft)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _activate(p),
                icon: const Icon(Icons.play_arrow, size: 14),
                label: const Text('Activer le programme'),
              ),
            ),
          if (p.isActive)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.hair),
                ),
                onPressed: () => _close(p),
                icon: const Icon(Icons.stop_circle, size: 14),
                label: const Text('Clôturer le programme'),
              ),
            ),
        ],
      ),
    );
  }

  String _monthShort(int m) {
    const months = [
      'JAN', 'FÉV', 'MAR', 'AVR', 'MAI', 'JUI',
      'JUL', 'AOÛ', 'SEP', 'OCT', 'NOV', 'DÉC'
    ];
    return months[m - 1];
  }
}

class _Bundle {
  final EvangelismProgramDto program;
  final List<EvangelismRecordDto> records;
  _Bundle({required this.program, required this.records});
}
