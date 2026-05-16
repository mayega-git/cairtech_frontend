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
}
