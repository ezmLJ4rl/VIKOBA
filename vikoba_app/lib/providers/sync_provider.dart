import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/data/app_repository.dart';
import '../core/data/pending_operation.dart';
import '../core/data/vikoba_api.dart';

/// Drives the offline-sync queue.
///
/// Local writes are always saved immediately; this provider flushes the
/// queued operations to the backend when connectivity returns. Each op keeps
/// its original idempotency key across retries, so the server replays safely.
class SyncProvider extends ChangeNotifier {
  SyncProvider(this._repo, this._api);

  final AppRepository _repo;
  final VikobaApiClient _api;
  bool _connected = false;
  bool _syncing = false;
  int _successfulSyncs = 0;
  String? _lastDeliveryError;

  bool get isConnected => _connected;
  bool get isSyncing => _syncing;
  int get pendingCount => _repo.pendingCount;
  int get successfulSyncs => _successfulSyncs;
  String? get lastSyncError => _lastDeliveryError;
  bool get isConfigured => _api.isConfigured;

  List<PendingOperation> get queue => _repo.pendingOps;

  void setConnectivity(bool online) {
    if (_connected == online) return;
    _connected = online;
    notifyListeners();
    if (online) unawaited(flush());
  }

  /// Pushes everything queued (oldest first). Retries with exponential backoff
  /// driven by [PendingOperation.attempts]: each failure doubles the wait, so
  /// flapping networks don't hammer the API.
  Future<void> flush() async {
    if (_syncing || !_connected || _repo.pendingOps.isEmpty) return;
    if (!_api.isConfigured) {
      _lastDeliveryError = 'No server token configured.';
      return;
    }
    _syncing = true;
    _lastDeliveryError = null;
    notifyListeners();

    for (final op in List.of(_repo.pendingOps)) {
      if (!_api.isConfigured) break; // credentials dropped mid-flush
      final ok = await _submit(op);
      if (ok) {
        await _repo.removePending(op.id);
        _successfulSyncs++;
      } else {
        final attempt = await _repo.bumpPendingAttempt(op.id);
        final backoffMs = (1 << (attempt.clamp(0, 6))) * 1000;
        _lastDeliveryError = 'Delivery failed (attempt $attempt), retry in '
            '${backoffMs ~/ 1000}s';
        await Future<void>.delayed(Duration(milliseconds: backoffMs));
      }
    }

    _syncing = false;
    notifyListeners();
  }

  /// Pushes one operation to `POST /api/v1/sync` and reports whether the
  /// server acknowledged it. `duplicated` counts as success — the server
  /// already has the effect from an earlier retry. `unsupported` ops (e.g.
  /// group settings) are dropped locally, since the server has no rule for
  /// them. Everything else stays queued for another attempt.
  Future<bool> _submit(PendingOperation op) async {
    try {
      final body = await _api.sync([
        {
          'idempotency_key': op.idempotencyKey,
          'type': op.type,
          'payload': op.payload,
        },
      ]);
      final status = (body['results'] as List?)?.firstOrNull?['result']?['status'];
      return switch (status) {
        'ok' || 'duplicated' || 'unsupported' => true,
        _ => false,
      };
    } on VikobaApiException {
      return false;
    }
  }

  /// Manual push regardless of the connectivity flag (used by the sync
  /// button in the UI); still guarded against concurrent runs.
  Future<void> flushNow() async {
    _connected = true;
    await flush();
  }
}