import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/domain/vizoba_calc.dart';
import '../core/state/session.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../core/validation/validators.dart';
import '../l10n/app_localizations.dart';
import '../models/loan.dart';
import '../models/loan_product.dart';
import '../models/loan_schedule.dart';
import '../providers/loans_provider.dart';
import '../providers/members_provider.dart';
import '../widgets/status_badge.dart';

/// One loan in depth: the amortized schedule, accrued penalties, guarantors
/// and the waterfall repayment form.
class LoanDetailScreen extends StatefulWidget {
  const LoanDetailScreen({super.key, required this.loanId});

  final String loanId;

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen> {
  Loan? get _loan =>
      context.read<LoansProvider>().loans.where((l) => l.id == widget.loanId).firstOrNull;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loans = context.watch<LoansProvider>();
    final session = context.watch<Session>();
    final loan = _loan;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.loanDetailTitle)),
      body: loan == null
          ? const Center(child: Text('Loan not found'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              children: [
                _HeaderCard(loan: loan),
                const SizedBox(height: 12),
                _BalanceCard(loan: loan),
                if (loan.penaltyAccrued > 0) ...[
                  const SizedBox(height: 12),
                  _PenaltyCard(loan: loan),
                ],
                if (loan.guarantorMemberIds.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _GuarantorsCard(
                    loans: loans,
                    memberIds: loan.guarantorMemberIds,
                  ),
                ],
                const SizedBox(height: 12),
                _ScheduleCard(loan: loan),
                if (loan.status == LoanStatus.active &&
                    session.canManageLoans) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showRepaySheet(loan),
                    icon: const Icon(Icons.payments_outlined),
                    label: Text(l10n.recordRepayment),
                  ),
                ],
                if (loan.status == LoanStatus.pending &&
                    session.canManageLoans) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => loans.rejectLoan(loan.id),
                          icon: const Icon(Icons.close, size: 18),
                          label: Text(l10n.reject),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => loans.approveLoan(loan.id),
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: Text(l10n.approve),
                        ),
                      ),
                    ],
                  ),
                ],
                if (loan.status == LoanStatus.approved &&
                    session.canManageLoans) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => loans.disburseLoan(loan.id),
                    icon: const Icon(Icons.paid_outlined),
                    label: Text(l10n.disburse),
                  ),
                ],
              ],
            ),
    );
  }

  void _showRepaySheet(Loan loan) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _RepaymentSheet(loan: loan),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.loan});

  final Loan loan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final members = context.watch<MembersProvider>();
    final member = members.members.where((m) => m.id == loan.memberId).firstOrNull;
    final overdue = loan.isOverdue;
    final statusColor = overdue
        ? AppColors.statusAttention
        : switch (loan.status) {
            LoanStatus.pending || LoanStatus.approved => AppColors.statusPending,
            LoanStatus.active || LoanStatus.repaid => AppColors.statusOk,
            LoanStatus.rejected => AppColors.statusAttention,
          };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(loan.memberName,
                      style: AppFonts.displayFont(20, FontWeight.w700,
                          color: AppColors.ink)),
                ),
                const SizedBox(width: 8),
                StatusBadge(
                  label: overdue ? l10n.overdue : loan.statusLabel,
                  color: statusColor,
                ),
              ],
            ),
            if (member != null) ...[
              const SizedBox(height: 4),
              Text('${member.roleLabel} · ${member.phoneNumber}',
                  style: AppFonts.body(12.5, FontWeight.w400,
                      color: AppColors.inkSoft)),
            ],
            const Divider(height: 24),
            _kv(l10n.principal, Formatters.money(loan.principal)),
            _kv(l10n.interestRateHelper(loan.interestRate.toString()),
                Formatters.money(loan.interestAmount)),
            _kv(
                loan.interestMethod == LoanInterestMethod.flat
                    ? l10n.quoteMethodFlat
                    : l10n.quoteMethodReducing,
                l10n.monthsPeriod(loan.termMonths)),
          ],
        ),
      ),
    );
  }

  Widget _kv(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: AppFonts.body(13, FontWeight.w400,
                    color: AppColors.inkSoft)),
            Text(value,
                style: AppFonts.body(13, FontWeight.w700,
                    color: AppColors.ink)),
          ],
        ),
      );
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.loan});

  final Loan loan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.forestDeep, AppColors.forest],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.balance,
                  style: AppFonts.body(12, FontWeight.w600,
                      color: AppColors.goldSoft)),
              const SizedBox(height: 2),
              Text(Formatters.money(loan.balance),
                  style: AppFonts.displayFont(30, FontWeight.w700,
                      color: AppColors.cream)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _mini(l10n.quoteTotalPayable,
                        Formatters.money(loan.totalPayable)),
                  ),
                  Expanded(
                    child: _mini(l10n.loanAmountRepaid,
                        Formatters.money(loan.amountRepaid)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _mini(l10n.due, Formatters.date(loan.dueDate)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mini(String label, String value) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppFonts.body(11, FontWeight.w500,
                    color: AppColors.goldSoft)),
            Text(value,
                style: AppFonts.body(13, FontWeight.w700,
                    color: AppColors.cream)),
          ],
        ),
      );
}

class _PenaltyCard extends StatelessWidget {
  const _PenaltyCard({required this.loan});

  final Loan loan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: ListTile(
        leading: Icon(Icons.warning_amber_outlined,
            color: AppColors.clay),
        title: Text(l10n.penaltyAccrued,
            style: AppFonts.body(14, FontWeight.w700)),
        subtitle: Text(l10n.loanTermTooLong,
            style: AppFonts.body(12, FontWeight.w400,
                color: AppColors.inkSoft)),
        trailing: Text(Formatters.money(loan.penaltyAccrued),
            style: AppFonts.body(15, FontWeight.w700,
                color: AppColors.clay)),
      ),
    );
  }
}

class _GuarantorsCard extends StatelessWidget {
  const _GuarantorsCard({required this.loans, required this.memberIds});

  final LoansProvider loans;
  final List<String> memberIds;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final members = context.watch<MembersProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.guarantorsList,
                style: AppFonts.body(14, FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: memberIds.map((id) {
                final m =
                    members.members.where((x) => x.id == id).firstOrNull;
                return Chip(
                  avatar: const Icon(Icons.handshake_outlined, size: 16),
                  label: Text(m?.fullName ?? id),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.loan});

  final Loan loan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.scheduleTitle,
                style: AppFonts.body(14, FontWeight.w700)),
            const SizedBox(height: 12),
            if (loan.schedules.isEmpty)
              Text(l10n.noLoansYet,
                  style: AppFonts.body(12, FontWeight.w400,
                      color: AppColors.inkSoft))
            else
              ...loan.schedules.map((s) => _ScheduleRow(
                  schedule: s, paidInFull: loan.status == LoanStatus.repaid)),
          ],
        ),
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.schedule, required this.paidInFull});

  final LoanSchedule schedule;
  final bool paidInFull;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final paid = schedule.isPaid || paidInFull;
    final paidTotal = schedule.paidPrincipal + schedule.paidInterest;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            child: Text('#${schedule.no}',
                style: AppFonts.body(13, FontWeight.w700,
                    color: paid ? AppColors.forest : AppColors.ink)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Formatters.money(schedule.totalDue),
                    style: AppFonts.body(13, FontWeight.w600,
                        color: AppColors.ink)),
                Text(
                  '${l10n.dueOn(Formatters.date(schedule.dueDate))} · '
                  '${Formatters.money(paidTotal)} '
                  '${l10n.loanAmountRepaid.toLowerCase()}',
                  style: AppFonts.body(11.5, FontWeight.w400,
                      color: AppColors.inkSoft),
                ),
              ],
            ),
          ),
          StatusBadge(
            label: paid ? l10n.paidLabel : l10n.unpaidLabel,
            color: paid ? AppColors.statusOk : AppColors.statusAttention,
          ),
        ],
      ),
    );
  }
}

/// Repayment form with a live waterfall preview: accrued penalties first,
/// then interest, then principal — overpayment is returned, never credited.
class _RepaymentSheet extends StatefulWidget {
  const _RepaymentSheet({required this.loan});

  final Loan loan;

  @override
  State<_RepaymentSheet> createState() => _RepaymentSheetState();
}

class _RepaymentSheetState extends State<_RepaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  late AppLocalizations _l10n;
  Loan? _preview;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _updatePreview() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final provider = context.read<LoansProvider>();
    final computed = VikobaCalc.accruedPenalty(
        loan: widget.loan,
        product: provider.productById(widget.loan.loanProductId));
    final accrued = widget.loan.penaltyAccrued > computed
        ? widget.loan.penaltyAccrued
        : computed;
    setState(() {
      _preview = amount > 0 ? widget.loan.copyWith(penaltyAccrued: accrued) : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loan = widget.loan;
    final preview = _preview;
    final amount = double.tryParse(_amountController.text) ?? 0;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_l10n.repaymentTitle(loan.memberName),
                style: AppFonts.displayFont(22, FontWeight.w700,
                    color: AppColors.ink)),
            const SizedBox(height: 4),
            Text('${_l10n.balance}: ${Formatters.money(loan.balance)}',
                style: AppFonts.body(13, FontWeight.w400,
                    color: AppColors.inkSoft)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: _l10n.amountTzs),
              validator: Validators.positiveNumber,
              onChanged: (_) => _updatePreview(),
            ),
            if (preview != null) ...[
              const SizedBox(height: 12),
              _WaterfallPreview(loan: preview, amount: amount),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final repayAmount = double.tryParse(_amountController.text) ?? 0;
                final messenger = ScaffoldMessenger.of(context);
                final overpayment = await context
                    .read<LoansProvider>()
                    .recordRepayment(loan.id, repayAmount);
                if (!context.mounted) return;
                Navigator.pop(context);
                if (overpayment > 0) {
                  messenger.showSnackBar(SnackBar(
                    content: Text(_l10n
                        .overpaymentReturned(Formatters.money(overpayment))),
                  ));
                }
              },
              icon: const Icon(Icons.payments_outlined),
              label: Text(_l10n.saveRepayment),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterfallPreview extends StatelessWidget {
  const _WaterfallPreview({required this.loan, required this.amount});

  final Loan loan;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final split = VikobaCalc.waterfall(loan: loan, amount: amount);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.goldSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.quoteTitle,
              style: AppFonts.body(13, FontWeight.w700,
                  color: AppColors.forestDeep)),
          const SizedBox(height: 8),
          _row(l10n.waterfallPenalty, Formatters.money(split.penaltyPaid)),
          _row(l10n.waterfallInterest, Formatters.money(split.interestPaid)),
          _row(l10n.waterfallPrincipal, Formatters.money(split.principalPaid)),
          if (split.overpayment > 0)
            _row(l10n.overpaymentReturned(''),
                '+${Formatters.money(split.overpayment)}'),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: AppFonts.body(12.5, FontWeight.w400,
                    color: AppColors.inkSoft)),
            Text(value,
                style: AppFonts.body(12.5, FontWeight.w700,
                    color: AppColors.ink)),
          ],
        ),
      );
}
