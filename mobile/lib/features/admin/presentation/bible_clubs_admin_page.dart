import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_config.dart';
import '../../../core/api/file_uploader.dart';
import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/tag.dart';
import '../data/bible_clubs_admin_repository.dart';

class BibleClubsAdminPage extends StatefulWidget {
  const BibleClubsAdminPage({super.key});

  @override
  State<BibleClubsAdminPage> createState() => _BibleClubsAdminPageState();
}

class _BibleClubsAdminPageState extends State<BibleClubsAdminPage> {
  late final BibleClubsAdminRepository _repo =
      BibleClubsAdminRepository(sl());
  late final FileUploader _uploader = FileUploader(sl());
  Future<List<BibleClubFullDto>>? _future;

  bool get _canCreate {
    final s = sl<AuthBloc>().state;
    if (s is! AuthAuthenticated) return false;
    return s.user.hasPermission('bbcms:bible-club:create');
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = _repo.list();
    setState(() {});
  }

  Future<void> _showCreateDialog() async {
    final name = TextEditingController();
    final school = TextEditingController();
    final goal = TextEditingController(text: '100');
    Uint8List? imageBytes;
    String? imageFileId;
    bool uploading = false;
    String? err;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setS) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg)),
            title:
                Text('Nouveau Bible Club', style: AppTypography.serif(size: 22)),
            content: SizedBox(
              width: 380,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: uploading
                          ? null
                          : () async {
                              try {
                                final picker = ImagePicker();
                                final file = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 75,
                                  maxWidth: 1600,
                                );
                                if (file == null) return;
                                setS(() => uploading = true);
                                final bytes = await file.readAsBytes();
                                final id = await _uploader.uploadBytes(
                                    bytes: bytes, filename: file.name);
                                setS(() {
                                  imageBytes = bytes;
                                  imageFileId = id;
                                  uploading = false;
                                });
                              } catch (e) {
                                setS(() {
                                  uploading = false;
                                  err = '$e';
                                });
                              }
                            },
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          border: Border.all(color: AppColors.hair),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imageBytes != null
                            ? Image.memory(imageBytes!, fit: BoxFit.cover)
                            : Center(
                                child: uploading
                                    ? const CircularProgressIndicator(
                                        strokeWidth: 2)
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                              Icons.add_photo_alternate_outlined,
                                              size: 22,
                                              color: AppColors.muted),
                                          const SizedBox(height: 4),
                                          Text(
                                              'IMAGE BBC',
                                              style: AppTypography.mono(
                                                  size: 10,
                                                  color: AppColors.muted,
                                                  letterSpacing: 1.4)),
                                        ],
                                      ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('NOM', style: AppTypography.eyebrow()),
                    const SizedBox(height: 4),
                    TextField(
                      controller: name,
                      decoration: const InputDecoration(
                          hintText: 'BBC · UNILU'),
                    ),
                    const SizedBox(height: 10),
                    Text('ÉCOLE / UNIVERSITÉ',
                        style: AppTypography.eyebrow()),
                    const SizedBox(height: 4),
                    TextField(
                      controller: school,
                      decoration: const InputDecoration(
                          hintText: 'Université de Lubumbashi'),
                    ),
                    const SizedBox(height: 10),
                    Text('OBJECTIF ANNUEL FIDÈLES',
                        style: AppTypography.eyebrow()),
                    const SizedBox(height: 4),
                    TextField(
                      controller: goal,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '100'),
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
                onPressed: () async {
                  if (name.text.trim().isEmpty) {
                    setS(() => err = 'Nom requis');
                    return;
                  }
                  try {
                    await _repo.create(
                      name: name.text.trim(),
                      schoolName: school.text.trim().isEmpty
                          ? null
                          : school.text.trim(),
                      goalNbFaithful: int.tryParse(goal.text),
                      dateCreated: Fmt.isoDate(DateTime.now()),
                      imageFileId: imageFileId,
                    );
                    Navigator.pop(ctx, true);
                  } catch (e) {
                    setS(() => err = '$e');
                  }
                },
                child: const Text('Créer'),
              ),
            ],
          );
        });
      },
    );
    if (ok == true) _reload();
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
                    onTap: () => context.canPop()
                        ? context.pop()
                        : context.go('/home'),
                    child: const Icon(Icons.arrow_back, size: 16),
                  ),
                  Row(
                    children: [
                      RoundIconButton(
                        onTap: _reload,
                        child: const Icon(Icons.refresh, size: 15),
                      ),
                      const SizedBox(width: 6),
                      if (_canCreate)
                        RoundIconButton(
                          onTap: _showCreateDialog,
                          child: const Icon(Icons.add, size: 16),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const ScreenHeader(
              eyebrow: 'NATIONAL · ADMIN',
              title: 'Bible Clubs',
              subtitle: 'Gestion des clubs, niveaux et reset annuel',
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _reload(),
                child: FutureBuilder<List<BibleClubFullDto>>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Text('Erreur: ${snap.error}',
                                style: AppTypography.sans(
                                    size: 12, color: AppColors.danger)),
                          ),
                        ],
                      );
                    }
                    final list = snap.data ?? const [];
                    if (list.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  const Icon(Icons.school_outlined,
                                      size: 32, color: AppColors.muted),
                                  const SizedBox(height: 12),
                                  Text('Aucun Bible Club configuré.',
                                      style: AppTypography.sans(
                                          size: 13, color: AppColors.muted)),
                                  if (_canCreate) ...[
                                    const SizedBox(height: 14),
                                    OutlinedButton.icon(
                                      onPressed: _showCreateDialog,
                                      icon: const Icon(Icons.add, size: 14),
                                      label: const Text('Créer un BBC'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _bbcCard(list[i]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bbcCard(BibleClubFullDto b) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: () async {
        await context.push('${AppRoutes.adminBibleClubsBase}/${b.id}');
        _reload();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.hair),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 90,
              height: 90,
              child: b.imageFileId != null
                  ? CachedNetworkImage(
                      imageUrl:
                          '${ApiConfig.apiBase}/files/${b.imageFileId}/url',
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: AppColors.surface2),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.surface2,
                        alignment: Alignment.center,
                        child: const Icon(Icons.school_outlined,
                            size: 24, color: AppColors.muted),
                      ),
                    )
                  : Container(
                      color: AppColors.surface2,
                      alignment: Alignment.center,
                      child: const Icon(Icons.school_outlined,
                          size: 24, color: AppColors.muted),
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
                        Expanded(
                          child: Text(b.name,
                              style: AppTypography.sans(
                                  size: 14, weight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        _statusBadge(b.status),
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (b.schoolName != null)
                      Text(b.schoolName!,
                          style: AppTypography.sans(
                              size: 11.5, color: AppColors.muted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (b.goalNbFaithful != null)
                          Text('Obj. ${b.goalNbFaithful} fidèles',
                              style: AppTypography.mono(
                                  size: 10,
                                  color: AppColors.muted2,
                                  letterSpacing: 0.6)),
                        const Spacer(),
                        const Icon(Icons.chevron_right,
                            size: 16, color: AppColors.muted2),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String s) => switch (s) {
        'ACTIVE' => const TagX('ACTIF', kind: TagKind.success),
        'UNDER_RESET' => const TagX('RESET', kind: TagKind.warn),
        'ARCHIVED' => const TagX('ARCHIVÉ'),
        _ => TagX(s),
      };
}
