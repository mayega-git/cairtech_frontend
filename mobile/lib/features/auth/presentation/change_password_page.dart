import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_repository.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/screen_header.dart';

/// Page accessible depuis le profil pour changer son mot de passe.
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscure = true;
  String? _error;
  bool _success = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
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
      await sl<AuthRepository>().changePassword(
        currentPassword: _current.text,
        newPassword: _next.text,
      );
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
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const ScreenHeader(
                eyebrow: 'COMPTE',
                title: 'Changer mon mot de passe',
                subtitle: 'Renseigne ton mot de passe actuel et un nouveau.',
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              if (_success) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECF3EE),
                    border: Border.all(color: const Color(0xFFD6E4DC)),
                    borderRadius: BorderRadius.circular(AppRadius.lg - 2),
                  ),
                  child: Text(
                    'Mot de passe mis à jour avec succès.',
                    style: AppTypography.sans(
                        size: 13, color: AppColors.positive, height: 1.5),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Retour'),
                  ),
                ),
              ] else
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Mot de passe actuel'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _current,
                        obscureText: _obscure,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Requis' : null,
                        decoration: const InputDecoration(),
                      ),
                      const SizedBox(height: 14),
                      _label('Nouveau mot de passe (8+)'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _next,
                        obscureText: _obscure,
                        validator: (v) => (v == null || v.length < 8)
                            ? 'Au moins 8 caractères'
                            : null,
                        decoration: InputDecoration(
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
                        ),
                      ),
                      const SizedBox(height: 14),
                      _label('Confirmer'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _confirm,
                        obscureText: _obscure,
                        validator: (v) =>
                            v != _next.text ? 'Les mots de passe diffèrent' : null,
                        decoration: const InputDecoration(),
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

  Widget _label(String s) => Text(s.toUpperCase(), style: AppTypography.eyebrow());
}
