import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_bloc.dart';
import '../di/service_locator.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/shell/presentation/widget_gallery_page.dart';

/// Routes nommées centralisées.
class AppRoutes {
  AppRoutes._();
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const gallery = '/_gallery';
}

GoRouter buildRouter() {
  final auth = sl<AuthBloc>();

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _BlocListenable(auth.stream),
    redirect: (context, state) {
      final s = auth.state;
      final loggedIn = s is AuthAuthenticated;
      final loggingIn = state.matchedLocation == AppRoutes.login;
      final initial = state.matchedLocation == AppRoutes.splash;

      if (s is AuthInitial || s is AuthInProgress) {
        return initial ? null : AppRoutes.splash;
      }
      if (!loggedIn && !loggingIn) return AppRoutes.login;
      if (loggedIn && (loggingIn || initial)) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const _SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const WidgetGalleryPage(),
      ),
      GoRoute(
        path: AppRoutes.gallery,
        builder: (_, __) => const WidgetGalleryPage(),
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
