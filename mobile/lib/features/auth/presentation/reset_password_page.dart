import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_repository.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/screen_header.dart';

/// Page atteinte via le lien envoyé par email (`?token=...`).
class ResetPasswordPage extends StatefulWidget {
  final String token;
  const ResetPasswordPage({super.key, required this.token});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscure = true;
  String? _error;
  bool _done = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await sl<AuthRepository>().confirmPasswordReset(
        token: widget.token,
        newPassword: _password.text,
      );
      setState(() {
        _done = true;
        _loading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Service indisponible — réessaie plus tard.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScreenHeader(
                eyebrow: 'AUTHENTIFICATION',
                title: 'Nouveau mot de passe',
                subtitle: 'Choisis un mot de passe d\'au moins 8 caractères.',
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              if (_done) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECF3EE),
                    border: Border.all(color: const Color(0xFFD6E4DC)),
                    borderRadius: BorderRadius.circular(AppRadius.lg - 2),
                  ),
                  child: Text(
                    'Mot de passe mis à jour. Vous pouvez maintenant vous connecter '
                    'avec votre nouveau mot de passe.',
                    style: AppTypography.sans(
                        size: 13, color: AppColors.positive, height: 1.5),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text('Aller à la connexion'),
                  ),
                ),
              ] else
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NOUVEAU MOT DE PASSE', style: AppTypography.eyebrow()),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _password,
                        obscureText: _obscure,
                        validator: (v) => (v == null || v.length < 8)
                            ? 'Au moins 8 caractères'
                            : null,
                        decoration: InputDecoration(
                          prefixIcon: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child:
                                Icon(Icons.lock_outline, size: 18, color: AppColors.muted),
                          ),
                          prefixIconConstraints:
                              const BoxConstraints(minWidth: 40, minHeight: 40),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 18,
                              color: AppColors.muted,
                            ),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                          hintText: '••••••••',
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text('CONFIRMER', style: AppTypography.eyebrow()),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _confirm,
                        obscureText: _obscure,
                        validator: (v) =>
                            v != _password.text ? 'Les mots de passe diffèrent' : null,
                        decoration: const InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child:
                                Icon(Icons.lock_outline, size: 18, color: AppColors.muted),
                          ),
                          prefixIconConstraints:
                              BoxConstraints(minWidth: 40, minHeight: 40),
                          hintText: '••••••••',
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(_error!,
                            style:
                                AppTypography.sans(size: 12, color: AppColors.danger)),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          child: _loading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Valider'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
