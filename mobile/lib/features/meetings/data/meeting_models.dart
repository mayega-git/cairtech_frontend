import 'package:equatable/equatable.dart';

enum MeetingStatus { planned, ongoing, ended, recorded, cancelled }

MeetingStatus _parseStatus(String s) => switch (s) {
      'PLANNED' => MeetingStatus.planned,
      'ONGOING' => MeetingStatus.ongoing,
      'ENDED' => MeetingStatus.ended,
      'RECORDED' => MeetingStatus.recorded,
      'CANCELLED' => MeetingStatus.cancelled,
      _ => MeetingStatus.planned,
    };

extension MeetingStatusExt on MeetingStatus {
  String get backendName => switch (this) {
        MeetingStatus.planned => 'PLANNED',
        MeetingStatus.ongoing => 'ONGOING',
        MeetingStatus.ended => 'ENDED',
        MeetingStatus.recorded => 'RECORDED',
        MeetingStatus.cancelled => 'CANCELLED',
      };

  String get label => switch (this) {
        MeetingStatus.planned => 'À venir',
        MeetingStatus.ongoing => 'En cours',
        MeetingStatus.ended => 'Terminée',
        MeetingStatus.recorded => 'Enregistrée',
        MeetingStatus.cancelled => 'Annulée',
      };
}

class MeetingDto extends Equatable {
  final String id;
  final String title;
  final String type;
  final MeetingStatus status;
  final String? bibleClubId;
  final String? levelId;
  final DateTime plannedDate; // yyyy-MM-dd
  final String plannedStartTime; // HH:mm:ss
  final DateTime? dateOccurred;
  final int? durationMinutes;
  final int nbBelievers;
  final int maxPictures;
  final String? summary;
  final String? teacherMemberId;

  const MeetingDto({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    this.bibleClubId,
    this.levelId,
    required this.plannedDate,
    required this.plannedStartTime,
    this.dateOccurred,
    this.durationMinutes,
    required this.nbBelievers,
    required this.maxPictures,
    this.summary,
    this.teacherMemberId,
  });

  factory MeetingDto.fromJson(Map<String, dynamic> j) {
    return MeetingDto(
      id: j['id'] as String,
      title: j['title'] as String,
      type: j['type'] as String,
      status: _parseStatus(j['status'] as String),
      bibleClubId: j['bibleClubId'] as String?,
      levelId: j['levelId'] as String?,
      plannedDate: DateTime.parse(j['plannedDate'] as String),
      plannedStartTime: j['plannedStartTime'] as String,
      dateOccurred: j['dateOccurred'] == null
          ? null
          : DateTime.parse(j['dateOccurred'] as String),
      durationMinutes: (j['durationMinutes'] as num?)?.toInt(),
      nbBelievers: (j['nbBelievers'] as num).toInt(),
      maxPictures: (j['maxPictures'] as num).toInt(),
      summary: j['summary'] as String?,
      teacherMemberId: j['teacherMemberId'] as String?,
    );
  }

  /// Date+heure combinée (UTC naïve — utilisée pour trier).
  DateTime get plannedStart {
    final parts = plannedStartTime.split(':');
    return DateTime(
      plannedDate.year,
      plannedDate.month,
      plannedDate.day,
      int.tryParse(parts[0]) ?? 0,
      parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        status,
        bibleClubId,
        levelId,
        plannedDate,
        plannedStartTime,
        dateOccurred,
        durationMinutes,
        nbBelievers,
        maxPictures,
        summary,
        teacherMemberId,
      ];
}
