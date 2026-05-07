// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GUR BHATTI';

  @override
  String get season => 'SEASON';

  @override
  String get totalWeight => 'TOTAL WEIGHT';

  @override
  String get outstanding => 'OUTSTANDING';

  @override
  String get liveOperations => 'Live Operations';

  @override
  String get recentIntake => 'Recent Intake';

  @override
  String get farmers => 'Farmers';

  @override
  String get totalPaid => 'Total Paid';

  @override
  String get newProcurement => 'NEW PROCUREMENT';

  @override
  String get tapToRecord => 'Tap to record weight & vehicle';

  @override
  String get seeAll => 'See all';

  @override
  String get home => 'Home';

  @override
  String get log => 'Log';

  @override
  String get menu => 'Menu';

  @override
  String get menuHub => 'MENU HUB';

  @override
  String get operationalTools => 'OPERATIONAL TOOLS';

  @override
  String get systemConfig => 'SYSTEM & CONFIG';

  @override
  String get apiSync => 'API & SYNC';

  @override
  String get apiSyncDesc => 'Backend connection and offline sync';

  @override
  String get rolesPermissions => 'ROLES & PERMISSIONS';

  @override
  String get rolesPermissionsDesc => 'Manager and Staff access levels';

  @override
  String get aboutVersion => 'ABOUT VERSION';

  @override
  String get sessions => 'Sessions';

  @override
  String get weighbridge => 'Weighbridge';

  @override
  String get reports => 'Reports';

  @override
  String get inventory => 'Inventory';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get farmerDirectory => 'FARMER DIRECTORY';

  @override
  String get searchHint => 'Search by name or village...';

  @override
  String get registerFarmer => 'REGISTER FARMER';

  @override
  String get registeredFarmers => 'REGISTERED FARMERS';

  @override
  String get total => 'TOTAL';

  @override
  String get editFarmer => 'EDIT FARMER';

  @override
  String get personalDetails => 'PERSONAL DETAILS';

  @override
  String get fullName => 'Full Name';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get village => 'Village';

  @override
  String get bankingInfo => 'BANKING INFORMATION (OPTIONAL)';

  @override
  String get bankName => 'Bank Name';

  @override
  String get accountNumber => 'Account Number';

  @override
  String get ifscCode => 'IFSC Code';

  @override
  String get saveChanges => 'SAVE CHANGES';

  @override
  String get completeRegistration => 'COMPLETE REGISTRATION';

  @override
  String get farmerUpdated => 'FARMER UPDATED';

  @override
  String get farmerRegistered => 'FARMER REGISTERED SUCCESSFULLY';

  @override
  String get required => 'Required';

  @override
  String get mobileRequired => '10-digit mobile required';

  @override
  String get procurementLog => 'PROCUREMENT LOG';

  @override
  String get searchFarmerVehicle => 'Search farmer or vehicle...';

  @override
  String get newEntry => 'NEW ENTRY';

  @override
  String get totalValue => 'TOTAL VALUE';

  @override
  String get netWeight => 'NET WEIGHT';

  @override
  String get totalAmount => 'TOTAL AMOUNT';

  @override
  String get unknownFarmer => 'Unknown Farmer';

  @override
  String get recordIntake => 'RECORD INTAKE';

  @override
  String get farmerVehicle => 'FARMER & VEHICLE';

  @override
  String get vehicleNumber => 'Vehicle Number';

  @override
  String get vehicleHint => 'e.g. MP09AB1234';

  @override
  String get weightMeasurements => 'WEIGHT MEASUREMENTS (Qtl)';

  @override
  String get gross => 'Gross';

  @override
  String get tare => 'Tare';

  @override
  String get trashDeduction => 'Trash / Impurity Deduction';

  @override
  String get ratePerQtl => 'Rate / Qtl';

  @override
  String get totalPayout => 'TOTAL PAYOUT';

  @override
  String get securityCapture => 'SECURITY CAPTURE';

  @override
  String get captureVehicleImage => 'Capture Vehicle Image';

  @override
  String get weightVerificationRequired => 'Required for weight verification';

  @override
  String get confirmSaveEntry => 'CONFIRM & SAVE ENTRY';

  @override
  String get capturePhotoError => 'Please capture a vehicle photo';

  @override
  String get procurementSaved => 'Procurement recorded successfully';

  @override
  String get selectFarmer => 'Select Farmer';

  @override
  String get farmerNotFound => 'FARMER NOT FOUND';

  @override
  String get farmerNotFoundDesc =>
      'The requested farmer record does not exist.';

  @override
  String get supplyHistory => 'SUPPLY HISTORY';

  @override
  String get entries => 'ENTRIES';

  @override
  String get noSupplies => 'No supplies recorded in current session';

  @override
  String get logNewSupply => 'LOG NEW SUPPLY';

  @override
  String get totalEarned => 'TOTAL EARNED';

  @override
  String get balanceDue => 'BALANCE DUE';

  @override
  String get payNow => 'PAY NOW';

  @override
  String get activeSession => 'Active Session';

  @override
  String get recentSupply => 'Recent Supply';

  @override
  String get sessionWeight => 'Session Weight';

  @override
  String get sessionEarned => 'Session Earned';

  @override
  String get sessionBalance => 'Session Balance';

  @override
  String get rate => 'Rate';

  @override
  String get veh => 'Veh';

  @override
  String get paid => 'PAID';

  @override
  String get statusPending => 'PENDING';

  @override
  String get statusPartial => 'PARTIAL';

  @override
  String get statusPaid => 'PAID';

  @override
  String get sessionManagement => 'SESSION MANAGEMENT';

  @override
  String get createNewSeason => 'CREATE NEW SEASON';

  @override
  String get historicalActiveSessions => 'HISTORICAL & ACTIVE SESSIONS';

  @override
  String get sessionInfo =>
      'Sessions define the financial year for your mill operations. Only one session can be active at a time.';

  @override
  String get active => 'ACTIVE';

  @override
  String get activate => 'ACTIVATE';

  @override
  String get switchSessionTitle => 'SWITCH SESSION?';

  @override
  String switchSessionDesc(Object name) {
    return 'Do you want to make $name the active operational session? This will change the context for all reports and entries.';
  }

  @override
  String get cancel => 'CANCEL';

  @override
  String get activateSession => 'ACTIVATE SESSION';

  @override
  String sessionUpdated(Object name) {
    return 'ACTIVE SESSION UPDATED TO $name';
  }

  @override
  String get intakeReceipt => 'INTAKE RECEIPT';

  @override
  String get date => 'DATE';

  @override
  String get receiptNo => 'RECEIPT #';

  @override
  String get trash => 'TRASH';

  @override
  String get authorizedSignatory => 'AUTHORIZED SIGNATORY';

  @override
  String get shareReceipt => 'SHARE RECEIPT';

  @override
  String get thankYouBusiness => 'Thank you for your business!';

  @override
  String get edit => 'Edit';

  @override
  String get share => 'Share';
}
