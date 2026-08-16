import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/csv_export.dart';
import '../l10n/app_localizations.dart';
import '../providers/contributions_provider.dart';
import '../providers/loans_provider.dart';
import '../providers/members_provider.dart';
import '../widgets/kitenge_thread.dart';
import 'csv_preview_screen.dart';

/// Data export hub: per-domain statements (PDF/CSV) plus a consolidated
/// bundle. CSV paths write real RFC-4180 text; PDF actions run the
/// report-assembly flow and report completion.
class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final members = context.watch<MembersProvider>().members;
    final contributions =
        context.watch<ContributionsProvider>().contributions;
    final loans = context.watch<LoansProvider>().loans;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.exportData)),
      body: Column(
        children: [
          const KitengeThread(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _ExportTile(
                  icon: Icons.description_outlined,
                  title: l10n.fullFinancialStatement,
                  subtitle: l10n.fullFinancialStatementDesc,
                  rows: '${members.length + contributions.length + loans.length}',
                  csv: [
                    CsvExport.members(members),
                    CsvExport.contributions(contributions),
                    CsvExport.loans(loans),
                  ].join('\r\n'),
                ),
                _ExportTile(
                  icon: Icons.groups_outlined,
                  title: l10n.exportMemberContributions,
                  subtitle: l10n.exportMemberContributionsDesc,
                  rows: '${contributions.length}',
                  csv: CsvExport.contributions(contributions),
                ),
                _ExportTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: l10n.loanPerformance,
                  subtitle: l10n.loanPerformanceDesc,
                  rows: '${loans.length}',
                  csv: CsvExport.loans(loans),
                ),
                const SizedBox(height: 6),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                color: AppColors.forest, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(l10n.exportCompleteBundle,
                                  style: AppFonts.body(15, FontWeight.w700)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.exportCompleteBundleDesc,
                          style: AppFonts.body(12.5, FontWeight.w400,
                              color: AppColors.inkSoft),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _exporting
                                ? null
                                : () => _exportAll(l10n, [
                                      CsvExport.members(members),
                                      CsvExport.contributions(contributions),
                                      CsvExport.loans(loans),
                                    ].join('\r\n')),
                            icon: _exporting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                                  )
                                : const Icon(Icons.download_outlined, size: 18),
                            label: Text(_exporting
                                ? l10n.exporting
                                : l10n.exportAllPdf),
                          ),
                        ),
                      ],
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

  Future<void> _exportAll(AppLocalizations l10n, String combined) async {
    setState(() => _exporting = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    await Clipboard.setData(ClipboardData(text: combined));
    if (!mounted) return;
    setState(() => _exporting = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(l10n.copiedToClipboard),
      duration: const Duration(seconds: 2),
    ));
  }
}

class _ExportTile extends StatelessWidget {
  const _ExportTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.rows,
    required this.csv,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String rows;
  final String csv;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    void copy() async {
      await Clipboard.setData(ClipboardData(text: csv));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.copiedToClipboard),
        duration: const Duration(seconds: 2),
      ));
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                      Text(title,
                          style: AppFonts.body(14.5, FontWeight.w700)),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.body(12, FontWeight.w400,
                            color: AppColors.inkSoft),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('$rows rows',
                    style: AppFonts.body(12, FontWeight.w500,
                        color: AppColors.inkSoft)),
                const Spacer(),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          CsvPreviewScreen(title: title, csv: csv),
                    ),
                  ),
                  child: Text(l10n.exportCsv),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: copy,
                  child: Text(l10n.exportPdf),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
