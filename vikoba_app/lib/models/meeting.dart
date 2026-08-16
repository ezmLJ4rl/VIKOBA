class Meeting {
  final String id;
  final DateTime date;
  final String agenda;
  final List<String> presentMemberIds;
  final int totalMembers;

  Meeting({
    required this.id,
    required this.date,
    required this.agenda,
    required this.presentMemberIds,
    required this.totalMembers,
  });

  int get absentCount => totalMembers - presentMemberIds.length;
  double get attendanceRate =>
      totalMembers == 0 ? 0 : presentMemberIds.length / totalMembers;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'agenda': agenda,
        'presentMemberIds': presentMemberIds,
        'totalMembers': totalMembers,
      };

  factory Meeting.fromJson(Map<String, dynamic> json) => Meeting(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        agenda: json['agenda'] as String,
        presentMemberIds: (json['presentMemberIds'] as List).cast<String>(),
        totalMembers: (json['totalMembers'] as num).toInt(),
      );
}
