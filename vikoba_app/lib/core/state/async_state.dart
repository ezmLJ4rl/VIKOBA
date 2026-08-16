import 'package:flutter/foundation.dart';

/// How far an async operation has got, so the UI can show loading / error /
/// retry instead of silently showing stale data.
enum LoadStatus { idle, loading, loaded, failed }

/// Thin wrapper around [LoadStatus] + an optional error message, exposed by
/// providers. Screens switch on [status] and render accordingly.
@immutable
class AsyncState {
  final LoadStatus status;
  final String? error;

  const AsyncState._(this.status, this.error);

  const AsyncState.idle() : this._(LoadStatus.idle, null);
  const AsyncState.loading() : this._(LoadStatus.loading, null);
  const AsyncState.loaded() : this._(LoadStatus.loaded, null);
  const AsyncState.failed(String error) : this._(LoadStatus.failed, error);

  bool get isLoading => status == LoadStatus.loading;
  bool get isLoaded => status == LoadStatus.loaded;
  bool get hasError => status == LoadStatus.failed;
}
