import 'package:equatable/equatable.dart';

import '../../../core/api/dio_client.dart';

/// EvangelismProgramType: INTERNAL_BBC ou JOINT.
class EvangelismProgramDto extends Equatable {
  final String id;
  final String title;
  final String type; // INTERNAL_BBC / JOINT
  final String status; // DRAFT / ACTIVE / CLOSED
  final int objectiveBelievers;
  final int totalSaved;
  final double percentageReached;
  final List<DateTime> dates;
  final List<String> bibleClubIds;

  const EvangelismProgramDto({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.objectiveBelievers,
    required this.totalSaved,
    required this.percentageReached,
    required this.dates,
    required this.bibleClubIds,
  });

  factory EvangelismProgramDto.fromJson(Map<String, dynamic> j) {
    return EvangelismProgramDto(
      id: j['id'] as String,
      title: j['title'] as String,
      type: j['type'] as String,
      status: j['status'] as String,
      objectiveBelievers: (j['objectiveBelievers'] as num).toInt(),
      totalSaved: (j['totalSaved'] as num).toInt(),
      percentageReached: (j['percentageReached'] as num).toDouble(),
      dates: (j['dates'] as List<dynamic>? ?? [])
          .map((e) => DateTime.parse(e as String))
          .toList(),
      bibleClubIds:
          (j['bibleClubIds'] as List<dynamic>? ?? []).cast<String>(),
    );
  }

  bool get isDraft => status == 'DRAFT';
  bool get isActive => status == 'ACTIVE';
  bool get isClosed => status == 'CLOSED';

  double get ratio => objectiveBelievers == 0
      ? 0
      : (totalSaved / objectiveBelievers).clamp(0.0, 1.0);

  @override
  List<Object?> get props => [
        id, title, type, status, objectiveBelievers, totalSaved,
        percentageReached, dates, bibleClubIds,
      ];
}

class EvangelismRecordDto extends Equatable {
  final String id;
  final String programId;
  final DateTime date;
  final int preached;
  final int believed;
  final int encouraged;
  final int tracts;
  final List<String> participantMemberIds;

  const EvangelismRecordDto({
    required this.id,
    required this.programId,
    required this.date,
    required this.preached,
    required this.believed,
    required this.encouraged,
    required this.tracts,
    required this.participantMemberIds,
  });

  factory EvangelismRecordDto.fromJson(Map<String, dynamic> j) {
    return EvangelismRecordDto(
      id: j['id'] as String,
      programId: j['programId'] as String,
      date: DateTime.parse(j['date'] as String),
      preached: (j['preached'] as num).toInt(),
      believed: (j['believed'] as num).toInt(),
      encouraged: (j['encouraged'] as num).toInt(),
      tracts: (j['tracts'] as num).toInt(),
      participantMemberIds:
          (j['participantMemberIds'] as List<dynamic>? ?? []).cast<String>(),
    );
  }

  @override
  List<Object?> get props => [
        id, programId, date, preached, believed, encouraged, tracts,
        participantMemberIds,
      ];
}

class EvangelismRepository {
  final DioClient client;
  EvangelismRepository(this.client);

  Future<List<EvangelismProgramDto>> listPrograms() async {
    final res = await client.dio.get('/evangelism/programs');
    return (res.data as List)
        .map((e) => EvangelismProgramDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<EvangelismProgramDto> findById(String id) async {
    final res = await client.dio.get('/evangelism/programs/$id');
    return EvangelismProgramDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<EvangelismProgramDto> draftProgram({
    required String title,
    required String type, // INTERNAL_BBC / JOINT
    required int objective,
  }) async {
    final res = await client.dio.post('/evangelism/programs', data: {
      'title': title,
      'type': type,
      'objective': objective,
    });
    return EvangelismProgramDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<EvangelismProgramDto> addDate({
    required String programId,
    required String date,
  }) async {
    final res = await client.dio
        .post('/evangelism/programs/$programId/dates', data: {'date': date});
    return EvangelismProgramDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<EvangelismProgramDto> addBibleClub({
    required String programId,
    required String bibleClubId,
  }) async {
    final res = await client.dio.post(
      '/evangelism/programs/$programId/bible-clubs',
      data: {'bibleClubId': bibleClubId},
    );
    return EvangelismProgramDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<EvangelismProgramDto> activate(String id) async {
    final res = await client.dio.post('/evangelism/programs/$id/activate');
    return EvangelismProgramDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<EvangelismProgramDto> close(String id) async {
    final res = await client.dio.post('/evangelism/programs/$id/close');
    return EvangelismProgramDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<EvangelismRecordDto> record({
    required String programId,
    required String date,
    required int preached,
    required int believed,
    required int encouraged,
    int tracts = 0,
    String? savedContacts,
    String? notes,
    List<String> participantMemberIds = const [],
  }) async {
    final res =
        await client.dio.post('/evangelism/programs/$programId/records', data: {
      'date': date,
      'preached': preached,
      'believed': believed,
      'encouraged': encouraged,
      'tracts': tracts,
      if (savedContacts != null) 'savedContacts': savedContacts,
      if (notes != null) 'notes': notes,
      'participantMemberIds': participantMemberIds,
    });
    return EvangelismRecordDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<EvangelismRecordDto>> listRecords(String programId) async {
    final res =
        await client.dio.get('/evangelism/programs/$programId/records');
    return (res.data as List)
        .map((e) => EvangelismRecordDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
