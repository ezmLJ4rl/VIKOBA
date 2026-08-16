import 'package:flutter/foundation.dart';

import '../core/data/app_repository.dart';
import '../core/data/pending_operation.dart';
import '../core/state/async_state.dart';
import '../core/state/session.dart';
import '../models/member.dart';

/// Owns the member roster. All persistence flows through [AppRepository] so
/// this provider is oblivious to whether data lives locally or on the API.
///
/// Writes are data-layer guarded: only admin accounts may add/deactivate.
class MembersProvider extends ChangeNotifier {
  MembersProvider(this._repo, this._session);

  final AppRepository _repo;
  final Session _session;
  AsyncState _state = const AsyncState.loading();

  AsyncState get state => _state;

  List<Member> get members => _repo.members;
  int get activeCount => _repo.members.where((m) => m.isActive).length;

  Future<void> load() async {
    _state = const AsyncState.loading();
    notifyListeners();
    try {
      await _repo.ensureLoaded();
      _state = const AsyncState.loaded();
    } catch (e) {
      _state = AsyncState.failed('Could not load members: $e');
    }
    notifyListeners();
  }

  /// Returns false when the session has no permission (member accounts can
  /// never create records — enforced here, at the data layer).
  Future<bool> addMember(Member member) async {
    if (!_session.canManageMembers) return false;
    await _repo.ensureLoaded();
    await _repo.setMembers([..._repo.members, member]);
    await _repo
        .enqueue(PendingOperation.create('member.create', member.toJson()));
    notifyListeners();
    return true;
  }

  /// Marks a member inactive rather than deleting history (finance audit).
  /// Archived members stay out of active lists but keep their records.
  Future<bool> deactivateMember(String memberId) async {
    if (!_session.canManageMembers) return false;
    await _repo.ensureLoaded();
    final updated = _repo.members
        .map((m) => m.id == memberId ? m.copyWith(isActive: false) : m)
        .toList();
    await _repo.setMembers(updated);
    await _repo.enqueue(PendingOperation.create('member.deactivate', {
      'id': memberId,
    }));
    notifyListeners();
    return true;
  }

  /// Restores an archived member to the active roster.
  Future<bool> reactivateMember(String memberId) async {
    if (!_session.canManageMembers) return false;
    await _repo.ensureLoaded();
    final updated = _repo.members
        .map((m) => m.id == memberId ? m.copyWith(isActive: true) : m)
        .toList();
    await _repo.setMembers(updated);
    await _repo.enqueue(PendingOperation.create('member.reactivate', {
      'id': memberId,
    }));
    notifyListeners();
    return true;
  }

  Future<void> refresh() async {
    await _repo.ensureLoaded();
    notifyListeners();
  }
}
