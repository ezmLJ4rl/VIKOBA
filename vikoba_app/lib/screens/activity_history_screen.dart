import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../l10n/app_localizations.dart';
import '../models/loan.dart';
import '../providers/contributions_provider.dart';
import '../providers/loans_provider.dart';
import '../providers/meetings_provider.dart';
import '../widgets/kitenge_thread.dart';

/// Timeline of group operations: contributions, loan events and meetings,
/// grouped by day, with an alerts card at the top for items needing action.
class ActivityHistoryScreen extends StatelessWidget {
  const ActivityHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final contributions = context.watch<ContributionsProvider>().contributions;
    final loans = context.watch<LoansProvider>().loans;
    final meetings = context.watch<MeetingsProvider>().meetings;

    final entries = _buildEntries(l10n, contributions, loans, meetings);
    final thisMonth = entries
        .where((e) =>
            e.date.year == DateTime.now().year &&
            e.date.month == DateTime.now().month)
        .length;

    final alerts = <Widget>[
      for (final l in loans)
        if (l.isOverdue)
          _AlertRow(
            icon: Icons.warning_amber_outlined,
            text: '${l.memberName} — ${l10n.overdue}',
            color: AppColors.statusAttention,
          ),
      for (final l in loans)
        if (l.status == LoanStatus.pending)
          _AlertRow(
            icon: Icons.schedule_outlined,
            text: '${l.memberName} — ${l10n.pendingApprovals}',
            color: AppColors.statusPending,
          ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.activityHistory)),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.actionsThisMonth,
                            style: AppFonts.body(14, FontWeight.w700)),
                        Text('$thisMonth',
                            style: AppFonts.displayFont(26, FontWeight.w600,
                                color: AppColors.forest)),
                      ],
                    ),
                  ),
                ),
                if (alerts.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(l10n.alerts,
                      style: AppFonts.body(15, FontWeight.w700)),
                  const SizedBox(height: 8),
                  ...alerts,
                ],
                const SizedBox(height: 14),
                if (entries.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(l10n.activityNoData,
                              style: AppFonts.body(14, FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(l10n.activityNoDataBody,
                              textAlign: TextAlign.center,
                              style: AppFonts.body(12, FontWeight.w400,
                                  color: AppColors.inkSoft)),
                        ],
                      ),
                    ),
                  )
                else
                  ..._grouped(entries, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _grouped(List<_ActivityEntry> entries, AppLocalizations l10n) {
    final now = DateTime.now();
    String groupOf(DateTime d) {
      final day = DateTime(d.year, d.month, d.day);
      final today = DateTime(now.year, now.month, now.day);
      final diff = today.difference(day).inDays;
      if (diff == 0) return l10n.today;
      if (diff == 1) return l10n.yesterday;
      return Formatters.date(d);
    }

    final groups = <String, List<_ActivityEntry>>{};
    for (final e in entries) {
      groups.putIfAbsent(groupOf(e.date), () => []).add(e);
    }

    return groups.entries.map((g) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(g.key,
                style: AppFonts.body(13, FontWeight.w700,
                    color: AppColors.inkSoft)),
          ),
          for (final e in g.value)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: e.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(e.icon, color: e.color, size: 20),
                ),
                title: Text(e.title,
                    style: AppFonts.body(14, FontWeight.w700)),
                subtitle: Text(
                  '${e.subtitle} · ${Formatters.dateTime(e.date)}',
                  style: AppFonts.body(11.5, FontWeight.w400,
                      color: AppColors.inkSoft),
                ),
                trailing: e.amount != null
                    ? Text(Formatters.money(e.amount!),
                        style: AppFonts.body(13, FontWeight.w700))
                    : null,
              ),
            ),
          const SizedBox(height: 6),
        ],
      );
    }).toList();
  }

  List<_ActivityEntry> _buildEntries(
    AppLocalizations l10n,
    List contributions,
    List loans,
    List meetings,
  ) {
    final entries = <_ActivityEntry>[];

    for (final c in contributions.cast<dynamic>()) {
      entries.add(_ActivityEntry(
        date: c.date,
        icon: Icons.payments_outlined,
        color: AppColors.forest,
        title: '${c.memberName} — ${l10n.activityContribution}',
        subtitle: '${c.sharesBought} hisa',
        amount: c.amount,
      ));
    }

    for (final l in loans.cast<dynamic>()) {
      if (l.status == LoanStatus.active) {
        entries.add(_ActivityEntry(
          date: l.disbursedAt ?? l.issuedDate,
          icon: Icons.paid_outlined,
          color: AppColors.stone,
          title: '${l.memberName} — ${l10n.loanDisbursed}',
          subtitle: l.id,
          amount: l.principal,
        ));
      } else if (l.status == LoanStatus.repaid) {
        entries.add(_ActivityEntry(
          date: l.dueDate,
          icon: Icons.check_circle_outline,
          color: AppColors.forest,
          title: '${l.memberName} — ${l10n.loanRepaid}',
          subtitle: l.id,
          amount: l.totalPayable,
        ));
      }
    }

    for (final m in meetings.cast<dynamic>()) {
      entries.add(_ActivityEntry(
        date: m.date,
        icon: Icons.event_note,
        color: AppColors.goldDeep,
        title: l10n.activityMeeting,
        subtitle: m.agenda,
      ));
    }

    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }
}

/// A single row on the activity timeline.
class _ActivityEntry {
  const _ActivityEntry({
    required this.date,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.amount,
  });

  final DateTime date;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final double? amount;
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: color, size: 20),
        title: Text(text, style: AppFonts.body(13, FontWeight.w600)),
      ),
    );
  }
}
