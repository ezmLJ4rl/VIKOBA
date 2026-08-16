import 'package:flutter/material.dart';
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

  testWidgets('app boots and shows dashboard hero + quick actions',
      (tester) async {
    await pumpApp(tester);
    expect(find.text('Vikoba Dashboard'), findsOneWidget);
    expect(find.text('Total Group Savings'), findsOneWidget);
    expect(find.textContaining('Active Members'), findsOneWidget);
    // Quick actions use the Swahili-primary / English-secondary pair.
    expect(find.text('Toa mchango'), findsOneWidget);
    expect(find.text('Add contribution'), findsOneWidget);
  });

  testWidgets('navigates between tabs', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Members'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Add Member'), findsOneWidget);

    await tester.tap(find.text('Loans'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('New Loan'), findsOneWidget);
  });

  testWidgets('recording a contribution updates the savings totals',
      (tester) async {
    final repo = await pumpApp(tester);

    // Go to Savings tab and open the record sheet via the FAB.
    await tester.tap(find.text('Savings'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Record'));
    await tester.pumpAndSettle();

    // Amount preview updates as shares change.
    await tester.enterText(find.byType(TextField).last, '2');
    await tester.pumpAndSettle();
    expect(find.textContaining('TZS 20,000'), findsOneWidget);

    await tester.tap(find.text('Save Contribution'));
    await tester.pumpAndSettle();

    // One queued op for the backend (offline queue).
    expect(repo.pendingCount, 1);
    expect(repo.pendingOps.first.type, 'contribution.create');
  });

  testWidgets('add-member form validates a bad phone number', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Members'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add Member'));
    await tester.pumpAndSettle();

    final sheet = find.byType(BottomSheet);
    final fields = find.descendant(
        of: sheet, matching: find.byType(TextField));
    await tester.enterText(fields.first, 'Neema Paulo');
    await tester.enterText(fields.at(1), '123');
    await tester.tap(find.text('Save Member'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid number — use +255… or 07…'), findsOneWidget);
  });
}