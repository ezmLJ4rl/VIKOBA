import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state/session.dart';
import '../core/theme/app_theme.dart';
import '../screens/account_switcher_sheet.dart';

/// Persistent, non-intrusive indicator shown while the session is view-only
/// (a plain member account). Explains why action buttons are absent and opens
/// the demo account switcher on tap. Hidden entirely for admins.
class ViewOnlyBanner extends StatelessWidget {
  const ViewOnlyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();
    if (!session.isViewOnly) return const SizedBox.shrink();

    final account = session.account;
    return Material(
      color: AppColors.goldSoft.withValues(alpha: 0.45),
      child: InkWell(
        onTap: () => _openAccountSwitcher(context),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Icon(Icons.visibility_outlined,
                    size: 17, color: AppColors.forestDeep),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${account.roleLabelSw} · ${account.name} — '
                    '${account.roleLabelEn}, unaweza kuona tu / view-only',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(
                        12, FontWeight.w600,
                        color: AppColors.forestDeep),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down,
                    size: 18, color: AppColors.forestDeep),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openAccountSwitcher(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => const AccountSwitcherSheet(),
    );
  }
}