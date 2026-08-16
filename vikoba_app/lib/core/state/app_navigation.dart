import 'package:flutter/foundation.dart';

/// Which primary create-flow a screen should auto-open on arrival.
///
/// Set by dashboard quick actions; the target screen consumes it once via
/// [AppNavigation.takePending] and opens its bottom sheet.
enum PendingAction { addContribution, addLoanRequest, addMember }

/// Lightweight cross-tab navigation controller.
///
/// Lets the dashboard quick-actions jump to a tab AND open that tab's primary
/// create sheet in one step, without screens reaching into each other.
class AppNavigation extends ChangeNotifier {
  int _index = 0;
  int get index => _index;

  PendingAction? _pending;

  /// Returns and clears the pending action (so it fires exactly once).
  PendingAction? takePending() {
    final pending = _pending;
    _pending = null;
    return pending;
  }

  void goTo(int index, [PendingAction? action]) {
    _index = index;
    _pending = action;
    notifyListeners();
  }
}