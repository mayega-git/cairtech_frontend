import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/screen_header.dart';
import '../data/publication_repository.dart';

enum _Kind { verse, announcement }

class PublicationCreatePage extends StatefulWidget {
  const PublicationCreatePage({super.key});

  @override
  State<PublicationCreatePage> createState() => _PublicationCreatePageState();
}

class _PublicationCreatePageState extends State<PublicationCreatePage> {
  late final PublicationRepository _repo = PublicationRepository(sl());

  _Kind _kind = _Kind.verse;
  final _title = TextEditingController();
  final _reference = TextEditingController(text: 'Ps. 23.1');
  final _verseText = TextEditingController();
  final _reflection = TextEditingController();
  final _content = TextEditingController();
  DateTime _publishDate = DateTime.now();
  String _audience = 'CHF';
  String _announcementType = 'CONGRESS';
  bool _publishNow = true;

  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _reference.dispose();
    _verseText.dispose();
    _reflection.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final dateStr = _formatDate(_publishDate);
      if (_kind == _Kind.verse) {
        if (_verseText.text.trim().isEmpty || _reference.text.trim().isEmpty) {
          setState(() {
            _error = 'Verset et référence requis';
            _submitting = false;
          });
          return;
        }
        final draft = await _repo.draftVerse(
          title: _title.text.trim().isEmpty
              ? 'Verset du ${_publishDate.day}/${_publishDate.month}'
              : _title.text.trim(),
          reference: _reference.text.trim(),
          verseText: _verseText.text.trim(),
          reflectionText: _reflection.text.trim().isEmpty
              ? null
              : _reflection.text.trim(),
          publishDate: dateStr,
          audience: _audience,
        );
        if (_publishNow) {
          await _repo.publishVerse(draft.id);
        }
      } else {
        if (_title.text.trim().isEmpty || _content.text.trim().isEmpty) {
          setState(() {
            _error = 'Titre et contenu requis';
            _submitting = false;
          });
          return;
        }
        final draft = await _repo.draftAnnouncement(
          title: _title.text.trim(),
          content: _content.text.trim(),
          type: _announcementType,
          publishDate: dateStr,
          audience: _audience,
        );
        if (_publishNow) {
          await _repo.publishAnnouncement(draft.id);
        }
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _error = '$e';
        _submitting = false;
      });
    }
  }

  String _formatDate(DateTime d) => Fmt.isoDate(d);

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
                  Text('NOUVELLE PUBLICATION',
                      style: AppTypography.mono(
                          size: 10,
                          letterSpacing: 1.6,
                          color: AppColors.muted)),
                  const SizedBox(width: 36),
                ],
              ),
            ),
            const ScreenHeader(
              eyebrow: 'BROUILLON',
              title: 'Publier un message',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                children: [
                  _label('Type'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _typeChoice('Verset du jour',
                            Icons.menu_book_outlined, _Kind.verse),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _typeChoice('Annonce spéciale',
                            Icons.campaign_outlined, _Kind.announcement),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_kind == _Kind.verse) ..._verseFields() else ..._announcementFields(),
                  const SizedBox(height: 14),
                  _label('Date de publication'),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _publishDate,
                        firstDate: DateTime.now()
                            .subtract(const Duration(days: 30)),
                        lastDate: DateTime.now()
                            .add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => _publishDate = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(),
                      child: Text(_displayDate(_publishDate)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _label('Audience'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _audience,
                    isExpanded: true,
                    decoration: const InputDecoration(),
                    items: const [
                      DropdownMenuItem(value: 'CHF', child: Text('Toute la CHF')),
                      DropdownMenuItem(value: 'BBC', child: Text('Mon BBC uniquement')),
                      DropdownMenuItem(value: 'LEVEL', child: Text('Mon niveau')),
                      DropdownMenuItem(value: 'DEPARTMENT', child: Text('Un département')),
                    ],
                    onChanged: (v) => setState(() => _audience = v!),
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Publier immédiatement',
                        style: AppTypography.sans(
                            size: 13.5, weight: FontWeight.w500)),
                    subtitle: Text(
                        _publishNow
                            ? 'Le message est diffusé maintenant.'
                            : 'Le message reste en brouillon (SCHEDULED).',
                        style: AppTypography.sans(
                            size: 11.5, color: AppColors.muted)),
                    value: _publishNow,
                    activeColor: AppColors.ink,
                    onChanged: (v) => setState(() => _publishNow = v),
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
                      : Text(_publishNow
                          ? 'Publier maintenant'
                          : 'Sauvegarder en brouillon'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChoice(String label, IconData icon, _Kind kind) {
    final selected = _kind == kind;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: () => setState(() => _kind = kind),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.surface,
          border:
              Border.all(color: selected ? AppColors.ink : AppColors.hair),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: selected ? Colors.white : AppColors.ink),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTypography.sans(
                  size: 13,
                  weight: FontWeight.w500,
                  color: selected ? Colors.white : AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _verseFields() => [
        _label('Titre (optionnel)'),
        const SizedBox(height: 6),
        TextField(
          controller: _title,
          decoration: const InputDecoration(hintText: 'Ex: Le bon berger'),
        ),
        const SizedBox(height: 14),
        _label('Référence biblique'),
        const SizedBox(height: 6),
        TextField(
          controller: _reference,
          decoration: const InputDecoration(hintText: 'Ps. 23.1'),
        ),
        const SizedBox(height: 14),
        _label('Texte du verset'),
        const SizedBox(height: 6),
        TextField(
          controller: _verseText,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: '« L\'Éternel est mon berger : je ne manquerai de rien. »',
          ),
        ),
        const SizedBox(height: 14),
        _label('Réflexion (optionnel)'),
        const SizedBox(height: 6),
        TextField(
          controller: _reflection,
          maxLines: 3,
          decoration: const InputDecoration(
              hintText: 'Une courte méditation pour accompagner le verset…'),
        ),
      ];

  List<Widget> _announcementFields() => [
        _label('Type d\'annonce'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _announcementType,
          isExpanded: true,
          decoration: const InputDecoration(),
          items: const [
            DropdownMenuItem(value: 'CONGRESS', child: Text('Congrès')),
            DropdownMenuItem(value: 'SUMMIT', child: Text('Sommet')),
            DropdownMenuItem(value: 'BIRTHDAY', child: Text('Anniversaire')),
            DropdownMenuItem(value: 'OBITUARY', child: Text('Nécrologie')),
            DropdownMenuItem(value: 'OTHER', child: Text('Autre')),
          ],
          onChanged: (v) => setState(() => _announcementType = v!),
        ),
        const SizedBox(height: 14),
        _label('Titre'),
        const SizedBox(height: 6),
        TextField(
          controller: _title,
          decoration: const InputDecoration(
              hintText: 'Camp national de jeunes — Goma 2026'),
        ),
        const SizedBox(height: 14),
        _label('Contenu'),
        const SizedBox(height: 6),
        TextField(
          controller: _content,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText:
                'Description, dates, lieu, places, modalités d\'inscription…',
          ),
        ),
      ];

  Widget _label(String s) =>
      Text(s.toUpperCase(), style: AppTypography.eyebrow());

  String _displayDate(DateTime d) {
    const months = [
      'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
