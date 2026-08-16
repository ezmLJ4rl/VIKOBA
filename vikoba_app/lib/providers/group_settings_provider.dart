import 'package:flutter/foundation.dart';

import '../core/data/app_repository.dart';
import '../core/data/pending_operation.dart';
import '../core/state/async_state.dart';

/// Group-level settings (share value, interest, group name).
class GroupSettingsProvider extends ChangeNotifier {
  GroupSettingsProvider(this._repo);

  final AppRepository _repo;
  AsyncState _state = const AsyncState.idle();

  AsyncState get state => _state;
  double get shareValue => _repo.shareValue;
  double get interestRate => _repo.defaultInterestRate;
  String get groupName => _repo.groupName;

  Future<void> load() async {
    _state = const AsyncState.loading();
    notifyListeners();
    try {
      await _repo.ensureLoaded();
      _state = const AsyncState.loaded();
    } catch (e) {
      _state = AsyncState.failed('Could not load settings: $e');
    }
    notifyListeners();
  }

  Future<void> setShareValue(double value) async {
    if (value <= 0) return;
    await _repo.updateSettings(shareValue: value);
    await _repo.enqueue(PendingOperation.create('settings.share_value', {
      'value': value,
    }));
    notifyListeners();
  }

  Future<void> setInterestRate(double value) async {
    if (value < 0) return;
    await _repo.updateSettings(interestRate: value);
    await _repo.enqueue(PendingOperation.create('settings.interest_rate', {
      'value': value,
    }));
    notifyListeners();
  }

  Future<void> setGroupName(String name) async {
    if (name.trim().isEmpty) return;
    await _repo.updateSettings(groupName: name.trim());
    notifyListeners();
  }
}
