import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state/app_navigation.dart';
import '../core/state/session.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../core/validation/validators.dart';
import '../l10n/app_localizations.dart';
import '../models/member.dart';
import '../providers/contributions_provider.dart';
import '../providers/members_provider.dart';
import '../widgets/hero_card.dart';
import '../widgets/kitenge_thread.dart';

/// Contribution history + record-shares sheet (validated), led by the savings
/// hero number.
class ContributionsScreen extends StatefulWidget {
  const ContributionsScreen({super.key});

  @override
  State<ContributionsScreen> createState() => _ContributionsScreenState();
}

class _ContributionsScreenState extends State<ContributionsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pending = context.read<AppNavigation>().takePending();
    if (pending == PendingAction.addContribution && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showRecordSheet();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<ContributionsProvider>();
    final session = context.watch<Session>();
    final contributions = provider.contributions;

    final totalShares =
        contributions.fold<int>(0, (sum, c) => sum + c.sharesBought);
    final lastDate =
        contributions.isNotEmpty ? contributions.first.date : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appBarContributions)),
      floatingActionButton: session.canRecordContributions
          ? FloatingActionButton(
              onPressed: _showRecordSheet,
              tooltip: l10n.record,
              heroTag: 'contributions-add-fab',
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          const KitengeThread(),
          Expanded(
            child: contributions.isEmpty
                ? Center(
                    child: Text(
                      l10n.noContributionsYet,
                      textAlign: TextAlign.center,
                      style: AppFonts.body(14, FontWeight.w400,
                          color: AppColors.inkSoft),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    children: [
                      HeroCard(
                        title: l10n.totalGroupSavings,
                        value: Formatters.money(provider.totalSavings),
                        chips: [
                          HeroChip(
                            icon: Icons.donut_small,
                            label: l10n.totalShares,
                            value: '$totalShares',
                          ),
                          if (lastDate != null)
                            HeroChip(
                              icon: Icons.event_outlined,
                              label: l10n.lastContribution,
                              value: Formatters.date(lastDate),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...contributions.map((c) => Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    AppColors.goldSoft.withValues(alpha: 0.55),
                                foregroundColor: AppColors.forest,
                                child: const Icon(Icons.arrow_downward, size: 18),
                              ),
                              title: Text(c.memberName,
                                  style: AppFonts.body(14.5, FontWeight.w700)),
                              subtitle: Text(l10n.sharesPrefix(
                                  c.sharesBought, Formatters.date(c.date))),
                              trailing: Text(
                                Formatters.money(c.amount),
                                style: AppFonts.body(14, FontWeight.w700),
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

  void _showRecordSheet() {
    final context = this.context;
    final l10n = AppLocalizations.of(context);
    final provider = context.read<ContributionsProvider>();
    final membersProvider = context.read<MembersProvider>();
    final formKey = GlobalKey<FormState>();
    final sharesController = TextEditingController(text: '1');
    final noteController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          final shares = int.tryParse(sharesController.text) ?? 0;
          final amount = shares * provider.shareValue;
          final members = membersProvider.members;
          final selected = members.firstOrNull;

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
                    Text(l10n.recordContribution,
                        style: AppFonts.displayFont(
                            22, FontWeight.w700,
                            color: AppColors.ink)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Member>(
                      initialValue: selected,
                      decoration: InputDecoration(labelText: l10n.member),
                      items: members
                          .map((m) => DropdownMenuItem(
                              value: m, child: Text(m.fullName)))
                          .toList(),
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: sharesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.numberOfShares,
                        helperText: l10n.oneShareHelper(
                            Formatters.money(provider.shareValue)),
                      ),
                      validator: Validators.wholePositiveInt,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: noteController,
                      decoration: InputDecoration(labelText: l10n.noteOptional),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            AppColors.goldSoft.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.totalAmount,
                              style: AppFonts.body(13, FontWeight.w600)),
                          Text(Formatters.money(amount),
                              style: AppFonts.body(15, FontWeight.w700)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: selected == null
                          ? null
                          : () {
                              if (!formKey.currentState!.validate()) return;
                              provider.recordContribution(
                                member: selected,
                                shares: shares,
                                note: noteController.text.trim().isEmpty
                                    ? null
                                    : noteController.text.trim(),
                              );
                              Navigator.pop(context);
                            },
                      icon: const Icon(Icons.add),
                      label: Text(l10n.saveContribution),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }
}