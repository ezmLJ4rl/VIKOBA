import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/member.dart';

/// The signed-in account. Member accounts are view-only; the three leadership
/// roles (chairperson / treasurer / secretary) are full-access admins.
///
/// Login flows will come with the Laravel API integration; until then the app
/// runs a local "preview session" persisted in SharedPreferences.
@immutable
class SessionAccount {
  const SessionAccount({
    required this.memberId,
    required this.name,
    required this.phone,
    required this.role,
  });

  final String memberId;
  final String name;
  final String phone;
  final MemberRole role;

  bool get isAdmin => role != MemberRole.member;

  /// Swahili-first / English pairing for the leadership label.
  String get roleLabelSw => switch (role) {
        MemberRole.chairperson => 'Mwenyekiti',
        MemberRole.treasurer => 'Mweka Hazina',
        MemberRole.secretary => 'Katibu',
        MemberRole.member => 'Mwanachama',
      };

  String get roleLabelEn => switch (role) {
        MemberRole.chairperson => 'Chairperson',
        MemberRole.treasurer => 'Treasurer',
        MemberRole.secretary => 'Secretary',
        MemberRole.member => 'Member',
      };

  Map<String, dynamic> toJson() => {
        'memberId': memberId,
        'name': name,
        'phone': phone,
        'role': role.name,
      };

  factory SessionAccount.fromJson(Map<String, dynamic> json) => SessionAccount(
        memberId: json['memberId'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        role: MemberRole.values.byName(json['role'] as String),
      );
}

/// Current signed-in account + permission surface.
///
/// This is the *client-side* convenience boundary: mutating providers refuse
/// to run for accounts without permission even if a button were somehow
/// reachable. The authoritative boundary lives in the Laravel API policies.
///
/// Three modes: `authenticated` (real backend login), `demo` (offline
/// preview with the roster's sample accounts) and signed out (login screen).
class Session extends ChangeNotifier {
  Session({SessionAccount? initial}) : _account = initial ?? _demoTreasurer;

  static const _prefsKey = 'vikoba.session.account';
  static const _modeKey = 'vikoba.session.mode';

  /// Default preview account until real auth lands: the group treasurer.
  static const SessionAccount _demoTreasurer = SessionAccount(
    memberId: 'MEM2',
    name: 'Elisha Mgeni',
    phone: '0765432109',
    role: MemberRole.treasurer,
  );

  SessionAccount _account;
  bool _authenticated = false;
  bool _demoMode = false;

  SessionAccount get account => _account;

  /// Real backend login (token stored).
  bool get isAuthenticated => _authenticated;

  /// Offline preview session — the role switcher is available.
  bool get isDemoMode => _demoMode;

  bool get canSwitchAccounts => _demoMode;
  bool get isSignedIn => _authenticated || _demoMode;
  bool get isAdmin => _account.isAdmin;
  bool get isViewOnly => !_account.isAdmin;

  // Permission surface — one source of truth for both providers and UI.
  bool get canManageMembers => isAdmin;
  bool get canRecordContributions => isAdmin;
  bool get canManageLoans => isAdmin; // approve / reject / disburse / repay
  bool get canLogMeetings => isAdmin;
  bool get canRequestLoans => true; // members may request for themselves only

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_modeKey);
    final raw = prefs.getString(_prefsKey);
    if (mode == 'auth') {
      _authenticated = true;
      _demoMode = false;
    } else if (mode == 'demo') {
      _demoMode = true;
      _authenticated = false;
    }
    if (raw != null) {
      try {
        _account =
            SessionAccount.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        // Corrupt stored account — fall back to the demo treasurer.
      }
    }
    notifyListeners();
  }

  /// Successful backend login: account is fixed to the authenticated user.
  Future<void> authenticate(SessionAccount account) async {
    _account = account;
    _authenticated = true;
    _demoMode = false;
    await _persist();
  }

  /// Skip the server: open the app with the demo roster (preview roles).
  Future<void> continueOffline() async {
    _account = _demoTreasurer;
    _demoMode = true;
    _authenticated = false;
    await _persist();
  }

  /// Switch account within the offline demo (used by the account switcher).
  Future<void> signInAs(SessionAccount account) async {
    _account = account;
    await _persist();
  }

  /// Full sign-out back to the login screen.
  Future<void> clear() async {
    _account = _demoTreasurer;
    _authenticated = false;
    _demoMode = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    await prefs.remove(_modeKey);
  }

  Future<void> _persist() async {
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_account.toJson()));
    await prefs.setString(
        _modeKey, _authenticated ? 'auth' : _demoMode ? 'demo' : '');
  }
}
