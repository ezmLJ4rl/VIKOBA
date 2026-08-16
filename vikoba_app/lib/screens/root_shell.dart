import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state/app_navigation.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/view_only_banner.dart';
import 'contributions_screen.dart';
import 'dashboard_screen.dart';
import 'loans_screen.dart';
import 'members_screen.dart';
import 'more_screen.dart';

/// Five-tab bottom navigation: Home · Members · Savings · Loans · More.
///
/// The share-out calculator lives on the dashboard (quick action); the fifth
/// "More" tab is the administration hub (settings, reports, sync, settlement).
/// Active tab is highlighted with a gold chip behind the icon.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  static const screens = [
    DashboardScreen(),
    MembersScreen(),
    ContributionsScreen(),
    LoansScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nav = context.watch<AppNavigation>();
    final index = nav.index;

    final items = [
      (
        icon: Icons.home_outlined,
        iconSelected: Icons.home,
        label: l10n.navHome
      ),
      (
        icon: Icons.groups_outlined,
        iconSelected: Icons.groups,
        label: l10n.navMembers
      ),
      (
        icon: Icons.savings_outlined,
        iconSelected: Icons.savings,
        label: l10n.navSavings
      ),
      (
        icon: Icons.account_balance_wallet_outlined,
        iconSelected: Icons.account_balance_wallet,
        label: l10n.navLoans
      ),
      (
        icon: Icons.grid_view_outlined,
        iconSelected: Icons.grid_view,
        label: l10n.navMore
      ),
    ];

    return Scaffold(
      body: Column(
        children: [
          const ViewOnlyBanner(),
          Expanded(
            child: IndexedStack(index: index, children: screens),
          ),
        ],
      ),
      bottomNavigationBar: _VikobaNavBar(
        items: items,
        currentIndex: index,
        onTap: (i) => nav.goTo(i),
      ),
    );
  }
}

typedef _NavItem = ({IconData icon, IconData iconSelected, String label});

class _VikobaNavBar extends StatelessWidget {
  const _VikobaNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: InkWell(
                      onTap: () => onTap(i),
                      customBorder: const CircleBorder(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: currentIndex == i
                                  ? AppColors.goldSoft
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              currentIndex == i
                                  ? items[i].iconSelected
                                  : items[i].icon,
                              size: 23,
                              color: currentIndex == i
                                  ? AppColors.forest
                                  : AppColors.inkSoft,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            items[i].label,
                            style: AppFonts.body(
                              11,
                              currentIndex == i
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: currentIndex == i
                                  ? AppColors.forest
                                  : AppColors.inkSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}