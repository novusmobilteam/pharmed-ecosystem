import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
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
    Locale('fr'),
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

  /// Boolean true display value — used in tables and forms across the app
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get common_boolYes;

  /// Boolean false display value — used in tables and forms across the app
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get common_boolNo;

  /// Action button label — discharge patient from hospitalization
  ///
  /// In en, this message translates to:
  /// **'Discharge'**
  String get common_action_discharge;

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

  /// Section error shown in place of the upcoming treatments panel when its request fails
  ///
  /// In en, this message translates to:
  /// **'Upcoming treatments could not be loaded'**
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

  /// No description provided for @wizard_successReloginPrompt.
  ///
  /// In en, this message translates to:
  /// **'You must log in to continue.'**
  String get wizard_successReloginPrompt;

  /// No description provided for @wizard_successLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get wizard_successLoginButton;

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

  /// No description provided for @emptyStateNoDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get emptyStateNoDataTitle;

  /// No description provided for @emptyStateNoDataDescription.
  ///
  /// In en, this message translates to:
  /// **'There is no data to display yet.'**
  String get emptyStateNoDataDescription;

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

  /// No description provided for @wasteNoWastableDrugs.
  ///
  /// In en, this message translates to:
  /// **'No disposable drugs found.'**
  String get wasteNoWastableDrugs;

  /// No description provided for @wasteSelectPatient.
  ///
  /// In en, this message translates to:
  /// **'Select a patient to proceed.'**
  String get wasteSelectPatient;

  /// No description provided for @common_confirmCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_confirmCancelButton;

  /// No description provided for @common_dismissButton.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get common_dismissButton;

  /// No description provided for @common_action_saving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get common_action_saving;

  /// No description provided for @common_action_drawerOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening drawer'**
  String get common_action_drawerOpening;

  /// No description provided for @common_action_connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get common_action_connecting;

  /// No description provided for @common_action_processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get common_action_processing;

  /// No description provided for @common_cancelInfo_drawerClose.
  ///
  /// In en, this message translates to:
  /// **'To cancel the operation, close the drawer.'**
  String get common_cancelInfo_drawerClose;

  /// No description provided for @common_patientListTitle.
  ///
  /// In en, this message translates to:
  /// **'Patient List'**
  String get common_patientListTitle;

  /// No description provided for @common_patientCountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Total {count} patients'**
  String common_patientCountSubtitle(int count);

  /// No description provided for @assignment_error_stationLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load cabin station information'**
  String get assignment_error_stationLoadFailed;

  /// No description provided for @cabinStock_panel_title.
  ///
  /// In en, this message translates to:
  /// **'Medications in Cabin Assigned to Patient'**
  String get cabinStock_panel_title;

  /// No description provided for @census_cancelDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Cancel Census'**
  String get census_cancelDialog_title;

  /// No description provided for @census_cancelDialog_message.
  ///
  /// In en, this message translates to:
  /// **'Cancel the census operation?'**
  String get census_cancelDialog_message;

  /// No description provided for @census_action_start.
  ///
  /// In en, this message translates to:
  /// **'Start Census'**
  String get census_action_start;

  /// No description provided for @census_action_drawerOpen.
  ///
  /// In en, this message translates to:
  /// **'Count medications'**
  String get census_action_drawerOpen;

  /// No description provided for @census_action_complete.
  ///
  /// In en, this message translates to:
  /// **'Complete census'**
  String get census_action_complete;

  /// No description provided for @census_action_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue census'**
  String get census_action_continue;

  /// No description provided for @census_success_completed.
  ///
  /// In en, this message translates to:
  /// **'Census completed successfully.'**
  String get census_success_completed;

  /// No description provided for @drugActivity_column_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get drugActivity_column_date;

  /// No description provided for @drugActivity_column_time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get drugActivity_column_time;

  /// No description provided for @drugActivity_column_patient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get drugActivity_column_patient;

  /// No description provided for @drugActivity_column_user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get drugActivity_column_user;

  /// No description provided for @drugActivity_column_material.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get drugActivity_column_material;

  /// No description provided for @drugActivity_column_quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get drugActivity_column_quantity;

  /// No description provided for @drugActivity_column_movement.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get drugActivity_column_movement;

  /// No description provided for @intake_cancelDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Cancel Intake'**
  String get intake_cancelDialog_title;

  /// No description provided for @intake_cancelDialog_message.
  ///
  /// In en, this message translates to:
  /// **'No medication taken yet. Cancel the intake?'**
  String get intake_cancelDialog_message;

  /// No description provided for @intake_action_start.
  ///
  /// In en, this message translates to:
  /// **'Start intake'**
  String get intake_action_start;

  /// No description provided for @intake_action_drawerOpen.
  ///
  /// In en, this message translates to:
  /// **'Take medications'**
  String get intake_action_drawerOpen;

  /// No description provided for @intake_action_complete.
  ///
  /// In en, this message translates to:
  /// **'Complete intake'**
  String get intake_action_complete;

  /// No description provided for @intake_action_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue intake'**
  String get intake_action_continue;

  /// No description provided for @intake_success_completed.
  ///
  /// In en, this message translates to:
  /// **'Intake completed successfully.'**
  String get intake_success_completed;

  /// No description provided for @intake_action_reportMissingStock.
  ///
  /// In en, this message translates to:
  /// **'Report Missing Stock'**
  String get intake_action_reportMissingStock;

  /// No description provided for @myPatients_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search patient, room, service...'**
  String get myPatients_search_hint;

  /// No description provided for @refill_cancelDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Cancel Refill'**
  String get refill_cancelDialog_title;

  /// No description provided for @refill_cancelDialog_message.
  ///
  /// In en, this message translates to:
  /// **'Medications will be assumed removed from the drawer. Cancel the refill?'**
  String get refill_cancelDialog_message;

  /// No description provided for @refill_action_start.
  ///
  /// In en, this message translates to:
  /// **'Start refill'**
  String get refill_action_start;

  /// No description provided for @refill_action_placeDrugs.
  ///
  /// In en, this message translates to:
  /// **'Place medications'**
  String get refill_action_placeDrugs;

  /// No description provided for @refill_action_complete.
  ///
  /// In en, this message translates to:
  /// **'Complete refill'**
  String get refill_action_complete;

  /// No description provided for @refill_action_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue refill'**
  String get refill_action_continue;

  /// No description provided for @refill_success_completedMobile.
  ///
  /// In en, this message translates to:
  /// **'Refill completed successfully.'**
  String get refill_success_completedMobile;

  /// Success message after queue finishes
  ///
  /// In en, this message translates to:
  /// **'Refill completed successfully'**
  String get refill_success_completedMaster;

  /// No description provided for @refill_hint_selectDrawer.
  ///
  /// In en, this message translates to:
  /// **'Select a drawer from the left panel to start refilling.'**
  String get refill_hint_selectDrawer;

  /// No description provided for @refill_hint_selectCell.
  ///
  /// In en, this message translates to:
  /// **'Select a cell from the drawer.'**
  String get refill_hint_selectCell;

  /// No description provided for @refill_hint_cellError.
  ///
  /// In en, this message translates to:
  /// **'Select a cell.'**
  String get refill_hint_cellError;

  /// Census/count input label
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get refill_label_countQty;

  /// Filling amount input label
  ///
  /// In en, this message translates to:
  /// **'Fill quantity'**
  String get refill_label_fillQty;

  /// Expiry (miad) date input label
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get refill_label_expiryDate;

  /// Phase 1 header — medicine selection screen title
  ///
  /// In en, this message translates to:
  /// **'Select medicines to refill'**
  String get refill_title_selectMedicines;

  /// Phase 2 header — automatic refill queue title
  ///
  /// In en, this message translates to:
  /// **'Auto refill'**
  String get refill_title_autoRefill;

  /// Number of selected cells in the selection header
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String refill_label_selectedCount(int count);

  /// How many cells a medicine is assigned to
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} cell} other{{count} cells}}'**
  String refill_label_cellCount(int count);

  /// Drawer job containing multiple distinct medicines
  ///
  /// In en, this message translates to:
  /// **'{count} medicines'**
  String refill_label_multiMedicine(int count);

  /// Label above the per-medicine cell chips
  ///
  /// In en, this message translates to:
  /// **'Cells to refill'**
  String get refill_label_targetCells;

  /// Queue progress indicator (completed/total drawers)
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} drawers'**
  String refill_label_queueProgress(int done, int total);

  /// Current stock quantity for a cell, in pieces
  ///
  /// In en, this message translates to:
  /// **'Current: {qty}'**
  String refill_label_current(String qty);

  /// Standard (non-cubic) drawer chip label by address
  ///
  /// In en, this message translates to:
  /// **'Drawer {address}'**
  String refill_chip_drawer(String address);

  /// Cubic drawer cell chip label
  ///
  /// In en, this message translates to:
  /// **'Drawer {address} - Cell {cell}'**
  String refill_chip_drawerCell(String address, String cell);

  /// Cubic drawer subtitle with cell count
  ///
  /// In en, this message translates to:
  /// **'Drawer {address} · {count, plural, one{{count} cell} other{{count} cells}}'**
  String refill_subtitle_kubikCells(String address, int count);

  /// Queue item completed status
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get refill_status_done;

  /// Queue item active/open status (short)
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get refill_status_open;

  /// Queue item pending status
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get refill_status_queued;

  /// Active form pill — drawer physically open
  ///
  /// In en, this message translates to:
  /// **'Drawer open'**
  String get refill_status_drawerOpen;

  /// Active form pill — drawer not yet open
  ///
  /// In en, this message translates to:
  /// **'Opening drawer'**
  String get refill_status_drawerOpening;

  /// Search field placeholder
  ///
  /// In en, this message translates to:
  /// **'Search medicine…'**
  String get refill_hint_searchMedicine;

  /// Empty list hint
  ///
  /// In en, this message translates to:
  /// **'No medicines assigned to this cabinet'**
  String get refill_hint_noMedicines;

  /// Selection footer info about queue behaviour
  ///
  /// In en, this message translates to:
  /// **'Selected drawers open one by one; the next opens once the current is closed.'**
  String get refill_hint_autoQueueOrder;

  /// Execution footer info
  ///
  /// In en, this message translates to:
  /// **'Saving will close the drawer and open the next one.'**
  String get refill_hint_confirmCloses;

  /// Phase 1 primary button
  ///
  /// In en, this message translates to:
  /// **'Start auto refill'**
  String get refill_action_startAuto;

  /// Phase 2 confirm button
  ///
  /// In en, this message translates to:
  /// **'Complete refill'**
  String get refill_action_completeFilling;

  /// Stop the auto-refill queue
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get refill_action_stop;

  /// No description provided for @refill_label_min.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get refill_label_min;

  /// No description provided for @refill_label_critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get refill_label_critical;

  /// No description provided for @refill_label_max.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get refill_label_max;

  /// No description provided for @refill_error_queueTitle.
  ///
  /// In en, this message translates to:
  /// **'Operation could not be completed'**
  String get refill_error_queueTitle;

  /// No description provided for @refill_error_queueMessage.
  ///
  /// In en, this message translates to:
  /// **'This drawer’s refill could not be saved. Please take back the medicines you placed.'**
  String get refill_error_queueMessage;

  /// No description provided for @refill_error_continueNext.
  ///
  /// In en, this message translates to:
  /// **'Next drawer'**
  String get refill_error_continueNext;

  /// No description provided for @refill_error_endProcess.
  ///
  /// In en, this message translates to:
  /// **'End process'**
  String get refill_error_endProcess;

  /// No description provided for @refill_status_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get refill_status_failed;

  /// No description provided for @refill_label_cellProgress.
  ///
  /// In en, this message translates to:
  /// **'Cell {current}/{total}'**
  String refill_label_cellProgress(int current, int total);

  /// No description provided for @refill_label_cellNo.
  ///
  /// In en, this message translates to:
  /// **'Cell {no}'**
  String refill_label_cellNo(int no);

  /// No description provided for @refill_action_nextCell.
  ///
  /// In en, this message translates to:
  /// **'Next cell'**
  String get refill_action_nextCell;

  /// No description provided for @refill_hint_nextCellOpens.
  ///
  /// In en, this message translates to:
  /// **'Saving closes this cell and opens the next one.'**
  String get refill_hint_nextCellOpens;

  /// No description provided for @refill_hint_selectionLocked.
  ///
  /// In en, this message translates to:
  /// **'Refill in progress — selection locked.'**
  String get refill_hint_selectionLocked;

  /// No description provided for @refill_hint_idleExecution.
  ///
  /// In en, this message translates to:
  /// **'Select medicines on the left to start refilling.'**
  String get refill_hint_idleExecution;

  /// No description provided for @refund_success_title.
  ///
  /// In en, this message translates to:
  /// **'Refund successful'**
  String get refund_success_title;

  /// No description provided for @refund_success_message.
  ///
  /// In en, this message translates to:
  /// **'Please deliver the refunded medication to the pharmacist.'**
  String get refund_success_message;

  /// No description provided for @refund_panel_title.
  ///
  /// In en, this message translates to:
  /// **'Refundable Medications'**
  String get refund_panel_title;

  /// No description provided for @refund_action_checking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get refund_action_checking;

  /// No description provided for @refund_action_refunding.
  ///
  /// In en, this message translates to:
  /// **'Refunding...'**
  String get refund_action_refunding;

  /// No description provided for @refund_action_refund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get refund_action_refund;

  /// No description provided for @unappliedPrescription_panel_patientTitle.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get unappliedPrescription_panel_patientTitle;

  /// No description provided for @unload_cancelDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Cancel Unload'**
  String get unload_cancelDialog_title;

  /// No description provided for @unload_cancelDialog_message.
  ///
  /// In en, this message translates to:
  /// **'No medication removed yet. Cancel the unload?'**
  String get unload_cancelDialog_message;

  /// Button to start the master cabin unload queue after selecting medicines
  ///
  /// In en, this message translates to:
  /// **'Start Unloading'**
  String get unload_action_start;

  /// No description provided for @unload_action_drawerOpen.
  ///
  /// In en, this message translates to:
  /// **'Remove medications'**
  String get unload_action_drawerOpen;

  /// No description provided for @unload_action_complete.
  ///
  /// In en, this message translates to:
  /// **'Complete unload'**
  String get unload_action_complete;

  /// No description provided for @unload_action_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue unload'**
  String get unload_action_continue;

  /// No description provided for @unload_success_completed.
  ///
  /// In en, this message translates to:
  /// **'Unload completed successfully.'**
  String get unload_success_completed;

  /// No description provided for @waste_panel_title.
  ///
  /// In en, this message translates to:
  /// **'Wasteable/Destructible Medications'**
  String get waste_panel_title;

  /// Master waste/destruction screen — segment label and submit button text for the wastage (fire) mode
  ///
  /// In en, this message translates to:
  /// **'Wastage'**
  String get waste_action_wastage;

  /// Master waste/destruction screen — segment label and submit button text for the destruction mode
  ///
  /// In en, this message translates to:
  /// **'Destruction'**
  String get waste_action_destruction;

  /// No description provided for @wastage_success_title.
  ///
  /// In en, this message translates to:
  /// **'Wastage recorded'**
  String get wastage_success_title;

  /// No description provided for @wastage_success_message.
  ///
  /// In en, this message translates to:
  /// **'Please place the wasted medication in the wastage bin.'**
  String get wastage_success_message;

  /// No description provided for @destruction_success_title.
  ///
  /// In en, this message translates to:
  /// **'Destruction recorded'**
  String get destruction_success_title;

  /// No description provided for @destruction_success_message.
  ///
  /// In en, this message translates to:
  /// **'Please dispose of the medication in accordance with the destruction procedure.'**
  String get destruction_success_message;

  /// No description provided for @assignment_success_created.
  ///
  /// In en, this message translates to:
  /// **'Bed assignment saved successfully.'**
  String get assignment_success_created;

  /// No description provided for @assignment_success_deleted.
  ///
  /// In en, this message translates to:
  /// **'Bed assignment removed.'**
  String get assignment_success_deleted;

  /// No description provided for @cabin_bannerCensus.
  ///
  /// In en, this message translates to:
  /// **'After the drawer opens, select the medications in the cabinet and complete the count. Medications with status \"Pending Intake\" can be counted; unselected medications are assumed to have a quantity of 0.'**
  String get cabin_bannerCensus;

  /// No description provided for @cabin_bannerIntake.
  ///
  /// In en, this message translates to:
  /// **'Drug Intake'**
  String get cabin_bannerIntake;

  /// No description provided for @cabin_bannerUnload.
  ///
  /// In en, this message translates to:
  /// **'Drug Unload'**
  String get cabin_bannerUnload;

  /// No description provided for @operationPanel_title_assign.
  ///
  /// In en, this message translates to:
  /// **'DRUG ASSIGNMENT'**
  String get operationPanel_title_assign;

  /// No description provided for @operationPanel_badge_assign.
  ///
  /// In en, this message translates to:
  /// **'ASSIGN'**
  String get operationPanel_badge_assign;

  /// No description provided for @operationPanel_title_refill.
  ///
  /// In en, this message translates to:
  /// **'DRUG REFILL'**
  String get operationPanel_title_refill;

  /// No description provided for @operationPanel_badge_refill.
  ///
  /// In en, this message translates to:
  /// **'REFILL'**
  String get operationPanel_badge_refill;

  /// No description provided for @operationPanel_title_census.
  ///
  /// In en, this message translates to:
  /// **'DRUG COUNT'**
  String get operationPanel_title_census;

  /// No description provided for @operationPanel_badge_census.
  ///
  /// In en, this message translates to:
  /// **'COUNT'**
  String get operationPanel_badge_census;

  /// No description provided for @operationPanel_title_fault.
  ///
  /// In en, this message translates to:
  /// **'REPORT FAULT'**
  String get operationPanel_title_fault;

  /// No description provided for @operationPanel_badge_fault.
  ///
  /// In en, this message translates to:
  /// **'FAULT'**
  String get operationPanel_badge_fault;

  /// No description provided for @operationPanel_title_intake.
  ///
  /// In en, this message translates to:
  /// **'DRUG INTAKE'**
  String get operationPanel_title_intake;

  /// No description provided for @operationPanel_badge_intake.
  ///
  /// In en, this message translates to:
  /// **'INTAKE'**
  String get operationPanel_badge_intake;

  /// No description provided for @operationPanel_title_unload.
  ///
  /// In en, this message translates to:
  /// **'DRUG UNLOAD'**
  String get operationPanel_title_unload;

  /// No description provided for @operationPanel_badge_unload.
  ///
  /// In en, this message translates to:
  /// **'UNLOAD'**
  String get operationPanel_badge_unload;

  /// No description provided for @drugAssignment_panel_title.
  ///
  /// In en, this message translates to:
  /// **'Select Drug'**
  String get drugAssignment_panel_title;

  /// No description provided for @session_timeout_warning.
  ///
  /// In en, this message translates to:
  /// **'Your session is about to expire.'**
  String get session_timeout_warning;

  /// No description provided for @session_timeout_continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get session_timeout_continueButton;

  /// No description provided for @session_timeout_prefix.
  ///
  /// In en, this message translates to:
  /// **'Your session will close in '**
  String get session_timeout_prefix;

  /// No description provided for @session_timeout_suffix.
  ///
  /// In en, this message translates to:
  /// **' seconds.'**
  String get session_timeout_suffix;

  /// No description provided for @session_locked_prefix.
  ///
  /// In en, this message translates to:
  /// **'Your session '**
  String get session_locked_prefix;

  /// No description provided for @session_locked_reason.
  ///
  /// In en, this message translates to:
  /// **'timed out'**
  String get session_locked_reason;

  /// No description provided for @session_locked_suffix.
  ///
  /// In en, this message translates to:
  /// **' and was closed. Please log in to continue.'**
  String get session_locked_suffix;

  /// No description provided for @movement_noHistory.
  ///
  /// In en, this message translates to:
  /// **'No movement history found.'**
  String get movement_noHistory;

  /// No description provided for @movement_performedBy.
  ///
  /// In en, this message translates to:
  /// **'Performed by'**
  String get movement_performedBy;

  /// No description provided for @common_search_noPatientResults.
  ///
  /// In en, this message translates to:
  /// **'No patients match your search.'**
  String get common_search_noPatientResults;

  /// No description provided for @common_drug_noFilterResults.
  ///
  /// In en, this message translates to:
  /// **'No medications match this filter.'**
  String get common_drug_noFilterResults;

  /// No description provided for @common_unknownName.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get common_unknownName;

  /// No description provided for @rfidStatus_read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get rfidStatus_read;

  /// No description provided for @rfidStatus_waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get rfidStatus_waiting;

  /// No description provided for @rfidStatus_inCabin.
  ///
  /// In en, this message translates to:
  /// **'In cabinet'**
  String get rfidStatus_inCabin;

  /// No description provided for @rfidStatus_notInCabin.
  ///
  /// In en, this message translates to:
  /// **'Not in cabinet'**
  String get rfidStatus_notInCabin;

  /// No description provided for @rfidStatus_taken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get rfidStatus_taken;

  /// No description provided for @rfidStatus_missing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get rfidStatus_missing;

  /// No description provided for @drawerStatus_full.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get drawerStatus_full;

  /// No description provided for @drawerStatus_low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get drawerStatus_low;

  /// No description provided for @drawerStatus_critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get drawerStatus_critical;

  /// No description provided for @drawerStatus_empty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get drawerStatus_empty;

  /// No description provided for @cabin_cellCount.
  ///
  /// In en, this message translates to:
  /// **'{count} cells'**
  String cabin_cellCount(Object count);

  /// No description provided for @cabin_drawerStats.
  ///
  /// In en, this message translates to:
  /// **'{rowCount} rows · {totalCells} cells · {columns} columns'**
  String cabin_drawerStats(Object columns, Object rowCount, Object totalCells);

  /// No description provided for @hospitalization_admissionDate.
  ///
  /// In en, this message translates to:
  /// **'Admission Date | {date}'**
  String hospitalization_admissionDate(Object date);

  /// No description provided for @movement_dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get movement_dateLabel;

  /// No description provided for @movement_quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get movement_quantityLabel;

  /// No description provided for @movement_showAll.
  ///
  /// In en, this message translates to:
  /// **'Show All Movements'**
  String get movement_showAll;

  /// No description provided for @cabin_masterDrawerStats.
  ///
  /// In en, this message translates to:
  /// **'{groupCount} groups · {steps} steps × {mult}'**
  String cabin_masterDrawerStats(Object groupCount, Object mult, Object steps);

  /// No description provided for @dashboard_cabinConnectionStatus_connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get dashboard_cabinConnectionStatus_connected;

  /// No description provided for @dashboard_cabinConnectionStatus_connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get dashboard_cabinConnectionStatus_connecting;

  /// No description provided for @dashboard_cabinConnectionStatus_error.
  ///
  /// In en, this message translates to:
  /// **'No Connection'**
  String get dashboard_cabinConnectionStatus_error;

  /// No description provided for @dashboard_cabinConnectionStatus_disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get dashboard_cabinConnectionStatus_disconnected;

  /// No description provided for @dashboard_cabinConnection_reconnectButton.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get dashboard_cabinConnection_reconnectButton;

  /// No description provided for @prescription_noPatients_title.
  ///
  /// In en, this message translates to:
  /// **'No Assigned Patients'**
  String get prescription_noPatients_title;

  /// No description provided for @prescription_noPatients_message.
  ///
  /// In en, this message translates to:
  /// **'No patients have been assigned to this cabinet yet. Patients must be assigned before prescriptions can be reviewed.'**
  String get prescription_noPatients_message;

  /// No description provided for @myPatients_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No Patients Selected Yet'**
  String get myPatients_empty_title;

  /// No description provided for @myPatients_empty_description.
  ///
  /// In en, this message translates to:
  /// **'Select patients from the list on the left to add them to your patient list. Your selected patients will appear here.'**
  String get myPatients_empty_description;

  /// No description provided for @cabin_stock_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No stock for this patient'**
  String get cabin_stock_empty_title;

  /// No description provided for @cabin_stock_empty_description.
  ///
  /// In en, this message translates to:
  /// **'This patient has no medications stocked in this cabin yet.'**
  String get cabin_stock_empty_description;

  /// No description provided for @unadministered_prescriptions_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No pending prescriptions'**
  String get unadministered_prescriptions_empty_title;

  /// No description provided for @unadministered_prescriptions_empty_description.
  ///
  /// In en, this message translates to:
  /// **'There are no prescriptions waiting to be administered for this patient.'**
  String get unadministered_prescriptions_empty_description;

  /// No description provided for @empty_state_no_patient_selected_title.
  ///
  /// In en, this message translates to:
  /// **'Select a patient'**
  String get empty_state_no_patient_selected_title;

  /// No description provided for @empty_state_no_patient_selected_description.
  ///
  /// In en, this message translates to:
  /// **'Choose a patient from the list to view their details.'**
  String get empty_state_no_patient_selected_description;

  /// No description provided for @date_preset_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get date_preset_today;

  /// No description provided for @date_preset_tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get date_preset_tomorrow;

  /// No description provided for @date_preset_last_3_days.
  ///
  /// In en, this message translates to:
  /// **'Last 3 days'**
  String get date_preset_last_3_days;

  /// No description provided for @date_preset_last_7_days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get date_preset_last_7_days;

  /// No description provided for @date_preset_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get date_preset_all;

  /// No description provided for @filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filter_all;

  /// No description provided for @census_action_report_extra_stock.
  ///
  /// In en, this message translates to:
  /// **'Report Extra Stock'**
  String get census_action_report_extra_stock;

  /// No description provided for @census_extra_stock_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Report Extra Stock'**
  String get census_extra_stock_dialog_title;

  /// No description provided for @census_extra_stock_quantity_label.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get census_extra_stock_quantity_label;

  /// No description provided for @common_action_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get common_action_add;

  /// No description provided for @census_extra_stock_summary_title.
  ///
  /// In en, this message translates to:
  /// **'Reported Extra Stocks'**
  String get census_extra_stock_summary_title;

  /// Fallback label shown when the serial port connection has no active port name
  ///
  /// In en, this message translates to:
  /// **'Not Connected'**
  String get core_serialPortDisconnectedLabel;

  /// Live status line shown while attempting to connect to a serial port
  ///
  /// In en, this message translates to:
  /// **'Connecting to port: {portName}...'**
  String core_serialConnectingStatus(String portName);

  /// Live status line shown after a successful serial port connection
  ///
  /// In en, this message translates to:
  /// **'Connected successfully: {portName}'**
  String core_serialConnectSuccessStatus(String portName);

  /// Live status line shown when the default port fails and the service falls back to scanning other ports
  ///
  /// In en, this message translates to:
  /// **'{portName} failed. Scanning other ports...'**
  String core_serialPortFailedScanningOthersStatus(String portName);

  /// Error message shown when the default serial port fails and no fallback port is available
  ///
  /// In en, this message translates to:
  /// **'The default port ({portName}) failed and no other port was found.'**
  String core_serialNoOtherPortsError(String portName);

  /// Live status line shown while trying an individual serial port during the scan
  ///
  /// In en, this message translates to:
  /// **'Trying: {portName}...'**
  String core_serialTryingPortStatus(String portName);

  /// Live status line shown once a serial port connection has been established during the scan
  ///
  /// In en, this message translates to:
  /// **'Connection established: {portName}'**
  String core_serialConnectionEstablishedStatus(String portName);

  /// Error message shown when no serial port could be connected to after scanning all candidates
  ///
  /// In en, this message translates to:
  /// **'Could not connect to any port. Check the cables.'**
  String get core_serialNoPortConnectedError;

  /// Error message shown when a specific serial port fails to open
  ///
  /// In en, this message translates to:
  /// **'The port could not be opened ({portName}).'**
  String core_serialPortOpenFailedError(String portName);

  /// Error message shown when a serial command is attempted with no active connection
  ///
  /// In en, this message translates to:
  /// **'No connection.'**
  String get core_serialNoConnectionError;

  /// Error message shown when the serial port is locked/busy and times out waiting for access
  ///
  /// In en, this message translates to:
  /// **'Port timed out.'**
  String get core_serialPortBusyTimeoutError;

  /// Error message shown when writing to the serial port fails
  ///
  /// In en, this message translates to:
  /// **'Write failed.'**
  String get core_serialWriteFailedError;

  /// Fallback success message shown when an API operation succeeds without a specific message
  ///
  /// In en, this message translates to:
  /// **'Operation successful'**
  String get common_defaultSuccessMessage;

  /// Generic success message shown after create/update/delete operations across CRUD screens (shared across the app)
  ///
  /// In en, this message translates to:
  /// **'Your operation was completed successfully.'**
  String get common_operationSuccessMessage;

  /// Generic loading indicator text shown while a dialog/overlay is busy
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loadingEllipsis;

  /// Generic search field hint text used in dialogs and lists
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get common_searchHint;

  /// Tooltip on the generic search icon button
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get common_searchTooltip;

  /// Tooltip on the generic add icon button
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get common_addTooltip;

  /// Tooltip on the generic close icon button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_closeTooltip;

  /// Generic save button label used across forms and dialogs
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_saveButton;

  /// Generic edit tooltip/button label used across list/table action items
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_editTooltip;

  /// Generic delete tooltip/button label used across list/table action items
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_deleteTooltip;

  /// Generic status field/dropdown label used across CRUD forms
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get common_statusLabel;

  /// Generic empty-state description shown when a CRUD list has no items (non-dialog context)
  ///
  /// In en, this message translates to:
  /// **'The list is currently empty'**
  String get common_emptyListMessage;

  /// Generic entity-name field label used across CRUD forms (e.g. active ingredient, unit)
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get common_nameLabel;

  /// Validation error dialog message shown when required form fields are left empty
  ///
  /// In en, this message translates to:
  /// **'Please fill in the required fields.'**
  String get common_requiredFieldsError;

  /// Generic description field label/hint used across forms
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get common_descriptionLabel;

  /// Button label to deselect all selected items in a selectable list
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get common_deselectAllButton;

  /// Button label to select all items in a selectable list
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get common_selectAllButton;

  /// Fallback unit label shown when a medicine/material has no operation unit configured
  ///
  /// In en, this message translates to:
  /// **'Piece'**
  String get common_defaultUnitFallback;

  /// Badge/checkbox label for the 'first dose emergency' prescription item flag
  ///
  /// In en, this message translates to:
  /// **'First Dose Emergency'**
  String get common_flagFirstDoseEmergency;

  /// Badge/checkbox label for the 'ask doctor' prescription item flag
  ///
  /// In en, this message translates to:
  /// **'Ask Doctor'**
  String get common_flagAskDoctor;

  /// Badge/checkbox label for the 'in case of necessity' (PRN) prescription item flag
  ///
  /// In en, this message translates to:
  /// **'As Needed'**
  String get common_flagInCaseOfNecessity;

  /// Empty-state hint shown in selection dialogs, telling the user how to add a new item of the given type
  ///
  /// In en, this message translates to:
  /// **'Tap the \"+\" button to add a new {item}'**
  String common_addItemHint(String item);

  /// Generic fallback error message shown when an operation fails without a specific error
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get common_genericErrorMessage;

  /// Fallback text shown on the hospitalization card when the doctor's name is null
  ///
  /// In en, this message translates to:
  /// **'No Doctor Specified'**
  String get hospitalizationCard_noDoctorFallback;

  /// Footer info label for the patient's national ID number on the hospitalization card
  ///
  /// In en, this message translates to:
  /// **'National ID No.'**
  String get hospitalizationCard_nationalIdLabel;

  /// Footer info label for the admission date on the hospitalization card
  ///
  /// In en, this message translates to:
  /// **'Admission Date'**
  String get hospitalizationCard_admissionDateLabel;

  /// Header label above the category list in the menu browser
  ///
  /// In en, this message translates to:
  /// **'CATEGORIES'**
  String get menuBrowser_categoriesHeader;

  /// Search field hint text in the menu browser's category list
  ///
  /// In en, this message translates to:
  /// **'Search category...'**
  String get menuBrowser_searchHint;

  /// Badge showing how many items are selected out of the total in the current category
  ///
  /// In en, this message translates to:
  /// **'{selected}/{total}'**
  String menuBrowser_selectionCountBadge(int selected, int total);

  /// Empty-state message shown when a selected category has no menu items
  ///
  /// In en, this message translates to:
  /// **'No menu found in this category'**
  String get menuBrowser_emptyCategoryMessage;

  /// Header title for a prescription group card, showing the prescription ID
  ///
  /// In en, this message translates to:
  /// **'Prescription #{id}'**
  String rxGroup_headerTitle(Object id);

  /// Header subtitle for a prescription group card, showing the doctor name and prescription date
  ///
  /// In en, this message translates to:
  /// **'{doctorName} · {date}'**
  String rxGroup_headerSubtitle(String doctorName, String date);

  /// Badge showing the total number of items in a prescription group
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String rxGroup_itemCountBadge(int count);

  /// Label showing how many items in a prescription group can currently be acted on
  ///
  /// In en, this message translates to:
  /// **'{count} actionable items'**
  String rxGroup_selectableCountLabel(int count);

  /// Fallback text shown when a prescription's doctor name is null
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get rxGroup_unknownDoctorFallback;

  /// Section label for the RFID tag area of a prescription item row
  ///
  /// In en, this message translates to:
  /// **'RFID TAG'**
  String get rxGroup_rfidTagLabel;

  /// Loading-state label shown while an RFID tag is being read
  ///
  /// In en, this message translates to:
  /// **'Waiting for tag...'**
  String get rxGroup_rfidTagLoadingLabel;

  /// Label shown when a prescription item has no RFID tag assigned
  ///
  /// In en, this message translates to:
  /// **'No tag assigned yet'**
  String get rxGroup_rfidTagUnassignedLabel;

  /// Button label to change the RFID tag assigned to a prescription item
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get rxGroup_rfidChangeButton;

  /// Button label to assign an RFID tag to a prescription item
  ///
  /// In en, this message translates to:
  /// **'Assign Tag'**
  String get rxGroup_rfidAssignButton;

  /// Bottom action bar label showing how many prescription items are currently selected
  ///
  /// In en, this message translates to:
  /// **'{count} items selected'**
  String rxGroup_selectedCountBar(int count);

  /// Action chip label to approve selected prescription items
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get rxGroup_approveAction;

  /// Action chip label to reject selected prescription items
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rxGroup_rejectAction;

  /// Dialog title for the change-password screen
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword_dialogTitle;

  /// Field label for the current password input
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get changePassword_currentPasswordLabel;

  /// Field label for the new password input
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get changePassword_newPasswordLabel;

  /// Field label for the new password confirmation input
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get changePassword_confirmPasswordLabel;

  /// Submit button label on the change-password form
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword_submitButton;

  /// Small badge label shown in the manager app bar
  ///
  /// In en, this message translates to:
  /// **'MANAGEMENT PANEL'**
  String get home_appBarBadgeLabel;

  /// Tooltip on the developer settings icon, only visible in debug builds
  ///
  /// In en, this message translates to:
  /// **'Developer Settings'**
  String get home_devSettingsTooltip;

  /// Empty-state title shown when the logged-in user has no accessible menus
  ///
  /// In en, this message translates to:
  /// **'No Authorized Menu Found'**
  String get home_noAuthorizedMenuTitle;

  /// Empty-state description shown when the logged-in user has no accessible menus
  ///
  /// In en, this message translates to:
  /// **'Your account has no access permissions defined.\nPlease contact your system administrator to obtain access.'**
  String get home_noAuthorizedMenuDescription;

  /// Dialog title for the branch (medical specialty) list screen
  ///
  /// In en, this message translates to:
  /// **'Branch Definition'**
  String get branch_listDialogTitle;

  /// Dialog title when creating a new branch
  ///
  /// In en, this message translates to:
  /// **'Add Branch'**
  String get branch_addTitle;

  /// Dialog title when editing an existing branch
  ///
  /// In en, this message translates to:
  /// **'Edit Branch'**
  String get branch_editTitle;

  /// Field label for the branch name
  ///
  /// In en, this message translates to:
  /// **'Branch Name'**
  String get branch_nameLabel;

  /// Success message shown after creating a firm/supplier
  ///
  /// In en, this message translates to:
  /// **'Firm created successfully'**
  String get firm_createSuccessMessage;

  /// Success message shown after updating a firm/supplier
  ///
  /// In en, this message translates to:
  /// **'Firm updated successfully'**
  String get firm_updateSuccessMessage;

  /// Side panel title / toolbar button label when creating a new firm
  ///
  /// In en, this message translates to:
  /// **'New Firm'**
  String get firm_createPanelTitle;

  /// Side panel title when editing an existing firm
  ///
  /// In en, this message translates to:
  /// **'Edit Firm'**
  String get firm_editPanelTitle;

  /// Side panel subtitle when creating a new firm
  ///
  /// In en, this message translates to:
  /// **'Fill in the firm details'**
  String get firm_createPanelSubtitle;

  /// Side panel subtitle when editing an existing firm
  ///
  /// In en, this message translates to:
  /// **'Update the firm details'**
  String get firm_editPanelSubtitle;

  /// Field label for the firm name
  ///
  /// In en, this message translates to:
  /// **'Firm Name'**
  String get firm_nameLabel;

  /// Field label for the firm's tax number
  ///
  /// In en, this message translates to:
  /// **'Tax No.'**
  String get firm_taxNoLabel;

  /// Field label for the firm's tax office
  ///
  /// In en, this message translates to:
  /// **'Tax Office'**
  String get firm_taxOfficeLabel;

  /// Field label for the firm type
  ///
  /// In en, this message translates to:
  /// **'Firm Type'**
  String get firm_typeLabel;

  /// Fallback screen title when the menu name is not provided
  ///
  /// In en, this message translates to:
  /// **'Firm Definition'**
  String get firm_screenDefaultTitle;

  /// Success message shown after deleting a dosage form
  ///
  /// In en, this message translates to:
  /// **'The dosage form was deleted successfully.'**
  String get dosageForm_deleteSuccessMessage;

  /// Success message shown after creating or updating a dosage form
  ///
  /// In en, this message translates to:
  /// **'The dosage form was saved successfully.'**
  String get dosageForm_saveSuccessMessage;

  /// Dialog title when creating a new dosage form
  ///
  /// In en, this message translates to:
  /// **'Create Dosage Form'**
  String get dosageForm_createTitle;

  /// Dialog title when editing an existing dosage form
  ///
  /// In en, this message translates to:
  /// **'Edit Dosage Form'**
  String get dosageForm_editTitle;

  /// Dialog title for the dosage form list screen
  ///
  /// In en, this message translates to:
  /// **'Dosage Form'**
  String get dosageForm_listDialogTitle;

  /// Empty-state title for the dosage form list
  ///
  /// In en, this message translates to:
  /// **'No dosage forms yet'**
  String get dosageForm_emptyTitle;

  /// Empty-state description for the dosage form list, prompting the user to add one
  ///
  /// In en, this message translates to:
  /// **'Tap the \"+\" button to create a dosage form'**
  String get dosageForm_emptyDescription;

  /// Tab label / side panel title for user authorization
  ///
  /// In en, this message translates to:
  /// **'User Authorization'**
  String get authorization_userTabTitle;

  /// Tab label for role authorization
  ///
  /// In en, this message translates to:
  /// **'Role Authorization'**
  String get authorization_roleTabTitle;

  /// Fallback screen title when the menu name is not provided
  ///
  /// In en, this message translates to:
  /// **'User/Role Authorization'**
  String get authorization_screenTitleFallback;

  /// Panel title showing which role's permissions are being edited
  ///
  /// In en, this message translates to:
  /// **'Role Authorization - {roleName}'**
  String authorization_rolePanelTitle(String roleName);

  /// Sub-tab label for menu permissions within the role authorization panel
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get authorization_tabMenuLabel;

  /// Sub-tab label for drug permissions within the role authorization panel
  ///
  /// In en, this message translates to:
  /// **'Drug'**
  String get authorization_tabDrugLabel;

  /// Sub-tab label for medical consumable permissions within the role authorization panel
  ///
  /// In en, this message translates to:
  /// **'Medical Consumable'**
  String get authorization_tabConsumableLabel;

  /// Column header for the 'pull drug' permission in the role/drug authorization table
  ///
  /// In en, this message translates to:
  /// **'Pull Drug'**
  String get authorization_drugTable_pullColumn;

  /// Column header for the 'refill' permission in the role/drug authorization table
  ///
  /// In en, this message translates to:
  /// **'Refill'**
  String get authorization_drugTable_fillColumn;

  /// Column header for the 'return' permission in the role/drug authorization table
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get authorization_drugTable_returnColumn;

  /// Column header for the 'dispose' permission in the role/drug authorization table
  ///
  /// In en, this message translates to:
  /// **'Dispose'**
  String get authorization_drugTable_disposeColumn;

  /// Row label for the 'select all drugs' header row in the drug authorization table
  ///
  /// In en, this message translates to:
  /// **'All Drugs'**
  String get authorization_drugTable_allDrugsRow;

  /// Fallback text shown when a drug's name is null in the authorization table
  ///
  /// In en, this message translates to:
  /// **'Unknown Drug'**
  String get authorization_drugTable_unknownDrugFallback;

  /// Success message shown after saving application settings
  ///
  /// In en, this message translates to:
  /// **'Settings updated successfully.'**
  String get settings_updateSuccessMessage;

  /// Dropdown label for the drawer-open wait duration setting
  ///
  /// In en, this message translates to:
  /// **'Drawer Open Wait Time (seconds)'**
  String get settingsCabin_drawerOpenWaitLabel;

  /// Helper text explaining the drawer-open wait duration setting
  ///
  /// In en, this message translates to:
  /// **'Specifies when the system will send a close command to the drawer if it is left open.'**
  String get settingsCabin_drawerOpenWaitDescription;

  /// Switch label to toggle the admin dashboard feature
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard Active'**
  String get settingsDeveloper_adminDashboardActiveLabel;

  /// Section label for the developer app-mode toggle
  ///
  /// In en, this message translates to:
  /// **'Application Mode'**
  String get settingsDeveloper_appModeLabel;

  /// Mode toggle button label to switch the app into client mode
  ///
  /// In en, this message translates to:
  /// **'Client Mode'**
  String get settingsDeveloper_clientModeButton;

  /// Mode toggle button label to switch the app into manager mode
  ///
  /// In en, this message translates to:
  /// **'Manager Mode'**
  String get settingsDeveloper_managerModeButton;

  /// Dropdown label for the auto-standby duration setting
  ///
  /// In en, this message translates to:
  /// **'Auto-Standby Duration (seconds)'**
  String get settingsGeneral_autoStandbyDurationLabel;

  /// Text field label for the expiry warning threshold setting
  ///
  /// In en, this message translates to:
  /// **'Expiry Warning'**
  String get settingsGeneral_expiryWarningLabel;

  /// Checkbox label for enabling hospital information system stock control
  ///
  /// In en, this message translates to:
  /// **'HIS Stock Control'**
  String get settingsGeneral_hbysStockControlLabel;

  /// Checkbox label restricting cabinet access to fingerprint reader only
  ///
  /// In en, this message translates to:
  /// **'Only allow fingerprint reader use on cabinets.'**
  String get settingsGeneral_fingerprintOnlyLabel;

  /// Checkbox label allowing orders to be accepted outside the configured time window
  ///
  /// In en, this message translates to:
  /// **'Orders outside the time window may be accepted.'**
  String get settingsGeneral_allowOutOfWindowOrdersLabel;

  /// Checkbox label allowing per-cell expiry date entry for unit-dose drawers during refill
  ///
  /// In en, this message translates to:
  /// **'Allow entering a separate expiry date for each compartment in unit-dose drawers during drug refill.'**
  String get settingsGeneral_perCellExpiryDateLabel;

  /// No description provided for @settingsGeneral_collectOrderTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Order Detail Listing Time Window (hours)'**
  String get settingsGeneral_collectOrderTimeLabel;

  /// No description provided for @settingsGeneral_wasteDestructionTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Waste/Destruction Time Window (hours)'**
  String get settingsGeneral_wasteDestructionTimeLabel;

  /// No description provided for @settingsGeneral_wasteOrderReactivateLabel.
  ///
  /// In en, this message translates to:
  /// **'Reactivate order after waste/destruction'**
  String get settingsGeneral_wasteOrderReactivateLabel;

  /// No description provided for @settingsGeneral_badgeCardPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Require password on badge card login'**
  String get settingsGeneral_badgeCardPasswordLabel;

  /// Dropdown label for the prescription access duration setting
  ///
  /// In en, this message translates to:
  /// **'Prescription Access Duration (minutes)'**
  String get settingsPrescription_accessDurationLabel;

  /// Helper text explaining the prescription access duration setting
  ///
  /// In en, this message translates to:
  /// **'Specifies how long before and after product pickup times prescriptions remain accessible.'**
  String get settingsPrescription_accessDurationDescription;

  /// Tab title for cabinet communication settings, visible to manager/admin only
  ///
  /// In en, this message translates to:
  /// **'Cabinet Communication Settings'**
  String get settingsView_cabinTabTitle;

  /// Tab title for prescription settings, visible to manager/admin only
  ///
  /// In en, this message translates to:
  /// **'Prescription Settings'**
  String get settingsView_prescriptionTabTitle;

  /// Tab title for general settings, visible to everyone
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get settingsView_generalTabTitle;

  /// Tab title for developer settings, visible to admin only
  ///
  /// In en, this message translates to:
  /// **'Developer Settings'**
  String get settingsView_developerTabTitle;

  /// Button label to refresh the current user's permissions
  ///
  /// In en, this message translates to:
  /// **'Refresh Permissions'**
  String get settingsView_refreshPermissionsButton;

  /// Default room name seeded into the name field when adding a new room
  ///
  /// In en, this message translates to:
  /// **'Room {index}'**
  String stationSetup_defaultRoomName(int index);

  /// Success message shown after creating a service
  ///
  /// In en, this message translates to:
  /// **'Service created successfully'**
  String get stationSetup_service_createdSuccessMessage;

  /// Success message shown after updating a service
  ///
  /// In en, this message translates to:
  /// **'Service updated successfully'**
  String get stationSetup_service_updatedSuccessMessage;

  /// Section header above the room/bed list in the service form
  ///
  /// In en, this message translates to:
  /// **'Rooms & Beds'**
  String get stationSetup_roomsSectionTitle;

  /// Summary line showing the total room and bed count for a service
  ///
  /// In en, this message translates to:
  /// **'{roomCount} rooms · {bedCount} beds'**
  String stationSetup_roomsBedsSummary(int roomCount, int bedCount);

  /// Button label to add a new room
  ///
  /// In en, this message translates to:
  /// **'Add Room'**
  String get stationSetup_addRoomButton;

  /// Badge showing the bed count for a room
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} bed} other{{count} beds}}'**
  String stationSetup_bedCountBadge(int count);

  /// Empty-state text inside an expanded room tile when it has no beds
  ///
  /// In en, this message translates to:
  /// **'No beds added yet'**
  String get stationSetup_noBedsAddedYetMessage;

  /// Button label to add a new bed to a room
  ///
  /// In en, this message translates to:
  /// **'Add Bed'**
  String get stationSetup_addBedButton;

  /// Side panel title / add button label when creating a new service
  ///
  /// In en, this message translates to:
  /// **'New Service'**
  String get stationSetup_service_formTitleNew;

  /// Side panel title when editing an existing service
  ///
  /// In en, this message translates to:
  /// **'Edit Service'**
  String get stationSetup_service_formTitleEdit;

  /// Side panel subtitle when creating a new service
  ///
  /// In en, this message translates to:
  /// **'Fill in the service details'**
  String get stationSetup_service_formSubtitleNew;

  /// Side panel subtitle when editing an existing service
  ///
  /// In en, this message translates to:
  /// **'Update the service details'**
  String get stationSetup_service_formSubtitleEdit;

  /// Field label for the service name
  ///
  /// In en, this message translates to:
  /// **'Service Name'**
  String get stationSetup_service_nameLabel;

  /// Field label for the service's branch selection
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get stationSetup_service_branchLabel;

  /// Selection dialog title for choosing a branch
  ///
  /// In en, this message translates to:
  /// **'Select Branch'**
  String get stationSetup_service_branchSelectTitle;

  /// Field label for the service's responsible user selection
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get stationSetup_service_userLabel;

  /// Status dropdown label shared by the service and warehouse forms in station setup
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get stationSetup_common_statusLabel;

  /// Success message shown after creating a station
  ///
  /// In en, this message translates to:
  /// **'Station created successfully'**
  String get stationSetup_station_createdSuccessMessage;

  /// Success message shown after updating a station
  ///
  /// In en, this message translates to:
  /// **'Station updated successfully'**
  String get stationSetup_station_updatedSuccessMessage;

  /// Side panel title / add button label when creating a new station
  ///
  /// In en, this message translates to:
  /// **'New Station'**
  String get stationSetup_station_formTitleNew;

  /// Side panel title when editing an existing station
  ///
  /// In en, this message translates to:
  /// **'Edit Station'**
  String get stationSetup_station_formTitleEdit;

  /// Side panel subtitle when creating a new station
  ///
  /// In en, this message translates to:
  /// **'Fill in the station details'**
  String get stationSetup_station_formSubtitleNew;

  /// Side panel subtitle when editing an existing station
  ///
  /// In en, this message translates to:
  /// **'Update the station details'**
  String get stationSetup_station_formSubtitleEdit;

  /// Field label for the station name
  ///
  /// In en, this message translates to:
  /// **'Station Name'**
  String get stationSetup_station_nameLabel;

  /// Field label for the station's drug warehouse selection
  ///
  /// In en, this message translates to:
  /// **'Drug Warehouse'**
  String get stationSetup_station_drugWarehouseLabel;

  /// Selection dialog title for choosing a drug warehouse
  ///
  /// In en, this message translates to:
  /// **'Select Drug Warehouse'**
  String get stationSetup_station_drugWarehouseSelectTitle;

  /// Dropdown label for the station's drug status
  ///
  /// In en, this message translates to:
  /// **'Drug Status'**
  String get stationSetup_station_drugStatusLabel;

  /// Field label for the station's medical consumable warehouse selection
  ///
  /// In en, this message translates to:
  /// **'Medical Consumable Warehouse'**
  String get stationSetup_station_consumableWarehouseLabel;

  /// Selection dialog title for choosing a medical consumable warehouse
  ///
  /// In en, this message translates to:
  /// **'Select Medical Consumable Warehouse'**
  String get stationSetup_station_consumableWarehouseSelectTitle;

  /// Dropdown label for the station's medical consumable status, shown in the setup wizard
  ///
  /// In en, this message translates to:
  /// **'Medical Consumable Status'**
  String get stationSetup_station_consumableStatusLabel;

  /// Field label for the station's service selection
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get stationSetup_station_serviceLabel;

  /// Selection dialog title for choosing a service
  ///
  /// In en, this message translates to:
  /// **'Select Service'**
  String get stationSetup_station_serviceSelectTitle;

  /// Field label / dialog title for the station's multi-selected list of served services
  ///
  /// In en, this message translates to:
  /// **'Services Served'**
  String get stationSetup_station_providedServicesLabel;

  /// Radio field label for the station type
  ///
  /// In en, this message translates to:
  /// **'Station Type'**
  String get stationSetup_station_typeLabel;

  /// Radio option label for patient-based station type
  ///
  /// In en, this message translates to:
  /// **'Patient-Based'**
  String get stationSetup_station_typePatientBasedLabel;

  /// Radio option label for medicine-based station type
  ///
  /// In en, this message translates to:
  /// **'Medicine-Based'**
  String get stationSetup_station_typeMedicineBasedLabel;

  /// Success message shown after creating a warehouse
  ///
  /// In en, this message translates to:
  /// **'Warehouse created successfully'**
  String get stationSetup_warehouse_createdSuccessMessage;

  /// Success message shown after updating a warehouse
  ///
  /// In en, this message translates to:
  /// **'Warehouse updated successfully'**
  String get stationSetup_warehouse_updatedSuccessMessage;

  /// Side panel title / add button label when creating a new warehouse
  ///
  /// In en, this message translates to:
  /// **'New Warehouse'**
  String get stationSetup_warehouse_formTitleNew;

  /// Side panel title when editing an existing warehouse
  ///
  /// In en, this message translates to:
  /// **'Edit Warehouse'**
  String get stationSetup_warehouse_formTitleEdit;

  /// Side panel subtitle when creating a new warehouse
  ///
  /// In en, this message translates to:
  /// **'Fill in the warehouse details'**
  String get stationSetup_warehouse_formSubtitleNew;

  /// Side panel subtitle when editing an existing warehouse
  ///
  /// In en, this message translates to:
  /// **'Update the warehouse details'**
  String get stationSetup_warehouse_formSubtitleEdit;

  /// Field label for the warehouse code
  ///
  /// In en, this message translates to:
  /// **'Warehouse Code'**
  String get stationSetup_warehouse_codeLabel;

  /// Field label for the warehouse name
  ///
  /// In en, this message translates to:
  /// **'Warehouse Name'**
  String get stationSetup_warehouse_nameLabel;

  /// Dropdown label for the warehouse type
  ///
  /// In en, this message translates to:
  /// **'Warehouse Type'**
  String get stationSetup_warehouse_typeLabel;

  /// Field label for the warehouse manager selection
  ///
  /// In en, this message translates to:
  /// **'Warehouse Manager'**
  String get stationSetup_warehouse_managerLabel;

  /// Selection dialog title for choosing a warehouse manager
  ///
  /// In en, this message translates to:
  /// **'Select Warehouse Manager'**
  String get stationSetup_warehouse_managerSelectTitle;

  /// Segmented-button tab label / wizard step title for station definition
  ///
  /// In en, this message translates to:
  /// **'Station Definition'**
  String get stationSetup_screen_stationTabTitle;

  /// Segmented-button tab label / wizard step title for service definition
  ///
  /// In en, this message translates to:
  /// **'Service Definition'**
  String get stationSetup_screen_serviceTabTitle;

  /// Segmented-button tab label / wizard step title for warehouse definition
  ///
  /// In en, this message translates to:
  /// **'Warehouse Definition'**
  String get stationSetup_screen_warehouseTabTitle;

  /// Button label opening the station setup wizard dialog
  ///
  /// In en, this message translates to:
  /// **'Setup Wizard'**
  String get stationSetup_screen_setupWizardButton;

  /// Dialog title for the station setup wizard
  ///
  /// In en, this message translates to:
  /// **'Station Setup Wizard'**
  String get stationSetup_wizard_title;

  /// Final-step confirm button label in the station setup wizard
  ///
  /// In en, this message translates to:
  /// **'Complete Setup'**
  String get stationSetup_wizard_completeSetupButton;

  /// Continue button label for non-final steps in the station setup wizard
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get stationSetup_wizard_continueButton;

  /// Back button label in the station setup wizard
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get stationSetup_wizard_backButton;

  /// Dialog title for the unapplied prescription detail/material list view
  ///
  /// In en, this message translates to:
  /// **'Material List'**
  String get unappliedPrescription_detailDialogTitle;

  /// Fallback screen title when the menu name is not provided
  ///
  /// In en, this message translates to:
  /// **'Unapplied Prescriptions'**
  String get unappliedPrescription_screenTitleFallback;

  /// Tooltip on the table action item to view unapplied prescription details
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get unappliedPrescription_viewDetailsTooltip;

  /// Fallback error text shown when the cabin list fails to load and no specific error message is provided
  ///
  /// In en, this message translates to:
  /// **'Cabinets could not be loaded'**
  String get dashboardCabinsLoadErrorFallback;

  /// Label shown next to the cabin selector when the cabin list is stale
  ///
  /// In en, this message translates to:
  /// **'Cabinet list is out of date'**
  String get dashboardCabinListStaleLabel;

  /// Panel header title for the dashboard drug activity panel
  ///
  /// In en, this message translates to:
  /// **'DRUG ACTIVITY'**
  String get dashboardDrugActivityPanelTitle;

  /// Empty-state title for the drug activity panel
  ///
  /// In en, this message translates to:
  /// **'No activity'**
  String get dashboardDrugActivityEmptyTitle;

  /// Combined date/time info-row label in the drug activity panel
  ///
  /// In en, this message translates to:
  /// **'DATE / TIME'**
  String get dashboardDrugActivityDateTimeLabel;

  /// Panel header title for the dashboard missing-stock panel
  ///
  /// In en, this message translates to:
  /// **'MISSING STOCK REPORTS'**
  String get dashboardMissingStockPanelTitle;

  /// Empty-state title for the missing-stock panel
  ///
  /// In en, this message translates to:
  /// **'No missing stock reports'**
  String get dashboardMissingStockEmptyTitle;

  /// Column header for the time in the missing-stock panel table
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get dashboardMissingStockTimeLabel;

  /// Approve action button in the missing-stock panel
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get dashboardMissingStockApproveButton;

  /// Reject action button in the missing-stock panel
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get dashboardMissingStockRejectButton;

  /// Placeholder text shown for the non-mobile-cabin panel, noting it's planned for a future iteration
  ///
  /// In en, this message translates to:
  /// **'Expired materials & critical stock (coming next)'**
  String get dashboardOtherCabinPlaceholderText;

  /// Panel header title for the dashboard unapplied-prescriptions panel
  ///
  /// In en, this message translates to:
  /// **'UNAPPLIED PRESCRIPTIONS'**
  String get dashboardUnappliedPrescriptionsPanelTitle;

  /// Empty-state title for the unapplied-prescriptions panel
  ///
  /// In en, this message translates to:
  /// **'No unapplied prescriptions'**
  String get dashboardUnappliedPrescriptionsEmptyTitle;

  /// Column header for the doctor name in the unapplied-prescriptions panel
  ///
  /// In en, this message translates to:
  /// **'DOCTOR'**
  String get dashboardDoctorLabel;

  /// Combined column header for room and bed in the unapplied-prescriptions panel
  ///
  /// In en, this message translates to:
  /// **'ROOM / BED'**
  String get dashboardRoomBedLabel;

  /// Panel header title for the dashboard upcoming-treatments panel
  ///
  /// In en, this message translates to:
  /// **'UPCOMING TREATMENTS'**
  String get dashboardUpcomingTreatmentsPanelTitle;

  /// Empty-state title for the upcoming-treatments panel
  ///
  /// In en, this message translates to:
  /// **'No upcoming treatments'**
  String get dashboardUpcomingTreatmentsEmptyTitle;

  /// Fallback error text for a dashboard list panel when no specific error message is provided
  ///
  /// In en, this message translates to:
  /// **'Could not load'**
  String get dashboardListPanelLoadErrorFallback;

  /// Success message shown after cancelling or rejecting a prescription action
  ///
  /// In en, this message translates to:
  /// **'The operation was completed successfully.'**
  String get prescriptionActionCompletedSuccess;

  /// Success message shown after approving a prescription
  ///
  /// In en, this message translates to:
  /// **'The prescription was approved successfully.'**
  String get prescriptionApprovedSuccess;

  /// Fallback panel title shown when the hospitalization record is null
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get prescriptionDetailPanelPatientFallback;

  /// Side panel subtitle for the prescription detail view
  ///
  /// In en, this message translates to:
  /// **'Prescription History'**
  String get prescriptionDetailPanelSubtitle;

  /// Field label for the prescription movement filter start date
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get prescriptionDetailStartDateLabel;

  /// Field label for the prescription movement filter end date
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get prescriptionDetailEndDateLabel;

  /// Dropdown field label for the prescription movement type filter
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get prescriptionDetailStatusLabel;

  /// Confirm dialog title for the check-warning flow before approving a prescription
  ///
  /// In en, this message translates to:
  /// **'Check Warning'**
  String get prescriptionCheckWarningDialogTitle;

  /// Success message shown when both the prescription and its template are saved
  ///
  /// In en, this message translates to:
  /// **'The prescription and template were saved successfully.'**
  String get prescriptionSaveWithTemplateSuccess;

  /// Informational message shown when the prescription saved but its template failed to save
  ///
  /// In en, this message translates to:
  /// **'The prescription was saved, but the template could not be saved.'**
  String get prescriptionSavedTemplateFailedMessage;

  /// Success message shown after saving a prescription without a template
  ///
  /// In en, this message translates to:
  /// **'The prescription was saved successfully.'**
  String get prescriptionSavedSuccess;

  /// Loading-state message shown while a prescription is being created
  ///
  /// In en, this message translates to:
  /// **'Creating prescription. Please wait.'**
  String get prescriptionCreatingLoadingMessage;

  /// Loading-state message shown while a prescription template is being saved
  ///
  /// In en, this message translates to:
  /// **'Saving template.'**
  String get prescriptionTemplateSavingLoadingMessage;

  /// Dialog title / button label / tooltip for creating a new prescription
  ///
  /// In en, this message translates to:
  /// **'New Prescription'**
  String get prescriptionNewTitle;

  /// Subtitle on the new-prescription dialog
  ///
  /// In en, this message translates to:
  /// **'Create a prescription or import one from history'**
  String get prescriptionNewDialogSubtitle;

  /// Tab label for the prescription history tab
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get prescriptionTabHistory;

  /// Tab label for the prescription templates tab
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get prescriptionTabTemplates;

  /// Empty-state title for the prescription content list
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any medicine to the prescription yet.'**
  String get prescriptionContentEmptyTitle;

  /// Empty-state description for the prescription content list
  ///
  /// In en, this message translates to:
  /// **'The medicines you add will be displayed here.'**
  String get prescriptionContentEmptyDescription;

  /// Shown when a prescription item has no configured dose times
  ///
  /// In en, this message translates to:
  /// **'No times added'**
  String get prescriptionItemNoTimesLabel;

  /// Placeholder item title shown before a medicine is selected
  ///
  /// In en, this message translates to:
  /// **'No medicine selected yet'**
  String get prescriptionItemNoMedicineSelected;

  /// Selection field label for the patient on the prescription dialog
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get prescriptionPatientFieldLabel;

  /// Selection field label for the doctor on the prescription dialog
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get prescriptionDoctorFieldLabel;

  /// Primary save button label on the prescription dialog
  ///
  /// In en, this message translates to:
  /// **'Save Prescription'**
  String get prescriptionSaveButton;

  /// Checkbox label to also save the prescription as a reusable template
  ///
  /// In en, this message translates to:
  /// **'Also save as template'**
  String get prescriptionSaveAsTemplateCheckboxLabel;

  /// Text field hint for the prescription template name
  ///
  /// In en, this message translates to:
  /// **'Template Name'**
  String get prescriptionTemplateNameHint;

  /// Field label for the medicine/material selection on the prescription item form
  ///
  /// In en, this message translates to:
  /// **'Medicine / Material'**
  String get prescriptionMedicineFieldLabel;

  /// Text field label for the prescription item description
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get prescriptionDescriptionFieldLabel;

  /// Quick-pick chip label for tomorrow's date on the prescription time picker
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get prescriptionTomorrowLabel;

  /// Section label above the dose times list on the prescription form
  ///
  /// In en, this message translates to:
  /// **'Times'**
  String get prescriptionTimesLabel;

  /// Add-row action label to add a new dose time
  ///
  /// In en, this message translates to:
  /// **'Add time'**
  String get prescriptionAddTimeButton;

  /// Empty-state title shown before a patient is selected in prescription history
  ///
  /// In en, this message translates to:
  /// **'Select a patient'**
  String get prescriptionHistorySelectPatientTitle;

  /// Empty-state description shown before a patient is selected in prescription history
  ///
  /// In en, this message translates to:
  /// **'Select a patient first to view their prescription history'**
  String get prescriptionHistorySelectPatientDescription;

  /// Empty-state description shown when the selected patient has no prescription history
  ///
  /// In en, this message translates to:
  /// **'This patient has no prescription history'**
  String get prescriptionHistoryEmptyDescription;

  /// Button label to add the selected items to the current prescription, showing the selected count
  ///
  /// In en, this message translates to:
  /// **'Add to Prescription ({count})'**
  String prescriptionAddToRxButton(int count);

  /// Empty-state title for the prescription template list
  ///
  /// In en, this message translates to:
  /// **'No template found'**
  String get prescriptionTemplateEmptyTitle;

  /// Empty-state description for the prescription template list
  ///
  /// In en, this message translates to:
  /// **'There is no saved prescription template'**
  String get prescriptionTemplateEmptyDescription;

  /// Shown when an expanded prescription template has zero items
  ///
  /// In en, this message translates to:
  /// **'This template has no items'**
  String get prescriptionTemplateNoItemsMessage;

  /// Fallback screen title when the menu name is not provided
  ///
  /// In en, this message translates to:
  /// **'Prescription Operations'**
  String get prescriptionScreenTitleFallback;

  /// Table row action tooltip to view prescription content
  ///
  /// In en, this message translates to:
  /// **'Prescription Content'**
  String get prescriptionContentTooltip;

  /// Toolbar toggle tooltip to switch back to showing active hospitalizations
  ///
  /// In en, this message translates to:
  /// **'Show active admissions'**
  String get prescriptionShowActiveButton;

  /// Toolbar toggle tooltip to show discharged patients
  ///
  /// In en, this message translates to:
  /// **'Show discharged patients'**
  String get prescriptionShowDischargedButton;

  /// Desktop layout screen title for cabinet temperature control
  ///
  /// In en, this message translates to:
  /// **'Cabinet Temperature Control'**
  String get cabinTemperatureScreenTitle;

  /// Dialog title for the cabinet temperature form, used for both create and edit
  ///
  /// In en, this message translates to:
  /// **'Edit Cabinet'**
  String get cabinTemperatureFormDialogTitle;

  /// Field label / table column header for the inside-bottom temperature reading
  ///
  /// In en, this message translates to:
  /// **'Inside Bottom Temperature'**
  String get cabinTemperatureInsideBottomLabel;

  /// Field label / table column header for the inside-top temperature reading
  ///
  /// In en, this message translates to:
  /// **'Inside Top Temperature'**
  String get cabinTemperatureInsideTopLabel;

  /// Field label / table column header for the outside-bottom temperature reading
  ///
  /// In en, this message translates to:
  /// **'Outside Bottom Temperature'**
  String get cabinTemperatureOutsideBottomLabel;

  /// Field label / table column header for the outside-top temperature reading
  ///
  /// In en, this message translates to:
  /// **'Outside Top Temperature'**
  String get cabinTemperatureOutsideTopLabel;

  /// Field label / table column header for the humidity lower limit
  ///
  /// In en, this message translates to:
  /// **'Humidity Lower Limit'**
  String get cabinTemperatureHumidityBottomLabel;

  /// Field label / table column header for the humidity upper limit
  ///
  /// In en, this message translates to:
  /// **'Humidity Upper Limit'**
  String get cabinTemperatureHumidityTopLabel;

  /// Generic error message with the underlying error detail appended
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String cabinTemperatureGenericErrorMessage(String error);

  /// Validation error shown when no station is selected before creating a cabinet temperature setting
  ///
  /// In en, this message translates to:
  /// **'No station selected'**
  String get cabinTemperatureStationNotSelectedError;

  /// Success message shown after creating a cabinet temperature setting
  ///
  /// In en, this message translates to:
  /// **'The cabinet temperature setting was created successfully.'**
  String get cabinTemperatureCreateSuccess;

  /// Validation error shown when the record to update cannot be found
  ///
  /// In en, this message translates to:
  /// **'No record found to update'**
  String get cabinTemperatureUpdateRecordNotFoundError;

  /// Success message shown after updating a cabinet temperature setting
  ///
  /// In en, this message translates to:
  /// **'The cabinet temperature setting was updated successfully.'**
  String get cabinTemperatureUpdateSuccess;

  /// Fallback station name shown in the sidebar category label when the station has no name
  ///
  /// In en, this message translates to:
  /// **'Unnamed Station'**
  String get cabinTemperatureUnnamedStationFallback;

  /// Loading-state message while stations are being fetched
  ///
  /// In en, this message translates to:
  /// **'Loading stations...'**
  String get cabinTemperatureStationsLoadingMessage;

  /// Loading-state message while temperature details are being fetched
  ///
  /// In en, this message translates to:
  /// **'Loading temperature details...'**
  String get cabinTemperatureDetailsLoadingMessage;

  /// Table column header for the cabinet name in the cabin temperature table
  ///
  /// In en, this message translates to:
  /// **'Cabinet'**
  String get cabinTemperatureColumnCabin;

  /// Desktop layout screen title / dialog title for the directed orders list
  ///
  /// In en, this message translates to:
  /// **'Directed Order List'**
  String get directedOrdersScreenTitle;

  /// Table column title for the protocol number in the directed orders table
  ///
  /// In en, this message translates to:
  /// **'Protocol No.'**
  String get directedOrdersColumnProtocolNo;

  /// Table column title for the bed in the directed orders table
  ///
  /// In en, this message translates to:
  /// **'Bed'**
  String get directedOrdersColumnBed;

  /// Table column title for the room in the directed orders table
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get directedOrdersColumnRoom;

  /// Row action tooltip that opens the medicine table dialog for a directed order
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get directedOrdersMedicinesTooltip;

  /// Loading-state message while patients are being fetched
  ///
  /// In en, this message translates to:
  /// **'Loading patients...'**
  String get directedOrdersPatientsLoadingMessage;

  /// Table column title for the barcode in the directed order entity
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get directedOrdersColumnBarcode;

  /// Success message shown after creating a drug
  ///
  /// In en, this message translates to:
  /// **'Drug created'**
  String get medicine_successCreated;

  /// Success message shown after updating a drug
  ///
  /// In en, this message translates to:
  /// **'Drug updated'**
  String get medicine_successUpdated;

  /// Success message shown after creating a medical consumable
  ///
  /// In en, this message translates to:
  /// **'Medical consumable created'**
  String get medicalConsumable_successCreated;

  /// Success message shown after updating a medical consumable
  ///
  /// In en, this message translates to:
  /// **'Medical consumable updated'**
  String get medicalConsumable_successUpdated;

  /// Side panel title / toolbar button label when creating a new drug
  ///
  /// In en, this message translates to:
  /// **'New Drug'**
  String get medicine_formTitleNew;

  /// Side panel title when editing an existing drug
  ///
  /// In en, this message translates to:
  /// **'Edit Drug'**
  String get medicine_formTitleEdit;

  /// Side panel subtitle when creating a new drug
  ///
  /// In en, this message translates to:
  /// **'Fill in the drug details'**
  String get medicine_formSubtitleNew;

  /// Side panel subtitle when editing an existing drug
  ///
  /// In en, this message translates to:
  /// **'Update the drug details'**
  String get medicine_formSubtitleEdit;

  /// Text field label for the drug's definition name
  ///
  /// In en, this message translates to:
  /// **'Definition Name'**
  String get medicine_fieldDefinitionName;

  /// Text field label for the drug/consumable barcode, shared between drug and medical consumable forms
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get medicine_fieldBarcode;

  /// Text field label for the drug name
  ///
  /// In en, this message translates to:
  /// **'Drug Name'**
  String get medicine_fieldName;

  /// Text field label for the drug code
  ///
  /// In en, this message translates to:
  /// **'Drug Code'**
  String get medicine_fieldCode;

  /// Dropdown label for the drug's prescription type
  ///
  /// In en, this message translates to:
  /// **'Prescription Type'**
  String get medicine_fieldPrescriptionType;

  /// Text field label for dose, used for both the main dose and measurement dose fields
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get medicine_fieldDose;

  /// Selection field label for the manufacturer, shared between drug and medical consumable forms
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get medicine_fieldManufacturer;

  /// Field label for the daily maximum usage amount, shared between drug and medical consumable forms
  ///
  /// In en, this message translates to:
  /// **'Daily Max. Usage Amount'**
  String get medicine_fieldDailyMaxUsage;

  /// Selection field label/title for the drug type
  ///
  /// In en, this message translates to:
  /// **'Drug Type'**
  String get medicine_fieldDrugType;

  /// Selection field label for the return method, shared between drug and medical consumable forms
  ///
  /// In en, this message translates to:
  /// **'Return Method'**
  String get medicine_fieldReturnType;

  /// Checkbox label shown when the return type is 'to origin'
  ///
  /// In en, this message translates to:
  /// **'Check the max value in the serum cabinet'**
  String get medicine_checkboxSerumMaxValue;

  /// Conditional checkbox label for checking the max value in a cubic drawer
  ///
  /// In en, this message translates to:
  /// **'Check the max value in the cubic drawer'**
  String get medicine_checkboxCubicMaxValue;

  /// Checkbox label indicating the drug has a QR code
  ///
  /// In en, this message translates to:
  /// **'Has QR Code'**
  String get medicine_checkboxQrCode;

  /// Dropdown label for the QR piece-count unit on the drug form
  ///
  /// In en, this message translates to:
  /// **'Piece Count'**
  String get medicine_fieldPieceCountLabel;

  /// Selection field label/title for the drug class
  ///
  /// In en, this message translates to:
  /// **'Drug Class'**
  String get medicine_fieldDrugClass;

  /// Selection field label for the purchase method, shared between drug and medical consumable forms
  ///
  /// In en, this message translates to:
  /// **'Purchase Method'**
  String get medicine_fieldPurchaseType;

  /// Checkbox label to enable measurement unit fields on the drug form
  ///
  /// In en, this message translates to:
  /// **'Use Measurement Unit'**
  String get medicine_checkboxUseMeasurementUnit;

  /// Text field label for the drug's volume
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get medicine_fieldVolume;

  /// Text field label opening the dosage form picker
  ///
  /// In en, this message translates to:
  /// **'Dosage Form'**
  String get medicine_fieldDosageForm;

  /// Dropdown label for the drug's status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get medicine_fieldStatus;

  /// Selection field label for the count type, shared between drug and medical consumable forms
  ///
  /// In en, this message translates to:
  /// **'Count Type'**
  String get medicine_fieldCountType;

  /// Text field label for the drug's ATC code
  ///
  /// In en, this message translates to:
  /// **'ATC Code'**
  String get medicine_fieldAtcCode;

  /// Text field label for the drug's equivalent code
  ///
  /// In en, this message translates to:
  /// **'Equivalent Code'**
  String get medicine_fieldEquivalentCode;

  /// Checkbox label indicating purchases require a witness
  ///
  /// In en, this message translates to:
  /// **'Witnessed Purchase'**
  String get medicine_checkboxWitnessedPurchase;

  /// Checkbox label indicating waste/disposal requires a witness
  ///
  /// In en, this message translates to:
  /// **'Witnessed Waste/Disposal'**
  String get medicine_checkboxWastageWitnessed;

  /// Checkbox label indicating the drug can be disposed of
  ///
  /// In en, this message translates to:
  /// **'Disposable'**
  String get medicine_checkboxDestroyable;

  /// Multi-selection field label/title for the drug's active ingredients
  ///
  /// In en, this message translates to:
  /// **'Active Ingredient'**
  String get medicine_fieldActiveIngredient;

  /// Text field label for the purchase note, shared between drug and medical consumable forms
  ///
  /// In en, this message translates to:
  /// **'Purchase Note'**
  String get medicine_fieldCollectNote;

  /// Text field label for the return note, shared between drug and medical consumable forms
  ///
  /// In en, this message translates to:
  /// **'Return Note'**
  String get medicine_fieldReturnNote;

  /// Text field label for the disposal note, shared between drug and medical consumable forms
  ///
  /// In en, this message translates to:
  /// **'Disposal Note'**
  String get medicine_fieldDestructionNote;

  /// Dialog title for the medical consumable form, used for both create and edit
  ///
  /// In en, this message translates to:
  /// **'Add/Edit Medical Consumable'**
  String get medicalConsumable_dialogTitle;

  /// Text field label for the medical consumable name
  ///
  /// In en, this message translates to:
  /// **'Material Name'**
  String get medicalConsumable_fieldName;

  /// Text field label for the medical consumable's institution code
  ///
  /// In en, this message translates to:
  /// **'Institution Code'**
  String get medicalConsumable_fieldInstitutionCode;

  /// Text field label for the medical consumable's SUT (reimbursement) code
  ///
  /// In en, this message translates to:
  /// **'SUT Code/Annex'**
  String get medicalConsumable_fieldSutCode;

  /// Text field label for the medical consumable's UBB (national product bank) code
  ///
  /// In en, this message translates to:
  /// **'UBB Code'**
  String get medicalConsumable_fieldUbbCode;

  /// Selection field label/title for the medical consumable's material type
  ///
  /// In en, this message translates to:
  /// **'Material Type'**
  String get medicalConsumable_fieldMaterialType;

  /// Dropdown label for the medical consumable's status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get medicalConsumable_fieldStatus;

  /// Fallback screen title when the menu name is not provided
  ///
  /// In en, this message translates to:
  /// **'Drug/Medical Consumable Definition'**
  String get medicine_screenTitleFallback;

  /// Toolbar button label to create a new drug
  ///
  /// In en, this message translates to:
  /// **'New Drug'**
  String get medicine_newButtonLabel;

  /// Bottom action button opening medical consumable definition
  ///
  /// In en, this message translates to:
  /// **'Define Medical Consumable'**
  String get medicine_defineMedicalConsumableButton;

  /// Bottom action button opening active ingredient definition
  ///
  /// In en, this message translates to:
  /// **'Define Active Ingredient'**
  String get medicine_defineActiveIngredientButton;

  /// Bottom action button opening drug class definition
  ///
  /// In en, this message translates to:
  /// **'Define Drug Class'**
  String get medicine_defineDrugClassButton;

  /// Bottom action button opening drug type definition
  ///
  /// In en, this message translates to:
  /// **'Define Drug Type'**
  String get medicine_defineDrugTypeButton;

  /// Bottom action button opening kit creation
  ///
  /// In en, this message translates to:
  /// **'Create Drug Kit'**
  String get medicine_createKitButton;

  /// Bottom action button opening material type definition
  ///
  /// In en, this message translates to:
  /// **'Define Material Type'**
  String get medicine_defineMaterialTypeButton;

  /// Checkbox label allowing doses lower than the specified amount
  ///
  /// In en, this message translates to:
  /// **'A dose lower than specified may be taken'**
  String get medicine_checkboxLowerDose;

  /// Checkbox label indicating RFID can be used for this drug
  ///
  /// In en, this message translates to:
  /// **'RFID Available'**
  String get medicine_checkboxRfid;

  /// Checkbox label enabling multi-patient access to the drug
  ///
  /// In en, this message translates to:
  /// **'Multi-Patient Access'**
  String get medicine_checkboxMultiPatientAccess;

  /// Checkbox label indicating the drug is for single use
  ///
  /// In en, this message translates to:
  /// **'Single Use'**
  String get medicine_checkboxSingleUse;

  /// Checkbox label requiring camera recording during drug operations
  ///
  /// In en, this message translates to:
  /// **'Camera Recording'**
  String get medicine_checkboxCameraRecording;

  /// Checkbox label indicating the drug is independent/unrestricted
  ///
  /// In en, this message translates to:
  /// **'Independent Drug'**
  String get medicine_checkboxIndependentMaterial;

  /// Checkbox label requiring pharmacy approval for waste/disposal
  ///
  /// In en, this message translates to:
  /// **'Require Pharmacy Approval for Waste/Disposal?'**
  String get medicine_checkboxWastagePharmacyApproval;

  /// Checkbox label to renew the waste order automatically
  ///
  /// In en, this message translates to:
  /// **'Renew Waste Order?'**
  String get medicine_checkboxWastageOrderRenewed;

  /// Multi-selection field label for authorized personnel
  ///
  /// In en, this message translates to:
  /// **'Personnel'**
  String get medicine_fieldPersonnel;

  /// Multi-selection field label for the drug's assigned stations
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get medicine_fieldStation;

  /// Text field label opening the unit picker
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get medicine_fieldUnit;

  /// Dialog title for the refill list detail/refill view
  ///
  /// In en, this message translates to:
  /// **'Drug Refill List'**
  String get refillList_dialogTitle;

  /// Label showing the refill list's record number
  ///
  /// In en, this message translates to:
  /// **'Refill Record No: {id}'**
  String refillList_recordNoLabel(Object id);

  /// Label showing the refill list's creation date
  ///
  /// In en, this message translates to:
  /// **'Created Date: {date}'**
  String refillList_createdDateLabel(String date);

  /// Label showing the user assigned to perform the refill
  ///
  /// In en, this message translates to:
  /// **'Assigned To: {name}'**
  String refillList_assignedUserNameLabel(String name);

  /// Side panel title when creating a new refill list
  ///
  /// In en, this message translates to:
  /// **'Create Refill List'**
  String get refillList_formTitleCreate;

  /// Side panel title when editing an existing refill list
  ///
  /// In en, this message translates to:
  /// **'Update Refill List'**
  String get refillList_formTitleUpdate;

  /// Selection field label/title for the user assigned to perform the refill
  ///
  /// In en, this message translates to:
  /// **'User Assigned to Refill'**
  String get refillList_fieldAssignedUser;

  /// Fallback screen title when the menu name is not provided
  ///
  /// In en, this message translates to:
  /// **'Refill List'**
  String get refillList_screenTitleFallback;

  /// Toolbar button label to create a new refill list
  ///
  /// In en, this message translates to:
  /// **'New Refill List'**
  String get refillList_newButtonLabel;

  /// Category title for the stations side-list, shared across refill list, expired items report and station transaction report screens
  ///
  /// In en, this message translates to:
  /// **'Stations'**
  String get report_stationsCategoryTitle;

  /// Table cell boolean display for a true value in the refill list table
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get refillList_cellValueYes;

  /// Table cell boolean display for a false value in the refill list table
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get refillList_cellValueNo;

  /// Tooltip on the table action item to update the refill list status
  ///
  /// In en, this message translates to:
  /// **'Update Status'**
  String get refillList_updateStatusTooltip;

  /// Fallback unit text shown in the refill dose stepper when the medicine has no operation unit
  ///
  /// In en, this message translates to:
  /// **'Piece'**
  String get refillList_defaultUnitFallback;

  /// Fallback screen title when the menu name is not provided, for the expired items report
  ///
  /// In en, this message translates to:
  /// **'Expired Materials'**
  String get report_expiredItemsTitleFallback;

  /// Fixed screen title for the station stock report
  ///
  /// In en, this message translates to:
  /// **'Station Cabinet Stock'**
  String get report_stationStockTitle;

  /// Fallback screen title when the menu name is not provided, for the station transaction report
  ///
  /// In en, this message translates to:
  /// **'Station Transactions'**
  String get report_stationTransactionTitleFallback;

  /// Fallback title for the hospital stock/material list report, shown when no more specific title is available
  ///
  /// In en, this message translates to:
  /// **'Hospital Material List'**
  String get report_hospitalStocksTitleFallback;

  /// Fallback screen title when the menu name is not provided
  ///
  /// In en, this message translates to:
  /// **'Inconsistency Movements'**
  String get inconsistency_screenTitleFallback;

  /// Tooltip on the table action item to view inconsistency details
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get inconsistency_viewTooltip;

  /// Tooltip on the table action item to view the inconsistency photo
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get inconsistency_photoTooltip;

  /// Side panel title / tooltip / button label when creating a new hospitalization
  ///
  /// In en, this message translates to:
  /// **'Enter New Admission'**
  String get hospitalization_formTitleNew;

  /// Side panel title / tooltip when editing an existing hospitalization
  ///
  /// In en, this message translates to:
  /// **'Edit Admission'**
  String get hospitalization_formTitleEdit;

  /// Selection field label/title for the hospitalization's patient
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get hospitalization_fieldPatient;

  /// Read-only text field label for the hospitalization code
  ///
  /// In en, this message translates to:
  /// **'Admission Code'**
  String get hospitalization_fieldCode;

  /// Selection field label/title for the hospitalization's doctor
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get hospitalization_fieldDoctor;

  /// Selection field label/title for the hospitalization's physical service
  ///
  /// In en, this message translates to:
  /// **'Physical Service'**
  String get hospitalization_fieldPhysicalService;

  /// Selection field label/title for the hospitalization's inpatient service
  ///
  /// In en, this message translates to:
  /// **'Inpatient Service'**
  String get hospitalization_fieldInpatientService;

  /// Field label for the hospitalization's room
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get hospitalization_fieldRoom;

  /// Selection dialog title for choosing a room
  ///
  /// In en, this message translates to:
  /// **'Select Room'**
  String get hospitalization_roomDialogTitle;

  /// Field label for the hospitalization's bed
  ///
  /// In en, this message translates to:
  /// **'Bed'**
  String get hospitalization_fieldBed;

  /// Selection dialog title for choosing a bed
  ///
  /// In en, this message translates to:
  /// **'Select Bed'**
  String get hospitalization_bedDialogTitle;

  /// Date field label for the hospitalization's admission date (standalone form field, distinct from the combined display string elsewhere)
  ///
  /// In en, this message translates to:
  /// **'Admission Date'**
  String get hospitalization_fieldAdmissionDate;

  /// Date field label for the hospitalization's discharge date
  ///
  /// In en, this message translates to:
  /// **'Discharge Date'**
  String get hospitalization_fieldExitDate;

  /// Checkbox label indicating the patient is an infant
  ///
  /// In en, this message translates to:
  /// **'Infant'**
  String get hospitalization_checkboxBaby;

  /// Fallback screen title when the menu name is not provided
  ///
  /// In en, this message translates to:
  /// **'Patient Operations'**
  String get hospitalization_screenTitleFallback;

  /// Tooltip on the table action item to edit patient details
  ///
  /// In en, this message translates to:
  /// **'Edit Patient Details'**
  String get hospitalization_editPatientTooltip;

  /// Toolbar icon tooltip to switch back to showing active hospitalizations
  ///
  /// In en, this message translates to:
  /// **'Show active admissions'**
  String get hospitalization_showActiveTooltip;

  /// Toolbar icon tooltip to show discharged patients
  ///
  /// In en, this message translates to:
  /// **'Show discharged patients'**
  String get hospitalization_showDischargedTooltip;

  /// Header action button to create a new admission
  ///
  /// In en, this message translates to:
  /// **'Create New Admission'**
  String get hospitalization_createButton;

  /// Side panel title / header action button label when creating a new patient
  ///
  /// In en, this message translates to:
  /// **'Create New Patient'**
  String get patient_formTitleNew;

  /// Side panel title when editing an existing patient
  ///
  /// In en, this message translates to:
  /// **'Edit Patient'**
  String get patient_formTitleEdit;

  /// Text field label for the patient's national ID number
  ///
  /// In en, this message translates to:
  /// **'National ID No.'**
  String get patient_fieldIdentity;

  /// Text field label for the patient's first name
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get patient_fieldName;

  /// Text field label for the patient's last name
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get patient_fieldSurname;

  /// Date field label for the patient's birth date
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get patient_fieldBirthDate;

  /// Dropdown label for the patient's gender
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get patient_fieldGender;

  /// Text field label for the patient's weight
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get patient_fieldWeight;

  /// Text field label for the patient's mother's name
  ///
  /// In en, this message translates to:
  /// **'Mother\'s Name'**
  String get patient_fieldMotherName;

  /// Text field label for the patient's father's name
  ///
  /// In en, this message translates to:
  /// **'Father\'s Name'**
  String get patient_fieldFatherName;

  /// Text field label for the patient's phone number
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get patient_fieldPhone;

  /// Text field label for the patient's address
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get patient_fieldAddress;

  /// Text field label for the patient's protocol number
  ///
  /// In en, this message translates to:
  /// **'Protocol No.'**
  String get patient_fieldProtocolNo;

  /// Dialog title when the active ingredient dialog is opened in selection mode
  ///
  /// In en, this message translates to:
  /// **'Select Active Ingredient'**
  String get activeIngredientDialogSelectTitle;

  /// Dialog title when the active ingredient dialog is opened in management mode
  ///
  /// In en, this message translates to:
  /// **'Active Ingredient Definition'**
  String get activeIngredientDialogTitle;

  /// Form dialog title when creating a new active ingredient
  ///
  /// In en, this message translates to:
  /// **'Add Active Ingredient'**
  String get activeIngredientFormAddTitle;

  /// Form dialog title when editing an existing active ingredient
  ///
  /// In en, this message translates to:
  /// **'Edit Active Ingredient'**
  String get activeIngredientFormEditTitle;

  /// Empty-state title for the active ingredient list
  ///
  /// In en, this message translates to:
  /// **'No active ingredients yet'**
  String get activeIngredientListEmptyTitle;

  /// Fallback screen title when the menu name is not provided
  ///
  /// In en, this message translates to:
  /// **'Station Material Assignment'**
  String get assignmentScreenTitle;

  /// Dropdown placeholder for the station selector on the assignment screen
  ///
  /// In en, this message translates to:
  /// **'Select a station'**
  String get assignmentStationSelectPlaceholder;

  /// Dialog title when the drug class dialog is opened in selection mode
  ///
  /// In en, this message translates to:
  /// **'Select Drug Class'**
  String get drugClassDialogSelectTitle;

  /// Dialog title when the drug class dialog is opened in management mode
  ///
  /// In en, this message translates to:
  /// **'Drug Class Definition'**
  String get drugClassDialogTitle;

  /// Form dialog title when creating a new drug class
  ///
  /// In en, this message translates to:
  /// **'Add Drug Class'**
  String get drugClassFormAddTitle;

  /// Form dialog title when editing an existing drug class
  ///
  /// In en, this message translates to:
  /// **'Edit Drug Class'**
  String get drugClassFormEditTitle;

  /// Text field label for the drug class name
  ///
  /// In en, this message translates to:
  /// **'Drug Class Name'**
  String get drugClassFormNameLabel;

  /// Empty-state title for the drug class list
  ///
  /// In en, this message translates to:
  /// **'No drug classes yet'**
  String get drugClassListEmptyTitle;

  /// Dialog title when the drug type dialog is opened in selection mode
  ///
  /// In en, this message translates to:
  /// **'Select Drug Type'**
  String get drugTypeDialogSelectTitle;

  /// Dialog title when the drug type dialog is opened in management mode
  ///
  /// In en, this message translates to:
  /// **'Drug Type Definition'**
  String get drugTypeDialogTitle;

  /// Form dialog title when creating a new drug type
  ///
  /// In en, this message translates to:
  /// **'Add Drug Type'**
  String get drugTypeFormAddTitle;

  /// Form dialog title when editing an existing drug type
  ///
  /// In en, this message translates to:
  /// **'Edit Drug Type'**
  String get drugTypeFormEditTitle;

  /// Text field label for the drug type name
  ///
  /// In en, this message translates to:
  /// **'Drug Type Name'**
  String get drugTypeFormNameLabel;

  /// Empty-state title for the drug type list
  ///
  /// In en, this message translates to:
  /// **'No drug types yet'**
  String get drugTypeListEmptyTitle;

  /// Form dialog title when creating a new kit
  ///
  /// In en, this message translates to:
  /// **'New Kit'**
  String get kitFormAddTitle;

  /// Form dialog title when editing an existing kit
  ///
  /// In en, this message translates to:
  /// **'Edit Kit'**
  String get kitFormEditTitle;

  /// Text field label for the kit name
  ///
  /// In en, this message translates to:
  /// **'Kit Name'**
  String get kitFormNameLabel;

  /// Dialog title when the kit dialog is opened in selection mode
  ///
  /// In en, this message translates to:
  /// **'Select Kit'**
  String get kitDialogSelectTitle;

  /// Dialog title when the kit dialog is opened in management mode
  ///
  /// In en, this message translates to:
  /// **'Kit Definition'**
  String get kitDialogTitle;

  /// Empty-state title for the kit list
  ///
  /// In en, this message translates to:
  /// **'No kits yet'**
  String get kitListEmptyTitle;

  /// Tooltip on the additional action button that opens the kit content dialog
  ///
  /// In en, this message translates to:
  /// **'Manage Kit Content'**
  String get kitListManageContentTooltip;

  /// Form dialog title when creating a new kit content item
  ///
  /// In en, this message translates to:
  /// **'Add Kit Content'**
  String get kitContentFormAddTitle;

  /// Form dialog title when editing an existing kit content item
  ///
  /// In en, this message translates to:
  /// **'Edit Kit Content'**
  String get kitContentFormEditTitle;

  /// Field label / selection dialog title for the kit content's material
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get kitContentFormMaterialLabel;

  /// Quantity/piece-count field label on the kit content form
  ///
  /// In en, this message translates to:
  /// **'Piece Count'**
  String get kitContentFormPieceLabel;

  /// Dialog title for the kit content list
  ///
  /// In en, this message translates to:
  /// **'Kit Content Definition'**
  String get kitContentDialogTitle;

  /// Empty-state title for the kit content list
  ///
  /// In en, this message translates to:
  /// **'No kit content yet'**
  String get kitContentListEmptyTitle;

  /// Form dialog title when creating a new material type
  ///
  /// In en, this message translates to:
  /// **'New Material Type'**
  String get materialTypeFormAddTitle;

  /// Form dialog title when editing an existing material type
  ///
  /// In en, this message translates to:
  /// **'Edit Material Type'**
  String get materialTypeFormEditTitle;

  /// Text field label for the material type name
  ///
  /// In en, this message translates to:
  /// **'Material Type Name'**
  String get materialTypeFormNameLabel;

  /// Dialog title when the material type dialog is opened in selection mode
  ///
  /// In en, this message translates to:
  /// **'Select Material Type'**
  String get materialTypeDialogSelectTitle;

  /// Dialog title when the material type dialog is opened in management mode
  ///
  /// In en, this message translates to:
  /// **'Material Type Definition'**
  String get materialTypeDialogTitle;

  /// Empty-state title for the material type list
  ///
  /// In en, this message translates to:
  /// **'No material types yet'**
  String get materialTypeListEmptyTitle;

  /// Form dialog title when editing an existing role
  ///
  /// In en, this message translates to:
  /// **'Edit Role'**
  String get roleFormEditTitle;

  /// Form dialog title when creating a new role
  ///
  /// In en, this message translates to:
  /// **'Add Role'**
  String get roleFormAddTitle;

  /// Text field label for the role name
  ///
  /// In en, this message translates to:
  /// **'Role Name'**
  String get roleFormNameLabel;

  /// Fallback screen title when the menu name is not provided
  ///
  /// In en, this message translates to:
  /// **'Role Definition'**
  String get roleScreenTitle;

  /// Toolbar button label to create a new role
  ///
  /// In en, this message translates to:
  /// **'New Role'**
  String get roleScreenAddButton;

  /// Success message shown after deleting a role
  ///
  /// In en, this message translates to:
  /// **'Role deleted successfully'**
  String get roleDeleteSuccessMessage;

  /// Form dialog title when creating a new unit
  ///
  /// In en, this message translates to:
  /// **'Create New Unit'**
  String get unitFormAddTitle;

  /// Form dialog title when editing an existing unit
  ///
  /// In en, this message translates to:
  /// **'Edit Unit'**
  String get unitFormEditTitle;

  /// Dialog title for the unit list screen
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitDialogTitle;

  /// Empty-state title for the unit list
  ///
  /// In en, this message translates to:
  /// **'No units yet'**
  String get unitListEmptyTitle;

  /// Side category tab label for the normal user type filter
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get userCategoryNormalLabel;

  /// Side category tab label for the time-based user type filter
  ///
  /// In en, this message translates to:
  /// **'Time-Limited'**
  String get userCategoryTimeBasedLabel;

  /// Side category tab label for the temporary user type filter
  ///
  /// In en, this message translates to:
  /// **'Temporary'**
  String get userCategoryTemporaryLabel;

  /// Success message shown after deleting a user
  ///
  /// In en, this message translates to:
  /// **'User deleted successfully'**
  String get userDeleteSuccessMessage;

  /// Success message shown after a bulk valid-date update
  ///
  /// In en, this message translates to:
  /// **'Expiry date updated'**
  String get userValidDateUpdateSuccessMessage;

  /// Form panel title when editing an existing user
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get userFormEditTitle;

  /// Form panel title when creating a new user
  ///
  /// In en, this message translates to:
  /// **'Create User'**
  String get userFormCreateTitle;

  /// Field label / column header for the user's institution registry number
  ///
  /// In en, this message translates to:
  /// **'Institution Registry No.'**
  String get userRegistrationNumberLabel;

  /// Field label for the user's first name, paired with surname
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get userNameLabel;

  /// Field label / column header for the user's last name
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get userSurnameLabel;

  /// Field label / column header for the user's occupation/role type
  ///
  /// In en, this message translates to:
  /// **'Occupation Type'**
  String get userRoleTypeLabel;

  /// Field label for the user's usage type
  ///
  /// In en, this message translates to:
  /// **'Usage Type'**
  String get userUsageTypeLabel;

  /// Field label / column header for the user's account expiry date
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get userValidUntilLabel;

  /// Field label for the user's email address on the user creation form
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get userEmailLabel;

  /// Field label for the permission allowing purchase without an order
  ///
  /// In en, this message translates to:
  /// **'Purchase Without Order'**
  String get userOrderPermissionLabel;

  /// Field label for the permission requiring a witness for station entry
  ///
  /// In en, this message translates to:
  /// **'Witnessed Station Entry'**
  String get userWitnessedStationEntryLabel;

  /// Field label for the kit purchase permission
  ///
  /// In en, this message translates to:
  /// **'Kit Purchase'**
  String get userKitPurchaseLabel;

  /// Field label in the user form showing the badge (RFID) card value read from the card reader
  ///
  /// In en, this message translates to:
  /// **'Badge Card'**
  String get user_badgeCardLabel;

  /// Placeholder shown in the user form badge card field before a card is scanned
  ///
  /// In en, this message translates to:
  /// **'Scan card'**
  String get user_badgeCardHint;

  /// Field label for the user's authorized stations
  ///
  /// In en, this message translates to:
  /// **'Authorized Stations'**
  String get userAuthorizedStationsLabel;

  /// Field label for the user's username
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get userUsernameLabel;

  /// Fallback screen title when the menu name is not provided
  ///
  /// In en, this message translates to:
  /// **'User List'**
  String get userScreenTitle;

  /// Toolbar button label to create a new user
  ///
  /// In en, this message translates to:
  /// **'New User'**
  String get userScreenAddButton;

  /// Button shown when time-based users are multi-selected, to bulk-update their expiry date
  ///
  /// In en, this message translates to:
  /// **'Update Expiry Date'**
  String get userBulkUpdateValidDateButton;

  /// Dialog title for the bulk valid-date update
  ///
  /// In en, this message translates to:
  /// **'Update Date'**
  String get userValidDateDialogTitle;

  /// Save-button label on the bulk valid-date update dialog
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get userValidDateDialogSaveButton;

  /// Date field label inside the bulk-update dialog
  ///
  /// In en, this message translates to:
  /// **'New Expiry Date'**
  String get userNewValidUntilLabel;

  /// Column header shown only for normal-type users
  ///
  /// In en, this message translates to:
  /// **'National ID No.'**
  String get userNationalIdColumnHeader;

  /// Side panel title / add button label when creating a new warning
  ///
  /// In en, this message translates to:
  /// **'New Warning'**
  String get warningFormAddTitle;

  /// Side panel title when editing an existing warning
  ///
  /// In en, this message translates to:
  /// **'Edit Warning'**
  String get warningFormEditTitle;

  /// Side panel subtitle when creating a new warning
  ///
  /// In en, this message translates to:
  /// **'Fill in the warning details'**
  String get warningFormAddSubtitle;

  /// Side panel subtitle when editing an existing warning
  ///
  /// In en, this message translates to:
  /// **'Update the warning details'**
  String get warningFormEditSubtitle;

  /// Text field label for the warning subject
  ///
  /// In en, this message translates to:
  /// **'Warning Subject'**
  String get warningFormSubjectLabel;

  /// Text field label for the warning body text
  ///
  /// In en, this message translates to:
  /// **'Warning Text'**
  String get warningFormTextLabel;

  /// Fallback screen title when the menu name is not provided
  ///
  /// In en, this message translates to:
  /// **'Warning Definition'**
  String get warningScreenTitle;

  /// Error message shown when the dashboard fails to load its data sections
  ///
  /// In en, this message translates to:
  /// **'The data could not be loaded. Please try again.'**
  String get dashboard_allSectionsLoadError;

  /// Ring-chart label for critically expiring items (under 7 days)
  ///
  /// In en, this message translates to:
  /// **'Critical\n(<7 days)'**
  String get dashboard_sktCriticalRingLabel;

  /// Ring-chart label for expiring-soon items (7-30 days)
  ///
  /// In en, this message translates to:
  /// **'Warning\n(7-30 days)'**
  String get dashboard_sktWarningRingLabel;

  /// Ring-chart label for already-expired items
  ///
  /// In en, this message translates to:
  /// **'Expired\nItems'**
  String get dashboard_sktExpiredRingLabel;

  /// Section header for the expiry-date (SKT) status panel on the dashboard
  ///
  /// In en, this message translates to:
  /// **'EXPIRY STATUS'**
  String get dashboard_sktStatusHeader;

  /// Badge showing the total item count in the SKT status panel
  ///
  /// In en, this message translates to:
  /// **'{count} Items'**
  String dashboard_sktItemCountBadge(int count);

  /// Small badge tag shown on expired SKT items
  ///
  /// In en, this message translates to:
  /// **'EXPIRED'**
  String get dashboard_sktExpiredTag;

  /// Inline hint link shown under an expired SKT item, offering to destroy it
  ///
  /// In en, this message translates to:
  /// **'destroy'**
  String get dashboard_sktDestroyHint;

  /// Label following the numeric days-remaining value on an SKT item
  ///
  /// In en, this message translates to:
  /// **'{days, plural, one{day left} other{days left}}'**
  String dashboard_sktDaysRemainingLabel(int days);

  /// Section header for the upcoming treatments panel on the dashboard
  ///
  /// In en, this message translates to:
  /// **'UPCOMING TREATMENTS'**
  String get dashboard_upcomingTreatmentsHeader;

  /// Badge showing the count of pending treatments
  ///
  /// In en, this message translates to:
  /// **'{count} Pending'**
  String dashboard_pendingTreatmentsBadge(int count);

  /// Filter chip label for pending treatments
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get dashboard_pendingFilterLabel;

  /// Filter chip label for urgent treatments
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get dashboard_urgentFilterLabel;

  /// Search field hint on the upcoming treatments panel
  ///
  /// In en, this message translates to:
  /// **'Search patient or medicine...'**
  String get dashboard_treatmentSearchHint;

  /// Button label to create a new treatment assignment
  ///
  /// In en, this message translates to:
  /// **'New Assignment'**
  String get dashboard_newAssignButton;

  /// Empty-state message for upcoming treatments when the 'all' filter is active
  ///
  /// In en, this message translates to:
  /// **'No treatment records found'**
  String get dashboard_noTreatmentsAllFilter;

  /// Empty-state message for upcoming treatments when the 'pending' filter is active
  ///
  /// In en, this message translates to:
  /// **'No pending treatments'**
  String get dashboard_noTreatmentsPendingFilter;

  /// Empty-state message for upcoming treatments when the 'urgent' filter is active
  ///
  /// In en, this message translates to:
  /// **'No urgent treatments'**
  String get dashboard_noTreatmentsUrgentFilter;

  /// Priority badge label for urgent treatments
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get dashboard_priorityUrgentLabel;

  /// Priority badge label for normal-priority treatments
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get dashboard_priorityNormalLabel;

  /// Priority badge label for routine treatments
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get dashboard_priorityRoutineLabel;

  /// Status badge label for a pending treatment
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get dashboard_statusPendingLabel;

  /// Status badge label for a dispensed/completed treatment
  ///
  /// In en, this message translates to:
  /// **'Dispensed'**
  String get dashboard_statusDoneLabel;

  /// Status badge label for a returned treatment item
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get dashboard_statusReturnedLabel;

  /// Placeholder message shown for a settings section that isn't implemented yet
  ///
  /// In en, this message translates to:
  /// **'{label} settings coming soon'**
  String settings_sectionComingSoon(String label);

  /// Stub message shown on the not-yet-implemented master cabinet refund screen
  ///
  /// In en, this message translates to:
  /// **'The master cabinet return screen isn\'t ready yet.'**
  String get refund_masterScreenNotReady;

  /// Error shown when the cabin's management/control board cannot be found during connection or drawer session setup
  ///
  /// In en, this message translates to:
  /// **'Management card not found.'**
  String get core_cabinConn_managerNotFoundError;

  /// Cabin connection state message shown when the connection to the cabin drops
  ///
  /// In en, this message translates to:
  /// **'Connection lost'**
  String get core_cabinConn_disconnectedError;

  /// Banner title instructing the operator to pull open an unlocked drawer
  ///
  /// In en, this message translates to:
  /// **'Open the drawer'**
  String get common_action_pullDrawerTitle;

  /// Banner subtitle instructing the operator to pull open an unlocked drawer
  ///
  /// In en, this message translates to:
  /// **'The lock is open, please pull it.'**
  String get common_action_pullDrawerSubtitle;

  /// Banner title shown while cubic drawer lids are opening
  ///
  /// In en, this message translates to:
  /// **'Opening lids'**
  String get masterDrawer_openingLidTitle;

  /// Banner subtitle shown while cubic drawer lids are opening
  ///
  /// In en, this message translates to:
  /// **'Preparing the cubic drawer lids.'**
  String get masterDrawer_openingLidSubtitle;

  /// Banner subtitle shown once the drawer is open and ready for the operation
  ///
  /// In en, this message translates to:
  /// **'Complete the operation and confirm.'**
  String get masterDrawer_readySubtitle;

  /// Banner title instructing the operator to close the drawer
  ///
  /// In en, this message translates to:
  /// **'Close the drawer'**
  String get common_action_closeDrawerTitle;

  /// Banner subtitle instructing the operator to close the drawer after confirming the operation
  ///
  /// In en, this message translates to:
  /// **'The operation is confirmed, please close it.'**
  String get common_action_closeDrawerSubtitle;

  /// Banner/status title shown once the drawer has been closed
  ///
  /// In en, this message translates to:
  /// **'Drawer closed'**
  String get common_action_drawerClosed;

  /// Banner subtitle shown once the drawer operation has fully completed
  ///
  /// In en, this message translates to:
  /// **'The operation is complete.'**
  String get common_action_operationCompletedSubtitle;

  /// Banner/status title shown when a drawer-related error occurs
  ///
  /// In en, this message translates to:
  /// **'Drawer error'**
  String get common_action_drawerError;

  /// Generic unexpected-error banner subtitle with the underlying error detail appended, used by master and mobile drawer session notifiers
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {error}'**
  String common_error_unexpectedWithDetail(Object error);

  /// Error message shown when a cubic drawer lid fails to open
  ///
  /// In en, this message translates to:
  /// **'The lid could not be opened: {error}'**
  String masterDrawer_lidOpenFailedError(Object error);

  /// Status message shown while the hardware device is being prepared before a drawer session starts
  ///
  /// In en, this message translates to:
  /// **'Preparing device...'**
  String get common_action_devicePreparing;

  /// Error message shown when connecting to the cabin fails, with the underlying error detail appended
  ///
  /// In en, this message translates to:
  /// **'Connection error: {error}'**
  String common_error_connectionErrorWithDetail(Object error);

  /// Status message shown while the drawer lock is being opened
  ///
  /// In en, this message translates to:
  /// **'Opening lock...'**
  String get common_action_lockOpening;

  /// Error message shown when opening the drawer lock fails, with the underlying error detail appended
  ///
  /// In en, this message translates to:
  /// **'The lock could not be opened: {error}'**
  String common_error_lockOpenFailedWithDetail(Object error);

  /// Subtitle showing the port number of the mobile drawer being operated
  ///
  /// In en, this message translates to:
  /// **'Drawer {port}'**
  String mobileDrawer_portSubtitle(int port);

  /// Status banner subtitle shown while a mobile drawer is open, prompting the operator to close it
  ///
  /// In en, this message translates to:
  /// **'Close the drawer to complete the operation.'**
  String get mobileDrawer_openedSubtitle;

  /// Status banner subtitle shown after a mobile drawer is closed, waiting for operator confirmation
  ///
  /// In en, this message translates to:
  /// **'Waiting for your confirmation'**
  String get mobileDrawer_closedSubtitle;

  /// Error message shown when connecting to the cabin's management board fails, with detail appended
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the management card: {error}'**
  String common_error_managerConnectFailedWithDetail(Object error);

  /// Error message shown when the drawer-open hardware command fails to send
  ///
  /// In en, this message translates to:
  /// **'Could not send the drawer-open command: {error}'**
  String mobileDrawer_openCommandFailedError(Object error);

  /// Error shown when reading the mobile drawer's hardware status times out
  ///
  /// In en, this message translates to:
  /// **'Timed out while reading the drawer status.'**
  String get mobileDrawer_statusTimeoutError;

  /// Error shown when the hardware doesn't confirm the drawer actually opened
  ///
  /// In en, this message translates to:
  /// **'Could not confirm that the drawer opened.'**
  String get mobileDrawer_openNotConfirmedError;

  /// Error shown when reading the mobile drawer's hardware status fails
  ///
  /// In en, this message translates to:
  /// **'An error occurred while reading the drawer status: {error}'**
  String mobileDrawer_statusReadError(Object error);

  /// Search field hint text in the master cabin patient picker panel
  ///
  /// In en, this message translates to:
  /// **'Search patient'**
  String get patientPicker_searchHint;

  /// Toggle button label for filtering to patients without an order
  ///
  /// In en, this message translates to:
  /// **'Without Order'**
  String get patientPicker_orderlessToggleLabel;

  /// Toggle button label for filtering to patients with an order
  ///
  /// In en, this message translates to:
  /// **'With Order'**
  String get patientPicker_orderedToggleLabel;

  /// Toggle button label for filtering to the current user's own patients
  ///
  /// In en, this message translates to:
  /// **'My Patients'**
  String get patientPicker_myPatientsToggleLabel;

  /// Hint text explaining how to create an urgent patient record
  ///
  /// In en, this message translates to:
  /// **'Create a record for an urgent patient not on the list.'**
  String get patientPicker_urgentPatientHint;

  /// Button label to create an urgent (unlisted) patient record
  ///
  /// In en, this message translates to:
  /// **'Create Urgent Patient'**
  String get patientPicker_createUrgentPatientButton;

  /// Success snackbar message shown after creating an urgent patient record
  ///
  /// In en, this message translates to:
  /// **'Urgent patient created.'**
  String get patientPicker_urgentPatientCreatedMessage;

  /// Hardware error shown when the serum cabinet card fails to enter slave communication mode
  ///
  /// In en, this message translates to:
  /// **'The serum card could not be set to slave mode...'**
  String get hw_cabinOps_serumSlaveModeError;

  /// Hardware error shown when a port has no configured solenoid
  ///
  /// In en, this message translates to:
  /// **'Port {port} has no solenoid (.no).'**
  String hw_cabinOps_solenoidMissingError(Object port);

  /// Hardware error shown when opening a cabin port fails, with the raw device response appended
  ///
  /// In en, this message translates to:
  /// **'Port {port} could not be opened. Response: {response}'**
  String hw_cabinOps_portOpenFailedError(Object port, Object response);

  /// Hardware error shown when opening a master cabin drawer fails, with technical addressing detail and raw device response
  ///
  /// In en, this message translates to:
  /// **'The master drawer could not be opened (row={row}, port={port}, drawer={drawer}). Response: {response}'**
  String hw_cabinOps_masterDrawerOpenFailedError(
    Object row,
    Object port,
    Object drawer,
    Object response,
  );

  /// Hardware error shown when opening a master serum drawer fails
  ///
  /// In en, this message translates to:
  /// **'The master serum drawer could not be opened (row={row}). Response: {response}'**
  String hw_cabinOps_masterSerumOpenFailedError(Object row, Object response);

  /// Detailed error shown when connecting to a serial port fails, with troubleshooting guidance
  ///
  /// In en, this message translates to:
  /// **'Could not connect to port {portName}. Make sure the device is connected and powered on, and that the port isn\'t in use by another application.'**
  String hw_serial_connectFailedDetailedError(String portName);

  /// Error shown when configuring a serial port fails
  ///
  /// In en, this message translates to:
  /// **'Port configuration failed ({portName}): {error}'**
  String hw_serial_portConfigFailedError(String portName, Object error);

  /// Suffix appended to a port-open-failed error when a specific system error is available
  ///
  /// In en, this message translates to:
  /// **'System error: {error}'**
  String hw_serial_systemErrorSuffix(Object error);

  /// Suffix appended to a port-open-failed error when no specific system error is available
  ///
  /// In en, this message translates to:
  /// **'The port may be in use by another application.'**
  String get hw_serial_portInUseSuffix;

  /// Error shown when reading from the serial port fails
  ///
  /// In en, this message translates to:
  /// **'Port read error: {error}'**
  String hw_serial_readErrorWithDetail(Object error);

  /// Status message used as the cancellation reason for pending commands while the serial connection restarts
  ///
  /// In en, this message translates to:
  /// **'Restarting the connection.'**
  String get hw_serial_reconnectingStatus;

  /// Error shown when connecting to the RFID reader fails
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the RFID reader: {error}'**
  String hw_rfid_connectFailedError(Object error);

  /// Error shown when the RFID reader returns an unparseable response
  ///
  /// In en, this message translates to:
  /// **'An invalid response was received.'**
  String get hw_rfid_invalidResponseError;

  /// Error shown when the RFID reader cannot be reached
  ///
  /// In en, this message translates to:
  /// **'The RFID reader could not be reached: {error}'**
  String hw_rfid_unreachableError(Object error);

  /// Error shown when the RFID reader connection test times out
  ///
  /// In en, this message translates to:
  /// **'The RFID connection test timed out.'**
  String get hw_rfid_testTimeoutError;

  /// Error shown when attempting to change RFID reader power settings during an active inventory scan
  ///
  /// In en, this message translates to:
  /// **'The power setting cannot be changed while inventory is active. Call stopInventory() first.'**
  String get hw_rfid_powerChangeBlockedError;

  /// Error shown when the RFID reader rejects a working-mode change command, with the raw hex status code
  ///
  /// In en, this message translates to:
  /// **'SetWorkingMode was rejected (status=0x{status})'**
  String hw_rfid_setModeRejectedError(Object status);

  /// Error shown when the RFID reader rejects an antenna configuration command, with the raw hex status code
  ///
  /// In en, this message translates to:
  /// **'SetWorkingAntenna was rejected (status=0x{status})'**
  String hw_rfid_setAntennaRejectedError(Object status);

  /// Hint suffix appended to the antenna-rejected error when the cause is a disconnected antenna port
  ///
  /// In en, this message translates to:
  /// **' (antenna connection error — one of the enabled ports is empty)'**
  String get hw_rfid_antennaConnFailedHint;

  /// Error shown when no RFID antenna could be connected on any port
  ///
  /// In en, this message translates to:
  /// **'Could not connect to any antenna (all ports are empty).'**
  String get hw_rfid_noAntennaConnectedError;

  /// Error shown when an RFID operation is attempted while the service is disconnected
  ///
  /// In en, this message translates to:
  /// **'The RFID service is not connected.'**
  String get hw_rfid_notConnectedError;

  /// Error shown when a new RFID command is issued while a previous one hasn't completed
  ///
  /// In en, this message translates to:
  /// **'The previous command is still awaiting a response.'**
  String get hw_rfid_commandPendingError;

  /// Error shown when an RFID command times out waiting for a response, with the raw hex command code
  ///
  /// In en, this message translates to:
  /// **'The command response timed out (cmd=0x{cmd}).'**
  String hw_rfid_commandTimeoutError(Object cmd);

  /// Generic RFID command error with the underlying error detail appended
  ///
  /// In en, this message translates to:
  /// **'Command error: {error}'**
  String hw_rfid_commandErrorWithDetail(Object error);

  /// Error shown by the mock RFID service (used only in the mock app flavor) when not connected
  ///
  /// In en, this message translates to:
  /// **'The mock RFID service is not connected.'**
  String get hw_rfid_mockNotConnectedError;

  /// Status badge label for a fatal/critical operation error
  ///
  /// In en, this message translates to:
  /// **'Critical Error'**
  String get operationStatus_fatalErrorLabel;

  /// Status badge label for a generic operation error
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get operationStatus_errorLabel;

  /// Status badge / rollback banner title shown while an operation is being rolled back
  ///
  /// In en, this message translates to:
  /// **'Rolling back the operation'**
  String get operationStatus_rollingBackLabel;

  /// Status badge label shown while an operation is being finalized
  ///
  /// In en, this message translates to:
  /// **'Finalizing the operation'**
  String get operationStatus_finalizingLabel;

  /// Status badge label shown when medicines remain in the cabinet after an operation
  ///
  /// In en, this message translates to:
  /// **'Medicines are still in the cabinet'**
  String get operationStatus_drugsStillInCabinetLabel;

  /// Status badge label for an incomplete or inconsistent operation result
  ///
  /// In en, this message translates to:
  /// **'Incomplete / Inconsistent'**
  String get operationStatus_incompleteLabel;

  /// Status badge label shown while an RFID scan is in progress
  ///
  /// In en, this message translates to:
  /// **'Scanning'**
  String get operationStatus_scanningLabel;

  /// Status badge label for an item reported as missing stock
  ///
  /// In en, this message translates to:
  /// **'Reported Missing'**
  String get operationStatus_reportedMissingLabel;

  /// Default title for the unplanned-movement warning banner
  ///
  /// In en, this message translates to:
  /// **'Unplanned movement detected'**
  String get operationBanner_unplannedMovementTitle;

  /// Message for the unplanned-movement warning banner, with the count of tags removed
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} tag was removed from the cabinet unexpectedly.} other{{count} tags were removed from the cabinet unexpectedly.}} A report will be sent to the pharmacy.'**
  String operationBanner_unplannedMovementMessage(num count);

  /// Title for the blocking banner shown when unexpected tags must be removed before continuing
  ///
  /// In en, this message translates to:
  /// **'Tag(s) not belonging to this cabinet detected'**
  String get operationBanner_unexpectedTagBlockingTitle;

  /// Title for the warning banner shown when unexpected tags are detected but don't block the operation
  ///
  /// In en, this message translates to:
  /// **'Unexpected medicine'**
  String get operationBanner_unexpectedTagWarningTitle;

  /// Message for the blocking unexpected-tag banner, listing how many tags must be removed
  ///
  /// In en, this message translates to:
  /// **'Remove the following {count, plural, one{{count} tag} other{{count} tags}} from the drawer to continue.'**
  String operationBanner_unexpectedTagBlockingMessage(num count);

  /// Message for the non-blocking unexpected-tag warning banner
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} tag} other{{count} tags}} not belonging to this cabinet {count, plural, one{was} other{were}} read. Please remove {count, plural, one{it} other{them}}.'**
  String operationBanner_unexpectedTagWarningMessage(num count);

  /// Title for the missing-stock warning banner shown during a cabin operation
  ///
  /// In en, this message translates to:
  /// **'Missing stock'**
  String get operationBanner_missingStockTitle;

  /// Message for the missing-stock warning banner, with the count of medicines not found
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} medicine was} other{{count} medicines were}} not found in the cabinet. It will be reported as missing stock when completed.'**
  String operationBanner_missingStockMessage(num count);

  /// Generic OK/dismiss button label used to close a dialog or banner
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_okButton;

  /// Search field hint text in the cabin patient picker list
  ///
  /// In en, this message translates to:
  /// **'Search patient, room, bed, or service...'**
  String get cabinPatientPicker_searchHint;

  /// Fallback text shown when a patient's full name is unavailable, used across cabin patient picker and dashboard treatment views
  ///
  /// In en, this message translates to:
  /// **'Unknown Patient'**
  String get common_unknownPatientFallback;

  /// Search field hint text in the generic patient list panel
  ///
  /// In en, this message translates to:
  /// **'Search patient...'**
  String get patientListPanel_searchHint;

  /// Suffix showing the maximum allowed quantity next to a dose value on the rx item card
  ///
  /// In en, this message translates to:
  /// **'/ max. {max} {unit}'**
  String rxItemCard_maxQuantitySuffix(String max, String unit);

  /// Banner message on the census extra-stock summary card
  ///
  /// In en, this message translates to:
  /// **'Excess stock will be reported at the end of the operation.'**
  String get census_extraStockSummaryMessage;

  /// Footer hint shown while the cabinet is being RFID-scanned, shared across census/intake/refill/unload
  ///
  /// In en, this message translates to:
  /// **'Scanning the cabinet, please wait'**
  String get cabinOperation_hint_scanning;

  /// Footer hint shown after census data is recorded, prompting the drawer to be closed
  ///
  /// In en, this message translates to:
  /// **'Recorded — close the drawer to finish the census'**
  String get census_hint_waitingClose;

  /// Footer hint shown when the census drawer closes before the operation completes
  ///
  /// In en, this message translates to:
  /// **'The drawer closed early — you can retry or cancel'**
  String get census_hint_closedEarly;

  /// Footer hint shown when an error occurs during a cabin operation, shared across census/intake/refill/unload
  ///
  /// In en, this message translates to:
  /// **'An error occurred — you can retry'**
  String get cabinOperation_hint_error;

  /// Footer hint shown when an unexpected RFID tag is detected during census/unload
  ///
  /// In en, this message translates to:
  /// **'There is a tag that doesn\'t belong in this cabinet — remove it to continue'**
  String get census_hint_unexpectedTag;

  /// Footer hint shown when the census is ready to be completed
  ///
  /// In en, this message translates to:
  /// **'Press the button to complete the census'**
  String get census_hint_readyToComplete;

  /// Footer button/instruction label to close the drawer, shared across census/unload
  ///
  /// In en, this message translates to:
  /// **'Close the Drawer'**
  String get cabinOperation_action_closeDrawer;

  /// Stat label / status badge for items that have been counted during census
  ///
  /// In en, this message translates to:
  /// **'Counted'**
  String get census_label_counted;

  /// Stat label for excess stock found during census
  ///
  /// In en, this message translates to:
  /// **'Excess'**
  String get census_label_excess;

  /// Stat label for tags that don't belong to the cabinet, shared across census/unload
  ///
  /// In en, this message translates to:
  /// **'Foreign'**
  String get cabinOperation_label_unexpectedTag;

  /// Error shown when an intake operation requires a witness login that hasn't been provided
  ///
  /// In en, this message translates to:
  /// **'A witness login is required.'**
  String get intake_error_witnessRequired;

  /// Error shown when none of the selected medicines have valid intake targets
  ///
  /// In en, this message translates to:
  /// **'The intake could not be performed for the selected medicines.'**
  String get intake_error_noValidTargets;

  /// Error shown when no drawer is found for the intake operation
  ///
  /// In en, this message translates to:
  /// **'No drawer was found to take from.'**
  String get intake_error_noDrawerFound;

  /// Hint shown on the intake operation card when the cabinet has no stock for the item
  ///
  /// In en, this message translates to:
  /// **'There is no stock in the cabinet'**
  String get intake_hint_noStock;

  /// Label showing the confirmed witness's name on the intake operation card
  ///
  /// In en, this message translates to:
  /// **'Witness: {name}'**
  String intake_label_witnessName(String name);

  /// Hint shown on the intake operation card when a witness hasn't logged in yet
  ///
  /// In en, this message translates to:
  /// **'Witness login required'**
  String get intake_hint_witnessRequired;

  /// Status label shown while an intake item's eligibility is being checked
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get intake_status_checking;

  /// Status label shown when an intake item is ready to be taken
  ///
  /// In en, this message translates to:
  /// **'Ready to take'**
  String get intake_status_readyToTake;

  /// Fallback status label shown when an intake item's eligibility check fails without a specific message
  ///
  /// In en, this message translates to:
  /// **'Check failed'**
  String get intake_status_checkFailed;

  /// Empty-state message shown before any medicine is selected on the master intake execution panel
  ///
  /// In en, this message translates to:
  /// **'Select a medicine to start the intake.'**
  String get intake_emptyState_selectMedicine;

  /// Label showing the count of distinct medicines in the current intake queue
  ///
  /// In en, this message translates to:
  /// **'{count} different medicines'**
  String intake_label_multiMedicine(int count);

  /// Label showing the amount taken during an intake operation
  ///
  /// In en, this message translates to:
  /// **'Taken: {amount} {unit}'**
  String intake_label_takenAmount(String amount, String unit);

  /// Field label for the manual count input during intake, showing the unit
  ///
  /// In en, this message translates to:
  /// **'Count ({unit})'**
  String intake_label_countFieldLabel(String unit);

  /// Hint shown on the intake execution panel explaining that confirming opens the next cell
  ///
  /// In en, this message translates to:
  /// **'The next cell will open once you confirm.'**
  String get intake_hint_nextCellOpens;

  /// Hint shown on the intake execution panel explaining that confirming closes the drawer
  ///
  /// In en, this message translates to:
  /// **'The drawer will close once you confirm.'**
  String get intake_hint_confirmCloses;

  /// Search field hint on the master intake selection panel
  ///
  /// In en, this message translates to:
  /// **'Search medicine (name / barcode)'**
  String get intake_hint_searchMedicine;

  /// Hint shown on the master intake selection panel while an intake is in progress
  ///
  /// In en, this message translates to:
  /// **'Intake in progress — selection is locked.'**
  String get intake_hint_selectionLocked;

  /// Hint explaining the automatic drawer queue ordering for intake
  ///
  /// In en, this message translates to:
  /// **'Drawers will open in the shortest-path order.'**
  String get intake_hint_autoQueueOrder;

  /// Informational message shown when an already-confirmed witness is auto-assigned to another medicine
  ///
  /// In en, this message translates to:
  /// **'{name} was also assigned as the witness for this medicine.'**
  String intake_info_witnessAutoAssigned(String name);

  /// Dialog title shown when the intake queue encounters an unrecoverable error
  ///
  /// In en, this message translates to:
  /// **'The intake could not be completed'**
  String get intake_error_queueTitle;

  /// Dialog message shown when the intake queue encounters an unrecoverable error, instructing the operator to undo their action; may have additional detail appended
  ///
  /// In en, this message translates to:
  /// **'Put the medicines back where you took them from.'**
  String get intake_error_queueMessage;

  /// Validation error shown when the operator tries to log in as their own witness
  ///
  /// In en, this message translates to:
  /// **'The user performing the operation cannot also witness it.'**
  String get intake_error_selfWitness;

  /// Success message shown after a witness successfully logs in
  ///
  /// In en, this message translates to:
  /// **'{name} was confirmed as the witness.'**
  String intake_success_witnessConfirmed(String name);

  /// Dialog title for the witness login dialog
  ///
  /// In en, this message translates to:
  /// **'Witness Verification'**
  String get intake_witnessDialog_title;

  /// Field label for the witness's username
  ///
  /// In en, this message translates to:
  /// **'Witness Username'**
  String get intake_witnessDialog_usernameLabel;

  /// Validation message for the witness username field
  ///
  /// In en, this message translates to:
  /// **'Enter a username'**
  String get intake_witnessDialog_usernameRequired;

  /// Field label for the witness's password
  ///
  /// In en, this message translates to:
  /// **'Witness Password'**
  String get intake_witnessDialog_passwordLabel;

  /// Validation message for the witness password field
  ///
  /// In en, this message translates to:
  /// **'Enter a password'**
  String get intake_witnessDialog_passwordRequired;

  /// Button label to confirm the witness login
  ///
  /// In en, this message translates to:
  /// **'Confirm Witness'**
  String get intake_witnessDialog_confirmButton;

  /// Informational text on the witness login dialog
  ///
  /// In en, this message translates to:
  /// **'Any staff member can witness this operation.'**
  String get intake_witnessDialog_anyoneInfo;

  /// Section header showing the count of authorized witnesses
  ///
  /// In en, this message translates to:
  /// **'Authorized Witnesses ({count})'**
  String intake_witnessDialog_authorizedWitnesses(int count);

  /// Footer hint shown when a fatal error occurs during intake/refill, with the error detail appended
  ///
  /// In en, this message translates to:
  /// **'A critical error occurred: {message}'**
  String cabinOperation_hint_fatalError(String message);

  /// Footer hint shown when the intake/refill operation has completed
  ///
  /// In en, this message translates to:
  /// **'Operation completed'**
  String get cabinOperation_hint_completed;

  /// Footer hint shown after intake/refill data is recorded, prompting the drawer to be closed
  ///
  /// In en, this message translates to:
  /// **'Recorded. Close the drawer to finish the operation'**
  String get cabinOperation_hint_waitingCloseGeneric;

  /// Footer hint shown when the intake/refill drawer closes before the operation completes
  ///
  /// In en, this message translates to:
  /// **'The drawer was closed. You can cancel or continue where you left off'**
  String get cabinOperation_hint_closedEarlyGeneric;

  /// Footer hint shown when the intake/refill operation is ready to be completed
  ///
  /// In en, this message translates to:
  /// **'Ready — you can complete the operation'**
  String get cabinOperation_hint_ready;

  /// Footer hint shown when an unexpected medicine is placed in the cabinet during intake
  ///
  /// In en, this message translates to:
  /// **'A medicine that shouldn\'t be in the cabinet was loaded, please remove it.'**
  String get intake_hint_extraPlacement;

  /// Footer hint instructing the operator to take medicines during intake
  ///
  /// In en, this message translates to:
  /// **'Take the medicines, then complete the operation'**
  String get intake_hint_takeItems;

  /// Generic primary action button label used on the mobile intake and refill footers
  ///
  /// In en, this message translates to:
  /// **'Complete the operation'**
  String get cabinOperation_action_completeGeneric;

  /// RFID status badge shown when an expected tag was not found, shared across intake/unload
  ///
  /// In en, this message translates to:
  /// **'Not Found'**
  String get rfidStatus_notFound;

  /// RFID status badge shown while a tag is being scanned, shared across intake/refill/unload
  ///
  /// In en, this message translates to:
  /// **'Scanning'**
  String get rfidStatus_scanning;

  /// Status badge shown when an intake item has no RFID tag
  ///
  /// In en, this message translates to:
  /// **'No RFID'**
  String get intake_label_noRfid;

  /// Stat label showing the count of selected items, shared across intake/refill dialogs
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get cabinOperation_label_selected;

  /// Stat label for the count of tags read inside the cabinet during intake
  ///
  /// In en, this message translates to:
  /// **'Read in Cabinet'**
  String get intake_label_readInCabin;

  /// Label showing the total number of RFID tags read
  ///
  /// In en, this message translates to:
  /// **'{count} tags'**
  String intake_label_tagCount(int count);

  /// Stat label for the count of items taken during intake
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get intake_label_takenCount;

  /// Stat label for unauthorized/unplanned takes detected during intake
  ///
  /// In en, this message translates to:
  /// **'Unauthorized Take'**
  String get intake_label_unauthorizedTake;

  /// Fixed error banner message shown on the mobile intake dialog when the operation cannot proceed
  ///
  /// In en, this message translates to:
  /// **'You can retry, or finish the operation by taking back the medicines you placed.'**
  String get intake_error_retryOrFinish;

  /// RFID status badge shown when a medicine has been placed in the drawer during refill
  ///
  /// In en, this message translates to:
  /// **'Placed'**
  String get refill_label_placed;

  /// Stat label for the count of medicines placed during refill
  ///
  /// In en, this message translates to:
  /// **'Placed'**
  String get refill_label_placedCount;

  /// Progress label showing placed-tag count out of expected count during refill
  ///
  /// In en, this message translates to:
  /// **'{done} / {total}'**
  String refill_label_placedProgress(Object done, Object total);

  /// Stat label for unplanned tag movements, shared across refill/unload dialogs
  ///
  /// In en, this message translates to:
  /// **'Unplanned'**
  String get cabinOperation_label_unplanned;

  /// Stat label for extra/unexpected tags detected during refill
  ///
  /// In en, this message translates to:
  /// **'Extra Tag'**
  String get refill_label_extraTag;

  /// Fixed error banner message shown on the mobile refill dialog
  ///
  /// In en, this message translates to:
  /// **'You can try again.'**
  String get refill_error_retry;

  /// Footer hint shown after unload data is recorded, prompting the drawer to be closed
  ///
  /// In en, this message translates to:
  /// **'Recorded — close the drawer to finish unloading'**
  String get unload_hint_waitingClose;

  /// Footer hint shown when the unload drawer closes before the operation completes
  ///
  /// In en, this message translates to:
  /// **'The drawer closed early — you can retry or cancel'**
  String get unload_hint_closedEarly;

  /// Footer hint shown when the unload operation is ready to be completed
  ///
  /// In en, this message translates to:
  /// **'Press the button to complete unloading'**
  String get unload_hint_readyToComplete;

  /// Status badge / stat label for items that have been unloaded
  ///
  /// In en, this message translates to:
  /// **'Unloaded'**
  String get unload_label_unloaded;

  /// Progress label showing unloaded-count out of expected total during unload
  ///
  /// In en, this message translates to:
  /// **'{done} / {total}'**
  String unload_label_unloadProgress(Object done, Object total);

  /// Step progress badge shown at the top of each setup wizard step
  ///
  /// In en, this message translates to:
  /// **'Step {step} / {total}'**
  String wizard_stepBadge(int step, int total);

  /// Title for wizard step 4 (drawer configuration)
  ///
  /// In en, this message translates to:
  /// **'Drawer Configuration'**
  String get wizard_step4Header;

  /// Subtitle for wizard step 4 when configuring a mobile cabinet
  ///
  /// In en, this message translates to:
  /// **'Define the mobile cabinet\'s drawer count, internal sections, and port connections.'**
  String get wizard_step4SubtitleMobile;

  /// Subtitle for wizard step 4 when configuring a master cabinet (auto-scanned)
  ///
  /// In en, this message translates to:
  /// **'The cabinet\'s internal structure will be read automatically from the device.'**
  String get wizard_step4SubtitleMaster;

  /// Shared 'Back' button label used by every setup wizard step footer
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get wizard_backButton;

  /// Idle-state button label to test the cabinet's serial connection
  ///
  /// In en, this message translates to:
  /// **'Test Cabinet Connection'**
  String get wizard_testCabinConnectionButton;

  /// Loading-state label shown while a connection test is running, shared between cabin and RFID test buttons
  ///
  /// In en, this message translates to:
  /// **'Testing…'**
  String get wizard_testingInProgress;

  /// Success-state label shown after a connection test succeeds, shared between cabin and RFID test buttons
  ///
  /// In en, this message translates to:
  /// **'Connection successful'**
  String get wizard_connectionSuccessLabel;

  /// Link to re-run a connection test after success, shared between cabin and RFID test buttons
  ///
  /// In en, this message translates to:
  /// **'Test again'**
  String get wizard_retestLink;

  /// Fallback error text for the cabinet connection test when no specific error is available
  ///
  /// In en, this message translates to:
  /// **'Could not establish a connection. Check the port settings.'**
  String get wizard_cabinConnectionErrorFallback;

  /// Idle-state button label to test the RFID antenna connection
  ///
  /// In en, this message translates to:
  /// **'Test Antenna Connection'**
  String get wizard_testRfidConnectionButton;

  /// RFID reader firmware version and power level shown after a successful connection test
  ///
  /// In en, this message translates to:
  /// **'· FW {firmwareVersion}  {power} dBm'**
  String wizard_rfidFirmwareInfo(String firmwareVersion, Object power);

  /// Fallback error text for the RFID connection test when no specific error is available
  ///
  /// In en, this message translates to:
  /// **'Could not establish a connection. Check the IP and port settings.'**
  String get wizard_rfidConnectionErrorFallback;

  /// Dropdown field label for the COM port selector in the setup wizard
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get wizard_portLabel;

  /// Toggle field label enabling the RFID configuration section in the setup wizard
  ///
  /// In en, this message translates to:
  /// **'Has RFID reader'**
  String get wizard_rfidReaderToggleLabel;

  /// Field label for the RFID reader's IP address
  ///
  /// In en, this message translates to:
  /// **'RFID IP Address'**
  String get wizard_rfidIpAddressLabel;

  /// Field label for the RFID reader's port number
  ///
  /// In en, this message translates to:
  /// **'RFID Port'**
  String get wizard_rfidPortFieldLabel;

  /// Hint text next to the drawer-count stepper in the setup wizard
  ///
  /// In en, this message translates to:
  /// **'1–8 drawers'**
  String get wizard_drawerCountRangeHint;

  /// Toggle title for applying the same drawer configuration to all drawers
  ///
  /// In en, this message translates to:
  /// **'All drawers have the same structure'**
  String get wizard_sameConfigToggleLabel;

  /// Toggle description shown when the same-configuration toggle is ON
  ///
  /// In en, this message translates to:
  /// **'All drawers use the same row/column configuration'**
  String get wizard_sameConfigToggleOnDesc;

  /// Toggle description shown when the same-configuration toggle is OFF
  ///
  /// In en, this message translates to:
  /// **'When off, row/column can be set separately for each drawer'**
  String get wizard_sameConfigToggleOffDesc;

  /// Summary text next to each collapsed drawer configuration card
  ///
  /// In en, this message translates to:
  /// **'{rowCount} rows · {totalCells} cells'**
  String wizard_drawerRowCellSummary(int rowCount, int totalCells);

  /// Label showing the port number assigned to a drawer
  ///
  /// In en, this message translates to:
  /// **'Port {portNumber}'**
  String wizard_drawerPortLabel(Object portNumber);

  /// Uppercase row label in the drawer row-configuration editor
  ///
  /// In en, this message translates to:
  /// **'ROW {rowIndex}'**
  String wizard_rowLabel(int rowIndex);

  /// Error shown when a hospital service's details fail to load in the setup wizard
  ///
  /// In en, this message translates to:
  /// **'Could not load the service details.'**
  String get wizard_serviceDetailsLoadError;

  /// Error shown when a station's details fail to load in the setup wizard
  ///
  /// In en, this message translates to:
  /// **'Could not load the station details.'**
  String get wizard_stationDetailsLoadError;

  /// Fallback error shown when the station list fails to load and no specific message is provided
  ///
  /// In en, this message translates to:
  /// **'Could not load the stations.'**
  String get wizard_stationsLoadErrorFallback;

  /// Empty-state message when the station list loads successfully but is empty
  ///
  /// In en, this message translates to:
  /// **'No registered stations were found.'**
  String get wizard_noStationsFoundMessage;

  /// Empty-state message when a selected station has no rooms defined
  ///
  /// In en, this message translates to:
  /// **'No rooms are defined for this station.'**
  String get wizard_noRoomsDefinedMessage;

  /// Badge chip showing the selected room count in the setup wizard
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} room} other{{count} rooms}}'**
  String wizard_selectedRoomCountBadge(int count);

  /// Fraction label showing how many rooms are selected out of the total
  ///
  /// In en, this message translates to:
  /// **'{selected}/{total}'**
  String wizard_roomSelectionFraction(int selected, int total);

  /// Footer hint shown when an unexpected medicine tag is placed during refill
  ///
  /// In en, this message translates to:
  /// **'A tag other than the selected medicines was placed, please remove it'**
  String get refill_hint_extraPlacement;

  /// Footer hint instructing the operator to place medicines during refill
  ///
  /// In en, this message translates to:
  /// **'Place the medicines, then complete the operation'**
  String get refill_hint_placeItems;

  /// Fallback UI message for NetworkUnavailableException, the base error-translation extension used by the manager app's generic error-display mixin
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server. Check your network connection.'**
  String get appException_networkUnavailable;

  /// Fallback UI message for TimeoutException
  ///
  /// In en, this message translates to:
  /// **'The server did not respond. Please try again.'**
  String get appException_timeout;

  /// Fallback UI message for ServiceException with a 5xx status code
  ///
  /// In en, this message translates to:
  /// **'Server error ({statusCode}). Please try again.'**
  String appException_serviceError5xx(Object statusCode);

  /// Fallback UI message for ServiceException with a non-5xx status code
  ///
  /// In en, this message translates to:
  /// **'The operation could not be completed ({statusCode}).'**
  String appException_serviceErrorOther(Object statusCode);

  /// Fallback UI message for MalformedDataException
  ///
  /// In en, this message translates to:
  /// **'Unexpected data was received from the server.'**
  String get appException_malformedData;

  /// Fallback UI message for EmptyResponseException
  ///
  /// In en, this message translates to:
  /// **'The server returned an empty response.'**
  String get appException_emptyResponse;

  /// Fallback UI message for ValidationException when a specific field is known
  ///
  /// In en, this message translates to:
  /// **'The {field} field is invalid.'**
  String appException_validationField(String field);

  /// Fallback UI message for ValidationException when no specific field is known
  ///
  /// In en, this message translates to:
  /// **'The information entered is invalid.'**
  String get appException_validationGeneric;

  /// Fallback UI message for MappingException
  ///
  /// In en, this message translates to:
  /// **'An error occurred while processing the data.'**
  String get appException_mapping;

  /// Fallback UI message for CacheException
  ///
  /// In en, this message translates to:
  /// **'Could not read local data.'**
  String get appException_cache;

  /// Fallback UI message for StaleCacheException
  ///
  /// In en, this message translates to:
  /// **'Cannot reach up-to-date data. Please check the connection.'**
  String get appException_staleCache;

  /// Fallback UI message for NotFoundException when the resource type is known
  ///
  /// In en, this message translates to:
  /// **'{resourceType} not found.'**
  String appException_notFoundWithType(String resourceType);

  /// Fallback UI message for NotFoundException when no resource type is known
  ///
  /// In en, this message translates to:
  /// **'Record not found.'**
  String get appException_notFoundGeneric;

  /// Fallback UI message for UnexpectedException (catch-all)
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get appException_unexpected;

  /// Fallback UI message for SerialPortException
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the serial port. Please contact technical service.'**
  String get appException_serialPort;

  /// Fixed fallback UI message shown for any CustomException, regardless of its own message
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred. Please try again later.'**
  String get appException_custom;

  /// APIManager error message when an API call returns 2xx with an empty body
  ///
  /// In en, this message translates to:
  /// **'The server returned an empty response'**
  String get dataError_emptyResponse;

  /// APIManager error message when the response parser throws
  ///
  /// In en, this message translates to:
  /// **'The response could not be processed'**
  String get dataError_malformedResponse;

  /// APIManager fallback error message for connect/receive/send timeouts
  ///
  /// In en, this message translates to:
  /// **'The request timed out'**
  String get dataError_requestTimeout;

  /// APIManager error message for connection errors (no network/DNS failure)
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the network'**
  String get dataError_networkUnavailable;

  /// APIManager fallback error message for a non-2xx HTTP response with no recognizable error field in the body — highest blast radius in the data layer
  ///
  /// In en, this message translates to:
  /// **'We encountered an error. Please try again later.'**
  String get dataError_genericApiError;

  /// APIManager error message when a request is cancelled
  ///
  /// In en, this message translates to:
  /// **'The request was cancelled'**
  String get dataError_requestCancelled;

  /// BaseRemoteDataSource fallback error message when the API response envelope says isSuccess:false with no message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get dataError_envelopeErrorFallback;

  /// Login error shown when the login endpoint returns 200 but no valid token
  ///
  /// In en, this message translates to:
  /// **'An invalid token response was received from the server'**
  String get authError_invalidTokenResponse;

  /// Login error shown when the token is obtained but fetching the current user fails
  ///
  /// In en, this message translates to:
  /// **'Could not retrieve user information'**
  String get authError_userInfoFetchFailed;

  /// Login error shown when the current-user payload is null
  ///
  /// In en, this message translates to:
  /// **'The user information returned was empty'**
  String get authError_userInfoEmpty;

  /// Fallback error message for the login-specific Dio error parser
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get authError_genericLoginError;

  /// Credential error shown by the mock login repository (mock app flavor only)
  ///
  /// In en, this message translates to:
  /// **'Incorrect username or password.'**
  String get authError_invalidCredentialsMock;

  /// Validation guard before deleting an active ingredient with a null/empty id
  ///
  /// In en, this message translates to:
  /// **'The ID of the active ingredient to delete cannot be empty'**
  String get dataGuard_deleteActiveIngredientIdEmpty;

  /// Validation guard before deleting a branch with a null/empty id
  ///
  /// In en, this message translates to:
  /// **'The ID of the branch to delete cannot be empty'**
  String get dataGuard_deleteBranchIdEmpty;

  /// Validation guard before deleting a cabinet with a null/empty id
  ///
  /// In en, this message translates to:
  /// **'The ID of the cabinet to delete cannot be empty'**
  String get dataGuard_deleteCabinIdEmpty;

  /// Validation guard before deleting a dosage form with a null/empty id
  ///
  /// In en, this message translates to:
  /// **'The ID of the dosage form to delete cannot be empty'**
  String get dataGuard_deleteDosageFormIdEmpty;

  /// Validation guard before deleting a drug class with a null/empty id
  ///
  /// In en, this message translates to:
  /// **'The ID of the drug class to delete cannot be empty'**
  String get dataGuard_deleteDrugClassIdEmpty;

  /// Validation guard before deleting a firm with a null/empty id
  ///
  /// In en, this message translates to:
  /// **'The ID of the firm to delete cannot be empty'**
  String get dataGuard_deleteFirmIdEmpty;

  /// Validation guard before deleting a drug type with a null/empty id
  ///
  /// In en, this message translates to:
  /// **'The ID of the drug type to delete cannot be empty'**
  String get dataGuard_deleteDrugTypeIdEmpty;

  /// Validation guard before deleting a hospitalization/admission with a null/empty id
  ///
  /// In en, this message translates to:
  /// **'The ID of the admission to delete cannot be empty'**
  String get dataGuard_deleteHospitalizationIdEmpty;

  /// Validation guard before deleting a kit with a null/empty id
  ///
  /// In en, this message translates to:
  /// **'The ID of the kit to delete cannot be empty'**
  String get dataGuard_deleteKitIdEmpty;

  /// Validation guard before deleting a kit content item with a null/empty id
  ///
  /// In en, this message translates to:
  /// **'The ID of the kit content to delete cannot be empty'**
  String get dataGuard_deleteKitContentIdEmpty;

  /// Validation guard before deleting a material type with a null/empty id
  ///
  /// In en, this message translates to:
  /// **'The ID of the material type to delete cannot be empty'**
  String get dataGuard_deleteMaterialTypeIdEmpty;

  /// Validation guard before deleting a medicine with a null/empty id
  ///
  /// In en, this message translates to:
  /// **'The ID of the medicine to delete cannot be empty'**
  String get dataGuard_deleteMedicineIdEmpty;

  /// Validation guard before deleting a patient with a null/empty id
  ///
  /// In en, this message translates to:
  /// **'The ID of the patient to delete cannot be empty'**
  String get dataGuard_deletePatientIdEmpty;

  /// Validation guard before deleting a role with a null/empty id
  ///
  /// In en, this message translates to:
  /// **'The ID of the role to delete cannot be empty'**
  String get dataGuard_deleteRoleIdEmpty;

  /// Validation guard before deleting a hospital service with a null/empty id
  ///
  /// In en, this message translates to:
  /// **'The ID of the service to delete cannot be empty'**
  String get dataGuard_deleteServiceIdEmpty;

  /// Validation guard before deleting a station with a null/empty id
  ///
  /// In en, this message translates to:
  /// **'The ID of the station to delete cannot be empty'**
  String get dataGuard_deleteStationIdEmpty;

  /// Validation guard before deleting a unit with a null/empty id
  ///
  /// In en, this message translates to:
  /// **'The ID of the unit to delete cannot be empty'**
  String get dataGuard_deleteUnitIdEmpty;

  /// Validation guard before deleting a warehouse with a null/empty id
  ///
  /// In en, this message translates to:
  /// **'The ID of the warehouse to delete cannot be empty'**
  String get dataGuard_deleteWarehouseIdEmpty;

  /// Validation guard before deleting a warning with a null/empty id
  ///
  /// In en, this message translates to:
  /// **'The ID of the warning to delete cannot be empty'**
  String get dataGuard_deleteWarningIdEmpty;

  /// Validation guard before updating a patient with a null id
  ///
  /// In en, this message translates to:
  /// **'The ID of the patient to update cannot be empty'**
  String get dataGuard_updatePatientIdEmpty;

  /// Validation guard before updating a hospitalization/admission with a null id
  ///
  /// In en, this message translates to:
  /// **'The ID of the admission to update cannot be empty'**
  String get dataGuard_updateHospitalizationIdEmpty;

  /// Generic error message with retry guidance, shared across several pharmed_core usecases (intake, refund)
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again later.'**
  String get core_genericErrorRetryMessage;

  /// Short generic error message, shared across several pharmed_core usecases (intake)
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get core_genericErrorShortMessage;

  /// Error shown when cabinet creation fails
  ///
  /// In en, this message translates to:
  /// **'An error occurred while creating the cabinet. Please try again later.'**
  String get cabinCore_createError;

  /// Error shown when no active cabinet is found for the visualizer
  ///
  /// In en, this message translates to:
  /// **'No active cabinet found'**
  String get cabinCore_activeCabinNotFound;

  /// Error shown when a mobile cabinet's design cannot be found
  ///
  /// In en, this message translates to:
  /// **'Mobile cabinet design not found'**
  String get cabinCore_mobileCabinDesignNotFound;

  /// Error shown when a cabinet's design cannot be found
  ///
  /// In en, this message translates to:
  /// **'Cabinet design not found'**
  String get cabinCore_cabinDesignNotFound;

  /// Error shown when cabinet creation succeeds but the server doesn't return an ID
  ///
  /// In en, this message translates to:
  /// **'The cabinet was created but its ID could not be retrieved.'**
  String get cabinCore_createdButIdMissing;

  /// Error shown during cabinet scan when definitions cannot be fetched
  ///
  /// In en, this message translates to:
  /// **'The definitions could not be retrieved.'**
  String get cabinCore_definitionsNotFound;

  /// Error shown during cabinet scan when no control cards are found
  ///
  /// In en, this message translates to:
  /// **'No cards were found.'**
  String get cabinCore_noCardsFound;

  /// Error shown during cabinet scan when no drawer matches
  ///
  /// In en, this message translates to:
  /// **'No matching drawer was found.'**
  String get cabinCore_noMatchingDrawerFound;

  /// Error shown when there is no cabinet design data to save
  ///
  /// In en, this message translates to:
  /// **'No data was found to save.'**
  String get cabinCore_designDataNotFound;

  /// Error shown when prescription creation fails
  ///
  /// In en, this message translates to:
  /// **'An error occurred while creating the prescription. Please try again later.'**
  String get prescriptionCore_createError;

  /// Error shown when assigning an RFID tag but none is detected
  ///
  /// In en, this message translates to:
  /// **'No RFID tag was found in the reader\'s range.'**
  String get prescriptionCore_rfidTagNotFoundInReader;

  /// Error shown when reading an RFID tag fails, with the underlying error detail appended
  ///
  /// In en, this message translates to:
  /// **'An error occurred while reading the RFID tag: {error}'**
  String prescriptionCore_rfidReadErrorWithDetail(Object error);

  /// Table column header for the role name
  ///
  /// In en, this message translates to:
  /// **'Role Name'**
  String get tableCore_roleNameColumn;

  /// Table column header for the warning subject
  ///
  /// In en, this message translates to:
  /// **'Warning Subject'**
  String get tableCore_warningSubjectColumn;

  /// Table column header for the warning text
  ///
  /// In en, this message translates to:
  /// **'Warning Text'**
  String get tableCore_warningTextColumn;

  /// Table column header for the warehouse code
  ///
  /// In en, this message translates to:
  /// **'Warehouse Code'**
  String get tableCore_warehouseCodeColumn;

  /// Table column header for the warehouse name
  ///
  /// In en, this message translates to:
  /// **'Warehouse Name'**
  String get tableCore_warehouseNameColumn;

  /// Table column header for the warehouse manager
  ///
  /// In en, this message translates to:
  /// **'Warehouse Manager'**
  String get tableCore_warehouseManagerColumn;

  /// Table column header for the dosage form's branch name (shared with the Branch entity's own name column)
  ///
  /// In en, this message translates to:
  /// **'Branch Name'**
  String get tableCore_dosageFormBranchColumn;

  /// Table column header for the firm's ID
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get tableCore_firmIdColumn;

  /// Table column header for the firm name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get tableCore_firmNameColumn;

  /// Table column header for the firm type
  ///
  /// In en, this message translates to:
  /// **'Firm Type'**
  String get tableCore_firmTypeColumn;

  /// Table column header for the firm's tax office
  ///
  /// In en, this message translates to:
  /// **'Tax Office'**
  String get tableCore_firmTaxOfficeColumn;

  /// Table column header for the firm's tax number
  ///
  /// In en, this message translates to:
  /// **'Tax No.'**
  String get tableCore_firmTaxNoColumn;

  /// Table column header for the kit name
  ///
  /// In en, this message translates to:
  /// **'Kit Name'**
  String get tableCore_kitNameColumn;

  /// Table column header for the kit content's material name
  ///
  /// In en, this message translates to:
  /// **'Material Name'**
  String get tableCore_kitContentMaterialNameColumn;

  /// Table column header for the kit content's piece count
  ///
  /// In en, this message translates to:
  /// **'Piece Count'**
  String get tableCore_kitContentPieceColumn;

  /// Table column header for the drug type name
  ///
  /// In en, this message translates to:
  /// **'Drug Type'**
  String get tableCore_drugTypeColumn;

  /// Table column header for the drug class name
  ///
  /// In en, this message translates to:
  /// **'Drug Class'**
  String get tableCore_drugClassColumn;

  /// Table column header for the material type name
  ///
  /// In en, this message translates to:
  /// **'Material Type'**
  String get tableCore_materialTypeColumn;

  /// Table column header for the station code
  ///
  /// In en, this message translates to:
  /// **'Station Code'**
  String get tableCore_stationCodeColumn;

  /// Table column header for the station name
  ///
  /// In en, this message translates to:
  /// **'Station Name'**
  String get tableCore_stationNameColumn;

  /// Table column header for the station's drug warehouse
  ///
  /// In en, this message translates to:
  /// **'Drug Warehouse'**
  String get tableCore_stationDrugWarehouseColumn;

  /// Table column header for the station's drug status
  ///
  /// In en, this message translates to:
  /// **'Drug'**
  String get tableCore_stationDrugColumn;

  /// Table column header for the station's medical consumable warehouse
  ///
  /// In en, this message translates to:
  /// **'Medical Consumable Warehouse'**
  String get tableCore_stationConsumableWarehouseColumn;

  /// Table column header for the station's medical consumable status
  ///
  /// In en, this message translates to:
  /// **'Medical Consumable'**
  String get tableCore_stationConsumableColumn;

  /// Table column header for the station's working type
  ///
  /// In en, this message translates to:
  /// **'Working Type'**
  String get tableCore_stationWorkingTypeColumn;

  /// Table column header for the hospitalization protocol number
  ///
  /// In en, this message translates to:
  /// **'Protocol No.'**
  String get tableCore_hospitalizationProtocolNoColumn;

  /// Table column header for the patient's national ID, on the hospitalization table
  ///
  /// In en, this message translates to:
  /// **'National ID No.'**
  String get tableCore_hospitalizationNationalIdColumn;

  /// Table column header for the patient name, on the hospitalization table
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get tableCore_hospitalizationPatientColumn;

  /// Table column header for the patient's national ID, on the patient row table
  ///
  /// In en, this message translates to:
  /// **'Patient National ID'**
  String get tableCore_patientRowNationalIdColumn;

  /// Table column header for the patient's full name, on the patient row table
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get tableCore_patientRowFullNameColumn;

  /// Table column header for the cabinet, on the inconsistency table
  ///
  /// In en, this message translates to:
  /// **'Cabinet'**
  String get tableCore_inconsistencyCabinColumn;

  /// Table column header for the row number, on the inconsistency table
  ///
  /// In en, this message translates to:
  /// **'Row No.'**
  String get tableCore_inconsistencyRowNoColumn;

  /// Table column header for the drawer cell, on the inconsistency table
  ///
  /// In en, this message translates to:
  /// **'Cell'**
  String get tableCore_inconsistencyCellColumn;

  /// Table column header for the expected quantity, on the inconsistency table
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get tableCore_inconsistencyExpectedColumn;

  /// Table column header for the counted quantity, on the inconsistency table
  ///
  /// In en, this message translates to:
  /// **'Counted Quantity'**
  String get tableCore_inconsistencyCountedColumn;

  /// Table column header for the transaction date, on the stock transaction table
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get tableCore_stockTransactionDateColumn;

  /// Table column header for the barcode, on the stock transaction table
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get tableCore_stockTransactionBarcodeColumn;

  /// Table column header for the transaction type, on the stock transaction table
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get tableCore_stockTransactionTypeColumn;

  /// Table column header for the quantity, on the stock transaction table
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get tableCore_stockTransactionQuantityColumn;

  /// Table column header for the quantity before the transaction, on the stock transaction table
  ///
  /// In en, this message translates to:
  /// **'Quantity Before Movement'**
  String get tableCore_stockTransactionPreviousQuantityColumn;

  /// Table column header for who performed the transaction, on the stock transaction table
  ///
  /// In en, this message translates to:
  /// **'Performed By'**
  String get tableCore_stockTransactionActorColumn;

  /// Shared table column header for a hospital service, used across station/hospitalization/patient row tables
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get tableCore_serviceColumn;

  /// Shared table column header for the admission date, used across hospitalization/patient row tables
  ///
  /// In en, this message translates to:
  /// **'Admission Date'**
  String get tableCore_admissionDateColumn;

  /// Shared table column header for the discharge date, used across hospitalization/patient row tables
  ///
  /// In en, this message translates to:
  /// **'Discharge Date'**
  String get tableCore_dischargeDateColumn;

  /// Shared table column header for material, used across inconsistency/stock transaction tables
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get tableCore_materialColumn;

  /// Shared enum label for the active status, used across most CRUD entities' Status enum
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get enumCore_statusActive;

  /// Shared enum label for the inactive/passive status, used across most CRUD entities' Status enum
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get enumCore_statusPassive;

  /// WarehouseType enum label for the main warehouse type
  ///
  /// In en, this message translates to:
  /// **'Main Warehouse'**
  String get enumCore_warehouseTypeMain;

  /// FirmType enum label for supplier
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get enumCore_firmTypeSupplier;

  /// FirmType enum label for customer
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get enumCore_firmTypeCustomer;

  /// FirmType enum label for manufacturer
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get enumCore_firmTypeManufacturer;

  /// WarningSubject enum label for an untimely/out-of-window purchase
  ///
  /// In en, this message translates to:
  /// **'Untimely Purchase'**
  String get enumCore_warningSubjectUntimelyPurchase;

  /// WarningSubject enum label for waste
  ///
  /// In en, this message translates to:
  /// **'Waste'**
  String get enumCore_warningSubjectWaste;

  /// WarningSubject enum label for inconsistency resolution
  ///
  /// In en, this message translates to:
  /// **'Inconsistency Resolution'**
  String get enumCore_warningSubjectInconsistencyResolution;

  /// WarningSubject enum label for disposal
  ///
  /// In en, this message translates to:
  /// **'Disposal'**
  String get enumCore_warningSubjectDisposal;

  /// Label for the Refill value of the StockTransactionKind enum (stock replenishment into the cabin)
  ///
  /// In en, this message translates to:
  /// **'Material Refill'**
  String get enumCore_stockTxKindRefill;

  /// Label for the StockOut value of the StockTransactionKind enum (material taken out of stock for use)
  ///
  /// In en, this message translates to:
  /// **'Stock Out'**
  String get enumCore_stockTxKindStockOut;

  /// Label for the CountConsistent value of the StockTransactionKind enum (physical census matches expected stock)
  ///
  /// In en, this message translates to:
  /// **'Consistent Count'**
  String get enumCore_stockTxKindConsistent;

  /// Label for the ReturnInward value of the StockTransactionKind enum (a returned item received back into the cabin)
  ///
  /// In en, this message translates to:
  /// **'Return Intake'**
  String get enumCore_stockTxKindReturnInward;

  /// Label for the Wastage value of the StockTransactionKind enum (material discarded/destroyed, e.g. expired or damaged)
  ///
  /// In en, this message translates to:
  /// **'Wastage'**
  String get enumCore_stockTxKindWastage;

  /// StockTransactionType enum label for incoming stock
  ///
  /// In en, this message translates to:
  /// **'Stock In'**
  String get enumCore_stockTxTypeIn;

  /// StockTransactionType enum label for outgoing stock
  ///
  /// In en, this message translates to:
  /// **'Stock Out'**
  String get enumCore_stockTxTypeOut;

  /// Label for the Return/Refund value of the StockTransactionKind enum (material returned out of the cabin)
  ///
  /// In en, this message translates to:
  /// **'Material Return'**
  String get enumCore_stockTxKindReturn;

  /// Label for the CountExcess value of the StockTransactionKind enum (physical census found more stock than expected)
  ///
  /// In en, this message translates to:
  /// **'Count Excess'**
  String get enumCore_stockTxKindExcess;

  /// Label for the CountShortage value of the StockTransactionKind enum (physical census found less stock than expected)
  ///
  /// In en, this message translates to:
  /// **'Count Shortage'**
  String get enumCore_stockTxKindShortage;

  /// Label for the Intake value of the StockTransactionKind enum (material received into the cabin, e.g. from purchasing)
  ///
  /// In en, this message translates to:
  /// **'Material Intake'**
  String get enumCore_stockTxKindPurchase;

  /// Label for the Unload value of the StockTransactionKind enum (material removed/emptied out of the cabin)
  ///
  /// In en, this message translates to:
  /// **'Material Unload'**
  String get enumCore_stockTxKindUnload;

  /// CountType enum label for no census configured
  ///
  /// In en, this message translates to:
  /// **'No Census'**
  String get enumCore_countTypeNone;

  /// CountType enum label for a normal (non-blind) census
  ///
  /// In en, this message translates to:
  /// **'Normal Census'**
  String get enumCore_countTypeNormal;

  /// CountType enum label for a blind census
  ///
  /// In en, this message translates to:
  /// **'Blind Census'**
  String get enumCore_countTypeBlind;

  /// ReturnType enum label for returning an item to its original location
  ///
  /// In en, this message translates to:
  /// **'Return to Origin'**
  String get enumCore_returnTypeToOrigin;

  /// ReturnType enum label for returning an item to the drawer
  ///
  /// In en, this message translates to:
  /// **'Return to Drawer'**
  String get enumCore_returnTypeToDrawer;

  /// ReturnType enum label for returning an item to the return box
  ///
  /// In en, this message translates to:
  /// **'Return to Return Box'**
  String get enumCore_returnTypeToReturnBox;

  /// ReturnType enum label for returning an item to the pharmacy
  ///
  /// In en, this message translates to:
  /// **'Return to Pharmacy'**
  String get enumCore_returnTypeToPharmacy;

  /// RequestType enum label for a normal request
  ///
  /// In en, this message translates to:
  /// **'Normal Request'**
  String get enumCore_requestTypeNormal;

  /// RequestType enum label for an urgent request
  ///
  /// In en, this message translates to:
  /// **'Urgent Request'**
  String get enumCore_requestTypeUrgent;

  /// PurchaseType enum label for allowing both ordered and orderless purchase
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get enumCore_purchaseTypeBoth;

  /// PrescriptionType enum label for a white (standard) prescription
  ///
  /// In en, this message translates to:
  /// **'White Prescription'**
  String get enumCore_prescriptionTypeWhite;

  /// PrescriptionType enum label for a serum white prescription
  ///
  /// In en, this message translates to:
  /// **'Serum (White Prescription)'**
  String get enumCore_prescriptionTypeSerumWhite;

  /// PrescriptionType enum label for a red (controlled) prescription
  ///
  /// In en, this message translates to:
  /// **'Red Prescription'**
  String get enumCore_prescriptionTypeRed;

  /// PrescriptionType enum label for a green prescription
  ///
  /// In en, this message translates to:
  /// **'Green Prescription'**
  String get enumCore_prescriptionTypeGreen;

  /// PrescriptionType enum label for an orange prescription
  ///
  /// In en, this message translates to:
  /// **'Orange Prescription'**
  String get enumCore_prescriptionTypeOrange;

  /// PrescriptionType enum label for a purple prescription
  ///
  /// In en, this message translates to:
  /// **'Purple Prescription'**
  String get enumCore_prescriptionTypePurple;

  /// RefillListStatus enum label for a refill list awaiting collection
  ///
  /// In en, this message translates to:
  /// **'To Collect'**
  String get enumCore_refillListStatusToCollect;

  /// RefillListStatus enum label for a collected refill list
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get enumCore_refillListStatusCollected;

  /// RefillListStatus enum label for a sent refill list
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get enumCore_refillListStatusSent;

  /// FillingType enum label for the minimum fill level
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get enumCore_fillingTypeMinimum;

  /// FillingType enum label for the critical fill level
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get enumCore_fillingTypeCritical;

  /// FillingType enum label for the maximum fill level
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get enumCore_fillingTypeMaximum;

  /// PatientFilterType enum label for patients whose order time has arrived
  ///
  /// In en, this message translates to:
  /// **'Order Time Reached'**
  String get enumCore_patientFilterOrderTimeReached;

  /// PatientFilterType enum label for all patients
  ///
  /// In en, this message translates to:
  /// **'All Patients'**
  String get enumCore_patientFilterAll;

  /// PatientFilterType enum label for patients whose time hasn't arrived yet
  ///
  /// In en, this message translates to:
  /// **'Time Not Reached Yet'**
  String get enumCore_patientFilterTimeNotReached;

  /// PatientFilterType enum label for patients whose time has passed
  ///
  /// In en, this message translates to:
  /// **'Time Passed'**
  String get enumCore_patientFilterTimePassed;

  /// PatientFilterType enum label for patients eligible for a return
  ///
  /// In en, this message translates to:
  /// **'Return Available'**
  String get enumCore_patientFilterReturnable;

  /// PatientFilterType enum label for patients eligible for waste/disposal entry
  ///
  /// In en, this message translates to:
  /// **'Waste/Disposal Available'**
  String get enumCore_patientFilterWasteDisposable;

  /// CabinType enum label for the standard cabinet type
  ///
  /// In en, this message translates to:
  /// **'Master Cabinet'**
  String get enumCore_cabinTypeStandard;

  /// CabinType enum label for a closet cabinet
  ///
  /// In en, this message translates to:
  /// **'Closet'**
  String get enumCore_cabinTypeCloset;

  /// CabinType enum label for a refrigerator cabinet
  ///
  /// In en, this message translates to:
  /// **'Refrigerator'**
  String get enumCore_cabinTypeFridge;

  /// CabinType enum label for an open closet cabinet
  ///
  /// In en, this message translates to:
  /// **'Open Closet'**
  String get enumCore_cabinTypeOpenCloset;

  /// CabinType enum label for a mobile cabinet
  ///
  /// In en, this message translates to:
  /// **'Mobile Cabinet'**
  String get enumCore_cabinTypeMobile;

  /// CabinType enum label for an external return cabinet
  ///
  /// In en, this message translates to:
  /// **'External Return Cabinet'**
  String get enumCore_cabinTypeExternalReturn;

  /// CabinType enum label for an open cabinet
  ///
  /// In en, this message translates to:
  /// **'Open Cabinet'**
  String get enumCore_cabinTypeOpen;

  /// CabinType enum label for a serum cabinet
  ///
  /// In en, this message translates to:
  /// **'Serum Cabinet'**
  String get enumCore_cabinTypeSerum;

  /// CabinOperationMode enum label for the drug-assignment operation
  ///
  /// In en, this message translates to:
  /// **'Drug Assignment'**
  String get enumCore_cabinOpModeAssignDrug;

  /// CabinOperationMode enum label for the drug-refill operation
  ///
  /// In en, this message translates to:
  /// **'Drug Refill'**
  String get enumCore_cabinOpModeRefill;

  /// CabinOperationMode enum label for the drug-census operation
  ///
  /// In en, this message translates to:
  /// **'Drug Census'**
  String get enumCore_cabinOpModeCensus;

  /// CabinOperationMode enum label for the drug-intake operation
  ///
  /// In en, this message translates to:
  /// **'Drug Intake'**
  String get enumCore_cabinOpModeIntake;

  /// CabinOperationMode enum label for the drawer-fault operation
  ///
  /// In en, this message translates to:
  /// **'Drawer Fault'**
  String get enumCore_cabinOpModeFault;

  /// CabinOperationMode enum label for the drug-unload operation
  ///
  /// In en, this message translates to:
  /// **'Drug Unload'**
  String get enumCore_cabinOpModeUnload;

  /// PermissionStatus enum label for a granted permission
  ///
  /// In en, this message translates to:
  /// **'Can'**
  String get enumCore_permissionCan;

  /// PermissionStatus enum label for a denied permission
  ///
  /// In en, this message translates to:
  /// **'Cannot'**
  String get enumCore_permissionCannot;

  /// Gender enum label for female
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get enumCore_genderFemale;

  /// Gender enum label for male
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get enumCore_genderMale;

  /// Gender enum label for unknown/unspecified
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get enumCore_genderUnknown;

  /// UserType enum label for a permanent/unlimited-duration user account
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get enumCore_userTypeUnlimited;

  /// AppMode/UserRole enum label for the admin mode/role
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get enumCore_appModeAdmin;

  /// AppMode enum label for management mode
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get enumCore_appModeManager;

  /// AppMode enum label for station mode
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get enumCore_appModeStation;

  /// UserRole enum label for the manager role
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get enumCore_userRoleManager;

  /// UserRole enum label for the station operator role
  ///
  /// In en, this message translates to:
  /// **'Station Operator'**
  String get enumCore_userRoleStationOperator;

  /// ParityBit enum label for no parity, serial port configuration
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get enumCore_parityBitNone;

  /// ParityBit enum label for even parity, serial port configuration
  ///
  /// In en, this message translates to:
  /// **'Even'**
  String get enumCore_parityBitEven;

  /// ParityBit enum label for odd parity, serial port configuration
  ///
  /// In en, this message translates to:
  /// **'Odd'**
  String get enumCore_parityBitOdd;

  /// CabinColor enum label for blue
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get enumCore_cabinColorBlue;

  /// CabinColor enum label for turquoise
  ///
  /// In en, this message translates to:
  /// **'Turquoise'**
  String get enumCore_cabinColorTurquoise;

  /// CabinColor enum label for green
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get enumCore_cabinColorGreen;

  /// CabinColor enum label for red
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get enumCore_cabinColorRed;

  /// CabinColor enum label for orange
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get enumCore_cabinColorOrange;

  /// CabinColor enum label for purple
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get enumCore_cabinColorPurple;

  /// CabinColor enum label for gray
  ///
  /// In en, this message translates to:
  /// **'Gray'**
  String get enumCore_cabinColorGray;

  /// CabinColor enum label for black
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get enumCore_cabinColorBlack;

  /// CabinColor enum label for white
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get enumCore_cabinColorWhite;

  /// Generic confirm button label for the base confirm-dialog widget
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_confirmButton;

  /// Generic warning dialog title
  ///
  /// In en, this message translates to:
  /// **'Warning!'**
  String get common_warningTitle;

  /// Title of the app-wide generic delete-confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dialog_deleteTitle;

  /// Default message of the generic delete-confirmation dialog when no item name is supplied
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get dialog_deleteDefaultMessage;

  /// Message of the generic delete-confirmation dialog when a specific item name is supplied
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{itemName}\"?\nThis action cannot be undone.'**
  String dialog_deleteItemMessage(String itemName);

  /// Confirm button label on the exit-with-unsaved-changes dialog
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get dialog_exitConfirmButtonText;

  /// Message on the exit-confirmation dialog when there are unsaved changes
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. If you exit, these changes will be lost.'**
  String get dialog_exitConfirmMessage;

  /// Message on the exit-confirmation dialog when there are no unsaved changes
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave this page?'**
  String get dialog_exitConfirmMessageNoChanges;

  /// Confirm button label on the discard-changes confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Yes, Discard'**
  String get dialog_confirmDiscardButton;

  /// Title of the logout confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get dialog_logoutTitle;

  /// Message on the logout confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account?'**
  String get dialog_logoutMessage;

  /// Default empty-state title for MedTable when no emptyWidget override is supplied
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get table_noDataTitle;

  /// Column header for the actions column in MedTable
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get table_actionsColumnHeader;

  /// Label preceding the active-filter chips in MedTable
  ///
  /// In en, this message translates to:
  /// **'Filters:'**
  String get table_activeFiltersLabel;

  /// Generic clear button label, used in table selection info and filter bars
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get common_clearButton;

  /// Label showing how many rows are selected in MedTable
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String table_selectedCountLabel(int count);

  /// Label showing how many values are selected for a specific column filter
  ///
  /// In en, this message translates to:
  /// **'{column}: {count} selected'**
  String table_columnSelectedCountLabel(String column, int count);

  /// Generic fallback label for a table column with no resolvable title
  ///
  /// In en, this message translates to:
  /// **'Column'**
  String get table_columnFallbackLabel;

  /// Button label to select all filtered rows, showing the count
  ///
  /// In en, this message translates to:
  /// **'Select All ({count})'**
  String table_selectAllCountLabel(int count);

  /// Short empty-state text in the table's column-filter popup
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get table_noResultsShort;

  /// Button label to apply a column filter selection, showing the count
  ///
  /// In en, this message translates to:
  /// **'Apply ({count})'**
  String table_applyCountLabel(int count);

  /// Generic apply button label in the table date-filter dialog
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get table_applyButton;

  /// Table footer label showing filtered vs total record count
  ///
  /// In en, this message translates to:
  /// **'{filtered} / {total} records'**
  String table_recordCountFiltered(int filtered, int total);

  /// Table footer label showing total record count with no filter applied
  ///
  /// In en, this message translates to:
  /// **'{total} records'**
  String table_recordCount(int total);

  /// Table pagination footer label showing the total record count
  ///
  /// In en, this message translates to:
  /// **'Total {total} records'**
  String table_totalRecordCount(int total);

  /// Tooltip on the table pagination previous-page button
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get table_prevPageTooltip;

  /// Tooltip on the table pagination next-page button
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get table_nextPageTooltip;

  /// Tooltip on the table toolbar's export button when rows are selected
  ///
  /// In en, this message translates to:
  /// **'Export Selected'**
  String get table_exportSelectedTooltip;

  /// Default title for the table's category side panel when no categoryTitle override is supplied
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get table_categoriesDefaultTitle;

  /// Fallback column title used when the legacy titles list has a null entry at a given index
  ///
  /// In en, this message translates to:
  /// **'Column {index}'**
  String table_columnFallback(int index);

  /// Quick date-range preset for yesterday in the table date filter
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateFilter_yesterday;

  /// Quick date-range preset for the last week
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get dateFilter_lastWeek;

  /// Quick date-range preset for this month
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get dateFilter_thisMonth;

  /// Quick date-range preset for the last 30 days
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get dateFilter_last30Days;

  /// Quick date-range preset to open the custom range picker
  ///
  /// In en, this message translates to:
  /// **'Set Custom Range...'**
  String get dateFilter_customRange;

  /// Button to clear the active date filter
  ///
  /// In en, this message translates to:
  /// **'Clear Filter'**
  String get dateFilter_clearFilter;

  /// Label shown when no date filter is applied
  ///
  /// In en, this message translates to:
  /// **'No Filter'**
  String get dateFilter_noFilter;

  /// Label shown when a custom date range is selected
  ///
  /// In en, this message translates to:
  /// **'Selected Range'**
  String get dateFilter_selectedRange;

  /// Title of the custom date-range picker dialog
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get dateFilter_selectRangeTitle;

  /// Label for the start date chip in the custom range picker
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get dateFilter_startDate;

  /// Label for the end date chip in the custom range picker
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get dateFilter_endDate;

  /// Generic placeholder text for dropdown/selection fields across the app, shown when nothing is selected
  ///
  /// In en, this message translates to:
  /// **'Please select'**
  String get common_selectPlaceholder;

  /// Label showing how many items are selected in a multi-selection dialog
  ///
  /// In en, this message translates to:
  /// **'{count} items selected'**
  String selectionDialog_selectedCount(int count);

  /// Empty-state text shown in a selection dialog before any item is chosen
  ///
  /// In en, this message translates to:
  /// **'No selection made'**
  String get selectionDialog_noSelection;

  /// Confirm button label on the generic selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectionDialog_confirmButton;

  /// Placeholder text for an empty date input field
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get dateField_placeholder;

  /// Help text on the native time picker when a specific day context is given
  ///
  /// In en, this message translates to:
  /// **'Select a time for {day}'**
  String timeField_helpTextWithDay(String day);

  /// Help text on the native time picker with no day context
  ///
  /// In en, this message translates to:
  /// **'Select a time'**
  String get timeField_helpText;

  /// Placeholder text for an empty time input field
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get timeField_placeholder;

  /// Title of the manual dose-entry numpad dialog
  ///
  /// In en, this message translates to:
  /// **'Enter {unit} Amount'**
  String doseStepper_manualEntryTitle(String unit);

  /// Default title for the generic numpad dialog
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get numpad_defaultTitle;

  /// Close button label on the on-screen keyboard
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get keyboard_closeButton;

  /// Enter/confirm key label on the on-screen keyboard
  ///
  /// In en, this message translates to:
  /// **'↵ OK'**
  String get keyboard_enterLabel;

  /// Dash key label on the on-screen keyboard's symbol row
  ///
  /// In en, this message translates to:
  /// **'— Dash'**
  String get keyboard_dashKeyLabel;

  /// Period key label on the on-screen keyboard's symbol row
  ///
  /// In en, this message translates to:
  /// **'. Period'**
  String get keyboard_periodKeyLabel;

  /// Shift key label on the on-screen keyboard
  ///
  /// In en, this message translates to:
  /// **'⇧ Shift'**
  String get keyboard_shiftLabel;

  /// Space bar label on the on-screen keyboard
  ///
  /// In en, this message translates to:
  /// **'SPACE'**
  String get keyboard_spaceLabel;

  /// Relative time label for data updated less than a minute ago
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get staleBanner_justNow;

  /// Relative time label for data updated N minutes ago
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String staleBanner_minutesAgo(int minutes);

  /// Relative time label for data updated N hours ago
  ///
  /// In en, this message translates to:
  /// **'{hours} hr ago'**
  String staleBanner_hoursAgo(int hours);

  /// Stale-data banner message when the operator may still proceed
  ///
  /// In en, this message translates to:
  /// **'Data is not up to date. '**
  String get staleBanner_dataStaleMessage;

  /// Stale-data banner message when the operator may not proceed (Class B safety-relevant)
  ///
  /// In en, this message translates to:
  /// **'Up-to-date data is unavailable. The operation cannot proceed. '**
  String get staleBanner_dataUnavailableMessage;

  /// Label showing the last-updated timestamp on the stale-data banner
  ///
  /// In en, this message translates to:
  /// **'Last updated: {time}'**
  String staleBanner_lastUpdatedLabel(String time);

  /// Status badge shown on the stale-data banner when the operation is blocked
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get staleBanner_blockedBadge;

  /// Chip label showing today's scheduled dose time
  ///
  /// In en, this message translates to:
  /// **'Today {time}'**
  String timeChip_today(String time);

  /// Chip label showing tomorrow's scheduled dose time
  ///
  /// In en, this message translates to:
  /// **'Tomorrow {time}'**
  String timeChip_tomorrow(String time);

  /// Lock button label in the cabin action bar
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get cabin_lockButton;

  /// Stat label for critical stock count in the cabin stats grid
  ///
  /// In en, this message translates to:
  /// **'Critical Stock'**
  String get cabin_criticalStockLabel;

  /// Sub-label under the critical stock stat, explaining the refill need
  ///
  /// In en, this message translates to:
  /// **'refill needed'**
  String get cabin_criticalStockSubLabel;

  /// Legend entry for normal fill level in the master cabin drawer panel
  ///
  /// In en, this message translates to:
  /// **'Normal stock'**
  String get cabin_legendFillNormal;

  /// Legend entry for a drawer needing refill in the master cabin drawer panel
  ///
  /// In en, this message translates to:
  /// **'Refill needed'**
  String get cabin_legendFillNeeded;

  /// Legend entry for a drawer needing urgent refill in the master cabin drawer panel
  ///
  /// In en, this message translates to:
  /// **'Urgent refill'**
  String get cabin_legendFillUrgent;

  /// Type badge for a serum drug group on the master cabin overview panel
  ///
  /// In en, this message translates to:
  /// **'Serum'**
  String get cabin_serumTypeLabel;

  /// Type badge abbreviation for a unit-dose drug group on the master cabin overview panel
  ///
  /// In en, this message translates to:
  /// **'Unit Dose'**
  String get cabin_unitDoseTypeLabel;

  /// Tooltip for the toggle on the refund screen that filters the list to show completed refund records
  ///
  /// In en, this message translates to:
  /// **'Show Completed'**
  String get refund_showCompletedTooltip;

  /// Tooltip for the toggle on the refund screen that filters the list to show incomplete (not yet completed) refund records
  ///
  /// In en, this message translates to:
  /// **'Show Incomplete'**
  String get refund_showIncompleteTooltip;

  /// Dashboard cabin sensor card title (temperature, humidity, battery)
  ///
  /// In en, this message translates to:
  /// **'Sensors'**
  String get dashboard_sensor_title;

  /// Cabin internal temperature label on the sensor card
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get dashboard_sensor_temperature;

  /// Cabin internal relative humidity label on the sensor card
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get dashboard_sensor_humidity;

  /// Cabin battery level label on the sensor card
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get dashboard_sensor_battery;

  /// No description provided for @dashboard_climate_title.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get dashboard_climate_title;

  /// No description provided for @dashboard_sensor_outOfRange.
  ///
  /// In en, this message translates to:
  /// **'Out of range'**
  String get dashboard_sensor_outOfRange;

  /// Header of the upcoming treatments panel on the client dashboard
  ///
  /// In en, this message translates to:
  /// **'Upcoming Treatments'**
  String get dashboard_upcomingTreatmentsPanelTitle;

  /// Badge in the upcoming treatments panel header showing how many treatments are scheduled
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} scheduled} other{{count} scheduled}}'**
  String dashboard_upcomingTreatmentsCountBadge(int count);

  /// Empty state shown in the upcoming treatments panel when no treatment is planned
  ///
  /// In en, this message translates to:
  /// **'No scheduled treatments'**
  String get dashboard_upcomingTreatmentsEmptyTitle;

  /// Shown under the time in a treatment row when the scheduled time has already passed
  ///
  /// In en, this message translates to:
  /// **'overdue'**
  String get dashboard_upcomingTreatmentsOverdueStatus;

  /// Header of the recent drug movements panel on the client dashboard
  ///
  /// In en, this message translates to:
  /// **'Drug Activity'**
  String get dashboard_drugActivityPanelTitle;

  /// Empty state shown in the drug activity panel when there are no recent movements
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get dashboard_drugActivityEmptyTitle;

  /// Section error shown in place of the drug activity panel when its request fails
  ///
  /// In en, this message translates to:
  /// **'Drug activity could not be loaded'**
  String get dashboard_activitiesLoadError;

  /// Header of the cabin telemetry panel showing temperature, humidity and battery
  ///
  /// In en, this message translates to:
  /// **'Cabin Climate'**
  String get dashboard_telemetryPanelTitle;

  /// Shown in the telemetry panel header while sensor polling is suspended during a cabin operation
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get dashboard_telemetryPausedStatus;

  /// Label of the active patients card in the dashboard KPI strip
  ///
  /// In en, this message translates to:
  /// **'Active Patients'**
  String get dashboard_kpiActivePatientsLabel;

  /// Label of the completed operations card in the dashboard KPI strip
  ///
  /// In en, this message translates to:
  /// **'Completed Operations'**
  String get dashboard_kpiCompletedOperationsLabel;

  /// Label of the pending prescriptions card in the dashboard KPI strip
  ///
  /// In en, this message translates to:
  /// **'Pending Prescriptions'**
  String get dashboard_kpiPendingPrescriptionsLabel;

  /// Label of the critical alerts card in the dashboard KPI strip
  ///
  /// In en, this message translates to:
  /// **'Critical Alerts'**
  String get dashboard_kpiCriticalAlertsLabel;

  /// Generic button that opens the full list behind a summary panel
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get common_seeAllButton;

  /// Generic fallback shown when a name (patient, medicine, user) is missing
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get common_unknownFallback;

  /// Relative time shown for events that happened less than a minute ago
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get common_justNowStatus;

  /// Relative time for events within the last hour, used in activity lists
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String common_minutesAgoStatus(int count);

  /// Relative time for events within the last day, used in activity lists
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String common_hoursAgoStatus(int count);

  /// Relative time for events older than a day, used in activity lists
  ///
  /// In en, this message translates to:
  /// **'{count} d ago'**
  String common_daysAgoStatus(int count);

  /// Countdown shown next to a treatment scheduled within the next hour
  ///
  /// In en, this message translates to:
  /// **'in {count} min'**
  String common_minutesRemainingStatus(int count);

  /// Countdown shown next to a treatment scheduled within the next day
  ///
  /// In en, this message translates to:
  /// **'in {count} h'**
  String common_hoursRemainingStatus(int count);

  /// Countdown shown next to a treatment scheduled more than a day ahead
  ///
  /// In en, this message translates to:
  /// **'in {count} d'**
  String common_daysRemainingStatus(int count);

  /// Subtitle under the medicine selection screen title, guiding the user to pick cells
  ///
  /// In en, this message translates to:
  /// **'Select the cells to fill. Low-stock cells are marked.'**
  String get refill_hint_selectSlots;

  /// Form header for a unit-dose drawer where all cells are filled in one list
  ///
  /// In en, this message translates to:
  /// **'Fill Cells'**
  String get refill_title_fillCells;

  /// Inline validation shown on a cell input when filling quantity is entered but expiry date is missing
  ///
  /// In en, this message translates to:
  /// **'Expiry date required'**
  String get refill_hint_miadRequired;

  /// Full-screen title while the physical drawer is being opened by the motor
  ///
  /// In en, this message translates to:
  /// **'Opening drawer…'**
  String get refill_status_openingTitle;

  /// Full-screen subtitle while the physical drawer is being opened
  ///
  /// In en, this message translates to:
  /// **'Please wait, the physical drawer is opening.'**
  String get refill_status_openingBody;

  /// Full-screen title when the lock is released and the drawer is waiting to be pulled open
  ///
  /// In en, this message translates to:
  /// **'Pull the drawer'**
  String get refill_status_waitingPullTitle;

  /// Full-screen subtitle when the drawer lock is released and waiting for the user to pull
  ///
  /// In en, this message translates to:
  /// **'The lock is released. Pull the drawer to continue.'**
  String get refill_status_waitingPullBody;

  /// Full-screen title while a cubic drawer inner lid is being opened
  ///
  /// In en, this message translates to:
  /// **'Opening cell…'**
  String get refill_status_openingLidTitle;

  /// Full-screen subtitle while a cubic drawer inner lid is being opened
  ///
  /// In en, this message translates to:
  /// **'Please wait, the cell lid is opening.'**
  String get refill_status_openingLidBody;

  /// Status badge on a cell card when current stock is above the minimum threshold
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get refill_status_stockOk;

  /// Status badge on a cell card when current stock is at or below the minimum threshold
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get refill_status_stockLow;

  /// Status badge on a cell card when current stock is at or below the critical threshold
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get refill_status_stockCritical;

  /// Confirmation dialog title when the user taps Stop during an active refill queue
  ///
  /// In en, this message translates to:
  /// **'Stop the refill?'**
  String get refill_stop_confirmTitle;

  /// Confirmation dialog body explaining the consequence of stopping an active refill queue
  ///
  /// In en, this message translates to:
  /// **'If you stop, the open drawer will be locked and this refill will be marked as partially completed. Entered counts and fill amounts are kept, but you cannot resume — you must start a new refill.'**
  String get refill_stop_confirmMessage;

  /// Confirm button on the stop-refill confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Yes, Stop'**
  String get refill_stop_confirmYes;

  /// PrescriptionMovementType.pendingApproval — status label shown in badges and lists
  ///
  /// In en, this message translates to:
  /// **'Pending Approval'**
  String get enumCore_prescriptionMovementPendingApprovalLabel;

  /// PrescriptionMovementType.purchasePending — status label
  ///
  /// In en, this message translates to:
  /// **'Purchase Pending'**
  String get enumCore_prescriptionMovementPurchasePendingLabel;

  /// PrescriptionMovementType.applied — status label
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get enumCore_prescriptionMovementAppliedLabel;

  /// PrescriptionMovementType.returned — status label
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get enumCore_prescriptionMovementReturnedLabel;

  /// PrescriptionMovementType.wastaged — status label
  ///
  /// In en, this message translates to:
  /// **'Wasted'**
  String get enumCore_prescriptionMovementWastagedLabel;

  /// PrescriptionMovementType.destructed — status label
  ///
  /// In en, this message translates to:
  /// **'Destructed'**
  String get enumCore_prescriptionMovementDestructedLabel;

  /// PrescriptionMovementType.cancelled — status label
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get enumCore_prescriptionMovementCancelledLabel;

  /// PrescriptionMovementType.rejected — status label
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get enumCore_prescriptionMovementRejectedLabel;

  /// PrescriptionMovementType.filledWaiting — status label
  ///
  /// In en, this message translates to:
  /// **'Awaiting Fill'**
  String get enumCore_prescriptionMovementFilledWaitingLabel;

  /// PrescriptionMovementType.returnPending — status label
  ///
  /// In en, this message translates to:
  /// **'Return Pending'**
  String get enumCore_prescriptionMovementReturnPendingLabel;

  /// PrescriptionMovementType.unloaded — status label
  ///
  /// In en, this message translates to:
  /// **'Unloaded'**
  String get enumCore_prescriptionMovementUnloadedLabel;

  /// PrescriptionMovementType.shortageReported — status label
  ///
  /// In en, this message translates to:
  /// **'Shortage Reported'**
  String get enumCore_prescriptionMovementShortageReportedLabel;

  /// PrescriptionMovementType.replenishmentPending — status label
  ///
  /// In en, this message translates to:
  /// **'Replenishment Pending'**
  String get enumCore_prescriptionMovementReplenishmentPendingLabel;

  /// PrescriptionMovementType.pendingApproval — actor label (who performed the action)
  ///
  /// In en, this message translates to:
  /// **'Created By'**
  String get enumCore_prescriptionMovementPendingApprovalActorLabel;

  /// PrescriptionMovementType.purchasePending — actor label
  ///
  /// In en, this message translates to:
  /// **'Filled By'**
  String get enumCore_prescriptionMovementPurchasePendingActorLabel;

  /// PrescriptionMovementType.applied — actor label
  ///
  /// In en, this message translates to:
  /// **'Applied By'**
  String get enumCore_prescriptionMovementAppliedActorLabel;

  /// PrescriptionMovementType.returned — actor label
  ///
  /// In en, this message translates to:
  /// **'Returned By'**
  String get enumCore_prescriptionMovementReturnedActorLabel;

  /// PrescriptionMovementType.wastaged — actor label
  ///
  /// In en, this message translates to:
  /// **'Wasted By'**
  String get enumCore_prescriptionMovementWastagedActorLabel;

  /// PrescriptionMovementType.destructed — actor label
  ///
  /// In en, this message translates to:
  /// **'Destructed By'**
  String get enumCore_prescriptionMovementDestructedActorLabel;

  /// PrescriptionMovementType.cancelled — actor label
  ///
  /// In en, this message translates to:
  /// **'Cancelled By'**
  String get enumCore_prescriptionMovementCancelledActorLabel;

  /// PrescriptionMovementType.rejected — actor label
  ///
  /// In en, this message translates to:
  /// **'Rejected By'**
  String get enumCore_prescriptionMovementRejectedActorLabel;

  /// PrescriptionMovementType.filledWaiting — actor label
  ///
  /// In en, this message translates to:
  /// **'Approved By'**
  String get enumCore_prescriptionMovementFilledWaitingActorLabel;

  /// PrescriptionMovementType.returnPending — actor label
  ///
  /// In en, this message translates to:
  /// **'Return Requested By'**
  String get enumCore_prescriptionMovementReturnPendingActorLabel;

  /// PrescriptionMovementType.unloaded — actor label
  ///
  /// In en, this message translates to:
  /// **'Unloaded By'**
  String get enumCore_prescriptionMovementUnloadedActorLabel;

  /// PrescriptionMovementType.shortageReported — actor label
  ///
  /// In en, this message translates to:
  /// **'Shortage Reported By'**
  String get enumCore_prescriptionMovementShortageReportedActorLabel;

  /// PrescriptionMovementType.replenishmentPending — actor label
  ///
  /// In en, this message translates to:
  /// **'Replenishment Approved By'**
  String get enumCore_prescriptionMovementReplenishmentPendingActorLabel;

  /// Status label for a prescription item that has been redirected to another station's cabin for intake
  ///
  /// In en, this message translates to:
  /// **'Redirected'**
  String get enumCore_prescriptionMovementRedirectedLabel;

  /// Actor label describing who performed the redirect action, shown in the movement history block
  ///
  /// In en, this message translates to:
  /// **'Redirected by'**
  String get enumCore_prescriptionMovementRedirectedActorLabel;

  /// Action label describing the redirect transition, shown in the movement history block
  ///
  /// In en, this message translates to:
  /// **'Redirected'**
  String get enumCore_prescriptionMovementRedirectedActionLabel;

  /// PrescriptionMovementType.pendingApproval — action label (what was done to reach this state)
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get enumCore_prescriptionMovementPendingApprovalActionLabel;

  /// PrescriptionMovementType.purchasePending — action label
  ///
  /// In en, this message translates to:
  /// **'Filled'**
  String get enumCore_prescriptionMovementPurchasePendingActionLabel;

  /// PrescriptionMovementType.applied — action label
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get enumCore_prescriptionMovementAppliedActionLabel;

  /// PrescriptionMovementType.returned — action label
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get enumCore_prescriptionMovementReturnedActionLabel;

  /// PrescriptionMovementType.wastaged — action label
  ///
  /// In en, this message translates to:
  /// **'Wasted'**
  String get enumCore_prescriptionMovementWastagedActionLabel;

  /// PrescriptionMovementType.destructed — action label
  ///
  /// In en, this message translates to:
  /// **'Destructed'**
  String get enumCore_prescriptionMovementDestructedActionLabel;

  /// PrescriptionMovementType.cancelled — action label
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get enumCore_prescriptionMovementCancelledActionLabel;

  /// PrescriptionMovementType.rejected — action label
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get enumCore_prescriptionMovementRejectedActionLabel;

  /// PrescriptionMovementType.filledWaiting — action label
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get enumCore_prescriptionMovementFilledWaitingActionLabel;

  /// PrescriptionMovementType.returnPending — action label
  ///
  /// In en, this message translates to:
  /// **'Return Requested'**
  String get enumCore_prescriptionMovementReturnPendingActionLabel;

  /// PrescriptionMovementType.unloaded — action label
  ///
  /// In en, this message translates to:
  /// **'Unloaded'**
  String get enumCore_prescriptionMovementUnloadedActionLabel;

  /// PrescriptionMovementType.shortageReported — action label
  ///
  /// In en, this message translates to:
  /// **'Shortage Reported'**
  String get enumCore_prescriptionMovementShortageReportedActionLabel;

  /// PrescriptionMovementType.replenishmentPending — action label
  ///
  /// In en, this message translates to:
  /// **'Replenishment Approved'**
  String get enumCore_prescriptionMovementReplenishmentPendingActionLabel;

  /// Table column header — user's first name, user auth management screen
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get userAuth_table_firstNameColumn;

  /// Table column header — user's last name, user auth management screen
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get userAuth_table_lastNameColumn;

  /// Table column header — user's profession/occupation type, user auth management screen
  ///
  /// In en, this message translates to:
  /// **'Occupation Type'**
  String get userAuth_table_occupationTypeColumn;

  /// Table column header — certificate/auth expiry date, user auth management screen
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get userAuth_table_expiryDateColumn;

  /// Table column header — days remaining until expiry, user auth management screen
  ///
  /// In en, this message translates to:
  /// **'Remaining Days'**
  String get userAuth_table_remainingDaysColumn;

  /// Table column header — current auth status of the user, user auth management screen
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get userAuth_table_statusColumn;

  /// Table column header — medicine barcode, medicine management screen
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get medicine_table_barcodeColumn;

  /// Table column header — ATC code (drugs only, consumables show dash), medicine management screen
  ///
  /// In en, this message translates to:
  /// **'ATC Code'**
  String get medicine_table_atcCodeColumn;

  /// Table column header — medicine name, medicine management screen
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get medicine_table_nameColumn;

  /// Table column header — drug or medical consumable type label, medicine management screen
  ///
  /// In en, this message translates to:
  /// **'Material Type'**
  String get medicine_table_materialTypeColumn;

  /// Table column header — prescription type (drugs only, consumables show dash), medicine management screen
  ///
  /// In en, this message translates to:
  /// **'Prescription Type'**
  String get medicine_table_prescriptionTypeColumn;

  /// Table column header — counting method type, medicine management screen
  ///
  /// In en, this message translates to:
  /// **'Count Type'**
  String get medicine_table_countTypeColumn;

  /// Table column header — acquisition/purchase method, medicine management screen
  ///
  /// In en, this message translates to:
  /// **'Purchase Type'**
  String get medicine_table_purchaseTypeColumn;

  /// Table column header — return method type, medicine management screen
  ///
  /// In en, this message translates to:
  /// **'Return Type'**
  String get medicine_table_returnTypeColumn;

  /// Table column header — active/inactive status, medicine management screen
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get medicine_table_statusColumn;

  /// Label for Medicine union type — drug variant
  ///
  /// In en, this message translates to:
  /// **'Drug'**
  String get enumCore_medicineTypeDrug;

  /// Label for Medicine union type — medical consumable variant
  ///
  /// In en, this message translates to:
  /// **'Medical Consumable'**
  String get enumCore_medicineTypeConsumable;

  /// Table column header — patient ID/code, refund management screen
  ///
  /// In en, this message translates to:
  /// **'Patient Code'**
  String get refund_table_patientCodeColumn;

  /// Table column header — patient full name, refund management screen
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get refund_table_patientColumn;

  /// Table column header — user who created the refund record, refund management screen
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get refund_table_userColumn;

  /// Table column header — medicine/material name, refund management screen
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get refund_table_medicineColumn;

  /// Table column header — refund quantity (numeric), refund management screen
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get refund_table_quantityColumn;

  /// Table column header — refund creation date, refund management screen
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get refund_table_dateColumn;

  /// Table column header — user who accepted/approved the refund, refund management screen
  ///
  /// In en, this message translates to:
  /// **'Approved By'**
  String get refund_table_approvedUserColumn;

  /// Table column header — date the refund was approved, refund management screen
  ///
  /// In en, this message translates to:
  /// **'Approval Date'**
  String get refund_table_approvedDateColumn;

  /// Table column header — refund description/note, completed refunds table
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get refund_table_descriptionColumn;

  /// Table column header — full name of the user, authorization management screen
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get authorization_table_userColumn;

  /// Table column header — role name assigned to user, authorization management screen
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get authorization_table_roleColumn;

  /// Table column header — whether the user uses encrypted login, authorization management screen
  ///
  /// In en, this message translates to:
  /// **'Encrypted Login'**
  String get authorization_table_encryptedLoginColumn;

  /// Table column header — whether the user record is soft-deleted, authorization management screen
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get authorization_table_isDeletedColumn;

  /// Table column header — count of extra authorizations granted to user, authorization management screen
  ///
  /// In en, this message translates to:
  /// **'Extra Authorization'**
  String get authorization_table_extraAuthCountColumn;

  /// Table column header — record date and time, cabin temperature screen
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get cabinTemperature_table_dateColumn;

  /// Table column header — cabin name, cabin temperature screen
  ///
  /// In en, this message translates to:
  /// **'Cabin'**
  String get cabinTemperature_table_cabinColumn;

  /// Table column header — inside temperature value in °C, cabin temperature screen
  ///
  /// In en, this message translates to:
  /// **'Inside Temperature'**
  String get cabinTemperature_table_insideTempColumn;

  /// Table column header — outside temperature value in °C, cabin temperature screen
  ///
  /// In en, this message translates to:
  /// **'Outside Temperature'**
  String get cabinTemperature_table_outsideTempColumn;

  /// Table column header — humidity percentage, cabin temperature screen
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get cabinTemperature_table_humidityColumn;

  /// Tooltip — filter button to show only records exceeding thresholds, cabin temperature screen
  ///
  /// In en, this message translates to:
  /// **'Show Out of Range'**
  String get cabinTemperature_action_showOutOfRange;

  /// Tooltip — filter button to show all records (reset out-of-range filter), cabin temperature screen
  ///
  /// In en, this message translates to:
  /// **'Show All'**
  String get cabinTemperature_action_showAll;

  /// Table column header — medicine barcode, expired items screen
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get expiredItems_table_barcodeColumn;

  /// Table column header — medicine/material name, expired items screen
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get expiredItems_table_medicineColumn;

  /// Table column header — cabin name, expired items screen
  ///
  /// In en, this message translates to:
  /// **'Cabin'**
  String get expiredItems_table_cabinColumn;

  /// Table column header — shelf/compartment location, expired items screen
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get expiredItems_table_locationColumn;

  /// Table column header — minimum stock quantity with unit, expired items screen
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get expiredItems_table_minQuantityColumn;

  /// Table column header — maximum stock quantity with unit, expired items screen
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get expiredItems_table_maxQuantityColumn;

  /// Table column header — critical stock threshold quantity with unit, expired items screen
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get expiredItems_table_criticalQuantityColumn;

  /// Table column header — current stock quantity with unit, expired items screen
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get expiredItems_table_quantityColumn;

  /// Table column header — medicine expiry date (S.K.T), expired items screen
  ///
  /// In en, this message translates to:
  /// **'Exp. Date'**
  String get expiredItems_table_expiryDateColumn;

  /// Table column header — days remaining until expiry, expired items screen
  ///
  /// In en, this message translates to:
  /// **'Remaining Days'**
  String get expiredItems_table_remainingDaysColumn;

  /// Table column header — service name, hospital stock screen
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get hospitalStock_table_serviceColumn;

  /// Table column header — stock code, hospital stock screen
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get hospitalStock_table_codeColumn;

  /// Table column header — medicine/material name, hospital stock screen
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get hospitalStock_table_medicineColumn;

  /// Table column header — current stock quantity, hospital stock screen
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get hospitalStock_table_quantityColumn;

  /// Table column header — doctor full name, patient inventory screen
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get patientInventory_table_doctorColumn;

  /// Table column header — physical service/department name, patient inventory screen
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get patientInventory_table_departmentColumn;

  /// Table column header — medicine barcode, patient inventory screen
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get patientInventory_table_barcodeColumn;

  /// Table column header — medicine/material name, patient inventory screen
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get patientInventory_table_medicineColumn;

  /// Table column header — requested dose/quantity, patient inventory screen
  ///
  /// In en, this message translates to:
  /// **'Requested Qty'**
  String get patientInventory_table_requestedQuantityColumn;

  /// Table column header — last movement/processed quantity, patient inventory screen
  ///
  /// In en, this message translates to:
  /// **'Processed Qty'**
  String get patientInventory_table_processedQuantityColumn;

  /// Table column header — prescription/request date, patient inventory screen
  ///
  /// In en, this message translates to:
  /// **'Request Date'**
  String get patientInventory_table_requestDateColumn;

  /// Table column header — transaction/process date, patient inventory screen
  ///
  /// In en, this message translates to:
  /// **'Process Date'**
  String get patientInventory_table_processDateColumn;

  /// Table column header — last movement type shown as chip, patient inventory screen
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get patientInventory_table_movementColumn;

  /// PDF report title — patient inventory list header, includes patient full name
  ///
  /// In en, this message translates to:
  /// **'{patientName} adlı hastaya ait Hasta Envanter Listesi'**
  String patientInventory_pdf_title(String patientName);

  /// PDF report info line — patient ID/code
  ///
  /// In en, this message translates to:
  /// **'Hasta Kodu: {code}'**
  String patientInventory_pdf_patientCode(Object code);

  /// PDF report info line — physical service name
  ///
  /// In en, this message translates to:
  /// **'Servis: {name}'**
  String patientInventory_pdf_service(String name);

  /// PDF report info line — bed name
  ///
  /// In en, this message translates to:
  /// **'Yatak: {name}'**
  String patientInventory_pdf_bed(String name);

  /// PDF report info line — report generation date
  ///
  /// In en, this message translates to:
  /// **'Rapor Tarihi: {date}'**
  String patientInventory_pdf_reportDate(String date);

  /// Table column header — service name, service management screen
  ///
  /// In en, this message translates to:
  /// **'Service Name'**
  String get service_table_nameColumn;

  /// Table column header — branch name, service management screen
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get service_table_branchColumn;

  /// Table column header — service responsible/manager name, service management screen
  ///
  /// In en, this message translates to:
  /// **'Service Manager'**
  String get service_table_managerColumn;

  /// Table column header — service status, service management screen
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get service_table_statusColumn;

  /// Table column header — physical service name, unapplied prescriptions screen
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get unappliedPrescription_table_serviceColumn;

  /// Table column header — room name, unapplied prescriptions screen
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get unappliedPrescription_table_roomColumn;

  /// Table column header — bed name, unapplied prescriptions screen
  ///
  /// In en, this message translates to:
  /// **'Bed'**
  String get unappliedPrescription_table_bedColumn;

  /// Table column header — patient protocol number, unapplied prescriptions screen
  ///
  /// In en, this message translates to:
  /// **'Patient Code'**
  String get unappliedPrescription_table_patientCodeColumn;

  /// Table column header — patient full name, unapplied prescriptions screen
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get unappliedPrescription_table_patientColumn;

  /// Table column header — hospitalization ID/code, unapplied prescriptions screen
  ///
  /// In en, this message translates to:
  /// **'Admission Code'**
  String get unappliedPrescription_table_hospitalizationCodeColumn;

  /// Table column header — hospitalization date, unapplied prescriptions screen
  ///
  /// In en, this message translates to:
  /// **'Admission Date'**
  String get unappliedPrescription_table_admissionDateColumn;

  /// Table column header — number of pending unapplied prescription items, unapplied prescriptions screen
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get unappliedPrescription_table_pendingCountColumn;

  /// Table column header — activity date, drug activity screen
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get drugActivity_table_dateColumn;

  /// Table column header — activity time, drug activity screen
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get drugActivity_table_timeColumn;

  /// Table column header — patient full name, drug activity screen
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get drugActivity_table_patientColumn;

  /// Table column header — user who performed the action, drug activity screen
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get drugActivity_table_userColumn;

  /// Table column header — medicine/material name, drug activity screen
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get drugActivity_table_medicineColumn;

  /// Table column header — movement quantity, drug activity screen
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get drugActivity_table_quantityColumn;

  /// Table column header — movement/transaction type action label, drug activity screen
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get drugActivity_table_movementColumn;

  /// Error message — RFID reader not connected when inventory start attempted
  ///
  /// In en, this message translates to:
  /// **'RFID reader is not connected'**
  String get rfid_notConnectedError;

  /// Error message — RFID inventory start failed with detail
  ///
  /// In en, this message translates to:
  /// **'Failed to start RFID inventory: {detail}'**
  String rfid_inventoryStartFailedError(String detail);

  /// Error message — RFID inventory stream error with detail
  ///
  /// In en, this message translates to:
  /// **'RFID inventory stream error: {detail}'**
  String rfid_inventoryStreamError(String detail);

  /// Generic error shown for all mobile drawer failures (managerNotFound, managerConnectFailed, openCommandFailed, statusTimeout, openNotConfirmed, statusReadError) when the cabinet cannot be reached
  ///
  /// In en, this message translates to:
  /// **'Unable to communicate with the cabinet. Please try again or contact authorized personnel.'**
  String get mobileDrawer_cabinConnectionErrorMessage;

  /// No description provided for @settingsView_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsView_title;

  /// No description provided for @settingsView_subtitle.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM CONFIGURATION'**
  String get settingsView_subtitle;

  /// No description provided for @settingsView_generalNav.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsView_generalNav;

  /// No description provided for @settingsView_appearanceNav.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsView_appearanceNav;

  /// No description provided for @settingsView_cabinNav.
  ///
  /// In en, this message translates to:
  /// **'Cabinet Settings'**
  String get settingsView_cabinNav;

  /// No description provided for @settingsView_prescriptionNav.
  ///
  /// In en, this message translates to:
  /// **'Prescription Settings'**
  String get settingsView_prescriptionNav;

  /// No description provided for @settingsView_developerNav.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get settingsView_developerNav;

  /// No description provided for @settingsView_debugNav.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get settingsView_debugNav;

  /// No description provided for @settingsView_sectionComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Content for this section is coming soon.'**
  String get settingsView_sectionComingSoon;

  /// No description provided for @census_hint_noMedicines.
  ///
  /// In en, this message translates to:
  /// **'No medicines found to count'**
  String get census_hint_noMedicines;

  /// No description provided for @census_label_queueProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total} drawers'**
  String census_label_queueProgress(Object current, Object total);

  /// No description provided for @census_action_stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get census_action_stop;

  /// No description provided for @census_stop_confirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to stop the census?'**
  String get census_stop_confirmTitle;

  /// No description provided for @census_stop_confirmMessage.
  ///
  /// In en, this message translates to:
  /// **'The census process will be stopped; counts completed so far will remain saved.'**
  String get census_stop_confirmMessage;

  /// No description provided for @census_stop_confirmYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, Stop'**
  String get census_stop_confirmYes;

  /// No description provided for @census_status_waitingPullTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for drawer'**
  String get census_status_waitingPullTitle;

  /// No description provided for @census_status_waitingPullBody.
  ///
  /// In en, this message translates to:
  /// **'Please pull the drawer'**
  String get census_status_waitingPullBody;

  /// No description provided for @census_status_openingLidTitle.
  ///
  /// In en, this message translates to:
  /// **'Opening cell'**
  String get census_status_openingLidTitle;

  /// No description provided for @census_status_openingLidBody.
  ///
  /// In en, this message translates to:
  /// **'Please wait, the cell is opening'**
  String get census_status_openingLidBody;

  /// No description provided for @census_status_openingTitle.
  ///
  /// In en, this message translates to:
  /// **'Opening drawer'**
  String get census_status_openingTitle;

  /// No description provided for @census_status_openingBody.
  ///
  /// In en, this message translates to:
  /// **'Please wait, the drawer is opening'**
  String get census_status_openingBody;

  /// No description provided for @census_action_nextCell.
  ///
  /// In en, this message translates to:
  /// **'Next Cell'**
  String get census_action_nextCell;

  /// No description provided for @census_action_completeCensus.
  ///
  /// In en, this message translates to:
  /// **'Complete Census'**
  String get census_action_completeCensus;

  /// No description provided for @census_error_queueTitle.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during the census'**
  String get census_error_queueTitle;

  /// No description provided for @census_error_queueMessage.
  ///
  /// In en, this message translates to:
  /// **'You can remove the medicines from the drawer and continue, or end the process here.'**
  String get census_error_queueMessage;

  /// No description provided for @census_error_continueNext.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get census_error_continueNext;

  /// No description provided for @census_error_endProcess.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get census_error_endProcess;

  /// No description provided for @census_label_countQty.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get census_label_countQty;

  /// Breadcrumb module title for the intake screen
  ///
  /// In en, this message translates to:
  /// **'Medication Intake'**
  String get intake_screenTitle;

  /// Breadcrumb label for the patient selection phase of the intake flow
  ///
  /// In en, this message translates to:
  /// **'Patient Selection'**
  String get intake_phase_patientLabel;

  /// Breadcrumb label for the medication selection phase of the intake flow
  ///
  /// In en, this message translates to:
  /// **'Medication Selection'**
  String get intake_phase_medicineLabel;

  /// Breadcrumb label for the executing phase of the intake flow
  ///
  /// In en, this message translates to:
  /// **'Intake Process'**
  String get intake_phase_executingLabel;

  /// Room info shown on a patient card
  ///
  /// In en, this message translates to:
  /// **'Room {room}'**
  String patientPicker_roomLabel(String room);

  /// Bed info shown on a patient card
  ///
  /// In en, this message translates to:
  /// **'Bed {bed}'**
  String patientPicker_bedLabel(String bed);

  /// Census/count field label when a target has multiple stock lots
  ///
  /// In en, this message translates to:
  /// **'Count {index} ({unit})'**
  String intake_label_countFieldLabelIndexed(String unit, int index);

  /// Label for the patient-status filter field (all patients vs my patients) in the patient selection panel's filter dialog
  ///
  /// In en, this message translates to:
  /// **'Patient Status'**
  String get patientListPanel_filter_patientStatusLabel;

  /// Label for the ordered/orderless toggle filter field in the patient selection panel's filter dialog
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get patientListPanel_filter_orderStatusLabel;

  /// Title shown while the master cabin drawer hardware is preparing to open (MasterDrawerOpening/devicePreparing stage), shared across all master cabin operation screens (refill, census, intake, etc.)
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get masterDrawer_status_devicePreparingTitle;

  /// Subtitle shown while the master cabin drawer hardware is preparing to open
  ///
  /// In en, this message translates to:
  /// **'The system is getting ready. Please wait a moment.'**
  String get masterDrawer_status_devicePreparingSubtitle;

  /// Title shown while the master cabin drawer lock is being released (MasterDrawerOpening/lockOpening stage)
  ///
  /// In en, this message translates to:
  /// **'Unlocking'**
  String get masterDrawer_status_lockOpeningTitle;

  /// Subtitle shown while the master cabin drawer lock is being released
  ///
  /// In en, this message translates to:
  /// **'The drawer lock is opening. Please wait a moment.'**
  String get masterDrawer_status_lockOpeningSubtitle;

  /// Title shown when the drawer lock has released and the user needs to physically pull the drawer open (MasterDrawerWaitingForPull stage)
  ///
  /// In en, this message translates to:
  /// **'Please Pull the Drawer'**
  String get masterDrawer_status_waitingPullTitle;

  /// Subtitle shown when waiting for the user to physically pull the drawer open
  ///
  /// In en, this message translates to:
  /// **'The lock has been released. Pull the drawer open to continue.'**
  String get masterDrawer_status_waitingPullSubtitle;

  /// Title shown while a cubic drawer's individual cell lid is opening (MasterDrawerOpeningLid stage)
  ///
  /// In en, this message translates to:
  /// **'Opening Compartment Lid'**
  String get masterDrawer_status_openingLidTitle;

  /// Subtitle shown while a cubic drawer's individual cell lid is opening
  ///
  /// In en, this message translates to:
  /// **'The compartment lid is opening. Please wait a moment.'**
  String get masterDrawer_status_openingLidSubtitle;

  /// Title shown after the user confirms completion and the system is waiting for the physical drawer to be closed (MasterDrawerWaitingForClose stage)
  ///
  /// In en, this message translates to:
  /// **'Please Close the Drawer'**
  String get masterDrawer_status_waitingCloseTitle;

  /// Subtitle shown while waiting for the physical drawer to be closed
  ///
  /// In en, this message translates to:
  /// **'Close the drawer to continue to the next step.'**
  String get masterDrawer_status_waitingCloseSubtitle;

  /// Title shown when the drawer hardware reports a failure (MasterDrawerFailed stage), before the queue-error confirmation dialog is shown
  ///
  /// In en, this message translates to:
  /// **'A Problem Occurred'**
  String get masterDrawer_status_failedTitle;

  /// Subtitle shown when the drawer hardware reports a failure
  ///
  /// In en, this message translates to:
  /// **'Please wait, the system is checking the drawer status.'**
  String get masterDrawer_status_failedSubtitle;

  /// Fallback title for drawer stages without a dedicated message (Idle/Closed transitional states, or any unmapped stage)
  ///
  /// In en, this message translates to:
  /// **'Opening Drawer'**
  String get masterDrawer_status_openingTitle;

  /// Fallback subtitle for drawer stages without a dedicated message
  ///
  /// In en, this message translates to:
  /// **'The drawer is opening. Please wait a moment.'**
  String get masterDrawer_status_openingSubtitle;

  /// Title shown after the user confirms stopping the queue while a drawer is still physically open — the stop will be applied once the drawer is closed
  ///
  /// In en, this message translates to:
  /// **'Please Close the Open Drawer'**
  String get masterDrawer_stop_waitingCloseTitle;

  /// Subtitle shown after the user confirms stopping the queue while a drawer is still physically open
  ///
  /// In en, this message translates to:
  /// **'Please close the open drawer. The process will stop once it is closed.'**
  String get masterDrawer_stop_waitingCloseSubtitle;

  /// Progress label shown in the top strip during intake execution, indicating which drawer in the queue is currently active
  ///
  /// In en, this message translates to:
  /// **'Drawer {done} of {total}'**
  String intake_label_queueProgress(int done, int total);

  /// Button label to stop the intake queue mid-execution, shown in the top strip
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get intake_action_stop;

  /// Title of the confirmation dialog shown when the user taps stop during intake execution
  ///
  /// In en, this message translates to:
  /// **'Stop Intake?'**
  String get intake_stop_confirmTitle;

  /// Message body of the confirmation dialog shown when the user taps stop during intake execution
  ///
  /// In en, this message translates to:
  /// **'The current intake process will be stopped. Completed drawers will be preserved.'**
  String get intake_stop_confirmMessage;

  /// Confirm button label in the stop-intake confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Yes, Stop'**
  String get intake_stop_confirmYes;

  /// Shown on an intake cell card when multiple prescription details (e.g. different times) draw from the same physical stock/cell, indicating the count is merged
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Combined from {count} prescription} other{Combined from {count} prescriptions}}'**
  String intake_hint_mergedFromMultiplePrescriptions(num count);

  /// Placeholder text for the medicine search field in the master refund medicine selection screen
  ///
  /// In en, this message translates to:
  /// **'Search medicine'**
  String get refund_hint_searchMedicine;

  /// Empty-state message shown in the medicine selection panel when no patient has been selected yet, on the master refund screen
  ///
  /// In en, this message translates to:
  /// **'Select a patient first'**
  String get refund_hint_selectPatientFirst;

  /// Empty-state message shown when the selected patient has no refundable medicines
  ///
  /// In en, this message translates to:
  /// **'No refundable medicine found'**
  String get refund_hint_noMedicineFound;

  /// Button label to start the check/refund process for the selected medicines on the master refund screen
  ///
  /// In en, this message translates to:
  /// **'Start Refund'**
  String get refund_action_start;

  /// Button label shown in a cubic drawer's refund confirmation form when there are more cells (lids) left to process in the current drawer
  ///
  /// In en, this message translates to:
  /// **'Next Cell'**
  String get refund_action_nextCell;

  /// Button label shown in the refund confirmation form to confirm and record the refund for the current drawer/cell, shown when it's the last cell or a unit-dose drawer
  ///
  /// In en, this message translates to:
  /// **'Complete Refund'**
  String get refund_action_completeRefund;

  /// Button label to stop the refund queue mid-execution, on the master refund execution screen
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get refund_action_stop;

  /// Confirmation dialog title shown when the user presses stop during the master refund execution queue
  ///
  /// In en, this message translates to:
  /// **'Stop Refund?'**
  String get refund_action_stopConfirmTitle;

  /// Confirmation dialog message explaining the consequence of stopping the refund queue mid-execution
  ///
  /// In en, this message translates to:
  /// **'Completed refunds will be kept, remaining drawers will not be processed.'**
  String get refund_action_stopConfirmMessage;

  /// Confirm button label inside the stop confirmation dialog on the master refund execution screen
  ///
  /// In en, this message translates to:
  /// **'Yes, Stop'**
  String get refund_action_stopConfirmYes;

  /// Label prefix shown before the maximum refundable quantity on a refund medicine card
  ///
  /// In en, this message translates to:
  /// **'Max. Refundable'**
  String get refund_field_maxAmount;

  /// Label prefix shown before the medicine's return note (Drug.returnNote) on a refund medicine card, if present
  ///
  /// In en, this message translates to:
  /// **'Return Note'**
  String get refund_field_returnNote;

  /// Status label shown on a refund medicine card while its refund eligibility check is in progress
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get refund_status_checking;

  /// Status label shown on a refund medicine card once its refund eligibility check succeeded
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get refund_status_ready;

  /// Fallback status message shown on a refund medicine card when its refund eligibility check fails without a specific server message
  ///
  /// In en, this message translates to:
  /// **'Check failed'**
  String get refund_status_checkFailed;

  /// Dialog title shown when a hardware/queue error occurs mid-refund, asking the user whether to continue with the next drawer or end the process
  ///
  /// In en, this message translates to:
  /// **'Refund Error'**
  String get refund_error_queueTitle;

  /// Confirm button label in the refund queue-error dialog, to skip the failed drawer and continue with the next one
  ///
  /// In en, this message translates to:
  /// **'Continue with Next'**
  String get refund_error_continueNext;

  /// Cancel button label in the refund queue-error dialog, to stop the refund queue entirely
  ///
  /// In en, this message translates to:
  /// **'End Process'**
  String get refund_error_endProcess;

  /// Validation error shown when the user tries to set a refund amount of 0 or less for a medicine on the master refund screen
  ///
  /// In en, this message translates to:
  /// **'Refund amount cannot be 0'**
  String get refund_error_amountZero;

  /// Validation error shown when the user tries to set a refund amount greater than the medicine's originally received quantity (dosePiece) on the master refund screen
  ///
  /// In en, this message translates to:
  /// **'Refund amount cannot exceed the received amount'**
  String get refund_error_amountExceedsMax;

  /// Progress label shown at the top of the master refund execution screen, indicating how many drawers have been processed out of the total queue
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} drawers'**
  String refund_label_progress(int done, int total);

  /// Master waste/destruction screen — search field placeholder for filtering the medicine list
  ///
  /// In en, this message translates to:
  /// **'Search medicine'**
  String get waste_hint_searchMedicine;

  /// Master waste/destruction screen — empty state message shown in the medicine panel before a patient is selected
  ///
  /// In en, this message translates to:
  /// **'Select a patient to continue'**
  String get waste_hint_selectPatientFirst;

  /// Master waste/destruction screen — empty state message when the selected patient has no disposable items
  ///
  /// In en, this message translates to:
  /// **'No disposable medicine found'**
  String get waste_hint_noMedicineFound;

  /// Master waste/destruction screen — shows the maximum disposable amount on an item card
  ///
  /// In en, this message translates to:
  /// **'Available amount: {amount}'**
  String waste_label_availableAmount(String amount);

  /// Shared witness login dialog — title, used by intake and waste/destruction screens
  ///
  /// In en, this message translates to:
  /// **'Witness Verification'**
  String get witnessDialog_title;

  /// Shared witness login dialog — username field label
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get witnessDialog_usernameLabel;

  /// Shared witness login dialog — validation message when the username field is left empty
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get witnessDialog_usernameRequired;

  /// Shared witness login dialog — password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get witnessDialog_passwordLabel;

  /// Shared witness login dialog — validation message when the password field is left empty
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get witnessDialog_passwordRequired;

  /// Shared witness login dialog — submit button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get witnessDialog_confirmButton;

  /// Shared witness login dialog — info banner shown when the item has no restricted witness list
  ///
  /// In en, this message translates to:
  /// **'Any user may act as a witness for this item.'**
  String get witnessDialog_anyoneInfo;

  /// Shared witness login dialog — heading above the chip list of users authorized to witness this item
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} authorized witness} other{{count} authorized witnesses}}'**
  String witnessDialog_authorizedWitnesses(num count);

  /// Shared witness login dialog — error shown when the currently logged-in user tries to log in as the witness
  ///
  /// In en, this message translates to:
  /// **'You cannot witness your own operation.'**
  String get witnessDialog_error_selfWitness;

  /// Shared witness login dialog — success message after a witness successfully logs in
  ///
  /// In en, this message translates to:
  /// **'{witnessName} confirmed as witness.'**
  String witnessDialog_success_confirmed(String witnessName);

  /// Inline witness row on an item card — shown when a witness has already been assigned to this item
  ///
  /// In en, this message translates to:
  /// **'Witness: {witnessName}'**
  String witnessDialog_assignedLabel(String witnessName);

  /// Inline witness row on an item card — shown when this item still needs a witness, tappable to open the witness dialog
  ///
  /// In en, this message translates to:
  /// **'Witness confirmation required'**
  String get witnessDialog_requiredHint;

  /// Info snackbar shown when an already-selected witness is automatically reused for another item without reopening the dialog
  ///
  /// In en, this message translates to:
  /// **'{witnessName} was automatically assigned as witness for this item.'**
  String witnessDialog_autoAssigned(String witnessName);

  /// Search field placeholder on the master cabin unload selection screen
  ///
  /// In en, this message translates to:
  /// **'Search medicine or barcode'**
  String get unload_hint_searchMedicine;

  /// Empty state message when no medicine matches the unload selection list/search
  ///
  /// In en, this message translates to:
  /// **'No medicine found'**
  String get unload_hint_noMedicineFound;

  /// Button label to stop the in-progress return-drawer unload and close the drawer without completing
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get unload_action_stop;

  /// Footer button label in a cubic unload drawer when the current lid is not the last one, opens the next cell
  ///
  /// In en, this message translates to:
  /// **'Next Cell'**
  String get unload_action_nextCell;

  /// Footer button label to finish the current drawer's unload: last cubic cell, or unit-dose/standard drawer
  ///
  /// In en, this message translates to:
  /// **'Complete Unloading'**
  String get unload_action_completeUnloading;

  /// Title of the confirmation dialog shown when the user taps Stop during the unload queue
  ///
  /// In en, this message translates to:
  /// **'Stop Unloading?'**
  String get unload_stop_confirmTitle;

  /// Body text of the confirmation dialog shown when the user taps Stop during the unload queue
  ///
  /// In en, this message translates to:
  /// **'The remaining drawers in the queue will not be unloaded. Are you sure you want to stop?'**
  String get unload_stop_confirmMessage;

  /// Confirm button label in the stop-unload confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Yes, Stop'**
  String get unload_stop_confirmYes;

  /// Dialog title shown when a hardware error occurs during return-drawer unload
  ///
  /// In en, this message translates to:
  /// **'Unload Error'**
  String get unload_error_queueTitle;

  /// Confirm button in the unload queue error dialog: mark current drawer failed and move to the next one
  ///
  /// In en, this message translates to:
  /// **'Continue to Next Drawer'**
  String get unload_error_continueNext;

  /// Cancel button in the unload queue error dialog: stop the queue, keep already completed drawers
  ///
  /// In en, this message translates to:
  /// **'End Process'**
  String get unload_error_endProcess;

  /// Progress label shown in the unload execution top strip
  ///
  /// In en, this message translates to:
  /// **'Drawer {done} of {total}'**
  String unload_label_queueProgress(int done, int total);

  /// Field label for the counted (current physical) quantity in the master unload execution cell card
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get unload_label_countQty;

  /// Field label for the quantity being removed from the cell in the master unload execution cell card
  ///
  /// In en, this message translates to:
  /// **'Unload Qty'**
  String get unload_label_unloadQty;

  /// Field label for the return quantity shown in the master refund execution cell card
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get refund_label_quantity;

  /// Queue progress label shown in the master destruction execution top strip
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String destruction_label_queueProgress(int current, int total);

  /// Button label to stop the master destruction queue
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get destruction_action_stop;

  /// Confirmation dialog title when stopping the master destruction queue
  ///
  /// In en, this message translates to:
  /// **'Stop destruction?'**
  String get destruction_stop_confirmTitle;

  /// Confirmation dialog message when stopping the master destruction queue
  ///
  /// In en, this message translates to:
  /// **'The destruction process will be stopped. Items already processed will be kept.'**
  String get destruction_stop_confirmMessage;

  /// Confirmation button label to confirm stopping the master destruction queue
  ///
  /// In en, this message translates to:
  /// **'Yes, stop'**
  String get destruction_stop_confirmYes;

  /// Field label for the quantity to destroy in the master destruction execution cell card
  ///
  /// In en, this message translates to:
  /// **'Destroy Qty'**
  String get destruction_label_quantity;

  /// Button label to advance to the next cell during master destruction execution
  ///
  /// In en, this message translates to:
  /// **'Next cell'**
  String get destruction_action_nextCell;

  /// Button label to complete the current master destruction target
  ///
  /// In en, this message translates to:
  /// **'Complete destruction'**
  String get destruction_action_completeDestruction;

  /// Chip shown on a medicine card in the destruction (imha) screen when the current user is not in the medicine's list of authorized destroyers
  ///
  /// In en, this message translates to:
  /// **'You are not authorized to destroy this medicine'**
  String get waste_hint_notAuthorized;

  /// Button on an out-of-stock intake item card, triggers the equivalent medicine lookup for that prescription item
  ///
  /// In en, this message translates to:
  /// **'Check Equivalent'**
  String get intake_action_checkEquivalent;

  /// Shown on an intake item card when the equivalent medicine check returns an empty list
  ///
  /// In en, this message translates to:
  /// **'No equivalent medicine found'**
  String get intake_hint_noEquivalentFound;

  /// Label above the list of equivalent medicine options returned for an out-of-stock intake item
  ///
  /// In en, this message translates to:
  /// **'Available equivalents'**
  String get intake_label_equivalentOptions;

  /// Loading text shown while checking if the medicine or its equivalent exists in another station's cabin
  ///
  /// In en, this message translates to:
  /// **'Searching other cabins...'**
  String get intake_hint_searchingOtherStations;

  /// Shown when neither the medicine nor an equivalent was found in this or any other station's cabin
  ///
  /// In en, this message translates to:
  /// **'This medicine was not found in any cabin'**
  String get intake_hint_noStockAnywhere;

  /// Label above the list of other stations where the medicine or its equivalent is available
  ///
  /// In en, this message translates to:
  /// **'Available in other cabins'**
  String get intake_label_otherStationOptions;

  /// Button to redirect an out-of-stock prescription item's intake to another station's cabin
  ///
  /// In en, this message translates to:
  /// **'Redirect'**
  String get intake_action_redirect;

  /// Confirmation shown on an intake item card after it has been successfully redirected to another station
  ///
  /// In en, this message translates to:
  /// **'Redirected to {stationName} cabin'**
  String intake_hint_redirectedTo(String stationName);

  /// Status chip label for an intake item that has been redirected to another station
  ///
  /// In en, this message translates to:
  /// **'Redirected'**
  String get intake_status_redirected;

  /// Tab label for the default prescription-based intake list in the master intake selection screen
  ///
  /// In en, this message translates to:
  /// **'Prescriptions'**
  String get intake_tab_prescriptions;

  /// Tab label for the list of prescription items redirected to this station's cabin from another station
  ///
  /// In en, this message translates to:
  /// **'Redirected Orders'**
  String get intake_tab_redirectedOrders;

  /// Empty state shown when there are no pending redirected intake orders for any patient
  ///
  /// In en, this message translates to:
  /// **'No redirected orders'**
  String get intake_hint_noRedirectedOrders;

  /// Status chip on a redirected order card showing which station it was redirected from
  ///
  /// In en, this message translates to:
  /// **'Redirected from {stationName}'**
  String intake_status_redirectedFrom(String stationName);

  /// Shown on a redirected order card, naming the user who performed the redirect
  ///
  /// In en, this message translates to:
  /// **'Redirected by {userName}'**
  String intake_label_redirectedBy(String userName);

  /// Master refund screen: per-card button for hardware-less return types (return box / pharmacy) to complete the refund for a single item immediately
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get refund_action_completeDirect;

  /// Title of the dialog shown after a hardware-less refund (return box / pharmacy) completes successfully
  ///
  /// In en, this message translates to:
  /// **'Return Completed'**
  String get refund_success_dialogTitle;

  /// Shown after completing a ReturnType.toPharmacy refund, instructing the user to hand the medicine to the pharmacist
  ///
  /// In en, this message translates to:
  /// **'The return has been completed. Please hand the medicine to the pharmacist.'**
  String get refund_success_toPharmacyMessage;

  /// Shown after completing a ReturnType.toReturnBox refund, instructing the user to place the medicine in the return box
  ///
  /// In en, this message translates to:
  /// **'The return has been completed. Please place the medicine in the return box.'**
  String get refund_success_toReturnBoxMessage;

  /// Drawer panel header type label shown when the selected DrawerSlot is designated as the return drawer (isReturnDrawerHere)
  ///
  /// In en, this message translates to:
  /// **'Return Drawer'**
  String get cabin_returnDrawerName;

  /// Drawer panel header subtitle shown when the selected DrawerSlot is the return drawer
  ///
  /// In en, this message translates to:
  /// **'Return Box'**
  String get cabin_returnDrawerView;

  /// Placeholder title shown instead of the cell grid when the selected drawer is designated as the return drawer
  ///
  /// In en, this message translates to:
  /// **'This drawer is designated as the return box'**
  String get cabin_returnDrawerViewTitle;

  /// Placeholder subtitle explaining that medicine assignment/refill is disabled for the return drawer
  ///
  /// In en, this message translates to:
  /// **'Medicine assignment/refill is not available for this drawer'**
  String get cabin_returnDrawerViewSubtitle;

  /// No description provided for @cabinDesign_dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Cabin Design'**
  String get cabinDesign_dialogTitle;

  /// No description provided for @cabinDesign_syncBadge.
  ///
  /// In en, this message translates to:
  /// **'SYNCED'**
  String get cabinDesign_syncBadge;

  /// No description provided for @cabinDesign_basicSettings_sectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Basic Settings'**
  String get cabinDesign_basicSettings_sectionTitle;

  /// No description provided for @cabinDesign_basicSettings_nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Cabin Name'**
  String get cabinDesign_basicSettings_nameLabel;

  /// No description provided for @cabinDesign_basicSettings_stationLabel.
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get cabinDesign_basicSettings_stationLabel;

  /// No description provided for @cabinDesign_basicSettings_comPortLabel.
  ///
  /// In en, this message translates to:
  /// **'COM Port'**
  String get cabinDesign_basicSettings_comPortLabel;

  /// No description provided for @cabinDesign_basicSettings_dvrIpLabel.
  ///
  /// In en, this message translates to:
  /// **'DVR IP'**
  String get cabinDesign_basicSettings_dvrIpLabel;

  /// No description provided for @cabinDesign_detail_sectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Drawer Detail'**
  String get cabinDesign_detail_sectionTitle;

  /// No description provided for @cabinDesign_detail_typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get cabinDesign_detail_typeLabel;

  /// Value shown for a cubic drawer's type, formatted as rows x columns
  ///
  /// In en, this message translates to:
  /// **'Cubic {rows}×{cols}'**
  String cabinDesign_detail_typeKubik(int rows, int cols);

  /// No description provided for @cabinDesign_detail_cellCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Cell Count'**
  String get cabinDesign_detail_cellCountLabel;

  /// No description provided for @cabinDesign_detail_addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get cabinDesign_detail_addressLabel;

  /// No description provided for @cabinDesign_detail_configLabel.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get cabinDesign_detail_configLabel;

  /// No description provided for @cabinDesign_returnDrawer_toggleLabel.
  ///
  /// In en, this message translates to:
  /// **'Return drawer'**
  String get cabinDesign_returnDrawer_toggleLabel;

  /// No description provided for @cabinDesign_returnDrawer_toggleHint.
  ///
  /// In en, this message translates to:
  /// **'This drawer will be reserved for return operations'**
  String get cabinDesign_returnDrawer_toggleHint;

  /// Info text showing the address of the currently designated return drawer
  ///
  /// In en, this message translates to:
  /// **'Only one return drawer can be designated per cabinet. Currently: {address}'**
  String cabinDesign_returnDrawer_currentInfo(String address);

  /// No description provided for @cabinDesign_returnDrawer_noneInfo.
  ///
  /// In en, this message translates to:
  /// **'Only one return drawer can be designated per cabinet. None designated yet.'**
  String get cabinDesign_returnDrawer_noneInfo;

  /// No description provided for @cabinDesign_serum_sectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Internal Layout'**
  String get cabinDesign_serum_sectionTitle;

  /// No description provided for @cabinDesign_serum_manualBadge.
  ///
  /// In en, this message translates to:
  /// **'MANUAL SETUP'**
  String get cabinDesign_serum_manualBadge;

  /// No description provided for @cabinDesign_serum_infoBanner.
  ///
  /// In en, this message translates to:
  /// **'The internal layout of a serum cabinet is not read from the card; define its drawers and equipment placement here.'**
  String get cabinDesign_serum_infoBanner;

  /// No description provided for @cabinDesign_serum_drawerCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Drawer count'**
  String get cabinDesign_serum_drawerCountLabel;

  /// Title of a single serum drawer's expandable config card
  ///
  /// In en, this message translates to:
  /// **'Drawer {index}'**
  String cabinDesign_serum_drawerCardTitle(int index);

  /// Collapsed summary of a serum drawer's equipment layout
  ///
  /// In en, this message translates to:
  /// **'{sideBySide}×{frontToBack} = {total} equipment'**
  String cabinDesign_serum_drawerCardSummary(
    int sideBySide,
    int frontToBack,
    int total,
  );

  /// No description provided for @cabinDesign_serum_equipmentLayoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Equipment Layout'**
  String get cabinDesign_serum_equipmentLayoutTitle;

  /// Compact badge identifying which serum drawer is currently being edited
  ///
  /// In en, this message translates to:
  /// **'S-0{index}'**
  String cabinDesign_serum_drawerBadge(int index);

  /// No description provided for @cabinDesign_serum_sideBySideLabel.
  ///
  /// In en, this message translates to:
  /// **'Side by side'**
  String get cabinDesign_serum_sideBySideLabel;

  /// No description provided for @cabinDesign_serum_frontToBackLabel.
  ///
  /// In en, this message translates to:
  /// **'Front to back'**
  String get cabinDesign_serum_frontToBackLabel;

  /// No description provided for @cabinDesign_serum_topViewLabel.
  ///
  /// In en, this message translates to:
  /// **'Top View'**
  String get cabinDesign_serum_topViewLabel;

  /// Summary text next to the top-down equipment grid preview
  ///
  /// In en, this message translates to:
  /// **'{sideBySide} × {frontToBack} = {total} equipment'**
  String cabinDesign_serum_totalEquipmentLabel(
    int sideBySide,
    int frontToBack,
    int total,
  );

  /// No description provided for @cabinDesign_serum_frontLabel.
  ///
  /// In en, this message translates to:
  /// **'← front'**
  String get cabinDesign_serum_frontLabel;

  /// No description provided for @cabinDesign_serum_backLabel.
  ///
  /// In en, this message translates to:
  /// **'back →'**
  String get cabinDesign_serum_backLabel;

  /// No description provided for @cabinDesign_serum_applyToAllButton.
  ///
  /// In en, this message translates to:
  /// **'Apply this layout to all drawers'**
  String get cabinDesign_serum_applyToAllButton;

  /// Warning shown when not all serum drawers have their equipment layout defined yet
  ///
  /// In en, this message translates to:
  /// **'The design cannot be saved until every drawer\'s layout is defined. Missing: {missingDrawerLabel}'**
  String cabinDesign_serum_incompleteWarning(String missingDrawerLabel);

  /// No description provided for @cabinDesign_noSelectionHint.
  ///
  /// In en, this message translates to:
  /// **'Select a drawer to see its details.'**
  String get cabinDesign_noSelectionHint;

  /// No description provided for @cabinDesign_scanButton.
  ///
  /// In en, this message translates to:
  /// **'Scan Device'**
  String get cabinDesign_scanButton;

  /// No description provided for @cabinDesign_saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Design'**
  String get cabinDesign_saveButton;

  /// No description provided for @cabinDesign_returnBadge.
  ///
  /// In en, this message translates to:
  /// **'RETURN'**
  String get cabinDesign_returnBadge;

  /// No description provided for @cabin_returnBoxLabel.
  ///
  /// In en, this message translates to:
  /// **'RETURN BOX'**
  String get cabin_returnBoxLabel;

  /// Segmented button label for switching to the return-drawer unload mode on the Unload screen
  ///
  /// In en, this message translates to:
  /// **'Return Drawer'**
  String get unload_segment_returnDrawer;

  /// Segmented button label for switching to the return-box unload mode on the Unload screen
  ///
  /// In en, this message translates to:
  /// **'Return Box'**
  String get unload_segment_returnBox;

  /// Empty-state message shown when the return-drawer unload list has no items
  ///
  /// In en, this message translates to:
  /// **'No medicines found in the return drawer'**
  String get unload_hint_noDrawerMedicineFound;

  /// Empty-state message shown when the return-box unload list has no items
  ///
  /// In en, this message translates to:
  /// **'No medicines found in the return box'**
  String get unload_hint_noBoxMedicineFound;

  /// Field label on a medicine card showing which user returned the medicine; shared across return-drawer and return-box unload modes
  ///
  /// In en, this message translates to:
  /// **'Returned By'**
  String get unload_fieldReturnedBy;

  /// Footer button on the return-drawer unload selection screen; opens the physical return drawer
  ///
  /// In en, this message translates to:
  /// **'Start Drawer Unload'**
  String get unload_action_startDrawerUnload;

  /// Footer button on the return-box unload selection screen; submits selected medicines for unload without opening hardware
  ///
  /// In en, this message translates to:
  /// **'Complete Box Unload'**
  String get unload_action_completeBoxUnload;

  /// Progress label shown on the execution screen while the return drawer is open and waiting for the user to confirm the unload
  ///
  /// In en, this message translates to:
  /// **'Return Drawer Unload In Progress'**
  String get unload_label_drawerInProgress;

  /// Confirmation dialog title shown when the user taps Stop during return-drawer unload
  ///
  /// In en, this message translates to:
  /// **'Stop Drawer Unload?'**
  String get unload_action_stopConfirmTitle;

  /// Confirmation dialog message shown when the user taps Stop during return-drawer unload
  ///
  /// In en, this message translates to:
  /// **'The drawer will close and the unload will not be completed. Do you want to continue?'**
  String get unload_action_stopConfirmMessage;

  /// Confirm button label in the stop-confirmation dialog for return-drawer unload
  ///
  /// In en, this message translates to:
  /// **'Yes, Stop'**
  String get unload_action_stopConfirmYes;

  /// Confirm button label on the execution screen; submits the unload request for the return drawer and closes it
  ///
  /// In en, this message translates to:
  /// **'Complete Drawer Unload'**
  String get unload_action_completeDrawerUnload;

  /// Shown when the RS485 management card cannot be located during any master drawer session (open or close monitoring).
  ///
  /// In en, this message translates to:
  /// **'Management card not found. Check the cabin connection.'**
  String get masterDrawer_error_managerNotFound;

  /// Shown when the app fails to establish a serial connection to the cabin's management card.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the cabin. Check the connection and try again.'**
  String get masterDrawer_error_managerConnectFailed;

  /// Shown when the hardware actively rejects the drawer/lid open command (non-ok response).
  ///
  /// In en, this message translates to:
  /// **'The drawer lock could not be opened. Check the hardware.'**
  String get masterDrawer_error_lockOpenFailed;

  /// Shown when a cubic lid open command is rejected by the hardware, most commonly because the outer drawer is not fully open.
  ///
  /// In en, this message translates to:
  /// **'The lid could not be opened. Make sure the drawer is fully open.'**
  String get masterDrawer_error_lidOpenFailed;

  /// Shown when the drawer sensor never reaches the fully-open state within the allotted time, despite the open command being accepted (e.g. mechanical jam).
  ///
  /// In en, this message translates to:
  /// **'The drawer did not fully open in time. Please pull the drawer all the way out.'**
  String get masterDrawer_error_lockOpenTimeout;

  /// Shown when the drawer status sensor stops responding for multiple consecutive polls during open or close monitoring.
  ///
  /// In en, this message translates to:
  /// **'Communication with the hardware was lost. Check the connection and try again.'**
  String get masterDrawer_error_sensorCommunicationLost;

  /// No description provided for @masterDrawer_error_unexpectedlyClosed.
  ///
  /// In en, this message translates to:
  /// **'The drawer was closed unexpectedly while still in use. Please reopen and try again.'**
  String get masterDrawer_error_unexpectedlyClosed;

  /// Title shown after the last job in the queue finishes and the drawer closes, informing the user the operation is finishing up.
  ///
  /// In en, this message translates to:
  /// **'Completing Your Operation'**
  String get masterDrawer_status_completingTitle;

  /// Subtitle for the Completing Your Operation title.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get masterDrawer_status_completingSubtitle;

  /// Section title for the list of cabins defined in the current station, shown in the left panel of the cabin design dialog
  ///
  /// In en, this message translates to:
  /// **'Defined Cabinets'**
  String get cabinDesign_cabinList_sectionTitle;

  /// Badge showing the total number of cabins defined in the station, next to the cabin list title
  ///
  /// In en, this message translates to:
  /// **'{count} Cabinets'**
  String cabinDesign_cabinList_countBadge(int count);

  /// Button at the bottom of the cabin list panel to start defining a new cabin
  ///
  /// In en, this message translates to:
  /// **'Define New Cabinet'**
  String get cabinDesign_cabinList_addCabinButton;

  /// Shown in place of the COM port in the cabin list item when the cabin has no assigned port (e.g. openCabinet, returnCabin types)
  ///
  /// In en, this message translates to:
  /// **'No Port'**
  String get cabinDesign_cabinList_noPortLabel;

  /// Badge shown on a cabin list item when the cabin's status is passive/inactive
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get cabinDesign_cabinList_passiveBadge;

  /// Label above the cabin type selector in the new cabin creation form
  ///
  /// In en, this message translates to:
  /// **'Cabinet Type'**
  String get cabinDesign_newCabin_typeLabel;

  /// Label above the management card address (letter) selector in the new cabin creation form
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get cabinDesign_newCabin_addressLabel;

  /// Shown instead of the address selector when all 15 non-master addresses (B-P) are already assigned to cabins in this station
  ///
  /// In en, this message translates to:
  /// **'No address left to assign in this station (all 15 addresses B-P are in use).'**
  String get cabinDesign_newCabin_noAddressAvailableWarning;

  /// No description provided for @cabinDesign_newCabin_saveAndScanButton.
  ///
  /// In en, this message translates to:
  /// **'Save & Scan'**
  String get cabinDesign_newCabin_saveAndScanButton;

  /// No description provided for @cabinDesign_newCabin_invalidAddressError.
  ///
  /// In en, this message translates to:
  /// **'The selected address is invalid.'**
  String get cabinDesign_newCabin_invalidAddressError;

  /// Button shown next to the COM port / address selector in the basic settings panel when a pending connection change (master port or slave address) exists — verifies the new address and re-scans the drawer layout
  ///
  /// In en, this message translates to:
  /// **'Rescan'**
  String get cabinDesign_basicSettings_rescanButton;

  /// No description provided for @cabinDesign_basicSettings_deactivateButton.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get cabinDesign_basicSettings_deactivateButton;

  /// No description provided for @cabinDesign_basicSettings_activateButton.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get cabinDesign_basicSettings_activateButton;

  /// No description provided for @cabinSelection_screenTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Cabinet'**
  String get cabinSelection_screenTitle;

  /// No description provided for @cabinSelection_continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get cabinSelection_continueButton;

  /// No description provided for @cabinSelection_dataUnavailableLabel.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get cabinSelection_dataUnavailableLabel;

  /// No description provided for @cabinOperation_changeCabinButton.
  ///
  /// In en, this message translates to:
  /// **'Select Cabinet'**
  String get cabinOperation_changeCabinButton;
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
      <String>['ar', 'en', 'fr', 'tr'].contains(locale.languageCode);

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
    case 'fr':
      return AppLocalizationsFr();
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
