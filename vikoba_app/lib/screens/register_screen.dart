import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state/auth_controller.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/sync_provider.dart';
import '../widgets/kitenge_thread.dart';
import 'success_screen.dart';

/// Registers a brand-new group + treasurer (`POST /auth/register`) and signs
/// in automatically. Single-group MVP: this creates the whole group.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _group = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _group.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      _email.text.trim().isNotEmpty &&
      _phone.text.trim().isNotEmpty &&
      _group.text.trim().isNotEmpty &&
      _password.text.length >= 8;

  Future<void> _submit() async {
    final auth = context.read<AuthController>();
    final sync = context.read<SyncProvider>();
    final navigator = Navigator.of(context);
    final error = await auth.register(
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      password: _password.text,
      groupName: _group.text.trim(),
    );
    if (error == null) {
      sync.setConnectivity(true);
      if (mounted) {
        navigator.pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const SuccessScreen()),
        );
      }
      return;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        title: Text(l10n.authRegister,
            style: AppFonts.displayFont(20, FontWeight.w700)),
      ),
      body: Column(
        children: [
          const KitengeThread(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _field(_name, l10n.authName, Icons.person_outline),
                  const SizedBox(height: 14),
                  _field(_email, l10n.authEmail, Icons.mail_outline),
                  const SizedBox(height: 14),
                  _field(_phone, l10n.authPhone, Icons.phone_outlined),
                  const SizedBox(height: 14),
                  _field(_group, l10n.authGroupName, Icons.groups_outlined),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _password,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: l10n.authPassword,
                      prefixIcon: Icon(Icons.lock_outline,
                          size: 20, color: AppColors.inkSoft),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: AppColors.inkSoft,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.line),
                      ),
                    ),
                  ),
                  if (auth.error != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      auth.error!,
                      style: AppFonts.body(13, FontWeight.w500,
                          color: AppColors.clay),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: (auth.busy || !_valid) ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.forest,
                      foregroundColor: AppColors.cream,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: auth.busy
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: AppColors.cream),
                          )
                        : Text(l10n.authCreateAccount,
                            style: AppFonts.body(16, FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon) =>
      TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon:
              Icon(icon, size: 20, color: AppColors.inkSoft),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.line),
          ),
        ),
      );
}
