import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';

/// Read-only viewer for an exported CSV. The content is selectable so the
/// user can copy any part of it, plus a toolbar action to copy it all.
class CsvPreviewScreen extends StatelessWidget {
  const CsvPreviewScreen({super.key, required this.title, required this.csv});

  final String title;
  final String csv;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.csvPreview} · $title'),
        actions: [
          IconButton(
            tooltip: l10n.copyCsv,
            icon: const Icon(Icons.copy_all_outlined),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: csv));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(l10n.copiedToClipboard),
                duration: const Duration(seconds: 2),
              ));
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: SelectableText(
            csv,
            style: AppFonts.body(12.5, FontWeight.w400, color: AppColors.ink)
                .copyWith(fontFamily: 'monospace'),
          ),
        ),
      ),
    );
  }
}
