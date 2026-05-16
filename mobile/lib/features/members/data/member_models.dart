import 'package:equatable/equatable.dart';

class MemberDto extends Equatable {
  final String id;
  final String userAccountId;
  final String kind; // STUDENT / PROFESSIONAL / MENTOR / NATIONAL_LEADER
  final String? bibleClubId;
  final String? levelId;
  final int participationScore;
  final double faithfulPercentage;
  final String? profession;
  final String status;
  final List<String> departments;

  const MemberDto({
    required this.id,
    required this.userAccountId,
    required this.kind,
    this.bibleClubId,
    this.levelId,
    required this.participationScore,
    required this.faithfulPercentage,
    this.profession,
    required this.status,
    required this.departments,
  });

  factory MemberDto.fromJson(Map<String, dynamic> j) {
    final fp = j['faithfulPercentage'];
    return MemberDto(
      id: j['id'] as String,
      userAccountId: j['userAccountId'] as String,
      kind: j['kind'] as String,
      bibleClubId: j['bibleClubId'] as String?,
      levelId: j['levelId'] as String?,
      participationScore: (j['participationScore'] as num).toInt(),
      faithfulPercentage:
          fp == null ? 0.0 : (fp is num ? fp.toDouble() : double.tryParse(fp.toString()) ?? 0),
      profession: j['profession'] as String?,
      status: j['status'] as String,
      departments: (j['departments'] as List?)?.cast<String>() ?? const [],
    );
  }

  bool get isFaithful => faithfulPercentage >= 50;

  @override
  List<Object?> get props => [
        id,
        userAccountId,
        kind,
        bibleClubId,
        levelId,
        participationScore,
        faithfulPercentage,
        profession,
        status,
        departments,
      ];
}

class AttendanceScoreDto extends Equatable {
  final String id;
  final String memberId;
  final String? bibleClubId;
  final String? levelId;
  final int academicYear;
  final int score;
  final int totalEligible;
  final double faithfulPercentage;
  final bool faithful;

  const AttendanceScoreDto({
    required this.id,
    required this.memberId,
    this.bibleClubId,
    this.levelId,
    required this.academicYear,
    required this.score,
    required this.totalEligible,
    required this.faithfulPercentage,
    required this.faithful,
  });

  factory AttendanceScoreDto.fromJson(Map<String, dynamic> j) {
    final fp = j['faithfulPercentage'];
    return AttendanceScoreDto(
      id: j['id'] as String,
      memberId: j['memberId'] as String,
      bibleClubId: j['bibleClubId'] as String?,
      levelId: j['levelId'] as String?,
      academicYear: (j['academicYear'] as num).toInt(),
      score: (j['score'] as num).toInt(),
      totalEligible: (j['totalEligible'] as num).toInt(),
      faithfulPercentage: fp == null
          ? 0
          : (fp is num ? fp.toDouble() : double.tryParse(fp.toString()) ?? 0),
      faithful: j['faithful'] as bool? ?? false,
    );
  }

  double get ratio => totalEligible == 0 ? 0 : score / totalEligible;

  @override
  List<Object?> get props => [
        id,
        memberId,
        bibleClubId,
        levelId,
        academicYear,
        score,
        totalEligible,
        faithfulPercentage,
        faithful,
      ];
}
