import 'package:flutter_test/flutter_test.dart';
import 'package:vikoba_app/core/domain/vizoba_calc.dart';
import 'package:vikoba_app/models/loan.dart';
import 'package:vikoba_app/models/loan_product.dart';
import 'package:vikoba_app/models/loan_schedule.dart';
import 'package:vikoba_app/models/member.dart';

/// Mirrors `backend/tests/Unit/LoanEngineTest.php` — the Flutter copy of the
/// money rules must agree with the authoritative Laravel engine.
void main() {
  LoanProduct product({
    String name = 'Test Loan',
    double rate = 10,
    LoanInterestMethod method = LoanInterestMethod.flat,
    int maxTerm = 6,
    int multiplier = 4,
    double minAmount = 20000,
    PenaltyType penaltyType = PenaltyType.flat,
    double penaltyValue = 5000,
    int penaltyGrace = 0,
    int penaltyPeriod = 7,
  }) =>
      LoanProduct(
        id: 'P1',
        name: name,
        interestRate: rate,
        interestMethod: method,
        maxTermMonths: maxTerm,
        maxMultiplier: multiplier,
        minAmount: minAmount,
        penaltyType: penaltyType,
        penaltyValue: penaltyValue,
        penaltyGraceDays: penaltyGrace,
        penaltyPeriodDays: penaltyPeriod,
      );

  Member member({int shares = 40, int daysJoined = 120, bool active = true}) =>
      Member(
        id: 'MEM1',
        fullName: 'Amina Juma',
        phoneNumber: '0712345678',
        role: MemberRole.member,
        joinedDate: DateTime.now().subtract(Duration(days: daysJoined)),
        totalShares: shares,
        shareValue: 10000,
        isActive: active,
      );

  Loan loan({
    double principal = 100000,
    LoanProduct? prod,
    int term = 1,
    LoanStatus status = LoanStatus.active,
    Duration lateBy = Duration.zero,
    double penaltyAccrued = 0,
  }) {
    final p = prod ?? product();
    final schedules = VikobaCalc.amortize(
      principal: principal,
      ratePercent: p.interestRate,
      termMonths: term,
      method: p.interestMethod,
    );
    return Loan(
      id: 'L1',
      memberId: 'MEM1',
      memberName: 'Amina Juma',
      principal: principal,
      interestRate: p.interestRate,
      loanProductId: p.id,
      termMonths: term,
      interestMethod: p.interestMethod,
      issuedDate: DateTime.now(),
      dueDate: DateTime.now().subtract(lateBy),
      status: status,
      penaltyAccrued: penaltyAccrued,
      schedules: schedules,
    );
  }

  double sumPrincipal(List<LoanSchedule> rows) =>
      rows.fold(0.0, (s, r) => s + r.principalDue);

  group('amortize (mirrors backend)', () {
    test('flat 100k @10% for 3 months sums exactly with drift to earliest', () {
      final rows = VikobaCalc.amortize(
          principal: 100000, ratePercent: 10, termMonths: 3);

      expect(rows.length, 3);
      expect(sumPrincipal(rows), 100000);
      expect(rows.fold(0.0, (s, r) => s + r.interestDue), 30000);
      expect(rows.first.principalDue, 33334);
      expect(rows[1].principalDue, 33333);
      expect(rows[2].principalDue, 33333);
    });

    test('single flat installment matches the legacy single-cycle formula', () {
      final rows = VikobaCalc.amortize(
          principal: 100000, ratePercent: 10, termMonths: 1);
      expect(rows.first.interestDue, 10000);
      expect(rows.first.totalDue, 110000);
    });

    test('reducing interest declines and costs less than flat', () {
      final flat = VikobaCalc.amortize(
          principal: 100000, ratePercent: 10, termMonths: 3);
      final reducing = VikobaCalc.amortize(
          principal: 100000,
          ratePercent: 10,
          termMonths: 3,
          method: LoanInterestMethod.reducing);

      expect(sumPrincipal(reducing), 100000);
      expect(reducing[0].interestDue, greaterThan(reducing[1].interestDue));
      expect(reducing[1].interestDue, greaterThan(reducing[2].interestDue));
      final flatInterest = flat.fold(0.0, (s, r) => s + r.interestDue);
      final reducingInterest =
          reducing.fold(0.0, (s, r) => s + r.interestDue);
      expect(reducingInterest, lessThan(flatInterest));
    });

    test('reducing zero rate is an even principal split', () {
      final rows = VikobaCalc.amortize(
          principal: 120000,
          ratePercent: 0,
          termMonths: 3,
          method: LoanInterestMethod.reducing);
      expect(rows.first.principalDue, 40000);
      expect(rows.first.interestDue, 0);
    });
  });

  group('quote', () {
    test('exposes totals and schedule from a product', () {
      final quote = VikobaCalc.quote(
          product: product(), principal: 100000, termMonths: 3);

      expect(quote.totalInterest, 30000);
      expect(quote.totalPayable, 130000);
      expect(quote.schedule.length, 3);
      expect(quote.method, LoanInterestMethod.flat);
      expect(quote.monthlyInstallment, closeTo(43334, 0.001));
    });
  });

  group('penalties (mirrors backend)', () {
    test('flat 5000 per 7-day period after grace, no grace', () {
      final l = loan(lateBy: const Duration(days: 15), prod: product());
      // ceil(15/7) = 3 charges x 5000.
      expect(
          VikobaCalc.accruedPenalty(loan: l, product: product()),
          closeTo(15000, 0.001));
    });

    test('grace period suppresses the penalty', () {
      final p = product(penaltyGrace: 10);
      final l = loan(lateBy: const Duration(days: 5), prod: p);
      expect(VikobaCalc.accruedPenalty(loan: l, product: p), 0);
    });

    test('no penalty before the due date or for non-active loans', () {
      expect(VikobaCalc.accruedPenalty(
          loan: loan(prod: product()), product: product()),
          0);
      expect(
          VikobaCalc.accruedPenalty(
              loan: loan(
                  status: LoanStatus.pending,
                  lateBy: const Duration(days: 30),
                  prod: product()),
              product: product()),
          0);
    });
  });

  group('repayment waterfall (mirrors backend)', () {
    test('pays penalties then interest then principal in schedule order', () {
      final l = loan(
        prod: product(),
        term: 2,
        lateBy: const Duration(days: 15),
        penaltyAccrued: 15000,
      );
      // balance = 120000 + 15000 = 135000; 50000 payment.
      final split = VikobaCalc.waterfall(loan: l, amount: 50000);

      expect(split.overpayment, 0);
      expect(split.penaltyPaid, 15000);
      expect(split.interestPaid, 10000);
      expect(split.principalPaid, 25000);
    });

    test('overpayment is returned, never credited', () {
      final l = loan(prod: product(), term: 1);
      final split = VikobaCalc.waterfall(loan: l, amount: 150000);

      expect(split.overpayment, 40000);
      expect(split.principalPaid + split.interestPaid, 110000);
      expect(l.balance, 110000);
    });
  });

  group('eligibility (mirrors backend)', () {
    test('applies product rules and membership days', () {
      final p = product();
      // Joined 5 days ago: membership too short.
      expect(
          VikobaCalc.checkLoanEligibility(
                  member: member(daysJoined: 5),
                  requestedAmount: 100000,
                  allLoans: const [],
                  product: p,
                  termMonths: 3)
              .verdict,
          LoanEligibility.membershipTooShort);

      // Old enough, but 10 shares x 10k x 4 = 400k cap.
      expect(
          VikobaCalc.checkLoanEligibility(
                  member: member(shares: 10, daysJoined: 120),
                  requestedAmount: 500000,
                  allLoans: const [],
                  product: p,
                  termMonths: 3)
              .verdict,
          LoanEligibility.exceedsMultiple);

      // Term past the product max.
      expect(
          VikobaCalc.checkLoanEligibility(
                  member: member(shares: 10, daysJoined: 120),
                  requestedAmount: 100000,
                  allLoans: const [],
                  product: p,
                  termMonths: 12)
              .verdict,
          LoanEligibility.termExceedsMax);

      // All good.
      expect(
          VikobaCalc.checkLoanEligibility(
                  member: member(),
                  requestedAmount: 100000,
                  allLoans: const [],
                  product: p,
                  termMonths: 3)
              .isOk,
          true);
    });

    test('blocks inactive members and repeat borrowers', () {
      final p = product();
      expect(
          VikobaCalc.checkLoanEligibility(
                  member: member(active: false),
                  requestedAmount: 100000,
                  allLoans: const [],
                  product: p)
              .verdict,
          LoanEligibility.memberInactive);

      final l = loan(prod: p, status: LoanStatus.active);
      expect(
          VikobaCalc.checkLoanEligibility(
                  member: member(),
                  requestedAmount: 50000,
                  allLoans: [l],
                  product: p)
              .verdict,
          LoanEligibility.alreadyOwing);
    });

    test('below the group minimum is refused', () {
      expect(
          VikobaCalc.checkLoanEligibility(
                  member: member(),
                  requestedAmount: 5000,
                  allLoans: const [],
                  product: product())
              .verdict,
          LoanEligibility.belowMinimum);
    });
  });
}
