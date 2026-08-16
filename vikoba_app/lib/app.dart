import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/data/app_repository.dart';
import 'core/data/vikoba_api.dart';
import 'core/state/app_navigation.dart';
import 'core/state/auth_controller.dart';
import 'core/state/notifications.dart';
import 'core/state/session.dart';
import 'core/state/theme_controller.dart';
import 'providers/contributions_provider.dart';
import 'providers/group_settings_provider.dart';
import 'providers/loans_provider.dart';
import 'providers/meetings_provider.dart';
import 'providers/members_provider.dart';
import 'providers/sync_provider.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth_gate.dart';

import 'l10n/app_localizations.dart';

/// Root widget: wires every domain provider to its own [AppRepository] (the
/// data gateway) so screens never touch storage or persistence directly.
///
/// Each provider loads lazily from the shared repository — the repository
/// memoizes its disk load, so only the first provider to call `load()` reads
/// from SharedPreferences.
class VikobaApp extends StatefulWidget {
  const VikobaApp({super.key, this.repository, this.apiClient, this.authGate = false});

  /// Test hooks / DI: pass a pre-configured repository (or mock storage).
  final AppRepository? repository;

  /// Test hooks / DI: inject a mock HTTP client for the API layer.
  final VikobaApiClient? apiClient;

  /// When true the app boots to the login screen (production). Off by
  /// default so widget tests drive the shell directly.
  final bool authGate;

  @override
  State<VikobaApp> createState() => _VikobaAppState();
}

class _VikobaAppState extends State<VikobaApp> {
  late final AppRepository _repository;
  late final VikobaApiClient _api;
  late final Session _session;
  late final AuthController _auth;
  late final NotificationsController _notifications;
  late final ThemeController _theme;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? AppRepository();
    _api = widget.apiClient ?? VikobaApiClient();
    _session = Session();
    _auth = AuthController(_api, _session, _repository);
    _notifications = NotificationsController();
    _theme = ThemeController()..restore();
    _theme.addListener(_onThemeChanged);
    _restore();
  }

  void _onThemeChanged() => setState(() {});

  @override
  void dispose() {
    _theme.removeListener(_onThemeChanged);
    super.dispose();
  }

  /// Restores the persisted session (demo/authenticated) then validates the
  /// token in the background if one exists.
  Future<void> _restore() async {
    await _session.restore();
    await _auth.restore();
    await _notifications.load();
    if (_session.isViewOnly && _session.isDemoMode) {
      await _notifications.seedForMember(_session.account.memberId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppRepository>.value(value: _repository),
        Provider<VikobaApiClient>.value(value: _api),
        ChangeNotifierProvider<Session>.value(value: _session),
        ChangeNotifierProvider<AuthController>.value(value: _auth),
        ChangeNotifierProvider<NotificationsController>.value(
            value: _notifications),
        ChangeNotifierProvider<MembersProvider>(
            create: (ctx) => MembersProvider(_repository, ctx.read<Session>())
              ..load()),
        ChangeNotifierProvider<ContributionsProvider>(
            create: (ctx) => ContributionsProvider(
                _repository,
                ctx.read<Session>(),
                ctx.read<NotificationsController>())
              ..load()),
        ChangeNotifierProvider<LoansProvider>(
            create: (ctx) => LoansProvider(
                _repository,
                ctx.read<Session>(),
                ctx.read<NotificationsController>())
              ..load()),
        ChangeNotifierProvider<MeetingsProvider>(
            create: (ctx) => MeetingsProvider(
                _repository,
                ctx.read<Session>(),
                ctx.read<NotificationsController>())
              ..load()),
        ChangeNotifierProvider<GroupSettingsProvider>(
            create: (_) => GroupSettingsProvider(_repository)..load()),
        ChangeNotifierProvider<SyncProvider>(
            create: (_) => SyncProvider(_repository, _api)),
        ChangeNotifierProvider<AppNavigation>(
            create: (_) => AppNavigation()),
        ChangeNotifierProvider<ThemeController>.value(value: _theme),
      ],
      child: MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: _theme.mode,
        home: AuthGate(enabled: widget.authGate),
      ),
    );
  }
}
