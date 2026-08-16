import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vikoba_app/app.dart';
import 'package:vikoba_app/core/data/app_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<AppRepository> pumpApp(WidgetTester tester) async {
    final repo = AppRepository();
    await tester.pumpWidget(VikobaApp(repository: repo));
    await tester.pumpAndSettle();
    return repo;
  }

  group('members', () {
    testWidgets('search narrows the roster by name', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Members'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Amina');
      await tester.pumpAndSettle();

      expect(find.text('Amina Juma'), findsOneWidget);
      expect(find.text('Elisha Mgeni'), findsNothing);
      expect(find.text('Fatuma Rashidi'), findsNothing);
    });

    testWidgets('opening a member shows their profile, loans and savings',
        (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Members'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Amina Juma'));
      await tester.pumpAndSettle();

      expect(find.text('Member profile'), findsOneWidget);
      expect(find.text('0712345678'), findsOneWidget);
      expect(find.text('Loans'), findsOneWidget);
      expect(find.text('Contributions'), findsOneWidget);
      // Amina (MEM1) has a pending 200,000 loan in seed data.
      expect(find.textContaining('200,000'), findsWidgets);
    });

    testWidgets('deactivating a member asks for confirmation and updates status',
        (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Members'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Amina Juma'));
      await tester.pumpAndSettle();

      expect(find.text('Active'), findsOneWidget);

      await tester.tap(find.byTooltip('Deactivate member'));
      await tester.pumpAndSettle();
      expect(find.text('Deactivate member?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Active'), findsOneWidget);

      await tester.tap(find.byTooltip('Deactivate member'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deactivate member').last);
      await tester.pumpAndSettle();

      expect(find.text('Inactive'), findsOneWidget);
      expect(find.text('Member deactivated'), findsOneWidget);
    });
  });

  group('meetings', () {
    testWidgets('meetings screen lists the seeded meeting', (tester) async {
      final repo = await pumpApp(tester);
      await tester.tap(find.text('Log meeting'));
      await tester.pumpAndSettle();

      expect(find.text('Meetings'), findsOneWidget);
      expect(find.text('Weekly contribution & loan review'), findsOneWidget);
      expect(find.text('1 absent'), findsOneWidget);
      expect(repo.meetings.length, 1);
    });
  });

  group('reports', () {
    testWidgets('copying the members report puts CSV on the clipboard',
        (tester) async {
      String? clipboardText;
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboardText = (call.arguments as Map)['text'] as String?;
        } else if (call.method == 'Clipboard.getData') {
          return {'text': clipboardText};
        }
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null));

      await pumpApp(tester);

      await tester.tap(find.text('Reports'));
      await tester.pumpAndSettle();
      expect(find.text('Reports'), findsOneWidget);

      await tester.tap(find.text('Copy CSV').first);
      await tester.pumpAndSettle();

      expect(clipboardText, isNotNull);
      expect(clipboardText, contains('fullName'));
      expect(clipboardText, contains('Amina Juma'));
    });

    testWidgets('tapping a report opens the CSV preview viewer',
        (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Reports'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Members'));
      await tester.pumpAndSettle();

      expect(find.textContaining('CSV preview'), findsOneWidget);
      expect(find.textContaining('id,fullName', findRichText: true),
          findsOneWidget);
      expect(
          find.textContaining('Amina Juma', findRichText: true),
          findsOneWidget);
    });
  });

  group('dark mode', () {
    testWidgets('toggling dark mode switches the theme brightness',
        (tester) async {
      await pumpApp(tester);

      expect(Theme.of(tester.element(find.text('Vikoba Dashboard'))).brightness,
          Brightness.light);

      await tester.tap(find.byTooltip('Treasurer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark mode'));
      await tester.pumpAndSettle();

      expect(
          Theme.of(tester.element(find.text('Vikoba Dashboard'))).brightness,
          Brightness.dark);
    });
  });
}
