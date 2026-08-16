import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/utils/csv_export.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/contributions_provider.dart';
import '../providers/loans_provider.dart';
import '../providers/members_provider.dart';
import '../widgets/hero_card.dart';
import '../widgets/kitenge_thread.dart';
import 'csv_preview_screen.dart';

/// Group ledger exports. Each section previews its row count and copies the
/// matching CSV to the clipboard for pasting into Excel / sheets.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final members = context.watch<MembersProvider>().members;
    final contributions =
        context.watch<ContributionsProvider>().contributions;
    final loans = context.watch<LoansProvider>().loans;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appBarReports)),
      body: Column(
        children: [
          const KitengeThread(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                HeroCard(
                  title: l10n.reportReady,
                  value: '${members.length + contributions.length + loans.length}',
                  chips: [
                    HeroChip(
                      icon: Icons.groups_outlined,
                      label: l10n.reportMembers,
                      value: '${members.length}',
                    ),
                    HeroChip(
                      icon: Icons.payments_outlined,
                      label: l10n.reportContributions,
                      value: '${contributions.length}',
                    ),
                    HeroChip(
                      icon: Icons.account_balance_wallet_outlined,
                      label: l10n.reportLoans,
                      value: '${loans.length}',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.reportsSubtitle,
                  style: AppFonts.body(13, FontWeight.w400,
                      color: AppColors.inkSoft),
                ),
                const SizedBox(height: 16),
                _ReportTile(
                  icon: Icons.groups_outlined,
                  title: l10n.reportMembers,
                  count: members.length,
                  csv: CsvExport.members(members),
                ),
                const SizedBox(height: 10),
                _ReportTile(
                  icon: Icons.payments_outlined,
                  title: l10n.reportContributions,
                  count: contributions.length,
                  csv: CsvExport.contributions(contributions),
                ),
                const SizedBox(height: 10),
                _ReportTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: l10n.reportLoans,
                  count: loans.length,
                  csv: CsvExport.loans(loans),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({
    required this.icon,
    required this.title,
    required this.count,
    required this.csv,
  });

  final IconData icon;
  final String title;
  final int count;
  final String csv;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: count == 0
            ? null
            : () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        CsvPreviewScreen(title: title, csv: csv),
                  ),
                ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.goldSoft.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: AppColors.forest, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppFonts.body(14.5, FontWeight.w700)),
                  const SizedBox(height: 1),
                  Text(
                    l10n.reportRows(count),
                    style: AppFonts.body(12, FontWeight.w500,
                        color: AppColors.inkSoft),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 120,
              height: 40,
              child: OutlinedButton.icon(
                onPressed: count == 0
                    ? null
                    : () async {
                        await Clipboard.setData(ClipboardData(text: csv));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(l10n.copiedToClipboard),
                          duration: const Duration(seconds: 2),
                        ));
                      },
                icon: const Icon(Icons.copy_all_outlined, size: 16),
                label: Text(l10n.copyCsv),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
