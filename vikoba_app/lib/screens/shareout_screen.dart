import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/data/app_config.dart';
import '../core/domain/vizoba_calc.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../l10n/app_localizations.dart';
import '../providers/loans_provider.dart';
import '../providers/members_provider.dart';
import '../widgets/hero_card.dart';
import '../widgets/kitenge_thread.dart';

/// Cycle-end payout preview: each member's savings + proportional interest.
///
/// Leads with a gold-gradient hero (the one screen where gold, not forest,
/// carries the "prosperity" message).
class ShareOutScreen extends StatelessWidget {
  const ShareOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final membersProvider = context.watch<MembersProvider>();
    final loansProvider = context.watch<LoansProvider>();

    final members = membersProvider.members;
    final results = VikobaCalc.calculateShareOut(
      members,
      loansProvider.totalInterestEarned,
    );
    final grandTotal = results.fold(0.0, (sum, r) => sum + r.totalPayout);
    final totalSavings =
        members.fold<double>(0, (sum, m) => sum + m.totalContributed);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appBarShareOut)),
      body: Column(
        children: [
          const KitengeThread(),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Text(
                      l10n.noSharesYet,
                      style: AppFonts.body(14, FontWeight.w400,
                          color: AppColors.inkSoft),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      HeroCard(
                        gold: true,
                        title: l10n.totalPayableToMembers,
                        value: Formatters.money(grandTotal),
                        chips: [
                          HeroChip(
                            icon: Icons.groups_outlined,
                            label: l10n.activeMembers,
                            value: '${members.length}',
                          ),
                          HeroChip(
                            icon: Icons.savings_outlined,
                            label: l10n.savings,
                            value: Formatters.money(totalSavings),
                          ),
                          HeroChip(
                            icon: Icons.trending_up,
                            label: l10n.interestEarned,
                            value: Formatters.money(
                                loansProvider.totalInterestEarned),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.savingsPoolComposition,
                                  style: AppFonts.body(15, FontWeight.w700)),
                              const SizedBox(height: 12),
                              Semantics(
                                label: l10n.savingsPoolComposition,
                                child: SizedBox(
                                  height: 200,
                                  child: PieChart(
                                    PieChartData(
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 42,
                                      sections: results
                                          .where(
                                              (r) => r.member.totalShares > 0)
                                          .toList()
                                          .asMap()
                                          .entries
                                          .map((entry) =>
                                              PieChartSectionData(
                                                value: entry.value.member
                                                    .totalShares
                                                    .toDouble(),
                                                color: kChartPalette[
                                                    entry.key %
                                                        kChartPalette.length],
                                                radius: 64,
                                                title:
                                                    '${(entry.value.shareProportion * 100).toStringAsFixed(0)}%',
                                                titleStyle: AppFonts.body(11,
                                                    FontWeight.w700,
                                                    color: Colors.white),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(l10n.perMemberBreakdown,
                          style: AppFonts.body(15, FontWeight.w700)),
                      const SizedBox(height: 10),
                      ...results.map((r) => Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(r.member.fullName,
                                          style: AppFonts.body(
                                              14.5, FontWeight.w700)),
                                      Text(
                                        l10n.ofPool((r.shareProportion * 100)
                                            .toStringAsFixed(1)),
                                        style: AppFonts.body(12,
                                                FontWeight.w500,
                                                color: AppColors.inkSoft),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _row(l10n.savings, Formatters.money(r.savings)),
                                  _row(l10n.interestShare,
                                      Formatters.money(r.interestShare)),
                                  const Divider(height: 16),
                                  _row(l10n.totalPayout,
                                      Formatters.money(r.totalPayout),
                                      bold: true),
                                ],
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

  Widget _row(String label, String value, {bool bold = false}) {
    final color =
        bold ? AppColors.ink : AppColors.inkSoft;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppFonts.body(
                bold ? 14 : 13,
                bold ? FontWeight.w700 : FontWeight.w500,
                color: color,
              )),
          Text(value,
              style: AppFonts.body(
                bold ? 14 : 13,
                bold ? FontWeight.w800 : FontWeight.w600,
              )),
        ],
      ),
    );
  }
}