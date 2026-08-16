enum LoanScheduleStatus { pending, paid }

/// One installment of an amortized loan (mirror of the backend
/// `loan_schedules` table). The waterfall repays interest before principal
/// within each row, walking rows in `no` order.
class LoanSchedule {
  final int no;
  final DateTime dueDate;
  final double principalDue;
  final double interestDue;
  final double totalDue;
  final double paidPrincipal;
  final double paidInterest;
  final LoanScheduleStatus status;

  const LoanSchedule({
    required this.no,
    required this.dueDate,
    required this.principalDue,
    required this.interestDue,
    required this.totalDue,
    this.paidPrincipal = 0,
    this.paidInterest = 0,
    this.status = LoanScheduleStatus.pending,
  });

  double get balance => totalDue - (paidPrincipal + paidInterest);

  bool get isPaid => status == LoanScheduleStatus.paid;

  LoanSchedule copyWith({
    double? paidPrincipal,
    double? paidInterest,
    LoanScheduleStatus? status,
  }) {
    return LoanSchedule(
      no: no,
      dueDate: dueDate,
      principalDue: principalDue,
      interestDue: interestDue,
      totalDue: totalDue,
      paidPrincipal: paidPrincipal ?? this.paidPrincipal,
      paidInterest: paidInterest ?? this.paidInterest,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'no': no,
        'dueDate': dueDate.toIso8601String(),
        'principalDue': principalDue,
        'interestDue': interestDue,
        'totalDue': totalDue,
        'paidPrincipal': paidPrincipal,
        'paidInterest': paidInterest,
        'status': status.name,
      };

  factory LoanSchedule.fromJson(Map<String, dynamic> json) => LoanSchedule(
        no: (json['no'] as num).toInt(),
        dueDate: DateTime.parse(json['dueDate'] as String),
        principalDue: (json['principalDue'] as num).toDouble(),
        interestDue: (json['interestDue'] as num).toDouble(),
        totalDue: (json['totalDue'] as num?)?.toDouble() ??
            (json['total'] as num).toDouble(),
        paidPrincipal: (json['paidPrincipal'] as num?)?.toDouble() ?? 0,
        paidInterest: (json['paidInterest'] as num?)?.toDouble() ?? 0,
        status: LoanScheduleStatus.values
            .byName(json['status'] as String? ?? 'pending'),
      );
}
