import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('hi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GUR BHATTI'**
  String get appTitle;

  /// No description provided for @season.
  ///
  /// In en, this message translates to:
  /// **'SEASON'**
  String get season;

  /// No description provided for @totalWeight.
  ///
  /// In en, this message translates to:
  /// **'TOTAL WEIGHT'**
  String get totalWeight;

  /// No description provided for @outstanding.
  ///
  /// In en, this message translates to:
  /// **'OUTSTANDING'**
  String get outstanding;

  /// No description provided for @liveOperations.
  ///
  /// In en, this message translates to:
  /// **'Live Operations'**
  String get liveOperations;

  /// No description provided for @recentIntake.
  ///
  /// In en, this message translates to:
  /// **'Recent Intake'**
  String get recentIntake;

  /// No description provided for @farmers.
  ///
  /// In en, this message translates to:
  /// **'Farmers'**
  String get farmers;

  /// No description provided for @totalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get totalPaid;

  /// No description provided for @newProcurement.
  ///
  /// In en, this message translates to:
  /// **'NEW PROCUREMENT'**
  String get newProcurement;

  /// No description provided for @tapToRecord.
  ///
  /// In en, this message translates to:
  /// **'Tap to record weight & vehicle'**
  String get tapToRecord;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @log.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get log;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @menuHub.
  ///
  /// In en, this message translates to:
  /// **'MENU HUB'**
  String get menuHub;

  /// No description provided for @operationalTools.
  ///
  /// In en, this message translates to:
  /// **'OPERATIONAL TOOLS'**
  String get operationalTools;

  /// No description provided for @systemConfig.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM & CONFIG'**
  String get systemConfig;

  /// No description provided for @apiSync.
  ///
  /// In en, this message translates to:
  /// **'API & SYNC'**
  String get apiSync;

  /// No description provided for @apiSyncDesc.
  ///
  /// In en, this message translates to:
  /// **'Backend connection and offline sync'**
  String get apiSyncDesc;

  /// No description provided for @rolesPermissions.
  ///
  /// In en, this message translates to:
  /// **'ROLES & PERMISSIONS'**
  String get rolesPermissions;

  /// No description provided for @rolesPermissionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Manager and Staff access levels'**
  String get rolesPermissionsDesc;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'ABOUT VERSION'**
  String get aboutVersion;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @weighbridge.
  ///
  /// In en, this message translates to:
  /// **'Weighbridge'**
  String get weighbridge;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @farmerDirectory.
  ///
  /// In en, this message translates to:
  /// **'FARMER DIRECTORY'**
  String get farmerDirectory;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or village...'**
  String get searchHint;

  /// No description provided for @registerFarmer.
  ///
  /// In en, this message translates to:
  /// **'REGISTER FARMER'**
  String get registerFarmer;

  /// No description provided for @registeredFarmers.
  ///
  /// In en, this message translates to:
  /// **'REGISTERED FARMERS'**
  String get registeredFarmers;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get total;

  /// No description provided for @editFarmer.
  ///
  /// In en, this message translates to:
  /// **'EDIT FARMER'**
  String get editFarmer;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'PERSONAL DETAILS'**
  String get personalDetails;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @village.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get village;

  /// No description provided for @bankingInfo.
  ///
  /// In en, this message translates to:
  /// **'BANKING INFORMATION (OPTIONAL)'**
  String get bankingInfo;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bankName;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get accountNumber;

  /// No description provided for @ifscCode.
  ///
  /// In en, this message translates to:
  /// **'IFSC Code'**
  String get ifscCode;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get saveChanges;

  /// No description provided for @completeRegistration.
  ///
  /// In en, this message translates to:
  /// **'COMPLETE REGISTRATION'**
  String get completeRegistration;

  /// No description provided for @farmerUpdated.
  ///
  /// In en, this message translates to:
  /// **'FARMER UPDATED'**
  String get farmerUpdated;

  /// No description provided for @farmerRegistered.
  ///
  /// In en, this message translates to:
  /// **'FARMER REGISTERED SUCCESSFULLY'**
  String get farmerRegistered;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @mobileRequired.
  ///
  /// In en, this message translates to:
  /// **'10-digit mobile required'**
  String get mobileRequired;

  /// No description provided for @procurementLog.
  ///
  /// In en, this message translates to:
  /// **'PROCUREMENT LOG'**
  String get procurementLog;

  /// No description provided for @searchFarmerVehicle.
  ///
  /// In en, this message translates to:
  /// **'Search farmer or vehicle...'**
  String get searchFarmerVehicle;

  /// No description provided for @newEntry.
  ///
  /// In en, this message translates to:
  /// **'NEW ENTRY'**
  String get newEntry;

  /// No description provided for @totalValue.
  ///
  /// In en, this message translates to:
  /// **'TOTAL VALUE'**
  String get totalValue;

  /// No description provided for @netWeight.
  ///
  /// In en, this message translates to:
  /// **'NET WEIGHT'**
  String get netWeight;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'TOTAL AMOUNT'**
  String get totalAmount;

  /// No description provided for @unknownFarmer.
  ///
  /// In en, this message translates to:
  /// **'Unknown Farmer'**
  String get unknownFarmer;

  /// No description provided for @recordIntake.
  ///
  /// In en, this message translates to:
  /// **'RECORD INTAKE'**
  String get recordIntake;

  /// No description provided for @farmerVehicle.
  ///
  /// In en, this message translates to:
  /// **'FARMER & VEHICLE'**
  String get farmerVehicle;

  /// No description provided for @vehicleNumber.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Number'**
  String get vehicleNumber;

  /// No description provided for @vehicleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. MP09AB1234'**
  String get vehicleHint;

  /// No description provided for @weightMeasurements.
  ///
  /// In en, this message translates to:
  /// **'WEIGHT MEASUREMENTS (Qtl)'**
  String get weightMeasurements;

  /// No description provided for @gross.
  ///
  /// In en, this message translates to:
  /// **'Gross'**
  String get gross;

  /// No description provided for @tare.
  ///
  /// In en, this message translates to:
  /// **'Tare'**
  String get tare;

  /// No description provided for @trashDeduction.
  ///
  /// In en, this message translates to:
  /// **'Trash / Impurity Deduction'**
  String get trashDeduction;

  /// No description provided for @ratePerQtl.
  ///
  /// In en, this message translates to:
  /// **'Rate / Qtl'**
  String get ratePerQtl;

  /// No description provided for @totalPayout.
  ///
  /// In en, this message translates to:
  /// **'TOTAL PAYOUT'**
  String get totalPayout;

  /// No description provided for @securityCapture.
  ///
  /// In en, this message translates to:
  /// **'SECURITY CAPTURE'**
  String get securityCapture;

  /// No description provided for @captureVehicleImage.
  ///
  /// In en, this message translates to:
  /// **'Capture Vehicle Image'**
  String get captureVehicleImage;

  /// No description provided for @weightVerificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Required for weight verification'**
  String get weightVerificationRequired;

  /// No description provided for @confirmSaveEntry.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM & SAVE ENTRY'**
  String get confirmSaveEntry;

  /// No description provided for @capturePhotoError.
  ///
  /// In en, this message translates to:
  /// **'Please capture a vehicle photo'**
  String get capturePhotoError;

  /// No description provided for @procurementSaved.
  ///
  /// In en, this message translates to:
  /// **'Procurement recorded successfully'**
  String get procurementSaved;

  /// No description provided for @selectFarmer.
  ///
  /// In en, this message translates to:
  /// **'Select Farmer'**
  String get selectFarmer;

  /// No description provided for @farmerNotFound.
  ///
  /// In en, this message translates to:
  /// **'FARMER NOT FOUND'**
  String get farmerNotFound;

  /// No description provided for @farmerNotFoundDesc.
  ///
  /// In en, this message translates to:
  /// **'The requested farmer record does not exist.'**
  String get farmerNotFoundDesc;

  /// No description provided for @supplyHistory.
  ///
  /// In en, this message translates to:
  /// **'SUPPLY HISTORY'**
  String get supplyHistory;

  /// No description provided for @entries.
  ///
  /// In en, this message translates to:
  /// **'ENTRIES'**
  String get entries;

  /// No description provided for @noSupplies.
  ///
  /// In en, this message translates to:
  /// **'No supplies recorded in current session'**
  String get noSupplies;

  /// No description provided for @logNewSupply.
  ///
  /// In en, this message translates to:
  /// **'LOG NEW SUPPLY'**
  String get logNewSupply;

  /// No description provided for @totalEarned.
  ///
  /// In en, this message translates to:
  /// **'TOTAL EARNED'**
  String get totalEarned;

  /// No description provided for @balanceDue.
  ///
  /// In en, this message translates to:
  /// **'BALANCE DUE'**
  String get balanceDue;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'PAY NOW'**
  String get payNow;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @veh.
  ///
  /// In en, this message translates to:
  /// **'Veh'**
  String get veh;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get paid;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get statusPending;

  /// No description provided for @statusPartial.
  ///
  /// In en, this message translates to:
  /// **'PARTIAL'**
  String get statusPartial;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get statusPaid;

  /// No description provided for @sessionManagement.
  ///
  /// In en, this message translates to:
  /// **'SESSION MANAGEMENT'**
  String get sessionManagement;

  /// No description provided for @createNewSeason.
  ///
  /// In en, this message translates to:
  /// **'CREATE NEW SEASON'**
  String get createNewSeason;

  /// No description provided for @historicalActiveSessions.
  ///
  /// In en, this message translates to:
  /// **'HISTORICAL & ACTIVE SESSIONS'**
  String get historicalActiveSessions;

  /// No description provided for @sessionInfo.
  ///
  /// In en, this message translates to:
  /// **'Sessions define the financial year for your mill operations. Only one session can be active at a time.'**
  String get sessionInfo;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get active;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'ACTIVATE'**
  String get activate;

  /// No description provided for @switchSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'SWITCH SESSION?'**
  String get switchSessionTitle;

  /// No description provided for @switchSessionDesc.
  ///
  /// In en, this message translates to:
  /// **'Do you want to make {name} the active operational session? This will change the context for all reports and entries.'**
  String switchSessionDesc(Object name);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @activateSession.
  ///
  /// In en, this message translates to:
  /// **'ACTIVATE SESSION'**
  String get activateSession;

  /// No description provided for @sessionUpdated.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE SESSION UPDATED TO {name}'**
  String sessionUpdated(Object name);
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
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
