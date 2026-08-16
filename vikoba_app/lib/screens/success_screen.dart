import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';

/// Post-registration success: green checkmark, what just happened, and the
/// next steps for the new group. Single action — go to the dashboard.
class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.forest.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle,
                    color: AppColors.forest, size: 56),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.groupRegistered,
                textAlign: TextAlign.center,
                style: AppFonts.displayFont(26, FontWeight.w700,
                    color: AppColors.ink),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.groupReadyBody,
                textAlign: TextAlign.center,
                style: AppFonts.body(13.5, FontWeight.w400,
                    color: AppColors.inkSoft),
              ),
              const SizedBox(height: 26),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.nextSteps,
                          style: AppFonts.body(15, FontWeight.w700)),
                      const SizedBox(height: 10),
                      _StepRow(
                        icon: Icons.person_add_alt,
                        label: l10n.inviteMembers,
                      ),
                      _StepRow(
                        icon: Icons.tune,
                        label: l10n.setRules,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                  child: Text(l10n.goToDashboard),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.goldSoft.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.forest, size: 18),
          ),
          const SizedBox(width: 12),
          Text(label,
              style: AppFonts.body(13.5, FontWeight.w600)),
        ],
      ),
    );
  }
}
