import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shared configuration for the app. Keeping these in one place makes it easy
/// for a treasurer to tune the rules (to match the group's constitution)
/// without touching business logic.
abstract final class AppConfig {
  static const String appTitle = 'Vikoba Manager';
  static const String defaultGroupName = 'Vikoba Group';

  /// Default price of a single share (TZS).
  static const double defaultShareValue = 10000;

  /// Default interest rate in percent per loan cycle.
  static const double defaultInterestRate = 10;

  /// Minimum loan the group hands out.
  static const double minLoanAmount = 20000;

  /// Maximum loan relative to a member's own savings.
  static const double maxLoanMultiple = 4;

  /// Repayment periods offered in the loan request sheet (days).
  static const List<int> loanRepaymentPeriods = [30, 60, 90];
}

/// Kitenge-inspired palette used by charts so share-out slices stay
/// distinguishable even in greyscale printing (statements often get
/// photocopied).
final List<Color> kChartPalette = [
  AppColors.forest,
  AppColors.gold,
  AppColors.clay,
  AppColors.forestDeep,
  AppColors.goldSoft,
  AppColors.stone,
];
