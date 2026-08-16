import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../l10n/app_localizations.dart';
import '../providers/sync_provider.dart';
import '../widgets/kitenge_thread.dart';
import '../widgets/status_badge.dart';
import 'sync_success_screen.dart';

/// Offline-first sync centre: connectivity state, the pending queue and
/// storage health. Manual "Sync now" flushes queued operations to the backend
/// and lands on the success screen when the queue drains.
class SyncCenterScreen extends StatelessWidget {
  const SyncCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sync = context.watch<SyncProvider>();
    final pending = sync.pendingCount;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.syncCenter)),
      body: Column(
        children: [
          const KitengeThread(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                if (sync.isConfigured && sync.isConnected)
                  _StateCard(
                    icon: Icons.cloud_done_outlined,
                    color: AppColors.statusOk,
                    title: l10n.synced,
                    body: _lastSyncLabel(l10n, sync.successfulSyncs),
                  )
                else
                  _StateCard(
                    icon: Icons.cloud_off_outlined,
                    color: AppColors.statusAttention,
                    title: l10n.currentlyOffline,
                    body: l10n.offlineBody,
                  ),
                const SizedBox(height: 14),
                _StorageCard(l10n: l10n, sync: sync),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.pendingChanges,
                                style: AppFonts.body(15, FontWeight.w700)),
                            StatusBadge(
                                label: '$pending',
                                color: pending > 0
                                    ? AppColors.statusPending
                                    : AppColors.statusOk),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (sync.queue.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              l10n.synced,
                              style: AppFonts.body(13, FontWeight.w400,
                                  color: AppColors.inkSoft),
                            ),
                          )
                        else
                          for (final op in sync.queue)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  Icon(Icons.cloud_upload_outlined,
                                      size: 18, color: AppColors.goldDeep),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      op.type,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFonts.body(
                                          13, FontWeight.w600),
                                    ),
                                  ),
                                  StatusBadge(
                                    label: l10n.localBadge,
                                    color: AppColors.stone,
                                  ),
                                ],
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: sync.isSyncing
                      ? null
                      : () => _syncNow(context, l10n, sync),
                  icon: sync.isSyncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.sync, size: 18),
                  label: Text(sync.isSyncing
                      ? l10n.syncNow
                      : l10n.syncNow),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _lastSyncLabel(AppLocalizations l10n, int successes) {
    if (successes == 0) return '';
    final now = DateTime.now();
    return l10n.lastSync(Formatters.dateTime(now));
  }

  Future<void> _syncNow(
      BuildContext context, AppLocalizations l10n, SyncProvider sync) async {
    await sync.flushNow();
    if (!context.mounted) return;
    if (sync.pendingCount == 0) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const SyncSuccessScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(sync.lastSyncError ?? l10n.offlineBody),
        duration: const Duration(seconds: 2),
      ));
    }
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
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
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppFonts.body(15, FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(body,
                      style: AppFonts.body(12.5, FontWeight.w400,
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

class _StorageCard extends StatelessWidget {
  const _StorageCard({required this.l10n, required this.sync});

  final AppLocalizations l10n;
  final SyncProvider sync;

  @override
  Widget build(BuildContext context) {
    const capacityMb = 500;
    final usedMb = sync.queue.length * 2;
    final fraction = (usedMb / capacityMb).clamp(0.0, 1.0);
    final availableMb = capacityMb - usedMb;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.storageHealth,
                    style: AppFonts.body(15, FontWeight.w700)),
                StatusBadge(label: l10n.storageSafe, color: AppColors.statusOk),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(l10n.capacityUsed,
                    style: AppFonts.body(12.5, FontWeight.w500,
                        color: AppColors.inkSoft)),
                const Spacer(),
                Text('$usedMb / $capacityMb MB',
                    style: AppFonts.body(12.5, FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8,
                backgroundColor: AppColors.line,
                color: AppColors.forest,
              ),
            ),
            const SizedBox(height: 8),
            Text(l10n.mbAvailable(availableMb),
                style: AppFonts.body(12, FontWeight.w500,
                    color: AppColors.inkSoft)),
          ],
        ),
      ),
    );
  }
}
