import 'package:equatable/equatable.dart';

import '../../../core/api/dio_client.dart';

class MembershipRequestDto extends Equatable {
  final String id;
  final String userAccountId;
  final String requestedType; // STUDENT / PROFESSIONAL / VISITOR
  final String? bibleClubId;
  final String? levelId;
  final String? profession;
  final String status; // PENDING / APPROVED / REJECTED / CANCELLED
  final String? decisionBy;
  final DateTime? decisionAt;
  final String? decisionComment;
  final DateTime? createdAt;

  // PII
  final String email;
  final String? firstNames;
  final String? nextNames;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? pictureFileId;
  final String? phone;

  const MembershipRequestDto({
    required this.id,
    required this.userAccountId,
    required this.requestedType,
    this.bibleClubId,
    this.levelId,
    this.profession,
    required this.status,
    this.decisionBy,
    this.decisionAt,
    this.decisionComment,
    this.createdAt,
    required this.email,
    this.firstNames,
    this.nextNames,
    this.gender,
    this.dateOfBirth,
    this.pictureFileId,
    this.phone,
  });

  factory MembershipRequestDto.fromJson(Map<String, dynamic> j) {
    return MembershipRequestDto(
      id: j['id'] as String,
      userAccountId: j['userAccountId'] as String,
      requestedType: j['requestedType'] as String,
      bibleClubId: j['bibleClubId'] as String?,
      levelId: j['levelId'] as String?,
      profession: j['profession'] as String?,
      status: j['status'] as String,
      decisionBy: j['decisionBy'] as String?,
      decisionAt: j['decisionAt'] == null
          ? null
          : DateTime.parse(j['decisionAt'] as String),
      decisionComment: j['decisionComment'] as String?,
      createdAt: j['createdAt'] == null
          ? null
          : DateTime.parse(j['createdAt'] as String),
      email: j['email'] as String,
      firstNames: j['firstNames'] as String?,
      nextNames: j['nextNames'] as String?,
      gender: j['gender'] as String?,
      dateOfBirth: j['dateOfBirth'] == null
          ? null
          : DateTime.parse(j['dateOfBirth'] as String),
      pictureFileId: j['pictureFileId'] as String?,
      phone: j['phone'] as String?,
    );
  }

  String get displayName {
    final parts = [firstNames, nextNames]
        .where((s) => s != null && s.trim().isNotEmpty)
        .toList();
    return parts.isEmpty ? email : parts.join(' ');
  }

  @override
  List<Object?> get props => [
        id, userAccountId, requestedType, bibleClubId, levelId, profession,
        status, decisionBy, decisionAt, decisionComment, createdAt,
        email, firstNames, nextNames, gender, dateOfBirth, pictureFileId,
        phone,
      ];
}

class MembershipRequestRepository {
  final DioClient client;
  MembershipRequestRepository(this.client);

  Future<List<MembershipRequestDto>> listWithProfile({
    String status = 'PENDING',
  }) async {
    final res = await client.dio.get(
      '/membership-requests/with-profile',
      queryParameters: {'status': status},
    );
    return (res.data as List)
        .map((e) => MembershipRequestDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> approve({
    required String requestId,
    required String assignedBibleClubId,
    required String assignedLevelId,
    String? comment,
  }) async {
    await client.dio.post('/membership-requests/$requestId/approve', data: {
      'assignedBibleClubId': assignedBibleClubId,
      'assignedLevelId': assignedLevelId,
      if (comment != null) 'comment': comment,
    });
  }

  Future<void> reject({
    required String requestId,
    String? comment,
  }) async {
    await client.dio.post('/membership-requests/$requestId/reject', data: {
      if (comment != null) 'comment': comment,
    });
  }
}
