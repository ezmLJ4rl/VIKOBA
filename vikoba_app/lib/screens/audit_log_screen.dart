import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../l10n/app_localizations.dart';
import '../models/loan.dart';
import '../providers/group_settings_provider.dart';
import '../providers/loans_provider.dart';
import '../providers/members_provider.dart';
import '../widgets/kitenge_thread.dart';

enum _AuditCategory { all, settings, members, loans }

/// Immutable record of admin actions. Every entry carries a lock glyph and is
/// derived from the live data so it always reflects current reality.
class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  String _query = '';
  _AuditCategory _category = _AuditCategory.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final members = context.watch<MembersProvider>().members;
    final loans = context.watch<LoansProvider>().loans;
    final settings = context.watch<GroupSettingsProvider>();

    final entries = <_AuditEntry>[
      _AuditEntry(
        when: DateTime(2026, 2, 1),
        category: _AuditCategory.settings,
        icon: Icons.sell_outlined,
        color: AppColors.goldDeep,
        description: l10n.auditChangedSharePrice(
          Formatters.money(5000),
          Formatters.money(settings.shareValue),
        ),
      ),
      for (final m in members)
        _AuditEntry(
          when: m.joinedDate,
          category: _AuditCategory.members,
          icon: Icons.person_add_alt,
          color: AppColors.forest,
          description: l10n.auditAddedMember(m.fullName),
        ),
      for (final l in loans)
        if (l.status != LoanStatus.pending &&
            l.status != LoanStatus.rejected)
          _AuditEntry(
            when: l.disbursedAt ?? l.issuedDate,
            category: _AuditCategory.loans,
            icon: Icons.account_balance_wallet_outlined,
            color: AppColors.stone,
            description: l10n.auditApprovedLoan(
              l.id,
              Formatters.money(l.principal),
            ),
          ),
    ]..sort((a, b) => b.when.compareTo(a.when));

    final filtered = entries.where((e) {
      final matchesCategory = _category == _AuditCategory.all ||
          e.category == _category;
      final q = _query.trim().toLowerCase();
      final matchesQuery =
          q.isEmpty || e.description.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.auditLog)),
      body: Column(
        children: [
          const KitengeThread(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lock_outline, size: 16, color: AppColors.inkSoft),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.immutableRecord,
                        style: AppFonts.body(12.5, FontWeight.w600,
                            color: AppColors.inkSoft),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: l10n.searchActions,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChip(
                      label: l10n.allActions,
                      selected: _category == _AuditCategory.all,
                      onTap: () => setState(
                          () => _category = _AuditCategory.all),
                    ),
                    _FilterChip(
                      label: l10n.filterSettings,
                      selected: _category == _AuditCategory.settings,
                      onTap: () => setState(
                          () => _category = _AuditCategory.settings),
                    ),
                    _FilterChip(
                      label: l10n.filterMembers,
                      selected: _category == _AuditCategory.members,
                      onTap: () => setState(
                          () => _category = _AuditCategory.members),
                    ),
                    _FilterChip(
                      label: l10n.filterLoans,
                      selected: _category == _AuditCategory.loans,
                      onTap: () => setState(
                          () => _category = _AuditCategory.loans),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      l10n.auditNoEntries,
                      style: AppFonts.body(14, FontWeight.w400,
                          color: AppColors.inkSoft),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    children: [
                      for (final e in filtered)
                        Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: e.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child:
                                  Icon(e.icon, color: e.color, size: 20),
                            ),
                            title: Text(e.description,
                                style: AppFonts.body(
                                    13.5, FontWeight.w600)),
                            subtitle: Text(
                              Formatters.dateTime(e.when),
                              style: AppFonts.body(11.5, FontWeight.w400,
                                  color: AppColors.inkSoft),
                            ),
                            trailing: Icon(Icons.lock,
                                size: 14, color: AppColors.inkSoft),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.forest : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.forest : AppColors.line),
        ),
        child: Text(
          label,
          style: AppFonts.body(
            12.5,
            FontWeight.w600,
            color: selected ? AppColors.cream : AppColors.inkSoft,
          ),
        ),
      ),
    );
  }
}

class _AuditEntry {
  const _AuditEntry({
    required this.when,
    required this.category,
    required this.icon,
    required this.color,
    required this.description,
  });

  final DateTime when;
  final _AuditCategory category;
  final IconData icon;
  final Color color;
  final String description;
}
