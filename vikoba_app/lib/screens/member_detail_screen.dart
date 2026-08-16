import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/domain/vizoba_calc.dart';
import '../core/state/session.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../l10n/app_localizations.dart';
import '../models/loan.dart';
import '../models/member.dart';
import '../providers/contributions_provider.dart';
import '../providers/loans_provider.dart';
import '../providers/members_provider.dart';
import '../widgets/hero_card.dart';
import '../widgets/status_badge.dart';
import 'loan_detail_screen.dart';

/// One member's full record: profile, financial position, their loans and
/// contribution history. Admins can deactivate/reactivate from here.
class MemberDetailScreen extends StatelessWidget {
  const MemberDetailScreen({super.key, required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final membersProvider = context.watch<MembersProvider>();
    final loansProvider = context.watch<LoansProvider>();
    final contributionsProvider = context.watch<ContributionsProvider>();
    final session = context.watch<Session>();

    final member = membersProvider.members
        .where((m) => m.id == memberId)
        .firstOrNull;
    if (member == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.memberDetailTitle)),
        body: Center(
          child: Text(
            l10n.noMembersFound,
            style: AppFonts.body(14, FontWeight.w400,
                color: AppColors.inkSoft),
          ),
        ),
      );
    }

    final loans = loansProvider.loans
        .where((l) => l.memberId == memberId)
        .toList();
    final contributions = contributionsProvider.contributions
        .where((c) => c.memberId == memberId)
        .toList();
    final capacity = VikobaCalc.maxAllowedFor(member: member);
    final exposure = loansProvider.guarantorExposure(memberId);
    final outstanding = loans
        .where((l) => l.status == LoanStatus.active)
        .fold<double>(0.0, (sum, l) => sum + VikobaCalc.balance(l));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.memberDetailTitle),
        actions: [
          if (session.canManageMembers)
            IconButton(
              tooltip: member.isActive
                  ? l10n.deactivateMember
                  : l10n.reactivateMember,
              onPressed: () => _toggleActive(context, member),
              icon: Icon(
                member.isActive ? Icons.person_off_outlined : Icons.person_add,
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _ProfileCard(member: member, l10n: l10n),
          const SizedBox(height: 16),
          HeroCard(
            title: l10n.totalContributed,
            value: Formatters.money(member.totalContributed),
            chips: [
              HeroChip(
                icon: Icons.donut_small,
                label: l10n.totalShares,
                value: '${member.totalShares}',
              ),
              HeroChip(
                icon: Icons.trending_up,
                label: l10n.loanCapacity,
                value: Formatters.money(capacity),
              ),
              HeroChip(
                icon: Icons.account_balance_wallet_outlined,
                label: l10n.balance,
                value: Formatters.money(outstanding),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (exposure > 0) ...[
            _InfoTile(
              icon: Icons.verified_user_outlined,
              label: l10n.guarantorExposure,
              value: Formatters.money(exposure),
            ),
            const SizedBox(height: 12),
          ],
          _SectionTitle(l10n.memberLoans),
          const SizedBox(height: 8),
          if (loans.isEmpty)
            _EmptyRow(text: l10n.noMemberLoans)
          else
            ...loans.map((l) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => LoanDetailScreen(loanId: l.id),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Formatters.money(l.principal),
                                  style: AppFonts.body(
                                      15, FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${l10n.due}: ${Formatters.date(l.dueDate)}',
                                  style: AppFonts.body(12.5,
                                      FontWeight.w400,
                                      color: AppColors.inkSoft),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(
                            label: l.isOverdue ? l10n.overdue : l.statusLabel,
                            color: l.isOverdue
                                ? AppColors.statusAttention
                                : _statusColor(l),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
          const SizedBox(height: 12),
          _SectionTitle(l10n.memberContributions),
          const SizedBox(height: 8),
          if (contributions.isEmpty)
            _EmptyRow(text: l10n.noMemberContributions)
          else
            ...contributions.map((c) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppColors.goldSoft.withValues(alpha: 0.55),
                      foregroundColor: AppColors.forest,
                      child: const Icon(Icons.arrow_downward, size: 18),
                    ),
                    title: Text(l10n.sharesPrefix(
                        c.sharesBought, Formatters.date(c.date))),
                    trailing: Text(
                      Formatters.money(c.amount),
                      style: AppFonts.body(14, FontWeight.w700),
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  Color _statusColor(Loan l) => switch (l.status) {
        LoanStatus.pending || LoanStatus.approved => AppColors.statusPending,
        LoanStatus.active || LoanStatus.repaid => AppColors.statusOk,
        LoanStatus.rejected => AppColors.statusAttention,
      };

  Future<void> _toggleActive(BuildContext context, Member member) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<MembersProvider>();

    if (member.isActive) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.deactivateConfirmTitle),
          content: Text(l10n.deactivateConfirmBody(member.fullName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.deactivateMember),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    final ok = member.isActive
        ? await provider.deactivateMember(member.id)
        : await provider.reactivateMember(member.id);

    messenger.showSnackBar(SnackBar(
      content: Text(member.isActive
          ? l10n.memberDeactivated
          : l10n.memberReactivated),
      duration: const Duration(seconds: 2),
    ));
    if (!ok) return;
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.member, required this.l10n});

  final Member member;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      AppColors.goldSoft.withValues(alpha: 0.55),
                  foregroundColor: AppColors.forest,
                  child: Text(
                    member.fullName.isEmpty
                        ? '?'
                        : member.fullName.substring(0, 1).toUpperCase(),
                    style: AppFonts.body(22, FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.fullName,
                          style: AppFonts.body(18, FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(member.roleLabel,
                          style: AppFonts.body(13, FontWeight.w500,
                              color: AppColors.inkSoft)),
                    ],
                  ),
                ),
                StatusBadge(
                  label: member.isActive
                      ? l10n.memberStatusActive
                      : l10n.memberStatusInactive,
                  color: member.isActive
                      ? AppColors.statusOk
                      : AppColors.statusAttention,
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),
            _detail(Icons.phone_outlined, member.phoneNumber),
            if (member.nidaNumber != null) ...[
              const SizedBox(height: 6),
              _detail(Icons.badge_outlined, member.nidaNumber!),
            ],
            const SizedBox(height: 6),
            _detail(
                Icons.calendar_today_outlined,
                '${l10n.joinedDate}: ${Formatters.date(member.joinedDate)}'),
            const SizedBox(height: 6),
            _detail(Icons.hourglass_bottom,
                l10n.membershipDaysLabel(member.membershipDays)),
          ],
        ),
      ),
    );
  }

  Widget _detail(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 16, color: AppColors.inkSoft),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: AppFonts.body(13, FontWeight.w500,
                    color: AppColors.ink)),
          ),
        ],
      );
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.forest),
        title: Text(label,
            style: AppFonts.body(14, FontWeight.w600)),
        trailing: Text(value,
            style: AppFonts.body(14, FontWeight.w700,
                color: AppColors.clay)),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppFonts.body(16, FontWeight.w700, color: AppColors.ink),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Text(
        text,
        style: AppFonts.body(14, FontWeight.w400, color: AppColors.inkSoft),
      ),
    );
  }
}
