import 'package:equatable/equatable.dart';

/// Vue UI d'un Member enrichie avec les PII de UserAccount.
/// Renvoyée par GET /members/with-profile et /members/{id}/with-profile.
class MemberWithProfileDto extends Equatable {
  final String id;
  final String userAccountId;
  final String kind;
  final String? bibleClubId;
  final String? levelId;
  final int participationScore;
  final double faithfulPercentage;
  final String? profession;
  final String? professionalPosition;
  final String status;
  final List<String> departments;

  // PII
  final String email;
  final String? firstNames;
  final String? nextNames;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? pictureFileId;
  final String accountStatus;
  final String userType;

  const MemberWithProfileDto({
    required this.id,
    required this.userAccountId,
    required this.kind,
    this.bibleClubId,
    this.levelId,
    required this.participationScore,
    required this.faithfulPercentage,
    this.profession,
    this.professionalPosition,
    required this.status,
    required this.departments,
    required this.email,
    this.firstNames,
    this.nextNames,
    this.gender,
    this.dateOfBirth,
    this.pictureFileId,
    required this.accountStatus,
    required this.userType,
  });

  factory MemberWithProfileDto.fromJson(Map<String, dynamic> j) {
    final fp = j['faithfulPercentage'];
    return MemberWithProfileDto(
      id: j['id'] as String,
      userAccountId: j['userAccountId'] as String,
      kind: j['kind'] as String,
      bibleClubId: j['bibleClubId'] as String?,
      levelId: j['levelId'] as String?,
      participationScore: (j['participationScore'] as num).toInt(),
      faithfulPercentage: fp == null
          ? 0
          : (fp is num ? fp.toDouble() : double.tryParse(fp.toString()) ?? 0),
      profession: j['profession'] as String?,
      professionalPosition: j['professionalPosition'] as String?,
      status: j['status'] as String,
      departments: (j['departments'] as List?)?.cast<String>() ?? const [],
      email: j['email'] as String,
      firstNames: j['firstNames'] as String?,
      nextNames: j['nextNames'] as String?,
      gender: j['gender'] as String?,
      dateOfBirth: j['dateOfBirth'] == null
          ? null
          : DateTime.parse(j['dateOfBirth'] as String),
      pictureFileId: j['pictureFileId'] as String?,
      accountStatus: j['accountStatus'] as String,
      userType: j['userType'] as String,
    );
  }

  String get displayName {
    final parts = [firstNames, nextNames]
        .where((s) => s != null && s.trim().isNotEmpty)
        .toList();
    return parts.isEmpty ? email : parts.join(' ');
  }

  String get firstLetter {
    final s = displayName.trim();
    return s.isEmpty ? '?' : s[0].toUpperCase();
  }

  bool get isFaithful => faithfulPercentage >= 50;
  bool get isActive => status == 'ACTIVE';
  bool get isInactive => status == 'INACTIVE';

  @override
  List<Object?> get props => [
        id, userAccountId, kind, bibleClubId, levelId, participationScore,
        faithfulPercentage, profession, professionalPosition, status,
        departments, email, firstNames, nextNames, gender, dateOfBirth,
        pictureFileId, accountStatus, userType,
      ];
}
