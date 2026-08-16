import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

/// What happened. Mapped to localized text + colour in the UI; stored as a
/// stable type so message wording can change without invalidating history.
enum NotificationKind {
  contribution,
  loanRequested,
  loanApproved,
  loanRejected,
  repayment,
  attendancePresent,
  attendanceAbsent,
}

/// A group event tied to one member's records. Members read & dismiss these;
/// they are never actionable (viewing never mutates the underlying record).
@immutable
class GroupNotification {
  const GroupNotification({
    required this.id,
    required this.memberId,
    required this.kind,
    required this.at,
    required this.amount,
    this.read = false,
  });

  final String id;
  final String memberId;
  final NotificationKind kind;
  final DateTime at;
  final double amount;

  /// Amount in TZS shown in the body (0 for events without money).
  final bool read;

  Color get tint => switch (kind) {
        NotificationKind.contribution ||
        NotificationKind.repayment ||
        NotificationKind.attendancePresent =>
          AppColors.forest,
        NotificationKind.loanRequested => AppColors.statusPending,
        NotificationKind.loanApproved => AppColors.forest,
        NotificationKind.loanRejected ||
        NotificationKind.attendanceAbsent =>
          AppColors.statusAttention,
      };

  GroupNotification markRead() => GroupNotification(
        id: id,
        memberId: memberId,
        kind: kind,
        at: at,
        amount: amount,
        read: true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'memberId': memberId,
        'kind': kind.name,
        'at': at.toIso8601String(),
        'amount': amount,
        'read': read,
      };

  factory GroupNotification.fromJson(Map<String, dynamic> json) =>
      GroupNotification(
        id: json['id'] as String,
        memberId: json['memberId'] as String,
        kind: NotificationKind.values.byName(json['kind'] as String),
        at: DateTime.parse(json['at'] as String),
        amount: (json['amount'] as num).toDouble(),
        read: json['read'] as bool? ?? false,
      );
}

/// Notification inbox, persisted locally. Events are appended by the domain
/// providers whenever a member's own record changes; the UI filters by the
/// current account.
class NotificationsController extends ChangeNotifier {
  NotificationsController();

  static const _prefsKey = 'vikoba.notifications';

  List<GroupNotification> _items = [];

  List<GroupNotification> get items => List.unmodifiable(_items);

  /// Newest first.
  List<GroupNotification> forMember(String memberId) =>
      _items.where((n) => n.memberId == memberId).toList().reversed.toList();

  int unreadFor(String memberId) =>
      _items.where((n) => n.memberId == memberId && !n.read).length;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => GroupNotification.fromJson(e as Map<String, dynamic>))
          .toList();
      _items = list;
      notifyListeners();
    } catch (_) {
      // Corrupt inbox — start fresh.
    }
  }

  Future<void> add({
    required String memberId,
    required NotificationKind kind,
    double amount = 0,
  }) async {
    _items.add(GroupNotification(
      id: 'N${_items.length + 1}',
      memberId: memberId,
      kind: kind,
      at: DateTime.now(),
      amount: amount,
    ));
    notifyListeners();
    await _persist();
  }

  Future<void> markRead(String id) async {
    _items = [
      for (final n in _items) n.id == id ? n.markRead() : n,
    ];
    notifyListeners();
    await _persist();
  }

  Future<void> markAllRead(String memberId) async {
    _items = [
      for (final n in _items)
        n.memberId == memberId ? n.markRead() : n,
    ];
    notifyListeners();
    await _persist();
  }

  /// Demo seed so a member preview has content on first launch.
  Future<void> seedForMember(String memberId) async {
    if (_items.any((n) => n.memberId == memberId)) return;
    final now = DateTime.now();
    _items.addAll([
      GroupNotification(
        id: 'N1',
        memberId: memberId,
        kind: NotificationKind.loanApproved,
        at: now.subtract(const Duration(days: 10)),
        amount: 100000,
        read: true,
      ),
      GroupNotification(
        id: 'N2',
        memberId: memberId,
        kind: NotificationKind.repayment,
        at: now.subtract(const Duration(days: 8)),
        amount: 110000,
        read: true,
      ),
      GroupNotification(
        id: 'N3',
        memberId: memberId,
        kind: NotificationKind.contribution,
        at: now.subtract(const Duration(days: 3)),
        amount: 20000,
      ),
    ]);
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _prefsKey, jsonEncode([for (final n in _items) n.toJson()]));
  }
}
