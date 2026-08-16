enum LoanInterestMethod { flat, reducing }

enum PenaltyType { flat, percent }

/// A group-configurable loan product (mirror of the backend `loan_products`
/// table). Rate and penalty rules come from here — the request form reads a
/// product so the quote preview and the server always agree.
class LoanProduct {
  final String id;
  final String name;
  final String? description;
  final double interestRate;
  final LoanInterestMethod interestMethod;
  final int maxTermMonths;
  final int maxMultiplier;
  final double minAmount;
  final PenaltyType penaltyType;
  final double penaltyValue;
  final int penaltyGraceDays;
  final int penaltyPeriodDays;
  final int installmentIntervalDays;
  final bool isActive;

  const LoanProduct({
    required this.id,
    required this.name,
    required this.interestRate,
    required this.interestMethod,
    required this.maxTermMonths,
    required this.maxMultiplier,
    required this.minAmount,
    required this.penaltyType,
    required this.penaltyValue,
    required this.penaltyGraceDays,
    required this.penaltyPeriodDays,
    this.description,
    this.installmentIntervalDays = 30,
    this.isActive = true,
  });

  String get methodLabel => switch (interestMethod) {
        LoanInterestMethod.flat => 'Flat',
        LoanInterestMethod.reducing => 'Reducing',
      };

  LoanProduct copyWith({
    String? name,
    double? interestRate,
    LoanInterestMethod? interestMethod,
    int? maxTermMonths,
    int? maxMultiplier,
    double? minAmount,
    PenaltyType? penaltyType,
    double? penaltyValue,
    int? penaltyGraceDays,
    int? penaltyPeriodDays,
    int? installmentIntervalDays,
    bool? isActive,
  }) {
    return LoanProduct(
      id: id,
      name: name ?? this.name,
      description: description,
      interestRate: interestRate ?? this.interestRate,
      interestMethod: interestMethod ?? this.interestMethod,
      maxTermMonths: maxTermMonths ?? this.maxTermMonths,
      maxMultiplier: maxMultiplier ?? this.maxMultiplier,
      minAmount: minAmount ?? this.minAmount,
      penaltyType: penaltyType ?? this.penaltyType,
      penaltyValue: penaltyValue ?? this.penaltyValue,
      penaltyGraceDays: penaltyGraceDays ?? this.penaltyGraceDays,
      penaltyPeriodDays: penaltyPeriodDays ?? this.penaltyPeriodDays,
      installmentIntervalDays:
          installmentIntervalDays ?? this.installmentIntervalDays,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'interestRate': interestRate,
        'interestMethod': interestMethod.name,
        'maxTermMonths': maxTermMonths,
        'maxMultiplier': maxMultiplier,
        'minAmount': minAmount,
        'penaltyType': penaltyType.name,
        'penaltyValue': penaltyValue,
        'penaltyGraceDays': penaltyGraceDays,
        'penaltyPeriodDays': penaltyPeriodDays,
        'installmentIntervalDays': installmentIntervalDays,
        'isActive': isActive,
      };

  factory LoanProduct.fromJson(Map<String, dynamic> json) => LoanProduct(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        interestRate: (json['interestRate'] as num).toDouble(),
        interestMethod: LoanInterestMethod.values
            .byName(json['interestMethod'] as String? ?? 'flat'),
        maxTermMonths: (json['maxTermMonths'] as num?)?.toInt() ?? 12,
        maxMultiplier: (json['maxMultiplier'] as num?)?.toInt() ?? 4,
        minAmount: (json['minAmount'] as num?)?.toDouble() ?? 20000,
        penaltyType: PenaltyType.values
            .byName(json['penaltyType'] as String? ?? 'flat'),
        penaltyValue: (json['penaltyValue'] as num?)?.toDouble() ?? 0,
        penaltyGraceDays: (json['penaltyGraceDays'] as num?)?.toInt() ?? 0,
        penaltyPeriodDays: (json['penaltyPeriodDays'] as num?)?.toInt() ?? 7,
        installmentIntervalDays:
            (json['installmentIntervalDays'] as num?)?.toInt() ?? 30,
        isActive: json['isActive'] as bool? ?? true,
      );
}
