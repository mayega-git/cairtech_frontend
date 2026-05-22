import 'package:flutter/material.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/screen_header.dart';
import '../../onboarding/data/public_registry_repository.dart';
import '../data/meeting_repository.dart';

/// Types les plus fréquents — d'autres types existent en BDD mais ne sont pas
/// exposés à la création directe (réservés aux jobs / migrations).
const _meetingTypes = [
  ('CLASS_MEETING', 'Étude', Icons.menu_book_outlined),
  ('PRAYER_MEETING', 'Prière', Icons.favorite_outline),
  ('GENERAL_MEETING', 'Culte', Icons.church_outlined),
  ('DEPARTMENTAL_MEETING', 'Dépt.', Icons.layers_outlined),
  ('LEADERS_MEETING', 'Leaders', Icons.workspace_premium_outlined),
  ('JOINT_CLASS_MEETING', 'Classes', Icons.group_outlined),
  ('JOINT_BBC_MEETING', 'Inter-BBC', Icons.public_outlined),
  ('SPIRITUAL_RETREAT', 'Retraite', Icons.self_improvement),
];

class MeetingCreatePage extends StatefulWidget {
  const MeetingCreatePage({super.key});

  @override
  State<MeetingCreatePage> createState() => _MeetingCreatePageState();
}

class _MeetingCreatePageState extends State<MeetingCreatePage> {
  late final MeetingRepository _repo = MeetingRepository(sl());
  late final PublicRegistryRepository _publicRepo =
      PublicRegistryRepository(sl());

  String _type = 'CLASS_MEETING';
  final _title = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 20, minute: 0);
  final _location = TextEditingController();
  int _maxPictures = 20;

  List<LevelLite> _levels = const [];
  LevelLite? _selectedLevel;
  bool _loadingLevels = false;

  bool _submitting = false;
  String? _error;

  String? get _bibleClubId {
    final s = sl<AuthBloc>().state;
    if (s is AuthAuthenticated) return s.user.bibleClubId;
    return null;
  }

  @override
  void initState() {
    super.initState();
    _title.text = 'Étude — Romains 8';
    _loadLevels();
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _loadLevels() async {
    final id = _bibleClubId;
    if (id == null) return;
    setState(() => _loadingLevels = true);
    try {
      final list = await _publicRepo.listLevels(id);
      setState(() {
        _levels = list;
        _loadingLevels = false;
      });
    } catch (_) {
      setState(() => _loadingLevels = false);
    }
  }

  bool get _requiresLevel => _type == 'CLASS_MEETING';

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty) {
      setState(() => _error = 'Titre requis');
      return;
    }
    if (_requiresLevel && _selectedLevel == null) {
      setState(() => _error = 'Niveau requis pour une étude de classe');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await _repo.plan(
        title: _title.text.trim(),
        type: _type,
        bibleClubId: _bibleClubId,
        levelId: _requiresLevel ? _selectedLevel?.id : null,
        plannedDate: _formatDateApi(_date),
        plannedStartTime: _formatTime(_startTime),
        plannedEndTime: _formatTime(_endTime),
        maxPictures: _maxPictures,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _error = '$e';
        _submitting = false;
      });
    }
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
                    onTap: () => Navigator.of(context).pop(false),
                    child: const Icon(Icons.close, size: 16),
                  ),
                  Text('NOUVELLE RÉUNION',
                      style: AppTypography.mono(
                          size: 10, letterSpacing: 1.6, color: AppColors.muted)),
                  const SizedBox(width: 36),
                ],
              ),
            ),
            const ScreenHeader(
              eyebrow: 'BROUILLON',
              title: 'Programmer une réunion',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                children: [
                  _label('Type de réunion'),
                  const SizedBox(height: 6),
                  _typeGrid(),
                  const SizedBox(height: 14),
                  _label('Titre de la réunion'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _title,
                    decoration: const InputDecoration(
                      hintText: 'Ex: Étude — Romains 8',
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_requiresLevel) ...[
                    _label('Niveau ciblé'),
                    const SizedBox(height: 6),
                    if (_loadingLevels)
                      const SizedBox(
                          height: 50,
                          child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2)))
                    else if (_levels.isEmpty)
                      Text('Aucun niveau configuré.',
                          style: AppTypography.sans(
                              size: 12, color: AppColors.muted))
                    else
                      DropdownButtonFormField<String>(
                        value: _selectedLevel?.id,
                        isExpanded: true,
                        decoration: const InputDecoration(),
                        hint: const Text('Choisir un niveau'),
                        items: _levels
                            .map((l) => DropdownMenuItem<String>(
                                  value: l.id,
                                  child: Text('${l.type} — ${l.name}'),
                                ))
                            .toList(),
                        onChanged: (id) {
                          setState(() {
                            _selectedLevel =
                                _levels.firstWhere((l) => l.id == id);
                          });
                        },
                      ),
                    const SizedBox(height: 14),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Date'),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _date,
                                  firstDate: DateTime.now()
                                      .subtract(const Duration(days: 365)),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 730)),
                                );
                                if (picked != null) {
                                  setState(() => _date = picked);
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(),
                                child: Text(_formatDate(_date)),
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
                            _label('Horaire'),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final start = await showTimePicker(
                                    context: context, initialTime: _startTime);
                                if (start == null) return;
                                final end = await showTimePicker(
                                    context: context, initialTime: _endTime);
                                setState(() {
                                  _startTime = start;
                                  if (end != null) _endTime = end;
                                });
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(),
                                child: Text(
                                    '${_formatTimeShort(_startTime)} → ${_formatTimeShort(_endTime)}'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _label('Lieu / salle (optionnel)'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _location,
                    decoration: const InputDecoration(
                      hintText: 'Salle B · Amphithéâtre',
                      prefixIcon: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Icon(Icons.location_on_outlined,
                            size: 16, color: AppColors.muted),
                      ),
                      prefixIconConstraints:
                          BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _label('Nombre max de photos'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _maxPictures.toDouble(),
                          min: 5,
                          max: 50,
                          divisions: 9,
                          activeColor: AppColors.ink,
                          inactiveColor: AppColors.hair,
                          label: '$_maxPictures',
                          onChanged: (v) =>
                              setState(() => _maxPictures = v.round()),
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          border: Border.all(color: AppColors.hair),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text('$_maxPictures',
                            style: AppTypography.serif(size: 14)),
                      ),
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: AppTypography.sans(
                            size: 12, color: AppColors.danger)),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Publier la réunion'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String s) =>
      Text(s.toUpperCase(), style: AppTypography.eyebrow());

  Widget _typeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.9,
      ),
      itemCount: _meetingTypes.length,
      itemBuilder: (_, i) {
        final (code, label, icon) = _meetingTypes[i];
        final selected = code == _type;
        return InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => setState(() => _type = code),
          child: Container(
            decoration: BoxDecoration(
              color: selected ? AppColors.ink : AppColors.surface,
              border: Border.all(
                  color: selected ? AppColors.ink : AppColors.hair),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 18, color: selected ? Colors.white : AppColors.ink),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: AppTypography.sans(
                    size: 11,
                    weight: FontWeight.w500,
                    color: selected ? Colors.white : AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _formatDateApi(DateTime d) => Fmt.isoDate(d);

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  String _formatTimeShort(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
