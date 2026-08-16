enum MemberRole { chairperson, treasurer, secretary, member }

class Member {
  final String id;
  final String fullName;
  final String phoneNumber;
  final MemberRole role;
  final DateTime joinedDate;
  final int totalShares;
  final double shareValue; // value of ONE share in TZS
  final bool isActive;
  final String? nidaNumber;
  final String? photoPath;

  Member({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    required this.joinedDate,
    required this.totalShares,
    required this.shareValue,
    this.isActive = true,
    this.nidaNumber,
    this.photoPath,
  });

  double get totalContributed => totalShares * shareValue;

  /// Days since joining (used by the membership-days eligibility rule).
  int get membershipDays =>
      DateTime.now().difference(joinedDate).inDays.clamp(0, 1 << 31);

  String get roleLabel {
    switch (role) {
      case MemberRole.chairperson:
        return 'Chairperson';
      case MemberRole.treasurer:
        return 'Treasurer';
      case MemberRole.secretary:
        return 'Secretary';
      case MemberRole.member:
        return 'Member';
    }
  }

  Member copyWith({int? totalShares, bool? isActive}) {
    return Member(
      id: id,
      fullName: fullName,
      phoneNumber: phoneNumber,
      role: role,
      joinedDate: joinedDate,
      totalShares: totalShares ?? this.totalShares,
      shareValue: shareValue,
      isActive: isActive ?? this.isActive,
      nidaNumber: nidaNumber,
      photoPath: photoPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'role': role.name,
        'joinedDate': joinedDate.toIso8601String(),
        'totalShares': totalShares,
        'shareValue': shareValue,
        'isActive': isActive,
        'nidaNumber': nidaNumber,
        'photoPath': photoPath,
      };

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        phoneNumber: json['phoneNumber'] as String,
        role: MemberRole.values.byName(json['role'] as String),
        joinedDate: DateTime.parse(json['joinedDate'] as String),
        totalShares: (json['totalShares'] as num).toInt(),
        shareValue: (json['shareValue'] as num).toDouble(),
        isActive: json['isActive'] as bool? ?? true,
        nidaNumber: json['nidaNumber'] as String?,
        photoPath: json['photoPath'] as String?,
      );
}
