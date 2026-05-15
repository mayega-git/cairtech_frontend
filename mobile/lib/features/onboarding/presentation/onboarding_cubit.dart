import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/file_uploader.dart';
import '../../../core/auth/auth_repository.dart';
import '../../../core/errors/api_exception.dart';
import '../data/public_registry_repository.dart';

/// Types d'adhésion proposés à un nouveau membre (cf cahier UC-REG-01).
enum OnboardingUserType { student, professional, visitor }

extension OnboardingUserTypeApi on OnboardingUserType {
  String get backendName => switch (this) {
        OnboardingUserType.student => 'STUDENT',
        OnboardingUserType.professional => 'PROFESSIONAL',
        OnboardingUserType.visitor => 'VISITOR',
      };
}

/// Genre selon l'enum backend.
enum OnboardingGender { male, female }

extension OnboardingGenderApi on OnboardingGender {
  String get backendName => switch (this) {
        OnboardingGender.male => 'MALE',
        OnboardingGender.female => 'FEMALE',
      };
}

/// État unique du wizard (4 étapes).
class OnboardingState extends Equatable {
  final int step; // 1..4

  // Étape 1 — Type
  final OnboardingUserType type;

  // Étape 2 — Affiliation
  final List<BibleClubLite> bibleClubs;
  final List<LevelLite> levels;
  final BibleClubLite? selectedBbc;
  final LevelLite? selectedLevel;
  final String? profession;
  final bool loadingBbcs;
  final bool loadingLevels;

  // Étape 3 — Profil + photo
  final String firstNames;
  final String nextNames;
  final OnboardingGender? gender;
  final DateTime? dateOfBirth;
  final String? phone;
  final Uint8List? photoBytes;
  final String? photoFilename;
  final String? uploadedPictureFileId;
  final bool uploadingPhoto;

  // Étape 4 — Credentials
  final String email;
  final String password;

  // Workflow
  final bool submitting;
  final String? errorMessage;
  final bool registered;

  const OnboardingState({
    this.step = 1,
    this.type = OnboardingUserType.student,
    this.bibleClubs = const [],
    this.levels = const [],
    this.selectedBbc,
    this.selectedLevel,
    this.profession,
    this.loadingBbcs = false,
    this.loadingLevels = false,
    this.firstNames = '',
    this.nextNames = '',
    this.gender,
    this.dateOfBirth,
    this.phone,
    this.photoBytes,
    this.photoFilename,
    this.uploadedPictureFileId,
    this.uploadingPhoto = false,
    this.email = '',
    this.password = '',
    this.submitting = false,
    this.errorMessage,
    this.registered = false,
  });

  bool get canGoNextFromStep1 => true;

  bool get canGoNextFromStep2 {
    if (type == OnboardingUserType.student) {
      return selectedBbc != null && selectedLevel != null;
    }
    if (type == OnboardingUserType.professional) {
      return profession != null && profession!.trim().isNotEmpty;
    }
    return true; // VISITOR
  }

  bool get canGoNextFromStep3 =>
      firstNames.trim().isNotEmpty && gender != null;

  bool get canSubmit =>
      email.contains('@') && password.length >= 8 && !submitting;

  OnboardingState copyWith({
    int? step,
    OnboardingUserType? type,
    List<BibleClubLite>? bibleClubs,
    List<LevelLite>? levels,
    BibleClubLite? selectedBbc,
    LevelLite? selectedLevel,
    String? profession,
    bool? loadingBbcs,
    bool? loadingLevels,
    String? firstNames,
    String? nextNames,
    OnboardingGender? gender,
    DateTime? dateOfBirth,
    String? phone,
    Uint8List? photoBytes,
    String? photoFilename,
    String? uploadedPictureFileId,
    bool? uploadingPhoto,
    String? email,
    String? password,
    bool? submitting,
    String? errorMessage,
    bool? registered,
    bool clearError = false,
    bool clearPhoto = false,
    bool clearSelectedLevel = false,
  }) =>
      OnboardingState(
        step: step ?? this.step,
        type: type ?? this.type,
        bibleClubs: bibleClubs ?? this.bibleClubs,
        levels: levels ?? this.levels,
        selectedBbc: selectedBbc ?? this.selectedBbc,
        selectedLevel: clearSelectedLevel ? null : selectedLevel ?? this.selectedLevel,
        profession: profession ?? this.profession,
        loadingBbcs: loadingBbcs ?? this.loadingBbcs,
        loadingLevels: loadingLevels ?? this.loadingLevels,
        firstNames: firstNames ?? this.firstNames,
        nextNames: nextNames ?? this.nextNames,
        gender: gender ?? this.gender,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        phone: phone ?? this.phone,
        photoBytes: clearPhoto ? null : photoBytes ?? this.photoBytes,
        photoFilename: clearPhoto ? null : photoFilename ?? this.photoFilename,
        uploadedPictureFileId:
            clearPhoto ? null : uploadedPictureFileId ?? this.uploadedPictureFileId,
        uploadingPhoto: uploadingPhoto ?? this.uploadingPhoto,
        email: email ?? this.email,
        password: password ?? this.password,
        submitting: submitting ?? this.submitting,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
        registered: registered ?? this.registered,
      );

  @override
  List<Object?> get props => [
        step,
        type,
        bibleClubs,
        levels,
        selectedBbc,
        selectedLevel,
        profession,
        loadingBbcs,
        loadingLevels,
        firstNames,
        nextNames,
        gender,
        dateOfBirth,
        phone,
        photoBytes,
        photoFilename,
        uploadedPictureFileId,
        uploadingPhoto,
        email,
        password,
        submitting,
        errorMessage,
        registered,
      ];
}

class OnboardingCubit extends Cubit<OnboardingState> {
  final PublicRegistryRepository publicRegistry;
  final FileUploader uploader;
  final AuthRepository authRepository;

  OnboardingCubit({
    required this.publicRegistry,
    required this.uploader,
    required this.authRepository,
  }) : super(const OnboardingState()) {
    _loadBibleClubs();
  }

  // ─── Navigation ────────────────────────────────────────────────
  void next() {
    if (state.step >= 4) return;
    emit(state.copyWith(step: state.step + 1, clearError: true));
  }

  void back() {
    if (state.step <= 1) return;
    emit(state.copyWith(step: state.step - 1, clearError: true));
  }

  // ─── Étape 1 — Type ────────────────────────────────────────────
  void selectType(OnboardingUserType type) {
    emit(state.copyWith(
      type: type,
      selectedBbc: null,
      clearSelectedLevel: true,
      levels: const [],
    ));
  }

  // ─── Étape 2 — Affiliation ─────────────────────────────────────
  Future<void> _loadBibleClubs() async {
    emit(state.copyWith(loadingBbcs: true));
    try {
      final list = await publicRegistry.listBibleClubs();
      emit(state.copyWith(bibleClubs: list, loadingBbcs: false));
    } on ApiException catch (e) {
      emit(state.copyWith(loadingBbcs: false, errorMessage: e.message));
    }
  }

  Future<void> selectBibleClub(BibleClubLite bbc) async {
    emit(state.copyWith(
      selectedBbc: bbc,
      clearSelectedLevel: true,
      loadingLevels: true,
      levels: const [],
    ));
    try {
      final list = await publicRegistry.listLevels(bbc.id);
      emit(state.copyWith(levels: list, loadingLevels: false));
    } on ApiException catch (e) {
      emit(state.copyWith(loadingLevels: false, errorMessage: e.message));
    }
  }

  void selectLevel(LevelLite level) => emit(state.copyWith(selectedLevel: level));

  void setProfession(String profession) =>
      emit(state.copyWith(profession: profession));

  // ─── Étape 3 — Profil + photo ──────────────────────────────────
  void setFirstNames(String v) => emit(state.copyWith(firstNames: v));
  void setNextNames(String v) => emit(state.copyWith(nextNames: v));
  void setGender(OnboardingGender g) => emit(state.copyWith(gender: g));
  void setDateOfBirth(DateTime? d) => emit(state.copyWith(dateOfBirth: d));
  void setPhone(String? v) => emit(state.copyWith(phone: v));

  Future<void> uploadPhoto(Uint8List bytes, String filename) async {
    emit(state.copyWith(
      photoBytes: bytes,
      photoFilename: filename,
      uploadingPhoto: true,
      clearError: true,
    ));
    try {
      final id = await uploader.uploadBytes(bytes: bytes, filename: filename);
      emit(state.copyWith(
        uploadedPictureFileId: id,
        uploadingPhoto: false,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        uploadingPhoto: false,
        errorMessage: e.message,
      ));
    }
  }

  void clearPhoto() => emit(state.copyWith(clearPhoto: true));

  // ─── Étape 4 — Credentials ─────────────────────────────────────
  void setEmail(String v) => emit(state.copyWith(email: v.trim(), clearError: true));
  void setPassword(String v) => emit(state.copyWith(password: v, clearError: true));

  Future<void> submit() async {
    if (!state.canSubmit) return;
    emit(state.copyWith(submitting: true, clearError: true));
    try {
      await authRepository.register(
        email: state.email,
        password: state.password,
        firstNames: state.firstNames.trim(),
        nextNames: state.nextNames.trim().isEmpty ? null : state.nextNames.trim(),
        phone: state.phone?.trim().isEmpty ?? true ? null : state.phone!.trim(),
        gender: state.gender?.backendName,
        dateOfBirth: state.dateOfBirth?.toIso8601String().substring(0, 10),
        requestedType: state.type.backendName,
        bibleClubId: state.type == OnboardingUserType.student
            ? state.selectedBbc?.id
            : null,
        levelId: state.type == OnboardingUserType.student
            ? state.selectedLevel?.id
            : null,
        profession: state.type == OnboardingUserType.professional
            ? state.profession?.trim()
            : null,
        pictureFileId: state.uploadedPictureFileId,
      );
      emit(state.copyWith(submitting: false, registered: true));
    } on ApiException catch (e) {
      emit(state.copyWith(
        submitting: false,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        submitting: false,
        errorMessage: 'Inscription impossible — vérifie le réseau.',
      ));
    }
  }
}
