import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/kitenge_thread.dart';

/// Project completion & handoff: the milestone achievements plus a final
/// handoff checklist. Completing the checklist marks the project done.
class ProjectCompletionScreen extends StatefulWidget {
  const ProjectCompletionScreen({super.key});

  @override
  State<ProjectCompletionScreen> createState() =>
      _ProjectCompletionScreenState();
}

class _ProjectCompletionScreenState extends State<ProjectCompletionScreen> {
  bool _complete = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.projectCompletion)),
      body: Column(
        children: [
          const KitengeThread(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _MilestoneCard(
                  icon: Icons.groups_outlined,
                  color: AppColors.forest,
                  title: l10n.memberOnboarding,
                  body: l10n.memberOnboardingDesc,
                ),
                const SizedBox(height: 12),
                _MilestoneCard(
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.stone,
                  title: l10n.loanManagementMilestone,
                  body: l10n.loanManagementDesc,
                ),
                const SizedBox(height: 12),
                _MilestoneCard(
                  icon: Icons.bar_chart_outlined,
                  color: AppColors.goldDeep,
                  title: l10n.financialReportsMilestone,
                  body: l10n.financialReportsDesc,
                ),
                const SizedBox(height: 16),
                Text(l10n.milestonesAchieved,
                    style: AppFonts.body(15, FontWeight.w700)),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.finalHandoffReview,
                            style: AppFonts.body(14, FontWeight.w700)),
                        const SizedBox(height: 10),
                        _CheckRow(label: l10n.dataMigrationComplete),
                        _CheckRow(label: l10n.uatSignOff),
                        _CheckRow(label: l10n.adminRolesConfigured),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_complete)
                  _DoneBanner(l10n: l10n)
                else
                  FilledButton.icon(
                    onPressed: () => setState(() => _complete = true),
                    icon: const Icon(Icons.flag_outlined, size: 18),
                    label: Text(l10n.completeHandoff),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppFonts.body(14.5, FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(body,
                      style: AppFonts.body(12, FontWeight.w400,
                          color: AppColors.inkSoft)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 20, color: AppColors.forest),
          const SizedBox(width: 10),
          Text(label, style: AppFonts.body(13.5, FontWeight.w600)),
        ],
      ),
    );
  }
}

class _DoneBanner extends StatelessWidget {
  const _DoneBanner({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.forest.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.forest),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.forest, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.projectCompleted,
                    style: AppFonts.body(14, FontWeight.w700)),
                const SizedBox(height: 2),
                Text(l10n.projectCompleteBody,
                    style: AppFonts.body(12, FontWeight.w400,
                        color: AppColors.inkSoft)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
