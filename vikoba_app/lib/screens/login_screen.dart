import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state/auth_controller.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/sync_provider.dart';
import '../widgets/kitenge_thread.dart';
import 'register_screen.dart';

/// Backend sign-in (email/password → Bearer token via `/auth/login`).
///
/// Also offers a demo path: "Continue offline" opens the app with the sample
/// roster so the whole product stays usable without a server.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final auth = context.read<AuthController>();
    final sync = context.read<SyncProvider>();
    final error = await auth.login(
      email: _email.text.trim(),
      password: _password.text,
    );
    if (error == null) {
      // Connected: let the sync queue start flushing.
      sync.setConnectivity(true);
      return; // AuthGate swaps to the app automatically.
    }
    if (mounted) setState(() {});
  }

  Future<void> _offline() =>
      context.read<AuthController>().continueOffline();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            const KitengeThread(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.appTitle,
                      textAlign: TextAlign.center,
                      style: AppFonts.displayFont(30, FontWeight.w700,
                          color: AppColors.forest),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.authSignInSubtitle,
                      textAlign: TextAlign.center,
                      style: AppFonts.body(14, FontWeight.w500,
                          color: AppColors.inkSoft),
                    ),
                    const SizedBox(height: 36),
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: _field(l10n.authEmail,
                          prefix: Icons.mail_outline),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _password,
                      obscureText: _obscure,
                      onSubmitted: (_) => _signIn(),
                      decoration: _field(l10n.authPassword,
                          prefix: Icons.lock_outline,
                          suffix: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: AppColors.inkSoft,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          )),
                    ),
                    if (auth.error != null) ...[
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.error_outline,
                              size: 18, color: AppColors.clay),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              auth.error!,
                              style: AppFonts.body(13, FontWeight.w500,
                                  color: AppColors.clay),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: auth.busy ? null : _signIn,
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
                          : Text(l10n.authSignIn,
                              style: AppFonts.body(16, FontWeight.w700)),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: auth.busy ? null : _offline,
                      child: Text(l10n.authContinueOffline,
                          style: AppFonts.body(14, FontWeight.w600,
                              color: AppColors.forest)),
                    ),
                    Text(
                      l10n.authOfflineHint,
                      textAlign: TextAlign.center,
                      style: AppFonts.body(12, FontWeight.w400,
                          color: AppColors.inkSoft),
                    ),
                    const SizedBox(height: 28),
                    TextButton.icon(
                      onPressed: auth.busy
                          ? null
                          : () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const RegisterScreen()),
                              ),
                      icon: Icon(Icons.add_business_outlined,
                          size: 18, color: AppColors.forest),
                      label: Text(l10n.authRegister,
                          style: AppFonts.body(14, FontWeight.w600,
                              color: AppColors.forest)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _field(String label, {IconData? prefix, Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        prefixIcon: prefix != null
            ? Icon(prefix, size: 20, color: AppColors.inkSoft)
            : null,
        suffixIcon: suffix,
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
      );
}
