import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vikoba_app/core/data/app_repository.dart';
import 'package:vikoba_app/core/state/notifications.dart';
import 'package:vikoba_app/core/state/session.dart';
import 'package:vikoba_app/models/loan.dart';
import 'package:vikoba_app/models/member.dart';
import 'package:vikoba_app/providers/contributions_provider.dart';
import 'package:vikoba_app/providers/loans_provider.dart';
import 'package:vikoba_app/providers/members_provider.dart';

/// Permission model tests: enforcement lives in the data layer, not the UI.
///
/// Member accounts (view-only):
///   - cannot add/deactivate members, record contributions, decide loans,
///     record repayments or log meetings — even if invoked directly;
///   - CAN request a loan, but only for themselves;
///   - receive notifications about their own records.
/// All three leadership roles share identical full access.
AppRepository makeRepo() {
  SharedPreferences.setMockInitialValues({});
  return AppRepository();
}

const _memberSession = SessionAccount(
  memberId: 'MEM4', // Yusuf Hamisi — plain member in the seed roster
  name: 'Yusuf Hamisi',
  phone: '0754332211',
  role: MemberRole.member,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Admin accounts (all three roles = full access)', () {
    test('default session is an admin and may add members', () async {
      final repo = makeRepo();
      await repo.ensureLoaded();
      final members = MembersProvider(repo, Session());
      await members.load();

      final ok = await members.addMember(Member(
        id: 'MEM9',
        fullName: 'Zawadi Kileo',
        phoneNumber: '0711223344',
        role: MemberRole.member,
        joinedDate: DateTime.now(),
        totalShares: 0,
        shareValue: repo.shareValue,
      ));
      expect(ok, isTrue);
      expect(members.members.length, 5);
    });

    test('every leadership role is treated as admin', () {
      for (final role in [
        MemberRole.chairperson,
        MemberRole.treasurer,
        MemberRole.secretary,
      ]) {
        final session = Session(
          initial: SessionAccount(
            memberId: 'MEM1',
            name: 'x',
            phone: 'x',
            role: role,
          ),
        );
        expect(session.isAdmin, isTrue, reason: '$role must be admin');
        expect(session.canManageLoans, isTrue);
        expect(session.canRecordContributions, isTrue);
        expect(session.canLogMeetings, isTrue);
      }
    });
  });

  group('Member accounts (view-only, hard boundaries)', () {
    test('cannot add members', () async {
      final repo = makeRepo();
      await repo.ensureLoaded();
      final members = MembersProvider(repo, Session(initial: _memberSession));
      await members.load();

      final ok = await members.addMember(Member(
        id: 'MEM9',
        fullName: 'Zawadi Kileo',
        phoneNumber: '0711223344',
        role: MemberRole.member,
        joinedDate: DateTime.now(),
        totalShares: 0,
        shareValue: repo.shareValue,
      ));
      expect(ok, isFalse);
      expect(members.members.length, 4); // nothing changed
    });

    test('cannot deactivate members', () async {
      final repo = makeRepo();
      await repo.ensureLoaded();
      final members = MembersProvider(repo, Session(initial: _memberSession));
      await members.load();

      final ok = await members.deactivateMember('MEM2');
      expect(ok, isFalse);
      expect(members.members.every((m) => m.isActive), isTrue);
    });

    test('cannot record contributions', () async {
      final repo = makeRepo();
      await repo.ensureLoaded();
      final contributions =
          ContributionsProvider(repo, Session(initial: _memberSession),
              NotificationsController());
      await contributions.load();

      final member = repo.members.first;
      final before = member.totalShares;
      final amount = await contributions.recordContribution(
          member: member, shares: 2);
      expect(amount, isNull);
      expect(member.totalShares, before); // member untouched
      expect(repo.contributions.length, 2); // no new record
    });

    test('cannot approve, reject or record repayments', () async {
      final repo = makeRepo();
      await repo.ensureLoaded();
      final loans = LoansProvider(repo, Session(initial: _memberSession),
          NotificationsController());
      await loans.load();

      final pending = repo.loans.firstWhere((l) => l.status == LoanStatus.pending);
      await loans.approveLoan(pending.id);
      expect(
        repo.loans.firstWhere((l) => l.id == pending.id).status,
        LoanStatus.pending,
      );

      final active = repo.loans.firstWhere((l) => l.status == LoanStatus.active);
      await loans.recordRepayment(active.id, 50000);
      expect(
        repo.loans.firstWhere((l) => l.id == active.id).amountRepaid,
        80000, // unchanged
      );
    });

    test('CAN request a loan — pinned to their own account', () async {
      final repo = makeRepo();
      await repo.ensureLoaded();
      final loans = LoansProvider(repo, Session(initial: _memberSession),
          NotificationsController());
      await loans.load();

      // Even if the UI somehow passed someone else, the request must land
      // on the signed-in member.
      final stranger = repo.members.firstWhere((m) => m.id == 'MEM1');
      final ok = await loans.requestLoan(
        member: stranger,
        principal: 60000,
        repaymentDays: 30,
      );
      expect(ok, isTrue);

      final created = repo.loans
          .firstWhere((l) => l.memberId == 'MEM4' && l.status == LoanStatus.pending);
      expect(created.principal, 60000);
    });
  });

  group('Notifications (members read, never act)', () {
    test('admin actions notify the affected member', () async {
      final repo = makeRepo();
      await repo.ensureLoaded();
      final notifications = NotificationsController();
      final contributions = ContributionsProvider(
          repo, Session(), notifications); // treasurer (admin)
      await contributions.load();

      // Record a contribution for Yusuf (MEM4) as treasurer.
      final yusuf = repo.members.firstWhere((m) => m.id == 'MEM4');
      await contributions.recordContribution(member: yusuf, shares: 1);

      final inbox = notifications.forMember('MEM4');
      expect(inbox, hasLength(1));
      expect(inbox.single.kind, NotificationKind.contribution);
      expect(inbox.single.amount, repo.shareValue);

      // Reading/dismissing never mutates group records.
      expect(notifications.unreadFor('MEM4'), 1);
      await notifications.markAllRead('MEM4');
      expect(notifications.unreadFor('MEM4'), 0);
      expect(repo.contributions.length, 3); // record untouched
    });

    test('member loan decisions produce notifications for that member',
        () async {
      final repo = makeRepo();
      await repo.ensureLoaded();
      final notifications = NotificationsController();
      final loans = LoansProvider(repo, Session(), notifications);
      await loans.load();

      final pending = repo.loans.firstWhere((l) => l.status == LoanStatus.pending);
      await loans.approveLoan(pending.id); // Amina (MEM1)

      final inbox = notifications.forMember('MEM1');
      expect(inbox.single.kind, NotificationKind.loanApproved);
    });
  });
}
