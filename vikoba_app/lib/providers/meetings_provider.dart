import 'package:flutter/foundation.dart';

import '../core/data/app_repository.dart';
import '../core/data/pending_operation.dart';
import '../core/state/async_state.dart';
import '../core/state/notifications.dart';
import '../core/state/session.dart';
import '../models/meeting.dart';

/// Meetings + attendance book-keeping. Logging meetings is admin-only.
class MeetingsProvider extends ChangeNotifier {
  MeetingsProvider(this._repo, this._session, this._notifications);

  final AppRepository _repo;
  final Session _session;
  final NotificationsController _notifications;
  AsyncState _state = const AsyncState.idle();

  AsyncState get state => _state;
  List<Meeting> get meetings => List.unmodifiable(_repo.meetings.reversed);

  Future<void> load() async {
    _state = const AsyncState.loading();
    notifyListeners();
    try {
      await _repo.ensureLoaded();
      _state = const AsyncState.loaded();
    } catch (e) {
      _state = AsyncState.failed('Could not load meetings: $e');
    }
    notifyListeners();
  }

  /// Returns false when the session has no permission.
  Future<bool> recordMeeting({
    required DateTime date,
    required String agenda,
    required List<String> presentMemberIds,
  }) async {
    if (!_session.canLogMeetings) return false;

    await _repo.ensureLoaded();
    final knownIds = _repo.members.map((m) => m.id).toSet();
    final present = presentMemberIds.toSet().intersection(knownIds);
    final absent = knownIds.difference(present);

    final meeting = Meeting(
      id: 'M${_repo.meetings.length + 1}',
      date: date,
      agenda: agenda,
      presentMemberIds: present.toList(),
      totalMembers: _repo.members.length,
    );
    await _repo.setMeetings([..._repo.meetings, meeting]);
    await _repo
        .enqueue(PendingOperation.create('meeting.create', meeting.toJson()));

    for (final id in present) {
      await _notifications.add(
          memberId: id, kind: NotificationKind.attendancePresent);
    }
    for (final id in absent) {
      await _notifications.add(
          memberId: id, kind: NotificationKind.attendanceAbsent);
    }
    notifyListeners();
    return true;
  }
}