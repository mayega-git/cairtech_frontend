import 'package:equatable/equatable.dart';

import '../../../core/api/dio_client.dart';

class PrayerChainDto extends Equatable {
  final String id;
  final String bibleClubId;
  final String title;
  final DateTime dateStart;
  final DateTime? dateEnd;
  final String status; // DRAFT / RUNNING / CLOSED

  const PrayerChainDto({
    required this.id,
    required this.bibleClubId,
    required this.title,
    required this.dateStart,
    this.dateEnd,
    required this.status,
  });

  factory PrayerChainDto.fromJson(Map<String, dynamic> j) => PrayerChainDto(
        id: j['id'] as String,
        bibleClubId: j['bibleClubId'] as String,
        title: j['title'] as String,
        dateStart: DateTime.parse(j['dateStart'] as String),
        dateEnd: j['dateEnd'] == null
            ? null
            : DateTime.parse(j['dateEnd'] as String),
        status: j['status'] as String,
      );

  bool get isRunning => status == 'RUNNING';
  bool get isDraft => status == 'DRAFT';
  bool get isClosed => status == 'CLOSED';

  @override
  List<Object?> get props => [id, bibleClubId, title, dateStart, dateEnd, status];
}

class PrayerSlotDto extends Equatable {
  final String id;
  final String prayerChainId;
  final String? intercessorMemberId;
  final DateTime dtStart;
  final DateTime dtEnd;
  final bool covered;
  final String? note;

  const PrayerSlotDto({
    required this.id,
    required this.prayerChainId,
    this.intercessorMemberId,
    required this.dtStart,
    required this.dtEnd,
    required this.covered,
    this.note,
  });

  factory PrayerSlotDto.fromJson(Map<String, dynamic> j) => PrayerSlotDto(
        id: j['id'] as String,
        prayerChainId: j['prayerChainId'] as String,
        intercessorMemberId: j['intercessorMemberId'] as String?,
        dtStart: DateTime.parse(j['dtStart'] as String),
        dtEnd: DateTime.parse(j['dtEnd'] as String),
        covered: j['covered'] as bool? ?? false,
        note: j['note'] as String?,
      );

  Duration get duration => dtEnd.difference(dtStart);

  @override
  List<Object?> get props =>
      [id, prayerChainId, intercessorMemberId, dtStart, dtEnd, covered, note];
}

class IntercessionRepository {
  final DioClient client;
  IntercessionRepository(this.client);

  Future<List<PrayerChainDto>> listChainsByBibleClub(String bibleClubId) async {
    final res =
        await client.dio.get('/intercession/bible-clubs/$bibleClubId/chains');
    return (res.data as List)
        .map((e) => PrayerChainDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PrayerSlotDto>> listSlotsByChain(String chainId) async {
    final res = await client.dio.get('/intercession/chains/$chainId/slots');
    return (res.data as List)
        .map((e) => PrayerSlotDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PrayerChainDto> draftChain({
    required String bibleClubId,
    required String title,
    required String dateStart,
    String? dateEnd,
  }) async {
    final res = await client.dio.post('/intercession/chains', data: {
      'bibleClubId': bibleClubId,
      'title': title,
      'dateStart': dateStart,
      if (dateEnd != null) 'dateEnd': dateEnd,
    });
    return PrayerChainDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<PrayerChainDto> startChain(String id) async {
    final res = await client.dio.post('/intercession/chains/$id/start');
    return PrayerChainDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<PrayerChainDto> closeChain(String id) async {
    final res = await client.dio.post('/intercession/chains/$id/close');
    return PrayerChainDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<PrayerSlotDto> addSlot({
    required String chainId,
    required String start,
    required String end,
  }) async {
    final res =
        await client.dio.post('/intercession/chains/$chainId/slots', data: {
      'start': start,
      'end': end,
    });
    return PrayerSlotDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<PrayerSlotDto> coverSlot({
    required String slotId,
    required String intercessorMemberId,
    String? note,
  }) async {
    final res =
        await client.dio.post('/intercession/slots/$slotId/cover', data: {
      'intercessorMemberId': intercessorMemberId,
      if (note != null) 'note': note,
    });
    return PrayerSlotDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<PrayerSlotDto> uncoverSlot(String slotId) async {
    final res = await client.dio.post('/intercession/slots/$slotId/uncover');
    return PrayerSlotDto.fromJson(res.data as Map<String, dynamic>);
  }
}
