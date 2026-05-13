import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
    Locale('ar'),
    Locale('en'),
    Locale('tr'),
  ];

  /// Placeholder title shown in right panel before any cell is selected
  ///
  /// In en, this message translates to:
  /// **'Select a Cell'**
  String get common_selectCellTitle;

  /// Badge shown on a cell that has no drug or patient assignment
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get common_noAssignmentBadge;

  /// Badge shown on a cell that has a drug assignment
  ///
  /// In en, this message translates to:
  /// **'Drug Assigned'**
  String get common_drugAssignedBadge;

  /// Badge shown on a cell that has a patient assignment
  ///
  /// In en, this message translates to:
  /// **'Patient Assigned'**
  String get common_patientAssignedBadge;

  /// Empty-state title when cabin data is unavailable
  ///
  /// In en, this message translates to:
  /// **'No Cabinet Data Found'**
  String get common_noCabinDataTitle;

  /// Empty-state description when cabin data is unavailable
  ///
  /// In en, this message translates to:
  /// **'The cabinet may not be configured yet\nor the connection could not be established.'**
  String get common_noCabinDataDescription;

  /// Empty-state title when a search or filter returns no results
  ///
  /// In en, this message translates to:
  /// **'No Results Found'**
  String get common_noResultsTitle;

  /// Empty-state description when a search or filter returns no results
  ///
  /// In en, this message translates to:
  /// **'Try changing your search criteria.'**
  String get common_noResultsDescription;

  /// Generic retry button label used in error states
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retryButton;

  /// Generic cancel button label used in dialogs
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancelButton;

  /// Fallback message shown for unknown dashboard routes
  ///
  /// In en, this message translates to:
  /// **'Page Not Found'**
  String get common_pageNotFound;

  /// Minimum quantity field label in drug assignment panel
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get common_minLabel;

  /// Maximum quantity field label in drug assignment panel
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get common_maxLabel;

  /// Critical quantity field label in drug assignment panel
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get common_criticalLabel;

  /// Subtitle below the logo on the login screen
  ///
  /// In en, this message translates to:
  /// **'Sign in to the system'**
  String get auth_loginSubtitle;

  /// Label for the email/username field on the login screen
  ///
  /// In en, this message translates to:
  /// **'Email / Username'**
  String get auth_emailLabel;

  /// Label for the password field on the login screen
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_passwordLabel;

  /// Login button on the login screen
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get auth_loginButton;

  /// Generic error message shown when login fails without a specific message
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get auth_genericError;

  /// Application name shown in the top app bar
  ///
  /// In en, this message translates to:
  /// **'MEDICINE CABINET MANAGEMENT'**
  String get dashboard_appBarTitle;

  /// Tooltip for the logout icon button in the top app bar
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get dashboard_logoutTooltip;

  /// Login button shown in the app bar when no user is logged in
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get dashboard_loginBarButton;

  /// KPI card label for active patients count
  ///
  /// In en, this message translates to:
  /// **'Active Patients'**
  String get dashboard_kpiActivePatients;

  /// KPI card label for completed operations count
  ///
  /// In en, this message translates to:
  /// **'Completed Operations'**
  String get dashboard_kpiCompletedOps;

  /// KPI card label for pending prescriptions count
  ///
  /// In en, this message translates to:
  /// **'Pending Prescriptions'**
  String get dashboard_kpiPendingPrescriptions;

  /// KPI card label for critical alerts count
  ///
  /// In en, this message translates to:
  /// **'Critical Alerts'**
  String get dashboard_kpiCriticalAlerts;

  /// Section header for the cabin status card on the dashboard
  ///
  /// In en, this message translates to:
  /// **'CABINET STATUS'**
  String get dashboard_cabinStatusHeader;

  /// Label for the cabin working-status row inside the cabin card
  ///
  /// In en, this message translates to:
  /// **'Cabinet Status'**
  String get dashboard_cabinStatusLabel;

  /// Error label shown in place of the KPI section when loading fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load KPI data'**
  String get dashboard_kpiLoadError;

  /// Error label shown in place of the cabin section when loading fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load cabinet data'**
  String get dashboard_cabinLoadError;

  /// Error label shown in place of the treatments section when loading fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load treatment list'**
  String get dashboard_treatmentsLoadError;

  /// Error label shown in place of the expiry-date section when loading fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load expiry data'**
  String get dashboard_sktLoadError;

  /// Placeholder description in patient-assignment right panel before a cell is selected
  ///
  /// In en, this message translates to:
  /// **'Select a cell from the center\npanel to assign a bed.'**
  String get assignment_assignBedPlaceholder;

  /// Placeholder description in drug-assignment right panel before a cell is selected
  ///
  /// In en, this message translates to:
  /// **'Select a cell from the center\npanel to make an assignment.'**
  String get assignment_assignDrugPlaceholder;

  /// Section label above the hospitalization selector in the patient-assignment panel
  ///
  /// In en, this message translates to:
  /// **'PATIENT / ADMISSION'**
  String get assignment_hospitalizationSectionLabel;

  /// Hint text in the hospitalization selector button when nothing is selected
  ///
  /// In en, this message translates to:
  /// **'Select admission...'**
  String get assignment_hospitalizationSelectorHint;

  /// Title of the dialog for selecting a hospitalization/bed
  ///
  /// In en, this message translates to:
  /// **'Select Admission'**
  String get assignment_selectHospitalizationDialogTitle;

  /// Section label above the drug selector in the drug-assignment panel
  ///
  /// In en, this message translates to:
  /// **'DRUG'**
  String get assignment_drugSectionLabel;

  /// Hint text in the drug selector button when nothing is selected
  ///
  /// In en, this message translates to:
  /// **'Select drug...'**
  String get assignment_drugSelectorHint;

  /// Title of the dialog for selecting a drug/medicine
  ///
  /// In en, this message translates to:
  /// **'Select Drug'**
  String get assignment_selectDrugDialogTitle;

  /// Section label above the min/max/critical quantity input fields
  ///
  /// In en, this message translates to:
  /// **'QUANTITY'**
  String get assignment_quantitySectionLabel;

  /// Primary button to save a new drug or patient assignment
  ///
  /// In en, this message translates to:
  /// **'Save Assignment'**
  String get assignment_saveAssignmentButton;

  /// Danger button to remove an existing drug or patient assignment
  ///
  /// In en, this message translates to:
  /// **'Remove Assignment'**
  String get assignment_removeAssignmentButton;

  /// Primary button to update an existing patient assignment to a different hospitalization
  ///
  /// In en, this message translates to:
  /// **'Change Assignment'**
  String get assignment_changeAssignmentButton;

  /// Label for the room/bed info row inside the patient card
  ///
  /// In en, this message translates to:
  /// **'Room / Bed'**
  String get assignment_roomBedLabel;

  /// Label for the physical service info row inside the patient card
  ///
  /// In en, this message translates to:
  /// **'Ward'**
  String get assignment_serviceLabel;

  /// Error message shown when the selected cell ID cannot be resolved before saving
  ///
  /// In en, this message translates to:
  /// **'Selected cell not found'**
  String get assignment_cellNotFoundError;

  /// Success snackbar/state message after a patient assignment is saved
  ///
  /// In en, this message translates to:
  /// **'Patient assignment saved successfully'**
  String get assignment_patientSavedSuccess;

  /// Success snackbar/state message after a patient assignment is removed
  ///
  /// In en, this message translates to:
  /// **'Patient assignment removed'**
  String get assignment_patientRemovedSuccess;

  /// Placeholder description in the fault right panel before a cell/slot is selected
  ///
  /// In en, this message translates to:
  /// **'Select a cell from the center\npanel to report a fault.'**
  String get fault_selectCellPlaceholder;

  /// Section label above the fault description text field
  ///
  /// In en, this message translates to:
  /// **'DESCRIPTION'**
  String get fault_descriptionSectionLabel;

  /// Hint text inside the fault description multi-line text field
  ///
  /// In en, this message translates to:
  /// **'Describe the fault...'**
  String get fault_descriptionHint;

  /// Left segment button label for selecting 'fault' status when reporting a new record
  ///
  /// In en, this message translates to:
  /// **'FAULT'**
  String get fault_faultSegmentLabel;

  /// Right segment button label for selecting 'maintenance' status when reporting a new record
  ///
  /// In en, this message translates to:
  /// **'MAINTENANCE'**
  String get fault_maintenanceSegmentLabel;

  /// Section label above the fault history list
  ///
  /// In en, this message translates to:
  /// **'HISTORY'**
  String get fault_historySectionLabel;

  /// Status label for a resolved/closed fault record in the history list
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get fault_historyStatusCompleted;

  /// Status label for a maintenance record in the history list
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get fault_historyStatusMaintenance;

  /// Status label for an active fault record in the history list
  ///
  /// In en, this message translates to:
  /// **'Fault'**
  String get fault_historyStatusFault;

  /// Badge shown next to active (not yet closed) fault records in the history list
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get fault_historyActiveBadge;

  /// Warning banner shown when the selected cell already has an active fault/maintenance record
  ///
  /// In en, this message translates to:
  /// **'This cell has an active {label} record. Confirming will close this record.'**
  String fault_activeFaultBanner(String label);

  /// Submit button label when creating a new fault/maintenance record
  ///
  /// In en, this message translates to:
  /// **'Report Fault'**
  String get fault_reportFaultButton;

  /// Submit button label when closing an existing active fault/maintenance record
  ///
  /// In en, this message translates to:
  /// **'Close Record'**
  String get fault_closeFaultButton;

  /// Success message shown after a fault record is successfully created
  ///
  /// In en, this message translates to:
  /// **'Fault record created.'**
  String get fault_recordCreatedSuccess;

  /// Success message shown after a fault record is successfully closed
  ///
  /// In en, this message translates to:
  /// **'Fault record closed.'**
  String get fault_recordClosedSuccess;

  /// Type badge label shown on the mobile cabin slot card in the left overview panel
  ///
  /// In en, this message translates to:
  /// **'MOBILE'**
  String get cabin_mobileTypeLabel;

  /// Header title of the mobile cabin drawer panel (center panel)
  ///
  /// In en, this message translates to:
  /// **'Mobile Drawer'**
  String get cabin_mobileDrawerTitle;

  /// Cell count label on the mobile cabin slot card
  ///
  /// In en, this message translates to:
  /// **'{count} cells'**
  String cabin_cellCountLabel(int count);

  /// Label for the drawer count stat box in the cabin stats grid
  ///
  /// In en, this message translates to:
  /// **'Drawers'**
  String get cabin_drawerStatsLabel;

  /// Sub-label for the drawer stat box showing full and empty counts
  ///
  /// In en, this message translates to:
  /// **'{full} full · {empty} empty'**
  String cabin_statsFullEmpty(int full, int empty);

  /// Hint text shown in the center panel when no drawer/slot is selected
  ///
  /// In en, this message translates to:
  /// **'Tap a drawer'**
  String get cabin_touchDrawerHint;

  /// Subtitle of the empty-state shown in the mobile drawer panel before a slot is selected
  ///
  /// In en, this message translates to:
  /// **'Mobile cabinet cell grid will be displayed'**
  String get cabin_mobileGridPlaceholder;

  /// Subtitle of the empty-state shown in the master drawer panel before a drawer is selected
  ///
  /// In en, this message translates to:
  /// **'Cubic · Unit Dose · Serum internal structures will be displayed'**
  String get cabin_masterGridPlaceholder;

  /// Uppercase drawer-type badge shown on kubik drawer cards in the master overview panel
  ///
  /// In en, this message translates to:
  /// **'CUBIC'**
  String get cabin_kubikTypeLabel;

  /// Header name for serum-type drawers in the master drawer panel
  ///
  /// In en, this message translates to:
  /// **'Serum Drawer'**
  String get cabin_serumDrawerName;

  /// Header name for kubik-type drawers in the master drawer panel
  ///
  /// In en, this message translates to:
  /// **'Cubic Drawer'**
  String get cabin_kubikDrawerName;

  /// Header name for unit-dose drawers in the master drawer panel
  ///
  /// In en, this message translates to:
  /// **'Unit Dose Drawer'**
  String get cabin_unitDoseDrawerName;

  /// Sub-label shown below the serum drawer header in the master panel
  ///
  /// In en, this message translates to:
  /// **'Rack view'**
  String get cabin_serumRackView;

  /// Placeholder title inside the serum drawer content area (not yet implemented)
  ///
  /// In en, this message translates to:
  /// **'Serum view'**
  String get cabin_serumViewTitle;

  /// Placeholder note inside the serum drawer content area shown until implementation is complete
  ///
  /// In en, this message translates to:
  /// **'TODO: Will be completed when serum internal structure is finalized'**
  String get cabin_serumViewTodo;

  /// Button label to open the cabin on the cabin action bar
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get cabin_openButton;

  /// Button label to enter drug-assignment mode from the cabin action bar
  ///
  /// In en, this message translates to:
  /// **'Assign Drug'**
  String get cabin_assignDrugButton;

  /// Info banner shown at the top of the drawer panel when in patient-assignment mode
  ///
  /// In en, this message translates to:
  /// **'Patient Assignment — assign a patient / admission to cells.'**
  String get cabin_bannerPatientAssign;

  /// Info banner shown at the top of the drawer panel when in drug-assignment mode
  ///
  /// In en, this message translates to:
  /// **'Drug Assignment — assign drugs to cells, set min/max/critical values.'**
  String get cabin_bannerDrugAssign;

  /// Info banner shown at the top of the drawer panel when in drug-fill mode
  ///
  /// In en, this message translates to:
  /// **'Drug Filling — tap the cell to fill, enter the quantity.'**
  String get cabin_bannerDrugFill;

  /// Info banner shown at the top of the drawer panel when in drug-count mode
  ///
  /// In en, this message translates to:
  /// **'Stock Count — enter the actual quantity, the system will calculate the difference.'**
  String get cabin_bannerDrugCount;

  /// Info banner shown at the top of the drawer panel when in fault-reporting mode
  ///
  /// In en, this message translates to:
  /// **'Fault — mark the faulty cell and enter a description.'**
  String get cabin_bannerFault;

  /// CabinWorkingStatus display label for a normally working cabin/cell
  ///
  /// In en, this message translates to:
  /// **'Operational'**
  String get cabin_statusWorking;

  /// CabinWorkingStatus display label for a cabin/cell with an active fault record
  ///
  /// In en, this message translates to:
  /// **'Fault Record'**
  String get cabin_statusFaultRecord;

  /// CabinWorkingStatus display label for a cabin/cell in maintenance
  ///
  /// In en, this message translates to:
  /// **'Maintenance Record'**
  String get cabin_statusMaintenanceRecord;

  /// Display name for CabinOperationMode.assign
  ///
  /// In en, this message translates to:
  /// **'Drug Assignment'**
  String get cabin_modeAssignLabel;

  /// Display name for CabinOperationMode.fill
  ///
  /// In en, this message translates to:
  /// **'Drug Filling'**
  String get cabin_modeFillLabel;

  /// Display name for CabinOperationMode.count
  ///
  /// In en, this message translates to:
  /// **'Drug Count'**
  String get cabin_modeCountLabel;

  /// Display name for CabinOperationMode.fault
  ///
  /// In en, this message translates to:
  /// **'Drawer Fault'**
  String get cabin_modeFaultLabel;

  /// Header title in the right operation panel when in drug-assignment mode
  ///
  /// In en, this message translates to:
  /// **'DRUG ASSIGNMENT'**
  String get cabin_operationPanelAssign;

  /// Header title in the right operation panel when in drug-fill mode
  ///
  /// In en, this message translates to:
  /// **'DRUG FILLING'**
  String get cabin_operationPanelFill;

  /// Header title in the right operation panel when in drug-count mode
  ///
  /// In en, this message translates to:
  /// **'DRUG COUNT'**
  String get cabin_operationPanelCount;

  /// Header title in the right operation panel when in fault-reporting mode
  ///
  /// In en, this message translates to:
  /// **'REPORT FAULT'**
  String get cabin_operationPanelFault;

  /// Legend item label for empty cells in drug-assignment mode
  ///
  /// In en, this message translates to:
  /// **'Empty cell (assign)'**
  String get cabin_legendAssignEmpty;

  /// Legend item label for drug-assigned cells in drug-assignment mode
  ///
  /// In en, this message translates to:
  /// **'Drug assigned'**
  String get cabin_legendAssignAssigned;

  /// Legend item label for faulty cells in assignment mode
  ///
  /// In en, this message translates to:
  /// **'Faulty'**
  String get cabin_legendAssignFault;

  /// Legend item label for cells under maintenance in assignment mode
  ///
  /// In en, this message translates to:
  /// **'Under maintenance'**
  String get cabin_legendAssignMaintenance;

  /// Legend item label for cells with a patient assignment in patient-assignment mode
  ///
  /// In en, this message translates to:
  /// **'Patient assigned'**
  String get cabin_legendPatientAssigned;

  /// Legend item label for filled cells in non-assignment modes
  ///
  /// In en, this message translates to:
  /// **'Filled'**
  String get cabin_legendFilled;

  /// Legend item label for empty (no fill needed) cells in drug-fill mode
  ///
  /// In en, this message translates to:
  /// **'Empty (no fill needed)'**
  String get cabin_legendFillEmpty;

  /// Legend item label for cells to be counted in drug-count mode
  ///
  /// In en, this message translates to:
  /// **'To count (has drug)'**
  String get cabin_legendCountAssigned;

  /// Legend item label for cells with low stock in drug-count mode
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get cabin_legendCountLow;

  /// Legend item label for empty cells to skip in drug-count mode
  ///
  /// In en, this message translates to:
  /// **'Empty (skip)'**
  String get cabin_legendCountEmpty;

  /// Legend item label for normally operating cells in fault mode
  ///
  /// In en, this message translates to:
  /// **'Operating normally'**
  String get cabin_legendFaultNormal;

  /// Legend item label for cells with a reported fault in fault mode
  ///
  /// In en, this message translates to:
  /// **'Fault reported'**
  String get cabin_legendFaultReported;

  /// Legend item label for empty cells in fault mode
  ///
  /// In en, this message translates to:
  /// **'Empty cell'**
  String get cabin_legendFaultEmpty;

  /// Title shown at the top of the setup wizard sidebar
  ///
  /// In en, this message translates to:
  /// **'Cabinet Setup'**
  String get wizard_sidebarTitle;

  /// Subtitle shown below the title in the setup wizard sidebar
  ///
  /// In en, this message translates to:
  /// **'New device configuration'**
  String get wizard_sidebarSubtitle;

  /// Step 1 title in the wizard sidebar step list
  ///
  /// In en, this message translates to:
  /// **'Cabinet Type'**
  String get wizard_step1SidebarTitle;

  /// Step 1 description in the wizard sidebar step list
  ///
  /// In en, this message translates to:
  /// **'Standard or Mobile'**
  String get wizard_step1SidebarDesc;

  /// Step 2 title in the wizard sidebar step list
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get wizard_step2SidebarTitle;

  /// Step 2 description in the wizard sidebar step list
  ///
  /// In en, this message translates to:
  /// **'Name, location, connection'**
  String get wizard_step2SidebarDesc;

  /// Step 3 title in the wizard sidebar step list
  ///
  /// In en, this message translates to:
  /// **'Service Scope'**
  String get wizard_step3SidebarTitle;

  /// Step 3 description in the wizard sidebar step list
  ///
  /// In en, this message translates to:
  /// **'Ward or room definitions'**
  String get wizard_step3SidebarDesc;

  /// Step 4 title in the wizard sidebar step list
  ///
  /// In en, this message translates to:
  /// **'Drawer Structure'**
  String get wizard_step4SidebarTitle;

  /// Step 4 description in the wizard sidebar step list
  ///
  /// In en, this message translates to:
  /// **'Scan or manual entry'**
  String get wizard_step4SidebarDesc;

  /// Step 5 title in the wizard sidebar step list
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get wizard_step5SidebarTitle;

  /// Step 5 description in the wizard sidebar step list
  ///
  /// In en, this message translates to:
  /// **'Review and complete'**
  String get wizard_step5SidebarDesc;

  /// Step 1 header title shown at the top of the cabin-type selection step
  ///
  /// In en, this message translates to:
  /// **'Select Cabinet Type'**
  String get wizard_step1Header;

  /// Step 1 header subtitle describing the purpose of the cabin-type selection step
  ///
  /// In en, this message translates to:
  /// **'Specify the type of cabinet you want to manage. This choice will shape the subsequent steps.'**
  String get wizard_step1Subtitle;

  /// Footer note on step 1 warning that the cabin type cannot be changed after completion
  ///
  /// In en, this message translates to:
  /// **'Cabinet type cannot be changed later.'**
  String get wizard_cabinTypeNote;

  /// First spec pill label on the standard (master) cabin type card
  ///
  /// In en, this message translates to:
  /// **'Cubic / Unit Dose'**
  String get wizard_masterCabinSpec1;

  /// Second spec pill label on the standard cabin type card
  ///
  /// In en, this message translates to:
  /// **'Ward-Based'**
  String get wizard_masterCabinSpec2;

  /// Description text on the standard (master) cabin type card on step 1
  ///
  /// In en, this message translates to:
  /// **'Wall-mounted or freestanding cabinet with a combination of cubic and unit-dose drawers.'**
  String get wizard_masterCabinDescription;

  /// First spec pill label on the mobile cabin type card
  ///
  /// In en, this message translates to:
  /// **'On Wheels'**
  String get wizard_mobileCabinSpec1;

  /// Second spec pill label on the mobile cabin type card
  ///
  /// In en, this message translates to:
  /// **'Room-Based'**
  String get wizard_mobileCabinSpec2;

  /// Description text on the mobile cabin type card on step 1
  ///
  /// In en, this message translates to:
  /// **'Wheeled, portable 4-row medication unit designed for ward rounds.'**
  String get wizard_mobileCabinDescription;

  /// Step 2 header title for basic cabin info (name, location, connection)
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get wizard_step2Header;

  /// Step 2 header subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter the cabinet name, location, and device connection settings.'**
  String get wizard_step2Subtitle;

  /// Label for the cabin name text field on step 2
  ///
  /// In en, this message translates to:
  /// **'Cabinet Name'**
  String get wizard_cabinNameLabel;

  /// Hint text for the cabin name text field on step 2
  ///
  /// In en, this message translates to:
  /// **'e.g. CB-304'**
  String get wizard_cabinNameHint;

  /// Section label for the connection settings group on step 2
  ///
  /// In en, this message translates to:
  /// **'CONNECTION SETTINGS'**
  String get wizard_connectionSettingsLabel;

  /// Warning text shown on step 2 when no active COM port is detected
  ///
  /// In en, this message translates to:
  /// **'No active COM Port found. Make sure the drivers are installed.'**
  String get wizard_noComPortWarning;

  /// Section label for the antenna/RFID settings group on step 2
  ///
  /// In en, this message translates to:
  /// **'ANTENNA SETTINGS'**
  String get wizard_antennaSettingsLabel;

  /// Label for the IP address input field on step 2
  ///
  /// In en, this message translates to:
  /// **'IP Address'**
  String get wizard_ipAddressLabel;

  /// Button to test the cabin card serial connection on step 2
  ///
  /// In en, this message translates to:
  /// **'Test Connection'**
  String get wizard_testConnectionButton;

  /// Step 3 header title for service/station scope selection
  ///
  /// In en, this message translates to:
  /// **'Service Scope'**
  String get wizard_step3Header;

  /// Step 3 header subtitle
  ///
  /// In en, this message translates to:
  /// **'Ward or room definitions.'**
  String get wizard_step3Subtitle;

  /// Section label for the room and bed selection area on step 3 for mobile cabins
  ///
  /// In en, this message translates to:
  /// **'ROOM & BED SELECTION'**
  String get wizard_roomBedSelectionLabel;

  /// Title of the idle scan state on step 4
  ///
  /// In en, this message translates to:
  /// **'Scan Device'**
  String get wizard_scanTitle;

  /// Description text shown in the idle scan state on step 4
  ///
  /// In en, this message translates to:
  /// **'The drawer structure of the connected cabinet will be read automatically via the serial port.'**
  String get wizard_scanDescription;

  /// Button to start the cabinet hardware scan on step 4
  ///
  /// In en, this message translates to:
  /// **'Start Scan'**
  String get wizard_startScanButton;

  /// Header text shown while the cabinet hardware scan is in progress
  ///
  /// In en, this message translates to:
  /// **'Scanning Cabinet..'**
  String get wizard_scanningStatus;

  /// Success banner title shown after a successful hardware scan on step 4
  ///
  /// In en, this message translates to:
  /// **'Scan Successful — {count} drawers found'**
  String wizard_scanSuccessBanner(int count);

  /// Description text in the scan success banner on step 4
  ///
  /// In en, this message translates to:
  /// **'The cabinet\'s internal layout was read from the device successfully. Confirm the structure below.'**
  String get wizard_scanSuccessDescription;

  /// Hint text at the bottom of the scan-found state telling the user to re-check connections if the result is wrong
  ///
  /// In en, this message translates to:
  /// **'If the structure is incorrect, go back and check the connection details.'**
  String get wizard_scanWrongStructure;

  /// Button to reset and re-run the hardware scan on step 4
  ///
  /// In en, this message translates to:
  /// **'Re-Scan'**
  String get wizard_rescanButton;

  /// Error banner message shown when the hardware scan fails on step 4
  ///
  /// In en, this message translates to:
  /// **'Scan failed. Check the COM port connection and try again.'**
  String get wizard_scanErrorBanner;

  /// Scan log entry message while connecting to the serial port
  ///
  /// In en, this message translates to:
  /// **'Connecting to serial port…'**
  String get wizard_scanLogConnecting;

  /// Scan log entry message while fetching drawer type metadata
  ///
  /// In en, this message translates to:
  /// **'Loading drawer definitions…'**
  String get wizard_scanLogFetchingMetadata;

  /// Scan log entry message while searching for the management card
  ///
  /// In en, this message translates to:
  /// **'Searching for management card…'**
  String get wizard_scanLogSearchingManager;

  /// Scan log entry message while scanning control cards
  ///
  /// In en, this message translates to:
  /// **'Scanning control cards…'**
  String get wizard_scanLogScanningCards;

  /// Scan log entry message when a drawer is found during the hardware scan
  ///
  /// In en, this message translates to:
  /// **'Drawer found'**
  String get wizard_scanLogDrawerFound;

  /// Label prefix for each scanned drawer row in the scan results list (1-based index)
  ///
  /// In en, this message translates to:
  /// **'DRAWER {index}'**
  String wizard_drawerLabel(int index);

  /// Cell count chip shown on scanned drawer rows for kubik drawers
  ///
  /// In en, this message translates to:
  /// **'{count} cells'**
  String wizard_cellCountLabel(int count);

  /// Row count chip shown on scanned drawer rows for unit-dose drawers
  ///
  /// In en, this message translates to:
  /// **'{count} rows'**
  String wizard_rowCountLabel(int count);

  /// Label for the drawer count input in the manual mobile cabinet configuration on step 4
  ///
  /// In en, this message translates to:
  /// **'Drawer Count'**
  String get wizard_drawerCountLabel;

  /// Button to add a row to the current drawer configuration in mobile manual setup
  ///
  /// In en, this message translates to:
  /// **'Add Row'**
  String get wizard_addRowButton;

  /// Button to remove the last row from the current drawer configuration in mobile manual setup
  ///
  /// In en, this message translates to:
  /// **'Remove Last Row'**
  String get wizard_removeLastRowButton;

  /// Step 5 header title for the summary and confirmation step
  ///
  /// In en, this message translates to:
  /// **'Summary & Complete'**
  String get wizard_step5Header;

  /// Step 5 header subtitle
  ///
  /// In en, this message translates to:
  /// **'Confirm the information you have entered. The setup will be completed after confirmation.'**
  String get wizard_step5Subtitle;

  /// Summary card title for the cabin basic information section on step 5
  ///
  /// In en, this message translates to:
  /// **'CABINET INFORMATION'**
  String get wizard_summaryCabinInfoTitle;

  /// Summary card title for the service scope section on step 5
  ///
  /// In en, this message translates to:
  /// **'SERVICE SCOPE'**
  String get wizard_summaryServiceScopeTitle;

  /// Summary card title for the drawer structure section on step 5
  ///
  /// In en, this message translates to:
  /// **'DRAWER STRUCTURE'**
  String get wizard_summaryDrawerStructureTitle;

  /// Summary card title for the cabin visual preview section on step 5
  ///
  /// In en, this message translates to:
  /// **'CABINET PREVIEW'**
  String get wizard_summaryCabinPreviewTitle;

  /// Row label for the cabin type in the cabin info summary card
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get wizard_summaryLabelType;

  /// Row label for the cabin name in the cabin info summary card
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get wizard_summaryLabelName;

  /// Row label for the station in the service scope summary card
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get wizard_summaryLabelStation;

  /// Row label for the room count in the service scope summary card (mobile cabin)
  ///
  /// In en, this message translates to:
  /// **'Room count'**
  String get wizard_summaryLabelRoomCount;

  /// Row label for the room names list in the service scope summary card (mobile cabin)
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get wizard_summaryLabelRooms;

  /// Row label for the bed names list in the service scope summary card (mobile cabin)
  ///
  /// In en, this message translates to:
  /// **'Beds'**
  String get wizard_summaryLabelBeds;

  /// Row label for the drawer count in the drawer structure summary card (mobile cabin)
  ///
  /// In en, this message translates to:
  /// **'Drawer count'**
  String get wizard_summaryLabelDrawerCount;

  /// Row label for the total drawer count in the drawer structure summary card (standard cabin)
  ///
  /// In en, this message translates to:
  /// **'Total drawers'**
  String get wizard_summaryLabelTotalDrawers;

  /// Row label for an individual drawer in the drawer structure summary card
  ///
  /// In en, this message translates to:
  /// **'Drawer {index}'**
  String wizard_summaryLabelDrawerIndexed(int index);

  /// Cabin type value in the summary card when the selected type is mobile
  ///
  /// In en, this message translates to:
  /// **'Mobile Cabinet'**
  String get wizard_summaryTypeMobile;

  /// Cabin type value in the summary card when the selected type is standard/master
  ///
  /// In en, this message translates to:
  /// **'Standard Cabinet'**
  String get wizard_summaryTypeStandard;

  /// Row label for the COM port value in the cabin info summary card
  ///
  /// In en, this message translates to:
  /// **'COM Port'**
  String get wizard_summaryLabelComPort;

  /// Row label for the DVR IP value in the cabin info summary card
  ///
  /// In en, this message translates to:
  /// **'DVR IP'**
  String get wizard_summaryLabelDvrIp;

  /// Row label for the RFID IP address value in the cabin info summary card
  ///
  /// In en, this message translates to:
  /// **'RFID Address'**
  String get wizard_summaryLabelRfidAddress;

  /// Row label for the RFID port value in the cabin info summary card
  ///
  /// In en, this message translates to:
  /// **'RFID Port'**
  String get wizard_summaryLabelRfidPort;

  /// Text shown below the loading spinner while the cabinet is being saved to the server
  ///
  /// In en, this message translates to:
  /// **'Saving cabinet…'**
  String get wizard_savingMessage;

  /// Title of the wizard success screen after the cabin is saved
  ///
  /// In en, this message translates to:
  /// **'Setup Complete!'**
  String get wizard_successTitle;

  /// Success message on the wizard completion screen
  ///
  /// In en, this message translates to:
  /// **'{cabinName} has been successfully added to the system.'**
  String wizard_successMessage(String cabinName);

  /// Cabin ID badge shown on the wizard success screen
  ///
  /// In en, this message translates to:
  /// **'Cabinet ID: #{id}'**
  String wizard_successCabinId(int id);

  /// Button on the wizard success screen to navigate to the dashboard
  ///
  /// In en, this message translates to:
  /// **'Go to Dashboard'**
  String get wizard_successDashboardButton;

  /// Title of the wizard error screen when cabin save fails
  ///
  /// In en, this message translates to:
  /// **'Save Failed'**
  String get wizard_errorTitle;

  /// Button on the wizard error screen to go back and retry
  ///
  /// In en, this message translates to:
  /// **'Go Back and Retry'**
  String get wizard_retryButton;

  /// Title label in the settings modal header
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// Section title for the system configuration area in the settings modal
  ///
  /// In en, this message translates to:
  /// **'SYSTEM CONFIGURATION'**
  String get settings_systemConfigTitle;

  /// Label for the appearance/theme section in the settings sidebar and modal
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settings_appearanceLabel;

  /// Label for the general section in the settings modal
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settings_generalLabel;

  /// Success snackbar/state message after a patient assignment is updated to a different hospitalization
  ///
  /// In en, this message translates to:
  /// **'Patient assignment updated successfully'**
  String get assignment_patientUpdatedSuccess;

  /// Placeholder description in the fault right panel before a mobile slot is selected
  ///
  /// In en, this message translates to:
  /// **'Select a drawer from the\nleft panel to report a fault.'**
  String get fault_selectSlotPlaceholder;

  /// Section label for bed selection dropdowns in right panel
  ///
  /// In en, this message translates to:
  /// **'Bed Selection'**
  String get assignment_bedSectionLabel;

  /// Hint text for service dropdown
  ///
  /// In en, this message translates to:
  /// **'Select a service'**
  String get assignment_serviceSelectorHint;

  /// Hint text for room dropdown
  ///
  /// In en, this message translates to:
  /// **'Select a room'**
  String get assignment_roomSelectorHint;

  /// Hint text for bed dropdown
  ///
  /// In en, this message translates to:
  /// **'Select a bed'**
  String get assignment_bedSelectorHint;

  /// Label for patient info row in bed card
  ///
  /// In en, this message translates to:
  /// **'PATIENT'**
  String get assignment_patientLabel;

  /// Settings > General section header for language selection
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get settings_languageTitle;

  /// Subtitle shown under language section header
  ///
  /// In en, this message translates to:
  /// **'Interface language'**
  String get settings_languageSubtitle;

  /// No description provided for @emptyStateCabinDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Cabinet data not found'**
  String get emptyStateCabinDataTitle;

  /// No description provided for @emptyStateCabinDataDescription.
  ///
  /// In en, this message translates to:
  /// **'The cabinet may not be configured yet\nor connection could not be established.'**
  String get emptyStateCabinDataDescription;

  /// No description provided for @emptyStateNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get emptyStateNoResultsTitle;

  /// No description provided for @emptyStateNoResultsDescription.
  ///
  /// In en, this message translates to:
  /// **'Try changing your search criteria.'**
  String get emptyStateNoResultsDescription;

  /// No description provided for @emptyStateNoCellSelectedTitle.
  ///
  /// In en, this message translates to:
  /// **'No cell selected'**
  String get emptyStateNoCellSelectedTitle;

  /// No description provided for @emptyStateNoCellSelectedDescription.
  ///
  /// In en, this message translates to:
  /// **'Select a cell to start filling.'**
  String get emptyStateNoCellSelectedDescription;

  /// No description provided for @emptyStateNoPatientTitle.
  ///
  /// In en, this message translates to:
  /// **'No patient assigned'**
  String get emptyStateNoPatientTitle;

  /// No description provided for @emptyStateNoPatientDescription.
  ///
  /// In en, this message translates to:
  /// **'No patient has been assigned to this cell yet.'**
  String get emptyStateNoPatientDescription;

  /// No description provided for @emptyStateNoPrescriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'No prescription found'**
  String get emptyStateNoPrescriptionTitle;

  /// No description provided for @emptyStateNoPrescriptionDescription.
  ///
  /// In en, this message translates to:
  /// **'There are no active prescriptions for this patient.'**
  String get emptyStateNoPrescriptionDescription;

  /// No description provided for @emptyStateNoCabinTitle.
  ///
  /// In en, this message translates to:
  /// **'No Cabinet Found'**
  String get emptyStateNoCabinTitle;

  /// No description provided for @emptyStateNoCabinDescription.
  ///
  /// In en, this message translates to:
  /// **'No cabinet has been defined yet. Please define a cabinet to continue.'**
  String get emptyStateNoCabinDescription;

  /// No description provided for @emptyStateNetworkErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get emptyStateNetworkErrorTitle;

  /// No description provided for @emptyStateNetworkErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'Please check your network connection and try again.'**
  String get emptyStateNetworkErrorDescription;

  /// No description provided for @emptyStateServerErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Server Unreachable'**
  String get emptyStateServerErrorTitle;

  /// No description provided for @emptyStateServerErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'The server could not be reached. Please try again later.'**
  String get emptyStateServerErrorDescription;

  /// No description provided for @emptyStateErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something Went Wrong'**
  String get emptyStateErrorTitle;

  /// No description provided for @emptyStateErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again or contact your system administrator.'**
  String get emptyStateErrorDescription;

  /// Message shown when the selected patient has no refundable medications.
  ///
  /// In en, this message translates to:
  /// **'No refundable medications found for this patient.'**
  String get refundNoRefundableDrugs;

  /// Empty state message shown in the right panel when no patient is selected.
  ///
  /// In en, this message translates to:
  /// **'Select a patient from the list on the left to start a refund.'**
  String get refundSelectPatient;
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
      <String>['ar', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
