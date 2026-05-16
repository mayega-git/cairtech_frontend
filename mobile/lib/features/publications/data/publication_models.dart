import 'package:equatable/equatable.dart';

class DailyVerseDto extends Equatable {
  final String id;
  final String title;
  final String reference; // Ps. 23.1
  final String verseText;
  final String? reflectionText;
  final String? imageFileId;
  final DateTime publishDate;
  final String status; // SCHEDULED / PUBLISHED / ARCHIVED
  final String audience; // CHF / BBC / LEVEL / DEPARTMENT

  const DailyVerseDto({
    required this.id,
    required this.title,
    required this.reference,
    required this.verseText,
    this.reflectionText,
    this.imageFileId,
    required this.publishDate,
    required this.status,
    required this.audience,
  });

  factory DailyVerseDto.fromJson(Map<String, dynamic> j) => DailyVerseDto(
        id: j['id'] as String,
        title: j['title'] as String,
        reference: j['reference'] as String,
        verseText: j['verseText'] as String,
        reflectionText: j['reflectionText'] as String?,
        imageFileId: j['imageFileId'] as String?,
        publishDate: DateTime.parse(j['publishDate'] as String),
        status: j['status'] as String,
        audience: j['audience'] as String,
      );

  @override
  List<Object?> get props => [
        id,
        title,
        reference,
        verseText,
        reflectionText,
        imageFileId,
        publishDate,
        status,
        audience,
      ];
}

class AnnouncementDto extends Equatable {
  final String id;
  final String title;
  final String content;
  final String? imageFileId;
  final String type; // BIRTHDAY / CONGRESS / SUMMIT / OBITUARY / OTHER
  final DateTime publishDate;
  final String status;
  final String audience;

  const AnnouncementDto({
    required this.id,
    required this.title,
    required this.content,
    this.imageFileId,
    required this.type,
    required this.publishDate,
    required this.status,
    required this.audience,
  });

  factory AnnouncementDto.fromJson(Map<String, dynamic> j) => AnnouncementDto(
        id: j['id'] as String,
        title: j['title'] as String,
        content: j['content'] as String,
        imageFileId: j['imageFileId'] as String?,
        type: j['type'] as String,
        publishDate: DateTime.parse(j['publishDate'] as String),
        status: j['status'] as String,
        audience: j['audience'] as String,
      );

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        imageFileId,
        type,
        publishDate,
        status,
        audience,
      ];
}
