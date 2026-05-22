import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/file_uploader.dart';
import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/chip_x.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/tag.dart';
import '../../members/data/member_models.dart';
import '../../members/data/member_repository.dart';
import '../data/meeting_models.dart';
import '../data/meeting_repository.dart';

class MeetingAttendancePage extends StatefulWidget {
  final String meetingId;
  const MeetingAttendancePage({super.key, required this.meetingId});

  @override
  State<MeetingAttendancePage> createState() => _MeetingAttendancePageState();
}

class _MeetingAttendancePageState extends State<MeetingAttendancePage> {
  late final MeetingRepository _meetingRepo = MeetingRepository(sl());
  late final MemberRepository _memberRepo = MemberRepository(sl());
  late final FileUploader _uploader = FileUploader(sl());

  MeetingDto? _meeting;
  List<MemberDto> _members = const [];
  final Set<String> _present = {};
  final Set<String> _teachers = {};
  final List<_UploadedPicture> _pictures = [];

  String _search = '';
  bool _loading = true;
  String? _error;
  bool _submitting = false;
  int _nbBelievers = 0;
  final _summaryCtrl = TextEditingController();

  String? get _bibleClubId {
    final s = sl<AuthBloc>().state;
    if (s is AuthAuthenticated) return s.user.bibleClubId;
    return null;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _summaryCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final m = await _meetingRepo.findById(widget.meetingId);
      final bbcId = m.bibleClubId ?? _bibleClubId;
      var members = <MemberDto>[];
      if (bbcId != null) {
        members = await _memberRepo.listByBibleClub(bbcId);
        // Pour CLASS_MEETING : filtre les membres du même niveau
        if (m.type == 'CLASS_MEETING' && m.levelId != null) {
          members = members
              .where((mm) => mm.levelId == m.levelId && mm.kind == 'STUDENT')
              .toList();
        } else {
          members = members
              .where((mm) =>
                  mm.status == 'ACTIVE' && mm.kind == 'STUDENT')
              .toList();
        }
      }
      members.sort((a, b) => a.id.compareTo(b.id));
      _summaryCtrl.text = m.summary ?? '';
      _nbBelievers = m.nbBelievers;
      setState(() {
        _meeting = m;
        _members = members;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _pickPhoto() async {
    final m = _meeting;
    if (m == null) return;
    if (_pictures.length >= m.maxPictures) {
      _toast('Maximum atteint : ${m.maxPictures} photo(s)');
      return;
    }
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
          source: ImageSource.gallery, imageQuality: 70, maxWidth: 1280);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      // Upload immédiat → fileId stocké
      final fileId =
          await _uploader.uploadBytes(bytes: bytes, filename: file.name);
      setState(() {
        _pictures.add(_UploadedPicture(
          fileId: fileId,
          filename: file.name,
          bytes: bytes,
        ));
      });
    } catch (e) {
      _toast('Erreur upload : $e');
    }
  }

  Future<void> _submit() async {
    final m = _meeting;
    if (m == null) return;
    if (_present.isEmpty) {
      _toast('Pointer au moins un membre');
      return;
    }
    if (_pictures.length > m.maxPictures) {
      _toast('Trop de photos (max ${m.maxPictures})');
      return;
    }
    setState(() => _submitting = true);
    try {
      final presents = <Map<String, dynamic>>[];
      for (final id in _present) {
        presents.add({
          'memberId': id,
          'role': _teachers.contains(id) ? 'TEACHER' : 'MEMBER',
        });
      }
      final pictures = _pictures
          .map((p) => {
                'fileId': p.fileId,
                'caption': p.filename,
              })
          .toList();
      await _meetingRepo.record(
        id: m.id,
        dateOccurred: _formatDateApi(m.dateOccurred ?? DateTime.now()),
        nbBelievers: _nbBelievers,
        summary: _summaryCtrl.text.trim().isEmpty
            ? null
            : _summaryCtrl.text.trim(),
        presents: presents,
        pictures: pictures,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _submitting = false);
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
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_meeting == null
                ? Center(
                    child: Text(_error ?? 'Réunion introuvable',
                        style: AppTypography.sans(
                            size: 13, color: AppColors.muted)))
                : _body(_meeting!)),
      ),
    );
  }

  Widget _body(MeetingDto m) {
    final filtered = _members
        .where((mm) =>
            _search.isEmpty ||
            mm.id.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Column(
      children: [
        _hero(m),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Pointer un membre…',
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            children: [
              ChipX('Tous · ${_members.length}', active: true),
              const SizedBox(width: 6),
              ChipX('Pointés · ${_present.length}'),
              const SizedBox(width: 6),
              ChipX('Restants · ${_members.length - _present.length}'),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (_, i) => _memberRow(filtered[i]),
          ),
        ),
        _bottomPanel(m),
      ],
    );
  }

  Widget _hero(MeetingDto m) {
    return Container(
      color: AppColors.ink,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RoundIconButton(
                dark: true,
                onTap: () => Navigator.of(context).pop(false),
                child: const Icon(Icons.arrow_back, size: 16),
              ),
              const TagX('POINTAGE', kind: TagKind.accent),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${_formatDate(m.plannedDate)} · ${m.plannedStartTime.substring(0, 5)}',
            style: AppTypography.eyebrow(
                color: Colors.white.withOpacity(0.55)),
          ),
          const SizedBox(height: 4),
          Text(
            m.title,
            style: AppTypography.serif(
                size: 22, color: Colors.white, letterSpacing: -0.3),
          ),
        ],
      ),
    );
  }

  Widget _memberRow(MemberDto mm) {
    final isPresent = _present.contains(mm.id);
    final isTeacher = _teachers.contains(mm.id);
    return InkWell(
      onTap: () {
        setState(() {
          if (isPresent) {
            _present.remove(mm.id);
            _teachers.remove(mm.id);
          } else {
            _present.add(mm.id);
          }
        });
      },
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(
            color: isPresent ? AppColors.ink : AppColors.hair,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Avatar(
              name: mm.id.substring(0, 2),
              size: AvatarSize.sm,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Membre ${mm.id.substring(0, 6)}',
                    style: AppTypography.sans(
                        size: 13.5, weight: FontWeight.w500),
                  ),
                  Text(
                    'Score ${mm.participationScore} · ${mm.faithfulPercentage.round()}%',
                    style: AppTypography.sans(
                        size: 11, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            if (isPresent)
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isTeacher) {
                      _teachers.remove(mm.id);
                    } else {
                      _teachers.add(mm.id);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TagX(
                    isTeacher ? 'ENSEIG.' : 'MEMBRE',
                    kind: isTeacher ? TagKind.accent : TagKind.defaultKind,
                  ),
                ),
              ),
            _checkCircle(isPresent),
          ],
        ),
      ),
    );
  }

  Widget _checkCircle(bool active) => Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: active ? AppColors.ink : AppColors.surface,
          border: Border.all(
              color: active ? AppColors.ink : AppColors.hair, width: 1.5),
          shape: BoxShape.circle,
        ),
        child: active
            ? const Icon(Icons.check, color: Colors.white, size: 14)
            : null,
      );

  Widget _bottomPanel(MeetingDto m) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.hair)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CROYANTS', style: AppTypography.eyebrow()),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _stepBtn(Icons.remove, () {
                          if (_nbBelievers > 0) {
                            setState(() => _nbBelievers--);
                          }
                        }),
                        SizedBox(
                          width: 50,
                          child: Center(
                            child: Text(
                              '$_nbBelievers',
                              style: AppTypography.serif(
                                  size: 18, letterSpacing: -0.3),
                            ),
                          ),
                        ),
                        _stepBtn(Icons.add,
                            () => setState(() => _nbBelievers++)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('PHOTOS (${_pictures.length}/${m.maxPictures})',
                            style: AppTypography.eyebrow()),
                        InkWell(
                          onTap: _pickPhoto,
                          child: Row(
                            children: [
                              const Icon(Icons.add_a_photo_outlined,
                                  size: 14, color: AppColors.ink),
                              const SizedBox(width: 4),
                              Text('Ajouter',
                                  style: AppTypography.mono(
                                      size: 10,
                                      color: AppColors.ink,
                                      weight: FontWeight.w600,
                                      letterSpacing: 1.2)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _pictures.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 4),
                        itemBuilder: (_, i) {
                          final p = _pictures[i];
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.surface2,
                                  borderRadius: BorderRadius.circular(6),
                                  border:
                                      Border.all(color: AppColors.hair),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child:
                                    Image.memory(p.bytes, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: -4,
                                right: -4,
                                child: InkWell(
                                  onTap: () => setState(
                                      () => _pictures.removeAt(i)),
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.hair),
                                    ),
                                    child: const Icon(Icons.close,
                                        size: 10),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('RÉSUMÉ DE L\'ENSEIGNEMENT',
              style: AppTypography.eyebrow()),
          const SizedBox(height: 4),
          TextField(
            controller: _summaryCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Texte du résumé (optionnel)…',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.check, size: 14),
              label: const Text('Clôturer le pointage'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.surface2,
            border: Border.all(color: AppColors.hair),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: AppColors.ink),
        ),
      );

  String _formatDate(DateTime d) {
    const days = ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM'];
    const months = [
      'JAN', 'FÉV', 'MAR', 'AVR', 'MAI', 'JUI',
      'JUL', 'AOÛ', 'SEP', 'OCT', 'NOV', 'DÉC'
    ];
    return '${days[d.weekday - 1]} ${d.day} ${months[d.month - 1]}';
  }

  String _formatDateApi(DateTime d) => Fmt.isoDate(d);
}

class _UploadedPicture {
  final String fileId;
  final String filename;
  final Uint8List bytes;
  _UploadedPicture({
    required this.fileId,
    required this.filename,
    required this.bytes,
  });
}
