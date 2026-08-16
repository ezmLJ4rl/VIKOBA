import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vikoba_app/core/data/app_repository.dart';
import 'package:vikoba_app/core/data/pending_operation.dart';
import 'package:vikoba_app/core/data/vikoba_api.dart';
import 'package:vikoba_app/providers/sync_provider.dart';

AppRepository makeRepo() {
  SharedPreferences.setMockInitialValues({});
  return AppRepository();
}

PendingOperation makePending(String type) => PendingOperation(
      id: 'op-1',
      type: type,
      payload: {'memberId': 'MEM1', 'principal': 60000, 'repaymentDays': 60},
      idempotencyKey: 'k1',
      createdAt: DateTime(2026, 1, 1),
    );

MockClient okClient() => MockClient((request) async {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final ops = body['operations'] as List;
      final results = ops
          .map((op) => {
                'idempotency_key': op['idempotency_key'],
                'type': op['type'],
                'result': {'status': 'ok'},
              })
          .toList();
      return http.Response(jsonEncode({'results': results}), 200,
          headers: {'content-type': 'application/json'});
    });

/// Fresh repo + provider pair backed by a fake HTTP transport.
Future<({AppRepository repo, SyncProvider sync})> makeSync(
    http.Client client) async {
  final repo = makeRepo();
  SharedPreferences.setMockInitialValues({});
  final api = VikobaApiClient(httpClient: client);
  await api.configure(baseUrl: 'http://test.local/api/v1', token: 'test-token');
  return (repo: repo, sync: SyncProvider(repo, api));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SyncProvider upload (HTTP transport)', () {
    test('pushes ops as an idempotency-keyed batch', () async {
      final requests = <http.Request>[];
      final pair = await makeSync(MockClient((request) async {
        requests.add(request);
        return http.Response(
            jsonEncode({
              'results': [
                {
                  'idempotency_key': 'k1',
                  'type': 'loan.request',
                  'result': {'status': 'ok'},
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'});
      }));
      await pair.repo.enqueue(makePending('loan.request'));
      await pair.sync.flushNow();

      expect(requests, hasLength(1));
      expect(requests.single.url.toString(), 'http://test.local/api/v1/sync');
      expect(requests.single.headers['Authorization'], 'Bearer test-token');
      final sent = jsonDecode(requests.single.body) as Map<String, dynamic>;
      final op = (sent['operations'] as List).single as Map<String, dynamic>;
      expect(op['idempotency_key'], 'k1');
      expect(op['type'], 'loan.request');
      expect(op['payload']['principal'], 60000);
      expect(pair.sync.pendingCount, 0);
      expect(pair.sync.successfulSyncs, 1);
    });

    test('duplicated reply is acknowledged (safe retry)', () async {
      final pair = await makeSync(MockClient((request) async {
        return http.Response(
            jsonEncode({
              'results': [
                {
                  'idempotency_key': 'k1',
                  'result': {'status': 'duplicated'},
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'});
      }));
      await pair.repo.enqueue(makePending('contribution.create'));
      await pair.sync.flushNow();
      expect(pair.sync.pendingCount, 0);
    });

    test('failed reply keeps the op queued with an error', () async {
      final pair = await makeSync(MockClient((request) async {
        return http.Response(
            jsonEncode({
              'results': [
                {
                  'idempotency_key': 'k1',
                  'result': {'status': 'failed', 'error': 'boom'},
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'});
      }));
      await pair.repo.enqueue(makePending('loan.request'));
      await pair.sync.flushNow();
      expect(pair.sync.pendingCount, 1);
      expect(pair.sync.lastSyncError, isNotNull);
    });

    test('network failure keeps the op queued', () async {
      final pair = await makeSync(
          MockClient((request) async => throw Exception('connection refused')));
      await pair.repo.enqueue(makePending('loan.request'));
      await pair.sync.flushNow();
      expect(pair.sync.pendingCount, 1);
      expect(pair.sync.lastSyncError, isNotNull);
    });

    test('unauthorized reply is not fatal, op stays queued', () async {
      final pair = await makeSync(
          MockClient((request) async => http.Response('denied', 401)));
      await pair.repo.enqueue(makePending('loan.request'));
      await pair.sync.flushNow();
      expect(pair.sync.pendingCount, 1);
    });

    test('without a token nothing is sent', () async {
      final repo = makeRepo();
      final sync = SyncProvider(repo, VikobaApiClient(httpClient: okClient()));
      await repo.enqueue(makePending('loan.request'));
      await sync.flushNow();
      expect(sync.pendingCount, 1);
      expect(sync.lastSyncError, contains('token'));
    });

    test('settings ops (unsupported server-side) are dropped as delivered',
        () async {
      final pair = await makeSync(MockClient((request) async {
        return http.Response(
            jsonEncode({
              'results': [
                {
                  'idempotency_key': 'k1',
                  'result': {'status': 'unsupported'},
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'});
      }));
      await pair.repo.enqueue(makePending('settings.share_value'));
      await pair.sync.flushNow();
      expect(pair.sync.pendingCount, 0);
    });
  });
}
