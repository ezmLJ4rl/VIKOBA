import '../../models/contribution.dart';
import '../../models/loan.dart';
import '../../models/loan_product.dart';
import '../../models/loan_schedule.dart';
import '../../models/meeting.dart';
import '../../models/member.dart';
import 'persisted_snapshot.dart';

/// Demo data for first launch so the prototype feels alive.
///
/// *Whole numbers only* values are used on purpose so manual sums are easy to
/// audit in the UI. The share-out and interest figures below are kept in sync
/// with the tests in `test/vikoba_provider_test.dart`.
class SeedData {
  static const double shareValue = 10000;
  static const double interestRate = 10;

  static PersistedSnapshot build() {
    final now = DateTime.now();
    final members = [
      Member(
        id: 'MEM1',
        fullName: 'Amina Juma',
        phoneNumber: '0712345678',
        role: MemberRole.chairperson,
        joinedDate: now.subtract(const Duration(days: 200)),
        totalShares: 24,
        shareValue: shareValue,
      ),
      Member(
        id: 'MEM2',
        fullName: 'Elisha Mgeni',
        phoneNumber: '0765432109',
        role: MemberRole.treasurer,
        joinedDate: now.subtract(const Duration(days: 180)),
        totalShares: 30,
        shareValue: shareValue,
      ),
      Member(
        id: 'MEM3',
        fullName: 'Fatuma Rashidi',
        phoneNumber: '0788112233',
        role: MemberRole.secretary,
        joinedDate: now.subtract(const Duration(days: 150)),
        totalShares: 18,
        shareValue: shareValue,
      ),
      Member(
        id: 'MEM4',
        fullName: 'Yusuf Hamisi',
        phoneNumber: '0754332211',
        role: MemberRole.member,
        joinedDate: now.subtract(const Duration(days: 90)),
        totalShares: 12,
        shareValue: shareValue,
      ),
    ];

    final products = [
      const LoanProduct(
        id: 'P1',
        name: 'Emergency Loan',
        description: 'Short-term cash for urgent needs.',
        interestRate: 10,
        interestMethod: LoanInterestMethod.flat,
        maxTermMonths: 6,
        maxMultiplier: 4,
        minAmount: 20000,
        penaltyType: PenaltyType.flat,
        penaltyValue: 5000,
        penaltyGraceDays: 0,
        penaltyPeriodDays: 7,
        installmentIntervalDays: 30,
      ),
      const LoanProduct(
        id: 'P2',
        name: 'Farm Inputs',
        description: 'Seeds, fertiliser and equipment purchases.',
        interestRate: 12,
        interestMethod: LoanInterestMethod.reducing,
        maxTermMonths: 12,
        maxMultiplier: 3,
        minAmount: 50000,
        penaltyType: PenaltyType.percent,
        penaltyValue: 2,
        penaltyGraceDays: 3,
        penaltyPeriodDays: 7,
        installmentIntervalDays: 30,
      ),
    ];

    final loans = [
      Loan(
        id: 'L1',
        memberId: 'MEM3',
        memberName: 'Fatuma Rashidi',
        principal: 150000,
        interestRate: interestRate,
        loanProductId: 'P1',
        termMonths: 1,
        interestMethod: LoanInterestMethod.flat,
        issuedDate: now.subtract(const Duration(days: 30)),
        dueDate: now.add(const Duration(days: 30)),
        amountRepaid: 80000,
        status: LoanStatus.active,
        schedules: [
          LoanSchedule(
            no: 1,
            dueDate: now.add(const Duration(days: 30)),
            principalDue: 150000,
            interestDue: 15000,
            totalDue: 165000,
            paidPrincipal: 80000,
            paidInterest: 0,
          ),
        ],
      ),
      Loan(
        id: 'L2',
        memberId: 'MEM4',
        memberName: 'Yusuf Hamisi',
        principal: 100000,
        interestRate: interestRate,
        loanProductId: 'P1',
        termMonths: 1,
        interestMethod: LoanInterestMethod.flat,
        issuedDate: now.subtract(const Duration(days: 60)),
        dueDate: now.subtract(const Duration(days: 5)),
        amountRepaid: 110000,
        status: LoanStatus.repaid,
        schedules: [
          LoanSchedule(
            no: 1,
            dueDate: now.subtract(const Duration(days: 5)),
            principalDue: 100000,
            interestDue: 10000,
            totalDue: 110000,
            paidPrincipal: 100000,
            paidInterest: 10000,
            status: LoanScheduleStatus.paid,
          ),
        ],
      ),
      Loan(
        id: 'L3',
        memberId: 'MEM1',
        memberName: 'Amina Juma',
        principal: 200000,
        interestRate: interestRate,
        loanProductId: 'P1',
        termMonths: 1,
        interestMethod: LoanInterestMethod.flat,
        issuedDate: now,
        dueDate: now.add(const Duration(days: 45)),
        status: LoanStatus.pending,
        schedules: [
          LoanSchedule(
            no: 1,
            dueDate: now.add(const Duration(days: 45)),
            principalDue: 200000,
            interestDue: 20000,
            totalDue: 220000,
          ),
        ],
      ),
    ];

    final contributions = [
      Contribution(
        id: 'C1',
        memberId: 'MEM2',
        memberName: 'Elisha Mgeni',
        sharesBought: 2,
        amount: 2 * shareValue,
        date: now.subtract(const Duration(days: 7)),
      ),
      Contribution(
        id: 'C2',
        memberId: 'MEM1',
        memberName: 'Amina Juma',
        sharesBought: 1,
        amount: shareValue,
        date: now.subtract(const Duration(days: 7)),
      ),
    ];

    final meetings = [
      Meeting(
        id: 'M1',
        date: now.subtract(const Duration(days: 7)),
        agenda: 'Weekly contribution & loan review',
        presentMemberIds: ['MEM1', 'MEM2', 'MEM3'],
        totalMembers: members.length,
      ),
    ];

    return PersistedSnapshot(
      groupName: 'Vikoba Group',
      shareValue: shareValue,
      defaultInterestRate: interestRate,
      members: members,
      contributions: contributions,
      loans: loans,
      loanProducts: products,
      meetings: meetings,
    );
  }
}
