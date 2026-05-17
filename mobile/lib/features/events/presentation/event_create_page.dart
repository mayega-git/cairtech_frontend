import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/file_uploader.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/screen_header.dart';
import '../data/events_repository.dart';

class EventCreatePage extends StatefulWidget {
  const EventCreatePage({super.key});

  @override
  State<EventCreatePage> createState() => _EventCreatePageState();
}

class _EventCreatePageState extends State<EventCreatePage> {
  late final EventsRepository _repo = EventsRepository(sl());
  late final FileUploader _uploader = FileUploader(sl());

  final _title = TextEditingController();
  final _location = TextEditingController();
  String _type = 'NATIONAL_CONGRESS';
  DateTime _startDate = DateTime.now().add(const Duration(days: 30));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  DateTime? _endDate;
  int _maxPictures = 50;
  Uint8List? _imageBytes;
  String? _imageFileId;
  bool _uploadingImage = false;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
          source: ImageSource.gallery, imageQuality: 75, maxWidth: 1600);
      if (file == null) return;
      setState(() => _uploadingImage = true);
      final bytes = await file.readAsBytes();
      final id = await _uploader.uploadBytes(bytes: bytes, filename: file.name);
      setState(() {
        _imageBytes = bytes;
        _imageFileId = id;
        _uploadingImage = false;
      });
    } catch (e) {
      setState(() => _uploadingImage = false);
      _toast('Erreur upload: $e');
    }
  }

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty) {
      setState(() => _error = 'Titre requis');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final startInstant = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _startTime.hour,
        _startTime.minute,
      ).toUtc().toIso8601String();
      final endInstant = _endDate == null
          ? null
          : DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59)
              .toUtc()
              .toIso8601String();
      await _repo.plan(
        title: _title.text.trim(),
        type: _type,
        plannedStart: startInstant,
        plannedEnd: endInstant,
        location: _location.text.trim().isEmpty ? null : _location.text.trim(),
        maxPictures: _maxPictures,
        imageFileId: _imageFileId,
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

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

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
                  Text('NOUVEL ÉVÉNEMENT',
                      style: AppTypography.mono(
                          size: 10,
                          letterSpacing: 1.6,
                          color: AppColors.muted)),
                  const SizedBox(width: 36),
                ],
              ),
            ),
            const ScreenHeader(
              eyebrow: 'NATIONAL',
              title: 'Programmer un événement',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                children: [
                  _imagePicker(),
                  const SizedBox(height: 14),
                  _label('Type'),
                  const SizedBox(height: 6),
                  _typeChooser(),
                  const SizedBox(height: 14),
                  _label('Titre'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _title,
                    decoration: const InputDecoration(
                        hintText: 'Congrès National CHF 2026'),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Date début'),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 730)),
                                );
                                if (picked != null) {
                                  setState(() => _startDate = picked);
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(),
                                child:
                                    Text(_formatDate(_startDate)),
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
                            _label('Heure'),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final picked = await showTimePicker(
                                    context: context,
                                    initialTime: _startTime);
                                if (picked != null) {
                                  setState(() => _startTime = picked);
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(),
                                child: Text(
                                    '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _label('Date de fin (optionnel)'),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            _endDate ?? _startDate.add(const Duration(days: 1)),
                        firstDate: _startDate,
                        lastDate:
                            _startDate.add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => _endDate = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(),
                      child: Text(_endDate == null
                          ? '—'
                          : _formatDate(_endDate!)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _label('Lieu (optionnel)'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _location,
                    decoration: const InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Icon(Icons.location_on_outlined,
                            size: 16, color: AppColors.muted),
                      ),
                      prefixIconConstraints:
                          BoxConstraints(minWidth: 40, minHeight: 40),
                      hintText: 'Goma · Centre des Conférences',
                    ),
                  ),
                  const SizedBox(height: 14),
                  _label('Max photos'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _maxPictures.toDouble(),
                          min: 10,
                          max: 200,
                          divisions: 19,
                          activeColor: AppColors.ink,
                          inactiveColor: AppColors.hair,
                          label: '$_maxPictures',
                          onChanged: (v) =>
                              setState(() => _maxPictures = v.round()),
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          border: Border.all(color: AppColors.hair),
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                      : const Text("Créer l'événement"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePicker() {
    return InkWell(
      onTap: _uploadingImage ? null : _pickImage,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.hair, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        clipBehavior: Clip.antiAlias,
        child: _imageBytes != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(_imageBytes!, fit: BoxFit.cover),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: RoundIconButton(
                      dark: true,
                      onTap: () => setState(() {
                        _imageBytes = null;
                        _imageFileId = null;
                      }),
                      child: const Icon(Icons.close, size: 14),
                    ),
                  ),
                ],
              )
            : Center(
                child: _uploadingImage
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate_outlined,
                              size: 24, color: AppColors.muted),
                          const SizedBox(height: 6),
                          Text(
                            'AJOUTER UNE IMAGE D\'AFFICHE',
                            style: AppTypography.mono(
                                size: 10,
                                color: AppColors.muted,
                                letterSpacing: 1.4),
                          ),
                          const SizedBox(height: 2),
                          Text('Affiche, bannière ou visuel',
                              style: AppTypography.sans(
                                  size: 11, color: AppColors.muted2)),
                        ],
                      ),
              ),
      ),
    );
  }

  Widget _typeChooser() {
    final types = [
      ('NATIONAL_CONGRESS', 'Congrès', Icons.groups_outlined),
      ('NATIONAL_SUMMIT', 'Sommet', Icons.workspace_premium_outlined),
      ('CONFERENCE', 'Conférence', Icons.mic_external_on_outlined),
    ];
    return Row(
      children: [
        for (final (value, label, icon) in types) ...[
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _type = value),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                margin: EdgeInsets.only(right: value == 'CONFERENCE' ? 0 : 6),
                decoration: BoxDecoration(
                  color: _type == value
                      ? AppColors.ink
                      : AppColors.surface,
                  border: Border.all(
                      color: _type == value
                          ? AppColors.ink
                          : AppColors.hair),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  children: [
                    Icon(icon,
                        size: 18,
                        color: _type == value
                            ? Colors.white
                            : AppColors.ink),
                    const SizedBox(height: 4),
                    Text(label,
                        style: AppTypography.sans(
                            size: 11.5,
                            weight: FontWeight.w500,
                            color: _type == value
                                ? Colors.white
                                : AppColors.ink)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _label(String s) =>
      Text(s.toUpperCase(), style: AppTypography.eyebrow());

  String _formatDate(DateTime d) {
    const months = [
      'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
