import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_repository.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Page atteinte via le lien dans l'email de bienvenue (`?token=...`).
class ActivationPage extends StatefulWidget {
  final String token;
  const ActivationPage({super.key, required this.token});

  @override
  State<ActivationPage> createState() => _ActivationPageState();
}

class _ActivationPageState extends State<ActivationPage> {
  bool _loading = true;
  bool _success = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _activate();
  }

  Future<void> _activate() async {
    try {
      await sl<AuthRepository>().activate(widget.token);
      setState(() {
        _success = true;
        _loading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Activation impossible — vérifie le lien ou réessaie.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: _content(),
          ),
        ),
      ),
    );
  }

  Widget _content() {
    if (_loading) {
      return const CircularProgressIndicator();
    }
    if (_success) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.positive,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 18),
          Text('Compte activé',
              style: AppTypography.serif(size: 32, letterSpacing: -0.6)),
          const SizedBox(height: 8),
          Text(
            "Bienvenue dans la communauté BBCMS. Vous pouvez maintenant\nvous connecter.",
            textAlign: TextAlign.center,
            style: AppTypography.sans(size: 14, color: AppColors.muted, height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.login),
            child: const Text('Se connecter'),
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.danger,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, size: 32, color: Colors.white),
        ),
        const SizedBox(height: 18),
        Text("Activation impossible",
            style: AppTypography.serif(size: 28, letterSpacing: -0.6)),
        const SizedBox(height: 8),
        Text(
          _error ?? 'Le lien d\'activation est invalide ou expiré.',
          textAlign: TextAlign.center,
          style: AppTypography.sans(size: 13, color: AppColors.muted, height: 1.5),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => context.go(AppRoutes.login),
          child: const Text('Retour'),
        ),
      ],
    );
  }
}
