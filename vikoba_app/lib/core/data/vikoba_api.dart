import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// HTTP transport for the Laravel backend.
///
/// The app is offline-first: everything is written locally and the sync queue
/// (see `SyncProvider`) is pushed to `POST /api/v1/sync` when a token is
/// configured and connectivity exists. The token comes from the login screen
/// (`POST /api/v1/auth/login`) and is kept in SharedPreferences.
class VikobaApiClient {
  VikobaApiClient({http.Client? httpClient, SharedPreferences? prefs})
      : _http = httpClient ?? http.Client(),
        _prefs = prefs;

  /// Development server (matches `php artisan serve --port=8123`).
  static const String defaultBaseUrl = 'http://127.0.0.1:8123/api/v1';

  static const String _kApiUrl = 'vikoba_api_base_url';
  static const String _kToken = 'vikoba_api_token';

  final http.Client _http;
  SharedPreferences? _prefs;

  /// Runtime overrides; fall back to persisted values.
  String? _baseUrl;
  String? _token;

  String get baseUrl =>
      _baseUrl ?? _prefs?.getString(_kApiUrl) ?? defaultBaseUrl;

  String? get token => _token ?? _prefs?.getString(_kToken);

  bool get isConfigured => (token ?? '').isNotEmpty;

  /// Stores the server address + token and persists them.
  Future<void> configure({
    required String baseUrl,
    required String token,
  }) async {
    _baseUrl = baseUrl;
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kApiUrl, baseUrl);
    await prefs.setString(_kToken, token);
    _prefs = prefs;
  }

  /// Forgets the stored credentials.
  Future<void> clearConfiguration() async {
    _token = null;
    _baseUrl = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kApiUrl);
    await prefs.remove(_kToken);
    _prefs = prefs;
  }

  /// GET with the stored Bearer token. Used by `AuthController.restore()`.
  Future<Map<String, dynamic>> get(String path) =>
      _send(() => _http.get(Uri.parse('$baseUrl$path'), headers: _headers()));

  /// POST with the stored Bearer token (`auth: false` for /auth/login).
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body,
          {bool auth = true}) =>
      _send(() => _http.post(
            Uri.parse('$baseUrl$path'),
            headers: _headers(auth: auth),
            body: jsonEncode(body),
          ));

  /// Pushes a batch of queued operations to `POST /sync`.
  Future<Map<String, dynamic>> sync(List<Map<String, dynamic>> ops) =>
      post('/sync', {'operations': ops});

  Map<String, String> _headers({bool auth = true}) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (auth && token != null) 'Authorization': 'Bearer $token',
      };

  Future<Map<String, dynamic>> _send(Future<http.Response> Function() run) async {
    final http.Response res;
    try {
      res = await run();
    } on Exception {
      throw VikobaApiException('network', 'Could not reach the server.');
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return const {};
      try {
        return (jsonDecode(res.body) as Map).cast<String, dynamic>();
      } on FormatException {
        throw VikobaApiException('bad_response', 'Response was not JSON.');
      }
    }

    throw VikobaApiException(
      _codeFor(res.statusCode),
      'Request to ${res.request?.url} failed (${res.statusCode}).',
      statusCode: res.statusCode,
      body: res.body,
    );
  }

  String _codeFor(int status) {
    if (status == 422) return 'validation';
    if (status == 401 || status == 403) return 'unauthorized';
    if (status >= 500) return 'server_error';
    return 'http_error';
  }
}

/// Machine-readable transport failures.
/// `code` is one of: network | unauthorized | validation | server_error |
/// http_error | bad_response.
class VikobaApiException implements Exception {
  VikobaApiException(this.code, this.details, {this.statusCode, this.body});

  final String code;
  final String details;
  final int? statusCode;

  /// Raw response body (may contain server-side validation messages).
  final String? body;

  @override
  String toString() => 'VikobaApiException($code): $details';
}