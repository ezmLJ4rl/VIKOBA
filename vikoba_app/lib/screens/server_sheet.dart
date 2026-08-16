import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/data/vikoba_api.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/sync_provider.dart';

/// Server connection sheet: paste the Bearer token from the backend login
/// (demo flow — the full login screen ships with auth), then watch queued
/// changes flush.
class ServerSheet extends StatefulWidget {
  const ServerSheet({super.key});

  @override
  State<ServerSheet> createState() => _ServerSheetState();
}

class _ServerSheetState extends State<ServerSheet> {
  final _tokenController = TextEditingController();
  final _urlController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final api = context.read<VikobaApiClient>();
    _tokenController.text = api.token ?? '';
    _urlController.text = api.baseUrl;
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final api = context.read<VikobaApiClient>();
    final sync = context.read<SyncProvider>();
    setState(() => _saving = true);
    await api.configure(
      baseUrl: _urlController.text.trim().isEmpty
          ? api.baseUrl
          : _urlController.text.trim(),
      token: _tokenController.text.trim(),
    );
    sync.setConnectivity(true);
    await sync.flushNow();
    if (!mounted) return;
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sync = context.watch<SyncProvider>();

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.syncTitle,
            style: AppFonts.displayFont(22, FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            sync.isConfigured
                ? l10n.syncServerConfigured
                : l10n.syncServerNotConfigured,
            style: AppFonts.body(14, FontWeight.w400)
                .copyWith(color: AppColors.inkSoft),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _urlController,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: l10n.syncBaseUrl,
              helperText: VikobaApiClient.defaultBaseUrl,
              border: _border,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _tokenController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l10n.syncToken,
              helperText: l10n.syncTokenHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.line),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.forest,
                    foregroundColor: AppColors.cream,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(_saving ? '...' : l10n.syncSave),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: sync.isConfigured && !sync.isSyncing
                    ? sync.flushNow
                    : null,
                icon: const Icon(Icons.sync, size: 18),
                label: Text(l10n.syncNow),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.forest,
                  minimumSize: const Size(0, 48),
                  side: BorderSide(color: AppColors.line),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const SizedBox(width: 4),
              Icon(
                sync.isConfigured ? Icons.cloud_done_outlined : Icons.cloud_off,
                size: 16,
                color: sync.isConfigured ? AppColors.forest : AppColors.stone,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sync.isSyncing
                      ? '${l10n.syncPending(sync.pendingCount)}…'
                      : sync.isConfigured
                          ? sync.lastSyncError ?? l10n.syncServerConnected
                          : l10n.syncServerNotConfigured,
                  style: AppFonts.body(13, FontWeight.w400)
                      .copyWith(color: AppColors.inkSoft),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

InputBorder get _border => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: AppColors.line),
    );