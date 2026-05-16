import 'package:equatable/equatable.dart';

import '../../../core/api/dio_client.dart';

class DiscipleLinkDto extends Equatable {
  final String id;
  final String makerId;
  final String discipleId;
  final DateTime? dateAssigned;
  final DateTime? dateEnded;
  final bool active;

  const DiscipleLinkDto({
    required this.id,
    required this.makerId,
    required this.discipleId,
    this.dateAssigned,
    this.dateEnded,
    required this.active,
  });

  factory DiscipleLinkDto.fromJson(Map<String, dynamic> j) => DiscipleLinkDto(
        id: j['id'] as String,
        makerId: j['makerId'] as String,
        discipleId: j['discipleId'] as String,
        dateAssigned: j['dateAssigned'] == null
            ? null
            : DateTime.parse(j['dateAssigned'] as String),
        dateEnded: j['dateEnded'] == null
            ? null
            : DateTime.parse(j['dateEnded'] as String),
        active: j['active'] as bool? ?? true,
      );

  @override
  List<Object?> get props =>
      [id, makerId, discipleId, dateAssigned, dateEnded, active];
}

class DiscipleshipRecordDto extends Equatable {
  final String id;
  final String makerId;
  final String? meetingId;
  final DateTime dateOccurred;
  final String? theme;
  final List<String> presentDiscipleIds;

  const DiscipleshipRecordDto({
    required this.id,
    required this.makerId,
    this.meetingId,
    required this.dateOccurred,
    this.theme,
    required this.presentDiscipleIds,
  });

  factory DiscipleshipRecordDto.fromJson(Map<String, dynamic> j) {
    return DiscipleshipRecordDto(
      id: j['id'] as String,
      makerId: j['makerId'] as String,
      meetingId: j['meetingId'] as String?,
      dateOccurred: DateTime.parse(j['dateOccurred'] as String),
      theme: j['theme'] as String?,
      presentDiscipleIds:
          (j['presentDiscipleIds'] as List<dynamic>? ?? []).cast<String>(),
    );
  }

  @override
  List<Object?> get props =>
      [id, makerId, meetingId, dateOccurred, theme, presentDiscipleIds];
}

class DiscipleshipRepository {
  final DioClient client;
  DiscipleshipRepository(this.client);

  Future<List<DiscipleLinkDto>> listDisciples(String makerId) async {
    final res = await client.dio.get('/discipleship/makers/$makerId/disciples');
    return (res.data as List)
        .map((e) => DiscipleLinkDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DiscipleLinkDto> assignDisciple({
    required String makerId,
    required String discipleId,
  }) async {
    final res = await client.dio.post('/discipleship/links', data: {
      'makerId': makerId,
      'discipleId': discipleId,
    });
    return DiscipleLinkDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<DiscipleLinkDto> endLink({
    required String linkId,
    String? when,
  }) async {
    final res = await client.dio.post('/discipleship/links/$linkId/end', data: {
      if (when != null) 'when': when,
    });
    return DiscipleLinkDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<DiscipleshipRecordDto>> listRecords(String makerId) async {
    final res = await client.dio.get('/discipleship/makers/$makerId/records');
    return (res.data as List)
        .map((e) => DiscipleshipRecordDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DiscipleshipRecordDto> recordSession({
    required String makerId,
    String? meetingId,
    required String dateOccurred,
    String? startTime,
    String? endTime,
    String? theme,
    String? location,
    String? description,
    String? disciplesState,
    String? investment,
    List<String> presentDiscipleIds = const [],
  }) async {
    final res = await client.dio.post('/discipleship/records', data: {
      'makerId': makerId,
      if (meetingId != null) 'meetingId': meetingId,
      'dateOccurred': dateOccurred,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      if (theme != null) 'theme': theme,
      if (location != null) 'location': location,
      if (description != null) 'description': description,
      if (disciplesState != null) 'disciplesState': disciplesState,
      if (investment != null) 'investment': investment,
      'presentDiscipleIds': presentDiscipleIds,
    });
    return DiscipleshipRecordDto.fromJson(res.data as Map<String, dynamic>);
  }
}
