import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController(text: 'admin@chf.org');
  final _password = TextEditingController(text: 'ChangeMeNow_2025!');
  final _form = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AuthBloc>(),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final loading = state is AuthInProgress;
          return Scaffold(
            backgroundColor: AppColors.ink,
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(child: _heroHeader()),
                  _formCard(context, loading, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _heroHeader() => Padding(
        padding: const EdgeInsets.fromLTRB(28, 40, 28, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text('B',
                      style: AppTypography.serif(
                          size: 18,
                          weight: FontWeight.w500,
                          color: AppColors.ink,
                          height: 1)),
                ),
                const SizedBox(width: 10),
                Text(
                  'BBCMS · CHF',
                  style: AppTypography.mono(
                    size: 11,
                    color: Colors.white.withOpacity(0.6),
                    letterSpacing: 1.8,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CONNEXION',
                    style: AppTypography.eyebrow(color: Colors.white.withOpacity(0.5)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bienvenue\ndans la maison.',
                    style: AppTypography.serif(
                      size: 44,
                      weight: FontWeight.w400,
                      color: Colors.white,
                      height: 1.05,
                      letterSpacing: -0.88,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Text(
                      'Suivez votre fidélité, vos réunions et votre marche avec vos frères et sœurs.',
                      style: AppTypography.sans(
                        size: 14,
                        color: Colors.white.withOpacity(0.65),
                        weight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _formCard(BuildContext context, bool loading, AuthState state) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field(
              label: 'Adresse e-mail',
              icon: Icons.mail_outline,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  (v == null || !v.contains('@')) ? 'Email invalide' : null,
            ),
            const SizedBox(height: 12),
            _field(
              label: 'Mot de passe',
              icon: Icons.lock_outline,
              controller: _password,
              obscure: _obscure,
              suffix: IconButton(
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 18, color: AppColors.muted),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              validator: (v) =>
                  (v == null || v.length < 8) ? '8 caractères minimum' : null,
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mot de passe oublié ?',
                    style: AppTypography.mono(size: 11, color: AppColors.muted)),
                Text(
                  'Réinitialiser',
                  style: AppTypography.mono(
                    size: 11,
                    color: AppColors.ink,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (state is AuthUnauthenticated && state.message != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  state.message!,
                  style: AppTypography.sans(size: 12, color: AppColors.danger),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading
                    ? null
                    : () {
                        if (_form.currentState!.validate()) {
                          context.read<AuthBloc>().add(AuthLoginRequested(
                                email: _email.text.trim(),
                                password: _password.text,
                              ));
                        }
                      },
                child: loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Se connecter'),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 14),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: RichText(
                text: TextSpan(
                  style: AppTypography.sans(size: 13, color: AppColors.muted),
                  children: [
                    const TextSpan(text: 'Pas encore membre ? '),
                    TextSpan(
                      text: "Demander l'adhésion",
                      style: AppTypography.sans(
                        size: 13,
                        color: AppColors.ink,
                        weight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(
                'V3.2 · SÉCURISÉ PAR JWT',
                style: AppTypography.mono(
                  size: 9,
                  color: AppColors.muted2,
                  letterSpacing: 1.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 2),
          child: Text(label.toUpperCase(), style: AppTypography.eyebrow()),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTypography.sans(size: 15),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Icon(icon, size: 18, color: AppColors.muted),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
