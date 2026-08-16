import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../l10n/app_localizations.dart';
import '../providers/contributions_provider.dart';
import '../providers/loans_provider.dart';
import '../providers/members_provider.dart';
import '../widgets/hero_card.dart';
import '../widgets/kitenge_thread.dart';
import '../widgets/status_badge.dart';

/// Monthly performance deep-dive: contribution compliance (on-time vs late),
/// capital growth vs the previous month, and the current top savers.
class MonthlyBreakdownScreen extends StatelessWidget {
  const MonthlyBreakdownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final contributions = context.watch<ContributionsProvider>();
    final loans = context.watch<LoansProvider>();
    final members = context.watch<MembersProvider>().members;

    final now = DateTime.now();
    final thisMonthContribs = contributions.contributions
        .where((c) =>
            c.date.year == now.year && c.date.month == now.month)
        .toList();
    final onTime = thisMonthContribs
        .where((c) => c.date.day <= 7)
        .length;
    final late = thisMonthContribs.length - onTime;

    final prev = now.subtract(const Duration(days: 32));
    final thisTotal = thisMonthContribs.fold<double>(
        0, (sum, c) => sum + c.amount);
    final lastTotal = contributions.contributions
        .where((c) =>
            c.date.year == prev.year && c.date.month == prev.month)
        .fold<double>(0, (sum, c) => sum + c.amount);
    final growth = lastTotal <= 0
        ? '0.0'
        : ((thisTotal - lastTotal) / lastTotal * 100).toStringAsFixed(1);

    final wealth = contributions.totalSavings + loans.totalInterestEarned;
    final topSavers = [...members]
      ..sort((a, b) => b.totalShares.compareTo(a.totalShares));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.monthlyPerformance)),
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
                      label: l10n.momGrowth(growth),
                      value: '',
                    ),
                    HeroChip(
                      icon: Icons.savings_outlined,
                      label: l10n.compliance,
                      value:
                          '$onTime/${onTime + late}',
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
                        Text(l10n.compliance,
                            style: AppFonts.body(15, FontWeight.w700)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatBox(
                                label: l10n.onTime,
                                value: '$onTime',
                                color: AppColors.statusOk,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatBox(
                                label: l10n.late,
                                value: '$late',
                                color: AppColors.statusPending,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: onTime + late == 0
                                ? 0
                                : onTime / (onTime + late),
                            minHeight: 8,
                            backgroundColor: AppColors.line,
                            color: AppColors.forest,
                          ),
                        ),
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
                        Text(l10n.capitalGrowth,
                            style: AppFonts.body(15, FontWeight.w700)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Formatters.money(thisTotal),
                              style: AppFonts.displayFont(
                                  24, FontWeight.w600,
                                  color: AppColors.forest),
                            ),
                            StatusBadge(
                              label: l10n.momGrowth(growth),
                              color: (double.tryParse(growth) ?? 0) >= 0
                                  ? AppColors.statusOk
                                  : AppColors.statusAttention,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.quarterlyReport(now.month ~/ 3 + 1),
                          style: AppFonts.body(12, FontWeight.w500,
                              color: AppColors.inkSoft),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(l10n.topSavers,
                    style: AppFonts.body(15, FontWeight.w700)),
                const SizedBox(height: 8),
                for (var i = 0; i < topSavers.take(3).length; i++)
                  Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            AppColors.goldSoft.withValues(alpha: 0.6),
                        foregroundColor: AppColors.forest,
                        child: Text('${i + 1}',
                            style: AppFonts.body(13, FontWeight.w800)),
                      ),
                      title: Text(topSavers[i].fullName,
                          style: AppFonts.body(14, FontWeight.w700)),
                      subtitle: Text(
                        i == 0
                            ? l10n.consistentSaver
                            : i == 1
                                ? l10n.earlyPayer
                                : '${topSavers[i].totalShares} hisa',
                        style: AppFonts.body(11.5, FontWeight.w400,
                            color: AppColors.inkSoft),
                      ),
                      trailing: Text(
                        '${topSavers[i].totalShares}',
                        style: AppFonts.body(14, FontWeight.w700,
                            color: AppColors.forest),
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(
                          content: Text(l10n.pdfReport),
                          duration: const Duration(seconds: 2),
                        )),
                        icon: const Icon(Icons.download_outlined, size: 18),
                        label: Text(l10n.pdfButton),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () => ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(
                          content: Text(l10n.shareReport),
                          duration: const Duration(seconds: 2),
                        )),
                        icon: const Icon(Icons.share_outlined, size: 18),
                        label: Text(l10n.shareReport),
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

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: AppFonts.displayFont(22, FontWeight.w600,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: AppFonts.body(12, FontWeight.w600,
                  color: AppColors.ink)),
        ],
      ),
    );
  }
}
