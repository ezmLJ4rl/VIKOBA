import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state/app_navigation.dart';
import '../core/state/session.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../core/validation/validators.dart';
import '../l10n/app_localizations.dart';
import '../models/member.dart';
import '../providers/group_settings_provider.dart';
import '../providers/members_provider.dart';
import '../widgets/hero_card.dart';
import '../widgets/kitenge_thread.dart';
import 'member_detail_screen.dart';

/// Member roster with a money-first hero, search, add-member sheet (validated)
/// and a clay "+" create action. Tapping a member opens their full record.
class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pending = context.read<AppNavigation>().takePending();
    if (pending == PendingAction.addMember && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showAddMemberSheet();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<MembersProvider>();
    final session = context.watch<Session>();
    final members = provider.members;
    final query = _query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? members
        : members
            .where((m) =>
                m.fullName.toLowerCase().contains(query) ||
                m.phoneNumber.contains(_query.trim()))
            .toList();

    final totalShares =
        members.fold<int>(0, (sum, m) => sum + m.totalShares);
    final totalContributed =
        members.fold<double>(0, (sum, m) => sum + m.totalContributed);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appBarMembers)),
      floatingActionButton: session.canManageMembers
          ? FloatingActionButton(
              onPressed: _showAddMemberSheet,
              tooltip: l10n.addMember,
              heroTag: 'members-add-fab',
              child: const Icon(Icons.person_add_alt),
            )
          : null,
      body: Column(
        children: [
          const KitengeThread(),
          Expanded(
            child: provider.members.isEmpty
                ? Center(
                    child: Text(
                      l10n.noMembersYet,
                      textAlign: TextAlign.center,
                      style: AppFonts.body(14, FontWeight.w400,
                          color: AppColors.inkSoft),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _query = v),
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: l10n.searchMembers,
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _query = '');
                                  },
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      HeroCard(
                        title: l10n.activeMembers,
                        value: '${provider.activeCount}',
                        chips: [
                          HeroChip(
                            icon: Icons.donut_small,
                            label: l10n.totalShares,
                            value: '$totalShares',
                          ),
                          HeroChip(
                            icon: Icons.payments_outlined,
                            label: l10n.totalContributed,
                            value: Formatters.money(totalContributed),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (filtered.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              l10n.noMembersFound,
                              textAlign: TextAlign.center,
                              style: AppFonts.body(14, FontWeight.w400,
                                  color: AppColors.inkSoft),
                            ),
                          ),
                        )
                      else
                        ...filtered.map((m) => Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => MemberDetailScreen(
                                        memberId: m.id),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        AppColors.goldSoft.withValues(
                                            alpha: 0.55),
                                    foregroundColor: AppColors.forest,
                                    child: Text(
                                      m.fullName.isEmpty
                                          ? '?'
                                          : m.fullName
                                              .substring(0, 1)
                                              .toUpperCase(),
                                      style:
                                          AppFonts.body(15, FontWeight.w700),
                                    ),
                                  ),
                                  title: Text(m.fullName,
                                      style: AppFonts.body(
                                          15, FontWeight.w700)),
                                  subtitle: Text(
                                      '${m.roleLabel} - ${m.phoneNumber}',
                                      style: AppFonts.body(12.5,
                                          FontWeight.w400,
                                          color: AppColors.inkSoft)),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        Formatters.money(m.totalContributed),
                                        style: AppFonts.body(
                                            14, FontWeight.w700),
                                      ),
                                      Text(
                                        l10n.memberSharesSuffix(m.totalShares),
                                        style: AppFonts.body(12,
                                                FontWeight.w500,
                                                color: AppColors.inkSoft),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddMemberSheet() {
    final context = this.context;
    final l10n = AppLocalizations.of(context);
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    MemberRole selectedRole = MemberRole.member;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.addMember,
                          style: AppFonts.displayFont(
                              22, FontWeight.w700,
                              color: AppColors.ink)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(labelText: l10n.fullName),
                        validator: (v) =>
                            Validators.required(v, l10n.fullName),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration:
                            InputDecoration(labelText: l10n.phoneNumber),
                        validator: Validators.tanzanianPhone,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<MemberRole>(
                        initialValue: selectedRole,
                        decoration: InputDecoration(labelText: l10n.role),
                        items: MemberRole.values
                            .map((r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(r.name[0].toUpperCase() +
                                      r.name.substring(1)),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => selectedRole = v!),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;
                          final provider = context.read<MembersProvider>();
                          provider.addMember(Member(
                            id:
                                'MEM${provider.members.length + 1}',
                            fullName: nameController.text.trim(),
                            phoneNumber: Validators.normalizeTzPhone(
                                phoneController.text)!,
                            role: selectedRole,
                            joinedDate: DateTime.now(),
                            totalShares: 0,
                            shareValue: context
                                .read<GroupSettingsProvider>()
                                .shareValue,
                          ));
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.person_add_alt),
                        label: Text(l10n.saveMember),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}