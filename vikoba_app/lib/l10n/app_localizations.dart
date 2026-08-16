import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sw')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Vikoba Manager'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get navMembers;

  /// No description provided for @navSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get navSavings;

  /// No description provided for @navLoans.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get navLoans;

  /// No description provided for @navShareOut.
  ///
  /// In en, this message translates to:
  /// **'Share-Out'**
  String get navShareOut;

  /// No description provided for @appBarDashboard.
  ///
  /// In en, this message translates to:
  /// **'Vikoba Dashboard'**
  String get appBarDashboard;

  /// No description provided for @appBarMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get appBarMembers;

  /// No description provided for @appBarContributions.
  ///
  /// In en, this message translates to:
  /// **'Contributions'**
  String get appBarContributions;

  /// No description provided for @appBarLoans.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get appBarLoans;

  /// No description provided for @appBarShareOut.
  ///
  /// In en, this message translates to:
  /// **'Share-Out Calculator'**
  String get appBarShareOut;

  /// No description provided for @dashboardGroupOverview.
  ///
  /// In en, this message translates to:
  /// **'Group Overview'**
  String get dashboardGroupOverview;

  /// No description provided for @totalGroupSavings.
  ///
  /// In en, this message translates to:
  /// **'Total Group Savings'**
  String get totalGroupSavings;

  /// No description provided for @activeLoansValue.
  ///
  /// In en, this message translates to:
  /// **'Active Loans'**
  String get activeLoansValue;

  /// No description provided for @interestEarned.
  ///
  /// In en, this message translates to:
  /// **'Interest Earned'**
  String get interestEarned;

  /// No description provided for @activeMembers.
  ///
  /// In en, this message translates to:
  /// **'Active Members'**
  String get activeMembers;

  /// No description provided for @recentContributions.
  ///
  /// In en, this message translates to:
  /// **'Recent Contributions'**
  String get recentContributions;

  /// No description provided for @loansNeedingAttention.
  ///
  /// In en, this message translates to:
  /// **'Loans Needing Attention'**
  String get loansNeedingAttention;

  /// No description provided for @noContributionsYet.
  ///
  /// In en, this message translates to:
  /// **'No contributions recorded yet'**
  String get noContributionsYet;

  /// No description provided for @nothingNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Nothing needs attention right now'**
  String get nothingNeedsAttention;

  /// No description provided for @awaitingDisbursement.
  ///
  /// In en, this message translates to:
  /// **'Awaiting disbursement'**
  String get awaitingDisbursement;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @sharesPrefix.
  ///
  /// In en, this message translates to:
  /// **'{count} shares - {date}'**
  String sharesPrefix(int count, String date);

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get addMember;

  /// No description provided for @totalShares.
  ///
  /// In en, this message translates to:
  /// **'Total shares'**
  String get totalShares;

  /// No description provided for @totalContributed.
  ///
  /// In en, this message translates to:
  /// **'Total contributed'**
  String get totalContributed;

  /// No description provided for @noMembersYet.
  ///
  /// In en, this message translates to:
  /// **'No members yet. Tap \'Add Member\' to register someone.'**
  String get noMembersYet;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @saveMember.
  ///
  /// In en, this message translates to:
  /// **'Save Member'**
  String get saveMember;

  /// No description provided for @memberSharesSuffix.
  ///
  /// In en, this message translates to:
  /// **'{count} shares'**
  String memberSharesSuffix(int count);

  /// No description provided for @searchMembers.
  ///
  /// In en, this message translates to:
  /// **'Search members'**
  String get searchMembers;

  /// No description provided for @noMembersFound.
  ///
  /// In en, this message translates to:
  /// **'No members match your search.'**
  String get noMembersFound;

  /// No description provided for @memberDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Member profile'**
  String get memberDetailTitle;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String memberSince(String date);

  /// No description provided for @membershipDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Member for {days} days'**
  String membershipDaysLabel(int days);

  /// No description provided for @joinedDate.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joinedDate;

  /// No description provided for @nidaNumber.
  ///
  /// In en, this message translates to:
  /// **'NIDA number'**
  String get nidaNumber;

  /// No description provided for @memberStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get memberStatusActive;

  /// No description provided for @memberStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get memberStatusInactive;

  /// No description provided for @loanCapacity.
  ///
  /// In en, this message translates to:
  /// **'Loan capacity'**
  String get loanCapacity;

  /// No description provided for @guarantorExposure.
  ///
  /// In en, this message translates to:
  /// **'Guarantor exposure'**
  String get guarantorExposure;

  /// No description provided for @memberLoans.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get memberLoans;

  /// No description provided for @memberContributions.
  ///
  /// In en, this message translates to:
  /// **'Contributions'**
  String get memberContributions;

  /// No description provided for @noMemberLoans.
  ///
  /// In en, this message translates to:
  /// **'No loans recorded for this member yet.'**
  String get noMemberLoans;

  /// No description provided for @noMemberContributions.
  ///
  /// In en, this message translates to:
  /// **'No contributions recorded for this member yet.'**
  String get noMemberContributions;

  /// No description provided for @deactivateMember.
  ///
  /// In en, this message translates to:
  /// **'Deactivate member'**
  String get deactivateMember;

  /// No description provided for @reactivateMember.
  ///
  /// In en, this message translates to:
  /// **'Reactivate member'**
  String get reactivateMember;

  /// No description provided for @deactivateConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Deactivate member?'**
  String get deactivateConfirmTitle;

  /// No description provided for @deactivateConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Stop {name} from contributing, taking loans and attending meetings? Their history stays on record.'**
  String deactivateConfirmBody(String name);

  /// No description provided for @memberDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Member deactivated'**
  String get memberDeactivated;

  /// No description provided for @memberReactivated.
  ///
  /// In en, this message translates to:
  /// **'Member reactivated'**
  String get memberReactivated;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @recordContribution.
  ///
  /// In en, this message translates to:
  /// **'Record Contribution'**
  String get recordContribution;

  /// No description provided for @record.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get record;

  /// No description provided for @lastContribution.
  ///
  /// In en, this message translates to:
  /// **'Last contribution'**
  String get lastContribution;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @numberOfShares.
  ///
  /// In en, this message translates to:
  /// **'Number of shares'**
  String get numberOfShares;

  /// No description provided for @oneShareHelper.
  ///
  /// In en, this message translates to:
  /// **'1 share = {amount}'**
  String oneShareHelper(String amount);

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total amount'**
  String get totalAmount;

  /// No description provided for @saveContribution.
  ///
  /// In en, this message translates to:
  /// **'Save Contribution'**
  String get saveContribution;

  /// No description provided for @newLoan.
  ///
  /// In en, this message translates to:
  /// **'New Loan'**
  String get newLoan;

  /// No description provided for @newLoanRequest.
  ///
  /// In en, this message translates to:
  /// **'New Loan Request'**
  String get newLoanRequest;

  /// No description provided for @loanAmount.
  ///
  /// In en, this message translates to:
  /// **'Loan amount (TZS)'**
  String get loanAmount;

  /// No description provided for @interestRateHelper.
  ///
  /// In en, this message translates to:
  /// **'Interest rate: {rate}%'**
  String interestRateHelper(String rate);

  /// No description provided for @repaymentPeriod.
  ///
  /// In en, this message translates to:
  /// **'Repayment period'**
  String get repaymentPeriod;

  /// No description provided for @daysPeriod.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String daysPeriod(int days);

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @principal.
  ///
  /// In en, this message translates to:
  /// **'Principal'**
  String get principal;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @disburse.
  ///
  /// In en, this message translates to:
  /// **'Disburse'**
  String get disburse;

  /// No description provided for @recordRepayment.
  ///
  /// In en, this message translates to:
  /// **'Record Repayment'**
  String get recordRepayment;

  /// No description provided for @repaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Repayment - {name}'**
  String repaymentTitle(String name);

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @amountTzs.
  ///
  /// In en, this message translates to:
  /// **'Amount (TZS)'**
  String get amountTzs;

  /// No description provided for @saveRepayment.
  ///
  /// In en, this message translates to:
  /// **'Save Repayment'**
  String get saveRepayment;

  /// No description provided for @repaidOf.
  ///
  /// In en, this message translates to:
  /// **'{amount} of {total} repaid'**
  String repaidOf(String amount, String total);

  /// No description provided for @noLoansYet.
  ///
  /// In en, this message translates to:
  /// **'No loans yet'**
  String get noLoansYet;

  /// No description provided for @pendingLoans.
  ///
  /// In en, this message translates to:
  /// **'Pending loans'**
  String get pendingLoans;

  /// No description provided for @loanEligibilityError.
  ///
  /// In en, this message translates to:
  /// **'Request exceeds what this member may borrow per group rules.'**
  String get loanEligibilityError;

  /// No description provided for @loanEligibilityOpen.
  ///
  /// In en, this message translates to:
  /// **'This member still has an approved or active loan.'**
  String get loanEligibilityOpen;

  /// No description provided for @loanBelowMinimum.
  ///
  /// In en, this message translates to:
  /// **'Amount is below the group\'s minimum loan.'**
  String get loanBelowMinimum;

  /// No description provided for @loanSelfRequestHint.
  ///
  /// In en, this message translates to:
  /// **'Submitted to the leaders for approval — you\'ll be notified of the decision.'**
  String get loanSelfRequestHint;

  /// No description provided for @loanProduct.
  ///
  /// In en, this message translates to:
  /// **'Loan product'**
  String get loanProduct;

  /// No description provided for @loanProductHelper.
  ///
  /// In en, this message translates to:
  /// **'The product sets the interest method, term limit and penalty rules.'**
  String get loanProductHelper;

  /// No description provided for @loanTermMonths.
  ///
  /// In en, this message translates to:
  /// **'Repayment term (months)'**
  String get loanTermMonths;

  /// No description provided for @monthsPeriod.
  ///
  /// In en, this message translates to:
  /// **'{count} months'**
  String monthsPeriod(int count);

  /// No description provided for @guarantors.
  ///
  /// In en, this message translates to:
  /// **'Guarantors (up to 2)'**
  String get guarantors;

  /// No description provided for @guarantorHint.
  ///
  /// In en, this message translates to:
  /// **'A guarantor shares responsibility for this loan.'**
  String get guarantorHint;

  /// No description provided for @guarantorSelect.
  ///
  /// In en, this message translates to:
  /// **'Choose a guarantor'**
  String get guarantorSelect;

  /// No description provided for @guarantorNone.
  ///
  /// In en, this message translates to:
  /// **'No guarantor'**
  String get guarantorNone;

  /// No description provided for @noProductsYet.
  ///
  /// In en, this message translates to:
  /// **'No loan products configured yet.'**
  String get noProductsYet;

  /// No description provided for @loanEligibleOk.
  ///
  /// In en, this message translates to:
  /// **'Eligible — submit to proceed.'**
  String get loanEligibleOk;

  /// No description provided for @loanMemberInactive.
  ///
  /// In en, this message translates to:
  /// **'This member is not active.'**
  String get loanMemberInactive;

  /// No description provided for @loanMembershipTooShort.
  ///
  /// In en, this message translates to:
  /// **'This member joined too recently to borrow yet.'**
  String get loanMembershipTooShort;

  /// No description provided for @loanTermTooLong.
  ///
  /// In en, this message translates to:
  /// **'The term exceeds this product\'s maximum.'**
  String get loanTermTooLong;

  /// No description provided for @loanMaxAllowedHint.
  ///
  /// In en, this message translates to:
  /// **'Maximum allowed: {amount}'**
  String loanMaxAllowedHint(String amount);

  /// No description provided for @quoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Loan quote'**
  String get quoteTitle;

  /// No description provided for @quoteTotalInterest.
  ///
  /// In en, this message translates to:
  /// **'Total interest'**
  String get quoteTotalInterest;

  /// No description provided for @quoteTotalPayable.
  ///
  /// In en, this message translates to:
  /// **'Total to repay'**
  String get quoteTotalPayable;

  /// No description provided for @quoteMonthlyInstallment.
  ///
  /// In en, this message translates to:
  /// **'Monthly installment'**
  String get quoteMonthlyInstallment;

  /// No description provided for @quoteMethodFlat.
  ///
  /// In en, this message translates to:
  /// **'Flat rate'**
  String get quoteMethodFlat;

  /// No description provided for @quoteMethodReducing.
  ///
  /// In en, this message translates to:
  /// **'Reducing balance'**
  String get quoteMethodReducing;

  /// No description provided for @quoteInstallments.
  ///
  /// In en, this message translates to:
  /// **'{count} installments'**
  String quoteInstallments(int count);

  /// No description provided for @penaltyAccrued.
  ///
  /// In en, this message translates to:
  /// **'Penalty accrued'**
  String get penaltyAccrued;

  /// No description provided for @penaltyRateHint.
  ///
  /// In en, this message translates to:
  /// **'{value} per {days} days late after grace'**
  String penaltyRateHint(String value, int days);

  /// No description provided for @loanDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Loan details'**
  String get loanDetailTitle;

  /// No description provided for @scheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Repayment schedule'**
  String get scheduleTitle;

  /// No description provided for @installmentShort.
  ///
  /// In en, this message translates to:
  /// **'Installment'**
  String get installmentShort;

  /// No description provided for @installmentTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get installmentTotal;

  /// No description provided for @dueOn.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String dueOn(String date);

  /// No description provided for @paidLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidLabel;

  /// No description provided for @unpaidLabel.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get unpaidLabel;

  /// No description provided for @waterfallPenalty.
  ///
  /// In en, this message translates to:
  /// **'Penalty paid'**
  String get waterfallPenalty;

  /// No description provided for @waterfallInterest.
  ///
  /// In en, this message translates to:
  /// **'Interest paid'**
  String get waterfallInterest;

  /// No description provided for @waterfallPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Principal paid'**
  String get waterfallPrincipal;

  /// No description provided for @overpaymentReturned.
  ///
  /// In en, this message translates to:
  /// **'Overpayment returned: {amount}'**
  String overpaymentReturned(String amount);

  /// No description provided for @guarantorsList.
  ///
  /// In en, this message translates to:
  /// **'Guarantors'**
  String get guarantorsList;

  /// No description provided for @noGuarantors.
  ///
  /// In en, this message translates to:
  /// **'No guarantors'**
  String get noGuarantors;

  /// No description provided for @loanAmountRepaid.
  ///
  /// In en, this message translates to:
  /// **'Repaid'**
  String get loanAmountRepaid;

  /// No description provided for @totalPayableToMembers.
  ///
  /// In en, this message translates to:
  /// **'Total Payable to Members'**
  String get totalPayableToMembers;

  /// No description provided for @shareOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Savings + proportional interest earned, calculated automatically'**
  String get shareOutSubtitle;

  /// No description provided for @perMemberBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Per-Member Breakdown'**
  String get perMemberBreakdown;

  /// No description provided for @savings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savings;

  /// No description provided for @interestShare.
  ///
  /// In en, this message translates to:
  /// **'Interest share'**
  String get interestShare;

  /// No description provided for @totalPayout.
  ///
  /// In en, this message translates to:
  /// **'Total payout'**
  String get totalPayout;

  /// No description provided for @savingsPoolComposition.
  ///
  /// In en, this message translates to:
  /// **'Savings Pool Composition'**
  String get savingsPoolComposition;

  /// No description provided for @noSharesYet.
  ///
  /// In en, this message translates to:
  /// **'No shares recorded yet'**
  String get noSharesYet;

  /// No description provided for @ofPool.
  ///
  /// In en, this message translates to:
  /// **'{pct}% of pool'**
  String ofPool(String pct);

  /// No description provided for @appBarMeetings.
  ///
  /// In en, this message translates to:
  /// **'Meetings'**
  String get appBarMeetings;

  /// No description provided for @noMeetingsYet.
  ///
  /// In en, this message translates to:
  /// **'No meetings recorded yet.'**
  String get noMeetingsYet;

  /// No description provided for @newMeeting.
  ///
  /// In en, this message translates to:
  /// **'Log Meeting'**
  String get newMeeting;

  /// No description provided for @meetingDate.
  ///
  /// In en, this message translates to:
  /// **'Meeting date'**
  String get meetingDate;

  /// No description provided for @meetingAgenda.
  ///
  /// In en, this message translates to:
  /// **'Agenda'**
  String get meetingAgenda;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @presentMembers.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get presentMembers;

  /// No description provided for @absentCount.
  ///
  /// In en, this message translates to:
  /// **'{count} absent'**
  String absentCount(int count);

  /// No description provided for @attendanceRate.
  ///
  /// In en, this message translates to:
  /// **'{pct}% attendance'**
  String attendanceRate(String pct);

  /// No description provided for @saveMeeting.
  ///
  /// In en, this message translates to:
  /// **'Save Meeting'**
  String get saveMeeting;

  /// No description provided for @logAttendance.
  ///
  /// In en, this message translates to:
  /// **'Mark attendance'**
  String get logAttendance;

  /// No description provided for @agendaLabel.
  ///
  /// In en, this message translates to:
  /// **'Agenda'**
  String get agendaLabel;

  /// No description provided for @appBarReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get appBarReports;

  /// No description provided for @reportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export records for the group ledger.'**
  String get reportsSubtitle;

  /// No description provided for @reportMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get reportMembers;

  /// No description provided for @reportContributions.
  ///
  /// In en, this message translates to:
  /// **'Contributions'**
  String get reportContributions;

  /// No description provided for @reportLoans.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get reportLoans;

  /// No description provided for @reportRows.
  ///
  /// In en, this message translates to:
  /// **'{count} rows'**
  String reportRows(int count);

  /// No description provided for @copyCsv.
  ///
  /// In en, this message translates to:
  /// **'Copy CSV'**
  String get copyCsv;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @csvPreview.
  ///
  /// In en, this message translates to:
  /// **'CSV preview'**
  String get csvPreview;

  /// No description provided for @viewCsv.
  ///
  /// In en, this message translates to:
  /// **'Tap a report to preview'**
  String get viewCsv;

  /// No description provided for @reportReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to export'**
  String get reportReady;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @accountSwitchTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview accounts'**
  String get accountSwitchTitle;

  /// No description provided for @accountSwitchHint.
  ///
  /// In en, this message translates to:
  /// **'Demo mode — pick a role to preview permissions.'**
  String get accountSwitchHint;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet. Notifications about your records will appear here.'**
  String get notificationsEmpty;

  /// No description provided for @notifContribution.
  ///
  /// In en, this message translates to:
  /// **'Contribution recorded'**
  String get notifContribution;

  /// No description provided for @notifLoanRequested.
  ///
  /// In en, this message translates to:
  /// **'Loan request submitted'**
  String get notifLoanRequested;

  /// No description provided for @notifLoanApproved.
  ///
  /// In en, this message translates to:
  /// **'Loan approved'**
  String get notifLoanApproved;

  /// No description provided for @notifLoanRejected.
  ///
  /// In en, this message translates to:
  /// **'Loan request not approved'**
  String get notifLoanRejected;

  /// No description provided for @notifRepayment.
  ///
  /// In en, this message translates to:
  /// **'Repayment recorded'**
  String get notifRepayment;

  /// No description provided for @notifAttendancePresent.
  ///
  /// In en, this message translates to:
  /// **'Marked present at meeting'**
  String get notifAttendancePresent;

  /// No description provided for @notifAttendanceAbsent.
  ///
  /// In en, this message translates to:
  /// **'Marked absent from meeting'**
  String get notifAttendanceAbsent;

  /// No description provided for @notifBodyContribution.
  ///
  /// In en, this message translates to:
  /// **'{amount} added to your savings'**
  String notifBodyContribution(String amount);

  /// No description provided for @notifBodyLoanRequested.
  ///
  /// In en, this message translates to:
  /// **'Your loan request of {amount} is awaiting approval'**
  String notifBodyLoanRequested(String amount);

  /// No description provided for @notifBodyLoanApproved.
  ///
  /// In en, this message translates to:
  /// **'Your loan of {amount} was approved'**
  String notifBodyLoanApproved(String amount);

  /// No description provided for @notifBodyLoanRejected.
  ///
  /// In en, this message translates to:
  /// **'Your loan request of {amount} was not approved'**
  String notifBodyLoanRejected(String amount);

  /// No description provided for @notifBodyRepayment.
  ///
  /// In en, this message translates to:
  /// **'{amount} repaid against your loan'**
  String notifBodyRepayment(String amount);

  /// No description provided for @notifBodyAttendancePresent.
  ///
  /// In en, this message translates to:
  /// **'You were marked present at the meeting'**
  String get notifBodyAttendancePresent;

  /// No description provided for @notifBodyAttendanceAbsent.
  ///
  /// In en, this message translates to:
  /// **'You were marked absent from the meeting'**
  String get notifBodyAttendanceAbsent;

  /// No description provided for @syncTitle.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get syncTitle;

  /// No description provided for @syncPending.
  ///
  /// In en, this message translates to:
  /// **'Syncing {count} pending change{count, plural, =1{} other{s}}'**
  String syncPending(num count);

  /// No description provided for @syncNothing.
  ///
  /// In en, this message translates to:
  /// **'Up to date with the server'**
  String get syncNothing;

  /// No description provided for @syncNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected to the server'**
  String get syncNotConnected;

  /// No description provided for @syncToken.
  ///
  /// In en, this message translates to:
  /// **'Server token'**
  String get syncToken;

  /// No description provided for @syncTokenHint.
  ///
  /// In en, this message translates to:
  /// **'Bearer token from POST /api/v1/auth/login (backend demos)'**
  String get syncTokenHint;

  /// No description provided for @syncBaseUrl.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get syncBaseUrl;

  /// No description provided for @syncSave.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get syncSave;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @syncServerConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected - sync queue will flush automatically'**
  String get syncServerConnected;

  /// No description provided for @syncServerConfigured.
  ///
  /// In en, this message translates to:
  /// **'Configured - saving your changes here also updates the server'**
  String get syncServerConfigured;

  /// No description provided for @syncServerNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Offline mode. Enter the token above to sync changes to the server.'**
  String get syncServerNotConfigured;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to keep your group records in sync.'**
  String get authSignInSubtitle;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get authPhone;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authContinueOffline.
  ///
  /// In en, this message translates to:
  /// **'Continue offline'**
  String get authContinueOffline;

  /// No description provided for @authOfflineHint.
  ///
  /// In en, this message translates to:
  /// **'No server? Open the demo with sample accounts.'**
  String get authOfflineHint;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Register a new group'**
  String get authRegister;

  /// No description provided for @authName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get authName;

  /// No description provided for @authGroupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get authGroupName;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get authLogout;

  /// No description provided for @authSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {name}'**
  String authSignedInAs(String name);

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @moreTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTitle;

  /// No description provided for @moreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Group administration and tools'**
  String get moreSubtitle;

  /// No description provided for @groupSettings.
  ///
  /// In en, this message translates to:
  /// **'Group settings'**
  String get groupSettings;

  /// No description provided for @activityHistory.
  ///
  /// In en, this message translates to:
  /// **'Activity history'**
  String get activityHistory;

  /// No description provided for @auditLog.
  ///
  /// In en, this message translates to:
  /// **'Audit log'**
  String get auditLog;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get exportData;

  /// No description provided for @syncCenter.
  ///
  /// In en, this message translates to:
  /// **'Sync center'**
  String get syncCenter;

  /// No description provided for @settlement.
  ///
  /// In en, this message translates to:
  /// **'Settlement'**
  String get settlement;

  /// No description provided for @savingsReport.
  ///
  /// In en, this message translates to:
  /// **'Savings report'**
  String get savingsReport;

  /// No description provided for @projectCompletion.
  ///
  /// In en, this message translates to:
  /// **'Project completion'**
  String get projectCompletion;

  /// No description provided for @loanManagement.
  ///
  /// In en, this message translates to:
  /// **'Loan management'**
  String get loanManagement;

  /// No description provided for @groupSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Cycle dates, contribution and loan rules'**
  String get groupSettingsDesc;

  /// No description provided for @activityHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Timeline of group operations'**
  String get activityHistoryDesc;

  /// No description provided for @auditLogDesc.
  ///
  /// In en, this message translates to:
  /// **'Immutable record of admin actions'**
  String get auditLogDesc;

  /// No description provided for @exportDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Statements, contributions and loans'**
  String get exportDataDesc;

  /// No description provided for @syncCenterDesc.
  ///
  /// In en, this message translates to:
  /// **'Offline-first sync queue and storage health'**
  String get syncCenterDesc;

  /// No description provided for @settlementDesc.
  ///
  /// In en, this message translates to:
  /// **'Lock and disburse the cycle payout'**
  String get settlementDesc;

  /// No description provided for @savingsReportDesc.
  ///
  /// In en, this message translates to:
  /// **'Wealth snapshot and monthly reports'**
  String get savingsReportDesc;

  /// No description provided for @projectCompletionDesc.
  ///
  /// In en, this message translates to:
  /// **'Handoff checklist and final review'**
  String get projectCompletionDesc;

  /// No description provided for @currentCycle.
  ///
  /// In en, this message translates to:
  /// **'Current cycle'**
  String get currentCycle;

  /// No description provided for @cycleActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get cycleActive;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @monthsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} months'**
  String monthsCount(int count);

  /// No description provided for @contributionRules.
  ///
  /// In en, this message translates to:
  /// **'Contribution rules'**
  String get contributionRules;

  /// No description provided for @sharePrice.
  ///
  /// In en, this message translates to:
  /// **'Share price'**
  String get sharePrice;

  /// No description provided for @minSharesPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Min shares / month'**
  String get minSharesPerMonth;

  /// No description provided for @lateFine.
  ///
  /// In en, this message translates to:
  /// **'Late fine'**
  String get lateFine;

  /// No description provided for @loanRules.
  ///
  /// In en, this message translates to:
  /// **'Loan rules'**
  String get loanRules;

  /// No description provided for @interestRate.
  ///
  /// In en, this message translates to:
  /// **'Interest rate'**
  String get interestRate;

  /// No description provided for @maxMultiplier.
  ///
  /// In en, this message translates to:
  /// **'Max multiplier'**
  String get maxMultiplier;

  /// No description provided for @maxRepayment.
  ///
  /// In en, this message translates to:
  /// **'Max repayment'**
  String get maxRepayment;

  /// No description provided for @memberManagement.
  ///
  /// In en, this message translates to:
  /// **'Member management'**
  String get memberManagement;

  /// No description provided for @manageRoles.
  ///
  /// In en, this message translates to:
  /// **'Manage roles'**
  String get manageRoles;

  /// No description provided for @addMemberShort.
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get addMemberShort;

  /// No description provided for @memberSinceShort.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String memberSinceShort(String date);

  /// No description provided for @closeCycle.
  ///
  /// In en, this message translates to:
  /// **'Close cycle'**
  String get closeCycle;

  /// No description provided for @archiveData.
  ///
  /// In en, this message translates to:
  /// **'Archive data'**
  String get archiveData;

  /// No description provided for @notTime.
  ///
  /// In en, this message translates to:
  /// **'Not time'**
  String get notTime;

  /// No description provided for @actionsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Actions this month'**
  String get actionsThisMonth;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @activityFinancial.
  ///
  /// In en, this message translates to:
  /// **'Financial'**
  String get activityFinancial;

  /// No description provided for @activityMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get activityMember;

  /// No description provided for @activitySystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get activitySystem;

  /// No description provided for @loanDisbursed.
  ///
  /// In en, this message translates to:
  /// **'Loan disbursed'**
  String get loanDisbursed;

  /// No description provided for @loanRepaid.
  ///
  /// In en, this message translates to:
  /// **'Loan fully repaid'**
  String get loanRepaid;

  /// No description provided for @backupSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Backup successful'**
  String get backupSuccessful;

  /// No description provided for @contributionPending.
  ///
  /// In en, this message translates to:
  /// **'Contribution pending'**
  String get contributionPending;

  /// No description provided for @activityContribution.
  ///
  /// In en, this message translates to:
  /// **'Contribution recorded'**
  String get activityContribution;

  /// No description provided for @activityMeeting.
  ///
  /// In en, this message translates to:
  /// **'Meeting logged'**
  String get activityMeeting;

  /// No description provided for @activityNoData.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get activityNoData;

  /// No description provided for @activityNoDataBody.
  ///
  /// In en, this message translates to:
  /// **'Contributions, loans and meetings will appear here.'**
  String get activityNoDataBody;

  /// No description provided for @immutableRecord.
  ///
  /// In en, this message translates to:
  /// **'Immutable record'**
  String get immutableRecord;

  /// No description provided for @searchActions.
  ///
  /// In en, this message translates to:
  /// **'Search actions'**
  String get searchActions;

  /// No description provided for @allActions.
  ///
  /// In en, this message translates to:
  /// **'All actions'**
  String get allActions;

  /// No description provided for @filterSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get filterSettings;

  /// No description provided for @filterMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get filterMembers;

  /// No description provided for @filterLoans.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get filterLoans;

  /// No description provided for @auditChangedSharePrice.
  ///
  /// In en, this message translates to:
  /// **'Changed share price from {from} to {to}'**
  String auditChangedSharePrice(String from, String to);

  /// No description provided for @auditAddedMember.
  ///
  /// In en, this message translates to:
  /// **'Added new member: {name}'**
  String auditAddedMember(String name);

  /// No description provided for @auditApprovedLoan.
  ///
  /// In en, this message translates to:
  /// **'Approved loan {id} for {amount}'**
  String auditApprovedLoan(String id, String amount);

  /// No description provided for @auditNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No audit entries yet'**
  String get auditNoEntries;

  /// No description provided for @fullFinancialStatement.
  ///
  /// In en, this message translates to:
  /// **'Full financial statement'**
  String get fullFinancialStatement;

  /// No description provided for @fullFinancialStatementDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete record of group income, expenses and current balances.'**
  String get fullFinancialStatementDesc;

  /// No description provided for @exportMemberContributions.
  ///
  /// In en, this message translates to:
  /// **'Member contributions'**
  String get exportMemberContributions;

  /// No description provided for @exportMemberContributionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Detailed summary of individual member shares and savings.'**
  String get exportMemberContributionsDesc;

  /// No description provided for @loanPerformance.
  ///
  /// In en, this message translates to:
  /// **'Loan performance'**
  String get loanPerformance;

  /// No description provided for @loanPerformanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Status of active loans, repayments made and outstanding balances.'**
  String get loanPerformanceDesc;

  /// No description provided for @exportCompleteBundle.
  ///
  /// In en, this message translates to:
  /// **'Export complete bundle'**
  String get exportCompleteBundle;

  /// No description provided for @exportCompleteBundleDesc.
  ///
  /// In en, this message translates to:
  /// **'Download a consolidated report containing all current financial records.'**
  String get exportCompleteBundleDesc;

  /// No description provided for @exportAllPdf.
  ///
  /// In en, this message translates to:
  /// **'Export All (PDF)'**
  String get exportAllPdf;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get exportPdf;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get exportCsv;

  /// No description provided for @exporting.
  ///
  /// In en, this message translates to:
  /// **'Preparing export...'**
  String get exporting;

  /// No description provided for @currentlyOffline.
  ///
  /// In en, this message translates to:
  /// **'Currently offline'**
  String get currentlyOffline;

  /// No description provided for @offlineBody.
  ///
  /// In en, this message translates to:
  /// **'You are working in offline mode. Changes are saved locally and will sync automatically when a connection is restored.'**
  String get offlineBody;

  /// No description provided for @searchingNetwork.
  ///
  /// In en, this message translates to:
  /// **'Searching for network...'**
  String get searchingNetwork;

  /// No description provided for @pendingChanges.
  ///
  /// In en, this message translates to:
  /// **'Pending changes'**
  String get pendingChanges;

  /// No description provided for @contributionsRecorded.
  ///
  /// In en, this message translates to:
  /// **'{count} contributions recorded'**
  String contributionsRecorded(int count);

  /// No description provided for @memberProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'{count} member profiles updated'**
  String memberProfileUpdated(int count);

  /// No description provided for @localBadge.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get localBadge;

  /// No description provided for @storageHealth.
  ///
  /// In en, this message translates to:
  /// **'Storage health'**
  String get storageHealth;

  /// No description provided for @capacityUsed.
  ///
  /// In en, this message translates to:
  /// **'Capacity used'**
  String get capacityUsed;

  /// No description provided for @storageSafe.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get storageSafe;

  /// No description provided for @mbAvailable.
  ///
  /// In en, this message translates to:
  /// **'{size}MB available'**
  String mbAvailable(int size);

  /// No description provided for @syncCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync complete'**
  String get syncCompleteTitle;

  /// No description provided for @syncCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'Your data is now safe and secure on the server.'**
  String get syncCompleteBody;

  /// No description provided for @updatedRecords.
  ///
  /// In en, this message translates to:
  /// **'Updated {count} records'**
  String updatedRecords(int count);

  /// No description provided for @syncedPhotos.
  ///
  /// In en, this message translates to:
  /// **'Synced {count} photos'**
  String syncedPhotos(int count);

  /// No description provided for @lastSync.
  ///
  /// In en, this message translates to:
  /// **'Last sync: {time}'**
  String lastSync(String time);

  /// No description provided for @returnToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Return to dashboard'**
  String get returnToDashboard;

  /// No description provided for @synced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get synced;

  /// No description provided for @totalGroupWealth.
  ///
  /// In en, this message translates to:
  /// **'Total group wealth'**
  String get totalGroupWealth;

  /// No description provided for @vsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'+{pct}% vs last month'**
  String vsLastMonth(String pct);

  /// No description provided for @generateReport.
  ///
  /// In en, this message translates to:
  /// **'Generate report'**
  String get generateReport;

  /// No description provided for @reportMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get reportMonth;

  /// No description provided for @reportYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get reportYear;

  /// No description provided for @downloadReport.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadReport;

  /// No description provided for @recentReports.
  ///
  /// In en, this message translates to:
  /// **'Recent reports'**
  String get recentReports;

  /// No description provided for @monthlyReport.
  ///
  /// In en, this message translates to:
  /// **'{month} monthly report'**
  String monthlyReport(String month);

  /// No description provided for @noReportsYet.
  ///
  /// In en, this message translates to:
  /// **'No reports generated yet'**
  String get noReportsYet;

  /// No description provided for @compliance.
  ///
  /// In en, this message translates to:
  /// **'Compliance'**
  String get compliance;

  /// No description provided for @onTime.
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get onTime;

  /// No description provided for @late.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get late;

  /// No description provided for @capitalGrowth.
  ///
  /// In en, this message translates to:
  /// **'Capital growth'**
  String get capitalGrowth;

  /// No description provided for @momGrowth.
  ///
  /// In en, this message translates to:
  /// **'+{pct}% MoM'**
  String momGrowth(String pct);

  /// No description provided for @topSavers.
  ///
  /// In en, this message translates to:
  /// **'Top savers'**
  String get topSavers;

  /// No description provided for @consistentSaver.
  ///
  /// In en, this message translates to:
  /// **'Consistent saver'**
  String get consistentSaver;

  /// No description provided for @earlyPayer.
  ///
  /// In en, this message translates to:
  /// **'Early payer'**
  String get earlyPayer;

  /// No description provided for @pdfButton.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdfButton;

  /// No description provided for @shareReport.
  ///
  /// In en, this message translates to:
  /// **'Share report'**
  String get shareReport;

  /// No description provided for @quarterlyReport.
  ///
  /// In en, this message translates to:
  /// **'Q{quarter} report'**
  String quarterlyReport(int quarter);

  /// No description provided for @monthlyPerformance.
  ///
  /// In en, this message translates to:
  /// **'Monthly performance'**
  String get monthlyPerformance;

  /// No description provided for @totalMembers.
  ///
  /// In en, this message translates to:
  /// **'Total members'**
  String get totalMembers;

  /// No description provided for @totalDisbursed.
  ///
  /// In en, this message translates to:
  /// **'Total disbursed'**
  String get totalDisbursed;

  /// No description provided for @readyForDisbursement.
  ///
  /// In en, this message translates to:
  /// **'Ready for disbursement'**
  String get readyForDisbursement;

  /// No description provided for @allLoansSettled.
  ///
  /// In en, this message translates to:
  /// **'All loans settled'**
  String get allLoansSettled;

  /// No description provided for @calculationsVerified.
  ///
  /// In en, this message translates to:
  /// **'Calculations verified'**
  String get calculationsVerified;

  /// No description provided for @finalReportGenerated.
  ///
  /// In en, this message translates to:
  /// **'Final report generated'**
  String get finalReportGenerated;

  /// No description provided for @warningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warningTitle;

  /// No description provided for @warningBody.
  ///
  /// In en, this message translates to:
  /// **'All records will be locked after this action.'**
  String get warningBody;

  /// No description provided for @lockAndDisburse.
  ///
  /// In en, this message translates to:
  /// **'Lock & disburse funds'**
  String get lockAndDisburse;

  /// No description provided for @pdfReport.
  ///
  /// In en, this message translates to:
  /// **'PDF report'**
  String get pdfReport;

  /// No description provided for @printReceipts.
  ///
  /// In en, this message translates to:
  /// **'Print receipts'**
  String get printReceipts;

  /// No description provided for @settlementComplete.
  ///
  /// In en, this message translates to:
  /// **'Settlement complete'**
  String get settlementComplete;

  /// No description provided for @cycleClosedBody.
  ///
  /// In en, this message translates to:
  /// **'The cycle is closed and funds have been marked for disbursement.'**
  String get cycleClosedBody;

  /// No description provided for @disbursed.
  ///
  /// In en, this message translates to:
  /// **'Disbursed'**
  String get disbursed;

  /// No description provided for @reviewApplication.
  ///
  /// In en, this message translates to:
  /// **'Review application'**
  String get reviewApplication;

  /// No description provided for @loanRequest.
  ///
  /// In en, this message translates to:
  /// **'Loan request'**
  String get loanRequest;

  /// No description provided for @requestedAmount.
  ///
  /// In en, this message translates to:
  /// **'Requested amount'**
  String get requestedAmount;

  /// No description provided for @totalToRepay.
  ///
  /// In en, this message translates to:
  /// **'Total to repay'**
  String get totalToRepay;

  /// No description provided for @purpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get purpose;

  /// No description provided for @eligibilityCheck.
  ///
  /// In en, this message translates to:
  /// **'Eligibility check'**
  String get eligibilityCheck;

  /// No description provided for @savingsToLoanRatio.
  ///
  /// In en, this message translates to:
  /// **'Savings-to-loan ratio'**
  String get savingsToLoanRatio;

  /// No description provided for @safe.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get safe;

  /// No description provided for @activeLoans.
  ///
  /// In en, this message translates to:
  /// **'Active loans'**
  String get activeLoans;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @approveLoan.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approveLoan;

  /// No description provided for @rejectLoan.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectLoan;

  /// No description provided for @approvedConfirm.
  ///
  /// In en, this message translates to:
  /// **'Loan approved'**
  String get approvedConfirm;

  /// No description provided for @rejectedConfirm.
  ///
  /// In en, this message translates to:
  /// **'Loan request rejected'**
  String get rejectedConfirm;

  /// No description provided for @noPurposeGiven.
  ///
  /// In en, this message translates to:
  /// **'No purpose given'**
  String get noPurposeGiven;

  /// No description provided for @actionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Action needed'**
  String get actionNeeded;

  /// No description provided for @pendingApprovals.
  ///
  /// In en, this message translates to:
  /// **'Pending approvals'**
  String get pendingApprovals;

  /// No description provided for @loanHistory.
  ///
  /// In en, this message translates to:
  /// **'Loan history'**
  String get loanHistory;

  /// No description provided for @reviewButton.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewButton;

  /// No description provided for @noPendingApprovals.
  ///
  /// In en, this message translates to:
  /// **'No pending approvals'**
  String get noPendingApprovals;

  /// No description provided for @noLoansInHistory.
  ///
  /// In en, this message translates to:
  /// **'No loans in history yet'**
  String get noLoansInHistory;

  /// No description provided for @groupRegistered.
  ///
  /// In en, this message translates to:
  /// **'Group registered successfully'**
  String get groupRegistered;

  /// No description provided for @groupReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Your community savings group is now active and ready to grow.'**
  String get groupReadyBody;

  /// No description provided for @nextSteps.
  ///
  /// In en, this message translates to:
  /// **'Next steps'**
  String get nextSteps;

  /// No description provided for @inviteMembers.
  ///
  /// In en, this message translates to:
  /// **'Invite members'**
  String get inviteMembers;

  /// No description provided for @setRules.
  ///
  /// In en, this message translates to:
  /// **'Set rules'**
  String get setRules;

  /// No description provided for @goToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Go to dashboard'**
  String get goToDashboard;

  /// No description provided for @projectComplete.
  ///
  /// In en, this message translates to:
  /// **'Project complete'**
  String get projectComplete;

  /// No description provided for @projectCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'All core modules for the Umoja Vikoba Group management system have been successfully integrated and tested.'**
  String get projectCompleteBody;

  /// No description provided for @milestonesAchieved.
  ///
  /// In en, this message translates to:
  /// **'Milestones achieved'**
  String get milestonesAchieved;

  /// No description provided for @memberOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Member onboarding'**
  String get memberOnboarding;

  /// No description provided for @memberOnboardingDesc.
  ///
  /// In en, this message translates to:
  /// **'Digital profiles, KYC documentation and initial share purchases mapped.'**
  String get memberOnboardingDesc;

  /// No description provided for @loanManagementMilestone.
  ///
  /// In en, this message translates to:
  /// **'Loan management'**
  String get loanManagementMilestone;

  /// No description provided for @loanManagementDesc.
  ///
  /// In en, this message translates to:
  /// **'Application workflows, interest calculation and repayment tracking active.'**
  String get loanManagementDesc;

  /// No description provided for @financialReportsMilestone.
  ///
  /// In en, this message translates to:
  /// **'Financial reports'**
  String get financialReportsMilestone;

  /// No description provided for @financialReportsDesc.
  ///
  /// In en, this message translates to:
  /// **'Automated ledger generation, balance sheets and dividend distribution ready.'**
  String get financialReportsDesc;

  /// No description provided for @finalHandoffReview.
  ///
  /// In en, this message translates to:
  /// **'Final handoff review'**
  String get finalHandoffReview;

  /// No description provided for @dataMigrationComplete.
  ///
  /// In en, this message translates to:
  /// **'Data migration complete'**
  String get dataMigrationComplete;

  /// No description provided for @uatSignOff.
  ///
  /// In en, this message translates to:
  /// **'UAT sign-off received'**
  String get uatSignOff;

  /// No description provided for @adminRolesConfigured.
  ///
  /// In en, this message translates to:
  /// **'Admin roles configured'**
  String get adminRolesConfigured;

  /// No description provided for @completeHandoff.
  ///
  /// In en, this message translates to:
  /// **'Complete handoff'**
  String get completeHandoff;

  /// No description provided for @projectCompleted.
  ///
  /// In en, this message translates to:
  /// **'Project completed'**
  String get projectCompleted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
