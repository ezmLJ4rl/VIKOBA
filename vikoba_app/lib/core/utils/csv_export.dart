import '../../models/contribution.dart';
import '../../models/loan.dart';
import '../../models/member.dart';

/// Pure CSV builders for the group ledger. Each returns RFC-4180 text: cells
/// quoting embedded commas / quotes / newlines, CRLF row endings so Excel
/// opens the file cleanly.
abstract final class CsvExport {
  static String members(List<Member> members) => _build([
        ['id', 'fullName', 'phoneNumber', 'role', 'joinedDate', 'isActive',
          'totalShares', 'shareValue', 'totalContributed', 'nidaNumber'],
        for (final m in members)
          [
            m.id,
            m.fullName,
            m.phoneNumber,
            m.role.name,
            m.joinedDate.toIso8601String(),
            '${m.isActive}',
            '${m.totalShares}',
            _num(m.shareValue),
            _num(m.totalContributed),
            m.nidaNumber ?? '',
          ],
      ]);

  static String contributions(List<Contribution> contributions) => _build([
        ['id', 'memberId', 'memberName', 'sharesBought', 'amount', 'date',
          'note'],
        for (final c in contributions)
          [
            c.id,
            c.memberId,
            c.memberName,
            '${c.sharesBought}',
            _num(c.amount),
            c.date.toIso8601String(),
            c.note ?? '',
          ],
      ]);

  static String loans(List<Loan> loans) => _build([
        ['id', 'memberId', 'memberName', 'principal', 'interestRate',
          'termMonths', 'interestMethod', 'issuedDate', 'dueDate',
          'amountRepaid', 'penaltyAccrued', 'status', 'totalPayable',
          'balance'],
        for (final l in loans)
          [
            l.id,
            l.memberId,
            l.memberName,
            _num(l.principal),
            _num(l.interestRate),
            '${l.termMonths}',
            l.interestMethod.name,
            l.issuedDate.toIso8601String(),
            l.dueDate.toIso8601String(),
            _num(l.amountRepaid),
            _num(l.penaltyAccrued),
            l.status.name,
            _num(l.totalPayable),
            _num(l.balance),
          ],
      ]);

  static String _build(List<List<Object>> rows) => rows
      .map((row) => row.map(_escape).join(','))
      .join('\r\n');

  static String _escape(Object cell) {
    final s = '$cell';
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  /// Whole-shilling figures as integers (no decimal noise) — matches how the
  /// app displays money.
  static String _num(num value) => value.round().toString();
}
