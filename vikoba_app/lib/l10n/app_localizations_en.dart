// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Vikoba Manager';

  @override
  String get navHome => 'Home';

  @override
  String get navMembers => 'Members';

  @override
  String get navSavings => 'Savings';

  @override
  String get navLoans => 'Loans';

  @override
  String get navShareOut => 'Share-Out';

  @override
  String get appBarDashboard => 'Vikoba Dashboard';

  @override
  String get appBarMembers => 'Members';

  @override
  String get appBarContributions => 'Contributions';

  @override
  String get appBarLoans => 'Loans';

  @override
  String get appBarShareOut => 'Share-Out Calculator';

  @override
  String get dashboardGroupOverview => 'Group Overview';

  @override
  String get totalGroupSavings => 'Total Group Savings';

  @override
  String get activeLoansValue => 'Active Loans';

  @override
  String get interestEarned => 'Interest Earned';

  @override
  String get activeMembers => 'Active Members';

  @override
  String get recentContributions => 'Recent Contributions';

  @override
  String get loansNeedingAttention => 'Loans Needing Attention';

  @override
  String get noContributionsYet => 'No contributions recorded yet';

  @override
  String get nothingNeedsAttention => 'Nothing needs attention right now';

  @override
  String get awaitingDisbursement => 'Awaiting disbursement';

  @override
  String get overdue => 'Overdue';

  @override
  String sharesPrefix(int count, String date) {
    return '$count shares - $date';
  }

  @override
  String get addMember => 'Add Member';

  @override
  String get totalShares => 'Total shares';

  @override
  String get totalContributed => 'Total contributed';

  @override
  String get noMembersYet =>
      'No members yet. Tap \'Add Member\' to register someone.';

  @override
  String get fullName => 'Full name';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get role => 'Role';

  @override
  String get saveMember => 'Save Member';

  @override
  String memberSharesSuffix(int count) {
    return '$count shares';
  }

  @override
  String get searchMembers => 'Search members';

  @override
  String get noMembersFound => 'No members match your search.';

  @override
  String get memberDetailTitle => 'Member profile';

  @override
  String memberSince(String date) {
    return 'Member since $date';
  }

  @override
  String membershipDaysLabel(int days) {
    return 'Member for $days days';
  }

  @override
  String get joinedDate => 'Joined';

  @override
  String get nidaNumber => 'NIDA number';

  @override
  String get memberStatusActive => 'Active';

  @override
  String get memberStatusInactive => 'Inactive';

  @override
  String get loanCapacity => 'Loan capacity';

  @override
  String get guarantorExposure => 'Guarantor exposure';

  @override
  String get memberLoans => 'Loans';

  @override
  String get memberContributions => 'Contributions';

  @override
  String get noMemberLoans => 'No loans recorded for this member yet.';

  @override
  String get noMemberContributions =>
      'No contributions recorded for this member yet.';

  @override
  String get deactivateMember => 'Deactivate member';

  @override
  String get reactivateMember => 'Reactivate member';

  @override
  String get deactivateConfirmTitle => 'Deactivate member?';

  @override
  String deactivateConfirmBody(String name) {
    return 'Stop $name from contributing, taking loans and attending meetings? Their history stays on record.';
  }

  @override
  String get memberDeactivated => 'Member deactivated';

  @override
  String get memberReactivated => 'Member reactivated';

  @override
  String get cancel => 'Cancel';

  @override
  String get recordContribution => 'Record Contribution';

  @override
  String get record => 'Record';

  @override
  String get lastContribution => 'Last contribution';

  @override
  String get member => 'Member';

  @override
  String get numberOfShares => 'Number of shares';

  @override
  String oneShareHelper(String amount) {
    return '1 share = $amount';
  }

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get totalAmount => 'Total amount';

  @override
  String get saveContribution => 'Save Contribution';

  @override
  String get newLoan => 'New Loan';

  @override
  String get newLoanRequest => 'New Loan Request';

  @override
  String get loanAmount => 'Loan amount (TZS)';

  @override
  String interestRateHelper(String rate) {
    return 'Interest rate: $rate%';
  }

  @override
  String get repaymentPeriod => 'Repayment period';

  @override
  String daysPeriod(int days) {
    return '$days days';
  }

  @override
  String get submitRequest => 'Submit Request';

  @override
  String get principal => 'Principal';

  @override
  String get due => 'Due';

  @override
  String get reject => 'Reject';

  @override
  String get approve => 'Approve';

  @override
  String get disburse => 'Disburse';

  @override
  String get recordRepayment => 'Record Repayment';

  @override
  String repaymentTitle(String name) {
    return 'Repayment - $name';
  }

  @override
  String get balance => 'Balance';

  @override
  String get amountTzs => 'Amount (TZS)';

  @override
  String get saveRepayment => 'Save Repayment';

  @override
  String repaidOf(String amount, String total) {
    return '$amount of $total repaid';
  }

  @override
  String get noLoansYet => 'No loans yet';

  @override
  String get pendingLoans => 'Pending loans';

  @override
  String get loanEligibilityError =>
      'Request exceeds what this member may borrow per group rules.';

  @override
  String get loanEligibilityOpen =>
      'This member still has an approved or active loan.';

  @override
  String get loanBelowMinimum => 'Amount is below the group\'s minimum loan.';

  @override
  String get loanSelfRequestHint =>
      'Submitted to the leaders for approval — you\'ll be notified of the decision.';

  @override
  String get loanProduct => 'Loan product';

  @override
  String get loanProductHelper =>
      'The product sets the interest method, term limit and penalty rules.';

  @override
  String get loanTermMonths => 'Repayment term (months)';

  @override
  String monthsPeriod(int count) {
    return '$count months';
  }

  @override
  String get guarantors => 'Guarantors (up to 2)';

  @override
  String get guarantorHint =>
      'A guarantor shares responsibility for this loan.';

  @override
  String get guarantorSelect => 'Choose a guarantor';

  @override
  String get guarantorNone => 'No guarantor';

  @override
  String get noProductsYet => 'No loan products configured yet.';

  @override
  String get loanEligibleOk => 'Eligible — submit to proceed.';

  @override
  String get loanMemberInactive => 'This member is not active.';

  @override
  String get loanMembershipTooShort =>
      'This member joined too recently to borrow yet.';

  @override
  String get loanTermTooLong => 'The term exceeds this product\'s maximum.';

  @override
  String loanMaxAllowedHint(String amount) {
    return 'Maximum allowed: $amount';
  }

  @override
  String get quoteTitle => 'Loan quote';

  @override
  String get quoteTotalInterest => 'Total interest';

  @override
  String get quoteTotalPayable => 'Total to repay';

  @override
  String get quoteMonthlyInstallment => 'Monthly installment';

  @override
  String get quoteMethodFlat => 'Flat rate';

  @override
  String get quoteMethodReducing => 'Reducing balance';

  @override
  String quoteInstallments(int count) {
    return '$count installments';
  }

  @override
  String get penaltyAccrued => 'Penalty accrued';

  @override
  String penaltyRateHint(String value, int days) {
    return '$value per $days days late after grace';
  }

  @override
  String get loanDetailTitle => 'Loan details';

  @override
  String get scheduleTitle => 'Repayment schedule';

  @override
  String get installmentShort => 'Installment';

  @override
  String get installmentTotal => 'Total';

  @override
  String dueOn(String date) {
    return 'Due $date';
  }

  @override
  String get paidLabel => 'Paid';

  @override
  String get unpaidLabel => 'Unpaid';

  @override
  String get waterfallPenalty => 'Penalty paid';

  @override
  String get waterfallInterest => 'Interest paid';

  @override
  String get waterfallPrincipal => 'Principal paid';

  @override
  String overpaymentReturned(String amount) {
    return 'Overpayment returned: $amount';
  }

  @override
  String get guarantorsList => 'Guarantors';

  @override
  String get noGuarantors => 'No guarantors';

  @override
  String get loanAmountRepaid => 'Repaid';

  @override
  String get totalPayableToMembers => 'Total Payable to Members';

  @override
  String get shareOutSubtitle =>
      'Savings + proportional interest earned, calculated automatically';

  @override
  String get perMemberBreakdown => 'Per-Member Breakdown';

  @override
  String get savings => 'Savings';

  @override
  String get interestShare => 'Interest share';

  @override
  String get totalPayout => 'Total payout';

  @override
  String get savingsPoolComposition => 'Savings Pool Composition';

  @override
  String get noSharesYet => 'No shares recorded yet';

  @override
  String ofPool(String pct) {
    return '$pct% of pool';
  }

  @override
  String get appBarMeetings => 'Meetings';

  @override
  String get noMeetingsYet => 'No meetings recorded yet.';

  @override
  String get newMeeting => 'Log Meeting';

  @override
  String get meetingDate => 'Meeting date';

  @override
  String get meetingAgenda => 'Agenda';

  @override
  String get attendance => 'Attendance';

  @override
  String get presentMembers => 'Present';

  @override
  String absentCount(int count) {
    return '$count absent';
  }

  @override
  String attendanceRate(String pct) {
    return '$pct% attendance';
  }

  @override
  String get saveMeeting => 'Save Meeting';

  @override
  String get logAttendance => 'Mark attendance';

  @override
  String get agendaLabel => 'Agenda';

  @override
  String get appBarReports => 'Reports';

  @override
  String get reportsSubtitle => 'Export records for the group ledger.';

  @override
  String get reportMembers => 'Members';

  @override
  String get reportContributions => 'Contributions';

  @override
  String get reportLoans => 'Loans';

  @override
  String reportRows(int count) {
    return '$count rows';
  }

  @override
  String get copyCsv => 'Copy CSV';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get csvPreview => 'CSV preview';

  @override
  String get viewCsv => 'Tap a report to preview';

  @override
  String get reportReady => 'Ready to export';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get accountSwitchTitle => 'Preview accounts';

  @override
  String get accountSwitchHint =>
      'Demo mode — pick a role to preview permissions.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsEmpty =>
      'Nothing here yet. Notifications about your records will appear here.';

  @override
  String get notifContribution => 'Contribution recorded';

  @override
  String get notifLoanRequested => 'Loan request submitted';

  @override
  String get notifLoanApproved => 'Loan approved';

  @override
  String get notifLoanRejected => 'Loan request not approved';

  @override
  String get notifRepayment => 'Repayment recorded';

  @override
  String get notifAttendancePresent => 'Marked present at meeting';

  @override
  String get notifAttendanceAbsent => 'Marked absent from meeting';

  @override
  String notifBodyContribution(String amount) {
    return '$amount added to your savings';
  }

  @override
  String notifBodyLoanRequested(String amount) {
    return 'Your loan request of $amount is awaiting approval';
  }

  @override
  String notifBodyLoanApproved(String amount) {
    return 'Your loan of $amount was approved';
  }

  @override
  String notifBodyLoanRejected(String amount) {
    return 'Your loan request of $amount was not approved';
  }

  @override
  String notifBodyRepayment(String amount) {
    return '$amount repaid against your loan';
  }

  @override
  String get notifBodyAttendancePresent =>
      'You were marked present at the meeting';

  @override
  String get notifBodyAttendanceAbsent =>
      'You were marked absent from the meeting';

  @override
  String get syncTitle => 'Server';

  @override
  String syncPending(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'Syncing $count pending change$_temp0';
  }

  @override
  String get syncNothing => 'Up to date with the server';

  @override
  String get syncNotConnected => 'Not connected to the server';

  @override
  String get syncToken => 'Server token';

  @override
  String get syncTokenHint =>
      'Bearer token from POST /api/v1/auth/login (backend demos)';

  @override
  String get syncBaseUrl => 'Server address';

  @override
  String get syncSave => 'Connect';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncServerConnected =>
      'Connected - sync queue will flush automatically';

  @override
  String get syncServerConfigured =>
      'Configured - saving your changes here also updates the server';

  @override
  String get syncServerNotConfigured =>
      'Offline mode. Enter the token above to sync changes to the server.';

  @override
  String get authSignInSubtitle =>
      'Sign in to keep your group records in sync.';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authPhone => 'Phone number';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authContinueOffline => 'Continue offline';

  @override
  String get authOfflineHint =>
      'No server? Open the demo with sample accounts.';

  @override
  String get authRegister => 'Register a new group';

  @override
  String get authName => 'Full name';

  @override
  String get authGroupName => 'Group name';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authLogout => 'Sign out';

  @override
  String authSignedInAs(String name) {
    return 'Signed in as $name';
  }

  @override
  String get navMore => 'More';

  @override
  String get moreTitle => 'More';

  @override
  String get moreSubtitle => 'Group administration and tools';

  @override
  String get groupSettings => 'Group settings';

  @override
  String get activityHistory => 'Activity history';

  @override
  String get auditLog => 'Audit log';

  @override
  String get exportData => 'Export data';

  @override
  String get syncCenter => 'Sync center';

  @override
  String get settlement => 'Settlement';

  @override
  String get savingsReport => 'Savings report';

  @override
  String get projectCompletion => 'Project completion';

  @override
  String get loanManagement => 'Loan management';

  @override
  String get groupSettingsDesc => 'Cycle dates, contribution and loan rules';

  @override
  String get activityHistoryDesc => 'Timeline of group operations';

  @override
  String get auditLogDesc => 'Immutable record of admin actions';

  @override
  String get exportDataDesc => 'Statements, contributions and loans';

  @override
  String get syncCenterDesc => 'Offline-first sync queue and storage health';

  @override
  String get settlementDesc => 'Lock and disburse the cycle payout';

  @override
  String get savingsReportDesc => 'Wealth snapshot and monthly reports';

  @override
  String get projectCompletionDesc => 'Handoff checklist and final review';

  @override
  String get currentCycle => 'Current cycle';

  @override
  String get cycleActive => 'Active';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get duration => 'Duration';

  @override
  String monthsCount(int count) {
    return '$count months';
  }

  @override
  String get contributionRules => 'Contribution rules';

  @override
  String get sharePrice => 'Share price';

  @override
  String get minSharesPerMonth => 'Min shares / month';

  @override
  String get lateFine => 'Late fine';

  @override
  String get loanRules => 'Loan rules';

  @override
  String get interestRate => 'Interest rate';

  @override
  String get maxMultiplier => 'Max multiplier';

  @override
  String get maxRepayment => 'Max repayment';

  @override
  String get memberManagement => 'Member management';

  @override
  String get manageRoles => 'Manage roles';

  @override
  String get addMemberShort => 'Add member';

  @override
  String memberSinceShort(String date) {
    return 'Member since $date';
  }

  @override
  String get closeCycle => 'Close cycle';

  @override
  String get archiveData => 'Archive data';

  @override
  String get notTime => 'Not time';

  @override
  String get actionsThisMonth => 'Actions this month';

  @override
  String get alerts => 'Alerts';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get activityFinancial => 'Financial';

  @override
  String get activityMember => 'Member';

  @override
  String get activitySystem => 'System';

  @override
  String get loanDisbursed => 'Loan disbursed';

  @override
  String get loanRepaid => 'Loan fully repaid';

  @override
  String get backupSuccessful => 'Backup successful';

  @override
  String get contributionPending => 'Contribution pending';

  @override
  String get activityContribution => 'Contribution recorded';

  @override
  String get activityMeeting => 'Meeting logged';

  @override
  String get activityNoData => 'No activity yet';

  @override
  String get activityNoDataBody =>
      'Contributions, loans and meetings will appear here.';

  @override
  String get immutableRecord => 'Immutable record';

  @override
  String get searchActions => 'Search actions';

  @override
  String get allActions => 'All actions';

  @override
  String get filterSettings => 'Settings';

  @override
  String get filterMembers => 'Members';

  @override
  String get filterLoans => 'Loans';

  @override
  String auditChangedSharePrice(String from, String to) {
    return 'Changed share price from $from to $to';
  }

  @override
  String auditAddedMember(String name) {
    return 'Added new member: $name';
  }

  @override
  String auditApprovedLoan(String id, String amount) {
    return 'Approved loan $id for $amount';
  }

  @override
  String get auditNoEntries => 'No audit entries yet';

  @override
  String get fullFinancialStatement => 'Full financial statement';

  @override
  String get fullFinancialStatementDesc =>
      'Complete record of group income, expenses and current balances.';

  @override
  String get exportMemberContributions => 'Member contributions';

  @override
  String get exportMemberContributionsDesc =>
      'Detailed summary of individual member shares and savings.';

  @override
  String get loanPerformance => 'Loan performance';

  @override
  String get loanPerformanceDesc =>
      'Status of active loans, repayments made and outstanding balances.';

  @override
  String get exportCompleteBundle => 'Export complete bundle';

  @override
  String get exportCompleteBundleDesc =>
      'Download a consolidated report containing all current financial records.';

  @override
  String get exportAllPdf => 'Export All (PDF)';

  @override
  String get exportPdf => 'PDF';

  @override
  String get exportCsv => 'CSV';

  @override
  String get exporting => 'Preparing export...';

  @override
  String get currentlyOffline => 'Currently offline';

  @override
  String get offlineBody =>
      'You are working in offline mode. Changes are saved locally and will sync automatically when a connection is restored.';

  @override
  String get searchingNetwork => 'Searching for network...';

  @override
  String get pendingChanges => 'Pending changes';

  @override
  String contributionsRecorded(int count) {
    return '$count contributions recorded';
  }

  @override
  String memberProfileUpdated(int count) {
    return '$count member profiles updated';
  }

  @override
  String get localBadge => 'Local';

  @override
  String get storageHealth => 'Storage health';

  @override
  String get capacityUsed => 'Capacity used';

  @override
  String get storageSafe => 'Safe';

  @override
  String mbAvailable(int size) {
    return '${size}MB available';
  }

  @override
  String get syncCompleteTitle => 'Sync complete';

  @override
  String get syncCompleteBody =>
      'Your data is now safe and secure on the server.';

  @override
  String updatedRecords(int count) {
    return 'Updated $count records';
  }

  @override
  String syncedPhotos(int count) {
    return 'Synced $count photos';
  }

  @override
  String lastSync(String time) {
    return 'Last sync: $time';
  }

  @override
  String get returnToDashboard => 'Return to dashboard';

  @override
  String get synced => 'Synced';

  @override
  String get totalGroupWealth => 'Total group wealth';

  @override
  String vsLastMonth(String pct) {
    return '+$pct% vs last month';
  }

  @override
  String get generateReport => 'Generate report';

  @override
  String get reportMonth => 'Month';

  @override
  String get reportYear => 'Year';

  @override
  String get downloadReport => 'Download';

  @override
  String get recentReports => 'Recent reports';

  @override
  String monthlyReport(String month) {
    return '$month monthly report';
  }

  @override
  String get noReportsYet => 'No reports generated yet';

  @override
  String get compliance => 'Compliance';

  @override
  String get onTime => 'On time';

  @override
  String get late => 'Late';

  @override
  String get capitalGrowth => 'Capital growth';

  @override
  String momGrowth(String pct) {
    return '+$pct% MoM';
  }

  @override
  String get topSavers => 'Top savers';

  @override
  String get consistentSaver => 'Consistent saver';

  @override
  String get earlyPayer => 'Early payer';

  @override
  String get pdfButton => 'PDF';

  @override
  String get shareReport => 'Share report';

  @override
  String quarterlyReport(int quarter) {
    return 'Q$quarter report';
  }

  @override
  String get monthlyPerformance => 'Monthly performance';

  @override
  String get totalMembers => 'Total members';

  @override
  String get totalDisbursed => 'Total disbursed';

  @override
  String get readyForDisbursement => 'Ready for disbursement';

  @override
  String get allLoansSettled => 'All loans settled';

  @override
  String get calculationsVerified => 'Calculations verified';

  @override
  String get finalReportGenerated => 'Final report generated';

  @override
  String get warningTitle => 'Warning';

  @override
  String get warningBody => 'All records will be locked after this action.';

  @override
  String get lockAndDisburse => 'Lock & disburse funds';

  @override
  String get pdfReport => 'PDF report';

  @override
  String get printReceipts => 'Print receipts';

  @override
  String get settlementComplete => 'Settlement complete';

  @override
  String get cycleClosedBody =>
      'The cycle is closed and funds have been marked for disbursement.';

  @override
  String get disbursed => 'Disbursed';

  @override
  String get reviewApplication => 'Review application';

  @override
  String get loanRequest => 'Loan request';

  @override
  String get requestedAmount => 'Requested amount';

  @override
  String get totalToRepay => 'Total to repay';

  @override
  String get purpose => 'Purpose';

  @override
  String get eligibilityCheck => 'Eligibility check';

  @override
  String get savingsToLoanRatio => 'Savings-to-loan ratio';

  @override
  String get safe => 'Safe';

  @override
  String get activeLoans => 'Active loans';

  @override
  String get none => 'None';

  @override
  String get approveLoan => 'Approve';

  @override
  String get rejectLoan => 'Reject';

  @override
  String get approvedConfirm => 'Loan approved';

  @override
  String get rejectedConfirm => 'Loan request rejected';

  @override
  String get noPurposeGiven => 'No purpose given';

  @override
  String get actionNeeded => 'Action needed';

  @override
  String get pendingApprovals => 'Pending approvals';

  @override
  String get loanHistory => 'Loan history';

  @override
  String get reviewButton => 'Review';

  @override
  String get noPendingApprovals => 'No pending approvals';

  @override
  String get noLoansInHistory => 'No loans in history yet';

  @override
  String get groupRegistered => 'Group registered successfully';

  @override
  String get groupReadyBody =>
      'Your community savings group is now active and ready to grow.';

  @override
  String get nextSteps => 'Next steps';

  @override
  String get inviteMembers => 'Invite members';

  @override
  String get setRules => 'Set rules';

  @override
  String get goToDashboard => 'Go to dashboard';

  @override
  String get projectComplete => 'Project complete';

  @override
  String get projectCompleteBody =>
      'All core modules for the Umoja Vikoba Group management system have been successfully integrated and tested.';

  @override
  String get milestonesAchieved => 'Milestones achieved';

  @override
  String get memberOnboarding => 'Member onboarding';

  @override
  String get memberOnboardingDesc =>
      'Digital profiles, KYC documentation and initial share purchases mapped.';

  @override
  String get loanManagementMilestone => 'Loan management';

  @override
  String get loanManagementDesc =>
      'Application workflows, interest calculation and repayment tracking active.';

  @override
  String get financialReportsMilestone => 'Financial reports';

  @override
  String get financialReportsDesc =>
      'Automated ledger generation, balance sheets and dividend distribution ready.';

  @override
  String get finalHandoffReview => 'Final handoff review';

  @override
  String get dataMigrationComplete => 'Data migration complete';

  @override
  String get uatSignOff => 'UAT sign-off received';

  @override
  String get adminRolesConfigured => 'Admin roles configured';

  @override
  String get completeHandoff => 'Complete handoff';

  @override
  String get projectCompleted => 'Project completed';
}
