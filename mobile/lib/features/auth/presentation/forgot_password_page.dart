import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_repository.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/screen_header.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _email = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await sl<AuthRepository>().requestPasswordReset(_email.text.trim());
      setState(() {
        _sent = true;
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
              Row(
                children: [
                  RoundIconButton(
                    onTap: () => context.go(AppRoutes.login),
                    child: const Icon(Icons.arrow_back, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const ScreenHeader(
                eyebrow: 'AUTHENTIFICATION',
                title: 'Mot de passe oublié',
                subtitle:
                    'Saisis ton email — un lien de réinitialisation te sera envoyé.',
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              if (_sent) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECF3EE),
                    border: Border.all(color: const Color(0xFFD6E4DC)),
                    borderRadius: BorderRadius.circular(AppRadius.lg - 2),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: AppColors.positive),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Si un compte est associé à cet email, un message vient "
                          "d'être envoyé. Suivez le lien dans le mail pour choisir "
                          "un nouveau mot de passe (valable 2 heures).",
                          style: AppTypography.sans(
                              size: 13, color: AppColors.positive, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text('Retour à la connexion'),
                  ),
                ),
              ] else
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ADRESSE E-MAIL', style: AppTypography.eyebrow()),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        validator: (v) =>
                            (v == null || !v.contains('@')) ? 'Email invalide' : null,
                        decoration: const InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Icon(Icons.mail_outline,
                                size: 18, color: AppColors.muted),
                          ),
                          prefixIconConstraints:
                              BoxConstraints(minWidth: 40, minHeight: 40),
                          hintText: 'vous@chf.org',
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(_error!,
                            style: AppTypography.sans(
                                size: 12, color: AppColors.danger)),
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
                              : const Text('Envoyer le lien'),
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
