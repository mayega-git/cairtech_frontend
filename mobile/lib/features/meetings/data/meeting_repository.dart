import '../../../core/api/dio_client.dart';
import 'meeting_models.dart';

class MeetingRepository {
  final DioClient client;
  MeetingRepository(this.client);

  Future<List<MeetingDto>> listByBibleClub(String bibleClubId) async {
    final res = await client.dio.get(
      '/meetings',
      queryParameters: {'bibleClubId': bibleClubId},
    );
    return (res.data as List)
        .map((e) => MeetingDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MeetingDto> findById(String id) async {
    final res = await client.dio.get('/meetings/$id');
    return MeetingDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<MeetingDto> plan({
    required String title,
    required String type,
    required String? bibleClubId,
    required String? levelId,
    required String plannedDate, // yyyy-MM-dd
    required String plannedStartTime, // HH:mm:ss
    String? plannedEndTime,
    String? teacherMemberId,
    int? maxPictures,
  }) async {
    final res = await client.dio.post('/meetings', data: {
      'title': title,
      'type': type,
      if (bibleClubId != null) 'bibleClubId': bibleClubId,
      if (levelId != null) 'levelId': levelId,
      'plannedDate': plannedDate,
      'plannedStartTime': plannedStartTime,
      if (plannedEndTime != null) 'plannedEndTime': plannedEndTime,
      if (teacherMemberId != null) 'teacherMemberId': teacherMemberId,
      if (maxPictures != null) 'maxPictures': maxPictures,
    });
    return MeetingDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<MeetingDto> start(String id,
      {String? dateOccurred, String? startTime}) async {
    final res = await client.dio.post('/meetings/$id/start', data: {
      if (dateOccurred != null) 'dateOccurred': dateOccurred,
      if (startTime != null) 'startTime': startTime,
    });
    return MeetingDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<MeetingDto> end(String id, {String? endTime}) async {
    final res = await client.dio.post('/meetings/$id/end', data: {
      if (endTime != null) 'endTime': endTime,
    });
    return MeetingDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<MeetingDto> cancel(String id) async {
    final res = await client.dio.post('/meetings/$id/cancel');
    return MeetingDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<MeetingDto> record({
    required String id,
    required String dateOccurred,
    String? startTime,
    String? endTime,
    required int nbBelievers,
    String? summary,
    required List<Map<String, dynamic>> presents,
    List<Map<String, dynamic>> pictures = const [],
  }) async {
    final res = await client.dio.post('/meetings/$id/record', data: {
      'dateOccurred': dateOccurred,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      'nbBelievers': nbBelievers,
      if (summary != null) 'summary': summary,
      'presents': presents,
      'pictures': pictures,
    });
    return MeetingDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<PresenceDto>> listPresences(String id) async {
    final res = await client.dio.get('/meetings/$id/presences');
    return (res.data as List)
        .map((e) => PresenceDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PictureDto>> listPictures(String id) async {
    final res = await client.dio.get('/meetings/$id/pictures');
    return (res.data as List)
        .map((e) => PictureDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class PresenceDto {
  final String id;
  final String? memberId;
  final String? visitorId;
  final DateTime? presentAt;
  final String role; // MEMBER / VISITOR / TEACHER / SPEAKER

  PresenceDto({
    required this.id,
    this.memberId,
    this.visitorId,
    this.presentAt,
    required this.role,
  });

  factory PresenceDto.fromJson(Map<String, dynamic> j) => PresenceDto(
        id: j['id'] as String,
        memberId: j['memberId'] as String?,
        visitorId: j['visitorId'] as String?,
        presentAt: j['presentAt'] == null
            ? null
            : DateTime.parse(j['presentAt'] as String),
        role: j['role'] as String,
      );
}

class PictureDto {
  final String id;
  final String fileId;
  final String? caption;
  final DateTime? takenAt;

  PictureDto({
    required this.id,
    required this.fileId,
    this.caption,
    this.takenAt,
  });

  factory PictureDto.fromJson(Map<String, dynamic> j) => PictureDto(
        id: j['id'] as String,
        fileId: j['fileId'] as String,
        caption: j['caption'] as String?,
        takenAt: j['takenAt'] == null
            ? null
            : DateTime.parse(j['takenAt'] as String),
      );
}
