import 'package:equatable/equatable.dart';

import '../../../core/api/dio_client.dart';

class BibleClubFullDto extends Equatable {
  final String id;
  final String name;
  final String? profile;
  final String? schoolName;
  final int? goalNbFaithful;
  final DateTime? dateCreated;
  final String status; // ACTIVE / UNDER_RESET / ARCHIVED
  final String? presidentMemberId;
  final String? vicePresidentMemberId;
  final String? secretaryMemberId;
  final String? imageFileId;

  const BibleClubFullDto({
    required this.id,
    required this.name,
    this.profile,
    this.schoolName,
    this.goalNbFaithful,
    this.dateCreated,
    required this.status,
    this.presidentMemberId,
    this.vicePresidentMemberId,
    this.secretaryMemberId,
    this.imageFileId,
  });

  factory BibleClubFullDto.fromJson(Map<String, dynamic> j) => BibleClubFullDto(
        id: j['id'] as String,
        name: j['name'] as String,
        profile: j['profile'] as String?,
        schoolName: j['schoolName'] as String?,
        goalNbFaithful: (j['goalNbFaithful'] as num?)?.toInt(),
        dateCreated: j['dateCreated'] == null
            ? null
            : DateTime.parse(j['dateCreated'] as String),
        status: j['status'] as String,
        presidentMemberId: j['presidentMemberId'] as String?,
        vicePresidentMemberId: j['vicePresidentMemberId'] as String?,
        secretaryMemberId: j['secretaryMemberId'] as String?,
        imageFileId: j['imageFileId'] as String?,
      );

  bool get isActive => status == 'ACTIVE';
  bool get isUnderReset => status == 'UNDER_RESET';
  bool get isArchived => status == 'ARCHIVED';

  @override
  List<Object?> get props => [
        id, name, profile, schoolName, goalNbFaithful, dateCreated, status,
        presidentMemberId, vicePresidentMemberId, secretaryMemberId,
        imageFileId,
      ];
}

class ResetSnapshotDto extends Equatable {
  final String id;
  final String bibleClubId;
  final int academicYear;
  final int nbMembersBefore;
  final int nbFaithfulBefore;
  final int nbMeetings;
  final double percentageReached;
  final DateTime? archivedAt;
  final String? archiveFileId;

  const ResetSnapshotDto({
    required this.id,
    required this.bibleClubId,
    required this.academicYear,
    required this.nbMembersBefore,
    required this.nbFaithfulBefore,
    required this.nbMeetings,
    required this.percentageReached,
    this.archivedAt,
    this.archiveFileId,
  });

  factory ResetSnapshotDto.fromJson(Map<String, dynamic> j) => ResetSnapshotDto(
        id: j['id'] as String,
        bibleClubId: j['bibleClubId'] as String,
        academicYear: (j['academicYear'] as num).toInt(),
        nbMembersBefore: (j['nbMembersBefore'] as num).toInt(),
        nbFaithfulBefore: (j['nbFaithfulBefore'] as num).toInt(),
        nbMeetings: (j['nbMeetings'] as num).toInt(),
        percentageReached: (j['percentageReached'] as num).toDouble(),
        archivedAt: j['archivedAt'] == null
            ? null
            : DateTime.parse(j['archivedAt'] as String),
        archiveFileId: j['archiveFileId'] as String?,
      );

  @override
  List<Object?> get props => [
        id, bibleClubId, academicYear, nbMembersBefore, nbFaithfulBefore,
        nbMeetings, percentageReached, archivedAt, archiveFileId,
      ];
}

class BibleClubsAdminRepository {
  final DioClient client;
  BibleClubsAdminRepository(this.client);

  Future<List<BibleClubFullDto>> list() async {
    final res = await client.dio.get('/bible-clubs');
    return (res.data as List)
        .map((e) => BibleClubFullDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BibleClubFullDto> findById(String id) async {
    final res = await client.dio.get('/bible-clubs/$id');
    return BibleClubFullDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<BibleClubFullDto> create({
    required String name,
    String? profile,
    String? schoolName,
    int? goalNbFaithful,
    String? dateCreated,
    String? imageFileId,
  }) async {
    final res = await client.dio.post('/bible-clubs', data: {
      'name': name,
      if (profile != null) 'profile': profile,
      if (schoolName != null) 'schoolName': schoolName,
      if (goalNbFaithful != null) 'goalNbFaithful': goalNbFaithful,
      if (dateCreated != null) 'dateCreated': dateCreated,
      if (imageFileId != null) 'imageFileId': imageFileId,
    });
    return BibleClubFullDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<BibleClubFullDto> setGoal(String id, int goal) async {
    final res = await client.dio.put('/bible-clubs/$id/goal', data: {
      'goalNbFaithful': goal,
    });
    return BibleClubFullDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<BibleClubFullDto> setImage(String id, String? imageFileId) async {
    final res = await client.dio.put('/bible-clubs/$id/image', data: {
      'imageFileId': imageFileId,
    });
    return BibleClubFullDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<BibleClubFullDto> assignTriumvirate({
    required String id,
    String? presidentId,
    String? vicePresidentId,
    String? secretaryId,
  }) async {
    final res = await client.dio.put('/bible-clubs/$id/triumvirate', data: {
      if (presidentId != null) 'presidentId': presidentId,
      if (vicePresidentId != null) 'vicePresidentId': vicePresidentId,
      if (secretaryId != null) 'secretaryId': secretaryId,
    });
    return BibleClubFullDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await client.dio.delete('/bible-clubs/$id');
  }

  Future<ResetSnapshotDto> reset({
    required String id,
    required int academicYear,
  }) async {
    final res = await client.dio.post('/bible-clubs/$id/reset', data: {
      'academicYear': academicYear,
    });
    return ResetSnapshotDto.fromJson(res.data as Map<String, dynamic>);
  }
}

class LevelDto extends Equatable {
  final String id;
  final String bibleClubId;
  final String name;
  final String? profile;
  final String type; // L1..L7
  final String? presidentMemberId;
  final String? vicePresidentMemberId;

  const LevelDto({
    required this.id,
    required this.bibleClubId,
    required this.name,
    this.profile,
    required this.type,
    this.presidentMemberId,
    this.vicePresidentMemberId,
  });

  factory LevelDto.fromJson(Map<String, dynamic> j) => LevelDto(
        id: j['id'] as String,
        bibleClubId: j['bibleClubId'] as String,
        name: j['name'] as String,
        profile: j['profile'] as String?,
        type: j['type'] as String,
        presidentMemberId: j['presidentMemberId'] as String?,
        vicePresidentMemberId: j['vicePresidentMemberId'] as String?,
      );

  @override
  List<Object?> get props => [id, bibleClubId, name, profile, type,
        presidentMemberId, vicePresidentMemberId];
}

class LevelsAdminRepository {
  final DioClient client;
  LevelsAdminRepository(this.client);

  Future<List<LevelDto>> listByBibleClub(String bibleClubId) async {
    final res = await client.dio.get('/bible-clubs/$bibleClubId/levels');
    return (res.data as List)
        .map((e) => LevelDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LevelDto> create({
    required String bibleClubId,
    required String name,
    String? profile,
    required String type, // L1..L7
  }) async {
    final res =
        await client.dio.post('/bible-clubs/$bibleClubId/levels', data: {
      'name': name,
      if (profile != null) 'profile': profile,
      'type': type,
    });
    return LevelDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<LevelDto> rename({
    required String bibleClubId,
    required String levelId,
    required String newName,
  }) async {
    final res = await client.dio.put(
      '/bible-clubs/$bibleClubId/levels/$levelId',
      data: {'name': newName},
    );
    return LevelDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> delete({
    required String bibleClubId,
    required String levelId,
  }) async {
    await client.dio
        .delete('/bible-clubs/$bibleClubId/levels/$levelId');
  }
}
