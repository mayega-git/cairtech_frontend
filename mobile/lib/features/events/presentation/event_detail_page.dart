import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/api/api_config.dart';
import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/tag.dart';
import '../../members/data/member_models.dart';
import '../../members/data/member_repository.dart';
import '../data/events_repository.dart';

class EventDetailPage extends StatefulWidget {
  final String eventId;
  const EventDetailPage({super.key, required this.eventId});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late final EventsRepository _repo = EventsRepository(sl());
  late final MemberRepository _memberRepo = MemberRepository(sl());

  Future<_Bundle>? _future;
  MemberDto? _me;
  bool _changed = false;

  bool get _canPlan {
    final s = sl<AuthBloc>().state;
    if (s is! AuthAuthenticated) return false;
    return s.user.hasPermission('bbcms:event:plan');
  }

  bool get _canEnroll {
    final s = sl<AuthBloc>().state;
    if (s is! AuthAuthenticated) return false;
    return s.user.hasPermission('bbcms:event:enroll');
  }

  bool get _canMarkPresence {
    final s = sl<AuthBloc>().state;
    if (s is! AuthAuthenticated) return false;
    return s.user.hasPermission('bbcms:event:record-presence');
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
      _repo.findById(widget.eventId),
      _repo.listParticipations(widget.eventId).catchError((_) => <EventParticipationDto>[]),
      _memberRepo.me().catchError((_) => null),
    ]);
    _me = results[2] as MemberDto?;
    return _Bundle(
      event: results[0] as EventDto,
      participations: results[1] as List<EventParticipationDto>,
    );
  }

  Future<void> _openRegistration() async {
    try {
      await _repo.openRegistration(widget.eventId);
      _changed = true;
      _reload();
    } catch (e) {
      _toast('$e');
    }
  }

  Future<void> _start() async {
    try {
      await _repo.start(widget.eventId);
      _changed = true;
      _reload();
    } catch (e) {
      _toast('$e');
    }
  }

  Future<void> _end() async {
    try {
      await _repo.end(widget.eventId);
      _changed = true;
      _reload();
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
        title: Text("Annuler l'événement ?",
            style: AppTypography.serif(size: 22)),
        content: Text(
          'Toutes les inscriptions seront conservées mais l\'événement passera '
          'au statut ANNULÉ.',
          style:
              AppTypography.sans(size: 13, color: AppColors.muted, height: 1.5),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _repo.cancel(widget.eventId);
      _changed = true;
      _reload();
    } catch (e) {
      _toast('$e');
    }
  }

  Future<void> _enroll() async {
    if (_me == null) {
      _toast('Vous devez être membre CHF pour vous inscrire');
      return;
    }
    try {
      await _repo.enrollMember(eventId: widget.eventId, memberId: _me!.id);
      _toast('Inscription confirmée');
      _reload();
    } catch (e) {
      _toast('$e');
    }
  }

  Future<void> _markMyPresence() async {
    if (_me == null) return;
    try {
      await _repo.markPresent(
        eventId: widget.eventId,
        memberId: _me!.id,
        when: DateTime.now().toUtc().toIso8601String(),
      );
      _toast('Présence enregistrée ✓');
      _reload();
    } catch (e) {
      _toast('$e');
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
            return _content(snap.data!);
          },
        ),
      ),
    );
  }

  Widget _content(_Bundle b) {
    final e = b.event;
    final myEnrollment = _me == null
        ? null
        : b.participations
            .where((p) => p.memberId == _me!.id)
            .cast<EventParticipationDto?>()
            .firstWhere((p) => p != null, orElse: () => null);
    final isEnrolled = myEnrollment != null;
    final isPresent = myEnrollment?.present ?? false;

    return Column(
      children: [
        _hero(e),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                _section('Informations', _info(e)),
                const SizedBox(height: 12),
                _section(
                  'Participants (${b.participations.length})',
                  _participations(b.participations, e.status),
                ),
                if (_canPlan) ...[
                  const SizedBox(height: 16),
                  _adminActions(e),
                ],
              ],
            ),
          ),
        ),
        _bottomBar(e, isEnrolled, isPresent),
      ],
    );
  }

  Widget _hero(EventDto e) {
    final statusBadge = switch (e.status) {
      EventStatus.planned => const TagX('PLANIFIÉ'),
      EventStatus.registrationOpen =>
        const TagX('INSCRIPTIONS', kind: TagKind.success),
      EventStatus.ongoing => const TagX('EN COURS', kind: TagKind.danger),
      EventStatus.ended => const TagX('TERMINÉ'),
      EventStatus.cancelled => const TagX('ANNULÉ'),
    };
    return Container(
      color: AppColors.ink,
      child: Column(
        children: [
          if (e.imageFileId != null)
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl:
                        '${ApiConfig.apiBase}/files/${e.imageFileId}/url',
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: Colors.white.withOpacity(0.04)),
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.white.withOpacity(0.04),
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image_outlined,
                          size: 40, color: Colors.white24),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.ink.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 20,
                    child: RoundIconButton(
                      dark: true,
                      onTap: () => Navigator.pop(context, _changed),
                      child: const Icon(Icons.arrow_back, size: 16),
                    ),
                  ),
                  Positioned(top: 20, right: 20, child: statusBadge),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, e.imageFileId == null ? 14 : 20, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (e.imageFileId == null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RoundIconButton(
                        dark: true,
                        onTap: () => Navigator.pop(context, _changed),
                        child: const Icon(Icons.arrow_back, size: 16),
                      ),
                      statusBadge,
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
                Text(e.typeLabel.toUpperCase(),
                    style: AppTypography.eyebrow(
                        color: Colors.white.withOpacity(0.55))),
                const SizedBox(height: 4),
                Text(e.title,
                    style: AppTypography.serif(
                        size: 28,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        height: 1.1)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 12,
                        color: Colors.white.withOpacity(0.65)),
                    const SizedBox(width: 4),
                    Text(_formatDate(e.plannedStart),
                        style: AppTypography.sans(
                            size: 12,
                            color: Colors.white.withOpacity(0.65))),
                    if (e.location != null) ...[
                      const SizedBox(width: 10),
                      Icon(Icons.location_on_outlined,
                          size: 12,
                          color: Colors.white.withOpacity(0.65)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(e.location!,
                            style: AppTypography.sans(
                                size: 12,
                                color: Colors.white.withOpacity(0.65)),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, Widget body) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.hair),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(), style: AppTypography.eyebrow()),
            const SizedBox(height: 8),
            body,
          ],
        ),
      );

  Widget _info(EventDto e) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kv('Type', e.typeLabel),
          _kv('Statut', e.status.label),
          _kv('Début', _formatDateTime(e.plannedStart)),
          if (e.plannedEnd != null) _kv('Fin', _formatDateTime(e.plannedEnd!)),
          if (e.startedAt != null)
            _kv('Démarré', _formatDateTime(e.startedAt!)),
          if (e.endedAt != null) _kv('Terminé', _formatDateTime(e.endedAt!)),
          if (e.durationMinutes != null)
            _kv('Durée', '${e.durationMinutes} min'),
          _kv('Max photos', '${e.maxPictures}'),
        ],
      );

  Widget _participations(
      List<EventParticipationDto> list, EventStatus eventStatus) {
    if (list.isEmpty) {
      return Text('Aucun participant inscrit pour le moment.',
          style: AppTypography.sans(size: 12, color: AppColors.muted));
    }
    final present = list.where((p) => p.present).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TagX('${list.length} INSCRITS', kind: TagKind.ink),
            const SizedBox(width: 6),
            TagX('$present PRÉSENTS', kind: TagKind.success),
          ],
        ),
        if (eventStatus == EventStatus.ongoing && _canMarkPresence) ...[
          const SizedBox(height: 10),
          Text(
            'Astuce : tu peux marquer ta présence depuis le bouton bas.',
            style: AppTypography.sans(
                size: 11.5, color: AppColors.muted),
          ),
        ],
      ],
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(k.toUpperCase(),
                  style: AppTypography.mono(
                      size: 10,
                      color: AppColors.muted,
                      letterSpacing: 1.2)),
            ),
            Expanded(
              child: Text(v,
                  style: AppTypography.sans(
                      size: 13, weight: FontWeight.w500)),
            ),
          ],
        ),
      );

  Widget _adminActions(EventDto e) {
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
          Text('ACTIONS LEADER NATIONAL',
              style: AppTypography.eyebrow()),
          const SizedBox(height: 10),
          if (e.status == EventStatus.planned)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openRegistration,
                icon: const Icon(Icons.lock_open_outlined, size: 14),
                label: const Text('Ouvrir les inscriptions'),
              ),
            ),
          if (e.status == EventStatus.registrationOpen)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _start,
                icon: const Icon(Icons.play_arrow, size: 14),
                label: const Text("Démarrer l'événement"),
              ),
            ),
          if (e.status == EventStatus.ongoing)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _end,
                icon: const Icon(Icons.stop_circle, size: 14),
                label: const Text("Clôturer l'événement"),
              ),
            ),
          if (e.status == EventStatus.planned ||
              e.status == EventStatus.registrationOpen) ...[
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.hair),
                ),
                onPressed: _cancel,
                icon: const Icon(Icons.close, size: 14),
                label: const Text('Annuler'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bottomBar(EventDto e, bool isEnrolled, bool isPresent) {
    if (!_canEnroll && !_canMarkPresence) return const SizedBox.shrink();
    Widget action;
    if (e.status == EventStatus.cancelled || e.status == EventStatus.ended) {
      return const SizedBox.shrink();
    }
    if (e.status == EventStatus.ongoing) {
      if (isPresent) {
        action = OutlinedButton.icon(
          onPressed: null,
          style: OutlinedButton.styleFrom(
            disabledForegroundColor: AppColors.positive,
            side: const BorderSide(color: AppColors.hair),
          ),
          icon: const Icon(Icons.check_circle, size: 16),
          label: const Text('Vous êtes pointé(e) ✓'),
        );
      } else {
        action = ElevatedButton.icon(
          onPressed: _canMarkPresence ? _markMyPresence : null,
          icon: const Icon(Icons.check, size: 14),
          label: const Text('Pointer ma présence'),
        );
      }
    } else if (e.acceptsEnrollment) {
      if (isEnrolled) {
        action = OutlinedButton.icon(
          onPressed: null,
          style: OutlinedButton.styleFrom(
            disabledForegroundColor: AppColors.positive,
            side: const BorderSide(color: AppColors.hair),
          ),
          icon: const Icon(Icons.check_circle, size: 16),
          label: const Text('Inscription confirmée ✓'),
        );
      } else {
        action = ElevatedButton.icon(
          onPressed: _canEnroll ? _enroll : null,
          icon: const Icon(Icons.how_to_reg, size: 14),
          label: const Text("S'inscrire à l'événement"),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.hair)),
      ),
      child: SizedBox(width: double.infinity, child: action),
    );
  }

  String _formatDate(DateTime d) {
    final l = d.toLocal();
    const months = [
      'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
    ];
    return '${l.day} ${months[l.month - 1]} ${l.year}';
  }

  String _formatDateTime(DateTime d) {
    final l = d.toLocal();
    return '${_formatDate(d)} · ${l.hour.toString().padLeft(2, '0')}h${l.minute.toString().padLeft(2, '0')}';
  }
}

class _Bundle {
  final EventDto event;
  final List<EventParticipationDto> participations;
  _Bundle({required this.event, required this.participations});
}
