import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../l10n/app_localizations.dart';
import '../models/loan.dart';
import '../providers/loans_provider.dart';
import '../widgets/hero_card.dart';
import '../widgets/kitenge_thread.dart';
import '../widgets/status_badge.dart';
import 'review_loan_screen.dart';

/// Admin loan hub: pending applications needing a decision, plus full loan
/// history. Each pending card routes to the detailed review screen.
class LoanManagementScreen extends StatelessWidget {
  const LoanManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<LoansProvider>();
    final loans = provider.loans;

    final pending = loans
        .where((l) => l.status == LoanStatus.pending)
        .toList();
    final history = loans
        .where((l) => l.status != LoanStatus.pending)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.loanManagement)),
      body: Column(
        children: [
          const KitengeThread(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                HeroCard(
                  title: l10n.pendingApprovals,
                  value: '${pending.length}',
                  chips: [
                    HeroChip(
                      icon: Icons.account_balance_wallet_outlined,
                      label: l10n.loanHistory,
                      value: '${history.length}',
                    ),
                    HeroChip(
                      icon: Icons.schedule_outlined,
                      label: l10n.actionNeeded,
                      value: '${pending.length}',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(l10n.pendingApprovals,
                    style: AppFonts.body(15, FontWeight.w700)),
                const SizedBox(height: 8),
                if (pending.isEmpty)
                  _Empty(text: l10n.noPendingApprovals)
                else
                  for (final l in pending)
                    Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ReviewLoanScreen(loanId: l.id),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(l.memberName,
                                        style: AppFonts.body(
                                            14.5, FontWeight.w700)),
                                    const SizedBox(height: 2),
                                    Text(
                                      Formatters.money(l.principal),
                                      style: AppFonts.body(13,
                                          FontWeight.w600,
                                          color: AppColors.inkSoft),
                                    ),
                                  ],
                                ),
                              ),
                              StatusBadge(
                                label: l10n.pendingApprovals,
                                color: AppColors.statusPending,
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        ReviewLoanScreen(loanId: l.id),
                                  ),
                                ),
                                child: Text(l10n.reviewButton),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                const SizedBox(height: 18),
                Text(l10n.loanHistory,
                    style: AppFonts.body(15, FontWeight.w700)),
                const SizedBox(height: 8),
                if (history.isEmpty)
                  _Empty(text: l10n.noLoansInHistory)
                else
                  for (final l in history)
                    Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(l.memberName,
                            style: AppFonts.body(14, FontWeight.w700)),
                        subtitle: Text(
                          '${l.id} · ${Formatters.money(l.principal)}',
                          style: AppFonts.body(12, FontWeight.w400,
                              color: AppColors.inkSoft),
                        ),
                        trailing: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 130),
                          child: StatusBadge(
                            label: l.statusLabel,
                            color: _statusColor(l),
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(Loan l) {
    if (l.isOverdue) return AppColors.statusAttention;
    return switch (l.status) {
      LoanStatus.approved => AppColors.statusPending,
      LoanStatus.active || LoanStatus.repaid => AppColors.statusOk,
      LoanStatus.rejected => AppColors.statusAttention,
      LoanStatus.pending => AppColors.statusPending,
    };
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(text,
            style: AppFonts.body(14, FontWeight.w400,
                color: AppColors.inkSoft)),
      ),
    );
  }
}
