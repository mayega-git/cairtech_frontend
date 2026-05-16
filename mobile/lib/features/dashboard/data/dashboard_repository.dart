import '../../../core/api/dio_client.dart';
import 'dashboard_models.dart';

class DashboardRepository {
  final DioClient client;
  DashboardRepository(this.client);

  Future<BibleClubDashboard> bbcDashboard(String bibleClubId,
      {int? academicYear}) async {
    final res = await client.dio.get(
      '/dashboards/bible-clubs/$bibleClubId',
      queryParameters:
          academicYear == null ? null : {'academicYear': academicYear},
    );
    return BibleClubDashboard.fromJson(res.data as Map<String, dynamic>);
  }

  Future<NationalDashboard> national({int? academicYear}) async {
    final res = await client.dio.get(
      '/dashboards/national',
      queryParameters:
          academicYear == null ? null : {'academicYear': academicYear},
    );
    return NationalDashboard.fromJson(res.data as Map<String, dynamic>);
  }
}
