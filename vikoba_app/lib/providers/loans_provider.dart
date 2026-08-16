import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../core/data/app_repository.dart';
import '../core/data/pending_operation.dart';
import '../core/domain/vizoba_calc.dart';
import '../core/state/async_state.dart';
import '../core/state/notifications.dart';
import '../core/state/session.dart';
import '../models/loan.dart';
import '../models/loan_product.dart';
import '../models/loan_schedule.dart';
import '../models/member.dart';

/// Loan requests, approvals, disbursements, repayments and interest math.
/// All writes go through [AppRepository] and are queued for offline sync.
///
/// Permission model (data layer):
/// * anyone may request a loan — members only ever for themselves, enforced
///   here by pinning the member to the signed-in account;
/// * approve / reject / disburse / repay are admin-only.
class LoansProvider extends ChangeNotifier {
  LoansProvider(this._repo, this._session, this._notifications);

  final AppRepository _repo;
  final Session _session;
  final NotificationsController _notifications;
  AsyncState _state = const AsyncState.idle();

  AsyncState get state => _state;
  double get interestRate => _repo.defaultInterestRate;
  int get minMembershipDays => _repo.minMembershipDays;

  /// Newest first (UI order).
  List<Loan> get loans => List.unmodifiable(_repo.loans.reversed);
  List<Loan> get _rawLoans => _repo.loans;
  List<LoanProduct> get loanProducts => List.unmodifiable(_repo.loanProducts);

  double get totalActiveLoans => _rawLoans
      .where((l) => l.status == LoanStatus.active)
      .fold(0.0, (sum, l) => sum + VikobaCalc.balance(l));

  double get totalInterestEarned => VikobaCalc.totalInterestEarned(_rawLoans);

  LoanProduct? productById(String? id) =>
      _repo.loanProducts.where((p) => p.id == id).firstOrNull;

  LoanProduct? _productFor(Loan loan) => productById(loan.loanProductId);

  /// Live quote preview for the request form (dates are placeholders — the
  /// server re-dates the schedule from the real disbursement).
  Future<LoanQuote> quote({
    required LoanProduct product,
    required double principal,
    required int termMonths,
  }) async {
    await _repo.ensureLoaded();
    return VikobaCalc.quote(
        product: product, principal: principal, termMonths: termMonths);
  }

  /// Computed-but-not-yet-recorded penalty for a loan (mirror; the server
  /// writes the authoritative ledger).
  double accruedPenalty(Loan loan) => VikobaCalc.accruedPenalty(
        loan: loan,
        product: _productFor(loan),
      );

  double guarantorExposure(String memberId) =>
      VikobaCalc.guarantorExposure(memberId, _rawLoans);

  Future<void> load() async {
    _state = const AsyncState.loading();
    notifyListeners();
    try {
      await _repo.ensureLoaded();
      _state = const AsyncState.loaded();
    } catch (e) {
      _state = AsyncState.failed('Could not load loans: $e');
    }
    notifyListeners();
  }

  Future<LoanEligibilityResult> checkEligibility({
    required Member member,
    required double requestedAmount,
    LoanProduct? product,
    int? termMonths,
  }) async {
    await _repo.ensureLoaded();
    return VikobaCalc.checkLoanEligibility(
      member: member,
      requestedAmount: requestedAmount,
      allLoans: _rawLoans,
      product: product,
      termMonths: termMonths,
      minMembershipDays: minMembershipDays,
    );
  }

  /// Requests a loan; returns false when the group rules disallow it.
  /// Member accounts may only request on their own behalf.
  Future<bool> requestLoan({
    required Member member,
    required double principal,
    required int repaymentDays,
    LoanProduct? product,
    int? termMonths,
    List<String> guarantorMemberIds = const [],
  }) async {
    await _repo.ensureLoaded();

    final effectiveMember = _selfMember(member, _session);
    if (effectiveMember == null) return false;

    final months = termMonths ?? ((repaymentDays / 30).ceil()).clamp(1, 120);
    final effectiveProduct = product ?? loanProducts.firstOrNull;

    if (!VikobaCalc.checkLoanEligibility(
      member: effectiveMember,
      requestedAmount: principal,
      allLoans: _rawLoans,
      product: effectiveProduct,
      termMonths: months,
      minMembershipDays: minMembershipDays,
    ).isOk) {
      return false;
    }

    final now = DateTime.now();
    final schedules = _datedSchedules(
      principal: principal,
      product: effectiveProduct,
      termMonths: months,
      start: now,
    );
    final dueDate = now.add(Duration(days: effectiveProduct?.installmentIntervalDays ?? 30) * months);

    final loan = Loan(
      id: 'L${_rawLoans.length + 1}',
      memberId: effectiveMember.id,
      memberName: effectiveMember.fullName,
      principal: principal,
      interestRate: effectiveProduct?.interestRate ?? _repo.defaultInterestRate,
      loanProductId: effectiveProduct?.id,
      termMonths: months,
      interestMethod: effectiveProduct?.interestMethod ?? LoanInterestMethod.flat,
      installmentIntervalDays:
          effectiveProduct?.installmentIntervalDays ?? 30,
      issuedDate: now,
      dueDate: dueDate,
      status: LoanStatus.pending,
      schedules: schedules,
      guarantorMemberIds: List.unmodifiable(guarantorMemberIds.take(2)),
    );
    await _replaceLoan([loan], sync: 'loan.request');
    await _notifications.add(
      memberId: effectiveMember.id,
      kind: NotificationKind.loanRequested,
      amount: principal,
    );
    return true;
  }

  /// A member's own roster record (for self-request); admins pass [member].
  Member? _selfMember(Member requested, Session session) {
    if (session.isAdmin) return requested;
    final account = session.account;
    return _repo.members.where((m) => m.id == account.memberId).firstOrNull;
  }

  Future<void> approveLoan(String loanId) =>
      _mutate(loanId, (l) {
        final updated = l.copyWith(status: LoanStatus.approved);
        return updated;
      }, 'loan.approve', onChanged: (l) async {
        await _notifications.add(
          memberId: l.memberId,
          kind: NotificationKind.loanApproved,
          amount: l.totalPayable,
        );
      });

  Future<void> rejectLoan(String loanId) =>
      _mutate(loanId, (l) => l.copyWith(status: LoanStatus.rejected),
          'loan.reject', onChanged: (l) async {
        await _notifications.add(
          memberId: l.memberId,
          kind: NotificationKind.loanRejected,
          amount: l.totalPayable,
        );
      });

  /// Starts the repayment clock: approved -> active, schedule re-dated from
  /// today so the member gets the full period they were promised.
  Future<void> disburseLoan(String loanId) async {
    await _repo.ensureLoaded();
    final idx = _rawLoans.indexWhere((l) => l.id == loanId);
    if (idx == -1) return;
    final loan = _rawLoans[idx];
    if (loan.status != LoanStatus.approved) return;
    await _mutate(
      loanId,
      (l) {
        final start = DateTime.now();
        final schedules = _datedSchedules(
          principal: l.principal,
          product: _productFor(l),
          termMonths: l.termMonths,
          start: start,
        );
        final dueDate = start.add(
            Duration(days: l.installmentIntervalDays) * l.termMonths);
        return l.copyWith(
          status: LoanStatus.active,
          disbursedAt: start,
          dueDate: dueDate,
          schedules: schedules,
        );
      },
      'loan.disburse',
    );
  }

  /// Records a repayment using the constitution waterfall: accrued penalties
  /// first, then interest, then principal — walking the schedule in order.
  /// Overpayment is returned, never credited.
  Future<double> recordRepayment(String loanId, double amount) async {
    await _repo.ensureLoaded();
    final idx = _rawLoans.indexWhere((l) => l.id == loanId);
    if (idx == -1 || amount <= 0) return 0;
    final loan = _rawLoans[idx];

    // Bring the local penalty counter up to what the rules now demand.
    final accrued =
        math.max(loan.penaltyAccrued, accruedPenalty(loan));
    final withPenalty = loan.copyWith(penaltyAccrued: accrued);

    final split = VikobaCalc.waterfall(loan: withPenalty, amount: amount);
    final schedules = _applyWaterfall(
        withPenalty.schedules, split.interestPaid, split.principalPaid);
    final newRepaid = (withPenalty.amountRepaid +
            split.interestPaid +
            split.principalPaid)
        .clamp(0.0, withPenalty.totalPayable);
    final newPenalty =
        (withPenalty.penaltyAccrued - split.penaltyPaid).clamp(0.0, double.infinity);
    final fullyRepaid = (withPenalty.totalPayable + newPenalty - newRepaid) <=
        0.001;

    await _mutate(
      loanId,
      (l) => l.copyWith(
        amountRepaid: newRepaid,
        penaltyAccrued: newPenalty,
        status: fullyRepaid ? LoanStatus.repaid : LoanStatus.active,
        schedules: schedules,
      ),
      'repayment.create',
      onChanged: (l) async {
        await _notifications.add(
          memberId: l.memberId,
          kind: NotificationKind.repayment,
          amount: amount,
        );
      },
    );
    return split.overpayment;
  }

  /// Applies a waterfall payment to the schedule rows, producing a new
  /// schedule list with paid principal/interest and paid-status flags.
  List<LoanSchedule> _applyWaterfall(List<LoanSchedule> schedules,
      double interestPool, double principalPool) {
    return schedules.map((s) {
      var interestPaid = s.paidInterest;
      var principalPaid = s.paidPrincipal;

      final interestLeft = s.interestDue - interestPaid;
      if (interestPool > 0 && interestLeft > 0) {
        final pay = math.min(interestPool, interestLeft);
        interestPaid += pay;
        interestPool -= pay;
      }

      final principalLeft = s.principalDue - principalPaid;
      if (principalPool > 0 && principalLeft > 0) {
        final pay = math.min(principalPool, principalLeft);
        principalPaid += pay;
        principalPool -= pay;
      }

      final done = interestPaid >= s.interestDue &&
          principalPaid >= s.principalDue;
      return s.copyWith(
        paidPrincipal: principalPaid,
        paidInterest: interestPaid,
        status: done ? LoanScheduleStatus.paid : s.status,
      );
    }).toList();
  }

  /// Amortizes [principal] and dates the installments `no * interval` days
  /// after [start], matching the backend's schedule generation.
  List<LoanSchedule> _datedSchedules({
    required double principal,
    required LoanProduct? product,
    required int termMonths,
    required DateTime start,
  }) {
    final method =
        product?.interestMethod ?? LoanInterestMethod.flat;
    final interval = product?.installmentIntervalDays ?? 30;
    return VikobaCalc.amortize(
      principal: principal,
      ratePercent: product?.interestRate ?? interestRate,
      termMonths: termMonths,
      method: method,
      start: start,
    ).map((s) => LoanSchedule(
          no: s.no,
          dueDate: start.add(Duration(days: s.no * interval)),
          principalDue: s.principalDue,
          interestDue: s.interestDue,
          totalDue: s.totalDue,
        )).toList();
  }

  Future<void> _mutate(
    String loanId,
    Loan Function(Loan) transform,
    String syncType, {
    Future<void> Function(Loan updated)? onChanged,
  }) async {
    // Admin-only boundary for loan decisions — the UI hides these buttons for
    // members, but the data layer refuses regardless.
    if (!_session.canManageLoans) return;
    await _repo.ensureLoaded();
    final idx = _rawLoans.indexWhere((l) => l.id == loanId);
    if (idx == -1) return;
    final updated = transform(_rawLoans[idx]);
    await _replaceLoan([updated], sync: syncType);
    if (onChanged != null) await onChanged(updated);
  }

  Future<void> _replaceLoan(List<Loan> withThese,
      {required String sync}) async {
    final byId = {for (final l in _rawLoans) l.id: l};
    for (final l in withThese) {
      byId[l.id] = l; // upsert: new loans added, existing ones replaced
    }
    final merged = byId.values.toList();
    await _repo.setLoans(merged);
    for (final l in withThese) {
      final payload = l.toJson();
      final member = _repo.members
          .where((m) => m.id == l.memberId)
          .firstOrNull;
      if (member != null) payload['phoneNumber'] = member.phoneNumber;
      await _repo.enqueue(PendingOperation.create(sync, payload));
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    await _repo.ensureLoaded();
    notifyListeners();
  }
}
