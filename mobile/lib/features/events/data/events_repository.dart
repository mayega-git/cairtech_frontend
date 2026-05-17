import 'package:equatable/equatable.dart';

import '../../../core/api/dio_client.dart';

enum EventStatus { planned, registrationOpen, ongoing, ended, cancelled }

EventStatus _parseStatus(String s) => switch (s) {
      'PLANNED' => EventStatus.planned,
      'REGISTRATION_OPEN' => EventStatus.registrationOpen,
      'ONGOING' => EventStatus.ongoing,
      'ENDED' => EventStatus.ended,
      'CANCELLED' => EventStatus.cancelled,
      _ => EventStatus.planned,
    };

extension EventStatusExt on EventStatus {
  String get backendName => switch (this) {
        EventStatus.planned => 'PLANNED',
        EventStatus.registrationOpen => 'REGISTRATION_OPEN',
        EventStatus.ongoing => 'ONGOING',
        EventStatus.ended => 'ENDED',
        EventStatus.cancelled => 'CANCELLED',
      };

  String get label => switch (this) {
        EventStatus.planned => 'Planifié',
        EventStatus.registrationOpen => 'Inscriptions ouvertes',
        EventStatus.ongoing => 'En cours',
        EventStatus.ended => 'Terminé',
        EventStatus.cancelled => 'Annulé',
      };
}

class EventDto extends Equatable {
  final String id;
  final String title;
  final String type; // NATIONAL_CONGRESS / NATIONAL_SUMMIT / CONFERENCE
  final EventStatus status;
  final DateTime plannedStart;
  final DateTime? plannedEnd;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int? durationMinutes;
  final String? location;
  final int maxPictures;
  final String? imageFileId;

  const EventDto({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.plannedStart,
    this.plannedEnd,
    this.startedAt,
    this.endedAt,
    this.durationMinutes,
    this.location,
    required this.maxPictures,
    this.imageFileId,
  });

  factory EventDto.fromJson(Map<String, dynamic> j) => EventDto(
        id: j['id'] as String,
        title: j['title'] as String,
        type: j['type'] as String,
        status: _parseStatus(j['status'] as String),
        plannedStart: DateTime.parse(j['plannedStart'] as String),
        plannedEnd: j['plannedEnd'] == null
            ? null
            : DateTime.parse(j['plannedEnd'] as String),
        startedAt: j['startedAt'] == null
            ? null
            : DateTime.parse(j['startedAt'] as String),
        endedAt: j['endedAt'] == null
            ? null
            : DateTime.parse(j['endedAt'] as String),
        durationMinutes: (j['durationMinutes'] as num?)?.toInt(),
        location: j['location'] as String?,
        maxPictures: (j['maxPictures'] as num).toInt(),
        imageFileId: j['imageFileId'] as String?,
      );

  bool get acceptsEnrollment =>
      status == EventStatus.planned ||
      status == EventStatus.registrationOpen;

  String get typeLabel => switch (type) {
        'NATIONAL_CONGRESS' => 'Congrès national',
        'NATIONAL_SUMMIT' => 'Sommet national',
        'CONFERENCE' => 'Conférence',
        _ => type,
      };

  @override
  List<Object?> get props => [
        id, title, type, status, plannedStart, plannedEnd, startedAt,
        endedAt, durationMinutes, location, maxPictures, imageFileId,
      ];
}

class EventParticipationDto extends Equatable {
  final String id;
  final String eventId;
  final String? memberId;
  final String? visitorId;
  final DateTime? registeredAt;
  final bool present;
  final DateTime? presentAt;

  const EventParticipationDto({
    required this.id,
    required this.eventId,
    this.memberId,
    this.visitorId,
    this.registeredAt,
    required this.present,
    this.presentAt,
  });

  factory EventParticipationDto.fromJson(Map<String, dynamic> j) =>
      EventParticipationDto(
        id: j['id'] as String,
        eventId: j['eventId'] as String,
        memberId: j['memberId'] as String?,
        visitorId: j['visitorId'] as String?,
        registeredAt: j['registeredAt'] == null
            ? null
            : DateTime.parse(j['registeredAt'] as String),
        present: j['present'] as bool? ?? false,
        presentAt: j['presentAt'] == null
            ? null
            : DateTime.parse(j['presentAt'] as String),
      );

  @override
  List<Object?> get props =>
      [id, eventId, memberId, visitorId, registeredAt, present, presentAt];
}

class EventsRepository {
  final DioClient client;
  EventsRepository(this.client);

  Future<List<EventDto>> list() async {
    final res = await client.dio.get('/events');
    return (res.data as List)
        .map((e) => EventDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<EventDto> findById(String id) async {
    final res = await client.dio.get('/events/$id');
    return EventDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<EventDto> plan({
    required String title,
    required String type, // NATIONAL_CONGRESS / NATIONAL_SUMMIT / CONFERENCE
    required String plannedStart, // ISO instant
    String? plannedEnd,
    String? location,
    int? maxPictures,
    String? imageFileId,
  }) async {
    final res = await client.dio.post('/events', data: {
      'title': title,
      'type': type,
      'plannedStart': plannedStart,
      if (plannedEnd != null) 'plannedEnd': plannedEnd,
      if (location != null) 'location': location,
      if (maxPictures != null) 'maxPictures': maxPictures,
      if (imageFileId != null) 'imageFileId': imageFileId,
    });
    return EventDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<EventDto> openRegistration(String id) async {
    final res = await client.dio.post('/events/$id/open-registration');
    return EventDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<EventDto> start(String id, {String? when}) async {
    final res = await client.dio.post('/events/$id/start', data: {
      if (when != null) 'when': when,
    });
    return EventDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<EventDto> end(String id, {String? when}) async {
    final res = await client.dio.post('/events/$id/end', data: {
      if (when != null) 'when': when,
    });
    return EventDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<EventDto> cancel(String id) async {
    final res = await client.dio.post('/events/$id/cancel');
    return EventDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<EventDto> setImage(String id, String imageFileId) async {
    final res = await client.dio.put('/events/$id/image', data: {
      'imageFileId': imageFileId,
    });
    return EventDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<EventParticipationDto> enrollMember({
    required String eventId,
    required String memberId,
  }) async {
    final res = await client.dio.post('/events/$eventId/enroll', data: {
      'memberId': memberId,
    });
    return EventParticipationDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<EventParticipationDto> markPresent({
    required String eventId,
    required String memberId,
    String? when,
  }) async {
    final res = await client.dio.post('/events/$eventId/presence', data: {
      'memberId': memberId,
      if (when != null) 'when': when,
    });
    return EventParticipationDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<EventParticipationDto>> listParticipations(String id) async {
    final res = await client.dio.get('/events/$id/participations');
    return (res.data as List)
        .map((e) =>
            EventParticipationDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
