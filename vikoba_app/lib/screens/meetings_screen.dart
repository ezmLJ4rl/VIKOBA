import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state/session.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../core/validation/validators.dart';
import '../l10n/app_localizations.dart';
import '../models/member.dart';
import '../providers/meetings_provider.dart';
import '../providers/members_provider.dart';
import '../widgets/kitenge_thread.dart';

/// Meeting minutes + attendance. Admins log a meeting by ticking who was
/// present; absentees and attendees are notified automatically.
class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({super.key});

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<MeetingsProvider>();
    final session = context.watch<Session>();
    final meetings = provider.meetings;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appBarMeetings)),
      floatingActionButton: session.canLogMeetings
          ? FloatingActionButton(
              onPressed: () => _showLogSheet(context),
              tooltip: l10n.newMeeting,
              heroTag: 'meetings-add-fab',
              child: const Icon(Icons.event_note),
            )
          : null,
      body: Column(
        children: [
          const KitengeThread(),
          Expanded(
            child: meetings.isEmpty
                ? Center(
                    child: Text(
                      l10n.noMeetingsYet,
                      textAlign: TextAlign.center,
                      style: AppFonts.body(14, FontWeight.w400,
                          color: AppColors.inkSoft),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    children: [
                      ...meetings.map((m) => Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(Formatters.date(m.date),
                                          style: AppFonts.body(
                                              15, FontWeight.w700)),
                                      Text(
                                        l10n.attendanceRate((m.attendanceRate *
                                                100)
                                            .toStringAsFixed(0)),
                                        style: AppFonts.body(12.5,
                                                FontWeight.w700,
                                                color: AppColors.forest),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    m.agenda.isEmpty
                                        ? l10n.agendaLabel
                                        : m.agenda,
                                    style: AppFonts.body(13, FontWeight.w400,
                                        color: AppColors.inkSoft),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(Icons.how_to_reg_outlined,
                                          size: 16, color: AppColors.forest),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${m.presentMemberIds.length} '
                                        '${l10n.presentMembers.toLowerCase()}',
                                        style: AppFonts.body(12.5,
                                            FontWeight.w600),
                                      ),
                                      const SizedBox(width: 14),
                                      Icon(Icons.event_busy_outlined,
                                          size: 16,
                                          color: AppColors.statusAttention),
                                      const SizedBox(width: 6),
                                      Text(
                                        l10n.absentCount(m.absentCount),
                                        style: AppFonts.body(12.5,
                                            FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ],
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

  Future<void> _showLogSheet(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final membersProvider = context.read<MembersProvider>();
    final members = membersProvider.members;
    if (members.isEmpty) return;

    final formKey = GlobalKey<FormState>();
    final agendaController = TextEditingController();
    DateTime date = DateTime.now();
    final present = <String>{};

    await showModalBottomSheet<void>(
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
                      Text(l10n.newMeeting,
                          style: AppFonts.displayFont(
                              22, FontWeight.w700, color: AppColors.ink)),
                      const SizedBox(height: 16),
                      _DateField(
                        date: date,
                        label: l10n.meetingDate,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 365)),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => date = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: agendaController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: l10n.meetingAgenda,
                        ),
                        validator: (v) =>
                            Validators.required(v, l10n.meetingAgenda),
                      ),
                      const SizedBox(height: 16),
                      Text(l10n.logAttendance,
                          style: AppFonts.body(14, FontWeight.w700)),
                      const SizedBox(height: 8),
                      ...members.map((m) => _AttendanceRow(
                            member: m,
                            checked: present.contains(m.id),
                            onChanged: (v) => setState(() {
                              if (v) {
                                present.add(m.id);
                              } else {
                                present.remove(m.id);
                              }
                            }),
                          )),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;
                          context.read<MeetingsProvider>().recordMeeting(
                                date: date,
                                agenda: agendaController.text.trim(),
                                presentMemberIds: present.toList(),
                              );
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.event_available),
                        label: Text(l10n.saveMeeting),
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
    agendaController.dispose();
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.date,
    required this.label,
    required this.onTap,
  });

  final DateTime date;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_month_outlined),
        ),
        child: Text(
          Formatters.date(date),
          style: AppFonts.body(14, FontWeight.w600),
        ),
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({
    required this.member,
    required this.checked,
    required this.onChanged,
  });

  final Member member;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: checked,
      onChanged: (v) => onChanged(v ?? false),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(member.fullName,
          style: AppFonts.body(14, FontWeight.w500)),
      subtitle: Text(member.roleLabel,
          style: AppFonts.body(11.5, FontWeight.w400,
              color: AppColors.inkSoft)),
    );
  }
}
