import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/contribution.dart';
import '../../models/loan.dart';
import '../../models/loan_product.dart';
import '../../models/meeting.dart';
import '../../models/member.dart';
import 'pending_operation.dart';
import 'persisted_snapshot.dart';
import 'seed_data.dart';

/// Gateway to everything the app stores.
///
/// Providers never touch SharedPreferences directly — they talk to a
/// repository so the data source can be swapped later (e.g. a backend
/// `AppRepository` that mirrors data, or Hive/Drift tables once the group
/// outgrows a single JSON document). Keeping all data funneled through one
/// class means the UI and providers don't change when the source does.
///
/// The repository holds the in-memory source of truth (loaded once from disk)
/// and persists it on every write. That is deliberately simple: a single
/// group's record-keeping document is a few KBs. The offline-sync queue is
/// persisted separately so queued actions survive restarts.
class AppRepository {
  static const _storageKey = 'vikoba_app_data_v1';
  static const _pendingKey = 'vikoba_app_pending_ops_v1';

  PersistedSnapshot _snapshot = const PersistedSnapshot();
  final List<PendingOperation> _pendingOps = [];
  Future<void>? _loading;
  bool _loaded = false;

  AppRepository({this.seedOnFirstLoad = true});

  /// Whether new installs start with demo data (true in dev, false in prod).
  final bool seedOnFirstLoad;

  PersistedSnapshot get snapshot => _snapshot;

  List<Member> get members => _snapshot.members;
  List<Contribution> get contributions => _snapshot.contributions;
  List<Loan> get loans => _snapshot.loans;
  List<LoanProduct> get loanProducts => _snapshot.loanProducts;
  List<Meeting> get meetings => _snapshot.meetings;
  double get shareValue => _snapshot.shareValue;
  double get defaultInterestRate => _snapshot.defaultInterestRate;
  int get minMembershipDays => _snapshot.minMembershipDays;
  String get groupName => _snapshot.groupName;

  List<PendingOperation> get pendingOps => List.unmodifiable(_pendingOps);
  int get pendingCount => _pendingOps.length;
  bool get isLoaded => _loaded;

  /// Loads from disk exactly once (so every provider can call it safely).
  Future<void> ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        _snapshot =
            PersistedSnapshot.fromJson(_decode(raw) as Map<String, dynamic>);
      } else if (seedOnFirstLoad) {
        _snapshot = SeedData.build();
      }
      final pendingRaw = prefs.getString(_pendingKey);
      if (pendingRaw != null) {
        final decoded = _decode(pendingRaw) as List;
        _pendingOps
          ..clear()
          ..addAll(decoded.map(
              (e) => PendingOperation.fromJson(e as Map<String, dynamic>)));
      }
    } catch (e) {
      debugPrint('AppRepository: failed to load saved data -> $e');
    }
    _loaded = true;
  }

  // ---------------------------------------------------------------------------
  // Writes
  // ---------------------------------------------------------------------------

  Future<void> updateSettings({
    double? shareValue,
    double? interestRate,
    String? groupName,
  }) async {
    await ensureLoaded();
    _snapshot = _snapshot.copyWith(
      shareValue: shareValue ?? _snapshot.shareValue,
      defaultInterestRate: interestRate ?? _snapshot.defaultInterestRate,
      groupName: groupName ?? _snapshot.groupName,
    );
    await _persist();
  }

  Future<void> setMembers(List<Member> members) async {
    _snapshot = _snapshot.copyWith(members: members);
    await _persist();
  }

  Future<void> setContributions(List<Contribution> contributions) async {
    _snapshot = _snapshot.copyWith(contributions: contributions);
    await _persist();
  }

  Future<void> setLoans(List<Loan> loans) async {
    _snapshot = _snapshot.copyWith(loans: loans);
    await _persist();
  }

  Future<void> setLoanProducts(List<LoanProduct> loanProducts) async {
    _snapshot = _snapshot.copyWith(loanProducts: loanProducts);
    await _persist();
  }

  Future<void> setMeetings(List<Meeting> meetings) async {
    _snapshot = _snapshot.copyWith(meetings: meetings);
    await _persist();
  }

  /// Replaces the whole snapshot — used when a full refresh syncs from the
  /// backend down to local storage.
  Future<void> replaceAll(PersistedSnapshot incoming) async {
    _snapshot = incoming;
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, _encode(_snapshot.toJson()));
      await prefs.setString(
        _pendingKey,
        _encode(_pendingOps.map((o) => o.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('AppRepository: failed to persist -> $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Offline sync queue
  // ---------------------------------------------------------------------------

  Future<void> enqueue(PendingOperation operation) async {
    _pendingOps.add(operation);
    await _persist();
  }

  /// Removes a successfully-synced operation from the queue.
  Future<void> removePending(String id) async {
    _pendingOps.removeWhere((o) => o.id == id);
    await _persist();
  }

  /// Records a failed delivery attempt and returns the new attempt count
  /// (used by the sync service for exponential backoff).
  Future<int> bumpPendingAttempt(String id) async {
    final idx = _pendingOps.indexWhere((o) => o.id == id);
    if (idx == -1) return 0;
    final next = _pendingOps[idx].attempts + 1;
    _pendingOps[idx] = _pendingOps[idx].copyWith(attempts: next);
    await _persist();
    return next;
  }

  List<PendingOperation> pendingOfType(String type) =>
      _pendingOps.where((o) => o.type == type).toList();

  static String _encode(Object data) => jsonEncode(data);
  static dynamic _decode(String raw) => jsonDecode(raw);
}
