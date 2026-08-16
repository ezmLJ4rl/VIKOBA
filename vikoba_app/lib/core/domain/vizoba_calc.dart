import 'dart:math' as math;

import '../../models/loan.dart';
import '../../models/loan_product.dart';
import '../../models/loan_schedule.dart';
import '../../models/member.dart';
import '../../models/share_out_result.dart';

/// Why a loan request was refused (or accepted). These same rules are
/// enforced server-side — the app-side check only surfaces feedback early.
enum LoanEligibility {
  ok,
  memberInactive,
  membershipTooShort,
  alreadyOwing,
  exceedsMultiple,
  belowMinimum,
  termExceedsMax,
}

/// Outcome of a loan eligibility check, with the max allowed amount so the UI
/// can tell the treasurer what IS possible.
class LoanEligibilityResult {
  final LoanEligibility verdict;
  final double maxAllowed;

  const LoanEligibilityResult(this.verdict, {required this.maxAllowed});

  bool get isOk => verdict == LoanEligibility.ok;
}

/// A full amortization row plus the derived totals a request form shows live.
class LoanQuote {
  final List<LoanSchedule> schedule;
  final double totalInterest;
  final double totalPayable;
  final double monthlyInstallment;
  final LoanInterestMethod method;

  const LoanQuote({
    required this.schedule,
    required this.totalInterest,
    required this.totalPayable,
    required this.monthlyInstallment,
    required this.method,
  });

  factory LoanQuote.fromSchedule(
      List<LoanSchedule> schedule, LoanInterestMethod method) {
    final totalInterest =
        schedule.fold(0.0, (sum, s) => sum + s.interestDue);
    final principal =
        schedule.fold(0.0, (sum, s) => sum + s.principalDue);
    return LoanQuote(
      schedule: schedule,
      totalInterest: totalInterest,
      totalPayable: principal + totalInterest,
      monthlyInstallment: schedule.isEmpty ? 0 : schedule.first.totalDue,
      method: method,
    );
  }
}

/// Pure, side-effect-free business logic.
///
/// These functions are the canonical mobile-side version of the money rules.
/// The backend implements **exactly** the same rules (see
/// `backend/app/Services/VikobaService.php`) so the numbers always agree — the
/// app copy is a preview / UI convenience only and the server always
/// recomputes the authoritative figures.
///
/// Money is stored as [double] for the UI. Floats drift; the backend keeps
/// balances in integer minor units for financial correctness and the UI
/// rounds to whole shillings when it formats.
abstract final class VikobaCalc {
  // ---------------------------------------------------------------------------
  // Fallback rules (used only when the group has no configured product)
  // ---------------------------------------------------------------------------

  static const double minLoanAmount = 20000;
  static const int maxTermMonths = 12;
  static const int defaultMinMembershipDays = 30;

  // ---------------------------------------------------------------------------
  // Savings
  // ---------------------------------------------------------------------------

  static double totalSavings(Iterable<Member> members) =>
      members.fold(0.0, (sum, m) => sum + m.totalContributed);

  // ---------------------------------------------------------------------------
  // Interest / amortization
  // ---------------------------------------------------------------------------

  /// Legacy single-cycle interest: principal x rate%.
  static double interestAmount({
    required double principal,
    required double ratePercent,
  }) =>
      (principal * (ratePercent / 100)).roundToDouble();

  static double totalPayable({
    required double principal,
    required double ratePercent,
  }) =>
      principal + interestAmount(principal: principal, ratePercent: ratePercent);

  static double balance(Loan loan) => loan.balance;

  /// Interest that has actually flowed in: only counted once money is repaid.
  static double totalInterestEarned(Iterable<Loan> loans) => loans
      .where((l) => l.status == LoanStatus.repaid || l.amountRepaid > 0)
      .fold(
          0.0,
          (sum, l) =>
              sum +
              (l.amountRepaid > l.principal
                  ? l.amountRepaid - l.principal
                  : 0));

  /// Installment-by-installment amortization for a whole term. Mirrors the
  /// backend `VikobaService::amortize` — rows always sum to exactly the
  /// principal and the last installment absorbs rounding drift.
  static List<LoanSchedule> amortize({
    required double principal,
    required double ratePercent,
    required int termMonths,
    LoanInterestMethod method = LoanInterestMethod.flat,
    DateTime? start,
  }) {
    final n = math.max(1, termMonths);
    final rows = <LoanSchedule>[];
    var balance = principal;
    final base = start ?? DateTime.now();

    if (method == LoanInterestMethod.reducing) {
      final r = ratePercent / 100;
      final emi = r > 0
          ? (principal * r * math.pow(1 + r, n) / (math.pow(1 + r, n) - 1))
              .roundToDouble()
          : (principal / n).roundToDouble();

      for (var i = 1; i <= n; i++) {
        final interest = r > 0 ? (balance * r).roundToDouble() : 0.0;
        final double principalPart;
        if (i == n) {
          principalPart = balance; // last installment absorbs drift
        } else {
          final remaining = n - i + 1;
          final floor = (balance / remaining).floorToDouble();
          principalPart = math
              .max(math.min(emi - interest, balance), math.max(floor, 0.0));
        }
        rows.add(_row(i, principalPart, interest, balance, base));
        balance -= principalPart;
      }

      return rows;
    }

    // Flat rate: interest is principal x rate% x term, split evenly with the
    // one-shilling remainder (of both principal and interest) given to the
    // earliest rows.
    final totalInterest =
        (principal * (ratePercent / 100) * n).roundToDouble();
    final basePrincipal = (principal / n).floorToDouble();
    final baseInterest = (totalInterest / n).floorToDouble();
    final principalRemainder = principal - basePrincipal * n;
    final interestRemainder = totalInterest - baseInterest * n;
    var runningPrincipal = 0.0;
    var runningInterest = 0.0;

    for (var i = 1; i <= n; i++) {
      var p = basePrincipal + (i <= principalRemainder.round() ? 1.0 : 0.0);
      var interest =
          baseInterest + (i <= interestRemainder.round() ? 1.0 : 0.0);
      if (i == n) {
        p = principal - runningPrincipal;
        interest = totalInterest - runningInterest;
      }
      runningPrincipal += p;
      runningInterest += interest;
      rows.add(_row(i, p, interest, balance, base));
      balance -= p;
    }

    return rows;
  }

  static LoanSchedule _row(
      int no, double principal, double interest, double balance, DateTime start) {
    return LoanSchedule(
      no: no,
      dueDate: start,
      principalDue: principal,
      interestDue: interest,
      totalDue: principal + interest,
      paidPrincipal: 0,
      paidInterest: 0,
    );
  }

  /// A full loan quote from a product's rules — the live preview a request
  /// form shows before submission.
  static LoanQuote quote({
    required LoanProduct product,
    required double principal,
    required int termMonths,
  }) =>
      LoanQuote.fromSchedule(
        amortize(
          principal: principal,
          ratePercent: product.interestRate,
          termMonths: termMonths,
          method: product.interestMethod,
        ),
        product.interestMethod,
      );

  // ---------------------------------------------------------------------------
  // Penalties
  // ---------------------------------------------------------------------------

  /// Penalties that SHOULD have accrued as of [asOf], per the product's
  /// penalty rules (flat TZS or % of outstanding, per completed period after
  /// the grace period). Purely a computation — the server writes the ledger.
  static double accruedPenalty({
    required Loan loan,
    LoanProduct? product,
    DateTime? asOf,
  }) {
    if (loan.status != LoanStatus.active) return 0;
    final now = asOf ?? DateTime.now();
    if (!now.isAfter(loan.dueDate)) return 0;

    final grace = product?.penaltyGraceDays ?? 0;
    final period = math.max(1, product?.penaltyPeriodDays ?? 7);
    final type = product?.penaltyType ?? PenaltyType.flat;
    final value = product?.penaltyValue ?? 0;
    if (value <= 0) return 0;

    final daysLate = _wholeDaysLate(loan.dueDate, now);
    if (daysLate <= 0) return 0;

    final daysAfterGrace = daysLate - grace;
    if (daysAfterGrace <= 0) return 0;

    final charges = (daysAfterGrace / period).ceil();
    final perCharge = type == PenaltyType.percent
        ? (loan.balance * (value / 100)).roundToDouble()
        : value;

    return charges * perCharge;
  }

  /// Whole days from [due] up to [asOf] (matches the backend's
  /// `(int) floor($dueDate->diffInDays($asOf))`).
  static int _wholeDaysLate(DateTime due, DateTime asOf) {
    final dueUtc = DateTime.utc(due.year, due.month, due.day);
    final asOfUtc = DateTime.utc(asOf.year, asOf.month, asOf.day);
    return asOfUtc.difference(dueUtc).inDays;
  }

  // ---------------------------------------------------------------------------
  // Share-out
  // ---------------------------------------------------------------------------

  /// Each member gets their own savings back plus a *proportional* slice of
  /// the interest earned, weighted by their share of the total shares held.
  static List<ShareOutResult> calculateShareOut(
    List<Member> members,
    double totalInterest,
  ) {
    final totalShares = members.fold(0, (sum, m) => sum + m.totalShares);
    if (totalShares == 0) return const [];

    return members.map((m) {
      final proportion = m.totalShares / totalShares;
      final interestShare = totalInterest * proportion;
      return ShareOutResult(
        member: m,
        savings: m.totalContributed,
        interestShare: interestShare,
        totalPayout: m.totalContributed + interestShare,
        shareProportion: proportion,
      );
    }).toList()
      ..sort((a, b) => b.totalPayout.compareTo(a.totalPayout));
  }

  // ---------------------------------------------------------------------------
  // Loan eligibility
  // ---------------------------------------------------------------------------

  /// Maximum a member may borrow given the effective rules (product wins over
  /// the group default; falls back to 4x when nothing is configured).
  static double maxAllowedFor({required Member member, LoanProduct? product}) {
    final multiplier = product?.maxMultiplier ?? 4;
    return member.totalContributed * multiplier;
  }

  /// Loan eligibility, mirroring the group constitution. Returns false for
  /// inactive members, members who joined too recently, requests below the
  /// minimum or above the savings multiple, terms past the product cap, and
  /// members who already hold an approved/active loan.
  static LoanEligibilityResult checkLoanEligibility({
    required Member member,
    required double requestedAmount,
    required List<Loan> allLoans,
    LoanProduct? product,
    int? termMonths,
    int? minMembershipDays,
  }) {
    final cap = maxAllowedFor(member: member, product: product);
    final minAmount = product?.minAmount ?? minLoanAmount;
    final maxTerm = product?.maxTermMonths ?? maxTermMonths;
    final requiredDays = minMembershipDays ?? defaultMinMembershipDays;

    if (!member.isActive) {
      return LoanEligibilityResult(LoanEligibility.memberInactive,
          maxAllowed: cap);
    }
    if (member.membershipDays < requiredDays) {
      return LoanEligibilityResult(LoanEligibility.membershipTooShort,
          maxAllowed: cap);
    }
    if (requestedAmount < minAmount - _epsilon) {
      return LoanEligibilityResult(LoanEligibility.belowMinimum,
          maxAllowed: cap);
    }
    if (requestedAmount > cap + _epsilon) {
      return LoanEligibilityResult(LoanEligibility.exceedsMultiple,
          maxAllowed: cap);
    }
    if (termMonths != null && termMonths > maxTerm) {
      return LoanEligibilityResult(LoanEligibility.termExceedsMax,
          maxAllowed: cap);
    }
    final alreadyOpen = allLoans.any((l) =>
        l.memberId == member.id &&
        (l.status == LoanStatus.approved || l.status == LoanStatus.active));
    if (alreadyOpen) {
      return LoanEligibilityResult(LoanEligibility.alreadyOwing,
          maxAllowed: cap);
    }
    return LoanEligibilityResult(LoanEligibility.ok, maxAllowed: cap);
  }

  // ---------------------------------------------------------------------------
  // Guarantors
  // ---------------------------------------------------------------------------

  /// Total unpaid balance this member is on the hook for as a guarantor.
  static double guarantorExposure(String memberId, Iterable<Loan> loans) =>
      loans
          .where((l) =>
              l.guarantorMemberIds.contains(memberId) &&
              (l.status == LoanStatus.approved ||
                  l.status == LoanStatus.active))
          .fold(0.0, (sum, l) => sum + l.balance);

  // ---------------------------------------------------------------------------
  // Repayment waterfall preview
  // ---------------------------------------------------------------------------

  /// Apply a cash payment in the constitution order: accrued penalties first,
  /// then interest, then principal — walking the schedule in order. Returns
  /// the split plus any overpayment. Mirrors `VikobaService::repay`.
  static ({double penaltyPaid, double interestPaid, double principalPaid,
      double overpayment}) waterfall({
    required Loan loan,
    required double amount,
  }) {
    final applied = math.min(amount, math.max(0.0, loan.balance)).toDouble();
    var overpayment = amount - applied;
    var remaining = applied;

    final penaltyPaid = math.min(remaining, loan.penaltyAccrued).toDouble();
    remaining -= penaltyPaid;

    var interestPaid = 0.0;
    var principalPaid = 0.0;
    final schedules = List<LoanSchedule>.from(loan.schedules)
      ..sort((a, b) => a.no.compareTo(b.no));

    if (schedules.isEmpty) {
      // Legacy pre-schedule loan: treat as a single installment.
      final interestLeft = loan.interestAmount -
          loan.schedules.fold(0.0, (s, x) => s + x.paidInterest);
      interestPaid = math.min(remaining, math.max(0.0, interestLeft));
      principalPaid = remaining - interestPaid;
    } else {
      for (final s in schedules) {
        if (remaining <= 0) break;
        final interestLeft = s.interestDue - s.paidInterest;
        if (interestLeft > 0) {
          final pay = math.min(remaining, interestLeft);
          interestPaid += pay;
          remaining -= pay;
        }
        final principalLeft = s.principalDue - s.paidPrincipal;
        if (principalLeft > 0) {
          final pay = math.min(remaining, principalLeft);
          principalPaid += pay;
          remaining -= pay;
        }
      }
    }

    // Overpayment is never credited — it is returned to the payer.
    return (
      penaltyPaid: penaltyPaid,
      interestPaid: interestPaid,
      principalPaid: principalPaid,
      overpayment: overpayment,
    );
  }

  static const _epsilon = 0.001;
}
