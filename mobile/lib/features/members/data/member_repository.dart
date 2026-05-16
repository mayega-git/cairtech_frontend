import '../../../core/api/dio_client.dart';
import '../../../core/errors/api_exception.dart';
import 'member_models.dart';
import 'member_with_profile_dto.dart';

class MemberRepository {
  final DioClient client;
  MemberRepository(this.client);

  Future<List<MemberWithProfileDto>> listByBibleClubWithProfile(String bibleClubId) async {
    final res = await client.dio.get(
      '/members/with-profile',
      queryParameters: {'bibleClubId': bibleClubId},
    );
    return (res.data as List)
        .map((e) => MemberWithProfileDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MemberWithProfileDto> findByIdWithProfile(String memberId) async {
    final res = await client.dio.get('/members/$memberId/with-profile');
    return MemberWithProfileDto.fromJson(res.data as Map<String, dynamic>);
  }

  /// Renvoie le `Member` rattaché à l'utilisateur connecté. `null` si le
  /// compte n'est rattaché à aucun member (visiteur).
  Future<MemberDto?> me() async {
    try {
      final res = await client.dio.get('/members/me');
      return MemberDto.fromJson(res.data as Map<String, dynamic>);
    } on Exception catch (e) {
      // 404 → l'utilisateur n'est pas (encore) un member
      final dyn = e as dynamic;
      try {
        final inner = dyn.error;
        if (inner is ApiException && inner.isNotFound) return null;
      } catch (_) {}
      rethrow;
    }
  }

  Future<List<MemberDto>> listByBibleClub(String bibleClubId) async {
    final res = await client.dio.get(
      '/members',
      queryParameters: {'bibleClubId': bibleClubId},
    );
    return (res.data as List)
        .map((e) => MemberDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AttendanceScoreDto?> myScore(String memberId, {int? academicYear}) async {
    try {
      final res = await client.dio.get(
        '/attendance/members/$memberId',
        queryParameters:
            academicYear == null ? null : {'academicYear': academicYear},
      );
      return AttendanceScoreDto.fromJson(res.data as Map<String, dynamic>);
    } on Exception catch (e) {
      final dyn = e as dynamic;
      try {
        final inner = dyn.error;
        if (inner is ApiException && inner.isNotFound) return null;
      } catch (_) {}
      rethrow;
    }
  }
}
