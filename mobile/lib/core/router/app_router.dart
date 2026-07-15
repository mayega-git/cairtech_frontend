import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_bloc.dart';
import '../di/service_locator.dart';
import '../../features/auth/presentation/activation_page.dart';
import '../../features/auth/presentation/change_password_page.dart';
import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/reset_password_page.dart';
import '../../features/dashboard/presentation/home_tab.dart';
import '../../features/meetings/presentation/meeting_attendance_page.dart';
import '../../features/meetings/presentation/meeting_create_page.dart';
import '../../features/meetings/presentation/meeting_detail_page.dart';
import '../../features/meetings/presentation/meetings_tab.dart';
import '../../features/members/presentation/member_detail_page.dart';
import '../../features/members/presentation/members_tab.dart';
import '../../features/admin/presentation/bible_club_admin_detail_page.dart';
import '../../features/admin/presentation/bible_clubs_admin_page.dart';
import '../../features/discipleship/presentation/discipleship_page.dart';
import '../../features/evangelism/presentation/evangelism_page.dart';
import '../../features/evangelism/presentation/evangelism_program_detail_page.dart';
import '../../features/events/presentation/event_create_page.dart';
import '../../features/events/presentation/event_detail_page.dart';
import '../../features/events/presentation/events_page.dart';
import '../../features/finance/presentation/contribution_detail_page.dart';
import '../../features/finance/presentation/finance_page.dart';
import '../../features/intercession/presentation/prayer_chain_detail_page.dart';
import '../../features/intercession/presentation/prayer_chains_page.dart';
import '../../features/membership_requests/presentation/membership_requests_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/profile/presentation/profile_tab.dart';
import '../../features/publications/presentation/publication_create_page.dart';
import '../../features/publications/presentation/spiritual_tab.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/shell/presentation/feature_stub_page.dart';
import '../../features/shell/presentation/widget_gallery_page.dart';

/// Routes nommées centralisées.
class AppRoutes {
  AppRoutes._();

  // Public
  static const splash = '/';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const activate = '/activate';
  static const onboarding = '/onboarding';

  // Tabs (shell)
  static const home = '/home';
  static const meetings = '/meetings';
  static const meetingsBase = '/meetings';
  static const meetingCreate = '/meetings/new';
  static const members = '/members';
  static const membersBase = '/members';
  static const prayerChains = '/intercession/chains';
  static const prayerChainsBase = '/intercession/chains';
  static const publicationCreate = '/publications/new';
  static const spiritual = '/spiritual';
  static const profile = '/profile';

  // Other routes
  static const gallery = '/_gallery';
  static const changePassword = '/me/change-password';

  // Leader / admin routes (drawer)
  static const membershipRequests = '/admin/membership-requests';
  static const adminBibleClubs = '/admin/bible-clubs';
  static const adminBibleClubsBase = '/admin/bible-clubs';
  static const events = '/events';
  static const eventsBase = '/events';
  static const eventCreate = '/events/new';
  static const evangelism = '/evangelism';
  static const evangelismBase = '/evangelism';
  static const discipleship = '/discipleship';
  static const finance = '/finance';
  static const financeBase = '/finance';
  static const publications = '/publications';
  static const nationalDashboard = '/admin/dashboard';
}

/// Clé root globale — requise pour que GoRouter résolve
/// les routes imbriquées dans [StatefulShellRoute] lors des redirects.
final _rootNavKey = GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter buildRouter() {
  final auth = sl<AuthBloc>();

  return GoRouter(
    navigatorKey: _rootNavKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: _BlocListenable(auth.stream),
    redirect: (context, state) {
      final s = auth.state;
      final loggedIn = s is AuthAuthenticated;
      final loc = state.matchedLocation;
      final publicRoutes = {
        AppRoutes.login,
        AppRoutes.forgotPassword,
        AppRoutes.resetPassword,
        AppRoutes.activate,
        AppRoutes.onboarding,
      };
      final isPublic = publicRoutes.contains(loc);
      final initial = loc == AppRoutes.splash;

      if (s is AuthInitial || s is AuthInProgress) {
        return initial ? null : AppRoutes.splash;
      }
      if (!loggedIn && !isPublic) return AppRoutes.login;
      if (loggedIn && (loc == AppRoutes.login || initial)) return AppRoutes.home;
      return null;
    },
    routes: [
      // ── Public ─────────────────────────────────────────────────────
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const _SplashPage()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginPage()),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => ResetPasswordPage(
          token: state.uri.queryParameters['token'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.activate,
        builder: (context, state) => ActivationPage(
          token: state.uri.queryParameters['token'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingPage(),
      ),

      // ── Authenticated shell (5 tabs) ───────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.home,
                builder: (_, __) => const HomeTabPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.meetings,
                builder: (_, __) => const MeetingsTabPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.members,
                builder: (_, __) => const MembersTabPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.spiritual,
                builder: (_, __) => const SpiritualTabPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.profile,
                builder: (_, __) => const ProfileTabPage()),
          ]),
        ],
      ),

      // ── Other authenticated routes ────────────────────────────────
      GoRoute(
        path: AppRoutes.gallery,
        builder: (_, __) => const WidgetGalleryPage(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        builder: (_, __) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.meetingCreate,
        builder: (_, __) => const MeetingCreatePage(),
      ),
      GoRoute(
        path: '${AppRoutes.meetingsBase}/:id',
        builder: (context, state) =>
            MeetingDetailPage(meetingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '${AppRoutes.meetingsBase}/:id/record',
        builder: (context, state) =>
            MeetingAttendancePage(meetingId: state.pathParameters['id']!),
      ),

      // ── Leader stubs (drawer destinations) ─────────────────────────
      GoRoute(
        path: AppRoutes.membershipRequests,
        builder: (_, __) => const MembershipRequestsPage(),
      ),
      GoRoute(
        path: '${AppRoutes.membersBase}/:id',
        builder: (context, state) =>
            MemberDetailPage(memberId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.adminBibleClubs,
        builder: (_, __) => const BibleClubsAdminPage(),
      ),
      GoRoute(
        path: '${AppRoutes.adminBibleClubsBase}/:id',
        builder: (context, state) =>
            BibleClubAdminDetailPage(bibleClubId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.events,
        builder: (_, __) => const EventsPage(),
      ),
      GoRoute(
        path: AppRoutes.eventCreate,
        builder: (_, __) => const EventCreatePage(),
      ),
      GoRoute(
        path: '${AppRoutes.eventsBase}/:id',
        builder: (context, state) =>
            EventDetailPage(eventId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.evangelism,
        builder: (_, __) => const EvangelismPage(),
      ),
      GoRoute(
        path: '${AppRoutes.evangelismBase}/:id',
        builder: (context, state) => EvangelismProgramDetailPage(
            programId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.discipleship,
        builder: (_, __) => const DiscipleshipPage(),
      ),
      GoRoute(
        path: AppRoutes.finance,
        builder: (_, __) => const FinancePage(),
      ),
      GoRoute(
        path: '${AppRoutes.financeBase}/:id',
        builder: (context, state) =>
            ContributionDetailPage(contributionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.publications,
        builder: (_, __) => const PublicationCreatePage(),
      ),
      GoRoute(
        path: AppRoutes.publicationCreate,
        builder: (_, __) => const PublicationCreatePage(),
      ),
      GoRoute(
        path: AppRoutes.prayerChains,
        builder: (_, __) => const PrayerChainsPage(),
      ),
      GoRoute(
        path: '${AppRoutes.prayerChainsBase}/:id',
        builder: (context, state) =>
            PrayerChainDetailPage(chainId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.nationalDashboard,
        builder: (_, __) => const FeatureStubPage(
          eyebrow: 'PILOTAGE',
          title: 'Vue nationale CHF',
          subtitle:
              'Total membres actifs, classement BBC, carte des provinces — '
              'Phase 3 (dashboards).',
          icon: Icons.public,
          roadmap: 'Phase 3 — Dashboards',
        ),
      ),
    ],
  );
}

/// Pont entre AuthBloc.stream et Listenable pour go_router.refreshListenable.
class _BlocListenable extends ChangeNotifier {
  _BlocListenable(Stream stream) {
    stream.listen((_) => notifyListeners());
  }
}

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
