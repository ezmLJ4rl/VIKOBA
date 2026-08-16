import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state/session.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/kitenge_thread.dart';
import 'activity_history_screen.dart';
import 'audit_log_screen.dart';
import 'export_data_screen.dart';
import 'group_settings_screen.dart';
import 'loan_management_screen.dart';
import 'project_completion_screen.dart';
import 'savings_report_screen.dart';
import 'settlement_screen.dart';
import 'sync_center_screen.dart';

/// Fifth-tab hub for group administration and tools: settings, history,
/// audit trail, exports, sync, settlement and the project handoff.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = context.watch<Session>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.moreTitle)),
      body: Column(
        children: [
          const KitengeThread(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Text(
                  l10n.moreSubtitle,
                  style: AppFonts.body(13, FontWeight.w400,
                      color: AppColors.inkSoft),
                ),
                const SizedBox(height: 14),
                _ToolTile(
                  icon: Icons.tune,
                  label: l10n.groupSettings,
                  subtitle: l10n.groupSettingsDesc,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const GroupSettingsScreen(),
                    ),
                  ),
                ),
                _ToolTile(
                  icon: Icons.history,
                  label: l10n.activityHistory,
                  subtitle: l10n.activityHistoryDesc,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ActivityHistoryScreen(),
                    ),
                  ),
                ),
                if (session.isAdmin) ...[
                  _ToolTile(
                    icon: Icons.manage_accounts_outlined,
                    label: l10n.loanManagement,
                    subtitle: l10n.auditLogDesc,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const LoanManagementScreen(),
                      ),
                    ),
                  ),
                  _ToolTile(
                    icon: Icons.receipt_long_outlined,
                    label: l10n.auditLog,
                    subtitle: l10n.auditLogDesc,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AuditLogScreen(),
                      ),
                    ),
                  ),
                  _ToolTile(
                    icon: Icons.file_upload_outlined,
                    label: l10n.exportData,
                    subtitle: l10n.exportDataDesc,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ExportDataScreen(),
                      ),
                    ),
                  ),
                  _ToolTile(
                    icon: Icons.sync_outlined,
                    label: l10n.syncCenter,
                    subtitle: l10n.syncCenterDesc,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SyncCenterScreen(),
                      ),
                    ),
                  ),
                  _ToolTile(
                    icon: Icons.payments_outlined,
                    label: l10n.settlement,
                    subtitle: l10n.settlementDesc,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SettlementScreen(),
                      ),
                    ),
                  ),
                ],
                _ToolTile(
                  icon: Icons.bar_chart_outlined,
                  label: l10n.savingsReport,
                  subtitle: l10n.savingsReportDesc,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SavingsReportScreen(),
                    ),
                  ),
                ),
                _ToolTile(
                  icon: Icons.flag_outlined,
                  label: l10n.projectCompletion,
                  subtitle: l10n.projectCompletionDesc,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ProjectCompletionScreen(),
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
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
                    Text(label,
                        style: AppFonts.body(14.5, FontWeight.w700)),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(12, FontWeight.w400,
                          color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: AppColors.inkSoft, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
