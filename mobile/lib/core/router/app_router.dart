import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_bloc.dart';
import '../di/service_locator.dart';
import '../../features/auth/presentation/activation_page.dart';
import '../../features/auth/presentation/change_password_page.dart';
import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/reset_password_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/shell/presentation/widget_gallery_page.dart';

/// Routes nommées centralisées.
class AppRoutes {
  AppRoutes._();
  static const splash = '/';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const activate = '/activate';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const gallery = '/_gallery';
  static const changePassword = '/me/change-password';
}

GoRouter buildRouter() {
  final auth = sl<AuthBloc>();

  return GoRouter(
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
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const _SplashPage()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginPage()),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordPage(token: token);
        },
      ),
      GoRoute(
        path: AppRoutes.activate,
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return ActivationPage(token: token);
        },
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(path: AppRoutes.home, builder: (_, __) => const WidgetGalleryPage()),
      GoRoute(path: AppRoutes.gallery, builder: (_, __) => const WidgetGalleryPage()),
      GoRoute(
        path: AppRoutes.changePassword,
        builder: (_, __) => const ChangePasswordPage(),
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
