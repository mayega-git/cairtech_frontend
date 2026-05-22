import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/chip_x.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/tag.dart';
import '../data/publication_models.dart';
import '../data/publication_repository.dart';

enum _Tab { verseToday, announcements, archives }

class SpiritualTabPage extends StatefulWidget {
  const SpiritualTabPage({super.key});

  @override
  State<SpiritualTabPage> createState() => _SpiritualTabPageState();
}

class _SpiritualTabPageState extends State<SpiritualTabPage> {
  late final PublicationRepository _repo = PublicationRepository(sl());
  _Tab _tab = _Tab.verseToday;

  Future<List<DailyVerseDto>>? _versesFuture;
  Future<List<AnnouncementDto>>? _announcementsFuture;

  bool get _canPublishVerse {
    final s = sl<AuthBloc>().state;
    if (s is! AuthAuthenticated) return false;
    return s.user.hasPermission('bbcms:publication:daily-verse');
  }

  bool get _canSeePrayerChain {
    final s = sl<AuthBloc>().state;
    if (s is! AuthAuthenticated) return false;
    return s.user.hasPermission('bbcms:intercession:read') ||
        s.user.hasPermission('bbcms:intercession:chain-manage');
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _versesFuture = _repo.listVerses();
    _announcementsFuture = _repo.listAnnouncements();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScreenHeader(
          eyebrow: 'SPIRITUEL',
          title: 'Verset & Annonces',
          actions: [
            RoundIconButton(
              onTap: _reload,
              child: const Icon(Icons.refresh, size: 15),
            ),
            const SizedBox(width: 6),
            if (_canSeePrayerChain)
              RoundIconButton(
                onTap: () => context.push(AppRoutes.prayerChains),
                child: const Icon(Icons.favorite_outline, size: 15),
              ),
          ],
        ),
        // Chips
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            children: [
              ChipX('Verset du jour',
                  active: _tab == _Tab.verseToday,
                  onTap: () => setState(() => _tab = _Tab.verseToday)),
              const SizedBox(width: 6),
              ChipX('Annonces',
                  active: _tab == _Tab.announcements,
                  onTap: () => setState(() => _tab = _Tab.announcements)),
              const SizedBox(width: 6),
              ChipX('Archives',
                  active: _tab == _Tab.archives,
                  onTap: () => setState(() => _tab = _Tab.archives)),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _reload(),
            child: switch (_tab) {
              _Tab.verseToday => _verseToday(),
              _Tab.announcements => _announcementsView(),
              _Tab.archives => _archivesView(),
            },
          ),
        ),
      ],
      // FAB conditionnel : créer un verset / annonce
    );
  }

  Widget _verseToday() {
    return FutureBuilder<List<DailyVerseDto>>(
      future: _versesFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return _err(snap.error);
        }
        final all = snap.data ?? const [];
        final published = all.where((v) => v.status == 'PUBLISHED').toList()
          ..sort((a, b) => b.publishDate.compareTo(a.publishDate));
        if (published.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 80),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(Icons.menu_book_outlined,
                          size: 32, color: AppColors.muted),
                      const SizedBox(height: 12),
                      Text(
                        'Aucun verset publié pour le moment.',
                        style: AppTypography.sans(
                            size: 13, color: AppColors.muted),
                        textAlign: TextAlign.center,
                      ),
                      if (_canPublishVerse) ...[
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final ok =
                                await context.push(AppRoutes.publicationCreate);
                            if (ok == true) _reload();
                          },
                          icon: const Icon(Icons.add, size: 14),
                          label: const Text('Publier un verset'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        final today = published.first;
        final rest = published.skip(1).toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            _todayVerseCard(today),
            const SizedBox(height: 18),
            if (rest.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Text('VERSETS RÉCENTS',
                    style: AppTypography.eyebrow()),
              ),
              ...rest.take(5).map(_verseCard),
            ],
            if (_canPublishVerse) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await context.push(AppRoutes.publicationCreate);
                    if (ok == true) _reload();
                  },
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Publier un verset / annonce'),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _todayVerseCard(DailyVerseDto v) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_dayLabel(v.publishDate)} · ${v.reference}'.toUpperCase(),
                style: AppTypography.eyebrow(
                    color: Colors.white.withOpacity(0.55)),
              ),
              Icon(Icons.add, size: 12, color: Colors.white.withOpacity(0.55)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '« ${v.verseText} »',
            style: AppTypography.serif(
              size: 26,
              color: Colors.white,
              height: 1.3,
              letterSpacing: -0.4,
            ),
          ),
          if (v.reflectionText != null && v.reflectionText!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              v.reflectionText!,
              style: AppTypography.sans(
                  size: 13,
                  color: Colors.white.withOpacity(0.75),
                  height: 1.55),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(Icons.favorite_outline,
                  size: 14, color: Colors.white.withOpacity(0.7)),
              const SizedBox(width: 4),
              Text(v.audience.toLowerCase(),
                  style: AppTypography.mono(
                      size: 10,
                      color: Colors.white.withOpacity(0.55),
                      letterSpacing: 1.2)),
              const Spacer(),
              Icon(Icons.share_outlined,
                  size: 14, color: Colors.white.withOpacity(0.7)),
              const SizedBox(width: 4),
              Text('PARTAGER',
                  style: AppTypography.mono(
                      size: 10,
                      color: Colors.white.withOpacity(0.55),
                      letterSpacing: 1.2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _verseCard(DailyVerseDto v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(v.reference,
                  style: AppTypography.mono(
                      size: 10,
                      color: AppColors.muted,
                      letterSpacing: 1.2)),
              Text(_dayLabel(v.publishDate),
                  style: AppTypography.mono(
                      size: 10,
                      color: AppColors.muted2,
                      letterSpacing: 1.0)),
            ],
          ),
          const SizedBox(height: 8),
          Text('« ${v.verseText} »',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.serif(
                  size: 15, color: AppColors.ink, height: 1.4)),
        ],
      ),
    );
  }

  Widget _announcementsView() {
    return FutureBuilder<List<AnnouncementDto>>(
      future: _announcementsFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) return _err(snap.error);
        final all = (snap.data ?? const [])
            .where((a) => a.status == 'PUBLISHED')
            .toList()
          ..sort((a, b) => b.publishDate.compareTo(a.publishDate));
        if (all.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 80),
              Center(
                child: Text(
                  'Aucune annonce publiée.',
                  style: AppTypography.sans(
                      size: 13, color: AppColors.muted),
                ),
              ),
            ],
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: all.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _announcementCard(all[i]),
        );
      },
    );
  }

  Widget _announcementCard(AnnouncementDto a) {
    final color = _colorForType(a.type);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.hair),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(AppRadius.lg),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TagX(_typeLabel(a.type), kind: _tagKindFor(a.type)),
                        const Spacer(),
                        Text(
                          _formatDate(a.publishDate),
                          style: AppTypography.mono(
                              size: 9,
                              color: AppColors.muted2,
                              letterSpacing: 1.2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(a.title,
                        style: AppTypography.sans(
                            size: 14.5, weight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(a.content,
                        style: AppTypography.sans(
                            size: 12.5, color: AppColors.muted, height: 1.5)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _archivesView() {
    return FutureBuilder<List<DailyVerseDto>>(
      future: _versesFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final all = (snap.data ?? const [])
            .where((v) => v.status == 'PUBLISHED')
            .toList()
          ..sort((a, b) => b.publishDate.compareTo(a.publishDate));
        if (all.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 80),
              Center(
                child: Text('Aucun verset archivé.',
                    style: AppTypography.sans(
                        size: 13, color: AppColors.muted)),
              ),
            ],
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: all.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _verseCard(all[i]),
        );
      },
    );
  }

  Widget _err(Object? e) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Text('Erreur: $e',
                style: AppTypography.sans(
                    size: 12, color: AppColors.danger)),
          ),
        ],
      );

  String _dayLabel(DateTime d) {
    const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    const months = [
      'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
    ];
    return '${days[d.weekday - 1]} ${d.day} ${months[d.month - 1]}';
  }

  String _formatDate(DateTime d) {
    const months = [
      'JAN', 'FÉV', 'MAR', 'AVR', 'MAI', 'JUI',
      'JUL', 'AOÛ', 'SEP', 'OCT', 'NOV', 'DÉC'
    ];
    return '${d.day.toString().padLeft(2, "0")} ${months[d.month - 1]}';
  }

  Color _colorForType(String type) => switch (type) {
        'CONGRESS' => AppColors.accent,
        'SUMMIT' => AppColors.gold,
        'BIRTHDAY' => AppColors.positive,
        'OBITUARY' => AppColors.danger,
        _ => AppColors.ink,
      };

  TagKind _tagKindFor(String type) => switch (type) {
        'CONGRESS' => TagKind.accent,
        'SUMMIT' => TagKind.defaultKind,
        'BIRTHDAY' => TagKind.success,
        'OBITUARY' => TagKind.danger,
        _ => TagKind.defaultKind,
      };

  String _typeLabel(String type) => switch (type) {
        'CONGRESS' => 'CONGRÈS',
        'SUMMIT' => 'SOMMET',
        'BIRTHDAY' => 'ANNIVERSAIRE',
        'OBITUARY' => 'NÉCROLOGIE',
        _ => 'ANNONCE',
      };
}
