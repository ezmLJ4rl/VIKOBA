import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/domain/vizoba_calc.dart';
import '../core/state/app_navigation.dart';
import '../core/state/session.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../core/validation/validators.dart';
import '../l10n/app_localizations.dart';
import '../models/loan.dart';
import '../models/loan_product.dart';
import '../models/member.dart';
import '../providers/loans_provider.dart';
import '../providers/members_provider.dart';
import '../widgets/hero_card.dart';
import '../widgets/kitenge_thread.dart';
import '../widgets/status_badge.dart';
import 'loan_detail_screen.dart';
import 'loan_management_screen.dart';

/// Loan list with approve/disburse/repay actions + validated request form.
/// Status is carried by colour first: forest = on track, gold = pending,
/// clay = overdue/attention.
class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pending = context.read<AppNavigation>().takePending();
    if (pending == PendingAction.addLoanRequest && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showRequestSheet();
      });
    }
  }

  Color _statusColor(Loan l) {
    if (l.isOverdue) return AppColors.statusAttention;
    return switch (l.status) {
      LoanStatus.pending || LoanStatus.approved => AppColors.statusPending,
      LoanStatus.active || LoanStatus.repaid => AppColors.statusOk,
      LoanStatus.rejected => AppColors.statusAttention,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<LoansProvider>();
    final session = context.watch<Session>();
    final loans = provider.loans;
    final overdueCount = loans.where((l) => l.isOverdue).length;
    final pendingCount =
        loans.where((l) => l.status == LoanStatus.pending).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appBarLoans),
        actions: [
          if (session.canManageLoans)
            IconButton(
              tooltip: l10n.loanManagement,
              icon: const Icon(Icons.manage_search_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const LoanManagementScreen(),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: session.canRequestLoans
          ? FloatingActionButton(
              onPressed: _showRequestSheet,
              tooltip: l10n.newLoan,
              heroTag: 'loans-add-fab',
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          const KitengeThread(),
          Expanded(
            child: loans.isEmpty
                ? Center(
                    child: Text(
                      l10n.noLoansYet,
                      style: AppFonts.body(14, FontWeight.w400,
                          color: AppColors.inkSoft),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    children: [
                      HeroCard(
                        title: l10n.activeLoansValue,
                        value: Formatters.money(provider.totalActiveLoans),
                        chips: [
                          HeroChip(
                            icon: Icons.trending_up,
                            label: l10n.interestEarned,
                            value:
                                Formatters.money(provider.totalInterestEarned),
                          ),
                          HeroChip(
                            icon: Icons.schedule_outlined,
                            label: l10n.pendingLoans,
                            value: '$pendingCount',
                          ),
                          if (overdueCount > 0)
                            HeroChip(
                              icon: Icons.warning_amber_outlined,
                              label: l10n.overdue,
                              value: '$overdueCount',
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...loans.map((loan) => Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => LoanDetailScreen(
                                      loanId: loan.id),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(loan.memberName,
                                              style: AppFonts.body(
                                                  15, FontWeight.w700),
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: StatusBadge(
                                            label: loan.isOverdue
                                                ? l10n.overdue
                                                : loan.statusLabel,
                                            color: _statusColor(loan),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${l10n.principal}: '
                                          '${Formatters.money(loan.principal)}',
                                          style: AppFonts.body(12.5,
                                              FontWeight.w400,
                                              color: AppColors.inkSoft),
                                        ),
                                        Text(
                                          '${l10n.due}: '
                                          '${Formatters.date(loan.dueDate)}',
                                          style: AppFonts.body(12.5,
                                              FontWeight.w400,
                                              color: AppColors.inkSoft),
                                        ),
                                      ],
                                    ),
                                    if (loan.status == LoanStatus.active ||
                                        loan.status == LoanStatus.repaid) ...[
                                      const SizedBox(height: 10),
                                      _GradientProgress(
                                        value: loan.progress,
                                        healthy: !loan.isOverdue,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.repaidOf(
                                            Formatters.money(loan.amountRepaid),
                                            Formatters.money(
                                                loan.totalPayable)),
                                        style: AppFonts.body(12,
                                                FontWeight.w500,
                                                color: AppColors.inkSoft),
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                    if (session.canManageLoans)
                                      Row(
                                        children: [
                                          if (loan.status ==
                                              LoanStatus.pending) ...[
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                onPressed: () => provider
                                                    .rejectLoan(loan.id),
                                                icon: const Icon(Icons.close,
                                                    size: 18),
                                                label: Text(l10n.reject),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () => provider
                                                    .approveLoan(loan.id),
                                                icon: const Icon(
                                                    Icons.check_circle_outline,
                                                    size: 18),
                                                label: Text(l10n.approve),
                                              ),
                                            ),
                                          ] else if (loan.status ==
                                              LoanStatus.approved)
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () => provider
                                                    .disburseLoan(loan.id),
                                                icon: const Icon(
                                                    Icons.paid_outlined,
                                                    size: 18),
                                                label: Text(l10n.disburse),
                                              ),
                                            )
                                          else if (loan.status ==
                                              LoanStatus.active)
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () => Navigator.of(
                                                        context)
                                                    .push(
                                                  MaterialPageRoute<void>(
                                                    builder: (_) =>
                                                        LoanDetailScreen(
                                                            loanId: loan.id),
                                                  ),
                                                ),
                                                icon: const Icon(
                                                    Icons.payments_outlined,
                                                    size: 18),
                                                label:
                                                    Text(l10n.recordRepayment),
                                              ),
                                            ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _showRequestSheet() {
    final context = this.context;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _LoanRequestSheet(),
    );
  }
}

/// The new-loan request form: product + term + guarantors, with a live quote
/// preview and eligibility gate computed from the same rules as the backend.
class _LoanRequestSheet extends StatefulWidget {
  @override
  State<_LoanRequestSheet> createState() => _LoanRequestSheetState();
}

class _LoanRequestSheetState extends State<_LoanRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  late final LoansProvider _loans;
  late final MembersProvider _members;
  late final Session _session;
  late final AppLocalizations _l10n;

  Member? _selectedMember;
  LoanProduct? _product;
  int _termMonths = 1;
  Member? _guarantor1;
  Member? _guarantor2;

  LoanQuote? _quote;
  LoanEligibilityResult? _eligibility;
  bool _checking = false;

  bool get _isMemberSelfService => !_session.isAdmin;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context);
    _loans = context.read<LoansProvider>();
    _members = context.read<MembersProvider>();
    _session = context.read<Session>();
    if (_selectedMember == null) {
      _selectedMember = _isMemberSelfService
          ? _members.members
              .where((m) => m.id == _session.account.memberId)
              .firstOrNull
          : _members.members.firstOrNull;
      _product = _loans.loanProducts.firstOrNull;
      _refresh();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final product = _product;
    final member = _selectedMember;
    if (member == null || product == null || amount <= 0) {
      setState(() {
        _quote = null;
        _eligibility = null;
      });
      return;
    }

    setState(() => _checking = true);
    final quote =
        await _loans.quote(product: product, principal: amount, termMonths: _termMonths);
    final eligibility = await _loans.checkEligibility(
      member: member,
      requestedAmount: amount,
      product: product,
      termMonths: _termMonths,
    );
    if (!mounted) return;
    setState(() {
      _quote = quote;
      _eligibility = eligibility;
      _checking = false;
    });
  }

  List<Member> _guarantorCandidates({Member? exclude}) => _members.members
      .where((m) =>
          m.isActive &&
          m.id != _selectedMember?.id &&
          m.id != exclude?.id)
      .toList();

  List<DropdownMenuItem<Member?>> _guarantorItems({Member? exclude}) => [
        DropdownMenuItem<Member?>(value: null, child: Text(_l10n.guarantorNone)),
        ..._guarantorCandidates(exclude: exclude)
            .map((m) => DropdownMenuItem<Member?>(value: m, child: Text(m.fullName))),
      ];

  String? _eligibilityError() {
    final verdict = _eligibility?.verdict;
    if (verdict == null || verdict == LoanEligibility.ok) return null;
    return switch (verdict) {
      LoanEligibility.belowMinimum => _l10n.loanBelowMinimum,
      LoanEligibility.exceedsMultiple => _l10n.loanEligibilityError,
      LoanEligibility.alreadyOwing => _l10n.loanEligibilityOpen,
      LoanEligibility.memberInactive => _l10n.loanMemberInactive,
      LoanEligibility.membershipTooShort => _l10n.loanMembershipTooShort,
      LoanEligibility.termExceedsMax => _l10n.loanTermTooLong,
      LoanEligibility.ok => null,
    };
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountController.text) ?? 0;
    final ok = await _loans.requestLoan(
      member: _selectedMember!,
      principal: amount,
      repaymentDays: _termMonths * 30,
      product: _product,
      termMonths: _termMonths,
      guarantorMemberIds: [
        if (_guarantor1 != null) _guarantor1!.id,
        if (_guarantor2 != null) _guarantor2!.id,
      ],
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final products = _loans.loanProducts
        .where((p) => p.isActive)
        .toList();
    final maxTerm = _product?.maxTermMonths ?? 12;
    if (_termMonths > maxTerm) _termMonths = maxTerm;
    final quote = _quote;
    final eligible = _eligibility?.isOk ?? false;
    final error = _eligibilityError();
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_l10n.newLoanRequest,
                  style: AppFonts.displayFont(
                      22, FontWeight.w700,
                      color: AppColors.ink)),
              const SizedBox(height: 4),
              Text(_isMemberSelfService ? _l10n.loanSelfRequestHint : '',
                  style: AppFonts.body(12, FontWeight.w400,
                      color: AppColors.inkSoft)),
              const SizedBox(height: 16),
              DropdownButtonFormField<Member>(
                value: _selectedMember,
                decoration: InputDecoration(labelText: _l10n.member),
                items: _members.members
                    .map((m) => DropdownMenuItem(
                        value: m, child: Text(m.fullName)))
                    .toList(),
                onChanged: _isMemberSelfService
                    ? null
                    : (v) => setState(() {
                          _selectedMember = v;
                          _guarantor1 = null;
                          _guarantor2 = null;
                        }),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<LoanProduct>(
                value: _product,
                decoration: InputDecoration(
                  labelText: _l10n.loanProduct,
                  helperText: _l10n.loanProductHelper,
                ),
                items: products.isEmpty
                    ? [
                        DropdownMenuItem<LoanProduct>(
                          value: null,
                          child: Text(_l10n.noProductsYet),
                        )
                      ]
                    : products
                        .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text('${p.name} (${p.interestRate}%)')))
                        .toList(),
                onChanged: (v) => setState(() {
                  _product = v;
                  if (_termMonths > (v?.maxTermMonths ?? 12)) {
                    _termMonths = 1;
                  }
                }),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _l10n.loanAmount,
                  helperText: _l10n.interestRateHelper(
                      _product?.interestRate.toString() ??
                          _loans.interestRate.toString()),
                  errorText: error,
                ),
                validator: (v) => Validators.positiveNumber(v,
                    label: _l10n.loanAmount),
                onChanged: (_) => _refresh(),
              ),
              if (_eligibility?.maxAllowed != null) ...[
                const SizedBox(height: 2),
                Text(
                  _l10n.loanMaxAllowedHint(Formatters.money(
                      _eligibility!.maxAllowed)),
                  style: AppFonts.body(12, FontWeight.w500,
                      color: AppColors.forest),
                ),
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _termMonths,
                decoration: InputDecoration(labelText: _l10n.loanTermMonths),
                items: List.generate(maxTerm, (i) => i + 1)
                    .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(_l10n.monthsPeriod(m))))
                    .toList(),
                onChanged: (v) => setState(() {
                  _termMonths = v!;
                  _refresh();
                }),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Member?>(
                value: _guarantor1,
                decoration: InputDecoration(
                  labelText: '${_l10n.guarantors} (1/2)',
                  helperText: _l10n.guarantorHint,
                ),
                items: _guarantorItems(exclude: _guarantor2),
                onChanged: (v) => setState(() => _guarantor1 = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Member?>(
                value: _guarantor2,
                decoration: InputDecoration(labelText: '${_l10n.guarantors} (2/2)'),
                items: _guarantorItems(exclude: _guarantor1),
                onChanged: (v) => setState(() => _guarantor2 = v),
              ),
              const SizedBox(height: 12),
              if (_checking)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.all(8),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ))
              else if (quote != null) ...[
                _QuoteCard(quote: quote, l10n: _l10n),
              ],
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: (eligible && quote != null && amount > 0)
                    ? _submit
                    : null,
                icon: const Icon(Icons.send_outlined),
                label: Text(_l10n.submitRequest),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Live quote preview card: installment, interest, total payable, method.
class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote, required this.l10n});

  final LoanQuote quote;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final method = quote.method == LoanInterestMethod.flat
        ? l10n.quoteMethodFlat
        : l10n.quoteMethodReducing;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.quoteTitle,
                  style: AppFonts.body(13, FontWeight.w700,
                      color: AppColors.forestDeep)),
              StatusBadge(label: method, color: AppColors.forest),
            ],
          ),
          const SizedBox(height: 10),
          _row(l10n.quoteMonthlyInstallment,
              Formatters.money(quote.monthlyInstallment)),
          _row(l10n.quoteTotalInterest,
              Formatters.money(quote.totalInterest)),
          _row(l10n.quoteTotalPayable,
              Formatters.money(quote.totalPayable)),
          _row(l10n.quoteInstallments(quote.schedule.length), ''),
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

/// Repayment progress as a gradient bar: forest when on track, gold→clay when
/// the loan is overdue — health at a glance before the label is read.
class _GradientProgress extends StatelessWidget {
  const _GradientProgress({required this.value, required this.healthy});

  final double value;
  final bool healthy;

  @override
  Widget build(BuildContext context) {
    final colors = healthy
        ? [AppColors.forest, AppColors.forestLight]
        : [AppColors.gold, AppColors.clay];

    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                Container(width: constraints.maxWidth, color: AppColors.line),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: value.clamp(0.0, 1.0),
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: colors,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
