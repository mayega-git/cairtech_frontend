import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/auth/current_user.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../meetings/data/meeting_repository.dart';
import '../../members/data/member_repository.dart';
import '../../publications/data/publication_repository.dart';
import '../../shell/presentation/app_shell.dart';
import '../data/dashboard_repository.dart';
import 'dashboard_cubit.dart';
import 'widgets/leader_dashboard.dart';
import 'widgets/member_dashboard.dart';
import 'widgets/national_dashboard.dart';

class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      bloc: sl<AuthBloc>(),
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Center(child: CircularProgressIndicator());
        }
        return _HomeContent(user: authState.user);
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  final CurrentUser user;
  const _HomeContent({required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardCubit>(
      create: (_) => DashboardCubit(
        dashboardRepository: DashboardRepository(sl()),
        memberRepository: MemberRepository(sl()),
        meetingRepository: MeetingRepository(sl()),
        publicationRepository: PublicationRepository(sl()),
        user: user,
      )..load(),
      child: _DashboardView(user: user),
    );
  }
}

class _DashboardView extends StatelessWidget {
  final CurrentUser user;
  const _DashboardView({required this.user});

  @override
  Widget build(BuildContext context) {
    final isNational = user.hasPermission('bbcms:dashboard:national');
    final isLeader = user.hasPermission('bbcms:dashboard:bbc');
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return Column(
          children: [
            HomeGreetingHeader(
              actions: [
                RoundIconButton(
                  onTap: () => context.read<DashboardCubit>().load(),
                  child: const Icon(Icons.refresh, size: 15),
                ),
                const SizedBox(width: 6),
                RoundIconButton(
                  hasBadge: false,
                  onTap: () {},
                  child: const Icon(Icons.notifications_outlined, size: 15),
                ),
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<DashboardCubit>().load(),
                child: _body(context, state, isNational: isNational, isLeader: isLeader),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    DashboardState s, {
    required bool isNational,
    required bool isLeader,
  }) {
    if (s.loading && s.nationalDashboard == null && s.bbcDashboard == null && s.myScore == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (s.error != null && s.bbcDashboard == null && s.nationalDashboard == null && s.myScore == null) {
      return _errorState(context, s.error!);
    }

    // Priorité d'affichage : national > leader BBC > membre
    if (isNational && s.nationalDashboard != null) {
      return NationalDashboardBody(data: s.nationalDashboard!);
    }
    if (isLeader && s.bbcDashboard != null) {
      return LeaderDashboardBody(
        dashboard: s.bbcDashboard!,
        members: s.bbcMembers,
        meetings: s.bbcMeetings,
      );
    }
    return MemberDashboard(
      member: s.me,
      score: s.myScore,
      verse: s.todayVerse,
      nextMeeting: s.nextMeeting,
      bbcDashboard: s.bbcDashboard,
    );
  }

  Widget _errorState(BuildContext context, String msg) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.warning_amber_outlined,
            size: 32, color: AppColors.muted),
        const SizedBox(height: 12),
        Center(
          child: Text(
            msg,
            textAlign: TextAlign.center,
            style: AppTypography.sans(size: 13, color: AppColors.muted, height: 1.5),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton.icon(
            onPressed: () => context.read<DashboardCubit>().load(),
            icon: const Icon(Icons.refresh, size: 14),
            label: const Text('Réessayer'),
          ),
        ),
      ],
    );
  }
}
