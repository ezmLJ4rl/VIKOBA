import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../l10n/app_localizations.dart';
import '../models/loan.dart';
import '../providers/loans_provider.dart';
import '../providers/members_provider.dart';
import '../widgets/kitenge_thread.dart';
import '../widgets/status_badge.dart';

/// Detailed loan decision screen: member context, the requested figures, an
/// eligibility read-out (savings-to-loan ratio) and approve / reject actions.
class ReviewLoanScreen extends StatelessWidget {
  const ReviewLoanScreen({super.key, required this.loanId});

  final String loanId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<LoansProvider>();
    final members = context.watch<MembersProvider>().members;
    final loan = provider.loans.where((l) => l.id == loanId).firstOrNull;
    if (loan == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reviewApplication)),
        body: const Center(child: Text('')),
      );
    }

    final member =
        members.where((m) => m.id == loan.memberId).firstOrNull;
    final activeLoans = provider.loans
        .where((l) =>
            l.memberId == loan.memberId &&
            l.status == LoanStatus.active)
        .length;
    final savings = member?.totalContributed ?? 0;
    final ratio = loan.principal <= 0
        ? 1.0
        : (savings / loan.principal).clamp(0.0, 1.0);
    final guarantors = members
        .where((m) => loan.guarantorMemberIds.contains(m.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reviewApplication)),
      body: Column(
        children: [
          const KitengeThread(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _MemberHeader(
                  name: loan.memberName,
                  phone: member?.phoneNumber ?? '',
                  joined: member?.joinedDate,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.loanRequest,
                            style: AppFonts.body(15, FontWeight.w700)),
                        const SizedBox(height: 12),
                        _row(l10n.requestedAmount,
                            Formatters.money(loan.principal)),
                        _row(l10n.totalToRepay,
                            Formatters.money(loan.totalPayable)),
                        _row(l10n.interestRate,
                            '${loan.interestRate.toStringAsFixed(0)}%'),
                        _row(l10n.purpose, l10n.noPurposeGiven),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.eligibilityCheck,
                            style: AppFonts.body(15, FontWeight.w700)),
                        const SizedBox(height: 12),
                        _row(
                          l10n.savingsToLoanRatio,
                          '${(ratio * 100).toStringAsFixed(0)}%',
                        ),
                        _row(l10n.activeLoans, '$activeLoans'),
                        if (guarantors.isNotEmpty)
                          _row(
                            l10n.guarantors,
                            guarantors.map((g) => g.fullName).join(', '),
                          ),
                        const SizedBox(height: 10),
                        StatusBadge(
                          label: l10n.safe,
                          color: ratio >= 1
                              ? AppColors.statusOk
                              : AppColors.statusPending,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _decide(
                            context, provider, loan.id, reject: true),
                        icon: const Icon(Icons.close, size: 18),
                        label: Text(l10n.rejectLoan),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _decide(
                            context, provider, loan.id, reject: false),
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: Text(l10n.approveLoan),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _decide(BuildContext context, LoansProvider provider,
      String loanId,
      {required bool reject}) async {
    final l10n = AppLocalizations.of(context);
    if (reject) {
      await provider.rejectLoan(loanId);
    } else {
      await provider.approveLoan(loanId);
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(reject ? l10n.rejectedConfirm : l10n.approvedConfirm),
      duration: const Duration(seconds: 2),
    ));
    Navigator.of(context).pop();
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: AppFonts.body(13, FontWeight.w500,
                    color: AppColors.inkSoft)),
            Flexible(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: AppFonts.body(13.5, FontWeight.w700,
                      color: AppColors.ink)),
            ),
          ],
        ),
      );
}

class _MemberHeader extends StatelessWidget {
  const _MemberHeader({required this.name, required this.phone, this.joined});

  final String name;
  final String phone;
  final DateTime? joined;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.goldSoft,
            foregroundColor: AppColors.forest,
            child: Text(
              name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
              style: AppFonts.body(18, FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppFonts.body(16, FontWeight.w700,
                        color: AppColors.cream)),
                const SizedBox(height: 2),
                Text(
                  phone.isEmpty
                      ? (joined != null
                          ? l10n.memberSinceShort(Formatters.date(joined!))
                          : '')
                      : phone,
                  style: AppFonts.body(12.5, FontWeight.w500,
                      color: AppColors.cream.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
          Text(
            l10n.memberSinceShort(
                joined == null ? '' : Formatters.date(joined!)),
            style: AppFonts.body(10.5, FontWeight.w600,
                color: AppColors.cream.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}
