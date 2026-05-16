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

  Future<DailyVerseDto> draftVerse({
    required String title,
    required String reference,
    required String verseText,
    String? reflectionText,
    String? imageFileId,
    required String publishDate,
    String audience = 'CHF',
  }) async {
    final res = await client.dio.post('/publications/daily-verses', data: {
      'title': title,
      'reference': reference,
      'verseText': verseText,
      if (reflectionText != null) 'reflectionText': reflectionText,
      if (imageFileId != null) 'imageFileId': imageFileId,
      'publishDate': publishDate,
      'audience': audience,
    });
    return DailyVerseDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<DailyVerseDto> publishVerse(String id) async {
    final res = await client.dio.post('/publications/daily-verses/$id/publish');
    return DailyVerseDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AnnouncementDto> draftAnnouncement({
    required String title,
    required String content,
    String? imageFileId,
    required String type, // BIRTHDAY / CONGRESS / SUMMIT / OBITUARY / OTHER
    required String publishDate,
    String audience = 'CHF',
  }) async {
    final res = await client.dio.post('/publications/announcements', data: {
      'title': title,
      'content': content,
      if (imageFileId != null) 'imageFileId': imageFileId,
      'type': type,
      'publishDate': publishDate,
      'audience': audience,
    });
    return AnnouncementDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AnnouncementDto> publishAnnouncement(String id) async {
    final res = await client.dio.post('/publications/announcements/$id/publish');
    return AnnouncementDto.fromJson(res.data as Map<String, dynamic>);
  }
}
