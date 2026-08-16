import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state/notifications.dart';
import '../core/state/session.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../l10n/app_localizations.dart';
import '../widgets/kitenge_thread.dart';

/// The member's notification inbox. Notifications are readable and
/// dismissible but never actionable — reading never mutates group records.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = context.watch<Session>();
    final controller = context.watch<NotificationsController>();

    final items = controller.forMember(session.account.memberId);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          if (items.any((n) => !n.read))
            TextButton.icon(
              onPressed: () =>
                  controller.markAllRead(session.account.memberId),
              icon: const Icon(Icons.done_all, size: 18),
              label: Text(l10n.notificationsMarkAllRead),
            ),
        ],
      ),
      body: Column(
        children: [
          const KitengeThread(),
          Expanded(
            child: items.isEmpty
                ? _EmptyInbox(message: l10n.notificationsEmpty)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final n = items[index];
                      return _NotificationTile(
                        notification: n,
                        title: _titleFor(l10n, n.kind),
                        body: _bodyFor(l10n, n),
                        onTap: () => controller.markRead(n.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _titleFor(AppLocalizations l10n, NotificationKind kind) =>
      switch (kind) {
        NotificationKind.contribution => l10n.notifContribution,
        NotificationKind.loanRequested => l10n.notifLoanRequested,
        NotificationKind.loanApproved => l10n.notifLoanApproved,
        NotificationKind.loanRejected => l10n.notifLoanRejected,
        NotificationKind.repayment => l10n.notifRepayment,
        NotificationKind.attendancePresent => l10n.notifAttendancePresent,
        NotificationKind.attendanceAbsent => l10n.notifAttendanceAbsent,
      };

  String _bodyFor(AppLocalizations l10n, GroupNotification n) => switch (n.kind) {
        NotificationKind.contribution => l10n.notifBodyContribution(
            Formatters.money(n.amount)),
        NotificationKind.loanRequested => l10n.notifBodyLoanRequested(
            Formatters.money(n.amount)),
        NotificationKind.loanApproved => l10n.notifBodyLoanApproved(
            Formatters.money(n.amount)),
        NotificationKind.loanRejected => l10n.notifBodyLoanRejected(
            Formatters.money(n.amount)),
        NotificationKind.repayment => l10n.notifBodyRepayment(
            Formatters.money(n.amount)),
        NotificationKind.attendancePresent => l10n.notifBodyAttendancePresent,
        NotificationKind.attendanceAbsent => l10n.notifBodyAttendanceAbsent,
      };
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final GroupNotification notification;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: notification.tint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  _iconFor(notification.kind),
                  color: notification.tint,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppFonts.body(
                                14.5,
                                notification.read
                                    ? FontWeight.w500
                                    : FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Formatters.date(notification.at),
                          style: AppFonts.body(11, FontWeight.w500,
                              color: AppColors.inkSoft),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      body,
                      style: AppFonts.body(12.5, FontWeight.w400,
                          color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ),
              if (!notification.read)
                Container(
                  width: 9,
                  height: 9,
                  margin: const EdgeInsets.only(top: 6, left: 6),
                  decoration: BoxDecoration(
                    color: AppColors.clay,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(NotificationKind kind) => switch (kind) {
        NotificationKind.contribution => Icons.savings_outlined,
        NotificationKind.loanRequested => Icons.request_quote_outlined,
        NotificationKind.loanApproved => Icons.check_circle_outline,
        NotificationKind.loanRejected => Icons.cancel_outlined,
        NotificationKind.repayment => Icons.payments_outlined,
        NotificationKind.attendancePresent => Icons.event_available_outlined,
        NotificationKind.attendanceAbsent => Icons.event_busy_outlined,
      };
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none_outlined,
              size: 44, color: AppColors.inkSoft),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: AppFonts.body(14, FontWeight.w400,
                  color: AppColors.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}