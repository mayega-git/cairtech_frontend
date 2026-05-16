import 'package:equatable/equatable.dart';

/// Réponse `/dashboards/bible-clubs/{id}`.
class BibleClubDashboard extends Equatable {
  final String bibleClubId;
  final String name;
  final String status;
  final int academicYear;
  final int? goalNbFaithful;
  final int nbMembers;
  final int nbFaithful;
  final double percentageReached;
  final int nbMeetingsRecorded;
  final int nbActiveContributions;
  final double totalContributedAmount;

  const BibleClubDashboard({
    required this.bibleClubId,
    required this.name,
    required this.status,
    required this.academicYear,
    required this.goalNbFaithful,
    required this.nbMembers,
    required this.nbFaithful,
    required this.percentageReached,
    required this.nbMeetingsRecorded,
    required this.nbActiveContributions,
    required this.totalContributedAmount,
  });

  factory BibleClubDashboard.fromJson(Map<String, dynamic> j) {
    return BibleClubDashboard(
      bibleClubId: j['bibleClubId'] as String,
      name: j['name'] as String,
      status: j['status'] as String,
      academicYear: (j['academicYear'] as num).toInt(),
      goalNbFaithful: (j['goalNbFaithful'] as num?)?.toInt(),
      nbMembers: (j['nbMembers'] as num).toInt(),
      nbFaithful: (j['nbFaithful'] as num).toInt(),
      percentageReached: _num(j['percentageReached']),
      nbMeetingsRecorded: (j['nbMeetingsRecorded'] as num).toInt(),
      nbActiveContributions: (j['nbActiveContributions'] as num).toInt(),
      totalContributedAmount: _num(j['totalContributedAmount']),
    );
  }

  double get faithfulRatio =>
      nbMembers == 0 ? 0 : nbFaithful / nbMembers;

  double get goalRatio {
    final goal = goalNbFaithful ?? 0;
    if (goal == 0) return 0;
    return (nbFaithful / goal).clamp(0.0, 1.0).toDouble();
  }

  static double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  @override
  List<Object?> get props => [
        bibleClubId,
        name,
        status,
        academicYear,
        goalNbFaithful,
        nbMembers,
        nbFaithful,
        percentageReached,
        nbMeetingsRecorded,
        nbActiveContributions,
        totalContributedAmount,
      ];
}

/// Réponse `/dashboards/national`.
class NationalDashboard extends Equatable {
  final int academicYear;
  final int nbBibleClubs;
  final int nbMembersTotal;
  final int nbFaithfulTotal;
  final int nbMeetingsRecordedTotal;
  final double totalContributedTotal;
  final List<BibleClubDashboard> perBibleClub;

  const NationalDashboard({
    required this.academicYear,
    required this.nbBibleClubs,
    required this.nbMembersTotal,
    required this.nbFaithfulTotal,
    required this.nbMeetingsRecordedTotal,
    required this.totalContributedTotal,
    required this.perBibleClub,
  });

  factory NationalDashboard.fromJson(Map<String, dynamic> j) {
    final list = (j['perBibleClub'] as List<dynamic>? ?? [])
        .map((e) => BibleClubDashboard.fromJson(e as Map<String, dynamic>))
        .toList();
    return NationalDashboard(
      academicYear: (j['academicYear'] as num).toInt(),
      nbBibleClubs: (j['nbBibleClubs'] as num).toInt(),
      nbMembersTotal: (j['nbMembersTotal'] as num).toInt(),
      nbFaithfulTotal: (j['nbFaithfulTotal'] as num).toInt(),
      nbMeetingsRecordedTotal:
          (j['nbMeetingsRecordedTotal'] as num).toInt(),
      totalContributedTotal: BibleClubDashboard._num(j['totalContributedTotal']),
      perBibleClub: list,
    );
  }

  double get faithfulRatio =>
      nbMembersTotal == 0 ? 0 : nbFaithfulTotal / nbMembersTotal;

  @override
  List<Object?> get props => [
        academicYear,
        nbBibleClubs,
        nbMembersTotal,
        nbFaithfulTotal,
        nbMeetingsRecordedTotal,
        totalContributedTotal,
        perBibleClub,
      ];
}
