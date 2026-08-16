import '../../models/contribution.dart';
import '../../models/loan.dart';
import '../../models/loan_product.dart';
import '../../models/meeting.dart';
import '../../models/member.dart';

/// An immutable snapshot of everything the app persists.
///
/// The repository treats this as a single document (JSON in local storage for
/// the MVP). Once the group data outgrows a single document, the
/// implementation should swap the backing store for Hive or Drift (SQLite)
/// tables — the repository interface hides that decision from providers.
class PersistedSnapshot {
  final String groupName;
  final double shareValue;
  final double defaultInterestRate;
  final int minMembershipDays;
  final List<Member> members;
  final List<Contribution> contributions;
  final List<Loan> loans;
  final List<LoanProduct> loanProducts;
  final List<Meeting> meetings;

  const PersistedSnapshot({
    this.groupName = 'Vikoba Group',
    this.shareValue = 10000,
    this.defaultInterestRate = 10,
    this.minMembershipDays = 30,
    this.members = const [],
    this.contributions = const [],
    this.loans = const [],
    this.loanProducts = const [],
    this.meetings = const [],
  });

  PersistedSnapshot copyWith({
    String? groupName,
    double? shareValue,
    double? defaultInterestRate,
    int? minMembershipDays,
    List<Member>? members,
    List<Contribution>? contributions,
    List<Loan>? loans,
    List<LoanProduct>? loanProducts,
    List<Meeting>? meetings,
  }) =>
      PersistedSnapshot(
        groupName: groupName ?? this.groupName,
        shareValue: shareValue ?? this.shareValue,
        defaultInterestRate: defaultInterestRate ?? this.defaultInterestRate,
        minMembershipDays: minMembershipDays ?? this.minMembershipDays,
        members: members ?? this.members,
        contributions: contributions ?? this.contributions,
        loans: loans ?? this.loans,
        loanProducts: loanProducts ?? this.loanProducts,
        meetings: meetings ?? this.meetings,
      );

  Map<String, dynamic> toJson() => {
        'groupName': groupName,
        'shareValue': shareValue,
        'interestRate': defaultInterestRate,
        'minMembershipDays': minMembershipDays,
        'members': members.map((m) => m.toJson()).toList(),
        'contributions': contributions.map((c) => c.toJson()).toList(),
        'loans': loans.map((l) => l.toJson()).toList(),
        'loanProducts': loanProducts.map((p) => p.toJson()).toList(),
        'meetings': meetings.map((m) => m.toJson()).toList(),
      };

  factory PersistedSnapshot.fromJson(Map<String, dynamic> json) =>
      PersistedSnapshot(
        groupName: json['groupName'] as String? ?? 'Vikoba Group',
        shareValue: (json['shareValue'] as num?)?.toDouble() ?? 10000,
        defaultInterestRate: (json['interestRate'] as num?)?.toDouble() ?? 10,
        minMembershipDays: (json['minMembershipDays'] as num?)?.toInt() ?? 30,
        members: (json['members'] as List? ?? const [])
            .map((e) => Member.fromJson(e as Map<String, dynamic>))
            .toList(),
        contributions: (json['contributions'] as List? ?? const [])
            .map((e) => Contribution.fromJson(e as Map<String, dynamic>))
            .toList(),
        loans: (json['loans'] as List? ?? const [])
            .map((e) => Loan.fromJson(e as Map<String, dynamic>))
            .toList(),
        loanProducts: (json['loanProducts'] as List? ?? const [])
            .map((e) => LoanProduct.fromJson(e as Map<String, dynamic>))
            .toList(),
        meetings: (json['meetings'] as List? ?? const [])
            .map((e) => Meeting.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
