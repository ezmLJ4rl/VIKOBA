/// A queued operation that must eventually reach the backend.
///
/// The Flutter app is offline-first: every local mutation is written to local
/// storage immediately, and a copy is queued here so `SyncProvider` can push
/// it to the API when connectivity returns. Operations carry an
/// [idempotencyKey] so the server can safely replay them (it ignores a
/// request that was already recorded) — this is what makes retries safe and
/// prevents double-recording a contribution or repayment.
class PendingOperation {
  final String id;
  final String type; // e.g. 'contribution.create', 'repayment.create', ...
  final Map<String, dynamic> payload;
  final String idempotencyKey;
  final DateTime createdAt;
  final int attempts;

  const PendingOperation({
    required this.id,
    required this.type,
    required this.payload,
    required this.idempotencyKey,
    required this.createdAt,
    this.attempts = 0,
  });

  PendingOperation copyWith({int? attempts}) => PendingOperation(
        id: id,
        type: type,
        payload: payload,
        idempotencyKey: idempotencyKey,
        createdAt: createdAt,
        attempts: attempts ?? this.attempts,
      );

  /// Builds a queue item with a fresh unique id + idempotency key. The key is
  /// stable for the life of the operation, so a retry re-sends the SAME key and
  /// the server can recognize a duplicate.
  factory PendingOperation.create(
    String type,
    Map<String, dynamic> payload,
  ) {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    return PendingOperation(
      id: id,
      type: type,
      payload: payload,
      idempotencyKey: id,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'payload': payload,
        'idempotencyKey': idempotencyKey,
        'createdAt': createdAt.toIso8601String(),
        'attempts': attempts,
      };

  factory PendingOperation.fromJson(Map<String, dynamic> json) =>
      PendingOperation(
        id: json['id'] as String,
        type: json['type'] as String,
        payload: (json['payload'] as Map).cast<String, dynamic>(),
        idempotencyKey: json['idempotencyKey'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      );
}
