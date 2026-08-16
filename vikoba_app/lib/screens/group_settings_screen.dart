import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state/app_navigation.dart';
import '../core/state/session.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../l10n/app_localizations.dart';
import '../providers/group_settings_provider.dart';
import '../widgets/kitenge_thread.dart';
import '../widgets/status_badge.dart';

/// Group administration: current cycle, contribution + loan rules, member
/// management entry points, and the cycle-end close/archive actions.
class GroupSettingsScreen extends StatelessWidget {
  const GroupSettingsScreen({super.key});

  static const double _minSharesPerMonth = 1;
  static const double _lateFine = 2000;
  static const double _maxMultiplier = 3;
  static const int _maxRepaymentMonths = 12;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<GroupSettingsProvider>();
    final session = context.watch<Session>();

    final cycleStart = DateTime(2026, 1, 1);
    final cycleEnd = cycleStart.add(const Duration(days: 365));
    const durationMonths = 12;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.groupSettings)),
      body: Column(
        children: [
          const KitengeThread(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.currentCycle,
                                style: AppFonts.body(15, FontWeight.w700)),
                            StatusBadge(
                                label: l10n.cycleActive,
                                color: AppColors.statusOk),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _row(l10n.startDate, Formatters.date(cycleStart)),
                        _row(l10n.endDate, Formatters.date(cycleEnd)),
                        _row(l10n.duration,
                            l10n.monthsCount(durationMonths)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _RuleCard(
                  title: l10n.contributionRules,
                  icon: Icons.savings_outlined,
                  children: [
                    _row(l10n.sharePrice, Formatters.money(settings.shareValue)),
                    _row(l10n.minSharesPerMonth,
                        _minSharesPerMonth.toStringAsFixed(0)),
                    _row(l10n.lateFine, Formatters.money(_lateFine)),
                  ],
                ),
                const SizedBox(height: 14),
                _RuleCard(
                  title: l10n.loanRules,
                  icon: Icons.account_balance_wallet_outlined,
                  children: [
                    _row(l10n.interestRate,
                        '${settings.interestRate.toStringAsFixed(0)}%'),
                    _row(l10n.maxMultiplier,
                        '${_maxMultiplier.toStringAsFixed(0)}x'),
                    _row(l10n.maxRepayment,
                        l10n.monthsCount(_maxRepaymentMonths)),
                  ],
                ),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.memberManagement,
                            style: AppFonts.body(15, FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(
                          l10n.manageRoles,
                          style: AppFonts.body(12, FontWeight.w400,
                              color: AppColors.inkSoft),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => context
                                    .read<AppNavigation>()
                                    .goTo(1, PendingAction.addMember),
                                icon: const Icon(Icons.person_add_alt, size: 18),
                                label: Text(l10n.addMemberShort),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _CloseCycleCard(
                  enabled: session.isAdmin,
                  onClose: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(l10n.notTime),
                      duration: const Duration(seconds: 2),
                    ));
                  },
                  onArchive: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(l10n.notTime),
                      duration: const Duration(seconds: 2),
                    ));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: AppFonts.body(13, FontWeight.w500,
                    color: AppColors.inkSoft)),
            Text(value,
                style: AppFonts.body(13.5, FontWeight.w700,
                    color: AppColors.ink)),
          ],
        ),
      );
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({required this.title, required this.icon, required this.children});

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.forest, size: 20),
                const SizedBox(width: 8),
                Text(title, style: AppFonts.body(15, FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _CloseCycleCard extends StatelessWidget {
  const _CloseCycleCard({
    required this.enabled,
    required this.onClose,
    required this.onArchive,
  });

  final bool enabled;
  final VoidCallback onClose;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: enabled ? onClose : null,
                icon: const Icon(Icons.lock_outline, size: 18),
                label: Text(AppLocalizations.of(context).closeCycle),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: enabled ? onArchive : null,
                icon: const Icon(Icons.archive_outlined, size: 18),
                label: Text(AppLocalizations.of(context).archiveData),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
