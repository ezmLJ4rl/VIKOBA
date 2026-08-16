import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state/auth_controller.dart';
import '../core/state/notifications.dart';
import '../core/state/session.dart';
import '../core/state/theme_controller.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../models/member.dart';
import '../providers/members_provider.dart';

/// Account sheet.
///
/// In demo (offline) mode it lists the roster so any role can be previewed —
/// signing in as a plain member switches the whole app to view-only. In
/// authenticated mode it shows the signed-in account. Both end with a sign-out
/// action that returns to the login screen.
class AccountSwitcherSheet extends StatelessWidget {
  const AccountSwitcherSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = context.watch<Session>();
    final members = context.watch<MembersProvider>().members;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              session.canSwitchAccounts
                  ? l10n.accountSwitchTitle
                  : l10n.authSignedInAs(session.account.name),
              style: AppFonts.displayFont(22, FontWeight.w700,
                  color: AppColors.ink),
            ),
            if (session.canSwitchAccounts) ...[
              const SizedBox(height: 4),
              Text(
                l10n.accountSwitchHint,
                style: AppFonts.body(12.5, FontWeight.w500,
                    color: AppColors.inkSoft),
              ),
              const SizedBox(height: 14),
              for (final m in members) ...[
                _AccountRow(
                  name: m.fullName,
                  phone: m.phoneNumber,
                  roleSw: _roleSw(m),
                  roleEn: m.roleLabel,
                  isActive: m.id == session.account.memberId,
                  isAdmin: m.role != MemberRole.member,
                  onTap: () async {
                    final session = context.read<Session>();
                    final notifications =
                        context.read<NotificationsController>();
                    final account = SessionAccount(
                      memberId: m.id,
                      name: m.fullName,
                      phone: m.phoneNumber,
                      role: m.role,
                    );
                    await session.signInAs(account);
                    if (!account.isAdmin) {
                      await notifications.seedForMember(account.memberId);
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ] else ...[
              const SizedBox(height: 12),
              _AccountRow(
                name: session.account.name,
                phone: session.account.phone,
                roleSw: session.account.roleLabelSw,
                roleEn: session.account.roleLabelEn,
                isActive: true,
                isAdmin: session.account.isAdmin,
                onTap: () {},
              ),
            ],
            const SizedBox(height: 6),
            const Divider(height: 24),
            SwitchListTile(
              value: context.watch<ThemeController>().isDark,
              onChanged: (v) => context.read<ThemeController>().setDark(v),
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.dark_mode_outlined, size: 20),
              title: Text(l10n.darkMode,
                  style: AppFonts.body(14, FontWeight.w600)),
              activeTrackColor: AppColors.forest,
            ),
            InkWell(
              onTap: () async {
                await context.read<AuthController>().logout();
                if (context.mounted) Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.logout,
                        size: 20, color: AppColors.clay),
                    const SizedBox(width: 10),
                    Text(
                      l10n.authLogout,
                      style: AppFonts.body(14, FontWeight.w700,
                          color: AppColors.clay),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _roleSw(Member m) => switch (m.role) {
        MemberRole.chairperson => 'Mwenyekiti',
        MemberRole.treasurer => 'Mweka Hazina',
        MemberRole.secretary => 'Katibu',
        MemberRole.member => 'Mwanachama',
      };
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.name,
    required this.phone,
    required this.roleSw,
    required this.roleEn,
    required this.isActive,
    required this.isAdmin,
    required this.onTap,
  });

  final String name;
  final String phone;
  final String roleSw;
  final String roleEn;
  final bool isActive;
  final bool isAdmin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive
          ? AppColors.goldSoft.withValues(alpha: 0.5)
          : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isAdmin
                    ? AppColors.forest.withValues(alpha: 0.12)
                    : AppColors.goldSoft.withValues(alpha: 0.6),
                foregroundColor: AppColors.forest,
                child: Text(
                  name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
                  style: AppFonts.body(15, FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppFonts.body(14.5, FontWeight.w700)),
                    const SizedBox(height: 1),
                    Text(
                      '$roleSw · $roleEn — $phone',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(11.5, FontWeight.w500,
                          color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ),
              if (isActive)
                Icon(Icons.check_circle,
                    color: AppColors.forest, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}