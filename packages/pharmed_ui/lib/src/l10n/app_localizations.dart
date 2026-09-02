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

  /// No description provided for @common_selectCellTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a Cell'**
  String get common_selectCellTitle;

  /// No description provided for @common_noAssignmentBadge.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get common_noAssignmentBadge;

  /// No description provided for @common_drugAssignedBadge.
  ///
  /// In en, this message translates to:
  /// **'Drug Assigned'**
  String get common_drugAssignedBadge;

  /// No description provided for @common_patientAssignedBadge.
  ///
  /// In en, this message translates to:
  /// **'Patient Assigned'**
  String get common_patientAssignedBadge;

  /// No description provided for @common_noCabinDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No Cabinet Data Found'**
  String get common_noCabinDataTitle;

  /// No description provided for @common_noCabinDataDescription.
  ///
  /// In en, this message translates to:
  /// **'The cabinet may not be configured yet\nor the connection could not be established.'**
  String get common_noCabinDataDescription;

  /// No description provided for @common_noResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Results Found'**
  String get common_noResultsTitle;

  /// No description provided for @common_noResultsDescription.
  ///
  /// In en, this message translates to:
  /// **'Try changing your search criteria.'**
  String get common_noResultsDescription;

  /// No description provided for @common_retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retryButton;

  /// No description provided for @common_completeButton.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get common_completeButton;

  /// No description provided for @common_cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancelButton;

  /// No description provided for @common_barcodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get common_barcodeLabel;

  /// No description provided for @common_pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page Not Found'**
  String get common_pageNotFound;

  /// No description provided for @common_minLabel.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get common_minLabel;

  /// No description provided for @common_maxLabel.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get common_maxLabel;

  /// No description provided for @common_criticalLabel.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get common_criticalLabel;

  /// No description provided for @common_boolYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get common_boolYes;

  /// No description provided for @common_boolNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get common_boolNo;

  /// No description provided for @common_action_discharge.
  ///
  /// In en, this message translates to:
  /// **'Discharge'**
  String get common_action_discharge;

  /// No description provided for @auth_loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to the system'**
  String get auth_loginSubtitle;

  /// No description provided for @auth_emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email / Username'**
  String get auth_emailLabel;

  /// No description provided for @auth_passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_passwordLabel;

  /// No description provided for @auth_loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get auth_loginButton;

  /// No description provided for @auth_genericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get auth_genericError;

  /// No description provided for @dashboard_appBarTitle.
  ///
  /// In en, this message translates to:
  /// **'MEDICINE CABINET MANAGEMENT'**
  String get dashboard_appBarTitle;

  /// No description provided for @dashboard_logoutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get dashboard_logoutTooltip;

  /// No description provided for @dashboard_loginBarButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get dashboard_loginBarButton;

  /// No description provided for @dashboard_kpiActivePatients.
  ///
  /// In en, this message translates to:
  /// **'Active Patients'**
  String get dashboard_kpiActivePatients;

  /// No description provided for @dashboard_kpiCompletedOps.
  ///
  /// In en, this message translates to:
  /// **'Completed Operations'**
  String get dashboard_kpiCompletedOps;

  /// No description provided for @dashboard_kpiPendingPrescriptions.
  ///
  /// In en, this message translates to:
  /// **'Pending Prescriptions'**
  String get dashboard_kpiPendingPrescriptions;

  /// No description provided for @dashboard_kpiCriticalAlerts.
  ///
  /// In en, this message translates to:
  /// **'Critical Alerts'**
  String get dashboard_kpiCriticalAlerts;

  /// No description provided for @dashboard_cabinStatusHeader.
  ///
  /// In en, this message translates to:
  /// **'CABINET STATUS'**
  String get dashboard_cabinStatusHeader;

  /// No description provided for @dashboard_cabinStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Cabinet Status'**
  String get dashboard_cabinStatusLabel;

  /// No description provided for @dashboard_kpiLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load KPI data'**
  String get dashboard_kpiLoadError;

  /// No description provided for @dashboard_cabinLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load cabinet data'**
  String get dashboard_cabinLoadError;

  /// No description provided for @dashboard_treatmentsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Upcoming treatments could not be loaded'**
  String get dashboard_treatmentsLoadError;

  /// No description provided for @dashboard_sktLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load expiry data'**
  String get dashboard_sktLoadError;

  /// No description provided for @assignment_assignBedPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select a cell from the center\npanel to assign a bed.'**
  String get assignment_assignBedPlaceholder;

  /// No description provided for @assignment_assignDrugPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select a cell from the center\npanel to make an assignment.'**
  String get assignment_assignDrugPlaceholder;

  /// No description provided for @assignment_hospitalizationSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'PATIENT / ADMISSION'**
  String get assignment_hospitalizationSectionLabel;

  /// No description provided for @assignment_hospitalizationSelectorHint.
  ///
  /// In en, this message translates to:
  /// **'Select admission...'**
  String get assignment_hospitalizationSelectorHint;

  /// No description provided for @assignment_selectHospitalizationDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Admission'**
  String get assignment_selectHospitalizationDialogTitle;

  /// No description provided for @assignment_drugSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'DRUG'**
  String get assignment_drugSectionLabel;

  /// No description provided for @assignment_drugSelectorHint.
  ///
  /// In en, this message translates to:
  /// **'Select drug...'**
  String get assignment_drugSelectorHint;

  /// No description provided for @assignment_selectDrugDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Drug'**
  String get assignment_selectDrugDialogTitle;

  /// No description provided for @assignment_quantitySectionLabel.
  ///
  /// In en, this message translates to:
  /// **'QUANTITY'**
  String get assignment_quantitySectionLabel;

  /// No description provided for @assignment_saveAssignmentButton.
  ///
  /// In en, this message translates to:
  /// **'Save Assignment'**
  String get assignment_saveAssignmentButton;

  /// No description provided for @assignment_removeAssignmentButton.
  ///
  /// In en, this message translates to:
  /// **'Remove Assignment'**
  String get assignment_removeAssignmentButton;

  /// No description provided for @assignment_changeAssignmentButton.
  ///
  /// In en, this message translates to:
  /// **'Change Assignment'**
  String get assignment_changeAssignmentButton;

  /// No description provided for @assignment_roomBedLabel.
  ///
  /// In en, this message translates to:
  /// **'Room / Bed'**
  String get assignment_roomBedLabel;

  /// No description provided for @assignment_serviceLabel.
  ///
  /// In en, this message translates to:
  /// **'Ward'**
  String get assignment_serviceLabel;

  /// No description provided for @assignment_cellNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'Selected cell not found'**
  String get assignment_cellNotFoundError;

  /// No description provided for @assignment_patientSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Patient assignment saved successfully'**
  String get assignment_patientSavedSuccess;

  /// No description provided for @assignment_patientRemovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Patient assignment removed'**
  String get assignment_patientRemovedSuccess;

  /// No description provided for @fault_selectCellPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select a cell from the center\npanel to report a fault.'**
  String get fault_selectCellPlaceholder;

  /// No description provided for @fault_descriptionSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'DESCRIPTION'**
  String get fault_descriptionSectionLabel;

  /// No description provided for @fault_descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the fault...'**
  String get fault_descriptionHint;

  /// No description provided for @fault_faultSegmentLabel.
  ///
  /// In en, this message translates to:
  /// **'FAULT'**
  String get fault_faultSegmentLabel;

  /// No description provided for @fault_maintenanceSegmentLabel.
  ///
  /// In en, this message translates to:
  /// **'MAINTENANCE'**
  String get fault_maintenanceSegmentLabel;

  /// No description provided for @fault_historySectionLabel.
  ///
  /// In en, this message translates to:
  /// **'HISTORY'**
  String get fault_historySectionLabel;

  /// No description provided for @fault_historyStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get fault_historyStatusCompleted;

  /// No description provided for @fault_historyStatusMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get fault_historyStatusMaintenance;

  /// No description provided for @fault_historyStatusFault.
  ///
  /// In en, this message translates to:
  /// **'Fault'**
  String get fault_historyStatusFault;

  /// No description provided for @fault_historyActiveBadge.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get fault_historyActiveBadge;

  /// No description provided for @fault_activeFaultBanner.
  ///
  /// In en, this message translates to:
  /// **'This cell has an active {label} record. Confirming will close this record.'**
  String fault_activeFaultBanner(String label);

  /// No description provided for @fault_reportFaultButton.
  ///
  /// In en, this message translates to:
  /// **'Report Fault'**
  String get fault_reportFaultButton;

  /// No description provided for @fault_closeFaultButton.
  ///
  /// In en, this message translates to:
  /// **'Close Record'**
  String get fault_closeFaultButton;

  /// No description provided for @fault_recordCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Fault record created.'**
  String get fault_recordCreatedSuccess;

  /// No description provided for @fault_recordClosedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Fault record closed.'**
  String get fault_recordClosedSuccess;

  /// No description provided for @cabin_mobileTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'MOBILE'**
  String get cabin_mobileTypeLabel;

  /// No description provided for @cabin_mobileDrawerTitle.
  ///
  /// In en, this message translates to:
  /// **'Mobile Drawer'**
  String get cabin_mobileDrawerTitle;

  /// No description provided for @cabin_cellCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} cells'**
  String cabin_cellCountLabel(int count);

  /// No description provided for @cabin_drawerStatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Drawers'**
  String get cabin_drawerStatsLabel;

  /// No description provided for @cabin_statsFullEmpty.
  ///
  /// In en, this message translates to:
  /// **'{full} full · {empty} empty'**
  String cabin_statsFullEmpty(int full, int empty);

  /// No description provided for @cabin_touchDrawerHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a drawer'**
  String get cabin_touchDrawerHint;

  /// No description provided for @cabin_mobileGridPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Mobile cabinet cell grid will be displayed'**
  String get cabin_mobileGridPlaceholder;

  /// No description provided for @cabin_masterGridPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Cubic · Unit Dose · Serum internal structures will be displayed'**
  String get cabin_masterGridPlaceholder;

  /// No description provided for @cabin_kubikTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'CUBIC'**
  String get cabin_kubikTypeLabel;

  /// No description provided for @cabin_serumDrawerName.
  ///
  /// In en, this message translates to:
  /// **'Serum Drawer'**
  String get cabin_serumDrawerName;

  /// No description provided for @cabin_kubikDrawerName.
  ///
  /// In en, this message translates to:
  /// **'Cubic Drawer'**
  String get cabin_kubikDrawerName;

  /// No description provided for @cabin_unitDoseDrawerName.
  ///
  /// In en, this message translates to:
  /// **'Unit Dose Drawer'**
  String get cabin_unitDoseDrawerName;

  /// No description provided for @cabin_serumRackView.
  ///
  /// In en, this message translates to:
  /// **'Rack view'**
  String get cabin_serumRackView;

  /// No description provided for @cabin_serumViewTitle.
  ///
  /// In en, this message translates to:
  /// **'Serum view'**
  String get cabin_serumViewTitle;

  /// No description provided for @cabin_serumViewTodo.
  ///
  /// In en, this message translates to:
  /// **'TODO: Will be completed when serum internal structure is finalized'**
  String get cabin_serumViewTodo;

  /// No description provided for @cabin_openButton.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get cabin_openButton;

  /// No description provided for @cabin_assignDrugButton.
  ///
  /// In en, this message translates to:
  /// **'Assign Drug'**
  String get cabin_assignDrugButton;

  /// No description provided for @cabin_bannerPatientAssign.
  ///
  /// In en, this message translates to:
  /// **'Patient Assignment — assign a patient / admission to cells.'**
  String get cabin_bannerPatientAssign;

  /// No description provided for @cabin_bannerDrugAssign.
  ///
  /// In en, this message translates to:
  /// **'Drug Assignment — assign drugs to cells, set min/max/critical values.'**
  String get cabin_bannerDrugAssign;

  /// No description provided for @cabin_bannerDrugFill.
  ///
  /// In en, this message translates to:
  /// **'Drug Filling — tap the cell to fill, enter the quantity.'**
  String get cabin_bannerDrugFill;

  /// No description provided for @cabin_bannerDrugCount.
  ///
  /// In en, this message translates to:
  /// **'Stock Count — enter the actual quantity, the system will calculate the difference.'**
  String get cabin_bannerDrugCount;

  /// No description provided for @cabin_bannerFault.
  ///
  /// In en, this message translates to:
  /// **'Fault — mark the faulty cell and enter a description.'**
  String get cabin_bannerFault;

  /// No description provided for @cabin_statusWorking.
  ///
  /// In en, this message translates to:
  /// **'Operational'**
  String get cabin_statusWorking;

  /// No description provided for @cabin_statusFaultRecord.
  ///
  /// In en, this message translates to:
  /// **'Fault Record'**
  String get cabin_statusFaultRecord;

  /// No description provided for @cabin_statusMaintenanceRecord.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Record'**
  String get cabin_statusMaintenanceRecord;

  /// No description provided for @cabin_modeAssignLabel.
  ///
  /// In en, this message translates to:
  /// **'Drug Assignment'**
  String get cabin_modeAssignLabel;

  /// No description provided for @cabin_modeFillLabel.
  ///
  /// In en, this message translates to:
  /// **'Drug Filling'**
  String get cabin_modeFillLabel;

  /// No description provided for @cabin_modeCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Drug Count'**
  String get cabin_modeCountLabel;

  /// No description provided for @cabin_modeFaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Drawer Fault'**
  String get cabin_modeFaultLabel;

  /// No description provided for @cabin_operationPanelAssign.
  ///
  /// In en, this message translates to:
  /// **'DRUG ASSIGNMENT'**
  String get cabin_operationPanelAssign;

  /// No description provided for @cabin_operationPanelFill.
  ///
  /// In en, this message translates to:
  /// **'DRUG FILLING'**
  String get cabin_operationPanelFill;

  /// No description provided for @cabin_operationPanelCount.
  ///
  /// In en, this message translates to:
  /// **'DRUG COUNT'**
  String get cabin_operationPanelCount;

  /// No description provided for @cabin_operationPanelFault.
  ///
  /// In en, this message translates to:
  /// **'REPORT FAULT'**
  String get cabin_operationPanelFault;

  /// No description provided for @cabin_legendAssignEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty cell (assign)'**
  String get cabin_legendAssignEmpty;

  /// No description provided for @cabin_legendAssignAssigned.
  ///
  /// In en, this message translates to:
  /// **'Drug assigned'**
  String get cabin_legendAssignAssigned;

  /// No description provided for @cabin_legendAssignFault.
  ///
  /// In en, this message translates to:
  /// **'Faulty'**
  String get cabin_legendAssignFault;

  /// No description provided for @cabin_legendAssignMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Under maintenance'**
  String get cabin_legendAssignMaintenance;

  /// No description provided for @cabin_legendPatientAssigned.
  ///
  /// In en, this message translates to:
  /// **'Patient assigned'**
  String get cabin_legendPatientAssigned;

  /// No description provided for @cabin_legendFilled.
  ///
  /// In en, this message translates to:
  /// **'Filled'**
  String get cabin_legendFilled;

  /// No description provided for @cabin_legendFillEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty (no fill needed)'**
  String get cabin_legendFillEmpty;

  /// No description provided for @cabin_legendCountAssigned.
  ///
  /// In en, this message translates to:
  /// **'To count (has drug)'**
  String get cabin_legendCountAssigned;

  /// No description provided for @cabin_legendCountLow.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get cabin_legendCountLow;

  /// No description provided for @cabin_legendCountEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty (skip)'**
  String get cabin_legendCountEmpty;

  /// No description provided for @cabin_legendFaultNormal.
  ///
  /// In en, this message translates to:
  /// **'Operating normally'**
  String get cabin_legendFaultNormal;

  /// No description provided for @cabin_legendFaultReported.
  ///
  /// In en, this message translates to:
  /// **'Fault reported'**
  String get cabin_legendFaultReported;

  /// No description provided for @cabin_legendFaultEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty cell'**
  String get cabin_legendFaultEmpty;

  /// No description provided for @wizard_sidebarTitle.
  ///
  /// In en, this message translates to:
  /// **'Cabinet Setup'**
  String get wizard_sidebarTitle;

  /// No description provided for @wizard_sidebarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'New device configuration'**
  String get wizard_sidebarSubtitle;

  /// No description provided for @wizard_step1SidebarTitle.
  ///
  /// In en, this message translates to:
  /// **'Cabinet Type'**
  String get wizard_step1SidebarTitle;

  /// No description provided for @wizard_step1SidebarDesc.
  ///
  /// In en, this message translates to:
  /// **'Standard or Mobile'**
  String get wizard_step1SidebarDesc;

  /// No description provided for @wizard_step2SidebarTitle.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get wizard_step2SidebarTitle;

  /// No description provided for @wizard_step2SidebarDesc.
  ///
  /// In en, this message translates to:
  /// **'Name, location, connection'**
  String get wizard_step2SidebarDesc;

  /// No description provided for @wizard_step3SidebarTitle.
  ///
  /// In en, this message translates to:
  /// **'Service Scope'**
  String get wizard_step3SidebarTitle;

  /// No description provided for @wizard_step3SidebarDesc.
  ///
  /// In en, this message translates to:
  /// **'Ward or room definitions'**
  String get wizard_step3SidebarDesc;

  /// No description provided for @wizard_step4SidebarTitle.
  ///
  /// In en, this message translates to:
  /// **'Drawer Structure'**
  String get wizard_step4SidebarTitle;

  /// No description provided for @wizard_step4SidebarDesc.
  ///
  /// In en, this message translates to:
  /// **'Scan or manual entry'**
  String get wizard_step4SidebarDesc;

  /// No description provided for @wizard_step5SidebarTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get wizard_step5SidebarTitle;

  /// No description provided for @wizard_step5SidebarDesc.
  ///
  /// In en, this message translates to:
  /// **'Review and complete'**
  String get wizard_step5SidebarDesc;

  /// No description provided for @wizard_step1Header.
  ///
  /// In en, this message translates to:
  /// **'Select Cabinet Type'**
  String get wizard_step1Header;

  /// No description provided for @wizard_step1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Specify the type of cabinet you want to manage. This choice will shape the subsequent steps.'**
  String get wizard_step1Subtitle;

  /// No description provided for @wizard_cabinTypeNote.
  ///
  /// In en, this message translates to:
  /// **'Cabinet type cannot be changed later.'**
  String get wizard_cabinTypeNote;

  /// No description provided for @wizard_masterCabinSpec1.
  ///
  /// In en, this message translates to:
  /// **'Cubic / Unit Dose'**
  String get wizard_masterCabinSpec1;

  /// No description provided for @wizard_masterCabinSpec2.
  ///
  /// In en, this message translates to:
  /// **'Ward-Based'**
  String get wizard_masterCabinSpec2;

  /// No description provided for @wizard_masterCabinDescription.
  ///
  /// In en, this message translates to:
  /// **'Wall-mounted or freestanding cabinet with a combination of cubic and unit-dose drawers.'**
  String get wizard_masterCabinDescription;

  /// No description provided for @wizard_mobileCabinSpec1.
  ///
  /// In en, this message translates to:
  /// **'On Wheels'**
  String get wizard_mobileCabinSpec1;

  /// No description provided for @wizard_mobileCabinSpec2.
  ///
  /// In en, this message translates to:
  /// **'Room-Based'**
  String get wizard_mobileCabinSpec2;

  /// No description provided for @wizard_mobileCabinDescription.
  ///
  /// In en, this message translates to:
  /// **'Wheeled, portable 4-row medication unit designed for ward rounds.'**
  String get wizard_mobileCabinDescription;

  /// No description provided for @wizard_step2Header.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get wizard_step2Header;

  /// No description provided for @wizard_step2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the cabinet name, location, and device connection settings.'**
  String get wizard_step2Subtitle;

  /// No description provided for @wizard_cabinNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Cabinet Name'**
  String get wizard_cabinNameLabel;

  /// No description provided for @wizard_cabinNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. CB-304'**
  String get wizard_cabinNameHint;

  /// No description provided for @wizard_connectionSettingsLabel.
  ///
  /// In en, this message translates to:
  /// **'CONNECTION SETTINGS'**
  String get wizard_connectionSettingsLabel;

  /// No description provided for @wizard_noComPortWarning.
  ///
  /// In en, this message translates to:
  /// **'No active COM Port found. Make sure the drivers are installed.'**
  String get wizard_noComPortWarning;

  /// No description provided for @wizard_antennaSettingsLabel.
  ///
  /// In en, this message translates to:
  /// **'ANTENNA SETTINGS'**
  String get wizard_antennaSettingsLabel;

  /// No description provided for @wizard_ipAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'IP Address'**
  String get wizard_ipAddressLabel;

  /// No description provided for @wizard_testConnectionButton.
  ///
  /// In en, this message translates to:
  /// **'Test Connection'**
  String get wizard_testConnectionButton;

  /// No description provided for @wizard_step3Header.
  ///
  /// In en, this message translates to:
  /// **'Service Scope'**
  String get wizard_step3Header;

  /// No description provided for @wizard_step3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Ward or room definitions.'**
  String get wizard_step3Subtitle;

  /// No description provided for @wizard_roomBedSelectionLabel.
  ///
  /// In en, this message translates to:
  /// **'ROOM & BED SELECTION'**
  String get wizard_roomBedSelectionLabel;

  /// No description provided for @wizard_scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Device'**
  String get wizard_scanTitle;

  /// No description provided for @wizard_scanDescription.
  ///
  /// In en, this message translates to:
  /// **'The drawer structure of the connected cabinet will be read automatically via the serial port.'**
  String get wizard_scanDescription;

  /// No description provided for @wizard_startScanButton.
  ///
  /// In en, this message translates to:
  /// **'Start Scan'**
  String get wizard_startScanButton;

  /// No description provided for @wizard_scanningStatus.
  ///
  /// In en, this message translates to:
  /// **'Scanning Cabinet..'**
  String get wizard_scanningStatus;

  /// No description provided for @wizard_scanSuccessBanner.
  ///
  /// In en, this message translates to:
  /// **'Scan Successful — {count} drawers found'**
  String wizard_scanSuccessBanner(int count);

  /// No description provided for @wizard_scanSuccessDescription.
  ///
  /// In en, this message translates to:
  /// **'The cabinet\'s internal layout was read from the device successfully. Confirm the structure below.'**
  String get wizard_scanSuccessDescription;

  /// No description provided for @wizard_scanWrongStructure.
  ///
  /// In en, this message translates to:
  /// **'If the structure is incorrect, go back and check the connection details.'**
  String get wizard_scanWrongStructure;

  /// No description provided for @wizard_rescanButton.
  ///
  /// In en, this message translates to:
  /// **'Re-Scan'**
  String get wizard_rescanButton;

  /// No description provided for @wizard_scanErrorBanner.
  ///
  /// In en, this message translates to:
  /// **'Scan failed. Check the COM port connection and try again.'**
  String get wizard_scanErrorBanner;

  /// No description provided for @wizard_scanLogConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to serial port…'**
  String get wizard_scanLogConnecting;

  /// No description provided for @wizard_scanLogFetchingMetadata.
  ///
  /// In en, this message translates to:
  /// **'Loading drawer definitions…'**
  String get wizard_scanLogFetchingMetadata;

  /// No description provided for @wizard_scanLogSearchingManager.
  ///
  /// In en, this message translates to:
  /// **'Searching for management card…'**
  String get wizard_scanLogSearchingManager;

  /// No description provided for @wizard_scanLogScanningCards.
  ///
  /// In en, this message translates to:
  /// **'Scanning control cards…'**
  String get wizard_scanLogScanningCards;

  /// No description provided for @wizard_scanLogDrawerFound.
  ///
  /// In en, this message translates to:
  /// **'Drawer found'**
  String get wizard_scanLogDrawerFound;

  /// No description provided for @wizard_drawerLabel.
  ///
  /// In en, this message translates to:
  /// **'DRAWER {index}'**
  String wizard_drawerLabel(int index);

  /// No description provided for @wizard_cellCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} cells'**
  String wizard_cellCountLabel(int count);

  /// No description provided for @wizard_rowCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} rows'**
  String wizard_rowCountLabel(int count);

  /// No description provided for @wizard_drawerCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Drawer Count'**
  String get wizard_drawerCountLabel;

  /// No description provided for @wizard_addRowButton.
  ///
  /// In en, this message translates to:
  /// **'Add Row'**
  String get wizard_addRowButton;

  /// No description provided for @wizard_removeLastRowButton.
  ///
  /// In en, this message translates to:
  /// **'Remove Last Row'**
  String get wizard_removeLastRowButton;

  /// No description provided for @wizard_step5Header.
  ///
  /// In en, this message translates to:
  /// **'Summary & Complete'**
  String get wizard_step5Header;

  /// No description provided for @wizard_step5Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm the information you have entered. The setup will be completed after confirmation.'**
  String get wizard_step5Subtitle;

  /// No description provided for @wizard_summaryCabinInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'CABINET INFORMATION'**
  String get wizard_summaryCabinInfoTitle;

  /// No description provided for @wizard_summaryServiceScopeTitle.
  ///
  /// In en, this message translates to:
  /// **'SERVICE SCOPE'**
  String get wizard_summaryServiceScopeTitle;

  /// No description provided for @wizard_summaryDrawerStructureTitle.
  ///
  /// In en, this message translates to:
  /// **'DRAWER STRUCTURE'**
  String get wizard_summaryDrawerStructureTitle;

  /// No description provided for @wizard_summaryCabinPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'CABINET PREVIEW'**
  String get wizard_summaryCabinPreviewTitle;

  /// No description provided for @wizard_summaryLabelType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get wizard_summaryLabelType;

  /// No description provided for @wizard_summaryLabelName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get wizard_summaryLabelName;

  /// No description provided for @wizard_summaryLabelStation.
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get wizard_summaryLabelStation;

  /// No description provided for @wizard_summaryLabelRoomCount.
  ///
  /// In en, this message translates to:
  /// **'Room count'**
  String get wizard_summaryLabelRoomCount;

  /// No description provided for @wizard_summaryLabelRooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get wizard_summaryLabelRooms;

  /// No description provided for @wizard_summaryLabelBeds.
  ///
  /// In en, this message translates to:
  /// **'Beds'**
  String get wizard_summaryLabelBeds;

  /// No description provided for @wizard_summaryLabelDrawerCount.
  ///
  /// In en, this message translates to:
  /// **'Drawer count'**
  String get wizard_summaryLabelDrawerCount;

  /// No description provided for @wizard_summaryLabelTotalDrawers.
  ///
  /// In en, this message translates to:
  /// **'Total drawers'**
  String get wizard_summaryLabelTotalDrawers;

  /// No description provided for @wizard_summaryLabelDrawerIndexed.
  ///
  /// In en, this message translates to:
  /// **'Drawer {index}'**
  String wizard_summaryLabelDrawerIndexed(int index);

  /// No description provided for @wizard_summaryTypeMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile Cabinet'**
  String get wizard_summaryTypeMobile;

  /// No description provided for @wizard_summaryTypeStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard Cabinet'**
  String get wizard_summaryTypeStandard;

  /// No description provided for @wizard_summaryLabelComPort.
  ///
  /// In en, this message translates to:
  /// **'COM Port'**
  String get wizard_summaryLabelComPort;

  /// No description provided for @wizard_summaryLabelDvrIp.
  ///
  /// In en, this message translates to:
  /// **'DVR IP'**
  String get wizard_summaryLabelDvrIp;

  /// No description provided for @wizard_summaryLabelRfidAddress.
  ///
  /// In en, this message translates to:
  /// **'RFID Address'**
  String get wizard_summaryLabelRfidAddress;

  /// No description provided for @wizard_summaryLabelRfidPort.
  ///
  /// In en, this message translates to:
  /// **'RFID Port'**
  String get wizard_summaryLabelRfidPort;

  /// No description provided for @wizard_savingMessage.
  ///
  /// In en, this message translates to:
  /// **'Saving cabinet…'**
  String get wizard_savingMessage;

  /// No description provided for @wizard_successTitle.
  ///
  /// In en, this message translates to:
  /// **'Setup Complete!'**
  String get wizard_successTitle;

  /// No description provided for @wizard_successMessage.
  ///
  /// In en, this message translates to:
  /// **'{cabinName} has been successfully added to the system.'**
  String wizard_successMessage(String cabinName);

  /// No description provided for @wizard_successCabinId.
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

  /// No description provided for @wizard_successDashboardButton.
  ///
  /// In en, this message translates to:
  /// **'Go to Dashboard'**
  String get wizard_successDashboardButton;

  /// No description provided for @wizard_errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Failed'**
  String get wizard_errorTitle;

  /// No description provided for @wizard_retryButton.
  ///
  /// In en, this message translates to:
  /// **'Go Back and Retry'**
  String get wizard_retryButton;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_systemConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM CONFIGURATION'**
  String get settings_systemConfigTitle;

  /// No description provided for @settings_appearanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settings_appearanceLabel;

  /// No description provided for @settings_generalLabel.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settings_generalLabel;

  /// No description provided for @assignment_patientUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Patient assignment updated successfully'**
  String get assignment_patientUpdatedSuccess;

  /// No description provided for @fault_selectSlotPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select a drawer from the\nleft panel to report a fault.'**
  String get fault_selectSlotPlaceholder;

  /// No description provided for @assignment_bedSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Bed Selection'**
  String get assignment_bedSectionLabel;

  /// No description provided for @assignment_serviceSelectorHint.
  ///
  /// In en, this message translates to:
  /// **'Select a service'**
  String get assignment_serviceSelectorHint;

  /// No description provided for @assignment_roomSelectorHint.
  ///
  /// In en, this message translates to:
  /// **'Select a room'**
  String get assignment_roomSelectorHint;

  /// No description provided for @assignment_bedSelectorHint.
  ///
  /// In en, this message translates to:
  /// **'Select a bed'**
  String get assignment_bedSelectorHint;

  /// No description provided for @assignment_patientLabel.
  ///
  /// In en, this message translates to:
  /// **'PATIENT'**
  String get assignment_patientLabel;

  /// No description provided for @settings_languageTitle.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get settings_languageTitle;

  /// No description provided for @settings_languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Interface language'**
  String get settings_languageSubtitle;

  /// No description provided for @emptyState_cabinDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Cabinet data not found'**
  String get emptyState_cabinDataTitle;

  /// No description provided for @emptyState_cabinDataDescription.
  ///
  /// In en, this message translates to:
  /// **'The cabinet may not be configured yet\nor connection could not be established.'**
  String get emptyState_cabinDataDescription;

  /// No description provided for @emptyState_noResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get emptyState_noResultsTitle;

  /// No description provided for @emptyState_noResultsDescription.
  ///
  /// In en, this message translates to:
  /// **'Try changing your search criteria.'**
  String get emptyState_noResultsDescription;

  /// No description provided for @emptyState_noCellSelectedTitle.
  ///
  /// In en, this message translates to:
  /// **'No cell selected'**
  String get emptyState_noCellSelectedTitle;

  /// No description provided for @emptyState_noCellSelectedDescription.
  ///
  /// In en, this message translates to:
  /// **'Select a cell to start filling.'**
  String get emptyState_noCellSelectedDescription;

  /// No description provided for @emptyState_noPatientTitle.
  ///
  /// In en, this message translates to:
  /// **'No patient assigned'**
  String get emptyState_noPatientTitle;

  /// No description provided for @emptyState_noPatientDescription.
  ///
  /// In en, this message translates to:
  /// **'No patient has been assigned to this cell yet.'**
  String get emptyState_noPatientDescription;

  /// No description provided for @emptyState_noPrescriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'No prescription found'**
  String get emptyState_noPrescriptionTitle;

  /// No description provided for @emptyState_noPrescriptionDescription.
  ///
  /// In en, this message translates to:
  /// **'There are no active prescriptions for this patient.'**
  String get emptyState_noPrescriptionDescription;

  /// No description provided for @emptyState_noCabinTitle.
  ///
  /// In en, this message translates to:
  /// **'No Cabinet Found'**
  String get emptyState_noCabinTitle;

  /// No description provided for @emptyState_noCabinDescription.
  ///
  /// In en, this message translates to:
  /// **'No cabinet has been defined yet. Please define a cabinet to continue.'**
  String get emptyState_noCabinDescription;

  /// No description provided for @emptyState_networkErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get emptyState_networkErrorTitle;

  /// No description provided for @emptyState_networkErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'Please check your network connection and try again.'**
  String get emptyState_networkErrorDescription;

  /// No description provided for @emptyState_serverErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Server Unreachable'**
  String get emptyState_serverErrorTitle;

  /// No description provided for @emptyState_serverErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'The server could not be reached. Please try again later.'**
  String get emptyState_serverErrorDescription;

  /// No description provided for @emptyState_errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something Went Wrong'**
  String get emptyState_errorTitle;

  /// No description provided for @emptyState_errorDescription.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again or contact your system administrator.'**
  String get emptyState_errorDescription;

  /// No description provided for @emptyState_noDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get emptyState_noDataTitle;

  /// No description provided for @emptyState_noDataDescription.
  ///
  /// In en, this message translates to:
  /// **'There is no data to display yet.'**
  String get emptyState_noDataDescription;

  /// No description provided for @refund_noRefundableDrugs.
  ///
  /// In en, this message translates to:
  /// **'No refundable medications found for this patient.'**
  String get refund_noRefundableDrugs;

  /// No description provided for @refund_selectPatient.
  ///
  /// In en, this message translates to:
  /// **'Select a patient from the list on the left to start a refund.'**
  String get refund_selectPatient;

  /// No description provided for @waste_noWastableDrugs.
  ///
  /// In en, this message translates to:
  /// **'No disposable drugs found.'**
  String get waste_noWastableDrugs;

  /// No description provided for @waste_selectPatient.
  ///
  /// In en, this message translates to:
  /// **'Select a patient to proceed.'**
  String get waste_selectPatient;

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

  /// No description provided for @refill_success_completedMaster.
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

  /// No description provided for @refill_label_countQty.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get refill_label_countQty;

  /// No description provided for @refill_label_fillQty.
  ///
  /// In en, this message translates to:
  /// **'Fill quantity'**
  String get refill_label_fillQty;

  /// No description provided for @refill_label_expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get refill_label_expiryDate;

  /// No description provided for @refill_title_selectMedicines.
  ///
  /// In en, this message translates to:
  /// **'Select medicines to refill'**
  String get refill_title_selectMedicines;

  /// No description provided for @refill_title_autoRefill.
  ///
  /// In en, this message translates to:
  /// **'Auto refill'**
  String get refill_title_autoRefill;

  /// No description provided for @refill_label_selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String refill_label_selectedCount(int count);

  /// No description provided for @refill_label_cellCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} cell} other{{count} cells}}'**
  String refill_label_cellCount(int count);

  /// No description provided for @refill_label_multiMedicine.
  ///
  /// In en, this message translates to:
  /// **'{count} medicines'**
  String refill_label_multiMedicine(int count);

  /// No description provided for @refill_label_targetCells.
  ///
  /// In en, this message translates to:
  /// **'Cells to refill'**
  String get refill_label_targetCells;

  /// No description provided for @refill_label_queueProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} drawers'**
  String refill_label_queueProgress(int done, int total);

  /// No description provided for @refill_label_current.
  ///
  /// In en, this message translates to:
  /// **'Current: {qty}'**
  String refill_label_current(String qty);

  /// No description provided for @refill_chip_drawer.
  ///
  /// In en, this message translates to:
  /// **'Drawer {address}'**
  String refill_chip_drawer(String address);

  /// No description provided for @refill_chip_drawerCell.
  ///
  /// In en, this message translates to:
  /// **'Drawer {address} - Cell {cell}'**
  String refill_chip_drawerCell(String address, String cell);

  /// No description provided for @refill_subtitle_kubikCells.
  ///
  /// In en, this message translates to:
  /// **'Drawer {address} · {count, plural, one{{count} cell} other{{count} cells}}'**
  String refill_subtitle_kubikCells(String address, int count);

  /// No description provided for @refill_status_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get refill_status_done;

  /// No description provided for @refill_status_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get refill_status_open;

  /// No description provided for @refill_status_queued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get refill_status_queued;

  /// No description provided for @refill_status_drawerOpen.
  ///
  /// In en, this message translates to:
  /// **'Drawer open'**
  String get refill_status_drawerOpen;

  /// No description provided for @refill_status_drawerOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening drawer'**
  String get refill_status_drawerOpening;

  /// No description provided for @refill_hint_searchMedicine.
  ///
  /// In en, this message translates to:
  /// **'Search medicine…'**
  String get refill_hint_searchMedicine;

  /// No description provided for @refill_hint_noMedicines.
  ///
  /// In en, this message translates to:
  /// **'No medicines assigned to this cabinet'**
  String get refill_hint_noMedicines;

  /// No description provided for @refill_hint_autoQueueOrder.
  ///
  /// In en, this message translates to:
  /// **'Selected drawers open one by one; the next opens once the current is closed.'**
  String get refill_hint_autoQueueOrder;

  /// No description provided for @refill_hint_confirmCloses.
  ///
  /// In en, this message translates to:
  /// **'Saving will close the drawer and open the next one.'**
  String get refill_hint_confirmCloses;

  /// No description provided for @refill_action_startAuto.
  ///
  /// In en, this message translates to:
  /// **'Start auto refill'**
  String get refill_action_startAuto;

  /// No description provided for @refill_action_completeFilling.
  ///
  /// In en, this message translates to:
  /// **'Complete refill'**
  String get refill_action_completeFilling;

  /// No description provided for @refill_action_stop.
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

  /// No description provided for @unload_action_start.
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

  /// No description provided for @waste_action_wastage.
  ///
  /// In en, this message translates to:
  /// **'Wastage'**
  String get waste_action_wastage;

  /// No description provided for @waste_action_destruction.
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

  /// No description provided for @cabinStock_emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No stock for this patient'**
  String get cabinStock_emptyTitle;

  /// No description provided for @cabinStock_emptyDescription.
  ///
  /// In en, this message translates to:
  /// **'This patient has no medications stocked in this cabin yet.'**
  String get cabinStock_emptyDescription;

  /// No description provided for @prescription_unadministeredEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No pending prescriptions'**
  String get prescription_unadministeredEmptyTitle;

  /// No description provided for @prescription_unadministeredEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'There are no prescriptions waiting to be administered for this patient.'**
  String get prescription_unadministeredEmptyDescription;

  /// No description provided for @emptyState_noPatientSelectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a patient'**
  String get emptyState_noPatientSelectedTitle;

  /// No description provided for @emptyState_noPatientSelectedDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a patient from the list to view their details.'**
  String get emptyState_noPatientSelectedDescription;

  /// No description provided for @dateFilter_todayPreset.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateFilter_todayPreset;

  /// No description provided for @dateFilter_tomorrowPreset.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get dateFilter_tomorrowPreset;

  /// No description provided for @dateFilter_last3DaysPreset.
  ///
  /// In en, this message translates to:
  /// **'Last 3 days'**
  String get dateFilter_last3DaysPreset;

  /// No description provided for @dateFilter_last7DaysPreset.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get dateFilter_last7DaysPreset;

  /// No description provided for @dateFilter_allPreset.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get dateFilter_allPreset;

  /// No description provided for @filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filter_all;

  /// No description provided for @census_action_reportExtraStock.
  ///
  /// In en, this message translates to:
  /// **'Report Extra Stock'**
  String get census_action_reportExtraStock;

  /// No description provided for @census_extraStockDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Extra Stock'**
  String get census_extraStockDialogTitle;

  /// No description provided for @census_extraStockQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get census_extraStockQuantityLabel;

  /// No description provided for @common_action_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get common_action_add;

  /// No description provided for @census_extraStockSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Reported Extra Stocks'**
  String get census_extraStockSummaryTitle;

  /// No description provided for @core_serialPortDisconnectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Not Connected'**
  String get core_serialPortDisconnectedLabel;

  /// No description provided for @core_serialConnectingStatus.
  ///
  /// In en, this message translates to:
  /// **'Connecting to port: {portName}...'**
  String core_serialConnectingStatus(String portName);

  /// No description provided for @core_serialConnectSuccessStatus.
  ///
  /// In en, this message translates to:
  /// **'Connected successfully: {portName}'**
  String core_serialConnectSuccessStatus(String portName);

  /// No description provided for @core_serialPortFailedScanningOthersStatus.
  ///
  /// In en, this message translates to:
  /// **'{portName} failed. Scanning other ports...'**
  String core_serialPortFailedScanningOthersStatus(String portName);

  /// No description provided for @core_serialNoOtherPortsError.
  ///
  /// In en, this message translates to:
  /// **'The default port ({portName}) failed and no other port was found.'**
  String core_serialNoOtherPortsError(String portName);

  /// No description provided for @core_serialTryingPortStatus.
  ///
  /// In en, this message translates to:
  /// **'Trying: {portName}...'**
  String core_serialTryingPortStatus(String portName);

  /// No description provided for @core_serialConnectionEstablishedStatus.
  ///
  /// In en, this message translates to:
  /// **'Connection established: {portName}'**
  String core_serialConnectionEstablishedStatus(String portName);

  /// No description provided for @core_serialNoPortConnectedError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to any port. Check the cables.'**
  String get core_serialNoPortConnectedError;

  /// No description provided for @core_serialPortOpenFailedError.
  ///
  /// In en, this message translates to:
  /// **'The port could not be opened ({portName}).'**
  String core_serialPortOpenFailedError(String portName);

  /// No description provided for @core_serialNoConnectionError.
  ///
  /// In en, this message translates to:
  /// **'No connection.'**
  String get core_serialNoConnectionError;

  /// No description provided for @core_serialPortBusyTimeoutError.
  ///
  /// In en, this message translates to:
  /// **'Port timed out.'**
  String get core_serialPortBusyTimeoutError;

  /// No description provided for @core_serialWriteFailedError.
  ///
  /// In en, this message translates to:
  /// **'Write failed.'**
  String get core_serialWriteFailedError;

  /// No description provided for @common_defaultSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Operation successful'**
  String get common_defaultSuccessMessage;

  /// No description provided for @common_operationSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your operation was completed successfully.'**
  String get common_operationSuccessMessage;

  /// No description provided for @common_loadingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loadingEllipsis;

  /// No description provided for @common_searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get common_searchHint;

  /// No description provided for @common_searchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get common_searchTooltip;

  /// No description provided for @common_addTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get common_addTooltip;

  /// No description provided for @common_closeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_closeTooltip;

  /// No description provided for @common_saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_saveButton;

  /// No description provided for @common_editTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_editTooltip;

  /// No description provided for @common_deleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_deleteTooltip;

  /// No description provided for @common_statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get common_statusLabel;

  /// No description provided for @common_emptyListMessage.
  ///
  /// In en, this message translates to:
  /// **'The list is currently empty'**
  String get common_emptyListMessage;

  /// No description provided for @common_nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get common_nameLabel;

  /// No description provided for @common_requiredFieldsError.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the required fields.'**
  String get common_requiredFieldsError;

  /// No description provided for @common_descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get common_descriptionLabel;

  /// No description provided for @common_deselectAllButton.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get common_deselectAllButton;

  /// No description provided for @common_selectAllButton.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get common_selectAllButton;

  /// No description provided for @common_defaultUnitFallback.
  ///
  /// In en, this message translates to:
  /// **'Piece'**
  String get common_defaultUnitFallback;

  /// No description provided for @common_flagFirstDoseEmergency.
  ///
  /// In en, this message translates to:
  /// **'First Dose Emergency'**
  String get common_flagFirstDoseEmergency;

  /// No description provided for @common_flagAskDoctor.
  ///
  /// In en, this message translates to:
  /// **'Ask Doctor'**
  String get common_flagAskDoctor;

  /// No description provided for @common_flagInCaseOfNecessity.
  ///
  /// In en, this message translates to:
  /// **'As Needed'**
  String get common_flagInCaseOfNecessity;

  /// No description provided for @common_addItemHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the \"+\" button to add a new {item}'**
  String common_addItemHint(String item);

  /// No description provided for @common_genericErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get common_genericErrorMessage;

  /// No description provided for @hospitalizationCard_noDoctorFallback.
  ///
  /// In en, this message translates to:
  /// **'No Doctor Specified'**
  String get hospitalizationCard_noDoctorFallback;

  /// No description provided for @hospitalizationCard_nationalIdLabel.
  ///
  /// In en, this message translates to:
  /// **'National ID No.'**
  String get hospitalizationCard_nationalIdLabel;

  /// No description provided for @hospitalizationCard_admissionDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Admission Date'**
  String get hospitalizationCard_admissionDateLabel;

  /// No description provided for @menuBrowser_categoriesHeader.
  ///
  /// In en, this message translates to:
  /// **'CATEGORIES'**
  String get menuBrowser_categoriesHeader;

  /// No description provided for @menuBrowser_searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search category...'**
  String get menuBrowser_searchHint;

  /// No description provided for @menuBrowser_selectionCountBadge.
  ///
  /// In en, this message translates to:
  /// **'{selected}/{total}'**
  String menuBrowser_selectionCountBadge(int selected, int total);

  /// No description provided for @menuBrowser_emptyCategoryMessage.
  ///
  /// In en, this message translates to:
  /// **'No menu found in this category'**
  String get menuBrowser_emptyCategoryMessage;

  /// No description provided for @rxGroup_headerTitle.
  ///
  /// In en, this message translates to:
  /// **'Prescription #{id}'**
  String rxGroup_headerTitle(Object id);

  /// No description provided for @rxGroup_headerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{doctorName} · {date}'**
  String rxGroup_headerSubtitle(String doctorName, String date);

  /// No description provided for @rxGroup_itemCountBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String rxGroup_itemCountBadge(int count);

  /// No description provided for @rxGroup_selectableCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} actionable items'**
  String rxGroup_selectableCountLabel(int count);

  /// No description provided for @rxGroup_unknownDoctorFallback.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get rxGroup_unknownDoctorFallback;

  /// No description provided for @rxGroup_rfidTagLabel.
  ///
  /// In en, this message translates to:
  /// **'RFID TAG'**
  String get rxGroup_rfidTagLabel;

  /// No description provided for @rxGroup_rfidTagLoadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Waiting for tag...'**
  String get rxGroup_rfidTagLoadingLabel;

  /// No description provided for @rxGroup_rfidTagUnassignedLabel.
  ///
  /// In en, this message translates to:
  /// **'No tag assigned yet'**
  String get rxGroup_rfidTagUnassignedLabel;

  /// No description provided for @rxGroup_rfidChangeButton.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get rxGroup_rfidChangeButton;

  /// No description provided for @rxGroup_rfidAssignButton.
  ///
  /// In en, this message translates to:
  /// **'Assign Tag'**
  String get rxGroup_rfidAssignButton;

  /// No description provided for @rxGroup_selectedCountBar.
  ///
  /// In en, this message translates to:
  /// **'{count} items selected'**
  String rxGroup_selectedCountBar(int count);

  /// No description provided for @rxGroup_approveAction.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get rxGroup_approveAction;

  /// No description provided for @rxGroup_rejectAction.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rxGroup_rejectAction;

  /// No description provided for @changePassword_dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword_dialogTitle;

  /// No description provided for @changePassword_currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get changePassword_currentPasswordLabel;

  /// No description provided for @changePassword_newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get changePassword_newPasswordLabel;

  /// No description provided for @changePassword_confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get changePassword_confirmPasswordLabel;

  /// No description provided for @changePassword_submitButton.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword_submitButton;

  /// No description provided for @home_appBarBadgeLabel.
  ///
  /// In en, this message translates to:
  /// **'MANAGEMENT PANEL'**
  String get home_appBarBadgeLabel;

  /// No description provided for @home_devSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Developer Settings'**
  String get home_devSettingsTooltip;

  /// No description provided for @home_noAuthorizedMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'No Authorized Menu Found'**
  String get home_noAuthorizedMenuTitle;

  /// No description provided for @home_noAuthorizedMenuDescription.
  ///
  /// In en, this message translates to:
  /// **'Your account has no access permissions defined.\nPlease contact your system administrator to obtain access.'**
  String get home_noAuthorizedMenuDescription;

  /// No description provided for @branch_listDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Branch Definition'**
  String get branch_listDialogTitle;

  /// No description provided for @branch_addTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Branch'**
  String get branch_addTitle;

  /// No description provided for @branch_editTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Branch'**
  String get branch_editTitle;

  /// No description provided for @branch_nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Branch Name'**
  String get branch_nameLabel;

  /// No description provided for @firm_createSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Firm created successfully'**
  String get firm_createSuccessMessage;

  /// No description provided for @firm_updateSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Firm updated successfully'**
  String get firm_updateSuccessMessage;

  /// No description provided for @firm_createPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'New Firm'**
  String get firm_createPanelTitle;

  /// No description provided for @firm_editPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Firm'**
  String get firm_editPanelTitle;

  /// No description provided for @firm_createPanelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in the firm details'**
  String get firm_createPanelSubtitle;

  /// No description provided for @firm_editPanelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update the firm details'**
  String get firm_editPanelSubtitle;

  /// No description provided for @firm_nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Firm Name'**
  String get firm_nameLabel;

  /// No description provided for @firm_taxNoLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax No.'**
  String get firm_taxNoLabel;

  /// No description provided for @firm_taxOfficeLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax Office'**
  String get firm_taxOfficeLabel;

  /// No description provided for @firm_typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Firm Type'**
  String get firm_typeLabel;

  /// No description provided for @firm_screenDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Firm Definition'**
  String get firm_screenDefaultTitle;

  /// No description provided for @dosageForm_deleteSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'The dosage form was deleted successfully.'**
  String get dosageForm_deleteSuccessMessage;

  /// No description provided for @dosageForm_saveSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'The dosage form was saved successfully.'**
  String get dosageForm_saveSuccessMessage;

  /// No description provided for @dosageForm_createTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Dosage Form'**
  String get dosageForm_createTitle;

  /// No description provided for @dosageForm_editTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Dosage Form'**
  String get dosageForm_editTitle;

  /// No description provided for @dosageForm_listDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Dosage Form'**
  String get dosageForm_listDialogTitle;

  /// No description provided for @dosageForm_emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No dosage forms yet'**
  String get dosageForm_emptyTitle;

  /// No description provided for @dosageForm_emptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap the \"+\" button to create a dosage form'**
  String get dosageForm_emptyDescription;

  /// No description provided for @authorization_userTabTitle.
  ///
  /// In en, this message translates to:
  /// **'User Authorization'**
  String get authorization_userTabTitle;

  /// No description provided for @authorization_roleTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Role Authorization'**
  String get authorization_roleTabTitle;

  /// No description provided for @authorization_screenTitleFallback.
  ///
  /// In en, this message translates to:
  /// **'User/Role Authorization'**
  String get authorization_screenTitleFallback;

  /// No description provided for @authorization_rolePanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Role Authorization - {roleName}'**
  String authorization_rolePanelTitle(String roleName);

  /// No description provided for @authorization_tabMenuLabel.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get authorization_tabMenuLabel;

  /// No description provided for @authorization_tabDrugLabel.
  ///
  /// In en, this message translates to:
  /// **'Drug'**
  String get authorization_tabDrugLabel;

  /// No description provided for @authorization_tabConsumableLabel.
  ///
  /// In en, this message translates to:
  /// **'Medical Consumable'**
  String get authorization_tabConsumableLabel;

  /// No description provided for @authorization_drugTable_pullColumn.
  ///
  /// In en, this message translates to:
  /// **'Pull Drug'**
  String get authorization_drugTable_pullColumn;

  /// No description provided for @authorization_drugTable_fillColumn.
  ///
  /// In en, this message translates to:
  /// **'Refill'**
  String get authorization_drugTable_fillColumn;

  /// No description provided for @authorization_drugTable_returnColumn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get authorization_drugTable_returnColumn;

  /// No description provided for @authorization_drugTable_disposeColumn.
  ///
  /// In en, this message translates to:
  /// **'Dispose'**
  String get authorization_drugTable_disposeColumn;

  /// No description provided for @authorization_drugTable_allDrugsRow.
  ///
  /// In en, this message translates to:
  /// **'All Drugs'**
  String get authorization_drugTable_allDrugsRow;

  /// No description provided for @authorization_drugTable_unknownDrugFallback.
  ///
  /// In en, this message translates to:
  /// **'Unknown Drug'**
  String get authorization_drugTable_unknownDrugFallback;

  /// No description provided for @settings_updateSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Settings updated successfully.'**
  String get settings_updateSuccessMessage;

  /// No description provided for @settingsCabin_drawerOpenWaitLabel.
  ///
  /// In en, this message translates to:
  /// **'Drawer Open Wait Time (seconds)'**
  String get settingsCabin_drawerOpenWaitLabel;

  /// No description provided for @settingsCabin_drawerOpenWaitDescription.
  ///
  /// In en, this message translates to:
  /// **'Specifies when the system will send a close command to the drawer if it is left open.'**
  String get settingsCabin_drawerOpenWaitDescription;

  /// No description provided for @settingsDeveloper_adminDashboardActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard Active'**
  String get settingsDeveloper_adminDashboardActiveLabel;

  /// No description provided for @settingsDeveloper_appModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Application Mode'**
  String get settingsDeveloper_appModeLabel;

  /// No description provided for @settingsDeveloper_clientModeButton.
  ///
  /// In en, this message translates to:
  /// **'Client Mode'**
  String get settingsDeveloper_clientModeButton;

  /// No description provided for @settingsDeveloper_managerModeButton.
  ///
  /// In en, this message translates to:
  /// **'Manager Mode'**
  String get settingsDeveloper_managerModeButton;

  /// No description provided for @settingsGeneral_autoStandbyDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Auto-Standby Duration (seconds)'**
  String get settingsGeneral_autoStandbyDurationLabel;

  /// No description provided for @settingsGeneral_expiryWarningLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry Warning'**
  String get settingsGeneral_expiryWarningLabel;

  /// No description provided for @settingsGeneral_hbysStockControlLabel.
  ///
  /// In en, this message translates to:
  /// **'HIS Stock Control'**
  String get settingsGeneral_hbysStockControlLabel;

  /// No description provided for @settingsGeneral_fingerprintOnlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Only allow fingerprint reader use on cabinets.'**
  String get settingsGeneral_fingerprintOnlyLabel;

  /// No description provided for @settingsGeneral_allowOutOfWindowOrdersLabel.
  ///
  /// In en, this message translates to:
  /// **'Orders outside the time window may be accepted.'**
  String get settingsGeneral_allowOutOfWindowOrdersLabel;

  /// No description provided for @settingsGeneral_perCellExpiryDateLabel.
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

  /// No description provided for @settingsPrescription_accessDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Prescription Access Duration (minutes)'**
  String get settingsPrescription_accessDurationLabel;

  /// No description provided for @settingsPrescription_accessDurationDescription.
  ///
  /// In en, this message translates to:
  /// **'Specifies how long before and after product pickup times prescriptions remain accessible.'**
  String get settingsPrescription_accessDurationDescription;

  /// No description provided for @settingsView_cabinTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Cabinet Communication Settings'**
  String get settingsView_cabinTabTitle;

  /// No description provided for @settingsView_prescriptionTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Prescription Settings'**
  String get settingsView_prescriptionTabTitle;

  /// No description provided for @settingsView_generalTabTitle.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get settingsView_generalTabTitle;

  /// No description provided for @settingsView_developerTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Developer Settings'**
  String get settingsView_developerTabTitle;

  /// No description provided for @settingsView_refreshPermissionsButton.
  ///
  /// In en, this message translates to:
  /// **'Refresh Permissions'**
  String get settingsView_refreshPermissionsButton;

  /// No description provided for @stationSetup_defaultRoomName.
  ///
  /// In en, this message translates to:
  /// **'Room {index}'**
  String stationSetup_defaultRoomName(int index);

  /// No description provided for @stationSetup_service_createdSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Service created successfully'**
  String get stationSetup_service_createdSuccessMessage;

  /// No description provided for @stationSetup_service_updatedSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Service updated successfully'**
  String get stationSetup_service_updatedSuccessMessage;

  /// No description provided for @stationSetup_roomsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Rooms & Beds'**
  String get stationSetup_roomsSectionTitle;

  /// No description provided for @stationSetup_roomsBedsSummary.
  ///
  /// In en, this message translates to:
  /// **'{roomCount} rooms · {bedCount} beds'**
  String stationSetup_roomsBedsSummary(int roomCount, int bedCount);

  /// No description provided for @stationSetup_addRoomButton.
  ///
  /// In en, this message translates to:
  /// **'Add Room'**
  String get stationSetup_addRoomButton;

  /// No description provided for @stationSetup_bedCountBadge.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} bed} other{{count} beds}}'**
  String stationSetup_bedCountBadge(int count);

  /// No description provided for @stationSetup_noBedsAddedYetMessage.
  ///
  /// In en, this message translates to:
  /// **'No beds added yet'**
  String get stationSetup_noBedsAddedYetMessage;

  /// No description provided for @stationSetup_addBedButton.
  ///
  /// In en, this message translates to:
  /// **'Add Bed'**
  String get stationSetup_addBedButton;

  /// No description provided for @stationSetup_service_formTitleNew.
  ///
  /// In en, this message translates to:
  /// **'New Service'**
  String get stationSetup_service_formTitleNew;

  /// No description provided for @stationSetup_service_formTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Service'**
  String get stationSetup_service_formTitleEdit;

  /// No description provided for @stationSetup_service_formSubtitleNew.
  ///
  /// In en, this message translates to:
  /// **'Fill in the service details'**
  String get stationSetup_service_formSubtitleNew;

  /// No description provided for @stationSetup_service_formSubtitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Update the service details'**
  String get stationSetup_service_formSubtitleEdit;

  /// No description provided for @stationSetup_service_nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Service Name'**
  String get stationSetup_service_nameLabel;

  /// No description provided for @stationSetup_service_branchLabel.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get stationSetup_service_branchLabel;

  /// No description provided for @stationSetup_service_branchSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Branch'**
  String get stationSetup_service_branchSelectTitle;

  /// No description provided for @stationSetup_service_userLabel.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get stationSetup_service_userLabel;

  /// No description provided for @stationSetup_common_statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get stationSetup_common_statusLabel;

  /// No description provided for @stationSetup_station_createdSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Station created successfully'**
  String get stationSetup_station_createdSuccessMessage;

  /// No description provided for @stationSetup_station_updatedSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Station updated successfully'**
  String get stationSetup_station_updatedSuccessMessage;

  /// No description provided for @stationSetup_station_formTitleNew.
  ///
  /// In en, this message translates to:
  /// **'New Station'**
  String get stationSetup_station_formTitleNew;

  /// No description provided for @stationSetup_station_formTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Station'**
  String get stationSetup_station_formTitleEdit;

  /// No description provided for @stationSetup_station_formSubtitleNew.
  ///
  /// In en, this message translates to:
  /// **'Fill in the station details'**
  String get stationSetup_station_formSubtitleNew;

  /// No description provided for @stationSetup_station_formSubtitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Update the station details'**
  String get stationSetup_station_formSubtitleEdit;

  /// No description provided for @stationSetup_station_nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Station Name'**
  String get stationSetup_station_nameLabel;

  /// No description provided for @stationSetup_station_drugWarehouseLabel.
  ///
  /// In en, this message translates to:
  /// **'Drug Warehouse'**
  String get stationSetup_station_drugWarehouseLabel;

  /// No description provided for @stationSetup_station_drugWarehouseSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Drug Warehouse'**
  String get stationSetup_station_drugWarehouseSelectTitle;

  /// No description provided for @stationSetup_station_drugStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Drug Status'**
  String get stationSetup_station_drugStatusLabel;

  /// No description provided for @stationSetup_station_consumableWarehouseLabel.
  ///
  /// In en, this message translates to:
  /// **'Medical Consumable Warehouse'**
  String get stationSetup_station_consumableWarehouseLabel;

  /// No description provided for @stationSetup_station_consumableWarehouseSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Medical Consumable Warehouse'**
  String get stationSetup_station_consumableWarehouseSelectTitle;

  /// No description provided for @stationSetup_station_consumableStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Medical Consumable Status'**
  String get stationSetup_station_consumableStatusLabel;

  /// No description provided for @stationSetup_station_serviceLabel.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get stationSetup_station_serviceLabel;

  /// No description provided for @stationSetup_station_serviceSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Service'**
  String get stationSetup_station_serviceSelectTitle;

  /// No description provided for @stationSetup_station_providedServicesLabel.
  ///
  /// In en, this message translates to:
  /// **'Services Served'**
  String get stationSetup_station_providedServicesLabel;

  /// No description provided for @stationSetup_station_typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Station Type'**
  String get stationSetup_station_typeLabel;

  /// No description provided for @stationSetup_station_typePatientBasedLabel.
  ///
  /// In en, this message translates to:
  /// **'Patient-Based'**
  String get stationSetup_station_typePatientBasedLabel;

  /// No description provided for @stationSetup_station_typeMedicineBasedLabel.
  ///
  /// In en, this message translates to:
  /// **'Medicine-Based'**
  String get stationSetup_station_typeMedicineBasedLabel;

  /// No description provided for @stationSetup_warehouse_createdSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Warehouse created successfully'**
  String get stationSetup_warehouse_createdSuccessMessage;

  /// No description provided for @stationSetup_warehouse_updatedSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Warehouse updated successfully'**
  String get stationSetup_warehouse_updatedSuccessMessage;

  /// No description provided for @stationSetup_warehouse_formTitleNew.
  ///
  /// In en, this message translates to:
  /// **'New Warehouse'**
  String get stationSetup_warehouse_formTitleNew;

  /// No description provided for @stationSetup_warehouse_formTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Warehouse'**
  String get stationSetup_warehouse_formTitleEdit;

  /// No description provided for @stationSetup_warehouse_formSubtitleNew.
  ///
  /// In en, this message translates to:
  /// **'Fill in the warehouse details'**
  String get stationSetup_warehouse_formSubtitleNew;

  /// No description provided for @stationSetup_warehouse_formSubtitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Update the warehouse details'**
  String get stationSetup_warehouse_formSubtitleEdit;

  /// No description provided for @stationSetup_warehouse_codeLabel.
  ///
  /// In en, this message translates to:
  /// **'Warehouse Code'**
  String get stationSetup_warehouse_codeLabel;

  /// No description provided for @stationSetup_warehouse_nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Warehouse Name'**
  String get stationSetup_warehouse_nameLabel;

  /// No description provided for @stationSetup_warehouse_typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Warehouse Type'**
  String get stationSetup_warehouse_typeLabel;

  /// No description provided for @stationSetup_warehouse_managerLabel.
  ///
  /// In en, this message translates to:
  /// **'Warehouse Manager'**
  String get stationSetup_warehouse_managerLabel;

  /// No description provided for @stationSetup_warehouse_managerSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Warehouse Manager'**
  String get stationSetup_warehouse_managerSelectTitle;

  /// No description provided for @stationSetup_screen_stationTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Station Definition'**
  String get stationSetup_screen_stationTabTitle;

  /// No description provided for @stationSetup_screen_serviceTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Service Definition'**
  String get stationSetup_screen_serviceTabTitle;

  /// No description provided for @stationSetup_screen_warehouseTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Warehouse Definition'**
  String get stationSetup_screen_warehouseTabTitle;

  /// No description provided for @stationSetup_screen_setupWizardButton.
  ///
  /// In en, this message translates to:
  /// **'Setup Wizard'**
  String get stationSetup_screen_setupWizardButton;

  /// No description provided for @stationSetup_wizard_title.
  ///
  /// In en, this message translates to:
  /// **'Station Setup Wizard'**
  String get stationSetup_wizard_title;

  /// No description provided for @stationSetup_wizard_completeSetupButton.
  ///
  /// In en, this message translates to:
  /// **'Complete Setup'**
  String get stationSetup_wizard_completeSetupButton;

  /// No description provided for @stationSetup_wizard_continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get stationSetup_wizard_continueButton;

  /// No description provided for @stationSetup_wizard_backButton.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get stationSetup_wizard_backButton;

  /// No description provided for @unappliedPrescription_detailDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Material List'**
  String get unappliedPrescription_detailDialogTitle;

  /// No description provided for @unappliedPrescription_screenTitleFallback.
  ///
  /// In en, this message translates to:
  /// **'Unapplied Prescriptions'**
  String get unappliedPrescription_screenTitleFallback;

  /// No description provided for @unappliedPrescription_viewDetailsTooltip.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get unappliedPrescription_viewDetailsTooltip;

  /// No description provided for @dashboard_cabinsLoadErrorFallback.
  ///
  /// In en, this message translates to:
  /// **'Cabinets could not be loaded'**
  String get dashboard_cabinsLoadErrorFallback;

  /// No description provided for @dashboard_cabinListStaleLabel.
  ///
  /// In en, this message translates to:
  /// **'Cabinet list is out of date'**
  String get dashboard_cabinListStaleLabel;

  /// No description provided for @dashboardDrugActivityPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'DRUG ACTIVITY'**
  String get dashboardDrugActivityPanelTitle;

  /// No description provided for @dashboardDrugActivityEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No activity'**
  String get dashboardDrugActivityEmptyTitle;

  /// No description provided for @dashboard_drugActivityDateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'DATE / TIME'**
  String get dashboard_drugActivityDateTimeLabel;

  /// No description provided for @dashboard_missingStockPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'MISSING STOCK REPORTS'**
  String get dashboard_missingStockPanelTitle;

  /// No description provided for @dashboard_missingStockEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No missing stock reports'**
  String get dashboard_missingStockEmptyTitle;

  /// No description provided for @dashboard_missingStockTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get dashboard_missingStockTimeLabel;

  /// No description provided for @dashboard_missingStockApproveButton.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get dashboard_missingStockApproveButton;

  /// No description provided for @dashboard_missingStockRejectButton.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get dashboard_missingStockRejectButton;

  /// No description provided for @dashboard_otherCabinPlaceholderText.
  ///
  /// In en, this message translates to:
  /// **'Expired materials & critical stock (coming next)'**
  String get dashboard_otherCabinPlaceholderText;

  /// No description provided for @dashboard_unappliedPrescriptionsPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'UNAPPLIED PRESCRIPTIONS'**
  String get dashboard_unappliedPrescriptionsPanelTitle;

  /// No description provided for @dashboard_unappliedPrescriptionsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No unapplied prescriptions'**
  String get dashboard_unappliedPrescriptionsEmptyTitle;

  /// No description provided for @dashboard_doctorLabel.
  ///
  /// In en, this message translates to:
  /// **'DOCTOR'**
  String get dashboard_doctorLabel;

  /// No description provided for @dashboard_roomBedLabel.
  ///
  /// In en, this message translates to:
  /// **'ROOM / BED'**
  String get dashboard_roomBedLabel;

  /// No description provided for @dashboardUpcomingTreatmentsPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING TREATMENTS'**
  String get dashboardUpcomingTreatmentsPanelTitle;

  /// No description provided for @dashboardUpcomingTreatmentsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No upcoming treatments'**
  String get dashboardUpcomingTreatmentsEmptyTitle;

  /// No description provided for @dashboard_listPanelLoadErrorFallback.
  ///
  /// In en, this message translates to:
  /// **'Could not load'**
  String get dashboard_listPanelLoadErrorFallback;

  /// No description provided for @prescription_actionCompletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'The operation was completed successfully.'**
  String get prescription_actionCompletedSuccess;

  /// No description provided for @prescription_approvedSuccess.
  ///
  /// In en, this message translates to:
  /// **'The prescription was approved successfully.'**
  String get prescription_approvedSuccess;

  /// No description provided for @prescription_detailPanelPatientFallback.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get prescription_detailPanelPatientFallback;

  /// No description provided for @prescription_detailPanelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prescription History'**
  String get prescription_detailPanelSubtitle;

  /// No description provided for @prescription_detailStartDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get prescription_detailStartDateLabel;

  /// No description provided for @prescription_detailEndDateLabel.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get prescription_detailEndDateLabel;

  /// No description provided for @prescription_detailStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get prescription_detailStatusLabel;

  /// No description provided for @prescription_checkWarningDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Check Warning'**
  String get prescription_checkWarningDialogTitle;

  /// No description provided for @prescription_saveWithTemplateSuccess.
  ///
  /// In en, this message translates to:
  /// **'The prescription and template were saved successfully.'**
  String get prescription_saveWithTemplateSuccess;

  /// No description provided for @prescription_savedTemplateFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'The prescription was saved, but the template could not be saved.'**
  String get prescription_savedTemplateFailedMessage;

  /// No description provided for @prescription_savedSuccess.
  ///
  /// In en, this message translates to:
  /// **'The prescription was saved successfully.'**
  String get prescription_savedSuccess;

  /// No description provided for @prescription_creatingLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Creating prescription. Please wait.'**
  String get prescription_creatingLoadingMessage;

  /// No description provided for @prescription_templateSavingLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Saving template.'**
  String get prescription_templateSavingLoadingMessage;

  /// No description provided for @prescription_newTitle.
  ///
  /// In en, this message translates to:
  /// **'New Prescription'**
  String get prescription_newTitle;

  /// No description provided for @prescription_newDialogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a prescription or import one from history'**
  String get prescription_newDialogSubtitle;

  /// No description provided for @prescription_tabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get prescription_tabHistory;

  /// No description provided for @prescription_tabTemplates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get prescription_tabTemplates;

  /// No description provided for @prescription_contentEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any medicine to the prescription yet.'**
  String get prescription_contentEmptyTitle;

  /// No description provided for @prescription_contentEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'The medicines you add will be displayed here.'**
  String get prescription_contentEmptyDescription;

  /// No description provided for @prescription_itemNoTimesLabel.
  ///
  /// In en, this message translates to:
  /// **'No times added'**
  String get prescription_itemNoTimesLabel;

  /// No description provided for @prescription_itemNoMedicineSelected.
  ///
  /// In en, this message translates to:
  /// **'No medicine selected yet'**
  String get prescription_itemNoMedicineSelected;

  /// No description provided for @prescription_patientFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get prescription_patientFieldLabel;

  /// No description provided for @prescription_doctorFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get prescription_doctorFieldLabel;

  /// No description provided for @prescription_saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Prescription'**
  String get prescription_saveButton;

  /// No description provided for @prescription_saveAsTemplateCheckboxLabel.
  ///
  /// In en, this message translates to:
  /// **'Also save as template'**
  String get prescription_saveAsTemplateCheckboxLabel;

  /// No description provided for @prescription_templateNameHint.
  ///
  /// In en, this message translates to:
  /// **'Template Name'**
  String get prescription_templateNameHint;

  /// No description provided for @prescription_medicineFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Medicine / Material'**
  String get prescription_medicineFieldLabel;

  /// No description provided for @prescription_descriptionFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get prescription_descriptionFieldLabel;

  /// No description provided for @prescription_tomorrowLabel.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get prescription_tomorrowLabel;

  /// No description provided for @prescription_timesLabel.
  ///
  /// In en, this message translates to:
  /// **'Times'**
  String get prescription_timesLabel;

  /// No description provided for @prescription_addTimeButton.
  ///
  /// In en, this message translates to:
  /// **'Add time'**
  String get prescription_addTimeButton;

  /// No description provided for @prescription_historySelectPatientTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a patient'**
  String get prescription_historySelectPatientTitle;

  /// No description provided for @prescription_historySelectPatientDescription.
  ///
  /// In en, this message translates to:
  /// **'Select a patient first to view their prescription history'**
  String get prescription_historySelectPatientDescription;

  /// No description provided for @prescription_historyEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'This patient has no prescription history'**
  String get prescription_historyEmptyDescription;

  /// No description provided for @prescription_addToRxButton.
  ///
  /// In en, this message translates to:
  /// **'Add to Prescription ({count})'**
  String prescription_addToRxButton(int count);

  /// No description provided for @prescription_templateEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No template found'**
  String get prescription_templateEmptyTitle;

  /// No description provided for @prescription_templateEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'There is no saved prescription template'**
  String get prescription_templateEmptyDescription;

  /// No description provided for @prescription_templateNoItemsMessage.
  ///
  /// In en, this message translates to:
  /// **'This template has no items'**
  String get prescription_templateNoItemsMessage;

  /// No description provided for @prescription_screenTitleFallback.
  ///
  /// In en, this message translates to:
  /// **'Prescription Operations'**
  String get prescription_screenTitleFallback;

  /// No description provided for @prescription_contentTooltip.
  ///
  /// In en, this message translates to:
  /// **'Prescription Content'**
  String get prescription_contentTooltip;

  /// No description provided for @prescription_showActiveButton.
  ///
  /// In en, this message translates to:
  /// **'Show active admissions'**
  String get prescription_showActiveButton;

  /// No description provided for @prescription_showDischargedButton.
  ///
  /// In en, this message translates to:
  /// **'Show discharged patients'**
  String get prescription_showDischargedButton;

  /// No description provided for @cabinTemperature_screenTitle.
  ///
  /// In en, this message translates to:
  /// **'Cabinet Temperature Control'**
  String get cabinTemperature_screenTitle;

  /// No description provided for @cabinTemperature_formDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Cabinet'**
  String get cabinTemperature_formDialogTitle;

  /// No description provided for @cabinTemperature_insideBottomLabel.
  ///
  /// In en, this message translates to:
  /// **'Inside Bottom Temperature'**
  String get cabinTemperature_insideBottomLabel;

  /// No description provided for @cabinTemperature_insideTopLabel.
  ///
  /// In en, this message translates to:
  /// **'Inside Top Temperature'**
  String get cabinTemperature_insideTopLabel;

  /// No description provided for @cabinTemperature_outsideBottomLabel.
  ///
  /// In en, this message translates to:
  /// **'Outside Bottom Temperature'**
  String get cabinTemperature_outsideBottomLabel;

  /// No description provided for @cabinTemperature_outsideTopLabel.
  ///
  /// In en, this message translates to:
  /// **'Outside Top Temperature'**
  String get cabinTemperature_outsideTopLabel;

  /// No description provided for @cabinTemperature_humidityBottomLabel.
  ///
  /// In en, this message translates to:
  /// **'Humidity Lower Limit'**
  String get cabinTemperature_humidityBottomLabel;

  /// No description provided for @cabinTemperature_humidityTopLabel.
  ///
  /// In en, this message translates to:
  /// **'Humidity Upper Limit'**
  String get cabinTemperature_humidityTopLabel;

  /// No description provided for @cabinTemperature_genericErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String cabinTemperature_genericErrorMessage(String error);

  /// No description provided for @cabinTemperature_stationNotSelectedError.
  ///
  /// In en, this message translates to:
  /// **'No station selected'**
  String get cabinTemperature_stationNotSelectedError;

  /// No description provided for @cabinTemperature_createSuccess.
  ///
  /// In en, this message translates to:
  /// **'The cabinet temperature setting was created successfully.'**
  String get cabinTemperature_createSuccess;

  /// No description provided for @cabinTemperature_updateRecordNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'No record found to update'**
  String get cabinTemperature_updateRecordNotFoundError;

  /// No description provided for @cabinTemperature_updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'The cabinet temperature setting was updated successfully.'**
  String get cabinTemperature_updateSuccess;

  /// No description provided for @cabinTemperature_unnamedStationFallback.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Station'**
  String get cabinTemperature_unnamedStationFallback;

  /// No description provided for @cabinTemperature_stationsLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading stations...'**
  String get cabinTemperature_stationsLoadingMessage;

  /// No description provided for @cabinTemperature_detailsLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading temperature details...'**
  String get cabinTemperature_detailsLoadingMessage;

  /// No description provided for @cabinTemperature_columnCabin.
  ///
  /// In en, this message translates to:
  /// **'Cabinet'**
  String get cabinTemperature_columnCabin;

  /// No description provided for @directedOrders_screenTitle.
  ///
  /// In en, this message translates to:
  /// **'Directed Order List'**
  String get directedOrders_screenTitle;

  /// No description provided for @directedOrders_columnProtocolNo.
  ///
  /// In en, this message translates to:
  /// **'Protocol No.'**
  String get directedOrders_columnProtocolNo;

  /// No description provided for @directedOrders_columnBed.
  ///
  /// In en, this message translates to:
  /// **'Bed'**
  String get directedOrders_columnBed;

  /// No description provided for @directedOrders_columnRoom.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get directedOrders_columnRoom;

  /// No description provided for @directedOrders_medicinesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get directedOrders_medicinesTooltip;

  /// No description provided for @directedOrders_patientsLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading patients...'**
  String get directedOrders_patientsLoadingMessage;

  /// No description provided for @directedOrders_columnBarcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get directedOrders_columnBarcode;

  /// No description provided for @medicine_successCreated.
  ///
  /// In en, this message translates to:
  /// **'Drug created'**
  String get medicine_successCreated;

  /// No description provided for @medicine_successUpdated.
  ///
  /// In en, this message translates to:
  /// **'Drug updated'**
  String get medicine_successUpdated;

  /// No description provided for @medicalConsumable_successCreated.
  ///
  /// In en, this message translates to:
  /// **'Medical consumable created'**
  String get medicalConsumable_successCreated;

  /// No description provided for @medicalConsumable_successUpdated.
  ///
  /// In en, this message translates to:
  /// **'Medical consumable updated'**
  String get medicalConsumable_successUpdated;

  /// No description provided for @medicine_formTitleNew.
  ///
  /// In en, this message translates to:
  /// **'New Drug'**
  String get medicine_formTitleNew;

  /// No description provided for @medicine_formTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Drug'**
  String get medicine_formTitleEdit;

  /// No description provided for @medicine_formSubtitleNew.
  ///
  /// In en, this message translates to:
  /// **'Fill in the drug details'**
  String get medicine_formSubtitleNew;

  /// No description provided for @medicine_formSubtitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Update the drug details'**
  String get medicine_formSubtitleEdit;

  /// No description provided for @medicine_fieldDefinitionName.
  ///
  /// In en, this message translates to:
  /// **'Definition Name'**
  String get medicine_fieldDefinitionName;

  /// No description provided for @medicine_fieldBarcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get medicine_fieldBarcode;

  /// No description provided for @medicine_fieldName.
  ///
  /// In en, this message translates to:
  /// **'Drug Name'**
  String get medicine_fieldName;

  /// No description provided for @medicine_fieldCode.
  ///
  /// In en, this message translates to:
  /// **'Drug Code'**
  String get medicine_fieldCode;

  /// No description provided for @medicine_fieldPrescriptionType.
  ///
  /// In en, this message translates to:
  /// **'Prescription Type'**
  String get medicine_fieldPrescriptionType;

  /// No description provided for @medicine_fieldDose.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get medicine_fieldDose;

  /// No description provided for @medicine_fieldManufacturer.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get medicine_fieldManufacturer;

  /// No description provided for @medicine_fieldDailyMaxUsage.
  ///
  /// In en, this message translates to:
  /// **'Daily Max. Usage Amount'**
  String get medicine_fieldDailyMaxUsage;

  /// No description provided for @medicine_fieldDrugType.
  ///
  /// In en, this message translates to:
  /// **'Drug Type'**
  String get medicine_fieldDrugType;

  /// No description provided for @medicine_fieldReturnType.
  ///
  /// In en, this message translates to:
  /// **'Return Method'**
  String get medicine_fieldReturnType;

  /// No description provided for @medicine_checkboxSerumMaxValue.
  ///
  /// In en, this message translates to:
  /// **'Check the max value in the serum cabinet'**
  String get medicine_checkboxSerumMaxValue;

  /// No description provided for @medicine_checkboxCubicMaxValue.
  ///
  /// In en, this message translates to:
  /// **'Check the max value in the cubic drawer'**
  String get medicine_checkboxCubicMaxValue;

  /// No description provided for @medicine_checkboxQrCode.
  ///
  /// In en, this message translates to:
  /// **'Has QR Code'**
  String get medicine_checkboxQrCode;

  /// No description provided for @medicine_fieldPieceCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Piece Count'**
  String get medicine_fieldPieceCountLabel;

  /// No description provided for @medicine_fieldDrugClass.
  ///
  /// In en, this message translates to:
  /// **'Drug Class'**
  String get medicine_fieldDrugClass;

  /// No description provided for @medicine_fieldPurchaseType.
  ///
  /// In en, this message translates to:
  /// **'Purchase Method'**
  String get medicine_fieldPurchaseType;

  /// No description provided for @medicine_checkboxUseMeasurementUnit.
  ///
  /// In en, this message translates to:
  /// **'Use Measurement Unit'**
  String get medicine_checkboxUseMeasurementUnit;

  /// No description provided for @medicine_fieldVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get medicine_fieldVolume;

  /// No description provided for @medicine_fieldDosageForm.
  ///
  /// In en, this message translates to:
  /// **'Dosage Form'**
  String get medicine_fieldDosageForm;

  /// No description provided for @medicine_fieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get medicine_fieldStatus;

  /// No description provided for @medicine_fieldCountType.
  ///
  /// In en, this message translates to:
  /// **'Count Type'**
  String get medicine_fieldCountType;

  /// No description provided for @medicine_fieldAtcCode.
  ///
  /// In en, this message translates to:
  /// **'ATC Code'**
  String get medicine_fieldAtcCode;

  /// No description provided for @medicine_fieldEquivalentCode.
  ///
  /// In en, this message translates to:
  /// **'Equivalent Code'**
  String get medicine_fieldEquivalentCode;

  /// No description provided for @medicine_checkboxWitnessedPurchase.
  ///
  /// In en, this message translates to:
  /// **'Witnessed Purchase'**
  String get medicine_checkboxWitnessedPurchase;

  /// No description provided for @medicine_checkboxWastageWitnessed.
  ///
  /// In en, this message translates to:
  /// **'Witnessed Waste/Disposal'**
  String get medicine_checkboxWastageWitnessed;

  /// No description provided for @medicine_checkboxDestroyable.
  ///
  /// In en, this message translates to:
  /// **'Disposable'**
  String get medicine_checkboxDestroyable;

  /// No description provided for @medicine_fieldActiveIngredient.
  ///
  /// In en, this message translates to:
  /// **'Active Ingredient'**
  String get medicine_fieldActiveIngredient;

  /// No description provided for @medicine_fieldCollectNote.
  ///
  /// In en, this message translates to:
  /// **'Purchase Note'**
  String get medicine_fieldCollectNote;

  /// No description provided for @medicine_fieldReturnNote.
  ///
  /// In en, this message translates to:
  /// **'Return Note'**
  String get medicine_fieldReturnNote;

  /// No description provided for @medicine_fieldDestructionNote.
  ///
  /// In en, this message translates to:
  /// **'Disposal Note'**
  String get medicine_fieldDestructionNote;

  /// No description provided for @medicalConsumable_dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add/Edit Medical Consumable'**
  String get medicalConsumable_dialogTitle;

  /// No description provided for @medicalConsumable_fieldName.
  ///
  /// In en, this message translates to:
  /// **'Material Name'**
  String get medicalConsumable_fieldName;

  /// No description provided for @medicalConsumable_fieldInstitutionCode.
  ///
  /// In en, this message translates to:
  /// **'Institution Code'**
  String get medicalConsumable_fieldInstitutionCode;

  /// No description provided for @medicalConsumable_fieldSutCode.
  ///
  /// In en, this message translates to:
  /// **'SUT Code/Annex'**
  String get medicalConsumable_fieldSutCode;

  /// No description provided for @medicalConsumable_fieldUbbCode.
  ///
  /// In en, this message translates to:
  /// **'UBB Code'**
  String get medicalConsumable_fieldUbbCode;

  /// No description provided for @medicalConsumable_fieldMaterialType.
  ///
  /// In en, this message translates to:
  /// **'Material Type'**
  String get medicalConsumable_fieldMaterialType;

  /// No description provided for @medicalConsumable_fieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get medicalConsumable_fieldStatus;

  /// No description provided for @medicine_screenTitleFallback.
  ///
  /// In en, this message translates to:
  /// **'Drug/Medical Consumable Definition'**
  String get medicine_screenTitleFallback;

  /// No description provided for @medicine_newButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'New Drug'**
  String get medicine_newButtonLabel;

  /// No description provided for @medicine_defineMedicalConsumableButton.
  ///
  /// In en, this message translates to:
  /// **'Define Medical Consumable'**
  String get medicine_defineMedicalConsumableButton;

  /// No description provided for @medicine_defineActiveIngredientButton.
  ///
  /// In en, this message translates to:
  /// **'Define Active Ingredient'**
  String get medicine_defineActiveIngredientButton;

  /// No description provided for @medicine_defineDrugClassButton.
  ///
  /// In en, this message translates to:
  /// **'Define Drug Class'**
  String get medicine_defineDrugClassButton;

  /// No description provided for @medicine_defineDrugTypeButton.
  ///
  /// In en, this message translates to:
  /// **'Define Drug Type'**
  String get medicine_defineDrugTypeButton;

  /// No description provided for @medicine_createKitButton.
  ///
  /// In en, this message translates to:
  /// **'Create Drug Kit'**
  String get medicine_createKitButton;

  /// No description provided for @medicine_defineMaterialTypeButton.
  ///
  /// In en, this message translates to:
  /// **'Define Material Type'**
  String get medicine_defineMaterialTypeButton;

  /// No description provided for @medicine_checkboxLowerDose.
  ///
  /// In en, this message translates to:
  /// **'A dose lower than specified may be taken'**
  String get medicine_checkboxLowerDose;

  /// No description provided for @medicine_checkboxRfid.
  ///
  /// In en, this message translates to:
  /// **'RFID Available'**
  String get medicine_checkboxRfid;

  /// No description provided for @medicine_checkboxMultiPatientAccess.
  ///
  /// In en, this message translates to:
  /// **'Multi-Patient Access'**
  String get medicine_checkboxMultiPatientAccess;

  /// No description provided for @medicine_checkboxSingleUse.
  ///
  /// In en, this message translates to:
  /// **'Single Use'**
  String get medicine_checkboxSingleUse;

  /// No description provided for @medicine_checkboxCameraRecording.
  ///
  /// In en, this message translates to:
  /// **'Camera Recording'**
  String get medicine_checkboxCameraRecording;

  /// No description provided for @medicine_checkboxIndependentMaterial.
  ///
  /// In en, this message translates to:
  /// **'Independent Drug'**
  String get medicine_checkboxIndependentMaterial;

  /// No description provided for @medicine_checkboxWastagePharmacyApproval.
  ///
  /// In en, this message translates to:
  /// **'Require Pharmacy Approval for Waste/Disposal?'**
  String get medicine_checkboxWastagePharmacyApproval;

  /// No description provided for @medicine_checkboxWastageOrderRenewed.
  ///
  /// In en, this message translates to:
  /// **'Renew Waste Order?'**
  String get medicine_checkboxWastageOrderRenewed;

  /// No description provided for @medicine_fieldPersonnel.
  ///
  /// In en, this message translates to:
  /// **'Personnel'**
  String get medicine_fieldPersonnel;

  /// No description provided for @medicine_fieldStation.
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get medicine_fieldStation;

  /// No description provided for @medicine_fieldUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get medicine_fieldUnit;

  /// No description provided for @refillList_dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Drug Refill List'**
  String get refillList_dialogTitle;

  /// No description provided for @refillList_recordNoLabel.
  ///
  /// In en, this message translates to:
  /// **'Refill Record No: {id}'**
  String refillList_recordNoLabel(Object id);

  /// No description provided for @refillList_createdDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Created Date: {date}'**
  String refillList_createdDateLabel(String date);

  /// No description provided for @refillList_assignedUserNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Assigned To: {name}'**
  String refillList_assignedUserNameLabel(String name);

  /// No description provided for @refillList_formTitleCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Refill List'**
  String get refillList_formTitleCreate;

  /// No description provided for @refillList_formTitleUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update Refill List'**
  String get refillList_formTitleUpdate;

  /// No description provided for @refillList_fieldAssignedUser.
  ///
  /// In en, this message translates to:
  /// **'User Assigned to Refill'**
  String get refillList_fieldAssignedUser;

  /// No description provided for @refillList_screenTitleFallback.
  ///
  /// In en, this message translates to:
  /// **'Refill List'**
  String get refillList_screenTitleFallback;

  /// No description provided for @refillList_newButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'New Refill List'**
  String get refillList_newButtonLabel;

  /// No description provided for @report_stationsCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Stations'**
  String get report_stationsCategoryTitle;

  /// No description provided for @refillList_cellValueYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get refillList_cellValueYes;

  /// No description provided for @refillList_cellValueNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get refillList_cellValueNo;

  /// No description provided for @refillList_updateStatusTooltip.
  ///
  /// In en, this message translates to:
  /// **'Update Status'**
  String get refillList_updateStatusTooltip;

  /// No description provided for @refillList_defaultUnitFallback.
  ///
  /// In en, this message translates to:
  /// **'Piece'**
  String get refillList_defaultUnitFallback;

  /// No description provided for @report_expiredItemsTitleFallback.
  ///
  /// In en, this message translates to:
  /// **'Expired Materials'**
  String get report_expiredItemsTitleFallback;

  /// No description provided for @report_stationStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Station Cabinet Stock'**
  String get report_stationStockTitle;

  /// No description provided for @report_stationTransactionTitleFallback.
  ///
  /// In en, this message translates to:
  /// **'Station Transactions'**
  String get report_stationTransactionTitleFallback;

  /// No description provided for @report_hospitalStocksTitleFallback.
  ///
  /// In en, this message translates to:
  /// **'Hospital Material List'**
  String get report_hospitalStocksTitleFallback;

  /// No description provided for @inconsistency_screenTitleFallback.
  ///
  /// In en, this message translates to:
  /// **'Inconsistency Movements'**
  String get inconsistency_screenTitleFallback;

  /// No description provided for @inconsistency_viewTooltip.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get inconsistency_viewTooltip;

  /// No description provided for @inconsistency_photoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get inconsistency_photoTooltip;

  /// No description provided for @hospitalization_formTitleNew.
  ///
  /// In en, this message translates to:
  /// **'Enter New Admission'**
  String get hospitalization_formTitleNew;

  /// No description provided for @hospitalization_formTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Admission'**
  String get hospitalization_formTitleEdit;

  /// No description provided for @hospitalization_fieldPatient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get hospitalization_fieldPatient;

  /// No description provided for @hospitalization_fieldCode.
  ///
  /// In en, this message translates to:
  /// **'Admission Code'**
  String get hospitalization_fieldCode;

  /// No description provided for @hospitalization_fieldDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get hospitalization_fieldDoctor;

  /// No description provided for @hospitalization_fieldPhysicalService.
  ///
  /// In en, this message translates to:
  /// **'Physical Service'**
  String get hospitalization_fieldPhysicalService;

  /// No description provided for @hospitalization_fieldInpatientService.
  ///
  /// In en, this message translates to:
  /// **'Inpatient Service'**
  String get hospitalization_fieldInpatientService;

  /// No description provided for @hospitalization_fieldRoom.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get hospitalization_fieldRoom;

  /// No description provided for @hospitalization_roomDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Room'**
  String get hospitalization_roomDialogTitle;

  /// No description provided for @hospitalization_fieldBed.
  ///
  /// In en, this message translates to:
  /// **'Bed'**
  String get hospitalization_fieldBed;

  /// No description provided for @hospitalization_bedDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Bed'**
  String get hospitalization_bedDialogTitle;

  /// No description provided for @hospitalization_fieldAdmissionDate.
  ///
  /// In en, this message translates to:
  /// **'Admission Date'**
  String get hospitalization_fieldAdmissionDate;

  /// No description provided for @hospitalization_fieldExitDate.
  ///
  /// In en, this message translates to:
  /// **'Discharge Date'**
  String get hospitalization_fieldExitDate;

  /// No description provided for @hospitalization_checkboxBaby.
  ///
  /// In en, this message translates to:
  /// **'Infant'**
  String get hospitalization_checkboxBaby;

  /// No description provided for @hospitalization_screenTitleFallback.
  ///
  /// In en, this message translates to:
  /// **'Patient Operations'**
  String get hospitalization_screenTitleFallback;

  /// No description provided for @hospitalization_editPatientTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit Patient Details'**
  String get hospitalization_editPatientTooltip;

  /// No description provided for @hospitalization_showActiveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show active admissions'**
  String get hospitalization_showActiveTooltip;

  /// No description provided for @hospitalization_showDischargedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show discharged patients'**
  String get hospitalization_showDischargedTooltip;

  /// No description provided for @hospitalization_createButton.
  ///
  /// In en, this message translates to:
  /// **'Create New Admission'**
  String get hospitalization_createButton;

  /// No description provided for @patient_formTitleNew.
  ///
  /// In en, this message translates to:
  /// **'Create New Patient'**
  String get patient_formTitleNew;

  /// No description provided for @patient_formTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Patient'**
  String get patient_formTitleEdit;

  /// No description provided for @patient_fieldIdentity.
  ///
  /// In en, this message translates to:
  /// **'National ID No.'**
  String get patient_fieldIdentity;

  /// No description provided for @patient_fieldName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get patient_fieldName;

  /// No description provided for @patient_fieldSurname.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get patient_fieldSurname;

  /// No description provided for @patient_fieldBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get patient_fieldBirthDate;

  /// No description provided for @patient_fieldGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get patient_fieldGender;

  /// No description provided for @patient_fieldWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get patient_fieldWeight;

  /// No description provided for @patient_fieldMotherName.
  ///
  /// In en, this message translates to:
  /// **'Mother\'s Name'**
  String get patient_fieldMotherName;

  /// No description provided for @patient_fieldFatherName.
  ///
  /// In en, this message translates to:
  /// **'Father\'s Name'**
  String get patient_fieldFatherName;

  /// No description provided for @patient_fieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get patient_fieldPhone;

  /// No description provided for @patient_fieldAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get patient_fieldAddress;

  /// No description provided for @patient_fieldProtocolNo.
  ///
  /// In en, this message translates to:
  /// **'Protocol No.'**
  String get patient_fieldProtocolNo;

  /// No description provided for @activeIngredient_dialogSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Active Ingredient'**
  String get activeIngredient_dialogSelectTitle;

  /// No description provided for @activeIngredient_dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Ingredient Definition'**
  String get activeIngredient_dialogTitle;

  /// No description provided for @activeIngredient_formAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Active Ingredient'**
  String get activeIngredient_formAddTitle;

  /// No description provided for @activeIngredient_formEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Active Ingredient'**
  String get activeIngredient_formEditTitle;

  /// No description provided for @activeIngredient_listEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No active ingredients yet'**
  String get activeIngredient_listEmptyTitle;

  /// No description provided for @activeIngredient_itemNameLabel.
  ///
  /// In en, this message translates to:
  /// **'active ingredient'**
  String get activeIngredient_itemNameLabel;

  /// No description provided for @assignment_screenTitle.
  ///
  /// In en, this message translates to:
  /// **'Station Material Assignment'**
  String get assignment_screenTitle;

  /// No description provided for @assignment_stationSelectPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select a station'**
  String get assignment_stationSelectPlaceholder;

  /// No description provided for @drugClass_dialogSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Drug Class'**
  String get drugClass_dialogSelectTitle;

  /// No description provided for @drugClass_dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Drug Class Definition'**
  String get drugClass_dialogTitle;

  /// No description provided for @drugClass_formAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Drug Class'**
  String get drugClass_formAddTitle;

  /// No description provided for @drugClass_formEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Drug Class'**
  String get drugClass_formEditTitle;

  /// No description provided for @drugClass_formNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Drug Class Name'**
  String get drugClass_formNameLabel;

  /// No description provided for @drugClass_listEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No drug classes yet'**
  String get drugClass_listEmptyTitle;

  /// No description provided for @drugClass_itemNameLabel.
  ///
  /// In en, this message translates to:
  /// **'drug class'**
  String get drugClass_itemNameLabel;

  /// No description provided for @drugType_dialogSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Drug Type'**
  String get drugType_dialogSelectTitle;

  /// No description provided for @drugType_dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Drug Type Definition'**
  String get drugType_dialogTitle;

  /// No description provided for @drugType_formAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Drug Type'**
  String get drugType_formAddTitle;

  /// No description provided for @drugType_formEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Drug Type'**
  String get drugType_formEditTitle;

  /// No description provided for @drugType_formNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Drug Type Name'**
  String get drugType_formNameLabel;

  /// No description provided for @drugType_listEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No drug types yet'**
  String get drugType_listEmptyTitle;

  /// No description provided for @drugType_itemNameLabel.
  ///
  /// In en, this message translates to:
  /// **'drug type'**
  String get drugType_itemNameLabel;

  /// No description provided for @kit_formAddTitle.
  ///
  /// In en, this message translates to:
  /// **'New Kit'**
  String get kit_formAddTitle;

  /// No description provided for @kit_formEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Kit'**
  String get kit_formEditTitle;

  /// No description provided for @kit_formNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Kit Name'**
  String get kit_formNameLabel;

  /// No description provided for @kit_dialogSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Kit'**
  String get kit_dialogSelectTitle;

  /// No description provided for @kit_dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Kit Definition'**
  String get kit_dialogTitle;

  /// No description provided for @kit_listEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No kits yet'**
  String get kit_listEmptyTitle;

  /// No description provided for @kit_listManageContentTooltip.
  ///
  /// In en, this message translates to:
  /// **'Manage Kit Content'**
  String get kit_listManageContentTooltip;

  /// No description provided for @kit_itemNameLabel.
  ///
  /// In en, this message translates to:
  /// **'kit'**
  String get kit_itemNameLabel;

  /// No description provided for @kitContent_formAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Kit Content'**
  String get kitContent_formAddTitle;

  /// No description provided for @kitContent_formEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Kit Content'**
  String get kitContent_formEditTitle;

  /// No description provided for @kitContent_formMaterialLabel.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get kitContent_formMaterialLabel;

  /// No description provided for @kitContent_formPieceLabel.
  ///
  /// In en, this message translates to:
  /// **'Piece Count'**
  String get kitContent_formPieceLabel;

  /// No description provided for @kitContent_dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Kit Content Definition'**
  String get kitContent_dialogTitle;

  /// No description provided for @kitContent_listEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No kit content yet'**
  String get kitContent_listEmptyTitle;

  /// No description provided for @kitContent_itemNameLabel.
  ///
  /// In en, this message translates to:
  /// **'content'**
  String get kitContent_itemNameLabel;

  /// No description provided for @materialType_formAddTitle.
  ///
  /// In en, this message translates to:
  /// **'New Material Type'**
  String get materialType_formAddTitle;

  /// No description provided for @materialType_formEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Material Type'**
  String get materialType_formEditTitle;

  /// No description provided for @materialType_formNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Material Type Name'**
  String get materialType_formNameLabel;

  /// No description provided for @materialType_dialogSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Material Type'**
  String get materialType_dialogSelectTitle;

  /// No description provided for @materialType_dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Material Type Definition'**
  String get materialType_dialogTitle;

  /// No description provided for @materialType_listEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No material types yet'**
  String get materialType_listEmptyTitle;

  /// No description provided for @materialType_itemNameLabel.
  ///
  /// In en, this message translates to:
  /// **'material type'**
  String get materialType_itemNameLabel;

  /// No description provided for @role_formEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Role'**
  String get role_formEditTitle;

  /// No description provided for @role_formAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Role'**
  String get role_formAddTitle;

  /// No description provided for @role_formNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Role Name'**
  String get role_formNameLabel;

  /// No description provided for @role_screenTitle.
  ///
  /// In en, this message translates to:
  /// **'Role Definition'**
  String get role_screenTitle;

  /// No description provided for @role_screenAddButton.
  ///
  /// In en, this message translates to:
  /// **'New Role'**
  String get role_screenAddButton;

  /// No description provided for @role_deleteSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Role deleted successfully'**
  String get role_deleteSuccessMessage;

  /// No description provided for @unit_formAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Unit'**
  String get unit_formAddTitle;

  /// No description provided for @unit_formEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Unit'**
  String get unit_formEditTitle;

  /// No description provided for @unit_dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit_dialogTitle;

  /// No description provided for @unit_itemNameLabel.
  ///
  /// In en, this message translates to:
  /// **'unit'**
  String get unit_itemNameLabel;

  /// No description provided for @unit_listEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No units yet'**
  String get unit_listEmptyTitle;

  /// No description provided for @user_categoryNormalLabel.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get user_categoryNormalLabel;

  /// No description provided for @user_categoryTimeBasedLabel.
  ///
  /// In en, this message translates to:
  /// **'Time-Limited'**
  String get user_categoryTimeBasedLabel;

  /// No description provided for @user_categoryTemporaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Temporary'**
  String get user_categoryTemporaryLabel;

  /// No description provided for @user_deleteSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'User deleted successfully'**
  String get user_deleteSuccessMessage;

  /// No description provided for @user_validDateUpdateSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Expiry date updated'**
  String get user_validDateUpdateSuccessMessage;

  /// No description provided for @user_formEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get user_formEditTitle;

  /// No description provided for @user_formCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create User'**
  String get user_formCreateTitle;

  /// No description provided for @user_registrationNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Institution Registry No.'**
  String get user_registrationNumberLabel;

  /// No description provided for @user_nameLabel.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get user_nameLabel;

  /// No description provided for @user_surnameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get user_surnameLabel;

  /// No description provided for @user_roleTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Occupation Type'**
  String get user_roleTypeLabel;

  /// No description provided for @user_usageTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Usage Type'**
  String get user_usageTypeLabel;

  /// No description provided for @user_validUntilLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get user_validUntilLabel;

  /// No description provided for @user_emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get user_emailLabel;

  /// No description provided for @user_orderPermissionLabel.
  ///
  /// In en, this message translates to:
  /// **'Purchase Without Order'**
  String get user_orderPermissionLabel;

  /// No description provided for @user_witnessedStationEntryLabel.
  ///
  /// In en, this message translates to:
  /// **'Witnessed Station Entry'**
  String get user_witnessedStationEntryLabel;

  /// No description provided for @user_kitPurchaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Kit Purchase'**
  String get user_kitPurchaseLabel;

  /// No description provided for @user_badgeCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Badge Card'**
  String get user_badgeCardLabel;

  /// No description provided for @user_emergencyAccessLabel.
  ///
  /// In en, this message translates to:
  /// **'Can Create Emergency Patient?'**
  String get user_emergencyAccessLabel;

  /// No description provided for @user_badgeCardHint.
  ///
  /// In en, this message translates to:
  /// **'Scan card'**
  String get user_badgeCardHint;

  /// No description provided for @user_authorizedStationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Authorized Stations'**
  String get user_authorizedStationsLabel;

  /// No description provided for @user_usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get user_usernameLabel;

  /// No description provided for @user_screenTitle.
  ///
  /// In en, this message translates to:
  /// **'User List'**
  String get user_screenTitle;

  /// No description provided for @user_screenAddButton.
  ///
  /// In en, this message translates to:
  /// **'New User'**
  String get user_screenAddButton;

  /// No description provided for @user_bulkUpdateValidDateButton.
  ///
  /// In en, this message translates to:
  /// **'Update Expiry Date'**
  String get user_bulkUpdateValidDateButton;

  /// No description provided for @user_validDateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Date'**
  String get user_validDateDialogTitle;

  /// No description provided for @user_validDateDialogSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get user_validDateDialogSaveButton;

  /// No description provided for @user_newValidUntilLabel.
  ///
  /// In en, this message translates to:
  /// **'New Expiry Date'**
  String get user_newValidUntilLabel;

  /// No description provided for @user_nationalIdColumnHeader.
  ///
  /// In en, this message translates to:
  /// **'National ID No.'**
  String get user_nationalIdColumnHeader;

  /// No description provided for @warning_formAddTitle.
  ///
  /// In en, this message translates to:
  /// **'New Warning'**
  String get warning_formAddTitle;

  /// No description provided for @warning_formEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Warning'**
  String get warning_formEditTitle;

  /// No description provided for @warning_formAddSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in the warning details'**
  String get warning_formAddSubtitle;

  /// No description provided for @warning_formEditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update the warning details'**
  String get warning_formEditSubtitle;

  /// No description provided for @warning_formSubjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Warning Subject'**
  String get warning_formSubjectLabel;

  /// No description provided for @warning_formTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Warning Text'**
  String get warning_formTextLabel;

  /// No description provided for @warning_screenTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning Definition'**
  String get warning_screenTitle;

  /// No description provided for @dashboard_allSectionsLoadError.
  ///
  /// In en, this message translates to:
  /// **'The data could not be loaded. Please try again.'**
  String get dashboard_allSectionsLoadError;

  /// No description provided for @dashboard_sktCriticalRingLabel.
  ///
  /// In en, this message translates to:
  /// **'Critical\n(<7 days)'**
  String get dashboard_sktCriticalRingLabel;

  /// No description provided for @dashboard_sktWarningRingLabel.
  ///
  /// In en, this message translates to:
  /// **'Warning\n(7-30 days)'**
  String get dashboard_sktWarningRingLabel;

  /// No description provided for @dashboard_sktExpiredRingLabel.
  ///
  /// In en, this message translates to:
  /// **'Expired\nItems'**
  String get dashboard_sktExpiredRingLabel;

  /// No description provided for @dashboard_sktStatusHeader.
  ///
  /// In en, this message translates to:
  /// **'EXPIRY STATUS'**
  String get dashboard_sktStatusHeader;

  /// No description provided for @dashboard_sktItemCountBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} Items'**
  String dashboard_sktItemCountBadge(int count);

  /// No description provided for @dashboard_sktExpiredTag.
  ///
  /// In en, this message translates to:
  /// **'EXPIRED'**
  String get dashboard_sktExpiredTag;

  /// No description provided for @dashboard_sktDestroyHint.
  ///
  /// In en, this message translates to:
  /// **'destroy'**
  String get dashboard_sktDestroyHint;

  /// No description provided for @dashboard_sktDaysRemainingLabel.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, one{day left} other{days left}}'**
  String dashboard_sktDaysRemainingLabel(int days);

  /// No description provided for @dashboard_upcomingTreatmentsHeader.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING TREATMENTS'**
  String get dashboard_upcomingTreatmentsHeader;

  /// No description provided for @dashboard_pendingTreatmentsBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} Pending'**
  String dashboard_pendingTreatmentsBadge(int count);

  /// No description provided for @dashboard_pendingFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get dashboard_pendingFilterLabel;

  /// No description provided for @dashboard_urgentFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get dashboard_urgentFilterLabel;

  /// No description provided for @dashboard_treatmentSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search patient or medicine...'**
  String get dashboard_treatmentSearchHint;

  /// No description provided for @dashboard_newAssignButton.
  ///
  /// In en, this message translates to:
  /// **'New Assignment'**
  String get dashboard_newAssignButton;

  /// No description provided for @dashboard_noTreatmentsAllFilter.
  ///
  /// In en, this message translates to:
  /// **'No treatment records found'**
  String get dashboard_noTreatmentsAllFilter;

  /// No description provided for @dashboard_noTreatmentsPendingFilter.
  ///
  /// In en, this message translates to:
  /// **'No pending treatments'**
  String get dashboard_noTreatmentsPendingFilter;

  /// No description provided for @dashboard_noTreatmentsUrgentFilter.
  ///
  /// In en, this message translates to:
  /// **'No urgent treatments'**
  String get dashboard_noTreatmentsUrgentFilter;

  /// No description provided for @dashboard_priorityUrgentLabel.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get dashboard_priorityUrgentLabel;

  /// No description provided for @dashboard_priorityNormalLabel.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get dashboard_priorityNormalLabel;

  /// No description provided for @dashboard_priorityRoutineLabel.
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get dashboard_priorityRoutineLabel;

  /// No description provided for @dashboard_statusPendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get dashboard_statusPendingLabel;

  /// No description provided for @dashboard_statusDoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Dispensed'**
  String get dashboard_statusDoneLabel;

  /// No description provided for @dashboard_statusReturnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get dashboard_statusReturnedLabel;

  /// No description provided for @settings_sectionComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{label} settings coming soon'**
  String settings_sectionComingSoon(String label);

  /// No description provided for @refund_masterScreenNotReady.
  ///
  /// In en, this message translates to:
  /// **'The master cabinet return screen isn\'t ready yet.'**
  String get refund_masterScreenNotReady;

  /// No description provided for @core_cabinConn_managerNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'Management card not found.'**
  String get core_cabinConn_managerNotFoundError;

  /// No description provided for @core_cabinConn_disconnectedError.
  ///
  /// In en, this message translates to:
  /// **'Connection lost'**
  String get core_cabinConn_disconnectedError;

  /// No description provided for @common_action_pullDrawerTitle.
  ///
  /// In en, this message translates to:
  /// **'Open the drawer'**
  String get common_action_pullDrawerTitle;

  /// No description provided for @common_action_pullDrawerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The lock is open, please pull it.'**
  String get common_action_pullDrawerSubtitle;

  /// No description provided for @masterDrawer_openingLidTitle.
  ///
  /// In en, this message translates to:
  /// **'Opening lids'**
  String get masterDrawer_openingLidTitle;

  /// No description provided for @masterDrawer_openingLidSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Preparing the cubic drawer lids.'**
  String get masterDrawer_openingLidSubtitle;

  /// No description provided for @masterDrawer_readySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete the operation and confirm.'**
  String get masterDrawer_readySubtitle;

  /// No description provided for @common_action_closeDrawerTitle.
  ///
  /// In en, this message translates to:
  /// **'Close the drawer'**
  String get common_action_closeDrawerTitle;

  /// No description provided for @common_action_closeDrawerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The operation is confirmed, please close it.'**
  String get common_action_closeDrawerSubtitle;

  /// No description provided for @common_action_drawerClosed.
  ///
  /// In en, this message translates to:
  /// **'Drawer closed'**
  String get common_action_drawerClosed;

  /// No description provided for @common_action_operationCompletedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The operation is complete.'**
  String get common_action_operationCompletedSubtitle;

  /// No description provided for @common_action_drawerError.
  ///
  /// In en, this message translates to:
  /// **'Drawer error'**
  String get common_action_drawerError;

  /// No description provided for @common_error_unexpectedWithDetail.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {error}'**
  String common_error_unexpectedWithDetail(Object error);

  /// No description provided for @masterDrawer_lidOpenFailedError.
  ///
  /// In en, this message translates to:
  /// **'The lid could not be opened: {error}'**
  String masterDrawer_lidOpenFailedError(Object error);

  /// No description provided for @common_action_devicePreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing device...'**
  String get common_action_devicePreparing;

  /// No description provided for @common_error_connectionErrorWithDetail.
  ///
  /// In en, this message translates to:
  /// **'Connection error: {error}'**
  String common_error_connectionErrorWithDetail(Object error);

  /// No description provided for @common_action_lockOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening lock...'**
  String get common_action_lockOpening;

  /// No description provided for @common_error_lockOpenFailedWithDetail.
  ///
  /// In en, this message translates to:
  /// **'The lock could not be opened: {error}'**
  String common_error_lockOpenFailedWithDetail(Object error);

  /// No description provided for @mobileDrawer_portSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Drawer {port}'**
  String mobileDrawer_portSubtitle(int port);

  /// No description provided for @mobileDrawer_openedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Close the drawer to complete the operation.'**
  String get mobileDrawer_openedSubtitle;

  /// No description provided for @mobileDrawer_closedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for your confirmation'**
  String get mobileDrawer_closedSubtitle;

  /// No description provided for @common_error_managerConnectFailedWithDetail.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the management card: {error}'**
  String common_error_managerConnectFailedWithDetail(Object error);

  /// No description provided for @mobileDrawer_openCommandFailedError.
  ///
  /// In en, this message translates to:
  /// **'Could not send the drawer-open command: {error}'**
  String mobileDrawer_openCommandFailedError(Object error);

  /// No description provided for @mobileDrawer_statusTimeoutError.
  ///
  /// In en, this message translates to:
  /// **'Timed out while reading the drawer status.'**
  String get mobileDrawer_statusTimeoutError;

  /// No description provided for @mobileDrawer_openNotConfirmedError.
  ///
  /// In en, this message translates to:
  /// **'Could not confirm that the drawer opened.'**
  String get mobileDrawer_openNotConfirmedError;

  /// No description provided for @mobileDrawer_statusReadError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while reading the drawer status: {error}'**
  String mobileDrawer_statusReadError(Object error);

  /// No description provided for @patientPicker_searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search patient'**
  String get patientPicker_searchHint;

  /// No description provided for @patientPicker_orderlessToggleLabel.
  ///
  /// In en, this message translates to:
  /// **'Without Order'**
  String get patientPicker_orderlessToggleLabel;

  /// No description provided for @patientPicker_orderedToggleLabel.
  ///
  /// In en, this message translates to:
  /// **'With Order'**
  String get patientPicker_orderedToggleLabel;

  /// No description provided for @patientPicker_myPatientsToggleLabel.
  ///
  /// In en, this message translates to:
  /// **'My Patients'**
  String get patientPicker_myPatientsToggleLabel;

  /// No description provided for @patientPicker_urgentPatientHint.
  ///
  /// In en, this message translates to:
  /// **'Create a record for an urgent patient not on the list.'**
  String get patientPicker_urgentPatientHint;

  /// No description provided for @patientPicker_createUrgentPatientButton.
  ///
  /// In en, this message translates to:
  /// **'Create Urgent Patient'**
  String get patientPicker_createUrgentPatientButton;

  /// No description provided for @patientPicker_urgentPatientCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Urgent patient created.'**
  String get patientPicker_urgentPatientCreatedMessage;

  /// No description provided for @patientPicker_urgentPatientCardDescription.
  ///
  /// In en, this message translates to:
  /// **'An urgent patient record was created. If you want to return to the normal flow, you need to delete the urgent patient.'**
  String get patientPicker_urgentPatientCardDescription;

  /// No description provided for @hw_cabinOps_serumSlaveModeError.
  ///
  /// In en, this message translates to:
  /// **'The serum card could not be set to slave mode...'**
  String get hw_cabinOps_serumSlaveModeError;

  /// No description provided for @hw_cabinOps_solenoidMissingError.
  ///
  /// In en, this message translates to:
  /// **'Port {port} has no solenoid (.no).'**
  String hw_cabinOps_solenoidMissingError(Object port);

  /// No description provided for @hw_cabinOps_portOpenFailedError.
  ///
  /// In en, this message translates to:
  /// **'Port {port} could not be opened. Response: {response}'**
  String hw_cabinOps_portOpenFailedError(Object port, Object response);

  /// No description provided for @hw_cabinOps_masterDrawerOpenFailedError.
  ///
  /// In en, this message translates to:
  /// **'The master drawer could not be opened (row={row}, port={port}, drawer={drawer}). Response: {response}'**
  String hw_cabinOps_masterDrawerOpenFailedError(
    Object row,
    Object port,
    Object drawer,
    Object response,
  );

  /// No description provided for @hw_cabinOps_masterSerumOpenFailedError.
  ///
  /// In en, this message translates to:
  /// **'The master serum drawer could not be opened (row={row}). Response: {response}'**
  String hw_cabinOps_masterSerumOpenFailedError(Object row, Object response);

  /// No description provided for @hw_cabinOps_sensorLostDuringCloseDetail.
  ///
  /// In en, this message translates to:
  /// **'Communication with the hardware was lost (the sensor is not responding while monitoring closure).'**
  String get hw_cabinOps_sensorLostDuringCloseDetail;

  /// No description provided for @hw_cabinOps_sensorLostDuringOpenDetail.
  ///
  /// In en, this message translates to:
  /// **'Communication with the hardware was lost (the sensor is not responding).'**
  String get hw_cabinOps_sensorLostDuringOpenDetail;

  /// No description provided for @hw_cabinOps_fullyOpenTimeoutDetail.
  ///
  /// In en, this message translates to:
  /// **'The drawer did not reach the fully open state within {timeout}.'**
  String hw_cabinOps_fullyOpenTimeoutDetail(Object timeout);

  /// No description provided for @hw_serial_connectFailedDetailedError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to port {portName}. Make sure the device is connected and powered on, and that the port isn\'t in use by another application.'**
  String hw_serial_connectFailedDetailedError(String portName);

  /// No description provided for @hw_serial_portConfigFailedError.
  ///
  /// In en, this message translates to:
  /// **'Port configuration failed ({portName}): {error}'**
  String hw_serial_portConfigFailedError(String portName, Object error);

  /// No description provided for @hw_serial_systemErrorSuffix.
  ///
  /// In en, this message translates to:
  /// **'System error: {error}'**
  String hw_serial_systemErrorSuffix(Object error);

  /// No description provided for @hw_serial_portInUseSuffix.
  ///
  /// In en, this message translates to:
  /// **'The port may be in use by another application.'**
  String get hw_serial_portInUseSuffix;

  /// No description provided for @hw_serial_readErrorWithDetail.
  ///
  /// In en, this message translates to:
  /// **'Port read error: {error}'**
  String hw_serial_readErrorWithDetail(Object error);

  /// No description provided for @hw_serial_reconnectingStatus.
  ///
  /// In en, this message translates to:
  /// **'Restarting the connection.'**
  String get hw_serial_reconnectingStatus;

  /// No description provided for @hw_rfid_connectFailedError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the RFID reader: {error}'**
  String hw_rfid_connectFailedError(Object error);

  /// No description provided for @hw_rfid_invalidResponseError.
  ///
  /// In en, this message translates to:
  /// **'An invalid response was received.'**
  String get hw_rfid_invalidResponseError;

  /// No description provided for @hw_rfid_unreachableError.
  ///
  /// In en, this message translates to:
  /// **'The RFID reader could not be reached: {error}'**
  String hw_rfid_unreachableError(Object error);

  /// No description provided for @hw_rfid_testTimeoutError.
  ///
  /// In en, this message translates to:
  /// **'The RFID connection test timed out.'**
  String get hw_rfid_testTimeoutError;

  /// No description provided for @hw_rfid_powerChangeBlockedError.
  ///
  /// In en, this message translates to:
  /// **'The power setting cannot be changed while inventory is active. Call stopInventory() first.'**
  String get hw_rfid_powerChangeBlockedError;

  /// No description provided for @hw_rfid_setModeRejectedError.
  ///
  /// In en, this message translates to:
  /// **'SetWorkingMode was rejected (status=0x{status})'**
  String hw_rfid_setModeRejectedError(Object status);

  /// No description provided for @hw_rfid_setAntennaRejectedError.
  ///
  /// In en, this message translates to:
  /// **'SetWorkingAntenna was rejected (status=0x{status})'**
  String hw_rfid_setAntennaRejectedError(Object status);

  /// No description provided for @hw_rfid_antennaConnFailedHint.
  ///
  /// In en, this message translates to:
  /// **' (antenna connection error — one of the enabled ports is empty)'**
  String get hw_rfid_antennaConnFailedHint;

  /// No description provided for @hw_rfid_noAntennaConnectedError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to any antenna (all ports are empty).'**
  String get hw_rfid_noAntennaConnectedError;

  /// No description provided for @hw_rfid_notConnectedError.
  ///
  /// In en, this message translates to:
  /// **'The RFID service is not connected.'**
  String get hw_rfid_notConnectedError;

  /// No description provided for @hw_rfid_commandPendingError.
  ///
  /// In en, this message translates to:
  /// **'The previous command is still awaiting a response.'**
  String get hw_rfid_commandPendingError;

  /// No description provided for @hw_rfid_commandTimeoutError.
  ///
  /// In en, this message translates to:
  /// **'The command response timed out (cmd=0x{cmd}).'**
  String hw_rfid_commandTimeoutError(Object cmd);

  /// No description provided for @hw_rfid_commandErrorWithDetail.
  ///
  /// In en, this message translates to:
  /// **'Command error: {error}'**
  String hw_rfid_commandErrorWithDetail(Object error);

  /// No description provided for @hw_rfid_mockNotConnectedError.
  ///
  /// In en, this message translates to:
  /// **'The mock RFID service is not connected.'**
  String get hw_rfid_mockNotConnectedError;

  /// No description provided for @operationStatus_fatalErrorLabel.
  ///
  /// In en, this message translates to:
  /// **'Critical Error'**
  String get operationStatus_fatalErrorLabel;

  /// No description provided for @operationStatus_errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get operationStatus_errorLabel;

  /// No description provided for @operationStatus_rollingBackLabel.
  ///
  /// In en, this message translates to:
  /// **'Rolling back the operation'**
  String get operationStatus_rollingBackLabel;

  /// No description provided for @operationStatus_finalizingLabel.
  ///
  /// In en, this message translates to:
  /// **'Finalizing the operation'**
  String get operationStatus_finalizingLabel;

  /// No description provided for @operationStatus_drugsStillInCabinetLabel.
  ///
  /// In en, this message translates to:
  /// **'Medicines are still in the cabinet'**
  String get operationStatus_drugsStillInCabinetLabel;

  /// No description provided for @operationStatus_incompleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Incomplete / Inconsistent'**
  String get operationStatus_incompleteLabel;

  /// No description provided for @operationStatus_scanningLabel.
  ///
  /// In en, this message translates to:
  /// **'Scanning'**
  String get operationStatus_scanningLabel;

  /// No description provided for @operationStatus_reportedMissingLabel.
  ///
  /// In en, this message translates to:
  /// **'Reported Missing'**
  String get operationStatus_reportedMissingLabel;

  /// No description provided for @operationBanner_unplannedMovementTitle.
  ///
  /// In en, this message translates to:
  /// **'Unplanned movement detected'**
  String get operationBanner_unplannedMovementTitle;

  /// No description provided for @operationBanner_unplannedMovementMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} tag was removed from the cabinet unexpectedly.} other{{count} tags were removed from the cabinet unexpectedly.}} A report will be sent to the pharmacy.'**
  String operationBanner_unplannedMovementMessage(num count);

  /// No description provided for @operationBanner_unexpectedTagBlockingTitle.
  ///
  /// In en, this message translates to:
  /// **'Tag(s) not belonging to this cabinet detected'**
  String get operationBanner_unexpectedTagBlockingTitle;

  /// No description provided for @operationBanner_unexpectedTagWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Unexpected medicine'**
  String get operationBanner_unexpectedTagWarningTitle;

  /// No description provided for @operationBanner_unexpectedTagBlockingMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove the following {count, plural, one{{count} tag} other{{count} tags}} from the drawer to continue.'**
  String operationBanner_unexpectedTagBlockingMessage(num count);

  /// No description provided for @operationBanner_unexpectedTagWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} tag} other{{count} tags}} not belonging to this cabinet {count, plural, one{was} other{were}} read. Please remove {count, plural, one{it} other{them}}.'**
  String operationBanner_unexpectedTagWarningMessage(num count);

  /// No description provided for @operationBanner_missingStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Missing stock'**
  String get operationBanner_missingStockTitle;

  /// No description provided for @operationBanner_missingStockMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} medicine was} other{{count} medicines were}} not found in the cabinet. It will be reported as missing stock when completed.'**
  String operationBanner_missingStockMessage(num count);

  /// No description provided for @common_okButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_okButton;

  /// No description provided for @cabinPatientPicker_searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search patient, room, bed, or service...'**
  String get cabinPatientPicker_searchHint;

  /// No description provided for @common_unknownPatientFallback.
  ///
  /// In en, this message translates to:
  /// **'Unknown Patient'**
  String get common_unknownPatientFallback;

  /// No description provided for @patientListPanel_searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search patient...'**
  String get patientListPanel_searchHint;

  /// No description provided for @rxItemCard_maxQuantitySuffix.
  ///
  /// In en, this message translates to:
  /// **'/ max. {max} {unit}'**
  String rxItemCard_maxQuantitySuffix(String max, String unit);

  /// No description provided for @census_extraStockSummaryMessage.
  ///
  /// In en, this message translates to:
  /// **'Excess stock will be reported at the end of the operation.'**
  String get census_extraStockSummaryMessage;

  /// No description provided for @cabinOperation_hint_scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning the cabinet, please wait'**
  String get cabinOperation_hint_scanning;

  /// No description provided for @census_hint_waitingClose.
  ///
  /// In en, this message translates to:
  /// **'Recorded — close the drawer to finish the census'**
  String get census_hint_waitingClose;

  /// No description provided for @census_hint_closedEarly.
  ///
  /// In en, this message translates to:
  /// **'The drawer closed early — you can retry or cancel'**
  String get census_hint_closedEarly;

  /// No description provided for @cabinOperation_hint_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred — you can retry'**
  String get cabinOperation_hint_error;

  /// No description provided for @census_hint_unexpectedTag.
  ///
  /// In en, this message translates to:
  /// **'There is a tag that doesn\'t belong in this cabinet — remove it to continue'**
  String get census_hint_unexpectedTag;

  /// No description provided for @census_hint_readyToComplete.
  ///
  /// In en, this message translates to:
  /// **'Press the button to complete the census'**
  String get census_hint_readyToComplete;

  /// No description provided for @cabinOperation_action_closeDrawer.
  ///
  /// In en, this message translates to:
  /// **'Close the Drawer'**
  String get cabinOperation_action_closeDrawer;

  /// No description provided for @census_label_counted.
  ///
  /// In en, this message translates to:
  /// **'Counted'**
  String get census_label_counted;

  /// No description provided for @census_label_excess.
  ///
  /// In en, this message translates to:
  /// **'Excess'**
  String get census_label_excess;

  /// No description provided for @cabinOperation_label_unexpectedTag.
  ///
  /// In en, this message translates to:
  /// **'Foreign'**
  String get cabinOperation_label_unexpectedTag;

  /// No description provided for @intake_error_witnessRequired.
  ///
  /// In en, this message translates to:
  /// **'A witness login is required.'**
  String get intake_error_witnessRequired;

  /// No description provided for @intake_error_noValidTargets.
  ///
  /// In en, this message translates to:
  /// **'The intake could not be performed for the selected medicines.'**
  String get intake_error_noValidTargets;

  /// No description provided for @intake_error_noDrawerFound.
  ///
  /// In en, this message translates to:
  /// **'No drawer was found to take from.'**
  String get intake_error_noDrawerFound;

  /// No description provided for @intake_hint_noStock.
  ///
  /// In en, this message translates to:
  /// **'There is no stock in the cabinet'**
  String get intake_hint_noStock;

  /// No description provided for @intake_label_witnessName.
  ///
  /// In en, this message translates to:
  /// **'Witness: {name}'**
  String intake_label_witnessName(String name);

  /// No description provided for @intake_hint_witnessRequired.
  ///
  /// In en, this message translates to:
  /// **'Witness login required'**
  String get intake_hint_witnessRequired;

  /// No description provided for @intake_status_checking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get intake_status_checking;

  /// No description provided for @intake_status_readyToTake.
  ///
  /// In en, this message translates to:
  /// **'Ready to take'**
  String get intake_status_readyToTake;

  /// No description provided for @intake_status_checkFailed.
  ///
  /// In en, this message translates to:
  /// **'Check failed'**
  String get intake_status_checkFailed;

  /// No description provided for @intake_emptyState_selectMedicine.
  ///
  /// In en, this message translates to:
  /// **'Select a medicine to start the intake.'**
  String get intake_emptyState_selectMedicine;

  /// No description provided for @intake_label_multiMedicine.
  ///
  /// In en, this message translates to:
  /// **'{count} different medicines'**
  String intake_label_multiMedicine(int count);

  /// No description provided for @intake_label_takenAmount.
  ///
  /// In en, this message translates to:
  /// **'Taken: {amount} {unit}'**
  String intake_label_takenAmount(String amount, String unit);

  /// No description provided for @intake_label_countFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Count ({unit})'**
  String intake_label_countFieldLabel(String unit);

  /// No description provided for @intake_hint_nextCellOpens.
  ///
  /// In en, this message translates to:
  /// **'The next cell will open once you confirm.'**
  String get intake_hint_nextCellOpens;

  /// No description provided for @intake_hint_confirmCloses.
  ///
  /// In en, this message translates to:
  /// **'The drawer will close once you confirm.'**
  String get intake_hint_confirmCloses;

  /// No description provided for @intake_hint_searchMedicine.
  ///
  /// In en, this message translates to:
  /// **'Search medicine (name / barcode)'**
  String get intake_hint_searchMedicine;

  /// No description provided for @intake_hint_selectionLocked.
  ///
  /// In en, this message translates to:
  /// **'Intake in progress — selection is locked.'**
  String get intake_hint_selectionLocked;

  /// No description provided for @intake_hint_autoQueueOrder.
  ///
  /// In en, this message translates to:
  /// **'Drawers will open in the shortest-path order.'**
  String get intake_hint_autoQueueOrder;

  /// No description provided for @intake_info_witnessAutoAssigned.
  ///
  /// In en, this message translates to:
  /// **'{name} was also assigned as the witness for this medicine.'**
  String intake_info_witnessAutoAssigned(String name);

  /// No description provided for @intake_error_queueTitle.
  ///
  /// In en, this message translates to:
  /// **'The intake could not be completed'**
  String get intake_error_queueTitle;

  /// No description provided for @intake_error_queueMessage.
  ///
  /// In en, this message translates to:
  /// **'Put the medicines back where you took them from.'**
  String get intake_error_queueMessage;

  /// No description provided for @intake_error_selfWitness.
  ///
  /// In en, this message translates to:
  /// **'The user performing the operation cannot also witness it.'**
  String get intake_error_selfWitness;

  /// No description provided for @intake_success_witnessConfirmed.
  ///
  /// In en, this message translates to:
  /// **'{name} was confirmed as the witness.'**
  String intake_success_witnessConfirmed(String name);

  /// No description provided for @intake_witnessDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Witness Verification'**
  String get intake_witnessDialog_title;

  /// No description provided for @intake_witnessDialog_usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Witness Username'**
  String get intake_witnessDialog_usernameLabel;

  /// No description provided for @intake_witnessDialog_usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a username'**
  String get intake_witnessDialog_usernameRequired;

  /// No description provided for @intake_witnessDialog_passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Witness Password'**
  String get intake_witnessDialog_passwordLabel;

  /// No description provided for @intake_witnessDialog_passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a password'**
  String get intake_witnessDialog_passwordRequired;

  /// No description provided for @intake_witnessDialog_confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm Witness'**
  String get intake_witnessDialog_confirmButton;

  /// No description provided for @intake_witnessDialog_anyoneInfo.
  ///
  /// In en, this message translates to:
  /// **'Any staff member can witness this operation.'**
  String get intake_witnessDialog_anyoneInfo;

  /// No description provided for @intake_witnessDialog_authorizedWitnesses.
  ///
  /// In en, this message translates to:
  /// **'Authorized Witnesses ({count})'**
  String intake_witnessDialog_authorizedWitnesses(int count);

  /// No description provided for @cabinOperation_hint_fatalError.
  ///
  /// In en, this message translates to:
  /// **'A critical error occurred: {message}'**
  String cabinOperation_hint_fatalError(String message);

  /// No description provided for @cabinOperation_hint_completed.
  ///
  /// In en, this message translates to:
  /// **'Operation completed'**
  String get cabinOperation_hint_completed;

  /// No description provided for @cabinOperation_hint_waitingCloseGeneric.
  ///
  /// In en, this message translates to:
  /// **'Recorded. Close the drawer to finish the operation'**
  String get cabinOperation_hint_waitingCloseGeneric;

  /// No description provided for @cabinOperation_hint_closedEarlyGeneric.
  ///
  /// In en, this message translates to:
  /// **'The drawer was closed. You can cancel or continue where you left off'**
  String get cabinOperation_hint_closedEarlyGeneric;

  /// No description provided for @cabinOperation_hint_ready.
  ///
  /// In en, this message translates to:
  /// **'Ready — you can complete the operation'**
  String get cabinOperation_hint_ready;

  /// No description provided for @intake_hint_extraPlacement.
  ///
  /// In en, this message translates to:
  /// **'A medicine that shouldn\'t be in the cabinet was loaded, please remove it.'**
  String get intake_hint_extraPlacement;

  /// No description provided for @intake_hint_takeItems.
  ///
  /// In en, this message translates to:
  /// **'Take the medicines, then complete the operation'**
  String get intake_hint_takeItems;

  /// No description provided for @cabinOperation_action_completeGeneric.
  ///
  /// In en, this message translates to:
  /// **'Complete the operation'**
  String get cabinOperation_action_completeGeneric;

  /// No description provided for @rfidStatus_notFound.
  ///
  /// In en, this message translates to:
  /// **'Not Found'**
  String get rfidStatus_notFound;

  /// No description provided for @rfidStatus_scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning'**
  String get rfidStatus_scanning;

  /// No description provided for @intake_label_noRfid.
  ///
  /// In en, this message translates to:
  /// **'No RFID'**
  String get intake_label_noRfid;

  /// No description provided for @cabinOperation_label_selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get cabinOperation_label_selected;

  /// No description provided for @intake_label_readInCabin.
  ///
  /// In en, this message translates to:
  /// **'Read in Cabinet'**
  String get intake_label_readInCabin;

  /// No description provided for @intake_label_tagCount.
  ///
  /// In en, this message translates to:
  /// **'{count} tags'**
  String intake_label_tagCount(int count);

  /// No description provided for @intake_label_takenCount.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get intake_label_takenCount;

  /// No description provided for @intake_label_unauthorizedTake.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized Take'**
  String get intake_label_unauthorizedTake;

  /// No description provided for @intake_error_retryOrFinish.
  ///
  /// In en, this message translates to:
  /// **'You can retry, or finish the operation by taking back the medicines you placed.'**
  String get intake_error_retryOrFinish;

  /// No description provided for @refill_label_placed.
  ///
  /// In en, this message translates to:
  /// **'Placed'**
  String get refill_label_placed;

  /// No description provided for @refill_label_placedCount.
  ///
  /// In en, this message translates to:
  /// **'Placed'**
  String get refill_label_placedCount;

  /// No description provided for @refill_label_placedProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total}'**
  String refill_label_placedProgress(Object done, Object total);

  /// No description provided for @cabinOperation_label_unplanned.
  ///
  /// In en, this message translates to:
  /// **'Unplanned'**
  String get cabinOperation_label_unplanned;

  /// No description provided for @refill_label_extraTag.
  ///
  /// In en, this message translates to:
  /// **'Extra Tag'**
  String get refill_label_extraTag;

  /// No description provided for @refill_error_retry.
  ///
  /// In en, this message translates to:
  /// **'You can try again.'**
  String get refill_error_retry;

  /// No description provided for @unload_hint_waitingClose.
  ///
  /// In en, this message translates to:
  /// **'Recorded — close the drawer to finish unloading'**
  String get unload_hint_waitingClose;

  /// No description provided for @unload_hint_closedEarly.
  ///
  /// In en, this message translates to:
  /// **'The drawer closed early — you can retry or cancel'**
  String get unload_hint_closedEarly;

  /// No description provided for @unload_hint_readyToComplete.
  ///
  /// In en, this message translates to:
  /// **'Press the button to complete unloading'**
  String get unload_hint_readyToComplete;

  /// No description provided for @unload_label_unloaded.
  ///
  /// In en, this message translates to:
  /// **'Unloaded'**
  String get unload_label_unloaded;

  /// No description provided for @unload_label_unloadProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total}'**
  String unload_label_unloadProgress(Object done, Object total);

  /// No description provided for @wizard_stepBadge.
  ///
  /// In en, this message translates to:
  /// **'Step {step} / {total}'**
  String wizard_stepBadge(int step, int total);

  /// No description provided for @wizard_step4Header.
  ///
  /// In en, this message translates to:
  /// **'Drawer Configuration'**
  String get wizard_step4Header;

  /// No description provided for @wizard_step4SubtitleMobile.
  ///
  /// In en, this message translates to:
  /// **'Define the mobile cabinet\'s drawer count, internal sections, and port connections.'**
  String get wizard_step4SubtitleMobile;

  /// No description provided for @wizard_step4SubtitleMaster.
  ///
  /// In en, this message translates to:
  /// **'The cabinet\'s internal structure will be read automatically from the device.'**
  String get wizard_step4SubtitleMaster;

  /// No description provided for @wizard_backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get wizard_backButton;

  /// No description provided for @wizard_testCabinConnectionButton.
  ///
  /// In en, this message translates to:
  /// **'Test Cabinet Connection'**
  String get wizard_testCabinConnectionButton;

  /// No description provided for @wizard_testingInProgress.
  ///
  /// In en, this message translates to:
  /// **'Testing…'**
  String get wizard_testingInProgress;

  /// No description provided for @wizard_connectionSuccessLabel.
  ///
  /// In en, this message translates to:
  /// **'Connection successful'**
  String get wizard_connectionSuccessLabel;

  /// No description provided for @wizard_retestLink.
  ///
  /// In en, this message translates to:
  /// **'Test again'**
  String get wizard_retestLink;

  /// No description provided for @wizard_cabinConnectionErrorFallback.
  ///
  /// In en, this message translates to:
  /// **'Could not establish a connection. Check the port settings.'**
  String get wizard_cabinConnectionErrorFallback;

  /// No description provided for @wizard_testRfidConnectionButton.
  ///
  /// In en, this message translates to:
  /// **'Test Antenna Connection'**
  String get wizard_testRfidConnectionButton;

  /// No description provided for @wizard_rfidFirmwareInfo.
  ///
  /// In en, this message translates to:
  /// **'· FW {firmwareVersion}  {power} dBm'**
  String wizard_rfidFirmwareInfo(String firmwareVersion, Object power);

  /// No description provided for @wizard_rfidConnectionErrorFallback.
  ///
  /// In en, this message translates to:
  /// **'Could not establish a connection. Check the IP and port settings.'**
  String get wizard_rfidConnectionErrorFallback;

  /// No description provided for @wizard_portLabel.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get wizard_portLabel;

  /// No description provided for @wizard_rfidReaderToggleLabel.
  ///
  /// In en, this message translates to:
  /// **'Has RFID reader'**
  String get wizard_rfidReaderToggleLabel;

  /// No description provided for @wizard_rfidIpAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'RFID IP Address'**
  String get wizard_rfidIpAddressLabel;

  /// No description provided for @wizard_rfidPortFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'RFID Port'**
  String get wizard_rfidPortFieldLabel;

  /// No description provided for @wizard_drawerCountRangeHint.
  ///
  /// In en, this message translates to:
  /// **'1–8 drawers'**
  String get wizard_drawerCountRangeHint;

  /// No description provided for @wizard_sameConfigToggleLabel.
  ///
  /// In en, this message translates to:
  /// **'All drawers have the same structure'**
  String get wizard_sameConfigToggleLabel;

  /// No description provided for @wizard_sameConfigToggleOnDesc.
  ///
  /// In en, this message translates to:
  /// **'All drawers use the same row/column configuration'**
  String get wizard_sameConfigToggleOnDesc;

  /// No description provided for @wizard_sameConfigToggleOffDesc.
  ///
  /// In en, this message translates to:
  /// **'When off, row/column can be set separately for each drawer'**
  String get wizard_sameConfigToggleOffDesc;

  /// No description provided for @wizard_drawerRowCellSummary.
  ///
  /// In en, this message translates to:
  /// **'{rowCount} rows · {totalCells} cells'**
  String wizard_drawerRowCellSummary(int rowCount, int totalCells);

  /// No description provided for @wizard_drawerPortLabel.
  ///
  /// In en, this message translates to:
  /// **'Port {portNumber}'**
  String wizard_drawerPortLabel(Object portNumber);

  /// No description provided for @wizard_rowLabel.
  ///
  /// In en, this message translates to:
  /// **'ROW {rowIndex}'**
  String wizard_rowLabel(int rowIndex);

  /// No description provided for @wizard_serviceDetailsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the service details.'**
  String get wizard_serviceDetailsLoadError;

  /// No description provided for @wizard_stationDetailsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the station details.'**
  String get wizard_stationDetailsLoadError;

  /// No description provided for @wizard_stationsLoadErrorFallback.
  ///
  /// In en, this message translates to:
  /// **'Could not load the stations.'**
  String get wizard_stationsLoadErrorFallback;

  /// No description provided for @wizard_noStationsFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'No registered stations were found.'**
  String get wizard_noStationsFoundMessage;

  /// No description provided for @wizard_noRoomsDefinedMessage.
  ///
  /// In en, this message translates to:
  /// **'No rooms are defined for this station.'**
  String get wizard_noRoomsDefinedMessage;

  /// No description provided for @wizard_selectedRoomCountBadge.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} room} other{{count} rooms}}'**
  String wizard_selectedRoomCountBadge(int count);

  /// No description provided for @wizard_roomSelectionFraction.
  ///
  /// In en, this message translates to:
  /// **'{selected}/{total}'**
  String wizard_roomSelectionFraction(int selected, int total);

  /// No description provided for @refill_hint_extraPlacement.
  ///
  /// In en, this message translates to:
  /// **'A tag other than the selected medicines was placed, please remove it'**
  String get refill_hint_extraPlacement;

  /// No description provided for @refill_hint_placeItems.
  ///
  /// In en, this message translates to:
  /// **'Place the medicines, then complete the operation'**
  String get refill_hint_placeItems;

  /// No description provided for @appException_networkUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server. Check your network connection.'**
  String get appException_networkUnavailable;

  /// No description provided for @appException_timeout.
  ///
  /// In en, this message translates to:
  /// **'The server did not respond. Please try again.'**
  String get appException_timeout;

  /// No description provided for @appException_serviceError5xx.
  ///
  /// In en, this message translates to:
  /// **'Server error ({statusCode}). Please try again.'**
  String appException_serviceError5xx(Object statusCode);

  /// No description provided for @appException_serviceErrorOther.
  ///
  /// In en, this message translates to:
  /// **'The operation could not be completed ({statusCode}).'**
  String appException_serviceErrorOther(Object statusCode);

  /// No description provided for @appException_malformedData.
  ///
  /// In en, this message translates to:
  /// **'Unexpected data was received from the server.'**
  String get appException_malformedData;

  /// No description provided for @appException_emptyResponse.
  ///
  /// In en, this message translates to:
  /// **'The server returned an empty response.'**
  String get appException_emptyResponse;

  /// No description provided for @appException_validationField.
  ///
  /// In en, this message translates to:
  /// **'The {field} field is invalid.'**
  String appException_validationField(String field);

  /// No description provided for @appException_validationGeneric.
  ///
  /// In en, this message translates to:
  /// **'The information entered is invalid.'**
  String get appException_validationGeneric;

  /// No description provided for @appException_mapping.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while processing the data.'**
  String get appException_mapping;

  /// No description provided for @appException_cache.
  ///
  /// In en, this message translates to:
  /// **'Could not read local data.'**
  String get appException_cache;

  /// No description provided for @appException_staleCache.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach up-to-date data. Please check the connection.'**
  String get appException_staleCache;

  /// No description provided for @appException_notFoundWithType.
  ///
  /// In en, this message translates to:
  /// **'{resourceType} not found.'**
  String appException_notFoundWithType(String resourceType);

  /// No description provided for @appException_notFoundGeneric.
  ///
  /// In en, this message translates to:
  /// **'Record not found.'**
  String get appException_notFoundGeneric;

  /// No description provided for @appException_unexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get appException_unexpected;

  /// No description provided for @appException_serialPort.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the serial port. Please contact technical service.'**
  String get appException_serialPort;

  /// No description provided for @appException_custom.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred. Please try again later.'**
  String get appException_custom;

  /// No description provided for @dataError_emptyResponse.
  ///
  /// In en, this message translates to:
  /// **'The server returned an empty response'**
  String get dataError_emptyResponse;

  /// No description provided for @dataError_malformedResponse.
  ///
  /// In en, this message translates to:
  /// **'The response could not be processed'**
  String get dataError_malformedResponse;

  /// No description provided for @dataError_requestTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request timed out'**
  String get dataError_requestTimeout;

  /// No description provided for @dataError_networkUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the network'**
  String get dataError_networkUnavailable;

  /// No description provided for @dataError_genericApiError.
  ///
  /// In en, this message translates to:
  /// **'We encountered an error. Please try again later.'**
  String get dataError_genericApiError;

  /// No description provided for @dataError_requestCancelled.
  ///
  /// In en, this message translates to:
  /// **'The request was cancelled'**
  String get dataError_requestCancelled;

  /// No description provided for @dataError_envelopeErrorFallback.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get dataError_envelopeErrorFallback;

  /// No description provided for @authError_invalidTokenResponse.
  ///
  /// In en, this message translates to:
  /// **'An invalid token response was received from the server'**
  String get authError_invalidTokenResponse;

  /// No description provided for @authError_userInfoFetchFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not retrieve user information'**
  String get authError_userInfoFetchFailed;

  /// No description provided for @authError_userInfoEmpty.
  ///
  /// In en, this message translates to:
  /// **'The user information returned was empty'**
  String get authError_userInfoEmpty;

  /// No description provided for @authError_genericLoginError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get authError_genericLoginError;

  /// No description provided for @authError_invalidCredentialsMock.
  ///
  /// In en, this message translates to:
  /// **'Incorrect username or password.'**
  String get authError_invalidCredentialsMock;

  /// No description provided for @dataGuard_deleteActiveIngredientIdEmpty.
  ///
  /// In en, this message translates to:
  /// **'The ID of the active ingredient to delete cannot be empty'**
  String get dataGuard_deleteActiveIngredientIdEmpty;

  /// No description provided for @dataGuard_deleteBranchIdEmpty.
  ///
  /// In en, this message translates to:
  /// **'The ID of the branch to delete cannot be empty'**
  String get dataGuard_deleteBranchIdEmpty;

  /// No description provided for @dataGuard_deleteCabinIdEmpty.
  ///
  /// In en, this message translates to:
  /// **'The ID of the cabinet to delete cannot be empty'**
  String get dataGuard_deleteCabinIdEmpty;

  /// No description provided for @dataGuard_deleteDosageFormIdEmpty.
  ///
  /// In en, this message translates to:
  /// **'The ID of the dosage form to delete cannot be empty'**
  String get dataGuard_deleteDosageFormIdEmpty;

  /// No description provided for @dataGuard_deleteDrugClassIdEmpty.
  ///
  /// In en, this message translates to:
  /// **'The ID of the drug class to delete cannot be empty'**
  String get dataGuard_deleteDrugClassIdEmpty;

  /// No description provided for @dataGuard_deleteFirmIdEmpty.
  ///
  /// In en, this message translates to:
  /// **'The ID of the firm to delete cannot be empty'**
  String get dataGuard_deleteFirmIdEmpty;

  /// No description provided for @dataGuard_deleteDrugTypeIdEmpty.
  ///
  /// In en, this message translates to:
  /// **'The ID of the drug type to delete cannot be empty'**
  String get dataGuard_deleteDrugTypeIdEmpty;

  /// No description provided for @dataGuard_deleteHospitalizationIdEmpty.
  ///
  /// In en, this message translates to:
  /// **'The ID of the admission to delete cannot be empty'**
  String get dataGuard_deleteHospitalizationIdEmpty;

  /// No description provided for @dataGuard_deleteKitIdEmpty.
  ///
  /// In en, this message translates to:
  /// **'The ID of the kit to delete cannot be empty'**
  String get dataGuard_deleteKitIdEmpty;

  /// No description provided for @dataGuard_deleteKitContentIdEmpty.
  ///
  /// In en, this message translates to:
  /// **'The ID of the kit content to delete cannot be empty'**
  String get dataGuard_deleteKitContentIdEmpty;

  /// No description provided for @dataGuard_deleteMaterialTypeIdEmpty.
  ///
  /// In en, this message translates to:
  /// **'The ID of the material type to delete cannot be empty'**
  String get dataGuard_deleteMaterialTypeIdEmpty;

  /// No description provided for @dataGuard_deleteMedicineIdEmpty.
  ///
  /// In en, this message translates to:
  /// **'The ID of the medicine to delete cannot be empty'**
  String get dataGuard_deleteMedicineIdEmpty;

  /// No description provided for @dataGuard_deletePatientIdEmpty.
  ///
  /// In en, this message translates to:
  /// **'The ID of the patient to delete cannot be empty'**
  String get dataGuard_deletePatientIdEmpty;

  /// No description provided for @dataGuard_deleteRoleIdEmpty.
  ///
  /// In en, this message translates to:
  /// **'The ID of the role to delete cannot be empty'**
  String get dataGuard_deleteRoleIdEmpty;

  /// No description provided for @dataGuard_deleteServiceIdEmpty.
  ///
  /// In en, this message translates to:
  /// **'The ID of the service to delete cannot be empty'**
  String get dataGuard_deleteServiceIdEmpty;

  /// No description provided for @dataGuard_deleteStationIdEmpty.
  ///
  /// In en, this message translates to:
  /// **'The ID of the station to delete cannot be empty'**
  String get dataGuard_deleteStationIdEmpty;

  /// No description provided for @dataGuard_deleteUnitIdEmpty.
  ///
  /// In en, this message translates to:
  /// **'The ID of the unit to delete cannot be empty'**
  String get dataGuard_deleteUnitIdEmpty;

  /// No description provided for @dataGuard_deleteWarehouseIdEmpty.
  ///
  /// In en, this message translates to:
  /// **'The ID of the warehouse to delete cannot be empty'**
  String get dataGuard_deleteWarehouseIdEmpty;

  /// No description provided for @dataGuard_deleteWarningIdEmpty.
  ///
  /// In en, this message translates to:
  /// **'The ID of the warning to delete cannot be empty'**
  String get dataGuard_deleteWarningIdEmpty;

  /// No description provided for @dataGuard_updatePatientIdEmpty.
  ///
  /// In en, this message translates to:
  /// **'The ID of the patient to update cannot be empty'**
  String get dataGuard_updatePatientIdEmpty;

  /// No description provided for @dataGuard_updateHospitalizationIdEmpty.
  ///
  /// In en, this message translates to:
  /// **'The ID of the admission to update cannot be empty'**
  String get dataGuard_updateHospitalizationIdEmpty;

  /// No description provided for @dataGuard_dosageFormNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Dosage form name is required'**
  String get dataGuard_dosageFormNameRequired;

  /// No description provided for @dataGuard_roleNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Role name is required'**
  String get dataGuard_roleNameRequired;

  /// No description provided for @dataGuard_branchNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Branch name is required'**
  String get dataGuard_branchNameRequired;

  /// No description provided for @dataGuard_warehouseNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Warehouse name is required'**
  String get dataGuard_warehouseNameRequired;

  /// No description provided for @dataGuard_warningTextRequired.
  ///
  /// In en, this message translates to:
  /// **'Warning text is required'**
  String get dataGuard_warningTextRequired;

  /// No description provided for @dataGuard_activeIngredientNameRequired.
  ///
  /// In en, this message translates to:
  /// **'The name field is required'**
  String get dataGuard_activeIngredientNameRequired;

  /// No description provided for @core_genericErrorRetryMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again later.'**
  String get core_genericErrorRetryMessage;

  /// No description provided for @core_genericErrorShortMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get core_genericErrorShortMessage;

  /// No description provided for @common_defaultReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get common_defaultReportTitle;

  /// No description provided for @fileExport_savedMessage.
  ///
  /// In en, this message translates to:
  /// **'File saved: {path}'**
  String fileExport_savedMessage(String path);

  /// No description provided for @fileExport_pdfSaveErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'PDF save error: {error}'**
  String fileExport_pdfSaveErrorMessage(Object error);

  /// No description provided for @fileExport_printErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Print error: {error}'**
  String fileExport_printErrorMessage(Object error);

  /// No description provided for @fileExport_saveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save File'**
  String get fileExport_saveDialogTitle;

  /// No description provided for @fileExport_saveErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'File save error: {error}'**
  String fileExport_saveErrorMessage(Object error);

  /// No description provided for @fileExport_saveToDesktopErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error saving to desktop: {error}'**
  String fileExport_saveToDesktopErrorMessage(Object error);

  /// No description provided for @fileExport_savedSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'File saved successfully: {path}'**
  String fileExport_savedSuccessMessage(String path);

  /// No description provided for @fileExport_saveCancelledMessage.
  ///
  /// In en, this message translates to:
  /// **'File save was cancelled'**
  String get fileExport_saveCancelledMessage;

  /// No description provided for @fileExport_excelCreateFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to create the Excel file'**
  String get fileExport_excelCreateFailedMessage;

  /// No description provided for @fileExport_excelExportFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Excel export failed: {error}'**
  String fileExport_excelExportFailedMessage(Object error);

  /// No description provided for @fileExport_tableExportFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Table export failed: {error}'**
  String fileExport_tableExportFailedMessage(Object error);

  /// No description provided for @cabinCore_createError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while creating the cabinet. Please try again later.'**
  String get cabinCore_createError;

  /// No description provided for @cabinCore_activeCabinNotFound.
  ///
  /// In en, this message translates to:
  /// **'No active cabinet found'**
  String get cabinCore_activeCabinNotFound;

  /// No description provided for @cabinCore_mobileCabinDesignNotFound.
  ///
  /// In en, this message translates to:
  /// **'Mobile cabinet design not found'**
  String get cabinCore_mobileCabinDesignNotFound;

  /// No description provided for @cabinCore_cabinDesignNotFound.
  ///
  /// In en, this message translates to:
  /// **'Cabinet design not found'**
  String get cabinCore_cabinDesignNotFound;

  /// No description provided for @cabinCore_createdButIdMissing.
  ///
  /// In en, this message translates to:
  /// **'The cabinet was created but its ID could not be retrieved.'**
  String get cabinCore_createdButIdMissing;

  /// No description provided for @cabinCore_definitionsNotFound.
  ///
  /// In en, this message translates to:
  /// **'The definitions could not be retrieved.'**
  String get cabinCore_definitionsNotFound;

  /// No description provided for @cabinCore_noCardsFound.
  ///
  /// In en, this message translates to:
  /// **'No cards were found.'**
  String get cabinCore_noCardsFound;

  /// No description provided for @cabinCore_noMatchingDrawerFound.
  ///
  /// In en, this message translates to:
  /// **'No matching drawer was found.'**
  String get cabinCore_noMatchingDrawerFound;

  /// No description provided for @cabinCore_designDataNotFound.
  ///
  /// In en, this message translates to:
  /// **'No data was found to save.'**
  String get cabinCore_designDataNotFound;

  /// No description provided for @cabinCore_targetDrawerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Target drawer/cell not found'**
  String get cabinCore_targetDrawerNotFound;

  /// No description provided for @cabinCore_unknownMedicineFallback.
  ///
  /// In en, this message translates to:
  /// **'Unknown Medicine'**
  String get cabinCore_unknownMedicineFallback;

  /// No description provided for @cabinAssignmentList_selectColumn.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get cabinAssignmentList_selectColumn;

  /// No description provided for @cabinAssignmentList_medicineColumn.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get cabinAssignmentList_medicineColumn;

  /// No description provided for @cabinAssignmentList_locationColumn.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get cabinAssignmentList_locationColumn;

  /// No description provided for @cabinAssignmentList_stockColumn.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get cabinAssignmentList_stockColumn;

  /// No description provided for @cabinAssignmentList_fillLevelColumn.
  ///
  /// In en, this message translates to:
  /// **'Fill Level'**
  String get cabinAssignmentList_fillLevelColumn;

  /// No description provided for @cabinAssignmentList_cubicLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Drawer {drawer} - Column {column} - Row {row}'**
  String cabinAssignmentList_cubicLocationLabel(
    Object drawer,
    Object column,
    Object row,
  );

  /// No description provided for @cabinAssignmentList_unitLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Drawer {drawer} - Cell {cell}'**
  String cabinAssignmentList_unitLocationLabel(Object drawer, Object cell);

  /// No description provided for @cabinOverview_panelTitle.
  ///
  /// In en, this message translates to:
  /// **'CABIN OVERVIEW'**
  String get cabinOverview_panelTitle;

  /// No description provided for @cabinOverview_cubicDrawerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cubic Drawer'**
  String get cabinOverview_cubicDrawerSubtitle;

  /// No description provided for @cabinOverview_unitDoseDrawerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unit Dose Drawer'**
  String get cabinOverview_unitDoseDrawerSubtitle;

  /// No description provided for @cabinOverview_cubicTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'CUBIC'**
  String get cabinOverview_cubicTypeLabel;

  /// No description provided for @cabinOverview_unitDoseTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'UNIT DOSE'**
  String get cabinOverview_unitDoseTypeLabel;

  /// No description provided for @cabinOverview_returnMergedCellLabel.
  ///
  /// In en, this message translates to:
  /// **'RETURN'**
  String get cabinOverview_returnMergedCellLabel;

  /// No description provided for @cabinOverview_legendFillingLabel.
  ///
  /// In en, this message translates to:
  /// **'Currently filling'**
  String get cabinOverview_legendFillingLabel;

  /// No description provided for @cabinOverview_legendCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get cabinOverview_legendCompletedLabel;

  /// No description provided for @cabinOverview_legendQueuedLabel.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get cabinOverview_legendQueuedLabel;

  /// No description provided for @cabinOverview_locationGuideLabel.
  ///
  /// In en, this message translates to:
  /// **'LOCATION GUIDE'**
  String get cabinOverview_locationGuideLabel;

  /// No description provided for @prescriptionCore_createError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while creating the prescription. Please try again later.'**
  String get prescriptionCore_createError;

  /// No description provided for @prescriptionCore_rfidTagNotFoundInReader.
  ///
  /// In en, this message translates to:
  /// **'No RFID tag was found in the reader\'s range.'**
  String get prescriptionCore_rfidTagNotFoundInReader;

  /// No description provided for @prescriptionCore_rfidReadErrorWithDetail.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while reading the RFID tag: {error}'**
  String prescriptionCore_rfidReadErrorWithDetail(Object error);

  /// No description provided for @prescriptionCore_actionApproveTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve Selected Requests'**
  String get prescriptionCore_actionApproveTitle;

  /// No description provided for @prescriptionCore_actionCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Selected Requests'**
  String get prescriptionCore_actionCancelTitle;

  /// No description provided for @prescriptionCore_actionRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject Selected Requests'**
  String get prescriptionCore_actionRejectTitle;

  /// No description provided for @prescriptionCore_actionRejectAfterApproveTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject Selected Requests'**
  String get prescriptionCore_actionRejectAfterApproveTitle;

  /// No description provided for @tableCore_roleNameColumn.
  ///
  /// In en, this message translates to:
  /// **'Role Name'**
  String get tableCore_roleNameColumn;

  /// No description provided for @tableCore_warningSubjectColumn.
  ///
  /// In en, this message translates to:
  /// **'Warning Subject'**
  String get tableCore_warningSubjectColumn;

  /// No description provided for @tableCore_warningTextColumn.
  ///
  /// In en, this message translates to:
  /// **'Warning Text'**
  String get tableCore_warningTextColumn;

  /// No description provided for @tableCore_warehouseCodeColumn.
  ///
  /// In en, this message translates to:
  /// **'Warehouse Code'**
  String get tableCore_warehouseCodeColumn;

  /// No description provided for @tableCore_warehouseNameColumn.
  ///
  /// In en, this message translates to:
  /// **'Warehouse Name'**
  String get tableCore_warehouseNameColumn;

  /// No description provided for @tableCore_warehouseManagerColumn.
  ///
  /// In en, this message translates to:
  /// **'Warehouse Manager'**
  String get tableCore_warehouseManagerColumn;

  /// No description provided for @tableCore_dosageFormBranchColumn.
  ///
  /// In en, this message translates to:
  /// **'Branch Name'**
  String get tableCore_dosageFormBranchColumn;

  /// No description provided for @tableCore_firmIdColumn.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get tableCore_firmIdColumn;

  /// No description provided for @tableCore_firmNameColumn.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get tableCore_firmNameColumn;

  /// No description provided for @tableCore_firmTypeColumn.
  ///
  /// In en, this message translates to:
  /// **'Firm Type'**
  String get tableCore_firmTypeColumn;

  /// No description provided for @tableCore_firmTaxOfficeColumn.
  ///
  /// In en, this message translates to:
  /// **'Tax Office'**
  String get tableCore_firmTaxOfficeColumn;

  /// No description provided for @tableCore_firmTaxNoColumn.
  ///
  /// In en, this message translates to:
  /// **'Tax No.'**
  String get tableCore_firmTaxNoColumn;

  /// No description provided for @tableCore_kitNameColumn.
  ///
  /// In en, this message translates to:
  /// **'Kit Name'**
  String get tableCore_kitNameColumn;

  /// No description provided for @tableCore_kitContentMaterialNameColumn.
  ///
  /// In en, this message translates to:
  /// **'Material Name'**
  String get tableCore_kitContentMaterialNameColumn;

  /// No description provided for @tableCore_kitContentPieceColumn.
  ///
  /// In en, this message translates to:
  /// **'Piece Count'**
  String get tableCore_kitContentPieceColumn;

  /// No description provided for @tableCore_drugTypeColumn.
  ///
  /// In en, this message translates to:
  /// **'Drug Type'**
  String get tableCore_drugTypeColumn;

  /// No description provided for @tableCore_drugClassColumn.
  ///
  /// In en, this message translates to:
  /// **'Drug Class'**
  String get tableCore_drugClassColumn;

  /// No description provided for @tableCore_materialTypeColumn.
  ///
  /// In en, this message translates to:
  /// **'Material Type'**
  String get tableCore_materialTypeColumn;

  /// No description provided for @tableCore_stationCodeColumn.
  ///
  /// In en, this message translates to:
  /// **'Station Code'**
  String get tableCore_stationCodeColumn;

  /// No description provided for @tableCore_stationNameColumn.
  ///
  /// In en, this message translates to:
  /// **'Station Name'**
  String get tableCore_stationNameColumn;

  /// No description provided for @tableCore_stationDrugWarehouseColumn.
  ///
  /// In en, this message translates to:
  /// **'Drug Warehouse'**
  String get tableCore_stationDrugWarehouseColumn;

  /// No description provided for @tableCore_stationDrugColumn.
  ///
  /// In en, this message translates to:
  /// **'Drug'**
  String get tableCore_stationDrugColumn;

  /// No description provided for @tableCore_stationConsumableWarehouseColumn.
  ///
  /// In en, this message translates to:
  /// **'Medical Consumable Warehouse'**
  String get tableCore_stationConsumableWarehouseColumn;

  /// No description provided for @tableCore_stationConsumableColumn.
  ///
  /// In en, this message translates to:
  /// **'Medical Consumable'**
  String get tableCore_stationConsumableColumn;

  /// No description provided for @tableCore_stationWorkingTypeColumn.
  ///
  /// In en, this message translates to:
  /// **'Working Type'**
  String get tableCore_stationWorkingTypeColumn;

  /// No description provided for @tableCore_hospitalizationProtocolNoColumn.
  ///
  /// In en, this message translates to:
  /// **'Protocol No.'**
  String get tableCore_hospitalizationProtocolNoColumn;

  /// No description provided for @tableCore_hospitalizationNationalIdColumn.
  ///
  /// In en, this message translates to:
  /// **'National ID No.'**
  String get tableCore_hospitalizationNationalIdColumn;

  /// No description provided for @tableCore_hospitalizationPatientColumn.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get tableCore_hospitalizationPatientColumn;

  /// No description provided for @tableCore_patientRowNationalIdColumn.
  ///
  /// In en, this message translates to:
  /// **'Patient National ID'**
  String get tableCore_patientRowNationalIdColumn;

  /// No description provided for @tableCore_patientRowFullNameColumn.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get tableCore_patientRowFullNameColumn;

  /// No description provided for @tableCore_inconsistencyCabinColumn.
  ///
  /// In en, this message translates to:
  /// **'Cabinet'**
  String get tableCore_inconsistencyCabinColumn;

  /// No description provided for @tableCore_inconsistencyRowNoColumn.
  ///
  /// In en, this message translates to:
  /// **'Row No.'**
  String get tableCore_inconsistencyRowNoColumn;

  /// No description provided for @tableCore_inconsistencyCellColumn.
  ///
  /// In en, this message translates to:
  /// **'Cell'**
  String get tableCore_inconsistencyCellColumn;

  /// No description provided for @tableCore_inconsistencyExpectedColumn.
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get tableCore_inconsistencyExpectedColumn;

  /// No description provided for @tableCore_inconsistencyCountedColumn.
  ///
  /// In en, this message translates to:
  /// **'Counted Quantity'**
  String get tableCore_inconsistencyCountedColumn;

  /// No description provided for @tableCore_stockTransactionDateColumn.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get tableCore_stockTransactionDateColumn;

  /// No description provided for @tableCore_stockTransactionBarcodeColumn.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get tableCore_stockTransactionBarcodeColumn;

  /// No description provided for @tableCore_stockTransactionTypeColumn.
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get tableCore_stockTransactionTypeColumn;

  /// No description provided for @tableCore_stockTransactionQuantityColumn.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get tableCore_stockTransactionQuantityColumn;

  /// No description provided for @tableCore_stockTransactionPreviousQuantityColumn.
  ///
  /// In en, this message translates to:
  /// **'Quantity Before Movement'**
  String get tableCore_stockTransactionPreviousQuantityColumn;

  /// No description provided for @tableCore_stockTransactionActorColumn.
  ///
  /// In en, this message translates to:
  /// **'Performed By'**
  String get tableCore_stockTransactionActorColumn;

  /// No description provided for @tableCore_serviceColumn.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get tableCore_serviceColumn;

  /// No description provided for @tableCore_admissionDateColumn.
  ///
  /// In en, this message translates to:
  /// **'Admission Date'**
  String get tableCore_admissionDateColumn;

  /// No description provided for @tableCore_dischargeDateColumn.
  ///
  /// In en, this message translates to:
  /// **'Discharge Date'**
  String get tableCore_dischargeDateColumn;

  /// No description provided for @tableCore_materialColumn.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get tableCore_materialColumn;

  /// No description provided for @tableCore_prescriptionMedicineColumn.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get tableCore_prescriptionMedicineColumn;

  /// No description provided for @tableCore_prescriptionDoseColumn.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get tableCore_prescriptionDoseColumn;

  /// No description provided for @tableCore_prescriptionApplicationUserColumn.
  ///
  /// In en, this message translates to:
  /// **'Applied By'**
  String get tableCore_prescriptionApplicationUserColumn;

  /// No description provided for @tableCore_prescriptionAppliedQuantityColumn.
  ///
  /// In en, this message translates to:
  /// **'Applied Quantity'**
  String get tableCore_prescriptionAppliedQuantityColumn;

  /// No description provided for @tableCore_prescriptionApplicationDateColumn.
  ///
  /// In en, this message translates to:
  /// **'Application Date'**
  String get tableCore_prescriptionApplicationDateColumn;

  /// No description provided for @tableCore_prescriptionReturnUserColumn.
  ///
  /// In en, this message translates to:
  /// **'Returned By'**
  String get tableCore_prescriptionReturnUserColumn;

  /// No description provided for @tableCore_prescriptionReturnQuantityColumn.
  ///
  /// In en, this message translates to:
  /// **'Returned Quantity'**
  String get tableCore_prescriptionReturnQuantityColumn;

  /// No description provided for @tableCore_prescriptionReturnDateColumn.
  ///
  /// In en, this message translates to:
  /// **'Return Date'**
  String get tableCore_prescriptionReturnDateColumn;

  /// No description provided for @tableCore_prescriptionWastageUserColumn.
  ///
  /// In en, this message translates to:
  /// **'Wasted By'**
  String get tableCore_prescriptionWastageUserColumn;

  /// No description provided for @tableCore_prescriptionWastageDateColumn.
  ///
  /// In en, this message translates to:
  /// **'Wastage Date'**
  String get tableCore_prescriptionWastageDateColumn;

  /// No description provided for @tableCore_prescriptionDestructionUserColumn.
  ///
  /// In en, this message translates to:
  /// **'Destroyed By'**
  String get tableCore_prescriptionDestructionUserColumn;

  /// No description provided for @tableCore_prescriptionDestructionDateColumn.
  ///
  /// In en, this message translates to:
  /// **'Destruction Date'**
  String get tableCore_prescriptionDestructionDateColumn;

  /// No description provided for @tableCore_prescriptionStatusColumn.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get tableCore_prescriptionStatusColumn;

  /// No description provided for @enumCore_statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get enumCore_statusActive;

  /// No description provided for @enumCore_statusPassive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get enumCore_statusPassive;

  /// No description provided for @enumCore_warehouseTypeMain.
  ///
  /// In en, this message translates to:
  /// **'Main Warehouse'**
  String get enumCore_warehouseTypeMain;

  /// No description provided for @enumCore_firmTypeSupplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get enumCore_firmTypeSupplier;

  /// No description provided for @enumCore_firmTypeCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get enumCore_firmTypeCustomer;

  /// No description provided for @enumCore_firmTypeManufacturer.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get enumCore_firmTypeManufacturer;

  /// No description provided for @enumCore_warningSubjectUntimelyPurchase.
  ///
  /// In en, this message translates to:
  /// **'Untimely Purchase'**
  String get enumCore_warningSubjectUntimelyPurchase;

  /// No description provided for @enumCore_warningSubjectWaste.
  ///
  /// In en, this message translates to:
  /// **'Waste'**
  String get enumCore_warningSubjectWaste;

  /// No description provided for @enumCore_warningSubjectInconsistencyResolution.
  ///
  /// In en, this message translates to:
  /// **'Inconsistency Resolution'**
  String get enumCore_warningSubjectInconsistencyResolution;

  /// No description provided for @enumCore_warningSubjectDisposal.
  ///
  /// In en, this message translates to:
  /// **'Disposal'**
  String get enumCore_warningSubjectDisposal;

  /// No description provided for @enumCore_stockTxKindRefill.
  ///
  /// In en, this message translates to:
  /// **'Material Refill'**
  String get enumCore_stockTxKindRefill;

  /// No description provided for @enumCore_stockTxKindStockOut.
  ///
  /// In en, this message translates to:
  /// **'Stock Out'**
  String get enumCore_stockTxKindStockOut;

  /// No description provided for @enumCore_stockTxKindConsistent.
  ///
  /// In en, this message translates to:
  /// **'Consistent Count'**
  String get enumCore_stockTxKindConsistent;

  /// No description provided for @enumCore_stockTxKindReturnInward.
  ///
  /// In en, this message translates to:
  /// **'Return Intake'**
  String get enumCore_stockTxKindReturnInward;

  /// No description provided for @enumCore_stockTxKindWastage.
  ///
  /// In en, this message translates to:
  /// **'Wastage'**
  String get enumCore_stockTxKindWastage;

  /// No description provided for @enumCore_stockTxTypeIn.
  ///
  /// In en, this message translates to:
  /// **'Stock In'**
  String get enumCore_stockTxTypeIn;

  /// No description provided for @enumCore_stockTxTypeOut.
  ///
  /// In en, this message translates to:
  /// **'Stock Out'**
  String get enumCore_stockTxTypeOut;

  /// No description provided for @enumCore_stockTxKindReturn.
  ///
  /// In en, this message translates to:
  /// **'Material Return'**
  String get enumCore_stockTxKindReturn;

  /// No description provided for @enumCore_stockTxKindExcess.
  ///
  /// In en, this message translates to:
  /// **'Count Excess'**
  String get enumCore_stockTxKindExcess;

  /// No description provided for @enumCore_stockTxKindShortage.
  ///
  /// In en, this message translates to:
  /// **'Count Shortage'**
  String get enumCore_stockTxKindShortage;

  /// No description provided for @enumCore_stockTxKindPurchase.
  ///
  /// In en, this message translates to:
  /// **'Material Intake'**
  String get enumCore_stockTxKindPurchase;

  /// No description provided for @enumCore_stockTxKindUnload.
  ///
  /// In en, this message translates to:
  /// **'Material Unload'**
  String get enumCore_stockTxKindUnload;

  /// No description provided for @enumCore_countTypeNone.
  ///
  /// In en, this message translates to:
  /// **'No Census'**
  String get enumCore_countTypeNone;

  /// No description provided for @enumCore_countTypeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal Census'**
  String get enumCore_countTypeNormal;

  /// No description provided for @enumCore_countTypeBlind.
  ///
  /// In en, this message translates to:
  /// **'Blind Census'**
  String get enumCore_countTypeBlind;

  /// No description provided for @enumCore_returnTypeToOrigin.
  ///
  /// In en, this message translates to:
  /// **'Return to Origin'**
  String get enumCore_returnTypeToOrigin;

  /// No description provided for @enumCore_returnTypeToDrawer.
  ///
  /// In en, this message translates to:
  /// **'Return to Drawer'**
  String get enumCore_returnTypeToDrawer;

  /// No description provided for @enumCore_returnTypeToReturnBox.
  ///
  /// In en, this message translates to:
  /// **'Return to Return Box'**
  String get enumCore_returnTypeToReturnBox;

  /// No description provided for @enumCore_returnTypeToPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Return to Pharmacy'**
  String get enumCore_returnTypeToPharmacy;

  /// No description provided for @enumCore_requestTypeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal Request'**
  String get enumCore_requestTypeNormal;

  /// No description provided for @enumCore_requestTypeUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent Request'**
  String get enumCore_requestTypeUrgent;

  /// No description provided for @enumCore_purchaseTypeBoth.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get enumCore_purchaseTypeBoth;

  /// No description provided for @enumCore_prescriptionTypeWhite.
  ///
  /// In en, this message translates to:
  /// **'White Prescription'**
  String get enumCore_prescriptionTypeWhite;

  /// No description provided for @enumCore_prescriptionTypeSerumWhite.
  ///
  /// In en, this message translates to:
  /// **'Serum (White Prescription)'**
  String get enumCore_prescriptionTypeSerumWhite;

  /// No description provided for @enumCore_prescriptionTypeRed.
  ///
  /// In en, this message translates to:
  /// **'Red Prescription'**
  String get enumCore_prescriptionTypeRed;

  /// No description provided for @enumCore_prescriptionTypeGreen.
  ///
  /// In en, this message translates to:
  /// **'Green Prescription'**
  String get enumCore_prescriptionTypeGreen;

  /// No description provided for @enumCore_prescriptionTypeOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange Prescription'**
  String get enumCore_prescriptionTypeOrange;

  /// No description provided for @enumCore_prescriptionTypePurple.
  ///
  /// In en, this message translates to:
  /// **'Purple Prescription'**
  String get enumCore_prescriptionTypePurple;

  /// No description provided for @enumCore_refillListStatusToCollect.
  ///
  /// In en, this message translates to:
  /// **'To Collect'**
  String get enumCore_refillListStatusToCollect;

  /// No description provided for @enumCore_refillListStatusCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get enumCore_refillListStatusCollected;

  /// No description provided for @enumCore_refillListStatusSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get enumCore_refillListStatusSent;

  /// No description provided for @enumCore_fillingTypeMinimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get enumCore_fillingTypeMinimum;

  /// No description provided for @enumCore_fillingTypeCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get enumCore_fillingTypeCritical;

  /// No description provided for @enumCore_fillingTypeMaximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get enumCore_fillingTypeMaximum;

  /// No description provided for @enumCore_patientFilterOrderTimeReached.
  ///
  /// In en, this message translates to:
  /// **'Order Time Reached'**
  String get enumCore_patientFilterOrderTimeReached;

  /// No description provided for @enumCore_patientFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All Patients'**
  String get enumCore_patientFilterAll;

  /// No description provided for @enumCore_patientFilterTimeNotReached.
  ///
  /// In en, this message translates to:
  /// **'Time Not Reached Yet'**
  String get enumCore_patientFilterTimeNotReached;

  /// No description provided for @enumCore_patientFilterTimePassed.
  ///
  /// In en, this message translates to:
  /// **'Time Passed'**
  String get enumCore_patientFilterTimePassed;

  /// No description provided for @enumCore_patientFilterReturnable.
  ///
  /// In en, this message translates to:
  /// **'Return Available'**
  String get enumCore_patientFilterReturnable;

  /// No description provided for @enumCore_patientFilterWasteDisposable.
  ///
  /// In en, this message translates to:
  /// **'Waste/Disposal Available'**
  String get enumCore_patientFilterWasteDisposable;

  /// No description provided for @enumCore_cabinTypeStandard.
  ///
  /// In en, this message translates to:
  /// **'Master Cabinet'**
  String get enumCore_cabinTypeStandard;

  /// No description provided for @enumCore_cabinTypeCloset.
  ///
  /// In en, this message translates to:
  /// **'Closet'**
  String get enumCore_cabinTypeCloset;

  /// No description provided for @enumCore_cabinTypeFridge.
  ///
  /// In en, this message translates to:
  /// **'Refrigerator'**
  String get enumCore_cabinTypeFridge;

  /// No description provided for @enumCore_cabinTypeOpenCloset.
  ///
  /// In en, this message translates to:
  /// **'Open Closet'**
  String get enumCore_cabinTypeOpenCloset;

  /// No description provided for @enumCore_cabinTypeMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile Cabinet'**
  String get enumCore_cabinTypeMobile;

  /// No description provided for @enumCore_cabinTypeExternalReturn.
  ///
  /// In en, this message translates to:
  /// **'External Return Cabinet'**
  String get enumCore_cabinTypeExternalReturn;

  /// No description provided for @enumCore_cabinTypeOpen.
  ///
  /// In en, this message translates to:
  /// **'Open Cabinet'**
  String get enumCore_cabinTypeOpen;

  /// No description provided for @enumCore_cabinTypeSerum.
  ///
  /// In en, this message translates to:
  /// **'Serum Cabinet'**
  String get enumCore_cabinTypeSerum;

  /// No description provided for @enumCore_cabinOpModeAssignDrug.
  ///
  /// In en, this message translates to:
  /// **'Drug Assignment'**
  String get enumCore_cabinOpModeAssignDrug;

  /// No description provided for @enumCore_cabinOpModeRefill.
  ///
  /// In en, this message translates to:
  /// **'Drug Refill'**
  String get enumCore_cabinOpModeRefill;

  /// No description provided for @enumCore_cabinOpModeCensus.
  ///
  /// In en, this message translates to:
  /// **'Drug Census'**
  String get enumCore_cabinOpModeCensus;

  /// No description provided for @enumCore_cabinOpModeIntake.
  ///
  /// In en, this message translates to:
  /// **'Drug Intake'**
  String get enumCore_cabinOpModeIntake;

  /// No description provided for @enumCore_cabinOpModeFault.
  ///
  /// In en, this message translates to:
  /// **'Drawer Fault'**
  String get enumCore_cabinOpModeFault;

  /// No description provided for @enumCore_cabinOpModeUnload.
  ///
  /// In en, this message translates to:
  /// **'Drug Unload'**
  String get enumCore_cabinOpModeUnload;

  /// No description provided for @enumCore_cabinInventoryTypeRefillOperationLabel.
  ///
  /// In en, this message translates to:
  /// **'Refill'**
  String get enumCore_cabinInventoryTypeRefillOperationLabel;

  /// No description provided for @enumCore_cabinInventoryTypeIntakeOperationLabel.
  ///
  /// In en, this message translates to:
  /// **'Intake'**
  String get enumCore_cabinInventoryTypeIntakeOperationLabel;

  /// No description provided for @enumCore_cabinInventoryTypeUnloadOperationLabel.
  ///
  /// In en, this message translates to:
  /// **'Unload'**
  String get enumCore_cabinInventoryTypeUnloadOperationLabel;

  /// No description provided for @enumCore_cabinInventoryTypeCensusOperationLabel.
  ///
  /// In en, this message translates to:
  /// **'Census'**
  String get enumCore_cabinInventoryTypeCensusOperationLabel;

  /// No description provided for @enumCore_cabinInventoryTypeDisposalOperationLabel.
  ///
  /// In en, this message translates to:
  /// **'Disposal'**
  String get enumCore_cabinInventoryTypeDisposalOperationLabel;

  /// No description provided for @enumCore_cabinInventoryTypeRefillListOperationLabel.
  ///
  /// In en, this message translates to:
  /// **'Refill'**
  String get enumCore_cabinInventoryTypeRefillListOperationLabel;

  /// No description provided for @enumCore_cabinInventoryTypeRefillTitle.
  ///
  /// In en, this message translates to:
  /// **'Drug Refill'**
  String get enumCore_cabinInventoryTypeRefillTitle;

  /// No description provided for @enumCore_cabinInventoryTypeRefillListTitle.
  ///
  /// In en, this message translates to:
  /// **'Drug Refill List'**
  String get enumCore_cabinInventoryTypeRefillListTitle;

  /// No description provided for @enumCore_cabinInventoryTypeCensusTitle.
  ///
  /// In en, this message translates to:
  /// **'Drug Census'**
  String get enumCore_cabinInventoryTypeCensusTitle;

  /// No description provided for @enumCore_cabinInventoryTypeDisposalTitle.
  ///
  /// In en, this message translates to:
  /// **'Drug Disposal'**
  String get enumCore_cabinInventoryTypeDisposalTitle;

  /// No description provided for @enumCore_cabinInventoryTypeUnloadTitle.
  ///
  /// In en, this message translates to:
  /// **'Drug Unload'**
  String get enumCore_cabinInventoryTypeUnloadTitle;

  /// No description provided for @enumCore_cabinInventoryTypeIntakeTitle.
  ///
  /// In en, this message translates to:
  /// **'Drug Intake'**
  String get enumCore_cabinInventoryTypeIntakeTitle;

  /// No description provided for @enumCore_cabinInventoryTypeRefillButtonText.
  ///
  /// In en, this message translates to:
  /// **'Refill'**
  String get enumCore_cabinInventoryTypeRefillButtonText;

  /// No description provided for @enumCore_cabinInventoryTypeRefillListButtonText.
  ///
  /// In en, this message translates to:
  /// **'Refill'**
  String get enumCore_cabinInventoryTypeRefillListButtonText;

  /// No description provided for @enumCore_cabinInventoryTypeCensusButtonText.
  ///
  /// In en, this message translates to:
  /// **'Take Census'**
  String get enumCore_cabinInventoryTypeCensusButtonText;

  /// No description provided for @enumCore_cabinInventoryTypeDisposalButtonText.
  ///
  /// In en, this message translates to:
  /// **'Dispose'**
  String get enumCore_cabinInventoryTypeDisposalButtonText;

  /// No description provided for @enumCore_cabinInventoryTypeUnloadButtonText.
  ///
  /// In en, this message translates to:
  /// **'Unload Drug'**
  String get enumCore_cabinInventoryTypeUnloadButtonText;

  /// No description provided for @enumCore_cabinInventoryTypeIntakeButtonText.
  ///
  /// In en, this message translates to:
  /// **'Take Drug'**
  String get enumCore_cabinInventoryTypeIntakeButtonText;

  /// No description provided for @enumCore_cabinInventoryTypeRefillFieldText.
  ///
  /// In en, this message translates to:
  /// **'Refill Quantity'**
  String get enumCore_cabinInventoryTypeRefillFieldText;

  /// No description provided for @enumCore_cabinInventoryTypeRefillListFieldText.
  ///
  /// In en, this message translates to:
  /// **'Refill Quantity'**
  String get enumCore_cabinInventoryTypeRefillListFieldText;

  /// No description provided for @enumCore_cabinInventoryTypeCensusFieldText.
  ///
  /// In en, this message translates to:
  /// **'Census Quantity'**
  String get enumCore_cabinInventoryTypeCensusFieldText;

  /// No description provided for @enumCore_cabinInventoryTypeDisposalFieldText.
  ///
  /// In en, this message translates to:
  /// **'Disposal Quantity'**
  String get enumCore_cabinInventoryTypeDisposalFieldText;

  /// No description provided for @enumCore_cabinInventoryTypeUnloadFieldText.
  ///
  /// In en, this message translates to:
  /// **'Unload Quantity'**
  String get enumCore_cabinInventoryTypeUnloadFieldText;

  /// No description provided for @enumCore_cabinInventoryTypeIntakeFieldText.
  ///
  /// In en, this message translates to:
  /// **'Intake Quantity'**
  String get enumCore_cabinInventoryTypeIntakeFieldText;

  /// No description provided for @enumCore_cabinInventoryTypeRefillSequentialText.
  ///
  /// In en, this message translates to:
  /// **'Start Automatic Refill'**
  String get enumCore_cabinInventoryTypeRefillSequentialText;

  /// No description provided for @enumCore_cabinInventoryTypeRefillListSequentialText.
  ///
  /// In en, this message translates to:
  /// **'Start Automatic Refill'**
  String get enumCore_cabinInventoryTypeRefillListSequentialText;

  /// No description provided for @enumCore_cabinInventoryTypeCensusSequentialText.
  ///
  /// In en, this message translates to:
  /// **'Start Automatic Census'**
  String get enumCore_cabinInventoryTypeCensusSequentialText;

  /// No description provided for @enumCore_cabinInventoryTypeDisposalSequentialText.
  ///
  /// In en, this message translates to:
  /// **'Start Automatic Disposal'**
  String get enumCore_cabinInventoryTypeDisposalSequentialText;

  /// No description provided for @enumCore_cabinInventoryTypeUnloadSequentialText.
  ///
  /// In en, this message translates to:
  /// **'Start Automatic Unload'**
  String get enumCore_cabinInventoryTypeUnloadSequentialText;

  /// No description provided for @enumCore_cabinInventoryTypeIntakeSequentialText.
  ///
  /// In en, this message translates to:
  /// **'Start Automatic Intake'**
  String get enumCore_cabinInventoryTypeIntakeSequentialText;

  /// No description provided for @enumCore_permissionCan.
  ///
  /// In en, this message translates to:
  /// **'Can'**
  String get enumCore_permissionCan;

  /// No description provided for @enumCore_permissionCannot.
  ///
  /// In en, this message translates to:
  /// **'Cannot'**
  String get enumCore_permissionCannot;

  /// No description provided for @enumCore_genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get enumCore_genderFemale;

  /// No description provided for @enumCore_genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get enumCore_genderMale;

  /// No description provided for @enumCore_genderUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get enumCore_genderUnknown;

  /// No description provided for @enumCore_userTypeUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get enumCore_userTypeUnlimited;

  /// No description provided for @enumCore_appModeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get enumCore_appModeAdmin;

  /// No description provided for @enumCore_appModeManager.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get enumCore_appModeManager;

  /// No description provided for @enumCore_appModeStation.
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get enumCore_appModeStation;

  /// No description provided for @enumCore_userRoleManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get enumCore_userRoleManager;

  /// No description provided for @enumCore_userRoleStationOperator.
  ///
  /// In en, this message translates to:
  /// **'Station Operator'**
  String get enumCore_userRoleStationOperator;

  /// No description provided for @enumCore_parityBitNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get enumCore_parityBitNone;

  /// No description provided for @enumCore_parityBitEven.
  ///
  /// In en, this message translates to:
  /// **'Even'**
  String get enumCore_parityBitEven;

  /// No description provided for @enumCore_parityBitOdd.
  ///
  /// In en, this message translates to:
  /// **'Odd'**
  String get enumCore_parityBitOdd;

  /// No description provided for @enumCore_cabinColorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get enumCore_cabinColorBlue;

  /// No description provided for @enumCore_cabinColorTurquoise.
  ///
  /// In en, this message translates to:
  /// **'Turquoise'**
  String get enumCore_cabinColorTurquoise;

  /// No description provided for @enumCore_cabinColorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get enumCore_cabinColorGreen;

  /// No description provided for @enumCore_cabinColorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get enumCore_cabinColorRed;

  /// No description provided for @enumCore_cabinColorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get enumCore_cabinColorOrange;

  /// No description provided for @enumCore_cabinColorPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get enumCore_cabinColorPurple;

  /// No description provided for @enumCore_cabinColorGray.
  ///
  /// In en, this message translates to:
  /// **'Gray'**
  String get enumCore_cabinColorGray;

  /// No description provided for @enumCore_cabinColorBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get enumCore_cabinColorBlack;

  /// No description provided for @enumCore_cabinColorWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get enumCore_cabinColorWhite;

  /// No description provided for @common_confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_confirmButton;

  /// No description provided for @common_viewInPreparationMessage.
  ///
  /// In en, this message translates to:
  /// **'This view is being prepared...'**
  String get common_viewInPreparationMessage;

  /// No description provided for @common_warningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning!'**
  String get common_warningTitle;

  /// No description provided for @dialog_deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dialog_deleteTitle;

  /// No description provided for @dialog_deleteDefaultMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get dialog_deleteDefaultMessage;

  /// No description provided for @dialog_deleteItemMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{itemName}\"?\nThis action cannot be undone.'**
  String dialog_deleteItemMessage(String itemName);

  /// No description provided for @dialog_exitConfirmButtonText.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get dialog_exitConfirmButtonText;

  /// No description provided for @dialog_exitConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. If you exit, these changes will be lost.'**
  String get dialog_exitConfirmMessage;

  /// No description provided for @dialog_exitConfirmMessageNoChanges.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave this page?'**
  String get dialog_exitConfirmMessageNoChanges;

  /// No description provided for @dialog_confirmDiscardButton.
  ///
  /// In en, this message translates to:
  /// **'Yes, Discard'**
  String get dialog_confirmDiscardButton;

  /// No description provided for @dialog_logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get dialog_logoutTitle;

  /// No description provided for @dialog_logoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account?'**
  String get dialog_logoutMessage;

  /// No description provided for @dialog_exitTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get dialog_exitTitle;

  /// No description provided for @dialog_exitMessage.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes may be lost.'**
  String get dialog_exitMessage;

  /// No description provided for @dialog_saveTitle.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get dialog_saveTitle;

  /// No description provided for @dialog_saveMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save the changes?'**
  String get dialog_saveMessage;

  /// No description provided for @dialog_discardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get dialog_discardTitle;

  /// No description provided for @dialog_discardMessage.
  ///
  /// In en, this message translates to:
  /// **'The changes you made will be reverted.'**
  String get dialog_discardMessage;

  /// No description provided for @dialog_customConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get dialog_customConfirmTitle;

  /// No description provided for @dialog_customConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you confirm this action?'**
  String get dialog_customConfirmMessage;

  /// No description provided for @table_noDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get table_noDataTitle;

  /// No description provided for @table_defaultPdfReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Table Report'**
  String get table_defaultPdfReportTitle;

  /// No description provided for @table_actionsColumnHeader.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get table_actionsColumnHeader;

  /// No description provided for @table_activeFiltersLabel.
  ///
  /// In en, this message translates to:
  /// **'Filters:'**
  String get table_activeFiltersLabel;

  /// No description provided for @common_clearButton.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get common_clearButton;

  /// No description provided for @table_selectedCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String table_selectedCountLabel(int count);

  /// No description provided for @table_columnSelectedCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{column}: {count} selected'**
  String table_columnSelectedCountLabel(String column, int count);

  /// No description provided for @table_columnFallbackLabel.
  ///
  /// In en, this message translates to:
  /// **'Column'**
  String get table_columnFallbackLabel;

  /// No description provided for @table_selectAllCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Select All ({count})'**
  String table_selectAllCountLabel(int count);

  /// No description provided for @table_noResultsShort.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get table_noResultsShort;

  /// No description provided for @table_applyCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Apply ({count})'**
  String table_applyCountLabel(int count);

  /// No description provided for @table_applyButton.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get table_applyButton;

  /// No description provided for @table_recordCountFiltered.
  ///
  /// In en, this message translates to:
  /// **'{filtered} / {total} records'**
  String table_recordCountFiltered(int filtered, int total);

  /// No description provided for @table_recordCount.
  ///
  /// In en, this message translates to:
  /// **'{total} records'**
  String table_recordCount(int total);

  /// No description provided for @table_totalRecordCount.
  ///
  /// In en, this message translates to:
  /// **'Total {total} records'**
  String table_totalRecordCount(int total);

  /// No description provided for @table_prevPageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get table_prevPageTooltip;

  /// No description provided for @table_nextPageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get table_nextPageTooltip;

  /// No description provided for @table_exportSelectedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export Selected'**
  String get table_exportSelectedTooltip;

  /// No description provided for @table_categoriesDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get table_categoriesDefaultTitle;

  /// No description provided for @table_columnFallback.
  ///
  /// In en, this message translates to:
  /// **'Column {index}'**
  String table_columnFallback(int index);

  /// No description provided for @dateFilter_yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateFilter_yesterday;

  /// No description provided for @dateFilter_lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get dateFilter_lastWeek;

  /// No description provided for @dateFilter_thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get dateFilter_thisMonth;

  /// No description provided for @dateFilter_last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get dateFilter_last30Days;

  /// No description provided for @dateFilter_customRange.
  ///
  /// In en, this message translates to:
  /// **'Set Custom Range...'**
  String get dateFilter_customRange;

  /// No description provided for @dateFilter_clearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear Filter'**
  String get dateFilter_clearFilter;

  /// No description provided for @dateFilter_noFilter.
  ///
  /// In en, this message translates to:
  /// **'No Filter'**
  String get dateFilter_noFilter;

  /// No description provided for @dateFilter_selectedRange.
  ///
  /// In en, this message translates to:
  /// **'Selected Range'**
  String get dateFilter_selectedRange;

  /// No description provided for @dateFilter_selectRangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get dateFilter_selectRangeTitle;

  /// No description provided for @dateFilter_startDate.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get dateFilter_startDate;

  /// No description provided for @dateFilter_endDate.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get dateFilter_endDate;

  /// No description provided for @common_selectPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Please select'**
  String get common_selectPlaceholder;

  /// No description provided for @selectionDialog_selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items selected'**
  String selectionDialog_selectedCount(int count);

  /// No description provided for @selectionDialog_noSelection.
  ///
  /// In en, this message translates to:
  /// **'No selection made'**
  String get selectionDialog_noSelection;

  /// No description provided for @selectionDialog_confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectionDialog_confirmButton;

  /// No description provided for @dateField_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get dateField_placeholder;

  /// No description provided for @timeField_helpTextWithDay.
  ///
  /// In en, this message translates to:
  /// **'Select a time for {day}'**
  String timeField_helpTextWithDay(String day);

  /// No description provided for @timeField_helpText.
  ///
  /// In en, this message translates to:
  /// **'Select a time'**
  String get timeField_helpText;

  /// No description provided for @timeField_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get timeField_placeholder;

  /// No description provided for @doseStepper_manualEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter {unit} Amount'**
  String doseStepper_manualEntryTitle(String unit);

  /// No description provided for @numpad_defaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get numpad_defaultTitle;

  /// No description provided for @keyboard_closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get keyboard_closeButton;

  /// No description provided for @keyboard_enterLabel.
  ///
  /// In en, this message translates to:
  /// **'↵ OK'**
  String get keyboard_enterLabel;

  /// No description provided for @keyboard_dashKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'— Dash'**
  String get keyboard_dashKeyLabel;

  /// No description provided for @keyboard_periodKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'. Period'**
  String get keyboard_periodKeyLabel;

  /// No description provided for @keyboard_shiftLabel.
  ///
  /// In en, this message translates to:
  /// **'⇧ Shift'**
  String get keyboard_shiftLabel;

  /// No description provided for @keyboard_spaceLabel.
  ///
  /// In en, this message translates to:
  /// **'SPACE'**
  String get keyboard_spaceLabel;

  /// No description provided for @staleBanner_justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get staleBanner_justNow;

  /// No description provided for @staleBanner_minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String staleBanner_minutesAgo(int minutes);

  /// No description provided for @staleBanner_hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr ago'**
  String staleBanner_hoursAgo(int hours);

  /// No description provided for @staleBanner_dataStaleMessage.
  ///
  /// In en, this message translates to:
  /// **'Data is not up to date. '**
  String get staleBanner_dataStaleMessage;

  /// No description provided for @staleBanner_dataUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Up-to-date data is unavailable. The operation cannot proceed. '**
  String get staleBanner_dataUnavailableMessage;

  /// No description provided for @staleBanner_lastUpdatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {time}'**
  String staleBanner_lastUpdatedLabel(String time);

  /// No description provided for @staleBanner_blockedBadge.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get staleBanner_blockedBadge;

  /// No description provided for @timeChip_today.
  ///
  /// In en, this message translates to:
  /// **'Today {time}'**
  String timeChip_today(String time);

  /// No description provided for @timeChip_tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow {time}'**
  String timeChip_tomorrow(String time);

  /// No description provided for @cabin_lockButton.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get cabin_lockButton;

  /// No description provided for @cabin_criticalStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Critical Stock'**
  String get cabin_criticalStockLabel;

  /// No description provided for @cabin_criticalStockSubLabel.
  ///
  /// In en, this message translates to:
  /// **'refill needed'**
  String get cabin_criticalStockSubLabel;

  /// No description provided for @cabin_legendFillNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal stock'**
  String get cabin_legendFillNormal;

  /// No description provided for @cabin_legendFillNeeded.
  ///
  /// In en, this message translates to:
  /// **'Refill needed'**
  String get cabin_legendFillNeeded;

  /// No description provided for @cabin_legendFillUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent refill'**
  String get cabin_legendFillUrgent;

  /// No description provided for @cabin_serumTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Serum'**
  String get cabin_serumTypeLabel;

  /// No description provided for @cabin_unitDoseTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit Dose'**
  String get cabin_unitDoseTypeLabel;

  /// No description provided for @refund_showCompletedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show Completed'**
  String get refund_showCompletedTooltip;

  /// No description provided for @refund_showIncompleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show Incomplete'**
  String get refund_showIncompleteTooltip;

  /// No description provided for @refund_takeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Take Refund'**
  String get refund_takeTooltip;

  /// No description provided for @refund_deleteDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get refund_deleteDialog_title;

  /// No description provided for @refund_deleteDialog_saveButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get refund_deleteDialog_saveButton;

  /// No description provided for @refund_deleteDialog_reasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Please explain your reason for deletion'**
  String get refund_deleteDialog_reasonLabel;

  /// No description provided for @refund_pdf_title.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy Refund Report'**
  String get refund_pdf_title;

  /// No description provided for @refund_pdf_station.
  ///
  /// In en, this message translates to:
  /// **'Station: {station}'**
  String refund_pdf_station(String station);

  /// No description provided for @refund_pdf_dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date: {startDate} - {endDate}'**
  String refund_pdf_dateRange(String startDate, String endDate);

  /// No description provided for @dashboard_sensor_title.
  ///
  /// In en, this message translates to:
  /// **'Sensors'**
  String get dashboard_sensor_title;

  /// No description provided for @dashboard_sensor_temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get dashboard_sensor_temperature;

  /// No description provided for @dashboard_sensor_humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get dashboard_sensor_humidity;

  /// No description provided for @dashboard_sensor_battery.
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

  /// No description provided for @dashboard_sensor_paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get dashboard_sensor_paused;

  /// No description provided for @dashboard_upcomingTreatmentsPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Treatments'**
  String get dashboard_upcomingTreatmentsPanelTitle;

  /// No description provided for @dashboard_upcomingTreatmentsCountBadge.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} scheduled} other{{count} scheduled}}'**
  String dashboard_upcomingTreatmentsCountBadge(int count);

  /// No description provided for @dashboard_upcomingTreatmentsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No scheduled treatments'**
  String get dashboard_upcomingTreatmentsEmptyTitle;

  /// No description provided for @dashboard_upcomingTreatmentsOverdueStatus.
  ///
  /// In en, this message translates to:
  /// **'overdue'**
  String get dashboard_upcomingTreatmentsOverdueStatus;

  /// No description provided for @dashboard_drugActivityPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Drug Activity'**
  String get dashboard_drugActivityPanelTitle;

  /// No description provided for @dashboard_drugActivityEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get dashboard_drugActivityEmptyTitle;

  /// No description provided for @dashboard_activitiesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Drug activity could not be loaded'**
  String get dashboard_activitiesLoadError;

  /// No description provided for @dashboard_telemetryPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cabin Climate'**
  String get dashboard_telemetryPanelTitle;

  /// No description provided for @dashboard_telemetryPausedStatus.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get dashboard_telemetryPausedStatus;

  /// No description provided for @dashboard_kpiActivePatientsLabel.
  ///
  /// In en, this message translates to:
  /// **'Active Patients'**
  String get dashboard_kpiActivePatientsLabel;

  /// No description provided for @dashboard_kpiCompletedOperationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed Operations'**
  String get dashboard_kpiCompletedOperationsLabel;

  /// No description provided for @dashboard_kpiPendingPrescriptionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending Prescriptions'**
  String get dashboard_kpiPendingPrescriptionsLabel;

  /// No description provided for @dashboard_kpiCriticalAlertsLabel.
  ///
  /// In en, this message translates to:
  /// **'Critical Alerts'**
  String get dashboard_kpiCriticalAlertsLabel;

  /// No description provided for @common_seeAllButton.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get common_seeAllButton;

  /// No description provided for @common_unknownFallback.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get common_unknownFallback;

  /// No description provided for @common_justNowStatus.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get common_justNowStatus;

  /// No description provided for @common_minutesAgoStatus.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String common_minutesAgoStatus(int count);

  /// No description provided for @common_hoursAgoStatus.
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String common_hoursAgoStatus(int count);

  /// No description provided for @common_daysAgoStatus.
  ///
  /// In en, this message translates to:
  /// **'{count} d ago'**
  String common_daysAgoStatus(int count);

  /// No description provided for @common_minutesRemainingStatus.
  ///
  /// In en, this message translates to:
  /// **'in {count} min'**
  String common_minutesRemainingStatus(int count);

  /// No description provided for @common_hoursRemainingStatus.
  ///
  /// In en, this message translates to:
  /// **'in {count} h'**
  String common_hoursRemainingStatus(int count);

  /// No description provided for @common_daysRemainingStatus.
  ///
  /// In en, this message translates to:
  /// **'in {count} d'**
  String common_daysRemainingStatus(int count);

  /// No description provided for @refill_hint_selectSlots.
  ///
  /// In en, this message translates to:
  /// **'Select the cells to fill. Low-stock cells are marked.'**
  String get refill_hint_selectSlots;

  /// No description provided for @refill_title_fillCells.
  ///
  /// In en, this message translates to:
  /// **'Fill Cells'**
  String get refill_title_fillCells;

  /// No description provided for @refill_hint_miadRequired.
  ///
  /// In en, this message translates to:
  /// **'Expiry date required'**
  String get refill_hint_miadRequired;

  /// No description provided for @refill_status_openingTitle.
  ///
  /// In en, this message translates to:
  /// **'Opening drawer…'**
  String get refill_status_openingTitle;

  /// No description provided for @refill_status_openingBody.
  ///
  /// In en, this message translates to:
  /// **'Please wait, the physical drawer is opening.'**
  String get refill_status_openingBody;

  /// No description provided for @refill_status_waitingPullTitle.
  ///
  /// In en, this message translates to:
  /// **'Pull the drawer'**
  String get refill_status_waitingPullTitle;

  /// No description provided for @refill_status_waitingPullBody.
  ///
  /// In en, this message translates to:
  /// **'The lock is released. Pull the drawer to continue.'**
  String get refill_status_waitingPullBody;

  /// No description provided for @refill_status_openingLidTitle.
  ///
  /// In en, this message translates to:
  /// **'Opening cell…'**
  String get refill_status_openingLidTitle;

  /// No description provided for @refill_status_openingLidBody.
  ///
  /// In en, this message translates to:
  /// **'Please wait, the cell lid is opening.'**
  String get refill_status_openingLidBody;

  /// No description provided for @refill_status_stockOk.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get refill_status_stockOk;

  /// No description provided for @refill_status_stockLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get refill_status_stockLow;

  /// No description provided for @refill_status_stockCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get refill_status_stockCritical;

  /// No description provided for @refill_stop_confirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop the refill?'**
  String get refill_stop_confirmTitle;

  /// No description provided for @refill_stop_confirmMessage.
  ///
  /// In en, this message translates to:
  /// **'If you stop, the open drawer will be locked and this refill will be marked as partially completed. Entered counts and fill amounts are kept, but you cannot resume — you must start a new refill.'**
  String get refill_stop_confirmMessage;

  /// No description provided for @refill_stop_confirmYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, Stop'**
  String get refill_stop_confirmYes;

  /// No description provided for @enumCore_prescriptionMovementPendingApprovalLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending Approval'**
  String get enumCore_prescriptionMovementPendingApprovalLabel;

  /// No description provided for @enumCore_prescriptionMovementPurchasePendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Purchase Pending'**
  String get enumCore_prescriptionMovementPurchasePendingLabel;

  /// No description provided for @enumCore_prescriptionMovementAppliedLabel.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get enumCore_prescriptionMovementAppliedLabel;

  /// No description provided for @enumCore_prescriptionMovementReturnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get enumCore_prescriptionMovementReturnedLabel;

  /// No description provided for @enumCore_prescriptionMovementWastagedLabel.
  ///
  /// In en, this message translates to:
  /// **'Wasted'**
  String get enumCore_prescriptionMovementWastagedLabel;

  /// No description provided for @enumCore_prescriptionMovementDestructedLabel.
  ///
  /// In en, this message translates to:
  /// **'Destructed'**
  String get enumCore_prescriptionMovementDestructedLabel;

  /// No description provided for @enumCore_prescriptionMovementCancelledLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get enumCore_prescriptionMovementCancelledLabel;

  /// No description provided for @enumCore_prescriptionMovementRejectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get enumCore_prescriptionMovementRejectedLabel;

  /// No description provided for @enumCore_prescriptionMovementFilledWaitingLabel.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Fill'**
  String get enumCore_prescriptionMovementFilledWaitingLabel;

  /// No description provided for @enumCore_prescriptionMovementReturnPendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Return Pending'**
  String get enumCore_prescriptionMovementReturnPendingLabel;

  /// No description provided for @enumCore_prescriptionMovementUnloadedLabel.
  ///
  /// In en, this message translates to:
  /// **'Unloaded'**
  String get enumCore_prescriptionMovementUnloadedLabel;

  /// No description provided for @enumCore_prescriptionMovementShortageReportedLabel.
  ///
  /// In en, this message translates to:
  /// **'Shortage Reported'**
  String get enumCore_prescriptionMovementShortageReportedLabel;

  /// No description provided for @enumCore_prescriptionMovementReplenishmentPendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Replenishment Pending'**
  String get enumCore_prescriptionMovementReplenishmentPendingLabel;

  /// No description provided for @enumCore_prescriptionMovementPendingApprovalActorLabel.
  ///
  /// In en, this message translates to:
  /// **'Created By'**
  String get enumCore_prescriptionMovementPendingApprovalActorLabel;

  /// No description provided for @enumCore_prescriptionMovementPurchasePendingActorLabel.
  ///
  /// In en, this message translates to:
  /// **'Filled By'**
  String get enumCore_prescriptionMovementPurchasePendingActorLabel;

  /// No description provided for @enumCore_prescriptionMovementAppliedActorLabel.
  ///
  /// In en, this message translates to:
  /// **'Applied By'**
  String get enumCore_prescriptionMovementAppliedActorLabel;

  /// No description provided for @enumCore_prescriptionMovementReturnedActorLabel.
  ///
  /// In en, this message translates to:
  /// **'Returned By'**
  String get enumCore_prescriptionMovementReturnedActorLabel;

  /// No description provided for @enumCore_prescriptionMovementWastagedActorLabel.
  ///
  /// In en, this message translates to:
  /// **'Wasted By'**
  String get enumCore_prescriptionMovementWastagedActorLabel;

  /// No description provided for @enumCore_prescriptionMovementDestructedActorLabel.
  ///
  /// In en, this message translates to:
  /// **'Destructed By'**
  String get enumCore_prescriptionMovementDestructedActorLabel;

  /// No description provided for @enumCore_prescriptionMovementCancelledActorLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancelled By'**
  String get enumCore_prescriptionMovementCancelledActorLabel;

  /// No description provided for @enumCore_prescriptionMovementRejectedActorLabel.
  ///
  /// In en, this message translates to:
  /// **'Rejected By'**
  String get enumCore_prescriptionMovementRejectedActorLabel;

  /// No description provided for @enumCore_prescriptionMovementFilledWaitingActorLabel.
  ///
  /// In en, this message translates to:
  /// **'Approved By'**
  String get enumCore_prescriptionMovementFilledWaitingActorLabel;

  /// No description provided for @enumCore_prescriptionMovementReturnPendingActorLabel.
  ///
  /// In en, this message translates to:
  /// **'Return Requested By'**
  String get enumCore_prescriptionMovementReturnPendingActorLabel;

  /// No description provided for @enumCore_prescriptionMovementUnloadedActorLabel.
  ///
  /// In en, this message translates to:
  /// **'Unloaded By'**
  String get enumCore_prescriptionMovementUnloadedActorLabel;

  /// No description provided for @enumCore_prescriptionMovementShortageReportedActorLabel.
  ///
  /// In en, this message translates to:
  /// **'Shortage Reported By'**
  String get enumCore_prescriptionMovementShortageReportedActorLabel;

  /// No description provided for @enumCore_prescriptionMovementReplenishmentPendingActorLabel.
  ///
  /// In en, this message translates to:
  /// **'Replenishment Approved By'**
  String get enumCore_prescriptionMovementReplenishmentPendingActorLabel;

  /// No description provided for @enumCore_prescriptionMovementRedirectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Redirected'**
  String get enumCore_prescriptionMovementRedirectedLabel;

  /// No description provided for @enumCore_prescriptionMovementRedirectedActorLabel.
  ///
  /// In en, this message translates to:
  /// **'Redirected by'**
  String get enumCore_prescriptionMovementRedirectedActorLabel;

  /// No description provided for @enumCore_prescriptionMovementRedirectedActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Redirected'**
  String get enumCore_prescriptionMovementRedirectedActionLabel;

  /// No description provided for @enumCore_prescriptionMovementPendingApprovalActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get enumCore_prescriptionMovementPendingApprovalActionLabel;

  /// No description provided for @enumCore_prescriptionMovementPurchasePendingActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Filled'**
  String get enumCore_prescriptionMovementPurchasePendingActionLabel;

  /// No description provided for @enumCore_prescriptionMovementAppliedActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get enumCore_prescriptionMovementAppliedActionLabel;

  /// No description provided for @enumCore_prescriptionMovementReturnedActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get enumCore_prescriptionMovementReturnedActionLabel;

  /// No description provided for @enumCore_prescriptionMovementWastagedActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Wasted'**
  String get enumCore_prescriptionMovementWastagedActionLabel;

  /// No description provided for @enumCore_prescriptionMovementDestructedActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Destructed'**
  String get enumCore_prescriptionMovementDestructedActionLabel;

  /// No description provided for @enumCore_prescriptionMovementCancelledActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get enumCore_prescriptionMovementCancelledActionLabel;

  /// No description provided for @enumCore_prescriptionMovementRejectedActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get enumCore_prescriptionMovementRejectedActionLabel;

  /// No description provided for @enumCore_prescriptionMovementFilledWaitingActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get enumCore_prescriptionMovementFilledWaitingActionLabel;

  /// No description provided for @enumCore_prescriptionMovementReturnPendingActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Return Requested'**
  String get enumCore_prescriptionMovementReturnPendingActionLabel;

  /// No description provided for @enumCore_prescriptionMovementUnloadedActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Unloaded'**
  String get enumCore_prescriptionMovementUnloadedActionLabel;

  /// No description provided for @enumCore_prescriptionMovementShortageReportedActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Shortage Reported'**
  String get enumCore_prescriptionMovementShortageReportedActionLabel;

  /// No description provided for @enumCore_prescriptionMovementReplenishmentPendingActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Replenishment Approved'**
  String get enumCore_prescriptionMovementReplenishmentPendingActionLabel;

  /// No description provided for @userAuth_table_firstNameColumn.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get userAuth_table_firstNameColumn;

  /// No description provided for @userAuth_table_lastNameColumn.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get userAuth_table_lastNameColumn;

  /// No description provided for @userAuth_table_occupationTypeColumn.
  ///
  /// In en, this message translates to:
  /// **'Occupation Type'**
  String get userAuth_table_occupationTypeColumn;

  /// No description provided for @userAuth_table_expiryDateColumn.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get userAuth_table_expiryDateColumn;

  /// No description provided for @userAuth_table_remainingDaysColumn.
  ///
  /// In en, this message translates to:
  /// **'Remaining Days'**
  String get userAuth_table_remainingDaysColumn;

  /// No description provided for @userAuth_table_statusColumn.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get userAuth_table_statusColumn;

  /// No description provided for @medicine_table_barcodeColumn.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get medicine_table_barcodeColumn;

  /// No description provided for @medicine_table_atcCodeColumn.
  ///
  /// In en, this message translates to:
  /// **'ATC Code'**
  String get medicine_table_atcCodeColumn;

  /// No description provided for @medicine_table_nameColumn.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get medicine_table_nameColumn;

  /// No description provided for @medicine_table_materialTypeColumn.
  ///
  /// In en, this message translates to:
  /// **'Material Type'**
  String get medicine_table_materialTypeColumn;

  /// No description provided for @medicine_table_prescriptionTypeColumn.
  ///
  /// In en, this message translates to:
  /// **'Prescription Type'**
  String get medicine_table_prescriptionTypeColumn;

  /// No description provided for @medicine_table_countTypeColumn.
  ///
  /// In en, this message translates to:
  /// **'Count Type'**
  String get medicine_table_countTypeColumn;

  /// No description provided for @medicine_table_purchaseTypeColumn.
  ///
  /// In en, this message translates to:
  /// **'Purchase Type'**
  String get medicine_table_purchaseTypeColumn;

  /// No description provided for @medicine_table_returnTypeColumn.
  ///
  /// In en, this message translates to:
  /// **'Return Type'**
  String get medicine_table_returnTypeColumn;

  /// No description provided for @medicine_table_statusColumn.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get medicine_table_statusColumn;

  /// No description provided for @enumCore_medicineTypeDrug.
  ///
  /// In en, this message translates to:
  /// **'Drug'**
  String get enumCore_medicineTypeDrug;

  /// No description provided for @enumCore_medicineTypeConsumable.
  ///
  /// In en, this message translates to:
  /// **'Medical Consumable'**
  String get enumCore_medicineTypeConsumable;

  /// No description provided for @refund_table_patientCodeColumn.
  ///
  /// In en, this message translates to:
  /// **'Patient Code'**
  String get refund_table_patientCodeColumn;

  /// No description provided for @refund_table_patientColumn.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get refund_table_patientColumn;

  /// No description provided for @refund_table_userColumn.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get refund_table_userColumn;

  /// No description provided for @refund_table_medicineColumn.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get refund_table_medicineColumn;

  /// No description provided for @refund_table_quantityColumn.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get refund_table_quantityColumn;

  /// No description provided for @refund_table_dateColumn.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get refund_table_dateColumn;

  /// No description provided for @refund_table_approvedUserColumn.
  ///
  /// In en, this message translates to:
  /// **'Approved By'**
  String get refund_table_approvedUserColumn;

  /// No description provided for @refund_table_approvedDateColumn.
  ///
  /// In en, this message translates to:
  /// **'Approval Date'**
  String get refund_table_approvedDateColumn;

  /// No description provided for @refund_table_descriptionColumn.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get refund_table_descriptionColumn;

  /// No description provided for @authorization_table_userColumn.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get authorization_table_userColumn;

  /// No description provided for @authorization_table_roleColumn.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get authorization_table_roleColumn;

  /// No description provided for @authorization_table_encryptedLoginColumn.
  ///
  /// In en, this message translates to:
  /// **'Encrypted Login'**
  String get authorization_table_encryptedLoginColumn;

  /// No description provided for @authorization_table_isDeletedColumn.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get authorization_table_isDeletedColumn;

  /// No description provided for @authorization_table_extraAuthCountColumn.
  ///
  /// In en, this message translates to:
  /// **'Extra Authorization'**
  String get authorization_table_extraAuthCountColumn;

  /// No description provided for @authorization_summary_viewDetailsTooltip.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get authorization_summary_viewDetailsTooltip;

  /// No description provided for @authorization_summary_dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'User Authorization Summary'**
  String get authorization_summary_dialogTitle;

  /// No description provided for @authorization_summary_roleMenusTitle.
  ///
  /// In en, this message translates to:
  /// **'Role-Based Authorized Menus'**
  String get authorization_summary_roleMenusTitle;

  /// No description provided for @authorization_summary_roleMenusEmptyLabel.
  ///
  /// In en, this message translates to:
  /// **'No role-based authorizations'**
  String get authorization_summary_roleMenusEmptyLabel;

  /// No description provided for @authorization_summary_extraMenusTitle.
  ///
  /// In en, this message translates to:
  /// **'Extra Authorized Menus'**
  String get authorization_summary_extraMenusTitle;

  /// No description provided for @authorization_summary_extraMenusEmptyLabel.
  ///
  /// In en, this message translates to:
  /// **'No extra authorizations'**
  String get authorization_summary_extraMenusEmptyLabel;

  /// No description provided for @cabinTemperature_table_dateColumn.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get cabinTemperature_table_dateColumn;

  /// No description provided for @cabinTemperature_table_cabinColumn.
  ///
  /// In en, this message translates to:
  /// **'Cabin'**
  String get cabinTemperature_table_cabinColumn;

  /// No description provided for @cabinTemperature_table_insideTempColumn.
  ///
  /// In en, this message translates to:
  /// **'Inside Temperature'**
  String get cabinTemperature_table_insideTempColumn;

  /// No description provided for @cabinTemperature_table_outsideTempColumn.
  ///
  /// In en, this message translates to:
  /// **'Outside Temperature'**
  String get cabinTemperature_table_outsideTempColumn;

  /// No description provided for @cabinTemperature_table_humidityColumn.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get cabinTemperature_table_humidityColumn;

  /// No description provided for @cabinTemperature_action_showOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Show Out of Range'**
  String get cabinTemperature_action_showOutOfRange;

  /// No description provided for @cabinTemperature_action_showAll.
  ///
  /// In en, this message translates to:
  /// **'Show All'**
  String get cabinTemperature_action_showAll;

  /// No description provided for @cabinTemperature_currentStationNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'No active station could be found'**
  String get cabinTemperature_currentStationNotFoundError;

  /// No description provided for @expiredItems_table_barcodeColumn.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get expiredItems_table_barcodeColumn;

  /// No description provided for @expiredItems_table_medicineColumn.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get expiredItems_table_medicineColumn;

  /// No description provided for @expiredItems_table_cabinColumn.
  ///
  /// In en, this message translates to:
  /// **'Cabin'**
  String get expiredItems_table_cabinColumn;

  /// No description provided for @expiredItems_table_locationColumn.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get expiredItems_table_locationColumn;

  /// No description provided for @expiredItems_table_minQuantityColumn.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get expiredItems_table_minQuantityColumn;

  /// No description provided for @expiredItems_table_maxQuantityColumn.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get expiredItems_table_maxQuantityColumn;

  /// No description provided for @expiredItems_table_criticalQuantityColumn.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get expiredItems_table_criticalQuantityColumn;

  /// No description provided for @expiredItems_table_quantityColumn.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get expiredItems_table_quantityColumn;

  /// No description provided for @expiredItems_table_expiryDateColumn.
  ///
  /// In en, this message translates to:
  /// **'Exp. Date'**
  String get expiredItems_table_expiryDateColumn;

  /// No description provided for @expiredItems_table_remainingDaysColumn.
  ///
  /// In en, this message translates to:
  /// **'Remaining Days'**
  String get expiredItems_table_remainingDaysColumn;

  /// No description provided for @hospitalStock_table_serviceColumn.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get hospitalStock_table_serviceColumn;

  /// No description provided for @hospitalStock_table_codeColumn.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get hospitalStock_table_codeColumn;

  /// No description provided for @hospitalStock_table_medicineColumn.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get hospitalStock_table_medicineColumn;

  /// No description provided for @hospitalStock_table_quantityColumn.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get hospitalStock_table_quantityColumn;

  /// No description provided for @patientInventory_table_doctorColumn.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get patientInventory_table_doctorColumn;

  /// No description provided for @patientInventory_table_departmentColumn.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get patientInventory_table_departmentColumn;

  /// No description provided for @patientInventory_table_barcodeColumn.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get patientInventory_table_barcodeColumn;

  /// No description provided for @patientInventory_table_medicineColumn.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get patientInventory_table_medicineColumn;

  /// No description provided for @patientInventory_table_requestedQuantityColumn.
  ///
  /// In en, this message translates to:
  /// **'Requested Qty'**
  String get patientInventory_table_requestedQuantityColumn;

  /// No description provided for @patientInventory_table_processedQuantityColumn.
  ///
  /// In en, this message translates to:
  /// **'Processed Qty'**
  String get patientInventory_table_processedQuantityColumn;

  /// No description provided for @patientInventory_table_requestDateColumn.
  ///
  /// In en, this message translates to:
  /// **'Request Date'**
  String get patientInventory_table_requestDateColumn;

  /// No description provided for @patientInventory_table_processDateColumn.
  ///
  /// In en, this message translates to:
  /// **'Process Date'**
  String get patientInventory_table_processDateColumn;

  /// No description provided for @patientInventory_table_movementColumn.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get patientInventory_table_movementColumn;

  /// No description provided for @patientInventory_pdf_title.
  ///
  /// In en, this message translates to:
  /// **'{patientName} adlı hastaya ait Hasta Envanter Listesi'**
  String patientInventory_pdf_title(String patientName);

  /// No description provided for @patientInventory_pdf_patientCode.
  ///
  /// In en, this message translates to:
  /// **'Hasta Kodu: {code}'**
  String patientInventory_pdf_patientCode(Object code);

  /// No description provided for @patientInventory_pdf_service.
  ///
  /// In en, this message translates to:
  /// **'Servis: {name}'**
  String patientInventory_pdf_service(String name);

  /// No description provided for @patientInventory_pdf_bed.
  ///
  /// In en, this message translates to:
  /// **'Yatak: {name}'**
  String patientInventory_pdf_bed(String name);

  /// No description provided for @patientInventory_pdf_reportDate.
  ///
  /// In en, this message translates to:
  /// **'Rapor Tarihi: {date}'**
  String patientInventory_pdf_reportDate(String date);

  /// No description provided for @service_table_nameColumn.
  ///
  /// In en, this message translates to:
  /// **'Service Name'**
  String get service_table_nameColumn;

  /// No description provided for @service_table_branchColumn.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get service_table_branchColumn;

  /// No description provided for @service_table_managerColumn.
  ///
  /// In en, this message translates to:
  /// **'Service Manager'**
  String get service_table_managerColumn;

  /// No description provided for @service_table_statusColumn.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get service_table_statusColumn;

  /// No description provided for @unappliedPrescription_table_serviceColumn.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get unappliedPrescription_table_serviceColumn;

  /// No description provided for @unappliedPrescription_table_roomColumn.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get unappliedPrescription_table_roomColumn;

  /// No description provided for @unappliedPrescription_table_bedColumn.
  ///
  /// In en, this message translates to:
  /// **'Bed'**
  String get unappliedPrescription_table_bedColumn;

  /// No description provided for @unappliedPrescription_table_patientCodeColumn.
  ///
  /// In en, this message translates to:
  /// **'Patient Code'**
  String get unappliedPrescription_table_patientCodeColumn;

  /// No description provided for @unappliedPrescription_table_patientColumn.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get unappliedPrescription_table_patientColumn;

  /// No description provided for @unappliedPrescription_table_hospitalizationCodeColumn.
  ///
  /// In en, this message translates to:
  /// **'Admission Code'**
  String get unappliedPrescription_table_hospitalizationCodeColumn;

  /// No description provided for @unappliedPrescription_table_admissionDateColumn.
  ///
  /// In en, this message translates to:
  /// **'Admission Date'**
  String get unappliedPrescription_table_admissionDateColumn;

  /// No description provided for @unappliedPrescription_table_pendingCountColumn.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get unappliedPrescription_table_pendingCountColumn;

  /// No description provided for @drugActivity_table_dateColumn.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get drugActivity_table_dateColumn;

  /// No description provided for @drugActivity_table_timeColumn.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get drugActivity_table_timeColumn;

  /// No description provided for @drugActivity_table_patientColumn.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get drugActivity_table_patientColumn;

  /// No description provided for @drugActivity_table_userColumn.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get drugActivity_table_userColumn;

  /// No description provided for @drugActivity_table_medicineColumn.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get drugActivity_table_medicineColumn;

  /// No description provided for @drugActivity_table_quantityColumn.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get drugActivity_table_quantityColumn;

  /// No description provided for @drugActivity_table_movementColumn.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get drugActivity_table_movementColumn;

  /// No description provided for @rfid_notConnectedError.
  ///
  /// In en, this message translates to:
  /// **'RFID reader is not connected'**
  String get rfid_notConnectedError;

  /// No description provided for @rfid_inventoryStartFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to start RFID inventory: {detail}'**
  String rfid_inventoryStartFailedError(String detail);

  /// No description provided for @rfid_inventoryStreamError.
  ///
  /// In en, this message translates to:
  /// **'RFID inventory stream error: {detail}'**
  String rfid_inventoryStreamError(String detail);

  /// No description provided for @mobileDrawer_cabinConnectionErrorMessage.
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

  /// No description provided for @census_mode_allCabin.
  ///
  /// In en, this message translates to:
  /// **'Whole Cabinet'**
  String get census_mode_allCabin;

  /// No description provided for @census_mode_byDrawer.
  ///
  /// In en, this message translates to:
  /// **'By Drawer'**
  String get census_mode_byDrawer;

  /// No description provided for @census_mode_byMedicine.
  ///
  /// In en, this message translates to:
  /// **'By Medicine'**
  String get census_mode_byMedicine;

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

  /// No description provided for @intake_screenTitle.
  ///
  /// In en, this message translates to:
  /// **'Medication Intake'**
  String get intake_screenTitle;

  /// No description provided for @intake_phase_patientLabel.
  ///
  /// In en, this message translates to:
  /// **'Patient Selection'**
  String get intake_phase_patientLabel;

  /// No description provided for @intake_phase_medicineLabel.
  ///
  /// In en, this message translates to:
  /// **'Medication Selection'**
  String get intake_phase_medicineLabel;

  /// No description provided for @intake_phase_executingLabel.
  ///
  /// In en, this message translates to:
  /// **'Intake Process'**
  String get intake_phase_executingLabel;

  /// No description provided for @patientPicker_roomLabel.
  ///
  /// In en, this message translates to:
  /// **'Room {room}'**
  String patientPicker_roomLabel(String room);

  /// No description provided for @patientPicker_bedLabel.
  ///
  /// In en, this message translates to:
  /// **'Bed {bed}'**
  String patientPicker_bedLabel(String bed);

  /// No description provided for @intake_label_countFieldLabelIndexed.
  ///
  /// In en, this message translates to:
  /// **'Count {index} ({unit})'**
  String intake_label_countFieldLabelIndexed(String unit, int index);

  /// No description provided for @patientListPanel_filter_patientStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Patient Status'**
  String get patientListPanel_filter_patientStatusLabel;

  /// No description provided for @patientListPanel_filter_orderStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get patientListPanel_filter_orderStatusLabel;

  /// No description provided for @patientListPanel_filter_dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get patientListPanel_filter_dialogTitle;

  /// No description provided for @masterDrawer_status_devicePreparingTitle.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get masterDrawer_status_devicePreparingTitle;

  /// No description provided for @masterDrawer_status_devicePreparingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The system is getting ready. Please wait a moment.'**
  String get masterDrawer_status_devicePreparingSubtitle;

  /// No description provided for @masterDrawer_status_lockOpeningTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlocking'**
  String get masterDrawer_status_lockOpeningTitle;

  /// No description provided for @masterDrawer_status_lockOpeningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The drawer lock is opening. Please wait a moment.'**
  String get masterDrawer_status_lockOpeningSubtitle;

  /// No description provided for @masterDrawer_status_waitingPullTitle.
  ///
  /// In en, this message translates to:
  /// **'Please Pull the Drawer'**
  String get masterDrawer_status_waitingPullTitle;

  /// No description provided for @masterDrawer_status_waitingPullSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The lock has been released. Pull the drawer open to continue.'**
  String get masterDrawer_status_waitingPullSubtitle;

  /// No description provided for @masterDrawer_status_openingLidTitle.
  ///
  /// In en, this message translates to:
  /// **'Opening Compartment Lid'**
  String get masterDrawer_status_openingLidTitle;

  /// No description provided for @masterDrawer_status_openingLidSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The compartment lid is opening. Please wait a moment.'**
  String get masterDrawer_status_openingLidSubtitle;

  /// No description provided for @masterDrawer_status_waitingCloseTitle.
  ///
  /// In en, this message translates to:
  /// **'Please Close the Drawer'**
  String get masterDrawer_status_waitingCloseTitle;

  /// No description provided for @masterDrawer_status_waitingCloseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Close the drawer to continue to the next step.'**
  String get masterDrawer_status_waitingCloseSubtitle;

  /// No description provided for @masterDrawer_status_failedTitle.
  ///
  /// In en, this message translates to:
  /// **'A Problem Occurred'**
  String get masterDrawer_status_failedTitle;

  /// No description provided for @masterDrawer_status_failedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please wait, the system is checking the drawer status.'**
  String get masterDrawer_status_failedSubtitle;

  /// No description provided for @masterDrawer_status_openingTitle.
  ///
  /// In en, this message translates to:
  /// **'Opening Drawer'**
  String get masterDrawer_status_openingTitle;

  /// No description provided for @masterDrawer_status_openingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The drawer is opening. Please wait a moment.'**
  String get masterDrawer_status_openingSubtitle;

  /// No description provided for @masterDrawer_stop_waitingCloseTitle.
  ///
  /// In en, this message translates to:
  /// **'Please Close the Open Drawer'**
  String get masterDrawer_stop_waitingCloseTitle;

  /// No description provided for @masterDrawer_stop_waitingCloseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please close the open drawer. The process will stop once it is closed.'**
  String get masterDrawer_stop_waitingCloseSubtitle;

  /// No description provided for @intake_label_queueProgress.
  ///
  /// In en, this message translates to:
  /// **'Drawer {done} of {total}'**
  String intake_label_queueProgress(int done, int total);

  /// No description provided for @intake_action_stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get intake_action_stop;

  /// No description provided for @intake_stop_confirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop Intake?'**
  String get intake_stop_confirmTitle;

  /// No description provided for @intake_stop_confirmMessage.
  ///
  /// In en, this message translates to:
  /// **'The current intake process will be stopped. Completed drawers will be preserved.'**
  String get intake_stop_confirmMessage;

  /// No description provided for @intake_stop_confirmYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, Stop'**
  String get intake_stop_confirmYes;

  /// No description provided for @intake_hint_mergedFromMultiplePrescriptions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Combined from {count} prescription} other{Combined from {count} prescriptions}}'**
  String intake_hint_mergedFromMultiplePrescriptions(num count);

  /// No description provided for @refund_hint_searchMedicine.
  ///
  /// In en, this message translates to:
  /// **'Search medicine'**
  String get refund_hint_searchMedicine;

  /// No description provided for @refund_hint_selectPatientFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a patient first'**
  String get refund_hint_selectPatientFirst;

  /// No description provided for @refund_hint_noMedicineFound.
  ///
  /// In en, this message translates to:
  /// **'No refundable medicine found'**
  String get refund_hint_noMedicineFound;

  /// No description provided for @refund_action_start.
  ///
  /// In en, this message translates to:
  /// **'Start Refund'**
  String get refund_action_start;

  /// No description provided for @refund_action_nextCell.
  ///
  /// In en, this message translates to:
  /// **'Next Cell'**
  String get refund_action_nextCell;

  /// No description provided for @refund_action_completeRefund.
  ///
  /// In en, this message translates to:
  /// **'Complete Refund'**
  String get refund_action_completeRefund;

  /// No description provided for @refund_action_stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get refund_action_stop;

  /// No description provided for @refund_action_stopConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop Refund?'**
  String get refund_action_stopConfirmTitle;

  /// No description provided for @refund_action_stopConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Completed refunds will be kept, remaining drawers will not be processed.'**
  String get refund_action_stopConfirmMessage;

  /// No description provided for @refund_action_stopConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, Stop'**
  String get refund_action_stopConfirmYes;

  /// No description provided for @refund_field_maxAmount.
  ///
  /// In en, this message translates to:
  /// **'Max. Refundable'**
  String get refund_field_maxAmount;

  /// No description provided for @refund_field_returnNote.
  ///
  /// In en, this message translates to:
  /// **'Return Note'**
  String get refund_field_returnNote;

  /// No description provided for @refund_status_checking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get refund_status_checking;

  /// No description provided for @refund_status_ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get refund_status_ready;

  /// No description provided for @refund_status_checkFailed.
  ///
  /// In en, this message translates to:
  /// **'Check failed'**
  String get refund_status_checkFailed;

  /// No description provided for @refund_error_queueTitle.
  ///
  /// In en, this message translates to:
  /// **'Refund Error'**
  String get refund_error_queueTitle;

  /// No description provided for @refund_error_continueNext.
  ///
  /// In en, this message translates to:
  /// **'Continue with Next'**
  String get refund_error_continueNext;

  /// No description provided for @refund_error_endProcess.
  ///
  /// In en, this message translates to:
  /// **'End Process'**
  String get refund_error_endProcess;

  /// No description provided for @refund_error_amountZero.
  ///
  /// In en, this message translates to:
  /// **'Refund quantity cannot be 0'**
  String get refund_error_amountZero;

  /// No description provided for @refund_error_amountExceedsMax.
  ///
  /// In en, this message translates to:
  /// **'Refund amount cannot exceed the received amount'**
  String get refund_error_amountExceedsMax;

  /// No description provided for @refund_label_progress.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} drawers'**
  String refund_label_progress(int done, int total);

  /// No description provided for @waste_hint_searchMedicine.
  ///
  /// In en, this message translates to:
  /// **'Search medicine'**
  String get waste_hint_searchMedicine;

  /// No description provided for @waste_hint_selectPatientFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a patient to continue'**
  String get waste_hint_selectPatientFirst;

  /// No description provided for @waste_hint_noMedicineFound.
  ///
  /// In en, this message translates to:
  /// **'No disposable medicine found'**
  String get waste_hint_noMedicineFound;

  /// No description provided for @waste_label_availableAmount.
  ///
  /// In en, this message translates to:
  /// **'Available amount: {amount}'**
  String waste_label_availableAmount(String amount);

  /// No description provided for @waste_error_amountZero.
  ///
  /// In en, this message translates to:
  /// **'Quantity cannot be 0.'**
  String get waste_error_amountZero;

  /// No description provided for @waste_error_wastageAmountExceeded.
  ///
  /// In en, this message translates to:
  /// **'The quantity to be wasted cannot exceed the intake quantity.'**
  String get waste_error_wastageAmountExceeded;

  /// No description provided for @waste_error_destructionAmountExceeded.
  ///
  /// In en, this message translates to:
  /// **'The quantity to be destroyed cannot exceed the intake quantity.'**
  String get waste_error_destructionAmountExceeded;

  /// No description provided for @waste_success_operationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Waste/destruction operation successful.'**
  String get waste_success_operationCompleted;

  /// No description provided for @witnessDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Witness Verification'**
  String get witnessDialog_title;

  /// No description provided for @witnessDialog_usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get witnessDialog_usernameLabel;

  /// No description provided for @witnessDialog_usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get witnessDialog_usernameRequired;

  /// No description provided for @witnessDialog_passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get witnessDialog_passwordLabel;

  /// No description provided for @witnessDialog_passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get witnessDialog_passwordRequired;

  /// No description provided for @witnessDialog_confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get witnessDialog_confirmButton;

  /// No description provided for @witnessDialog_anyoneInfo.
  ///
  /// In en, this message translates to:
  /// **'Any user may act as a witness for this item.'**
  String get witnessDialog_anyoneInfo;

  /// No description provided for @witnessDialog_authorizedWitnesses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} authorized witness} other{{count} authorized witnesses}}'**
  String witnessDialog_authorizedWitnesses(num count);

  /// No description provided for @witnessDialog_error_selfWitness.
  ///
  /// In en, this message translates to:
  /// **'You cannot witness your own operation.'**
  String get witnessDialog_error_selfWitness;

  /// No description provided for @witnessDialog_success_confirmed.
  ///
  /// In en, this message translates to:
  /// **'{witnessName} confirmed as witness.'**
  String witnessDialog_success_confirmed(String witnessName);

  /// No description provided for @witnessDialog_assignedLabel.
  ///
  /// In en, this message translates to:
  /// **'Witness: {witnessName}'**
  String witnessDialog_assignedLabel(String witnessName);

  /// No description provided for @witnessDialog_requiredHint.
  ///
  /// In en, this message translates to:
  /// **'Witness confirmation required'**
  String get witnessDialog_requiredHint;

  /// No description provided for @witnessDialog_autoAssigned.
  ///
  /// In en, this message translates to:
  /// **'{witnessName} was automatically assigned as witness for this item.'**
  String witnessDialog_autoAssigned(String witnessName);

  /// No description provided for @unload_hint_searchMedicine.
  ///
  /// In en, this message translates to:
  /// **'Search medicine or barcode'**
  String get unload_hint_searchMedicine;

  /// No description provided for @unload_hint_noMedicineFound.
  ///
  /// In en, this message translates to:
  /// **'No medicine found'**
  String get unload_hint_noMedicineFound;

  /// No description provided for @unload_action_stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get unload_action_stop;

  /// No description provided for @unload_action_nextCell.
  ///
  /// In en, this message translates to:
  /// **'Next Cell'**
  String get unload_action_nextCell;

  /// No description provided for @unload_action_completeUnloading.
  ///
  /// In en, this message translates to:
  /// **'Complete Unloading'**
  String get unload_action_completeUnloading;

  /// No description provided for @unload_stop_confirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop Unloading?'**
  String get unload_stop_confirmTitle;

  /// No description provided for @unload_stop_confirmMessage.
  ///
  /// In en, this message translates to:
  /// **'The remaining drawers in the queue will not be unloaded. Are you sure you want to stop?'**
  String get unload_stop_confirmMessage;

  /// No description provided for @unload_stop_confirmYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, Stop'**
  String get unload_stop_confirmYes;

  /// No description provided for @unload_error_queueTitle.
  ///
  /// In en, this message translates to:
  /// **'Unload Error'**
  String get unload_error_queueTitle;

  /// No description provided for @unload_error_continueNext.
  ///
  /// In en, this message translates to:
  /// **'Continue to Next Drawer'**
  String get unload_error_continueNext;

  /// No description provided for @unload_error_endProcess.
  ///
  /// In en, this message translates to:
  /// **'End Process'**
  String get unload_error_endProcess;

  /// No description provided for @unload_label_queueProgress.
  ///
  /// In en, this message translates to:
  /// **'Drawer {done} of {total}'**
  String unload_label_queueProgress(int done, int total);

  /// No description provided for @unload_label_countQty.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get unload_label_countQty;

  /// No description provided for @unload_label_unloadQty.
  ///
  /// In en, this message translates to:
  /// **'Unload Qty'**
  String get unload_label_unloadQty;

  /// No description provided for @refund_label_quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get refund_label_quantity;

  /// No description provided for @destruction_label_queueProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String destruction_label_queueProgress(int current, int total);

  /// No description provided for @destruction_action_stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get destruction_action_stop;

  /// No description provided for @destruction_stop_confirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop destruction?'**
  String get destruction_stop_confirmTitle;

  /// No description provided for @destruction_stop_confirmMessage.
  ///
  /// In en, this message translates to:
  /// **'The destruction process will be stopped. Items already processed will be kept.'**
  String get destruction_stop_confirmMessage;

  /// No description provided for @destruction_stop_confirmYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, stop'**
  String get destruction_stop_confirmYes;

  /// No description provided for @destruction_label_quantity.
  ///
  /// In en, this message translates to:
  /// **'Destroy Qty'**
  String get destruction_label_quantity;

  /// No description provided for @destruction_action_nextCell.
  ///
  /// In en, this message translates to:
  /// **'Next cell'**
  String get destruction_action_nextCell;

  /// No description provided for @destruction_action_completeDestruction.
  ///
  /// In en, this message translates to:
  /// **'Complete destruction'**
  String get destruction_action_completeDestruction;

  /// No description provided for @waste_hint_notAuthorized.
  ///
  /// In en, this message translates to:
  /// **'You are not authorized to destroy this medicine'**
  String get waste_hint_notAuthorized;

  /// No description provided for @intake_action_checkEquivalent.
  ///
  /// In en, this message translates to:
  /// **'Check Equivalent'**
  String get intake_action_checkEquivalent;

  /// No description provided for @intake_hint_noEquivalentFound.
  ///
  /// In en, this message translates to:
  /// **'No equivalent medicine found'**
  String get intake_hint_noEquivalentFound;

  /// No description provided for @intake_label_equivalentOptions.
  ///
  /// In en, this message translates to:
  /// **'Available equivalents'**
  String get intake_label_equivalentOptions;

  /// No description provided for @intake_hint_searchingOtherStations.
  ///
  /// In en, this message translates to:
  /// **'Searching other cabins...'**
  String get intake_hint_searchingOtherStations;

  /// No description provided for @intake_hint_noStockAnywhere.
  ///
  /// In en, this message translates to:
  /// **'This medicine was not found in any cabin'**
  String get intake_hint_noStockAnywhere;

  /// No description provided for @intake_label_otherStationOptions.
  ///
  /// In en, this message translates to:
  /// **'Available in other cabins'**
  String get intake_label_otherStationOptions;

  /// No description provided for @intake_action_redirect.
  ///
  /// In en, this message translates to:
  /// **'Redirect'**
  String get intake_action_redirect;

  /// No description provided for @intake_hint_redirectedTo.
  ///
  /// In en, this message translates to:
  /// **'Redirected to {stationName} cabin'**
  String intake_hint_redirectedTo(String stationName);

  /// No description provided for @intake_status_redirected.
  ///
  /// In en, this message translates to:
  /// **'Redirected'**
  String get intake_status_redirected;

  /// No description provided for @intake_tab_prescriptions.
  ///
  /// In en, this message translates to:
  /// **'Prescriptions'**
  String get intake_tab_prescriptions;

  /// No description provided for @intake_tab_redirectedOrders.
  ///
  /// In en, this message translates to:
  /// **'Redirected Orders'**
  String get intake_tab_redirectedOrders;

  /// No description provided for @intake_hint_noRedirectedOrders.
  ///
  /// In en, this message translates to:
  /// **'No redirected orders'**
  String get intake_hint_noRedirectedOrders;

  /// No description provided for @intake_status_redirectedFrom.
  ///
  /// In en, this message translates to:
  /// **'Redirected from {stationName}'**
  String intake_status_redirectedFrom(String stationName);

  /// No description provided for @intake_label_redirectedBy.
  ///
  /// In en, this message translates to:
  /// **'Redirected by {userName}'**
  String intake_label_redirectedBy(String userName);

  /// No description provided for @refund_action_completeDirect.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get refund_action_completeDirect;

  /// No description provided for @refund_success_dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Return Completed'**
  String get refund_success_dialogTitle;

  /// No description provided for @refund_success_toPharmacyMessage.
  ///
  /// In en, this message translates to:
  /// **'The return has been completed. Please hand the medicine to the pharmacist.'**
  String get refund_success_toPharmacyMessage;

  /// No description provided for @refund_success_toReturnBoxMessage.
  ///
  /// In en, this message translates to:
  /// **'The return has been completed. Please place the medicine in the return box.'**
  String get refund_success_toReturnBoxMessage;

  /// No description provided for @refund_error_amountExceeded.
  ///
  /// In en, this message translates to:
  /// **'The quantity to be refunded cannot exceed the intake quantity'**
  String get refund_error_amountExceeded;

  /// No description provided for @refund_error_genericCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again later.'**
  String get refund_error_genericCheckFailed;

  /// No description provided for @refund_error_returnDrawerNotDefined.
  ///
  /// In en, this message translates to:
  /// **'The return drawer is not defined. Please define it in the Cabinet Design screen.'**
  String get refund_error_returnDrawerNotDefined;

  /// No description provided for @refund_error_completeFailed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during the return.'**
  String get refund_error_completeFailed;

  /// No description provided for @cabin_returnDrawerName.
  ///
  /// In en, this message translates to:
  /// **'Return Drawer'**
  String get cabin_returnDrawerName;

  /// No description provided for @cabin_returnDrawerView.
  ///
  /// In en, this message translates to:
  /// **'Return Box'**
  String get cabin_returnDrawerView;

  /// No description provided for @cabin_returnDrawerViewTitle.
  ///
  /// In en, this message translates to:
  /// **'This drawer is designated as the return box'**
  String get cabin_returnDrawerViewTitle;

  /// No description provided for @cabin_returnDrawerViewSubtitle.
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

  /// No description provided for @cabinDesign_detail_typeKubik.
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

  /// No description provided for @cabinDesign_returnDrawer_currentInfo.
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

  /// No description provided for @cabinDesign_serum_equipmentLayoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Equipment Layout'**
  String get cabinDesign_serum_equipmentLayoutTitle;

  /// No description provided for @cabinDesign_serum_drawerBadge.
  ///
  /// In en, this message translates to:
  /// **'S-0{index}'**
  String cabinDesign_serum_drawerBadge(int index);

  /// No description provided for @cabinDesign_serum_topViewLabel.
  ///
  /// In en, this message translates to:
  /// **'Top View'**
  String get cabinDesign_serum_topViewLabel;

  /// No description provided for @cabinDesign_serum_shelfCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Shelf {index}'**
  String cabinDesign_serum_shelfCardTitle(int index);

  /// No description provided for @cabinDesign_serum_shelfCardSummary.
  ///
  /// In en, this message translates to:
  /// **'{used}/{total} slots • {count} trays'**
  String cabinDesign_serum_shelfCardSummary(int used, int total, int count);

  /// No description provided for @cabinDesign_serum_lockToggleLabel.
  ///
  /// In en, this message translates to:
  /// **'Electromagnetic Lock'**
  String get cabinDesign_serum_lockToggleLabel;

  /// No description provided for @cabinDesign_serum_addSmallButton.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get cabinDesign_serum_addSmallButton;

  /// No description provided for @cabinDesign_serum_addMediumButton.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get cabinDesign_serum_addMediumButton;

  /// No description provided for @cabinDesign_serum_addLargeButton.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get cabinDesign_serum_addLargeButton;

  /// No description provided for @cabinDesign_serum_traySizeSmallLabel.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get cabinDesign_serum_traySizeSmallLabel;

  /// No description provided for @cabinDesign_serum_traySizeMediumLabel.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get cabinDesign_serum_traySizeMediumLabel;

  /// No description provided for @cabinDesign_serum_traySizeLargeLabel.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get cabinDesign_serum_traySizeLargeLabel;

  /// No description provided for @cabinDesign_serum_trayListItemLabel.
  ///
  /// In en, this message translates to:
  /// **'{index}. Tray • {sizeLabel}'**
  String cabinDesign_serum_trayListItemLabel(int index, String sizeLabel);

  /// No description provided for @cabinDesign_serum_areaUsedLabel.
  ///
  /// In en, this message translates to:
  /// **'{used}/{total} slots used'**
  String cabinDesign_serum_areaUsedLabel(int used, int total);

  /// No description provided for @cabinDesign_serum_capacityFullWarning.
  ///
  /// In en, this message translates to:
  /// **'Shelf is full, no more trays can be added'**
  String get cabinDesign_serum_capacityFullWarning;

  /// No description provided for @cabinDesign_serum_leftLabel.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get cabinDesign_serum_leftLabel;

  /// No description provided for @cabinDesign_serum_rightLabel.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get cabinDesign_serum_rightLabel;

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

  /// No description provided for @unload_segment_returnDrawer.
  ///
  /// In en, this message translates to:
  /// **'Return Drawer'**
  String get unload_segment_returnDrawer;

  /// No description provided for @unload_segment_returnBox.
  ///
  /// In en, this message translates to:
  /// **'Return Box'**
  String get unload_segment_returnBox;

  /// No description provided for @unload_hint_noDrawerMedicineFound.
  ///
  /// In en, this message translates to:
  /// **'No medicines found in the return drawer'**
  String get unload_hint_noDrawerMedicineFound;

  /// No description provided for @unload_hint_noBoxMedicineFound.
  ///
  /// In en, this message translates to:
  /// **'No medicines found in the return box'**
  String get unload_hint_noBoxMedicineFound;

  /// No description provided for @unload_fieldReturnedBy.
  ///
  /// In en, this message translates to:
  /// **'Returned By'**
  String get unload_fieldReturnedBy;

  /// No description provided for @unload_action_startDrawerUnload.
  ///
  /// In en, this message translates to:
  /// **'Start Drawer Unload'**
  String get unload_action_startDrawerUnload;

  /// No description provided for @unload_action_completeBoxUnload.
  ///
  /// In en, this message translates to:
  /// **'Complete Box Unload'**
  String get unload_action_completeBoxUnload;

  /// No description provided for @unload_label_drawerInProgress.
  ///
  /// In en, this message translates to:
  /// **'Return Drawer Unload In Progress'**
  String get unload_label_drawerInProgress;

  /// No description provided for @unload_action_stopConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop Drawer Unload?'**
  String get unload_action_stopConfirmTitle;

  /// No description provided for @unload_action_stopConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'The drawer will close and the unload will not be completed. Do you want to continue?'**
  String get unload_action_stopConfirmMessage;

  /// No description provided for @unload_action_stopConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, Stop'**
  String get unload_action_stopConfirmYes;

  /// No description provided for @unload_action_completeDrawerUnload.
  ///
  /// In en, this message translates to:
  /// **'Complete Drawer Unload'**
  String get unload_action_completeDrawerUnload;

  /// No description provided for @masterDrawer_error_managerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Management card not found. Check the cabin connection.'**
  String get masterDrawer_error_managerNotFound;

  /// No description provided for @masterDrawer_error_managerConnectFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the cabin. Check the connection and try again.'**
  String get masterDrawer_error_managerConnectFailed;

  /// No description provided for @masterDrawer_error_lockOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'The drawer lock could not be opened. Check the hardware.'**
  String get masterDrawer_error_lockOpenFailed;

  /// No description provided for @masterDrawer_error_lidOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'The lid could not be opened. Make sure the drawer is fully open.'**
  String get masterDrawer_error_lidOpenFailed;

  /// No description provided for @masterDrawer_error_lockOpenTimeout.
  ///
  /// In en, this message translates to:
  /// **'The drawer did not fully open in time. Please pull the drawer all the way out.'**
  String get masterDrawer_error_lockOpenTimeout;

  /// No description provided for @masterDrawer_error_sensorCommunicationLost.
  ///
  /// In en, this message translates to:
  /// **'Communication with the hardware was lost. Check the connection and try again.'**
  String get masterDrawer_error_sensorCommunicationLost;

  /// No description provided for @masterDrawer_error_unexpectedlyClosed.
  ///
  /// In en, this message translates to:
  /// **'The drawer was closed unexpectedly while still in use. Please reopen and try again.'**
  String get masterDrawer_error_unexpectedlyClosed;

  /// No description provided for @masterDrawer_status_completingTitle.
  ///
  /// In en, this message translates to:
  /// **'Completing Your Operation'**
  String get masterDrawer_status_completingTitle;

  /// No description provided for @masterDrawer_status_completingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get masterDrawer_status_completingSubtitle;

  /// No description provided for @cabinDesign_cabinList_sectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Defined Cabinets'**
  String get cabinDesign_cabinList_sectionTitle;

  /// No description provided for @cabinDesign_cabinList_countBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} Cabinets'**
  String cabinDesign_cabinList_countBadge(int count);

  /// No description provided for @cabinDesign_cabinList_addCabinButton.
  ///
  /// In en, this message translates to:
  /// **'Define New Cabinet'**
  String get cabinDesign_cabinList_addCabinButton;

  /// No description provided for @cabinDesign_cabinList_noPortLabel.
  ///
  /// In en, this message translates to:
  /// **'No Port'**
  String get cabinDesign_cabinList_noPortLabel;

  /// No description provided for @cabinDesign_cabinList_passiveBadge.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get cabinDesign_cabinList_passiveBadge;

  /// No description provided for @cabinDesign_newCabin_typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Cabinet Type'**
  String get cabinDesign_newCabin_typeLabel;

  /// No description provided for @cabinDesign_newCabin_addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get cabinDesign_newCabin_addressLabel;

  /// No description provided for @cabinDesign_newCabin_noAddressAvailableWarning.
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

  /// No description provided for @cabinDesign_basicSettings_rescanButton.
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

  /// No description provided for @assignment_idle_kicker.
  ///
  /// In en, this message translates to:
  /// **'CABINET CONFIGURATION'**
  String get assignment_idle_kicker;

  /// No description provided for @assignment_idle_title.
  ///
  /// In en, this message translates to:
  /// **'Drug Assignment'**
  String get assignment_idle_title;

  /// No description provided for @assignment_idle_description.
  ///
  /// In en, this message translates to:
  /// **'Tap a cell on the cabinet to the left; choose a drug from the list for that cell and enter minimum, critical, and maximum quantities. Tap a filled cell to edit its existing assignment.'**
  String get assignment_idle_description;

  /// No description provided for @assignment_idle_tableTitle.
  ///
  /// In en, this message translates to:
  /// **'Current Assignments'**
  String get assignment_idle_tableTitle;

  /// No description provided for @assignment_idle_columnLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get assignment_idle_columnLocation;

  /// No description provided for @assignment_idle_columnDrug.
  ///
  /// In en, this message translates to:
  /// **'Drug'**
  String get assignment_idle_columnDrug;

  /// No description provided for @assignment_idle_columnMin.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get assignment_idle_columnMin;

  /// No description provided for @assignment_idle_columnCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get assignment_idle_columnCritical;

  /// No description provided for @assignment_idle_columnMax.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get assignment_idle_columnMax;

  /// No description provided for @assignment_idle_editLink.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get assignment_idle_editLink;

  /// No description provided for @assignment_idle_locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Drawer {drawer} — Cell {cell}'**
  String assignment_idle_locationLabel(String drawer, int cell);

  /// No description provided for @assignment_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Assignment'**
  String get assignment_edit_title;

  /// No description provided for @assignment_edit_cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get assignment_edit_cancelButton;

  /// No description provided for @assignment_edit_selectDrugStep.
  ///
  /// In en, this message translates to:
  /// **'1 — Select Drug'**
  String get assignment_edit_selectDrugStep;

  /// No description provided for @assignment_edit_quantityStep.
  ///
  /// In en, this message translates to:
  /// **'2 — Enter Quantities'**
  String get assignment_edit_quantityStep;

  /// No description provided for @assignment_edit_searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search drug name...'**
  String get assignment_edit_searchHint;

  /// No description provided for @assignment_edit_inCabinBadge.
  ///
  /// In en, this message translates to:
  /// **'In Cabinet'**
  String get assignment_edit_inCabinBadge;

  /// No description provided for @assignment_edit_minQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum Quantity'**
  String get assignment_edit_minQuantityLabel;

  /// No description provided for @assignment_edit_minQuantityHint.
  ///
  /// In en, this message translates to:
  /// **'Orders are suggested below this level'**
  String get assignment_edit_minQuantityHint;

  /// No description provided for @assignment_edit_criticalQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Critical Quantity'**
  String get assignment_edit_criticalQuantityLabel;

  /// No description provided for @assignment_edit_criticalQuantityHint.
  ///
  /// In en, this message translates to:
  /// **'A critical alert is raised at this level'**
  String get assignment_edit_criticalQuantityHint;

  /// No description provided for @assignment_edit_maxQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Maximum Quantity'**
  String get assignment_edit_maxQuantityLabel;

  /// No description provided for @assignment_edit_maxQuantityHint.
  ///
  /// In en, this message translates to:
  /// **'The most the cell can hold'**
  String get assignment_edit_maxQuantityHint;

  /// No description provided for @assignment_edit_removeLink.
  ///
  /// In en, this message translates to:
  /// **'Remove Assignment'**
  String get assignment_edit_removeLink;

  /// No description provided for @assignment_edit_saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get assignment_edit_saveButton;

  /// No description provided for @assignment_edit_previousPage.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get assignment_edit_previousPage;

  /// No description provided for @assignment_edit_nextPage.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get assignment_edit_nextPage;

  /// No description provided for @assignment_edit_pageIndicator.
  ///
  /// In en, this message translates to:
  /// **'Page {current} / {total}'**
  String assignment_edit_pageIndicator(int current, int total);

  /// No description provided for @unscannedBarcode_scan_actionLabel.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get unscannedBarcode_scan_actionLabel;

  /// No description provided for @dashboard_delayMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String dashboard_delayMinutesLabel(int minutes);

  /// No description provided for @dashboard_delayHoursMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String dashboard_delayHoursMinutesLabel(int hours, int minutes);

  /// No description provided for @dashboard_upcomingTreatmentsDelayedTitle.
  ///
  /// In en, this message translates to:
  /// **'Delayed'**
  String get dashboard_upcomingTreatmentsDelayedTitle;

  /// No description provided for @dashboard_upcomingTreatmentsDueSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Within 20 Minutes'**
  String get dashboard_upcomingTreatmentsDueSoonTitle;

  /// No description provided for @dashboard_upcomingTreatmentsUpcomingTitle.
  ///
  /// In en, this message translates to:
  /// **'20-60 Min'**
  String get dashboard_upcomingTreatmentsUpcomingTitle;

  /// Upcoming treatments panel — relative time label under the clock for non-delayed patients, e.g. '4 DK SONRA'
  ///
  /// In en, this message translates to:
  /// **'{minutes} MIN LEFT'**
  String dashboard_upcomingTreatmentsDueInMinutesLabel(int minutes);

  /// No description provided for @assignment_edit_equivalentMedicinesSegment.
  ///
  /// In en, this message translates to:
  /// **'Equivalent Medicines'**
  String get assignment_edit_equivalentMedicinesSegment;

  /// No description provided for @assignment_edit_allMedicinesSegment.
  ///
  /// In en, this message translates to:
  /// **'All Medicines'**
  String get assignment_edit_allMedicinesSegment;

  /// No description provided for @unapplied_showUnappliedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show Unapplied'**
  String get unapplied_showUnappliedTooltip;

  /// No description provided for @unapplied_showOverdueTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show Overdue'**
  String get unapplied_showOverdueTooltip;

  /// No description provided for @stationStock_table_cabinNameColumn.
  ///
  /// In en, this message translates to:
  /// **'Cabin Name'**
  String get stationStock_table_cabinNameColumn;

  /// No description provided for @stationStock_table_maxQuantityColumn.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get stationStock_table_maxQuantityColumn;

  /// No description provided for @stationStock_table_currentQuantityColumn.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get stationStock_table_currentQuantityColumn;

  /// No description provided for @stationStock_table_reservedColumn.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get stationStock_table_reservedColumn;

  /// No description provided for @urgentPatient_intakeCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Emergency patient intake completed'**
  String get urgentPatient_intakeCompletedMessage;

  /// No description provided for @urgentPatient_intakeCompletedDescription.
  ///
  /// In en, this message translates to:
  /// **'You can close out this emergency patient from the Terminate Emergency Patient screen.'**
  String get urgentPatient_intakeCompletedDescription;

  /// No description provided for @directedOrders_table_dateColumn.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get directedOrders_table_dateColumn;

  /// No description provided for @directedOrders_table_materialColumn.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get directedOrders_table_materialColumn;

  /// No description provided for @directedOrders_table_quantityColumn.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get directedOrders_table_quantityColumn;

  /// No description provided for @directedOrders_table_targetServiceColumn.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get directedOrders_table_targetServiceColumn;

  /// No description provided for @directedOrders_table_targetStationColumn.
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get directedOrders_table_targetStationColumn;

  /// No description provided for @directedOrders_table_sentByColumn.
  ///
  /// In en, this message translates to:
  /// **'Sent By'**
  String get directedOrders_table_sentByColumn;

  /// No description provided for @directedOrders_table_cancelledColumn.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Status'**
  String get directedOrders_table_cancelledColumn;

  /// No description provided for @directedOrders_table_cancelledYes.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get directedOrders_table_cancelledYes;

  /// No description provided for @directedOrders_table_cancelledNo.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get directedOrders_table_cancelledNo;

  /// No description provided for @unscannedBarcodes_action_showScanned.
  ///
  /// In en, this message translates to:
  /// **'Show Scanned Barcodes'**
  String get unscannedBarcodes_action_showScanned;

  /// No description provided for @unscannedBarcodes_action_showDeleted.
  ///
  /// In en, this message translates to:
  /// **'Show Deleted Barcodes'**
  String get unscannedBarcodes_action_showDeleted;

  /// No description provided for @unscannedBarcodes_action_showUnscanned.
  ///
  /// In en, this message translates to:
  /// **'Show Unscanned Barcodes'**
  String get unscannedBarcodes_action_showUnscanned;

  /// No description provided for @urgentPatientTermination_listTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Patients'**
  String get urgentPatientTermination_listTitle;

  /// No description provided for @urgentPatientTermination_selectHint.
  ///
  /// In en, this message translates to:
  /// **'Select an emergency patient to continue'**
  String get urgentPatientTermination_selectHint;

  /// No description provided for @urgentPatientTermination_takenMedicinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Medicines Taken'**
  String get urgentPatientTermination_takenMedicinesTitle;

  /// No description provided for @urgentPatientTermination_defaultPatientLabel.
  ///
  /// In en, this message translates to:
  /// **'Emergency Patient'**
  String get urgentPatientTermination_defaultPatientLabel;

  /// No description provided for @urgentPatientTermination_openRecordChip.
  ///
  /// In en, this message translates to:
  /// **'Record Open'**
  String get urgentPatientTermination_openRecordChip;

  /// No description provided for @urgentPatientTermination_serviceLabel.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get urgentPatientTermination_serviceLabel;

  /// No description provided for @urgentPatientTermination_sourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Emergency Record'**
  String get urgentPatientTermination_sourceLabel;

  /// Value shown under urgentPatientTermination_sourceLabel — the urgent patient's display code.
  ///
  /// In en, this message translates to:
  /// **'Emergency Patient #{code}'**
  String urgentPatientTermination_sourceValue(String code);

  /// No description provided for @urgentPatientTermination_targetLabel.
  ///
  /// In en, this message translates to:
  /// **'Patient to Match'**
  String get urgentPatientTermination_targetLabel;

  /// No description provided for @urgentPatientTermination_finalizeButton.
  ///
  /// In en, this message translates to:
  /// **'Match and Finalize'**
  String get urgentPatientTermination_finalizeButton;

  /// No description provided for @urgentPatientTermination_medicineTakenChip.
  ///
  /// In en, this message translates to:
  /// **'Medicine Taken'**
  String get urgentPatientTermination_medicineTakenChip;

  /// No description provided for @urgentPatientTermination_medicineNotTakenChip.
  ///
  /// In en, this message translates to:
  /// **'No Medicine'**
  String get urgentPatientTermination_medicineNotTakenChip;

  /// No description provided for @urgentPatientTermination_noMedicineEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No medicine has been taken under this emergency record'**
  String get urgentPatientTermination_noMedicineEmptyTitle;

  /// No description provided for @urgentPatientTermination_noMedicineEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'The record cannot be finalized because no medicine has been taken; however, the record may still be deleted.'**
  String get urgentPatientTermination_noMedicineEmptyDescription;
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
