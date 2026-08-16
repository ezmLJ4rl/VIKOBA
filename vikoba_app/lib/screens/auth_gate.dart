import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state/session.dart';
import 'login_screen.dart';
import 'root_shell.dart';

/// Route gate between the login screen and the app shell.
///
/// - authenticated (real backend token) or demo (offline preview) → app shell
/// - otherwise → login screen
///
/// When [enabled] is false the gate is bypassed and the shell always shows
/// (used by widget tests that drive the UI without a backend).
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, this.enabled = true});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const RootShell();
    final session = context.watch<Session>();
    return session.isSignedIn ? const RootShell() : const LoginScreen();
  }
}
