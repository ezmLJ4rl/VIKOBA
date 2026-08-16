import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vikoba_app/app.dart';
import 'package:vikoba_app/core/data/app_repository.dart';
import 'package:vikoba_app/core/data/vikoba_api.dart';
import 'package:vikoba_app/core/state/auth_controller.dart';
import 'package:vikoba_app/core/state/session.dart';
import 'package:vikoba_app/models/member.dart';

http.Response jsonRes(int status, Map<String, dynamic> body) =>
    http.Response(jsonEncode(body), status,
        headers: {'content-type': 'application/json'});

/// Fake backend: POST /auth/login (good@test / password) → token + user.
MockClient fakeApi({Map<String, dynamic>? loginUser}) => MockClient((request) async {
      final path = request.url.path;
      if (path == '/api/v1/auth/login') {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        if (body['email'] == 'good@test' && body['password'] == 'password') {
          return jsonRes(201, {
            'token': 'token-1',
            'user': loginUser ??
                {
                  'id': 2,
                  'name': 'Elisha Mgeni',
                  'email': 'good@test',
                  'phone': '0765432109',
                  'role': 'treasurer',
                },
          });
        }
        return jsonRes(422, {'message': 'Invalid credentials.'});
      }
      if (path == '/api/v1/auth/me') {
        return jsonRes(200, {
          'user': loginUser ??
              {
                'id': 2,
                'name': 'Elisha Mgeni',
                'email': 'good@test',
                'phone': '0765432109',
                'role': 'treasurer',
              },
        });
      }
      if (path == '/api/v1/auth/logout') {
        return jsonRes(200, {'message': 'Logged out.'});
      }
      return jsonRes(404, {'message': 'not found'});
    });

AppRepository makeRepo() {
  SharedPreferences.setMockInitialValues({});
  return AppRepository();
}

VikobaApiClient makeApi(http.Client client) =>
    VikobaApiClient(httpClient: client);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthController', () {
    test('login resolves the local member by phone and authenticates',
        () async {
      final repo = makeRepo();
      await repo.ensureLoaded();
      final session = Session();
      final auth = AuthController(makeApi(fakeApi()), session, repo);

      final error = await auth.login(
          email: 'good@test', password: 'password');

      expect(error, isNull);
      expect(session.isAuthenticated, isTrue);
      expect(session.account.memberId, 'MEM2'); // Elisha Mgeni in seed
      expect(session.account.role, MemberRole.treasurer);
      expect(session.canManageLoans, isTrue);
    });

    test('invalid credentials set a user-facing error', () async {
      final repo = makeRepo();
      await repo.ensureLoaded();
      final session = Session();
      final auth = AuthController(makeApi(fakeApi()), session, repo);

      final error = await auth.login(
          email: 'good@test', password: 'wrong');

      expect(error, isNotNull);
      expect(session.isAuthenticated, isFalse);
      expect(auth.error, 'Invalid email or password.');
    });

    test('network failure keeps the session signed out', () async {
      final repo = makeRepo();
      await repo.ensureLoaded();
      final session = Session();
      final auth = AuthController(
          makeApi(MockClient((request) async => throw Exception('down'))),
          session,
          repo);

      final error = await auth.login(email: 'a@b.c', password: 'x');

      expect(error, 'Could not reach the server.');
      expect(session.isSignedIn, isFalse);
    });

    test('continueOffline enters demo mode with the treasurer account',
        () async {
      final repo = makeRepo();
      await repo.ensureLoaded();
      final session = Session();
      final auth = AuthController(makeApi(fakeApi()), session, repo);

      await auth.continueOffline();

      expect(session.isDemoMode, isTrue);
      expect(session.canSwitchAccounts, isTrue);
      expect(session.account.role, MemberRole.treasurer);
    });

    test('logout clears token and returns to signed out', () async {
      SharedPreferences.setMockInitialValues({});
      final api = makeApi(fakeApi());
      final repo = AppRepository();
      final session = Session();
      final auth = AuthController(api, session, repo);

      await auth.login(email: 'good@test', password: 'password');
      expect(session.isAuthenticated, isTrue);
      expect(api.isConfigured, isTrue);

      await auth.logout();

      expect(session.isSignedIn, isFalse);
      expect(api.isConfigured, isFalse);
    });

    test('restore validates a stored token via /auth/me', () async {
      SharedPreferences.setMockInitialValues({});
      final api = makeApi(fakeApi());
      await api.configure(baseUrl: 'http://x/api/v1', token: 'token-1');
      final repo = AppRepository();
      await repo.ensureLoaded();
      final session = Session();
      await session.authenticate(const SessionAccount(
          memberId: 'MEM2',
          name: 'Elisha Mgeni',
          phone: '0765432109',
          role: MemberRole.treasurer));
      final auth = AuthController(api, session, repo);

      await auth.restore();

      expect(session.isAuthenticated, isTrue);
      expect(session.account.role, MemberRole.treasurer);
    });

    test('restore clears the session when the token is unauthorized',
        () async {
      SharedPreferences.setMockInitialValues({});
      final api = makeApi(
          MockClient((request) async => jsonRes(401, {'message': 'no'})));
      await api.configure(baseUrl: 'http://x/api/v1', token: 'stale');
      final repo = AppRepository();
      final session = Session();
      await session.authenticate(const SessionAccount(
          memberId: 'MEM2',
          name: 'Elisha Mgeni',
          phone: '0765432109',
          role: MemberRole.treasurer));
      final auth = AuthController(api, session, repo);

      await auth.restore();

      expect(session.isSignedIn, isFalse);
      expect(api.isConfigured, isFalse);
    });
  });

  group('Login flow (widget)', () {
    testWidgets('boots to login when auth gate is enabled', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repo = AppRepository();
      await tester.pumpWidget(VikobaApp(
        repository: repo,
        apiClient: makeApi(fakeApi()),
        authGate: true,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Continue offline'), findsOneWidget);
      expect(find.text('Vikoba Dashboard'), findsNothing);
    });

    testWidgets('successful login opens the dashboard', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(VikobaApp(
        repository: AppRepository(),
        apiClient: makeApi(fakeApi()),
        authGate: true,
      ));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextField, 'Email'), 'good@test');
      await tester.enterText(
          find.widgetWithText(TextField, 'Password'), 'password');
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Vikoba Dashboard'), findsOneWidget);
    });

    testWidgets('invalid credentials show the error message', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(VikobaApp(
        repository: AppRepository(),
        apiClient: makeApi(fakeApi()),
        authGate: true,
      ));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextField, 'Email'), 'good@test');
      await tester.enterText(
          find.widgetWithText(TextField, 'Password'), 'wrong');
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid email or password.'), findsOneWidget);
      expect(find.text('Vikoba Dashboard'), findsNothing);
    });

    testWidgets('continue offline enters the demo app', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(VikobaApp(
        repository: AppRepository(),
        apiClient: makeApi(fakeApi()),
        authGate: true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue offline'));
      await tester.pumpAndSettle();

      expect(find.text('Vikoba Dashboard'), findsOneWidget);
    });
  });
}
