// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appTitle => 'Meneja wa Vikoba';

  @override
  String get navHome => 'Nyumbani';

  @override
  String get navMembers => 'Wanachama';

  @override
  String get navSavings => 'Akiba';

  @override
  String get navLoans => 'Mikopo';

  @override
  String get navShareOut => 'Mgawanyo';

  @override
  String get appBarDashboard => 'Dashibodi ya Vikoba';

  @override
  String get appBarMembers => 'Wanachama';

  @override
  String get appBarContributions => 'Michango';

  @override
  String get appBarLoans => 'Mikopo';

  @override
  String get appBarShareOut => 'Kikokotoo cha Mgawanyo';

  @override
  String get dashboardGroupOverview => 'Muhtasari wa Kikundi';

  @override
  String get totalGroupSavings => 'Akiba ya Kikundi';

  @override
  String get activeLoansValue => 'Mikopo Inayoendelea';

  @override
  String get interestEarned => 'Riba Iliyopatikana';

  @override
  String get activeMembers => 'Wanachama Waliohai';

  @override
  String get recentContributions => 'Michango ya Karibuni';

  @override
  String get loansNeedingAttention => 'Mikopo Inayohitaji Uangalizi';

  @override
  String get noContributionsYet => 'Bado hakuna michango iliyorekodiwa';

  @override
  String get nothingNeedsAttention => 'Hakuna kinachohitaji uangalizi sasa';

  @override
  String get awaitingDisbursement => 'Inasubiri kutolewa';

  @override
  String get overdue => 'Imechelewa';

  @override
  String sharesPrefix(int count, String date) {
    return '$count hisa - $date';
  }

  @override
  String get addMember => 'Ongeza Mnachama';

  @override
  String get totalShares => 'Jumla ya hisa';

  @override
  String get totalContributed => 'Jumla ya michango';

  @override
  String get noMembersYet =>
      'Hakuna wanachama bado. Bonyeza \'Ongeza Mnachama\' kusajili.';

  @override
  String get fullName => 'Jina kamili';

  @override
  String get phoneNumber => 'Namba ya simu';

  @override
  String get role => 'Wadhifa';

  @override
  String get saveMember => 'Hifadhi Mnachama';

  @override
  String memberSharesSuffix(int count) {
    return '$count hisa';
  }

  @override
  String get searchMembers => 'Tafuta wanachama';

  @override
  String get noMembersFound =>
      'Hakuna mwanachama anayelingana na utafutaji wako.';

  @override
  String get memberDetailTitle => 'Wasifu wa Mwanachama';

  @override
  String memberSince(String date) {
    return 'Mwanachama tangu $date';
  }

  @override
  String membershipDaysLabel(int days) {
    return 'Mwanachama kwa siku $days';
  }

  @override
  String get joinedDate => 'Alijiunga';

  @override
  String get nidaNumber => 'Namba ya NIDA';

  @override
  String get memberStatusActive => 'Hai';

  @override
  String get memberStatusInactive => 'Si hai';

  @override
  String get loanCapacity => 'Kikomo cha mkopo';

  @override
  String get guarantorExposure => 'Dhima ya mdhamini';

  @override
  String get memberLoans => 'Mikopo';

  @override
  String get memberContributions => 'Michango';

  @override
  String get noMemberLoans =>
      'Bado hakuna mikopo iliyorekodiwa kwa mwanachama huyu.';

  @override
  String get noMemberContributions =>
      'Bado hakuna michango iliyorekodiwa kwa mwanachama huyu.';

  @override
  String get deactivateMember => 'Zima akaunti ya mwanachama';

  @override
  String get reactivateMember => 'Washa akaunti ya mwanachama';

  @override
  String get deactivateConfirmTitle => 'Zima akaunti ya mwanachama?';

  @override
  String deactivateConfirmBody(String name) {
    return 'Zima $name asiweze kuchanga, kuchukua mikopo au kuhudhuria vikao? Historia yake inabaki kwenye kumbukumbu.';
  }

  @override
  String get memberDeactivated => 'Akaunti ya mwanachama imezimwa';

  @override
  String get memberReactivated => 'Akaunti ya mwanachama imewashwa';

  @override
  String get cancel => 'Ghairi';

  @override
  String get recordContribution => 'Rekodi Mchango';

  @override
  String get record => 'Rekodi';

  @override
  String get lastContribution => 'Mchango wa mwisho';

  @override
  String get member => 'Mnachama';

  @override
  String get numberOfShares => 'Idadi ya hisa';

  @override
  String oneShareHelper(String amount) {
    return 'Hisa 1 = $amount';
  }

  @override
  String get noteOptional => 'Maelezo (si muhimu)';

  @override
  String get totalAmount => 'Jumla ya kiasi';

  @override
  String get saveContribution => 'Hifadhi Mchango';

  @override
  String get newLoan => 'Mkopo Mpya';

  @override
  String get newLoanRequest => 'Ombi la Mkopo Mpya';

  @override
  String get loanAmount => 'Kiasi cha mkopo (TZS)';

  @override
  String interestRateHelper(String rate) {
    return 'Riba: $rate%';
  }

  @override
  String get repaymentPeriod => 'Muda wa kurudisha';

  @override
  String daysPeriod(int days) {
    return 'siku $days';
  }

  @override
  String get submitRequest => 'Tuma Ombi';

  @override
  String get principal => 'Kiasi cha mkopo';

  @override
  String get due => 'Inadaiwa';

  @override
  String get reject => 'Kataa';

  @override
  String get approve => 'Idhinisha';

  @override
  String get disburse => 'Toa';

  @override
  String get recordRepayment => 'Rekodi Ulipaji';

  @override
  String repaymentTitle(String name) {
    return 'Ulipaji - $name';
  }

  @override
  String get balance => 'Salio';

  @override
  String get amountTzs => 'Kiasi (TZS)';

  @override
  String get saveRepayment => 'Hifadhi Ulipaji';

  @override
  String repaidOf(String amount, String total) {
    return '$amount kati ya $total';
  }

  @override
  String get noLoansYet => 'Hakuna mikopo bado';

  @override
  String get pendingLoans => 'Mikopo inayosubiri';

  @override
  String get loanEligibilityError =>
      'Kiasi kinazidi kikomo cha mkopo cha mwanachama huyu kwa kanuni za kikundi.';

  @override
  String get loanEligibilityOpen =>
      'Mwanachama huyu bado ana mkopo uliokubaliwa au unaoendelea.';

  @override
  String get loanBelowMinimum =>
      'Kiasi kiko chini ya kiwango cha chini cha mkopo cha kikundi.';

  @override
  String get loanSelfRequestHint =>
      'Ombi linapelekwa kwa viongozi kwa kukubaliwa — utaarifiwa uamuzi.';

  @override
  String get loanProduct => 'Aina ya mkopo';

  @override
  String get loanProductHelper =>
      'Aina ya mkopo huweka njia ya riba, kikomo cha muda na kanuni za adhabu.';

  @override
  String get loanTermMonths => 'Muda wa kurudisha (miezi)';

  @override
  String monthsPeriod(int count) {
    return 'miezi $count';
  }

  @override
  String get guarantors => 'Wadhamini (hadi 2)';

  @override
  String get guarantorHint => 'Mdhamini hushiriki wajibu wa kulipa mkopo huu.';

  @override
  String get guarantorSelect => 'Chagua mdhamini';

  @override
  String get guarantorNone => 'Hakuna mdhamini';

  @override
  String get noProductsYet => 'Bado hakuna aina za mikopo zilizosanidiwa.';

  @override
  String get loanEligibleOk => 'Unastahili — tuma kuendelea.';

  @override
  String get loanMemberInactive => 'Mwanachama huyu hayuko hai.';

  @override
  String get loanMembershipTooShort =>
      'Mwanachama amejiunga hivi karibuni mno kukopa.';

  @override
  String get loanTermTooLong => 'Muda unazidi kikomo cha aina hii ya mkopo.';

  @override
  String loanMaxAllowedHint(String amount) {
    return 'Kiwango cha juu kinachoruhusiwa: $amount';
  }

  @override
  String get quoteTitle => 'Makadirio ya Mkopo';

  @override
  String get quoteTotalInterest => 'Jumla ya riba';

  @override
  String get quoteTotalPayable => 'Jumla ya kulipa';

  @override
  String get quoteMonthlyInstallment => 'Malipo ya kila mwezi';

  @override
  String get quoteMethodFlat => 'Riba ya mara kwa mara';

  @override
  String get quoteMethodReducing => 'Riba inayopungua';

  @override
  String quoteInstallments(int count) {
    return 'michango $count';
  }

  @override
  String get penaltyAccrued => 'Adhabu zilizojilimbikiza';

  @override
  String penaltyRateHint(String value, int days) {
    return '$value kwa kila siku $days za kuchelewa baada ya muda wa msamaha';
  }

  @override
  String get loanDetailTitle => 'Maelezo ya mkopo';

  @override
  String get scheduleTitle => 'Ratiba ya ulipaji';

  @override
  String get installmentShort => 'Michango';

  @override
  String get installmentTotal => 'Jumla';

  @override
  String dueOn(String date) {
    return 'Inadaiwa $date';
  }

  @override
  String get paidLabel => 'Imelipwa';

  @override
  String get unpaidLabel => 'Haijalipwa';

  @override
  String get waterfallPenalty => 'Adhabu iliyolipwa';

  @override
  String get waterfallInterest => 'Riba iliyolipwa';

  @override
  String get waterfallPrincipal => 'Mkuu aliyelipwa';

  @override
  String overpaymentReturned(String amount) {
    return 'Ziada imerudishwa: $amount';
  }

  @override
  String get guarantorsList => 'Wadhamini';

  @override
  String get noGuarantors => 'Hakuna wadhamini';

  @override
  String get loanAmountRepaid => 'Imelipwa';

  @override
  String get totalPayableToMembers => 'Jumla Inayolipwa kwa Wanachama';

  @override
  String get shareOutSubtitle =>
      'Akiba + riba iliyopatikana, kukokotolewa kiotomatiki';

  @override
  String get perMemberBreakdown => 'Mgawanyo kwa Kila Mnachama';

  @override
  String get savings => 'Akiba';

  @override
  String get interestShare => 'Sehemu ya riba';

  @override
  String get totalPayout => 'Jumla ya malipo';

  @override
  String get savingsPoolComposition => 'Muundo wa Mfuko wa Akiba';

  @override
  String get noSharesYet => 'Bado hakuna hisa zilizorekodiwa';

  @override
  String ofPool(String pct) {
    return '$pct% ya mfuko';
  }

  @override
  String get appBarMeetings => 'Mikutano';

  @override
  String get noMeetingsYet => 'Bado hakuna mikutano iliyorekodiwa.';

  @override
  String get newMeeting => 'Rekodi Mkutano';

  @override
  String get meetingDate => 'Tarehe ya mkutano';

  @override
  String get meetingAgenda => 'Ajenda';

  @override
  String get attendance => 'Mahudhurio';

  @override
  String get presentMembers => 'Waliohudhuria';

  @override
  String absentCount(int count) {
    return '$count hawakuhudhuria';
  }

  @override
  String attendanceRate(String pct) {
    return 'Mahudhurio $pct%';
  }

  @override
  String get saveMeeting => 'Hifadhi Mkutano';

  @override
  String get logAttendance => 'Weka mahudhurio';

  @override
  String get agendaLabel => 'Ajenda';

  @override
  String get appBarReports => 'Ripoti';

  @override
  String get reportsSubtitle => 'Hamisha rekodi kwa leja ya kikundi.';

  @override
  String get reportMembers => 'Wanachama';

  @override
  String get reportContributions => 'Michango';

  @override
  String get reportLoans => 'Mikopo';

  @override
  String reportRows(int count) {
    return 'safu $count';
  }

  @override
  String get copyCsv => 'Nakili CSV';

  @override
  String get copiedToClipboard => 'Imenakiliwa kwenye ubao';

  @override
  String get csvPreview => 'Hakiki CSV';

  @override
  String get viewCsv => 'Gusa ripoti kuiona hakiki';

  @override
  String get reportReady => 'Tayari kuhamishwa';

  @override
  String get appearance => 'Muonekano';

  @override
  String get darkMode => 'Hali ya giza';

  @override
  String get accountSwitchTitle => 'Taarifa za akaunti';

  @override
  String get accountSwitchHint => 'Hali ya demo — chagua wadhifa kuona ruhusa.';

  @override
  String get notificationsTitle => 'Taarifa';

  @override
  String get notificationsMarkAllRead => 'Weka zote zimesomwa';

  @override
  String get notificationsEmpty =>
      'Hakuna taarifa bado. Taarifa kuhusu rekodi zako zitaonekana hapa.';

  @override
  String get notifContribution => 'Mchango umerekodiwa';

  @override
  String get notifLoanRequested => 'Ombi la mkopo limepelekwa';

  @override
  String get notifLoanApproved => 'Mkopo umekubaliwa';

  @override
  String get notifLoanRejected => 'Ombi la mkopo halijakubaliwa';

  @override
  String get notifRepayment => 'Malipo yamerekodiwa';

  @override
  String get notifAttendancePresent => 'Umehudhuria mkutano';

  @override
  String get notifAttendanceAbsent => 'Haikuhudhuria mkutano';

  @override
  String notifBodyContribution(String amount) {
    return '$amount limeongezwa kwenye akiba yako';
  }

  @override
  String notifBodyLoanRequested(String amount) {
    return 'Ombi lako la mkopo wa $amount linasubiri kukubaliwa';
  }

  @override
  String notifBodyLoanApproved(String amount) {
    return 'Mkopo wako wa $amount umekubaliwa';
  }

  @override
  String notifBodyLoanRejected(String amount) {
    return 'Ombi lako la mkopo wa $amount halijakubaliwa';
  }

  @override
  String notifBodyRepayment(String amount) {
    return '$amount imelipwa kwenye mkopo wako';
  }

  @override
  String get notifBodyAttendancePresent => 'Umehudhuria mkutano';

  @override
  String get notifBodyAttendanceAbsent => 'Haikujahudhuria mkutano';

  @override
  String get syncTitle => 'Seva';

  @override
  String syncPending(num count) {
    return 'Inasawazisha mabadiliko $count';
  }

  @override
  String get syncNothing => 'Taarifa zimesawazishwa na seva';

  @override
  String get syncNotConnected => 'Hajaunganishwa kwenye seva';

  @override
  String get syncToken => 'Tokeni ya seva';

  @override
  String get syncTokenHint =>
      'Bearer token kutoka POST /api/v1/auth/login (backend demos)';

  @override
  String get syncBaseUrl => 'Anwani ya seva';

  @override
  String get syncSave => 'Unganisha';

  @override
  String get syncNow => 'Sawazisha sasa';

  @override
  String get syncServerConnected =>
      'Umeunganishwa - mabadiliko yatasawazishwa kiotomatiki';

  @override
  String get syncServerConfigured =>
      'Seva imeusanwa - kuhifadhi mabadiliko kunasawazisha na seva';

  @override
  String get syncServerNotConfigured =>
      'Hali ya nje ya mtandao. Weka tokeni hapo juu kusawazisha mabadiliko.';

  @override
  String get authSignInSubtitle =>
      'Ingia ili kumbukumbu za kikundi zisawazishwe.';

  @override
  String get authEmail => 'Barua pepe';

  @override
  String get authPassword => 'Nenosiri';

  @override
  String get authPhone => 'Nambari ya simu';

  @override
  String get authSignIn => 'Ingia';

  @override
  String get authContinueOffline => 'Endelea bila mtandao';

  @override
  String get authOfflineHint => 'Huna seva? Fungua demo na akaunti za mfano.';

  @override
  String get authRegister => 'Sajili kikundi kipya';

  @override
  String get authName => 'Jina kamili';

  @override
  String get authGroupName => 'Jina la kikundi';

  @override
  String get authCreateAccount => 'Unda akaunti';

  @override
  String get authLogout => 'Toka';

  @override
  String authSignedInAs(String name) {
    return 'Umeingia kama $name';
  }

  @override
  String get navMore => 'Zaidi';

  @override
  String get moreTitle => 'Zaidi';

  @override
  String get moreSubtitle => 'Usimamizi wa kikundi na zana';

  @override
  String get groupSettings => 'Mipangilio ya kikundi';

  @override
  String get activityHistory => 'Historia ya shughuli';

  @override
  String get auditLog => 'Kumbukumbu za ukaguzi';

  @override
  String get exportData => 'Toa takwimu';

  @override
  String get syncCenter => 'Kituo cha usawazishaji';

  @override
  String get settlement => 'Kukamilisha malipo';

  @override
  String get savingsReport => 'Ripoti ya akiba';

  @override
  String get projectCompletion => 'Hitimisho la mradi';

  @override
  String get loanManagement => 'Udhibiti wa mikopo';

  @override
  String get groupSettingsDesc =>
      'Tarehe za mzunguko, sheria za michango na mikopo';

  @override
  String get activityHistoryDesc => 'Rekodi ya shughuli za kikundi';

  @override
  String get auditLogDesc => 'Rekodi isiyobadilika ya hatua za viongozi';

  @override
  String get exportDataDesc => 'Taarifa, michango na mikopo';

  @override
  String get syncCenterDesc =>
      'Usawazishaji wa nje ya mtandao na afya ya hifadhi';

  @override
  String get settlementDesc => 'Funga na gawa malipo ya mzunguko';

  @override
  String get savingsReportDesc =>
      'Muhtasari wa utajiri na ripoti za kila mwezi';

  @override
  String get projectCompletionDesc =>
      'Orodha ya ukamilishaji na mapitio ya mwisho';

  @override
  String get currentCycle => 'Mzunguko wa sasa';

  @override
  String get cycleActive => 'Hai';

  @override
  String get startDate => 'Tarehe ya kuanza';

  @override
  String get endDate => 'Tarehe ya kumaliza';

  @override
  String get duration => 'Muda';

  @override
  String monthsCount(int count) {
    return 'miezi $count';
  }

  @override
  String get contributionRules => 'Sheria za michango';

  @override
  String get sharePrice => 'Bei ya hisa';

  @override
  String get minSharesPerMonth => 'Hisa za chini kwa mwezi';

  @override
  String get lateFine => 'Faini ya kuchelewa';

  @override
  String get loanRules => 'Sheria za mikopo';

  @override
  String get interestRate => 'Riba';

  @override
  String get maxMultiplier => 'Kiwango cha juu';

  @override
  String get maxRepayment => 'Muda wa marejesho';

  @override
  String get memberManagement => 'Usimamizi wa wanachama';

  @override
  String get manageRoles => 'Majukumu';

  @override
  String get addMemberShort => 'Ongeza mwanachama';

  @override
  String memberSinceShort(String date) {
    return 'Mwanachama tangu $date';
  }

  @override
  String get closeCycle => 'Funga mzunguko';

  @override
  String get archiveData => 'Hifadhi data';

  @override
  String get notTime => 'Si wakati';

  @override
  String get actionsThisMonth => 'Shughuli mwezi huu';

  @override
  String get alerts => 'Arifa muhimu';

  @override
  String get today => 'Leo';

  @override
  String get yesterday => 'Jana';

  @override
  String get activityFinancial => 'Kifedha';

  @override
  String get activityMember => 'Mwanachama';

  @override
  String get activitySystem => 'Mfumo';

  @override
  String get loanDisbursed => 'Mkopo umetolewa';

  @override
  String get loanRepaid => 'Mkopo umelipwa kikamilifu';

  @override
  String get backupSuccessful => 'Hifadhi imefanikiwa';

  @override
  String get contributionPending => 'Mchango unasubiri';

  @override
  String get activityContribution => 'Mchango umerekodiwa';

  @override
  String get activityMeeting => 'Mkutano umeandikwa';

  @override
  String get activityNoData => 'Hakuna shughuli bado';

  @override
  String get activityNoDataBody =>
      'Michango, mikopo na mikutano vitaonekana hapa.';

  @override
  String get immutableRecord => 'Rekodi isiyobadilika';

  @override
  String get searchActions => 'Tafuta matukio';

  @override
  String get allActions => 'Matukio yote';

  @override
  String get filterSettings => 'Mipangilio';

  @override
  String get filterMembers => 'Wanachama';

  @override
  String get filterLoans => 'Mikopo';

  @override
  String auditChangedSharePrice(String from, String to) {
    return 'Badilisha bei ya hisa kutoka $from kwenda $to';
  }

  @override
  String auditAddedMember(String name) {
    return 'Ongeza mwanachama mpya: $name';
  }

  @override
  String auditApprovedLoan(String id, String amount) {
    return 'Kubali mkopo $id wa $amount';
  }

  @override
  String get auditNoEntries => 'Hakuna kumbukumbu za ukaguzi bado';

  @override
  String get fullFinancialStatement => 'Taarifa kamili ya kifedha';

  @override
  String get fullFinancialStatementDesc =>
      'Rekodi kamili ya mapato, matumizi na mizani ya sasa ya kikundi.';

  @override
  String get exportMemberContributions => 'Michango ya wanachama';

  @override
  String get exportMemberContributionsDesc =>
      'Muhtasari wa hisa na akiba za kila mwanachama.';

  @override
  String get loanPerformance => 'Utendaji wa mikopo';

  @override
  String get loanPerformanceDesc =>
      'Hali ya mikopo inayoendelea, malipo yaliyofanywa na mabaki.';

  @override
  String get exportCompleteBundle => 'Toa ripoti zote';

  @override
  String get exportCompleteBundleDesc =>
      'Pakua ripoti iliyounganishwa ya taarifa zote za kifedha za sasa.';

  @override
  String get exportAllPdf => 'Toa Ripoti Zote (PDF)';

  @override
  String get exportPdf => 'PDF';

  @override
  String get exportCsv => 'CSV';

  @override
  String get exporting => 'Inaandaa ripoti...';

  @override
  String get currentlyOffline => 'Huna mtandao kwa sasa';

  @override
  String get offlineBody =>
      'Unafanya kazi bila mtandao. Mabadiliko yanahifadhiwa ndani na yatasawazishwa kiotomatiki mtandao ukirudi.';

  @override
  String get searchingNetwork => 'Inatafuta mtandao...';

  @override
  String get pendingChanges => 'Mabadiliko yanayosubiri';

  @override
  String contributionsRecorded(int count) {
    return '$count michango imerekodiwa';
  }

  @override
  String memberProfileUpdated(int count) {
    return '$count wasifu wa wanachama umesasishwa';
  }

  @override
  String get localBadge => 'Ndani';

  @override
  String get storageHealth => 'Afya ya hifadhi';

  @override
  String get capacityUsed => 'Uwezo uliotumika';

  @override
  String get storageSafe => 'Salama';

  @override
  String mbAvailable(int size) {
    return '${size}MB yapatikana';
  }

  @override
  String get syncCompleteTitle => 'Usawazishaji umekamilika';

  @override
  String get syncCompleteBody => 'Data yako sasa iko salama kwenye seva.';

  @override
  String updatedRecords(int count) {
    return 'Imesasisha rekodi $count';
  }

  @override
  String syncedPhotos(int count) {
    return 'Imesawazisha picha $count';
  }

  @override
  String lastSync(String time) {
    return 'Sawazisho la mwisho: $time';
  }

  @override
  String get returnToDashboard => 'Rudi nyumbani';

  @override
  String get synced => 'Imesawazishwa';

  @override
  String get totalGroupWealth => 'Jumla ya utajiri wa kikundi';

  @override
  String vsLastMonth(String pct) {
    return '+$pct% ikilinganishwa na mwezi uliopita';
  }

  @override
  String get generateReport => 'Tengeneza ripoti';

  @override
  String get reportMonth => 'Mwezi';

  @override
  String get reportYear => 'Mwaka';

  @override
  String get downloadReport => 'Pakua';

  @override
  String get recentReports => 'Ripoti za hivi karibuni';

  @override
  String monthlyReport(String month) {
    return 'Ripoti ya $month';
  }

  @override
  String get noReportsYet => 'Hakuna ripoti zilizotengenezwa bado';

  @override
  String get compliance => 'Utiifu wa michango';

  @override
  String get onTime => 'Wakati';

  @override
  String get late => 'Wamechelewa';

  @override
  String get capitalGrowth => 'Ukuaji wa mtaji';

  @override
  String momGrowth(String pct) {
    return '+$pct% MoM';
  }

  @override
  String get topSavers => 'Wanachama vinara';

  @override
  String get consistentSaver => 'Mchangiaji wa kawaida';

  @override
  String get earlyPayer => 'Analipa mapema';

  @override
  String get pdfButton => 'PDF';

  @override
  String get shareReport => 'Shiriki ripoti';

  @override
  String quarterlyReport(int quarter) {
    return 'Ripoti ya Robo $quarter';
  }

  @override
  String get monthlyPerformance => 'Mchanganuo wa utendaji';

  @override
  String get totalMembers => 'Jumla ya wanachama';

  @override
  String get totalDisbursed => 'Jumla inayogawiwa';

  @override
  String get readyForDisbursement => 'Tayari kwa mgao';

  @override
  String get allLoansSettled => 'Mikopo yote imelipwa';

  @override
  String get calculationsVerified => 'Mahesabu yamethibitishwa';

  @override
  String get finalReportGenerated => 'Ripoti ya mwisho imeandaliwa';

  @override
  String get warningTitle => 'Angalizo';

  @override
  String get warningBody => 'Taarifa zote zitafungwa baada ya hatua hii.';

  @override
  String get lockAndDisburse => 'Funga na gawa fedha';

  @override
  String get pdfReport => 'Ripoti ya PDF';

  @override
  String get printReceipts => 'Chapisha risiti';

  @override
  String get settlementComplete => 'Malipo yamekamilika';

  @override
  String get cycleClosedBody => 'Mzunguko umefungwa na fedha zimegawiwa.';

  @override
  String get disbursed => 'Imegawiwa';

  @override
  String get reviewApplication => 'Hakiki ombi';

  @override
  String get loanRequest => 'Maombi ya mkopo';

  @override
  String get requestedAmount => 'Kiasi kinachoombwa';

  @override
  String get totalToRepay => 'Jumla ya kurejesha';

  @override
  String get purpose => 'Dhumuni';

  @override
  String get eligibilityCheck => 'Uhakiki wa vigezo';

  @override
  String get savingsToLoanRatio => 'Uwiano wa akiba na mkopo';

  @override
  String get safe => 'Salama';

  @override
  String get activeLoans => 'Mikopo inayoendelea';

  @override
  String get none => 'Hakuna';

  @override
  String get approveLoan => 'Kubali';

  @override
  String get rejectLoan => 'Kataa';

  @override
  String get approvedConfirm => 'Mkopo umekubaliwa';

  @override
  String get rejectedConfirm => 'Ombi la mkopo limekataliwa';

  @override
  String get noPurposeGiven => 'Hakuna dhumuni';

  @override
  String get actionNeeded => 'Inahitaji hatua';

  @override
  String get pendingApprovals => 'Maombi yanayosubiri';

  @override
  String get loanHistory => 'Historia ya mikopo';

  @override
  String get reviewButton => 'Pitia';

  @override
  String get noPendingApprovals => 'Hakuna maombi yanayosubiri';

  @override
  String get noLoansInHistory => 'Hakuna mikopo katika historia bado';

  @override
  String get groupRegistered => 'Kikundi kimesajiliwa salama';

  @override
  String get groupReadyBody => 'Kikundi chako cha akiba kiko tayari kukua.';

  @override
  String get nextSteps => 'Hatua zinazofuata';

  @override
  String get inviteMembers => 'Alika wanachama';

  @override
  String get setRules => 'Weka kanuni';

  @override
  String get goToDashboard => 'Nenda kwenye dashibodi';

  @override
  String get projectComplete => 'Mradi umekamilika';

  @override
  String get projectCompleteBody =>
      'Moduli zote kuu za mfumo wa usimamizi wa kikundi cha Umoja Vikoba zimeunganishwa na kujaribiwa kwa mafanikio.';

  @override
  String get milestonesAchieved => 'Hatua zilizofikiwa';

  @override
  String get memberOnboarding => 'Usajili wa wanachama';

  @override
  String get memberOnboardingDesc =>
      'Wasifu wa kidijitali, hati za KYC na ununuzi wa hisa za awali zimepangwa.';

  @override
  String get loanManagementMilestone => 'Usimamizi wa mikopo';

  @override
  String get loanManagementDesc =>
      'Mchakato wa maombi, kukokotoa riba na ufuatiliaji wa marejesho yameanza.';

  @override
  String get financialReportsMilestone => 'Ripoti za kifedha';

  @override
  String get financialReportsDesc =>
      'Uundaji wa leja kiotomatiki, mizani na mgao wa faida uko tayari.';

  @override
  String get finalHandoffReview => 'Mapitio ya mwisho';

  @override
  String get dataMigrationComplete => 'Data zimehamishiwa';

  @override
  String get uatSignOff => 'Sahihi ya majaribio imepatikana';

  @override
  String get adminRolesConfigured => 'Majukumu ya uongozi yamepangwa';

  @override
  String get completeHandoff => 'Kamilisha ukabidhi';

  @override
  String get projectCompleted => 'Mradi umekamilika';
}
