import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vikoba_app/core/data/app_repository.dart';
import 'package:vikoba_app/core/data/pending_operation.dart';
import 'package:vikoba_app/core/data/vikoba_api.dart';
import 'package:vikoba_app/providers/sync_provider.dart';

/// LIVE end-to-end check against the real backend (requires
/// `php artisan serve --port=8123` + seeded DB). Skipped by default; run with
/// `flutter test test/live_sync_test.dart --dart-define=LIVE_SYNC=true`.
void main() {
  const live = bool.fromEnvironment('LIVE_SYNC');

  test('live: queued loan request reaches the backend', () async {
    if (!live) return; // needs --dart-define=LIVE_SYNC=true
    const server = 'http://127.0.0.1:8123/api/v1';

    final login = await http.post(
      Uri.parse('$server/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': 'treasurer@vikoba.test',
        'password': 'password',
      }),
    );
    expect(login.statusCode, 201,
        reason: 'Backend must be running (php artisan serve --port=8123)');
    final token = (jsonDecode(login.body) as Map)['token'] as String;

    Future<http.Response> getLoans() => http.get(
          Uri.parse('$server/loans?per_page=100'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );

    final before = jsonDecode((await getLoans()).body) as Map;
    final countBefore = ((before['loans'] as Map)['data'] as List).length;

    SharedPreferences.setMockInitialValues({});
    final api = VikobaApiClient(httpClient: http.Client());
    await api.configure(baseUrl: server, token: token);

    final repo = AppRepository();
    final sync = SyncProvider(repo, api);
    await repo.ensureLoaded();

    await repo.enqueue(PendingOperation.create('loan.request', {
      'memberId': 'MEM1',
      'phoneNumber': '0712345678',
      'principal': 50000,
      'repaymentDays': 30,
    }));
    await sync.flushNow();

    expect(sync.pendingCount, 0,
        reason: 'op must be delivered + dropped; error=${sync.lastSyncError}');
    expect(sync.lastSyncError, isNull);

    final afterLoans = ((jsonDecode((await getLoans()).body) as Map)['loans']
        as Map)['data'] as List;
    expect(afterLoans.length, countBefore + 1);
    final synced = afterLoans.cast<Map>().firstWhere(
          (l) => l['principal'] == 50000 && l['status'] == 'pending',
        );
    expect(synced['member_id'], isNotNull);
  });
}