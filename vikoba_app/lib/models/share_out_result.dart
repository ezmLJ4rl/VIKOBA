import 'member.dart';

/// Result of running the cycle-end share-out for one member.
///
/// A member's payout = their own savings (shares they hold x share value)
/// plus their **proportional** share of the interest the group earned from
/// loans, weighted by how many shares they hold relative to the group total.
class ShareOutResult {
  final Member member;
  final double savings;
  final double interestShare;
  final double totalPayout;
  final double shareProportion;

  const ShareOutResult({
    required this.member,
    required this.savings,
    required this.interestShare,
    required this.totalPayout,
    required this.shareProportion,
  });
}
