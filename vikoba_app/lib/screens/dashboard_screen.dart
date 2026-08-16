import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state/app_navigation.dart';
import '../core/state/notifications.dart';
import '../core/state/session.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../l10n/app_localizations.dart';
import '../models/loan.dart';
import '../providers/contributions_provider.dart';
import '../providers/loans_provider.dart';
import '../providers/members_provider.dart';
import '../providers/sync_provider.dart';
import '../widgets/hero_card.dart';
import '../widgets/kitenge_thread.dart';
import '../widgets/status_badge.dart';
import 'account_switcher_sheet.dart';
import 'meetings_screen.dart';
import 'notifications_screen.dart';
import 'reports_screen.dart';
import 'server_sheet.dart';
import 'shareout_screen.dart';

/// Group overview: money-first hero card, quick actions, recent activity and
/// loans needing attention.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final membersProvider = context.watch<MembersProvider>();
    final contributionsProvider = context.watch<ContributionsProvider>();
    final loansProvider = context.watch<LoansProvider>();

    final savings = contributionsProvider.totalSavings;
    final attentionLoans = loansProvider.loans
        .where((l) =>
            l.status == LoanStatus.pending ||
            l.status == LoanStatus.approved ||
            l.isOverdue)
        .toList();

    final session = context.watch<Session>();
    final notifications = context.watch<NotificationsController>();
    final unread = notifications.unreadFor(session.account.memberId);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appBarDashboard),
        actions: [
          _NotificationBell(
            unread: unread,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          _SyncButton(
            onTap: () => showModalBottomSheet<void>(
              context: context,
              builder: (_) => const ServerSheet(),
            ),
          ),
          IconButton(
            tooltip: session.account.roleLabelEn,
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              builder: (_) => const AccountSwitcherSheet(),
            ),
            icon: CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.goldSoft,
              foregroundColor: AppColors.forest,
              child: Text(
                session.account.name.isEmpty
                    ? '?'
                    : session.account.name.substring(0, 1).toUpperCase(),
                style: AppFonts.body(13, FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const KitengeThread(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => Future.wait([
                membersProvider.refresh(),
                loansProvider.refresh(),
              ]),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  HeroCard(
                    title: l10n.totalGroupSavings,
                    value: Formatters.money(savings),
                    chips: [
                      HeroChip(
                        icon: Icons.groups_outlined,
                        label: l10n.activeMembers,
                        value: '${membersProvider.activeCount}',
                      ),
                      HeroChip(
                        icon: Icons.trending_up,
                        label: l10n.interestEarned,
                        value: Formatters.money(
                            loansProvider.totalInterestEarned),
                      ),
                      HeroChip(
                        icon: Icons.account_balance_wallet_outlined,
                        label: l10n.activeLoansValue,
                        value: Formatters.money(
                            loansProvider.totalActiveLoans),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _QuickActions(
                    isAdmin: session.isAdmin,
                    onAddContribution: () => context
                        .read<AppNavigation>()
                        .goTo(2, PendingAction.addContribution),
                    onRequestLoan: () => context
                        .read<AppNavigation>()
                        .goTo(3, PendingAction.addLoanRequest),
                    onAddMember: () => context
                        .read<AppNavigation>()
                        .goTo(1, PendingAction.addMember),
                    onShareOut: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ShareOutScreen(),
                      ),
                    ),
                    onLogMeeting: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MeetingsScreen(),
                      ),
                    ),
                    onReports: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ReportsScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _SectionTitle(l10n.recentContributions),
                  const SizedBox(height: 8),
                  if (contributionsProvider.contributions.isEmpty)
                    _EmptyRow(text: l10n.noContributionsYet)
                  else
                    ...contributionsProvider.contributions.take(3).map((c) =>
                        Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppColors.goldSoft.withValues(alpha: 0.55),
                              foregroundColor: AppColors.forest,
                              child: const Icon(Icons.arrow_downward, size: 18),
                            ),
                            title: Text(c.memberName,
                                style: AppFonts.body(
                                    14.5, FontWeight.w700)),
                            subtitle: Text(l10n.sharesPrefix(c.sharesBought,
                                Formatters.date(c.date))),
                            trailing: Text(
                              Formatters.money(c.amount),
                              style: AppFonts.body(14, FontWeight.w700),
                            ),
                          ),
                        )),
                  const SizedBox(height: 16),
                  _SectionTitle(l10n.loansNeedingAttention),
                  const SizedBox(height: 8),
                  if (attentionLoans.isEmpty)
                    _EmptyRow(text: l10n.nothingNeedsAttention)
                  else
                    ...attentionLoans.map((l) => Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(l.memberName,
                                style: AppFonts.body(15, FontWeight.w700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            subtitle: Text(Formatters.money(l.principal)),
                            trailing: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 140),
                              child: StatusBadge(
                                label: l.isOverdue
                                    ? l10n.overdue
                                    : l.status == LoanStatus.approved
                                        ? l10n.awaitingDisbursement
                                        : l.statusLabel,
                                color: l.isOverdue
                                    ? AppColors.statusAttention
                                    : AppColors.statusPending,
                              ),
                            ),
                          ),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppFonts.body(16, FontWeight.w700, color: AppColors.ink),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Text(text, style: AppFonts.body(14, FontWeight.w400,
          color: AppColors.inkSoft)),
    );
  }
}

/// Cloud with a badge for queued offline changes. Opens the server sheet.
class _SyncButton extends StatelessWidget {
  const _SyncButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sync = context.watch<SyncProvider>();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: AppLocalizations.of(context).syncTitle,
          onPressed: onTap,
          icon: Icon(
            sync.isConfigured
                ? Icons.cloud_done_outlined
                : Icons.cloud_off_outlined,
            size: 24,
          ),
        ),
        if (sync.pendingCount > 0)
          Positioned(
            right: 8,
            top: 7,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${sync.pendingCount}',
                style: AppFonts.body(10, FontWeight.w700)
                    .copyWith(color: AppColors.cream),
              ),
            ),
          ),
      ],
    );
  }
}

/// Bell with an unread dot. Opens the (read-only) notification inbox.
class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.unread, required this.onTap});

  final int unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: AppLocalizations.of(context).notificationsTitle,
          onPressed: onTap,
          icon: const Icon(Icons.notifications_none_outlined, size: 24),
        ),
        if (unread > 0)
          Positioned(
            right: 9,
            top: 8,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: AppColors.clay,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

/// 2x2 grid of large tap targets. Each card pairs an icon, the primary
/// Swahili label and a small English subtitle — never icon alone, never text
/// alone. Fixed height keeps tiles compact and content vertically centred.
typedef _QuickAction = ({
  IconData icon,
  String swahili,
  String english,
  VoidCallback onTap,
});

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.isAdmin,
    required this.onAddContribution,
    required this.onRequestLoan,
    required this.onAddMember,
    required this.onShareOut,
    required this.onLogMeeting,
    required this.onReports,
  });

  final bool isAdmin;
  final VoidCallback onAddContribution;
  final VoidCallback onRequestLoan;
  final VoidCallback onAddMember;
  final VoidCallback onShareOut;
  final VoidCallback onLogMeeting;
  final VoidCallback onReports;

  @override
  Widget build(BuildContext context) {
    // Member accounts keep only the actions they may actually perform
    // (view share-out, request a loan for themselves). Admin-only actions
    // are absent, not dead.
    final actions = <_QuickAction>[
      if (isAdmin)
        (
          icon: Icons.savings_outlined,
          swahili: 'Toa mchango',
          english: 'Add contribution',
          onTap: onAddContribution,
        ),
      (
        icon: Icons.request_quote_outlined,
        swahili: 'Omba mkopo',
        english: 'Request loan',
        onTap: onRequestLoan,
      ),
      if (isAdmin)
        (
          icon: Icons.person_add_alt,
          swahili: 'Ongeza mwanachama',
          english: 'Add member',
          onTap: onAddMember,
        ),
      (
        icon: Icons.pie_chart_outline,
        swahili: 'Gawanya',
        english: 'Share-out',
        onTap: onShareOut,
      ),
      if (isAdmin)
        (
          icon: Icons.event_note,
          swahili: 'Andika kikao',
          english: 'Log meeting',
          onTap: onLogMeeting,
        ),
      if (isAdmin)
        (
          icon: Icons.description_outlined,
          swahili: 'Ripoti',
          english: 'Reports',
          onTap: onReports,
        ),
    ];

    final rows = <List<_QuickAction>>[];
    for (var i = 0; i < actions.length; i += 2) {
      final end = i + 2 < actions.length ? i + 2 : actions.length;
      rows.add(actions.sublist(i, end));
    }

    return Column(
      children: [
        for (final row in rows) ...[
          Row(
            children: [
              for (var i = 0; i < row.length; i++) ...[
                Expanded(child: _ActionTile(row[i])),
                if (i < row.length - 1) const SizedBox(width: 10),
              ],
              if (row.length == 1) const Expanded(child: SizedBox.shrink()),
            ],
          ),
          if (row != rows.last) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile(this.action);

  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: action.onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 76),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.goldSoft.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(action.icon, color: AppColors.forest, size: 20),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(action.swahili,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.body(13, FontWeight.w700)),
                      const SizedBox(height: 1),
                      Text(action.english,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.body(10.5, FontWeight.w500,
                              color: AppColors.inkSoft)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}