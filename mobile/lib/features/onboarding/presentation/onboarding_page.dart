import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/file_uploader.dart';
import '../../../core/auth/auth_repository.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../data/public_registry_repository.dart';
import 'onboarding_cubit.dart';
import 'widgets/step_indicator.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingCubit>(
      create: (_) => OnboardingCubit(
        publicRegistry: PublicRegistryRepository(sl()),
        uploader: FileUploader(sl()),
        authRepository: sl<AuthRepository>(),
      ),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state.registered) {
          _showSuccessDialog(context);
        }
      },
      builder: (context, state) {
        final cubit = context.read<OnboardingCubit>();
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Column(
              children: [
                OnboardingTopBar(
                  step: state.step,
                  total: 4,
                  onBack: state.step > 1
                      ? cubit.back
                      : () => context.go(AppRoutes.login),
                  onClose: () => context.go(AppRoutes.login),
                ),
                StepProgress(step: state.step, total: 4),
                Expanded(child: _stepBody(context, state)),
                _bottomActions(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _stepBody(BuildContext context, OnboardingState state) {
    switch (state.step) {
      case 1:
        return _Step1Type(state: state);
      case 2:
        return _Step2Affiliation(state: state);
      case 3:
        return _Step3Profile(state: state);
      case 4:
      default:
        return _Step4Credentials(state: state);
    }
  }

  Widget _bottomActions(BuildContext context, OnboardingState state) {
    final cubit = context.read<OnboardingCubit>();
    final isLast = state.step == 4;
    final disabled = switch (state.step) {
          1 => !state.canGoNextFromStep1,
          2 => !state.canGoNextFromStep2,
          3 => !state.canGoNextFromStep3,
          4 => !state.canSubmit,
          _ => false,
        } ||
        state.submitting;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                state.errorMessage!,
                style: AppTypography.sans(size: 12, color: AppColors.danger),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: disabled
                  ? null
                  : () {
                      if (isLast) {
                        cubit.submit();
                      } else {
                        cubit.next();
                      }
                    },
              child: state.submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(isLast ? 'Soumettre la demande' : 'Continuer'),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 14),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Demande envoyée', style: AppTypography.serif(size: 22)),
        content: Text(
          "Votre compte a été créé et un email d'activation vous a été envoyé.\n\n"
          "Pour les étudiants et professionnels, votre demande d'adhésion est soumise "
          "à validation par un leader compétent.\n\n"
          "Vous pourrez vous connecter une fois votre compte activé.",
          style: AppTypography.sans(size: 13, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.login),
            child: const Text("Retour à la connexion"),
          ),
        ],
      ),
    );
  }
}

// ─── Étape 1 — Type ─────────────────────────────────────────────────
class _Step1Type extends StatelessWidget {
  final OnboardingState state;
  const _Step1Type({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    final options = [
      (
        OnboardingUserType.student,
        'Étudiant',
        "Membre régulier d'un club universitaire",
        Icons.menu_book_outlined,
      ),
      (
        OnboardingUserType.professional,
        'Professionnel',
        'Anciens & responsables, marché du travail',
        Icons.layers_outlined,
      ),
      (
        OnboardingUserType.visitor,
        'Visiteur',
        'Accompagnement temporaire, en discernement',
        Icons.favorite_outline,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ADHÉSION · PROFIL', style: AppTypography.eyebrow()),
          const SizedBox(height: 8),
          Text(
            'Quel est votre lien\nau Bible Club ?',
            style: AppTypography.serif(size: 32, height: 1.1, letterSpacing: -0.6),
          ),
          const SizedBox(height: 6),
          Text(
            'Le responsable national valide chaque demande sous 48 h.',
            style: AppTypography.sans(size: 13, color: AppColors.muted, height: 1.5),
          ),
          const SizedBox(height: 24),
          for (final (type, label, sub, icon) in options) ...[
            _typeCard(
              selected: state.type == type,
              label: label,
              sub: sub,
              icon: icon,
              onTap: () => cubit.selectType(type),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _typeCard({
    required bool selected,
    required String label,
    required String sub,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.surface,
          border: Border.all(color: selected ? AppColors.ink : AppColors.hair),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: selected ? Colors.white.withOpacity(0.15) : AppColors.hair,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 20, color: selected ? Colors.white : AppColors.ink),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.sans(
                      size: 15,
                      weight: FontWeight.w500,
                      color: selected ? Colors.white : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: AppTypography.sans(
                      size: 12,
                      color: selected
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: selected ? Colors.white : AppColors.hair,
                  width: 1.5,
                ),
                shape: BoxShape.circle,
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.ink, shape: BoxShape.circle),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Étape 2 — Affiliation ───────────────────────────────────────────
class _Step2Affiliation extends StatelessWidget {
  final OnboardingState state;
  const _Step2Affiliation({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ADHÉSION · AFFILIATION', style: AppTypography.eyebrow()),
          const SizedBox(height: 8),
          Text(
            switch (state.type) {
              OnboardingUserType.student => 'Quel BBC et quel niveau ?',
              OnboardingUserType.professional => 'Votre profession',
              OnboardingUserType.visitor => 'Statut visiteur',
            },
            style: AppTypography.serif(size: 28, height: 1.1, letterSpacing: -0.6),
          ),
          const SizedBox(height: 24),
          if (state.type == OnboardingUserType.student) ...[
            _label('Bible Club souhaité'),
            const SizedBox(height: 6),
            _bbcDropdown(context, cubit),
            const SizedBox(height: 18),
            _label('Niveau académique'),
            const SizedBox(height: 6),
            _levelDropdown(context, cubit),
          ] else if (state.type == OnboardingUserType.professional) ...[
            _label('Profession'),
            const SizedBox(height: 6),
            TextFormField(
              initialValue: state.profession ?? '',
              decoration: const InputDecoration(hintText: 'Ex: Pasteur, Ingénieur…'),
              onChanged: cubit.setProfession,
            ),
          ] else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.hair),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'En tant que visiteur, vous serez accompagné par un mentor BBC. '
                'Aucune affiliation à renseigner à cette étape.',
                style: AppTypography.sans(
                    size: 13, color: AppColors.muted, height: 1.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _label(String s) => Text(s.toUpperCase(), style: AppTypography.eyebrow());

  Widget _bbcDropdown(BuildContext context, OnboardingCubit cubit) {
    if (state.loadingBbcs) {
      return const SizedBox(
        height: 50,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (state.bibleClubs.isEmpty) {
      return Text(
        'Aucun Bible Club disponible — contactez votre leader national.',
        style: AppTypography.sans(size: 12, color: AppColors.muted),
      );
    }
    return DropdownButtonFormField<String>(
      value: state.selectedBbc?.id,
      isExpanded: true,
      decoration: const InputDecoration(),
      hint: const Text('Choisir un BBC'),
      items: state.bibleClubs
          .map((b) => DropdownMenuItem<String>(
                value: b.id,
                child: Text(
                  '${b.name}${b.schoolName == null ? '' : ' · ${b.schoolName}'}',
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      onChanged: (id) {
        final bbc = state.bibleClubs.firstWhere((b) => b.id == id);
        cubit.selectBibleClub(bbc);
      },
    );
  }

  Widget _levelDropdown(BuildContext context, OnboardingCubit cubit) {
    if (state.selectedBbc == null) {
      return Text(
        'Choisissez d\'abord un BBC.',
        style: AppTypography.sans(size: 12, color: AppColors.muted),
      );
    }
    if (state.loadingLevels) {
      return const SizedBox(
        height: 50,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (state.levels.isEmpty) {
      return Text(
        'Aucun niveau configuré pour ce BBC.',
        style: AppTypography.sans(size: 12, color: AppColors.muted),
      );
    }
    return DropdownButtonFormField<String>(
      value: state.selectedLevel?.id,
      isExpanded: true,
      decoration: const InputDecoration(),
      hint: const Text('Choisir un niveau'),
      items: state.levels
          .map((l) => DropdownMenuItem<String>(
                value: l.id,
                child: Text('${l.type} — ${l.name}'),
              ))
          .toList(),
      onChanged: (id) {
        final level = state.levels.firstWhere((l) => l.id == id);
        cubit.selectLevel(level);
      },
    );
  }
}

// ─── Étape 3 — Profil + Photo ───────────────────────────────────────
class _Step3Profile extends StatelessWidget {
  final OnboardingState state;
  const _Step3Profile({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ADHÉSION · PROFIL PERSONNEL', style: AppTypography.eyebrow()),
          const SizedBox(height: 8),
          Text('Apprenons à\nvous connaître',
              style: AppTypography.serif(size: 28, height: 1.1, letterSpacing: -0.6)),
          const SizedBox(height: 20),

          // Photo picker
          Center(
            child: _PhotoPicker(
              photoBytes: state.photoBytes,
              uploading: state.uploadingPhoto,
              onPick: (bytes, name) => cubit.uploadPhoto(bytes, name),
              onClear: cubit.clearPhoto,
            ),
          ),
          const SizedBox(height: 24),

          _label('Prénoms *'),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: state.firstNames,
            decoration: const InputDecoration(hintText: 'Ex: Marie'),
            onChanged: cubit.setFirstNames,
          ),
          const SizedBox(height: 14),
          _label('Nom de famille'),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: state.nextNames,
            decoration: const InputDecoration(hintText: 'Ex: Lukombo'),
            onChanged: cubit.setNextNames,
          ),
          const SizedBox(height: 14),
          _label('Genre *'),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _genderBtn(
                  label: 'Femme',
                  selected: state.gender == OnboardingGender.female,
                  onTap: () => cubit.setGender(OnboardingGender.female),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _genderBtn(
                  label: 'Homme',
                  selected: state.gender == OnboardingGender.male,
                  onTap: () => cubit.setGender(OnboardingGender.male),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _label('Date de naissance'),
          const SizedBox(height: 6),
          InkWell(
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: state.dateOfBirth ?? DateTime(now.year - 20),
                firstDate: DateTime(1900),
                lastDate: now,
              );
              if (picked != null) cubit.setDateOfBirth(picked);
            },
            child: InputDecorator(
              decoration: const InputDecoration(),
              child: Text(
                state.dateOfBirth == null
                    ? 'JJ/MM/AAAA'
                    : Fmt.date(state.dateOfBirth!),
                style: AppTypography.sans(
                  size: 15,
                  color: state.dateOfBirth == null ? AppColors.muted : AppColors.ink,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _label('Téléphone'),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: state.phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: '+243 …'),
            onChanged: cubit.setPhone,
          ),
        ],
      ),
    );
  }

  Widget _label(String s) => Text(s.toUpperCase(), style: AppTypography.eyebrow());

  Widget _genderBtn({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.surface,
          border: Border.all(color: selected ? AppColors.ink : AppColors.hair),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.sans(
              size: 14,
              weight: FontWeight.w500,
              color: selected ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

/// Cercle 96px + bouton flottant pour choisir une photo (galerie ou camera).
class _PhotoPicker extends StatelessWidget {
  final dynamic photoBytes; // Uint8List?
  final bool uploading;
  final void Function(dynamic bytes, String filename) onPick;
  final VoidCallback onClear;

  const _PhotoPicker({
    required this.photoBytes,
    required this.uploading,
    required this.onPick,
    required this.onClear,
  });

  Future<void> _pick(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    onPick(bytes, file.name);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.hair, width: 1.5),
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child: photoBytes != null
              ? Image.memory(photoBytes!, fit: BoxFit.cover)
              : const Center(
                  child: Icon(Icons.person, size: 38, color: AppColors.muted2),
                ),
        ),
        Positioned(
          bottom: -2,
          right: -2,
          child: InkWell(
            onTap: uploading ? null : () => _pick(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                  color: AppColors.ink, shape: BoxShape.circle),
              child: uploading
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Icon(
                      photoBytes == null
                          ? Icons.camera_alt_outlined
                          : Icons.edit_outlined,
                      size: 14,
                      color: Colors.white,
                    ),
            ),
          ),
        ),
        if (photoBytes != null && !uploading)
          Positioned(
            top: -4,
            right: -4,
            child: InkWell(
              onTap: onClear,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.hair),
                ),
                child: const Icon(Icons.close, size: 12),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Étape 4 — Email + Mot de passe ──────────────────────────────────
class _Step4Credentials extends StatefulWidget {
  final OnboardingState state;
  const _Step4Credentials({required this.state});

  @override
  State<_Step4Credentials> createState() => _Step4CredentialsState();
}

class _Step4CredentialsState extends State<_Step4Credentials> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ADHÉSION · CONNEXION', style: AppTypography.eyebrow()),
          const SizedBox(height: 8),
          Text(
            'Votre accès\nsécurisé',
            style: AppTypography.serif(size: 30, height: 1.1, letterSpacing: -0.6),
          ),
          const SizedBox(height: 6),
          Text(
            "Un email d'activation sera envoyé à l'adresse renseignée.",
            style: AppTypography.sans(size: 13, color: AppColors.muted, height: 1.5),
          ),
          const SizedBox(height: 24),
          _label('Adresse e-mail'),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: widget.state.email,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: const InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Icon(Icons.mail_outline, size: 18, color: AppColors.muted),
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 40, minHeight: 40),
              hintText: 'vous@chf.org',
            ),
            onChanged: cubit.setEmail,
          ),
          const SizedBox(height: 14),
          _label('Mot de passe (8+ caractères)'),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: widget.state.password,
            obscureText: _obscure,
            decoration: InputDecoration(
              prefixIcon: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Icon(Icons.lock_outline, size: 18, color: AppColors.muted),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 40, minHeight: 40),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.muted,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              hintText: '••••••••',
            ),
            onChanged: cubit.setPassword,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              border: Border.all(color: AppColors.hair),
              borderRadius: BorderRadius.circular(AppRadius.lg - 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RÉCAPITULATIF', style: AppTypography.eyebrow()),
                const SizedBox(height: 8),
                _row('Type', _userTypeLabel(widget.state.type)),
                if (widget.state.type == OnboardingUserType.student) ...[
                  if (widget.state.selectedBbc != null)
                    _row('Bible Club', widget.state.selectedBbc!.name),
                  if (widget.state.selectedLevel != null)
                    _row('Niveau', widget.state.selectedLevel!.name),
                ] else if (widget.state.type == OnboardingUserType.professional &&
                    widget.state.profession != null)
                  _row('Profession', widget.state.profession!),
                _row('Nom complet',
                    '${widget.state.firstNames} ${widget.state.nextNames}'),
                if (widget.state.gender != null)
                  _row(
                      'Genre',
                      widget.state.gender == OnboardingGender.female
                          ? 'Femme'
                          : 'Homme'),
                _row(
                  'Photo',
                  widget.state.uploadedPictureFileId == null
                      ? '— non fournie —'
                      : '✓ Uploadée',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String s) => Text(s.toUpperCase(), style: AppTypography.eyebrow());

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(label,
                  style: AppTypography.mono(
                      size: 10, letterSpacing: 1.2, color: AppColors.muted)),
            ),
            Expanded(
              child: Text(value,
                  style: AppTypography.sans(size: 13, weight: FontWeight.w500)),
            ),
          ],
        ),
      );

  String _userTypeLabel(OnboardingUserType t) => switch (t) {
        OnboardingUserType.student => 'Étudiant',
        OnboardingUserType.professional => 'Professionnel',
        OnboardingUserType.visitor => 'Visiteur',
      };
}
