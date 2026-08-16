import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vikoba_app/core/data/app_repository.dart';
import 'package:vikoba_app/core/state/notifications.dart';
import 'package:vikoba_app/core/state/session.dart';
import 'package:vikoba_app/core/domain/vizoba_calc.dart';
import 'package:vikoba_app/models/loan.dart';
import 'package:vikoba_app/models/member.dart';
import 'package:vikoba_app/providers/contributions_provider.dart';
import 'package:vikoba_app/providers/group_settings_provider.dart';
import 'package:vikoba_app/providers/loans_provider.dart';
import 'package:vikoba_app/providers/members_provider.dart';

AppRepository makeRepo() {
  SharedPreferences.setMockInitialValues({});
  return AppRepository();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VikobaCalc (money correctness)', () {
    test('seeds mock data on first run', () async {
      final repo = makeRepo();
      await repo.ensureLoaded();
      expect(repo.members.length, 4);
      expect(repo.loans.length, 3);
      expect(repo.contributions.length, 2);
      expect(repo.meetings.length, 1);
      expect(repo.shareValue, 10000);
    });

    test('total group savings = shares * share value', () async {
      final repo = makeRepo();
      await repo.ensureLoaded();
      // 24+30+18+12 = 84 shares @ 10000
      expect(VikobaCalc.totalSavings(repo.members), 840000);
    });

    test('interest on a 100k loan at 10% payable is 110k', () {
      expect(
          VikobaCalc.totalPayable(principal: 100000, ratePercent: 10), 110000);
      expect(
          VikobaCalc.interestAmount(principal: 100000, ratePercent: 10), 10000);
    });

    test('earned interest only counts money actually repaid', () async {
      final repo = makeRepo();
      await repo.ensureLoaded();
      // Seed: L1 repaid 80k against 165k payable (0 interest yet), L2 paid
      // 110k of a 110k payable loan (interest 10k).
      expect(VikobaCalc.totalInterestEarned(repo.loans), 10000);
    });

    test('share-out per member = savings + proportional interest', () async {
      final repo = makeRepo();
      await repo.ensureLoaded();
      final results = VikobaCalc.calculateShareOut(
          repo.members, VikobaCalc.totalInterestEarned(repo.loans));

      final totalShares = repo.members.fold(0, (s, m) => s + m.totalShares);
      for (final r in results) {
        expect(r.shareProportion,
            closeTo(r.member.totalShares / totalShares, 0.000001));
        expect(r.totalPayout, closeTo(r.savings + r.interestShare, 0.001));
      }
      // Grand total == savings + interest earned.
      final payouts = results.fold(0.0, (s, r) => s + r.totalPayout);
      expect(payouts, closeTo(840000 + 10000, 0.001));
      // Sorted descending.
      for (var i = 0; i < results.length - 1; i++) {
        expect(results[i].totalPayout,
            greaterThanOrEqualTo(results[i + 1].totalPayout));
      }
      // The 30-share treasurer tops the list.
      expect(results.first.member.id, 'MEM2');
    });

    test('loan eligibility rules', () async {
      final repo = makeRepo();
      await repo.ensureLoaded();
      final member = repo.members.first; // MEM1, 24 shares = 240k savings

      // Allowed: within 4x savings and no open loan (seeded L3 is pending).
      expect(
          VikobaCalc.checkLoanEligibility(
                  member: member, requestedAmount: 50000, allLoans: repo.loans)
              .isOk,
          true);

      // Rejected: exceeds 4x savings (240k * 4 = 960k).
      expect(
          VikobaCalc.checkLoanEligibility(
                  member: member,
                  requestedAmount: 1000000,
                  allLoans: repo.loans)
              .isOk,
          false);

      // Rejected: below minimum (20k).
      expect(
          VikobaCalc.checkLoanEligibility(
                  member: member, requestedAmount: 5000, allLoans: repo.loans)
              .isOk,
          false);

      // Rejected: member already owes.
      final loanee = repo.members.firstWhere((m) => m.id == 'MEM3');
      expect(
          VikobaCalc.checkLoanEligibility(
                  member: loanee, requestedAmount: 50000, allLoans: repo.loans)
              .verdict,
          LoanEligibility.alreadyOwing);
    });
  });

  group('Providers (through repository)', () {
    test('addMember persists across restarts', () async {
      final repo = makeRepo();
      await repo.ensureLoaded();

      final members = MembersProvider(repo, Session());
      await members.load();
      await members.addMember(Member(
        id: 'MEM9',
        fullName: 'Zawadi Kileo',
        phoneNumber: '0711223344',
        role: MemberRole.member,
        joinedDate: DateTime.now(),
        totalShares: 0,
        shareValue: repo.shareValue,
      ));
      expect(members.members.length, 5);

      // A fresh repository (restart) reads the same prefs.
      final repo2 = AppRepository();
      await repo2.ensureLoaded();
      expect(repo2.members.length, 5);
    });

    test('recordContribution updates member share count + savings', () async {
      final repo = makeRepo();
      await repo.ensureLoaded();
      final contributions = ContributionsProvider(repo, Session(), NotificationsController());
      await contributions.load();

      final member = repo.members.first; // 24 shares
      final before = member.totalShares;
      await contributions.recordContribution(member: member, shares: 3);

      final updated = repo.members.firstWhere((m) => m.id == member.id);
      expect(updated.totalShares, before + 3);
      expect(contributions.totalSavings,
          (before + 3) * repo.shareValue + (30 + 18 + 12) * repo.shareValue);
      expect(contributions.contributions.first.amount, 3 * repo.shareValue);
    });

    test('loan goes pending -> approved -> active -> repaid', () async {
      final repo = makeRepo();
      await repo.ensureLoaded();
      final loans = LoansProvider(repo, Session(), NotificationsController());
      await loans.load();

      final member = repo.members.firstWhere((m) => m.id == 'MEM4');
      await loans.requestLoan(
          member: member, principal: 50000, repaymentDays: 30);
      final id = loans.loans.first.id;

      await loans.approveLoan(id);
      expect(loans.loans.first.status, LoanStatus.approved);

      await loans.disburseLoan(id);
      expect(loans.loans.first.status, LoanStatus.active);

      await loans.recordRepayment(id, 55000);
      expect(loans.loans.first.status, LoanStatus.repaid);
      expect(loans.loans.first.amountRepaid, 55000);
    });

    test('repayment clamps to total payable (no overpayment)', () async {
      final repo = makeRepo();
      await repo.ensureLoaded();
      final loans = LoansProvider(repo, Session(), NotificationsController());
      await loans.load();

      final loan = repo.loans.firstWhere((l) => l.status == LoanStatus.active);
      await loans.recordRepayment(loan.id, loan.totalPayable + 999999);
      final updated = repo.loans.firstWhere((l) => l.id == loan.id);
      expect(updated.amountRepaid, loan.totalPayable);
      expect(updated.status, LoanStatus.repaid);
    });

    test('settings mutate + persist', () async {
      final repo = makeRepo();
      await repo.ensureLoaded();
      final settings = GroupSettingsProvider(repo);
      await settings.load();

      await settings.setShareValue(20000);
      await settings.setInterestRate(15);
      expect(repo.shareValue, 20000);
      expect(repo.defaultInterestRate, 15);

      final repo2 = AppRepository();
      await repo2.ensureLoaded();
      expect(repo2.shareValue, 20000);
      expect(repo2.defaultInterestRate, 15);
    });

    test('offline-sync queue records mutations', () async {
      final repo = makeRepo();
      await repo.ensureLoaded();
      final members = MembersProvider(repo, Session());
      await members.load();
      await members.addMember(Member(
        id: 'MEM8',
        fullName: 'Rehema Moris',
        phoneNumber: '0711223344',
        role: MemberRole.treasurer,
        joinedDate: DateTime.now(),
        totalShares: 0,
        shareValue: repo.shareValue,
      ));

      expect(repo.pendingCount, 1);
      expect(repo.pendingOps.first.type, 'member.create');
    });
  });
}
