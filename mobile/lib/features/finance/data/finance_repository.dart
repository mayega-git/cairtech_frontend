import 'package:equatable/equatable.dart';

import '../../../core/api/dio_client.dart';

/// PaymentChannel: CASH / MTN_MOMO / ORANGE_MONEY / BANK_TRANSFER (cahier UC-FIN-01).
enum PaymentChannel { cash, mtnMomo, orangeMoney, bankTransfer }

extension PaymentChannelApi on PaymentChannel {
  String get backendName => switch (this) {
        PaymentChannel.cash => 'CASH',
        PaymentChannel.mtnMomo => 'MTN_MOMO',
        PaymentChannel.orangeMoney => 'ORANGE_MONEY',
        PaymentChannel.bankTransfer => 'BANK_TRANSFER',
      };

  String get label => switch (this) {
        PaymentChannel.cash => 'Cash',
        PaymentChannel.mtnMomo => 'MTN MoMo',
        PaymentChannel.orangeMoney => 'Orange Money',
        PaymentChannel.bankTransfer => 'Virement',
      };
}

PaymentChannel paymentChannelFromString(String s) => switch (s) {
      'CASH' => PaymentChannel.cash,
      'MTN_MOMO' => PaymentChannel.mtnMomo,
      'ORANGE_MONEY' => PaymentChannel.orangeMoney,
      'BANK_TRANSFER' => PaymentChannel.bankTransfer,
      _ => PaymentChannel.cash,
    };

class ContributionDto extends Equatable {
  final String id;
  final String bibleClubId;
  final String title;
  final double objectiveAmount;
  final String currency;
  final double totalContributed;
  final double percentageReached;
  final String status; // OPEN / CLOSED
  final DateTime dateOpen;
  final DateTime? dateClose;

  const ContributionDto({
    required this.id,
    required this.bibleClubId,
    required this.title,
    required this.objectiveAmount,
    required this.currency,
    required this.totalContributed,
    required this.percentageReached,
    required this.status,
    required this.dateOpen,
    this.dateClose,
  });

  factory ContributionDto.fromJson(Map<String, dynamic> j) {
    double n(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return ContributionDto(
      id: j['id'] as String,
      bibleClubId: j['bibleClubId'] as String,
      title: j['title'] as String,
      objectiveAmount: n(j['objectiveAmount']),
      currency: j['currency'] as String? ?? 'XAF',
      totalContributed: n(j['totalContributed']),
      percentageReached: n(j['percentageReached']),
      status: j['status'] as String,
      dateOpen: DateTime.parse(j['dateOpen'] as String),
      dateClose: j['dateClose'] == null
          ? null
          : DateTime.parse(j['dateClose'] as String),
    );
  }

  bool get isOpen => status == 'OPEN';
  double get ratio =>
      objectiveAmount == 0 ? 0 : (totalContributed / objectiveAmount).clamp(0.0, 1.0);

  @override
  List<Object?> get props => [
        id, bibleClubId, title, objectiveAmount, currency,
        totalContributed, percentageReached, status, dateOpen, dateClose,
      ];
}

class ContributionLineDto extends Equatable {
  final String id;
  final String contributionId;
  final String? contributorMemberId;
  final String? contributorName;
  final double amount;
  final PaymentChannel paymentChannel;
  final String? paymentReference;
  final DateTime paymentDate;

  const ContributionLineDto({
    required this.id,
    required this.contributionId,
    this.contributorMemberId,
    this.contributorName,
    required this.amount,
    required this.paymentChannel,
    this.paymentReference,
    required this.paymentDate,
  });

  factory ContributionLineDto.fromJson(Map<String, dynamic> j) {
    double n(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return ContributionLineDto(
      id: j['id'] as String,
      contributionId: j['contributionId'] as String,
      contributorMemberId: j['contributorMemberId'] as String?,
      contributorName: j['contributorName'] as String?,
      amount: n(j['amount']),
      paymentChannel: paymentChannelFromString(j['paymentChannel'] as String),
      paymentReference: j['paymentReference'] as String?,
      paymentDate: DateTime.parse(j['paymentDate'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id, contributionId, contributorMemberId, contributorName,
        amount, paymentChannel, paymentReference, paymentDate,
      ];
}

class FinanceRepository {
  final DioClient client;
  FinanceRepository(this.client);

  Future<List<ContributionDto>> listByBibleClub(String bibleClubId) async {
    final res = await client.dio.get(
      '/finance/contributions',
      queryParameters: {'bibleClubId': bibleClubId},
    );
    return (res.data as List)
        .map((e) => ContributionDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ContributionDto> findById(String id) async {
    final res = await client.dio.get('/finance/contributions/$id');
    return ContributionDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<ContributionDto> openContribution({
    required String bibleClubId,
    required String title,
    String? description,
    required double objective,
    String? dateOpen,
  }) async {
    final res = await client.dio.post('/finance/contributions', data: {
      'bibleClubId': bibleClubId,
      'title': title,
      if (description != null) 'description': description,
      'objective': objective,
      if (dateOpen != null) 'dateOpen': dateOpen,
    });
    return ContributionDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<ContributionDto> close(String id, {String? when}) async {
    final res = await client.dio.post('/finance/contributions/$id/close', data: {
      if (when != null) 'when': when,
    });
    return ContributionDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<ContributionLineDto> recordPayment({
    required String contributionId,
    String? memberId,
    String? contributorName,
    required double amount,
    required PaymentChannel channel,
    String? reference,
    String? paymentDate,
  }) async {
    final res = await client.dio
        .post('/finance/contributions/$contributionId/payments', data: {
      if (memberId != null) 'memberId': memberId,
      if (contributorName != null) 'contributorName': contributorName,
      'amount': amount,
      'channel': channel.backendName,
      if (reference != null) 'reference': reference,
      if (paymentDate != null) 'paymentDate': paymentDate,
    });
    return ContributionLineDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<ContributionLineDto>> listPayments(String contributionId) async {
    final res =
        await client.dio.get('/finance/contributions/$contributionId/payments');
    return (res.data as List)
        .map((e) => ContributionLineDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
