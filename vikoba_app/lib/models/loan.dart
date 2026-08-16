import 'loan_product.dart';
import 'loan_schedule.dart';

enum LoanStatus { pending, approved, active, repaid, rejected }

class Loan {
  final String id;
  final String memberId;
  final String memberName;
  final double principal;
  final double interestRate; // percentage per installment period, e.g. 10
  final String? loanProductId;
  final int termMonths;
  final LoanInterestMethod interestMethod;
  final int installmentIntervalDays;
  final DateTime issuedDate;
  final DateTime dueDate;
  final DateTime? disbursedAt;
  final double amountRepaid;
  final double penaltyAccrued;
  final LoanStatus status;
  final List<LoanSchedule> schedules;
  final List<String> guarantorMemberIds;

  Loan({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.principal,
    required this.interestRate,
    required this.issuedDate,
    required this.dueDate,
    this.loanProductId,
    this.termMonths = 1,
    this.interestMethod = LoanInterestMethod.flat,
    this.installmentIntervalDays = 30,
    this.disbursedAt,
    this.amountRepaid = 0,
    this.penaltyAccrued = 0,
    this.status = LoanStatus.pending,
    this.schedules = const [],
    this.guarantorMemberIds = const [],
  });

  /// Interest charged for the whole term: the amortized schedule total when
  /// the schedule exists, otherwise flat principal x rate% x term.
  double get interestAmount => schedules.isEmpty
      ? (principal * (interestRate / 100) * termMonths).roundToDouble()
      : schedules.fold(0.0, (sum, s) => sum + s.interestDue);

  double get totalPayable => principal + interestAmount;
  double get balance => totalPayable + penaltyAccrued - amountRepaid;
  double get progress =>
      totalPayable == 0 ? 0 : (amountRepaid / totalPayable).clamp(0, 1);

  bool get isOverdue =>
      status == LoanStatus.active &&
      DateTime.now().isAfter(dueDate) &&
      balance > 0;

  bool get isFullyRepaid => balance <= 0.001;

  String get statusLabel {
    switch (status) {
      case LoanStatus.pending:
        return 'Pending Approval';
      case LoanStatus.approved:
        return 'Approved';
      case LoanStatus.active:
        return 'Active';
      case LoanStatus.repaid:
        return 'Repaid';
      case LoanStatus.rejected:
        return 'Rejected';
    }
  }

  Loan copyWith({
    double? amountRepaid,
    double? penaltyAccrued,
    LoanStatus? status,
    DateTime? dueDate,
    DateTime? disbursedAt,
    List<LoanSchedule>? schedules,
    List<String>? guarantorMemberIds,
  }) {
    return Loan(
      id: id,
      memberId: memberId,
      memberName: memberName,
      principal: principal,
      interestRate: interestRate,
      loanProductId: loanProductId,
      termMonths: termMonths,
      interestMethod: interestMethod,
      installmentIntervalDays: installmentIntervalDays,
      issuedDate: issuedDate,
      dueDate: dueDate ?? this.dueDate,
      disbursedAt: disbursedAt ?? this.disbursedAt,
      amountRepaid: amountRepaid ?? this.amountRepaid,
      penaltyAccrued: penaltyAccrued ?? this.penaltyAccrued,
      status: status ?? this.status,
      schedules: schedules ?? this.schedules,
      guarantorMemberIds: guarantorMemberIds ?? this.guarantorMemberIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'memberId': memberId,
        'memberName': memberName,
        'principal': principal,
        'interestRate': interestRate,
        'loanProductId': loanProductId,
        'termMonths': termMonths,
        'interestMethod': interestMethod.name,
        'installmentIntervalDays': installmentIntervalDays,
        'issuedDate': issuedDate.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'disbursedAt': disbursedAt?.toIso8601String(),
        'amountRepaid': amountRepaid,
        'penaltyAccrued': penaltyAccrued,
        'status': status.name,
        'schedules': schedules.map((s) => s.toJson()).toList(),
        'guarantorMemberIds': guarantorMemberIds,
      };

  factory Loan.fromJson(Map<String, dynamic> json) => Loan(
        id: json['id'] as String,
        memberId: json['memberId'] as String,
        memberName: json['memberName'] as String,
        principal: (json['principal'] as num).toDouble(),
        interestRate: (json['interestRate'] as num).toDouble(),
        loanProductId: json['loanProductId'] as String?,
        termMonths: (json['termMonths'] as num?)?.toInt() ?? 1,
        interestMethod: LoanInterestMethod.values
            .byName(json['interestMethod'] as String? ?? 'flat'),
        installmentIntervalDays:
            (json['installmentIntervalDays'] as num?)?.toInt() ?? 30,
        issuedDate: DateTime.parse(json['issuedDate'] as String),
        dueDate: DateTime.parse(json['dueDate'] as String),
        disbursedAt: json['disbursedAt'] == null
            ? null
            : DateTime.parse(json['disbursedAt'] as String),
        amountRepaid: (json['amountRepaid'] as num).toDouble(),
        penaltyAccrued: (json['penaltyAccrued'] as num?)?.toDouble() ?? 0,
        status: LoanStatus.values.byName(json['status'] as String),
        schedules: (json['schedules'] as List? ?? const [])
            .map((e) => LoanSchedule.fromJson(e as Map<String, dynamic>))
            .toList(),
        guarantorMemberIds:
            (json['guarantorMemberIds'] as List? ?? const []).cast<String>(),
      );
}
