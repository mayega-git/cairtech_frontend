import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/tag.dart';
import '../data/meeting_models.dart';
import '../data/meeting_repository.dart';

class MeetingDetailPage extends StatefulWidget {
  final String meetingId;
  const MeetingDetailPage({super.key, required this.meetingId});

  @override
  State<MeetingDetailPage> createState() => _MeetingDetailPageState();
}

class _MeetingDetailPageState extends State<MeetingDetailPage> {
  late final MeetingRepository _repo = MeetingRepository(sl());
  MeetingDto? _meeting;
  List<PresenceDto> _presences = const [];
  List<PictureDto> _pictures = const [];
  bool _loading = true;
  String? _error;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final m = await _repo.findById(widget.meetingId);
      List<PresenceDto> pres = const [];
      List<PictureDto> pics = const [];
      if (m.status == MeetingStatus.recorded) {
        final results = await Future.wait([
          _repo.listPresences(m.id),
          _repo.listPictures(m.id),
        ]);
        pres = results[0] as List<PresenceDto>;
        pics = results[1] as List<PictureDto>;
      }
      setState(() {
        _meeting = m;
        _presences = pres;
        _pictures = pics;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  bool _has(String code) {
    final s = sl<AuthBloc>().state;
    if (s is! AuthAuthenticated) return false;
    return s.user.hasPermission(code);
  }

  Future<void> _start() async {
    try {
      final m = await _repo.start(widget.meetingId);
      _changed = true;
      setState(() => _meeting = m);
    } catch (e) {
      _toast('$e');
    }
  }

  Future<void> _end() async {
    try {
      final m = await _repo.end(widget.meetingId);
      _changed = true;
      setState(() => _meeting = m);
    } catch (e) {
      _toast('$e');
    }
  }

  Future<void> _cancel() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Annuler la réunion ?',
            style: AppTypography.serif(size: 22)),
        content: Text(
          'Cette action est irréversible. La réunion ne sera pas comptée '
          'dans les scores de fidélité.',
          style: AppTypography.sans(size: 13, color: AppColors.muted),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final m = await _repo.cancel(widget.meetingId);
      _changed = true;
      setState(() => _meeting = m);
    } catch (e) {
      _toast('$e');
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final m = _meeting;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (m == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        _error ?? 'Réunion introuvable.',
                        style: AppTypography.sans(
                            size: 13, color: AppColors.muted),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : _content(m)),
      ),
    );
  }

  Widget _content(MeetingDto m) {
    return Column(
      children: [
        _hero(m),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            children: [
              _section('Informations', _info(m)),
              const SizedBox(height: 12),
              _section('Présences', _presencesBlock(m)),
              if (m.summary != null && m.summary!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _section('Résumé de l\'enseignement', _summary(m)),
              ],
              if (m.status == MeetingStatus.recorded &&
                  _pictures.isNotEmpty) ...[
                const SizedBox(height: 12),
                _section('Photos', _picturesBlock()),
              ],
            ],
          ),
        ),
        _actions(m),
      ],
    );
  }

  Widget _hero(MeetingDto m) {
    final dateStr = _formatDate(m.plannedDate);
    final time = m.plannedStartTime.substring(0, 5);
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
              _statusBadge(m.status),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '$dateStr · $time · ${_typeLabel(m.type)}',
            style: AppTypography.eyebrow(
                color: Colors.white.withOpacity(0.55)),
          ),
          const SizedBox(height: 6),
          Text(
            m.title,
            style: AppTypography.serif(
                size: 26,
                color: Colors.white,
                height: 1.15,
                letterSpacing: -0.4),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child:
                      _heroStat('PRÉSENTS', _presences.length.toString(), '')),
              Expanded(
                  child: _heroStat('CROYANTS',
                      m.nbBelievers.toString(), '')),
              Expanded(
                  child: _heroStat('PHOTOS',
                      _pictures.length.toString(), '/${m.maxPictures}')),
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
                    size: 22,
                    color: Colors.white,
                    height: 1,
                    letterSpacing: -0.3)),
            if (sub.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 3, left: 3),
                child: Text(sub,
                    style: AppTypography.sans(
                        size: 10, color: Colors.white.withOpacity(0.5))),
              ),
          ],
        ),
      ],
    );
  }

  Widget _statusBadge(MeetingStatus s) {
    return switch (s) {
      MeetingStatus.planned => const TagX('À VENIR'),
      MeetingStatus.ongoing => const TagX('EN COURS', kind: TagKind.danger),
      MeetingStatus.ended => const TagX('TERMINÉE', kind: TagKind.warn),
      MeetingStatus.recorded => const TagX('CLÔTURÉE', kind: TagKind.success),
      MeetingStatus.cancelled =>
        const TagX('ANNULÉE', kind: TagKind.defaultKind),
    };
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
          Text(title.toUpperCase(),
              style: AppTypography.eyebrow()),
          const SizedBox(height: 10),
          body,
        ],
      ),
    );
  }

  Widget _info(MeetingDto m) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _kv('Type', _typeLabel(m.type)),
        _kv('Date planifiée', _formatDate(m.plannedDate)),
        _kv('Heure', m.plannedStartTime.substring(0, 5)),
        if (m.dateOccurred != null)
          _kv('Date effective', _formatDate(m.dateOccurred!)),
        if (m.durationMinutes != null)
          _kv('Durée', '${m.durationMinutes} min'),
        _kv('Max photos', '${m.maxPictures}'),
      ],
    );
  }

  Widget _presencesBlock(MeetingDto m) {
    if (m.status != MeetingStatus.recorded) {
      return Text(
        'Les présences seront visibles ici après l\'enregistrement de la réunion.',
        style: AppTypography.sans(size: 12, color: AppColors.muted),
      );
    }
    if (_presences.isEmpty) {
      return Text(
        'Aucune présence enregistrée.',
        style: AppTypography.sans(size: 12, color: AppColors.muted),
      );
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        TagX('${_presences.where((p) => p.role == 'MEMBER').length} membres',
            kind: TagKind.ink),
        TagX('${_presences.where((p) => p.role == 'VISITOR').length} visiteurs'),
        TagX('${_presences.where((p) => p.role == 'TEACHER').length} enseignant',
            kind: TagKind.accent),
      ],
    );
  }

  Widget _summary(MeetingDto m) => Text(
        m.summary ?? '',
        style: AppTypography.sans(size: 13, color: AppColors.ink, height: 1.5),
      );

  Widget _picturesBlock() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _pictures
          .map((p) => Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  border: Border.all(color: AppColors.hair),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image_outlined,
                    size: 18, color: AppColors.muted),
              ))
          .toList(),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(
              width: 130,
              child: Text(
                k.toUpperCase(),
                style: AppTypography.mono(
                    size: 10, color: AppColors.muted, letterSpacing: 1.2),
              ),
            ),
            Expanded(
              child: Text(v,
                  style: AppTypography.sans(size: 13, weight: FontWeight.w500)),
            ),
          ],
        ),
      );

  Widget _actions(MeetingDto m) {
    final canRecord = _has('bbcms:meeting:record');
    final canStart = _has('bbcms:meeting:start');
    final canEnd = _has('bbcms:meeting:end');
    final canCancel = _has('bbcms:meeting:cancel');

    final actions = <Widget>[];

    switch (m.status) {
      case MeetingStatus.planned:
        if (canStart) {
          actions.add(_btnPrimary('Démarrer la réunion', Icons.play_arrow,
              () => _start()));
        }
        if (canCancel) {
          actions.add(_btnOutline('Annuler', _cancel,
              color: AppColors.danger));
        }
        break;
      case MeetingStatus.ongoing:
        if (canEnd) {
          actions.add(_btnPrimary('Clôturer la session', Icons.stop_circle,
              () => _end()));
        }
        if (canRecord) {
          actions.add(_btnOutline('Enregistrer les présences', () async {
            final ok =
                await context.push('${AppRoutes.meetingsBase}/${m.id}/record');
            if (ok == true) {
              _changed = true;
              _load();
            }
          }));
        }
        break;
      case MeetingStatus.ended:
        if (canRecord) {
          actions.add(_btnPrimary('Enregistrer les présences', Icons.check,
              () async {
            final ok =
                await context.push('${AppRoutes.meetingsBase}/${m.id}/record');
            if (ok == true) {
              _changed = true;
              _load();
            }
          }));
        }
        if (canCancel) {
          actions.add(_btnOutline('Annuler la réunion', _cancel,
              color: AppColors.danger));
        }
        break;
      case MeetingStatus.recorded:
        actions.add(_btnOutline('Voir les détails', () {}));
        break;
      case MeetingStatus.cancelled:
        actions.add(_btnOutline('Réunion annulée', () {}));
        break;
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.hair)),
      ),
      child: Column(
        children: [
          for (final w in actions) ...[
            SizedBox(width: double.infinity, child: w),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _btnPrimary(String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label),
    );
  }

  Widget _btnOutline(String label, VoidCallback onTap, {Color? color}) {
    return OutlinedButton(
      style: color == null
          ? null
          : OutlinedButton.styleFrom(
              foregroundColor: color,
              side: const BorderSide(color: AppColors.hair),
            ),
      onPressed: onTap,
      child: Text(label),
    );
  }

  String _formatDate(DateTime d) {
    const days = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi',
      'Vendredi', 'Samedi', 'Dimanche'
    ];
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${days[d.weekday - 1]} ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _typeLabel(String t) => switch (t) {
        'CLASS_MEETING' => 'Étude de classe',
        'JOINT_CLASS_MEETING' => 'Classe jointe',
        'JOINT_BBC_MEETING' => 'BBC jointe',
        'DEPARTMENTAL_MEETING' => 'Département',
        'LEADERS_MEETING' => 'Réunion des leaders',
        'GENERAL_MEETING' => 'Culte général',
        'ACADEMIC_MEETING' => 'Académique',
        'SPIRITUAL_RETREAT' => 'Retraite spirituelle',
        'PRAYER_MEETING' => 'Réunion de prière',
        'WELCOME_PARTY' => 'Accueil',
        'CONFERENCE' => 'Conférence',
        'FEAST' => 'Fête',
        _ => t,
      };
}
