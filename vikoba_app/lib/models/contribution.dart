class Contribution {
  final String id;
  final String memberId;
  final String memberName;
  final int sharesBought;
  final double amount; // TZS
  final DateTime date;
  final String? note;

  Contribution({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.sharesBought,
    required this.amount,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'memberId': memberId,
        'memberName': memberName,
        'sharesBought': sharesBought,
        'amount': amount,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory Contribution.fromJson(Map<String, dynamic> json) => Contribution(
        id: json['id'] as String,
        memberId: json['memberId'] as String,
        memberName: json['memberName'] as String,
        sharesBought: (json['sharesBought'] as num).toInt(),
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
        note: json['note'] as String?,
      );
}
