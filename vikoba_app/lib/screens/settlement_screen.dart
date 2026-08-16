import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/domain/vizoba_calc.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../l10n/app_localizations.dart';
import '../models/loan.dart';
import '../providers/loans_provider.dart';
import '../providers/members_provider.dart';
import '../widgets/hero_card.dart';
import '../widgets/kitenge_thread.dart';
import '../widgets/status_badge.dart';

/// Cycle-end settlement: locks the records and marks the total payout for
/// disbursement. Leads with the gold prosperity hero and a pre-close checklist.
class SettlementScreen extends StatefulWidget {
  const SettlementScreen({super.key});

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  bool _locked = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final membersProvider = context.watch<MembersProvider>();
    final loansProvider = context.watch<LoansProvider>();

    final results = VikobaCalc.calculateShareOut(
      membersProvider.members,
      loansProvider.totalInterestEarned,
    );
    final grandTotal = results.fold(0.0, (sum, r) => sum + r.totalPayout);
    final openLoans = loansProvider.loans
        .where((l) =>
            l.status != LoanStatus.repaid && l.status != LoanStatus.rejected)
        .length;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settlement)),
      body: Column(
        children: [
          const KitengeThread(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                HeroCard(
                  gold: true,
                  title: l10n.totalDisbursed,
                  value: Formatters.money(grandTotal),
                  chips: [
                    HeroChip(
                      icon: Icons.verified_outlined,
                      label: l10n.readyForDisbursement,
                      value: '',
                    ),
                    HeroChip(
                      icon: Icons.groups_outlined,
                      label: l10n.activeMembers,
                      value: '${membersProvider.activeCount}',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.eligibilityCheck,
                            style: AppFonts.body(15, FontWeight.w700)),
                        const SizedBox(height: 12),
                        _CheckRow(
                          label: l10n.allLoansSettled,
                          done: openLoans == 0,
                        ),
                        _CheckRow(
                          label: l10n.calculationsVerified,
                          done: true,
                        ),
                        _CheckRow(
                          label: l10n.finalReportGenerated,
                          done: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_outlined,
                            color: AppColors.clay, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.warningTitle,
                                  style: AppFonts.body(
                                      14, FontWeight.w700,
                                      color: AppColors.clay)),
                              const SizedBox(height: 2),
                              Text(l10n.warningBody,
                                  style: AppFonts.body(12.5,
                                      FontWeight.w400,
                                      color: AppColors.inkSoft)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_locked)
                  _LockedBanner(l10n: l10n)
                else
                  FilledButton.icon(
                    onPressed: () => setState(() => _locked = true),
                    icon: const Icon(Icons.lock_outline, size: 18),
                    label: Text(l10n.lockAndDisburse),
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(
                          content: Text(l10n.pdfReport),
                          duration: const Duration(seconds: 2),
                        )),
                        icon: const Icon(Icons.description_outlined, size: 18),
                        label: Text(l10n.pdfReport),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(
                          content: Text(l10n.printReceipts),
                          duration: const Duration(seconds: 2),
                        )),
                        icon: const Icon(Icons.print_outlined, size: 18),
                        label: Text(l10n.printReceipts),
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
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: done ? AppColors.forest : AppColors.inkSoft,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppFonts.body(13.5, FontWeight.w600,
                color: done ? AppColors.ink : AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}

class _LockedBanner extends StatelessWidget {
  const _LockedBanner({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.forest.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.forest),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.forest, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.settlementComplete,
                    style: AppFonts.body(14, FontWeight.w700)),
                const SizedBox(height: 2),
                Text(l10n.cycleClosedBody,
                    style: AppFonts.body(12, FontWeight.w400,
                        color: AppColors.inkSoft)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusBadge(label: l10n.disbursed, color: AppColors.statusOk),
        ],
      ),
    );
  }
}
