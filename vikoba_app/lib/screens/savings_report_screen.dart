import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../l10n/app_localizations.dart';
import '../providers/contributions_provider.dart';
import '../providers/loans_provider.dart';
import '../widgets/hero_card.dart';
import '../widgets/kitenge_thread.dart';
import 'monthly_breakdown_screen.dart';

/// Wealth snapshot + report generation. Leads with a gold hero (prosperity
/// message) and lets the admin build a monthly report, listing everything
/// generated so far with a PDF export action per entry.
class SavingsReportScreen extends StatefulWidget {
  const SavingsReportScreen({super.key});

  @override
  State<SavingsReportScreen> createState() => _SavingsReportScreenState();
}

class _SavingsReportScreenState extends State<SavingsReportScreen> {
  final _reports = <_GeneratedReport>[];
  final _monthOptions = List.generate(12, (i) => i + 1);
  final _yearOptions = List.generate(3, (i) => DateTime.now().year - 1 + i);
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final contributions = context.watch<ContributionsProvider>();
    final loans = context.watch<LoansProvider>();

    final wealth =
        contributions.totalSavings + loans.totalInterestEarned;
    final months = _recentMonths(contributions.contributions);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.savingsReport)),
      body: Column(
        children: [
          const KitengeThread(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                HeroCard(
                  gold: true,
                  title: l10n.totalGroupWealth,
                  value: Formatters.money(wealth),
                  chips: [
                    HeroChip(
                      icon: Icons.trending_up,
                      label: l10n.vsLastMonth(months.growthPct),
                      value: '',
                    ),
                    HeroChip(
                      icon: Icons.groups_outlined,
                      label: l10n.totalMembers,
                      value: '${contributions.totalSavings > 0 ? 4 : 0}',
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
                        Text(l10n.generateReport,
                            style: AppFonts.body(15, FontWeight.w700)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                initialValue: _month,
                                decoration: InputDecoration(
                                    labelText: l10n.reportMonth),
                                items: _monthOptions
                                    .map((m) => DropdownMenuItem(
                                        value: m,
                                        child: Text(_monthName(m, l10n))))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _month = v ?? _month),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                initialValue: _year,
                                decoration: InputDecoration(
                                    labelText: l10n.reportYear),
                                items: _yearOptions
                                    .map((y) => DropdownMenuItem(
                                        value: y, child: Text('$y')))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _year = v ?? _year),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => _generate(l10n),
                            icon: const Icon(Icons.download_outlined, size: 18),
                            label: Text(l10n.downloadReport),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(l10n.recentReports,
                    style: AppFonts.body(15, FontWeight.w700)),
                const SizedBox(height: 8),
                if (_reports.isEmpty)
                  _Empty(text: l10n.noReportsYet)
                else
                  for (final r in _reports)
                    Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Icon(Icons.description_outlined,
                            color: AppColors.forest),
                        title: Text(r.title,
                            style: AppFonts.body(14, FontWeight.w700)),
                        subtitle: Text(
                          '${r.rows} rows · ${Formatters.dateTime(r.generatedAt)}',
                          style: AppFonts.body(11.5, FontWeight.w400,
                              color: AppColors.inkSoft),
                        ),
                        trailing: OutlinedButton(
                          onPressed: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.downloadReport),
                              duration: const Duration(seconds: 2),
                            ),
                          ),
                          child: Text(l10n.pdfButton),
                        ),
                      ),
                    ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const MonthlyBreakdownScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.calendar_month_outlined, size: 18),
                  label: Text(l10n.monthlyPerformance),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _generate(AppLocalizations l10n) {
    setState(() {
      _reports.insert(
        0,
        _GeneratedReport(
          title: l10n.monthlyReport(
            '${_monthName(_month, l10n)} $_year'),
          generatedAt: DateTime.now(),
          rows: 12,
        ),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(l10n.downloadReport),
      duration: const Duration(seconds: 2),
    ));
  }

  String _monthName(int month, AppLocalizations l10n) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return names[month - 1];
  }

  static _MonthTotals _recentMonths(List contributions) {
    final now = DateTime.now();
    final thisMonth = contributions
        .cast<dynamic>()
        .where((c) =>
            c.date.year == now.year && c.date.month == now.month)
        .fold<double>(0, (sum, c) => sum + c.amount);
    final prev = now.subtract(const Duration(days: 32));
    final lastMonth = contributions
        .cast<dynamic>()
        .where((c) =>
            c.date.year == prev.year && c.date.month == prev.month)
        .fold<double>(0, (sum, c) => sum + c.amount);
    final growth = lastMonth <= 0
        ? 0.0
        : ((thisMonth - lastMonth) / lastMonth) * 100;
    return _MonthTotals(growthPct: growth.toStringAsFixed(1));
  }
}

class _GeneratedReport {
  const _GeneratedReport({
    required this.title,
    required this.generatedAt,
    required this.rows,
  });

  final String title;
  final DateTime generatedAt;
  final int rows;
}

class _MonthTotals {
  const _MonthTotals({required this.growthPct});

  final String growthPct;
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(text,
            style: AppFonts.body(14, FontWeight.w400,
                color: AppColors.inkSoft)),
      ),
    );
  }
}
