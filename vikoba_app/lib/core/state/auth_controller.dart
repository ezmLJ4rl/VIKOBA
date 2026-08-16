import 'package:flutter/foundation.dart';

import '../data/app_repository.dart';
import '../data/vikoba_api.dart';
import '../../models/member.dart';
import 'session.dart';

/// Backend auth: login / register / logout + session restore.
///
/// On success the Bearer token is stored in the [VikobaApiClient] (so the
/// sync queue can push) and the [Session] is switched to an authenticated
/// account resolved from the server user. `continueOffline` keeps the app
/// fully usable without a server, with the demo roster.
class AuthController extends ChangeNotifier {
  AuthController(this._api, this._session, this._repo);

  final VikobaApiClient _api;
  final Session _session;
  final AppRepository _repo;

  bool _busy = false;
  String? _error;

  bool get busy => _busy;
  String? get error => _error;
  bool get isConfigured => _api.isConfigured;

  /// Logs in against `POST /auth/login`. Returns a user-facing error message
  /// or null on success.
  Future<String?> login({
    required String email,
    required String password,
  }) =>
      _run(() async {
        final body = await _api.post(
          '/auth/login',
          {'email': email, 'password': password},
          auth: false,
        );
        final user = body['user'] as Map<String, dynamic>;
        await _applyServerUser(user,
            token: body['token'] as String?);
      });

  /// Registers a brand-new group + treasurer (single-group MVP) and logs in.
  Future<String?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String groupName,
  }) =>
      _run(() async {
        final body = await _api.post(
          '/auth/register',
          {
            'name': name,
            'email': email,
            'phone': phone,
            'password': password,
            'group_name': groupName,
          },
          auth: false,
        );
        final user = body['user'] as Map<String, dynamic>;
        await _applyServerUser(user, token: body['token'] as String?);
      });

  /// Restores a persisted authenticated session on app start. If the token is
  /// invalid the session is cleared; network failures keep the cached session
  /// (offline tolerance).
  Future<void> restore() async {
    if (!_api.isConfigured) return;
    try {
      final body = await _api.get('/auth/me');
      await _applyServerUser(body['user'] as Map<String, dynamic>);
    } on VikobaApiException catch (e) {
      if (e.code == 'unauthorized') {
        await _api.clearConfiguration();
        await _session.clear();
      }
      // network/server errors → keep the cached account; sync retries later.
    }
  }

  /// Enters the offline demo (no token, sample accounts).
  Future<void> continueOffline() async {
    _error = null;
    await _session.continueOffline();
  }

  /// Best-effort logout: revokes the token, clears local credentials and
  /// returns to the login screen.
  Future<void> logout() async {
    try {
      await _api.post('/auth/logout', {});
    } on VikobaApiException {
      // Token already invalid / offline — clearing locally still signs out.
    }
    await _api.clearConfiguration();
    await _session.clear();
  }

  Future<String?> _run(Future<void> Function() action) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await action();
    } on VikobaApiException catch (e) {
      _error = switch (e.code) {
        'validation' => 'Invalid email or password.',
        'network' => 'Could not reach the server.',
        'server_error' => 'Server error — try again shortly.',
        _ => 'Something went wrong ($e).',
      };
    } finally {
      _busy = false;
      notifyListeners();
    }
    return _error;
  }

  /// Builds the local [SessionAccount] from the server `user` payload.
  ///
  /// The roster is seeded identically on both stacks, so the member is first
  /// matched by phone (which is unique and stable). When there is no local
  /// member (e.g. a fresh registration), a view-model account is built from
  /// the user row instead.
  Future<void> _applyServerUser(Map<String, dynamic> user,
      {String? token}) async {
    if (token != null && token.isNotEmpty) {
      await _api.configure(baseUrl: _api.baseUrl, token: token);
    }
    await _repo.ensureLoaded();

    final phone = (user['phone'] as String?) ?? '';
    Member? member;
    for (final m in _repo.members) {
      if (m.phoneNumber == phone) {
        member = m;
        break;
      }
    }

    if (member != null) {
      await _session.authenticate(SessionAccount(
        memberId: member.id,
        name: member.fullName,
        phone: member.phoneNumber,
        role: member.role,
      ));
      return;
    }

    final role = MemberRole.values
        .where((r) => r.name == (user['role'] ?? 'member'))
        .firstOrNull;
    await _session.authenticate(SessionAccount(
      memberId: '${user['id']}',
      name: (user['name'] as String?) ?? 'Member',
      phone: phone,
      role: role ?? MemberRole.member,
    ));
  }
}