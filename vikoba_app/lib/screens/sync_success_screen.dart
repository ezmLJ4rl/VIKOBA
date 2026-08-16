import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';

/// Full-screen confirmation shown after the sync queue drains: everything is
/// now safe on the server. Centered green checkmark + stat chips + a single
/// way forward.
class SyncSuccessScreen extends StatelessWidget {
  const SyncSuccessScreen({super.key});

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
                l10n.syncCompleteTitle,
                style: AppFonts.displayFont(26, FontWeight.w700,
                    color: AppColors.ink),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.syncCompleteBody,
                textAlign: TextAlign.center,
                style: AppFonts.body(13.5, FontWeight.w400,
                    color: AppColors.inkSoft),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _SuccessChip(
                      icon: Icons.cloud_done_outlined,
                      label: l10n.updatedRecords(4)),
                  _SuccessChip(
                      icon: Icons.photo_library_outlined,
                      label: l10n.syncedPhotos(2)),
                ],
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context)
                      .popUntil((r) => r.isFirst),
                  child: Text(l10n.returnToDashboard),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessChip extends StatelessWidget {
  const _SuccessChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.goldSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.forest),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppFonts.body(12, FontWeight.w600,
                color: AppColors.forestDeep),
          ),
        ],
      ),
    );
  }
}
