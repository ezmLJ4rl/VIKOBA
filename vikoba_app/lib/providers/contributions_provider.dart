import 'package:flutter/foundation.dart';

import '../core/data/app_repository.dart';
import '../core/data/pending_operation.dart';
import '../core/domain/vizoba_calc.dart';
import '../core/state/async_state.dart';
import '../core/state/notifications.dart';
import '../core/state/session.dart';
import '../models/contribution.dart';
import '../models/member.dart';

/// Contribution (share-purchase) history + group savings totals.
class ContributionsProvider extends ChangeNotifier {
  ContributionsProvider(this._repo, this._session, this._notifications);

  final AppRepository _repo;
  final Session _session;
  final NotificationsController _notifications;
  AsyncState _state = const AsyncState.idle();

  AsyncState get state => _state;

  /// Newest first (UI order).
  List<Contribution> get contributions =>
      List.unmodifiable(_repo.contributions.reversed);

  double get totalSavings => VikobaCalc.totalSavings(_repo.members);
  double get shareValue => _repo.shareValue;

  Future<void> load() async {
    _state = const AsyncState.loading();
    notifyListeners();
    try {
      await _repo.ensureLoaded();
      _state = const AsyncState.loaded();
    } catch (e) {
      _state = AsyncState.failed('Could not load contributions: $e');
    }
    notifyListeners();
  }

  /// Records [shares] bought by [member] and updates the member's running
  /// share count. Returns the amount captured (TZS) or null on invalid input
  /// or when the session lacks permission.
  Future<double?> recordContribution({
    required Member member,
    required int shares,
    String? note,
  }) async {
    if (shares <= 0) return null;
    if (!_session.canRecordContributions) return null;

    await _repo.ensureLoaded();
    final amount = shares * _repo.shareValue;

    final contribution = Contribution(
      id: 'C${_repo.contributions.length + 1}',
      memberId: member.id,
      memberName: member.fullName,
      sharesBought: shares,
      amount: amount,
      date: DateTime.now(),
      note: note,
    );

    final updatedMembers = _repo.members
        .map((m) => m.id == member.id
            ? m.copyWith(totalShares: m.totalShares + shares)
            : m)
        .toList();
    await _repo.setMembers(updatedMembers);
    await _repo.setContributions([..._repo.contributions, contribution]);
    await _repo.enqueue(PendingOperation.create(
        'contribution.create',
        contribution.toJson()..['phoneNumber'] = member.phoneNumber));
    await _notifications.add(
      memberId: member.id,
      kind: NotificationKind.contribution,
      amount: amount,
    );
    notifyListeners();
    return amount;
  }

  Future<void> refresh() async {
    await _repo.ensureLoaded();
    notifyListeners();
  }
}
