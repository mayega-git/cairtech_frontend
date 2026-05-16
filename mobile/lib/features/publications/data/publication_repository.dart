import '../../../core/api/dio_client.dart';
import 'publication_models.dart';

class PublicationRepository {
  final DioClient client;
  PublicationRepository(this.client);

  Future<List<DailyVerseDto>> listVerses() async {
    final res = await client.dio.get('/publications/daily-verses');
    return (res.data as List)
        .map((e) => DailyVerseDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DailyVerseDto?> todayVerse() async {
    final list = await listVerses();
    if (list.isEmpty) return null;
    final today = DateTime.now();
    DailyVerseDto? exact;
    for (final v in list) {
      if (v.status != 'PUBLISHED') continue;
      if (v.publishDate.year == today.year &&
          v.publishDate.month == today.month &&
          v.publishDate.day == today.day) {
        exact = v;
        break;
      }
    }
    if (exact != null) return exact;
    // Sinon, dernier verset publié le plus récent (≤ aujourd'hui).
    final published = list
        .where((v) => v.status == 'PUBLISHED' && !v.publishDate.isAfter(today))
        .toList()
      ..sort((a, b) => b.publishDate.compareTo(a.publishDate));
    return published.isEmpty ? null : published.first;
  }

  Future<List<AnnouncementDto>> listAnnouncements() async {
    final res = await client.dio.get('/publications/announcements');
    return (res.data as List)
        .map((e) => AnnouncementDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
