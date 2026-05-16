import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/auth/current_user.dart';
import '../../../core/errors/api_exception.dart';
import '../../meetings/data/meeting_models.dart';
import '../../meetings/data/meeting_repository.dart';
import '../../members/data/member_models.dart';
import '../../members/data/member_repository.dart';
import '../../publications/data/publication_models.dart';
import '../../publications/data/publication_repository.dart';
import '../data/dashboard_models.dart';
import '../data/dashboard_repository.dart';

/// État unifié des 3 dashboards (membre/leader/national). Les sections
/// non pertinentes pour un rôle restent null et le widget les masque.
class DashboardState extends Equatable {
  final bool loading;
  final String? error;

  // Member-only
  final MemberDto? me;
  final AttendanceScoreDto? myScore;
  final DailyVerseDto? todayVerse;
  final MeetingDto? nextMeeting;

  // Leader BBC
  final BibleClubDashboard? bbcDashboard;
  final List<MemberDto> bbcMembers;
  final List<MeetingDto> bbcMeetings;

  // National
  final NationalDashboard? nationalDashboard;

  const DashboardState({
    this.loading = false,
    this.error,
    this.me,
    this.myScore,
    this.todayVerse,
    this.nextMeeting,
    this.bbcDashboard,
    this.bbcMembers = const [],
    this.bbcMeetings = const [],
    this.nationalDashboard,
  });

  DashboardState copyWith({
    bool? loading,
    String? error,
    MemberDto? me,
    AttendanceScoreDto? myScore,
    DailyVerseDto? todayVerse,
    MeetingDto? nextMeeting,
    BibleClubDashboard? bbcDashboard,
    List<MemberDto>? bbcMembers,
    List<MeetingDto>? bbcMeetings,
    NationalDashboard? nationalDashboard,
    bool clearError = false,
  }) =>
      DashboardState(
        loading: loading ?? this.loading,
        error: clearError ? null : error ?? this.error,
        me: me ?? this.me,
        myScore: myScore ?? this.myScore,
        todayVerse: todayVerse ?? this.todayVerse,
        nextMeeting: nextMeeting ?? this.nextMeeting,
        bbcDashboard: bbcDashboard ?? this.bbcDashboard,
        bbcMembers: bbcMembers ?? this.bbcMembers,
        bbcMeetings: bbcMeetings ?? this.bbcMeetings,
        nationalDashboard: nationalDashboard ?? this.nationalDashboard,
      );

  @override
  List<Object?> get props => [
        loading,
        error,
        me,
        myScore,
        todayVerse,
        nextMeeting,
        bbcDashboard,
        bbcMembers,
        bbcMeetings,
        nationalDashboard,
      ];
}

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository dashboardRepository;
  final MemberRepository memberRepository;
  final MeetingRepository meetingRepository;
  final PublicationRepository publicationRepository;
  final CurrentUser user;

  DashboardCubit({
    required this.dashboardRepository,
    required this.memberRepository,
    required this.meetingRepository,
    required this.publicationRepository,
    required this.user,
  }) : super(const DashboardState());

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final isNational = user.hasPermission('bbcms:dashboard:national');
      final isLeader = user.hasPermission('bbcms:dashboard:bbc');

      // Charge en parallèle ce qui est pertinent.
      final futures = <Future<void>>[];

      // 1. Verset du jour (toujours)
      futures.add(_loadVerse());

      // 2. Membre courant + score (si étudiant)
      if (user.userType == 'STUDENT') {
        futures.add(_loadMyMemberAndScore());
      }

      // 3. Dashboard BBC (leader OU étudiant rattaché à un BBC)
      if (user.bibleClubId != null && user.bibleClubId!.isNotEmpty) {
        futures.add(_loadBbcDashboard(user.bibleClubId!, asLeader: isLeader));
      }

      // 4. Dashboard national (super-admin / leader national)
      if (isNational) {
        futures.add(_loadNational());
      }

      await Future.wait(futures);
      emit(state.copyWith(loading: false));
    } on ApiException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: 'Impossible de charger les données — vérifie ta connexion.',
      ));
    }
  }

  Future<void> _loadVerse() async {
    try {
      final v = await publicationRepository.todayVerse();
      if (v != null) emit(state.copyWith(todayVerse: v));
    } catch (_) {
      // Optionnel — ignore l'erreur sur le verset (non-bloquant)
    }
  }

  Future<void> _loadMyMemberAndScore() async {
    try {
      final me = await memberRepository.me();
      if (me == null) return;
      emit(state.copyWith(me: me));
      final score = await memberRepository.myScore(me.id);
      if (score != null) emit(state.copyWith(myScore: score));
    } catch (_) {/* silencieux */ }
  }

  Future<void> _loadBbcDashboard(String bibleClubId,
      {required bool asLeader}) async {
    try {
      final futures = <Future<dynamic>>[
        dashboardRepository.bbcDashboard(bibleClubId),
        meetingRepository.listByBibleClub(bibleClubId),
      ];
      if (asLeader) {
        futures.add(memberRepository.listByBibleClub(bibleClubId));
      }
      final results = await Future.wait(futures);
      final dash = results[0] as BibleClubDashboard;
      final meetings = (results[1] as List<MeetingDto>);
      final members = asLeader ? (results[2] as List<MemberDto>) : <MemberDto>[];

      // Prochaine réunion planifiée
      final now = DateTime.now();
      final upcoming = meetings
          .where((m) =>
              m.status == MeetingStatus.planned &&
              m.plannedStart.isAfter(now))
          .toList()
        ..sort((a, b) => a.plannedStart.compareTo(b.plannedStart));

      emit(state.copyWith(
        bbcDashboard: dash,
        bbcMeetings: meetings,
        bbcMembers: members,
        nextMeeting: upcoming.isEmpty ? null : upcoming.first,
      ));
    } catch (_) {/* silencieux — l'UI affichera un état vide */ }
  }

  Future<void> _loadNational() async {
    try {
      final n = await dashboardRepository.national();
      emit(state.copyWith(nationalDashboard: n));
    } catch (_) {/* silencieux */ }
  }
}
