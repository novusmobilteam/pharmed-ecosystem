// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get common_selectCellTitle => 'Select a Cell';

  @override
  String get common_noAssignmentBadge => 'Unassigned';

  @override
  String get common_drugAssignedBadge => 'Drug Assigned';

  @override
  String get common_patientAssignedBadge => 'Patient Assigned';

  @override
  String get common_noCabinDataTitle => 'No Cabinet Data Found';

  @override
  String get common_noCabinDataDescription =>
      'The cabinet may not be configured yet\nor the connection could not be established.';

  @override
  String get common_noResultsTitle => 'No Results Found';

  @override
  String get common_noResultsDescription =>
      'Try changing your search criteria.';

  @override
  String get common_retryButton => 'Retry';

  @override
  String get common_cancelButton => 'Cancel';

  @override
  String get common_pageNotFound => 'Page Not Found';

  @override
  String get common_minLabel => 'Min';

  @override
  String get common_maxLabel => 'Max';

  @override
  String get common_criticalLabel => 'Critical';

  @override
  String get auth_loginSubtitle => 'Sign in to the system';

  @override
  String get auth_emailLabel => 'Email / Username';

  @override
  String get auth_passwordLabel => 'Password';

  @override
  String get auth_loginButton => 'Log In';

  @override
  String get auth_genericError => 'An error occurred';

  @override
  String get dashboard_appBarTitle => 'MEDICINE CABINET MANAGEMENT';

  @override
  String get dashboard_logoutTooltip => 'Log Out';

  @override
  String get dashboard_loginBarButton => 'Log In';

  @override
  String get dashboard_kpiActivePatients => 'Active Patients';

  @override
  String get dashboard_kpiCompletedOps => 'Completed Operations';

  @override
  String get dashboard_kpiPendingPrescriptions => 'Pending Prescriptions';

  @override
  String get dashboard_kpiCriticalAlerts => 'Critical Alerts';

  @override
  String get dashboard_cabinStatusHeader => 'CABINET STATUS';

  @override
  String get dashboard_cabinStatusLabel => 'Cabinet Status';

  @override
  String get dashboard_kpiLoadError => 'Failed to load KPI data';

  @override
  String get dashboard_cabinLoadError => 'Failed to load cabinet data';

  @override
  String get dashboard_treatmentsLoadError => 'Failed to load treatment list';

  @override
  String get dashboard_sktLoadError => 'Failed to load expiry data';

  @override
  String get assignment_assignBedPlaceholder =>
      'Select a cell from the center\npanel to assign a bed.';

  @override
  String get assignment_assignDrugPlaceholder =>
      'Select a cell from the center\npanel to make an assignment.';

  @override
  String get assignment_hospitalizationSectionLabel => 'PATIENT / ADMISSION';

  @override
  String get assignment_hospitalizationSelectorHint => 'Select admission...';

  @override
  String get assignment_selectHospitalizationDialogTitle => 'Select Admission';

  @override
  String get assignment_drugSectionLabel => 'DRUG';

  @override
  String get assignment_drugSelectorHint => 'Select drug...';

  @override
  String get assignment_selectDrugDialogTitle => 'Select Drug';

  @override
  String get assignment_quantitySectionLabel => 'QUANTITY';

  @override
  String get assignment_saveAssignmentButton => 'Save Assignment';

  @override
  String get assignment_removeAssignmentButton => 'Remove Assignment';

  @override
  String get assignment_changeAssignmentButton => 'Change Assignment';

  @override
  String get assignment_roomBedLabel => 'Room / Bed';

  @override
  String get assignment_serviceLabel => 'Ward';

  @override
  String get assignment_cellNotFoundError => 'Selected cell not found';

  @override
  String get assignment_patientSavedSuccess =>
      'Patient assignment saved successfully';

  @override
  String get assignment_patientRemovedSuccess => 'Patient assignment removed';

  @override
  String get fault_selectCellPlaceholder =>
      'Select a cell from the center\npanel to report a fault.';

  @override
  String get fault_descriptionSectionLabel => 'DESCRIPTION';

  @override
  String get fault_descriptionHint => 'Describe the fault...';

  @override
  String get fault_faultSegmentLabel => 'FAULT';

  @override
  String get fault_maintenanceSegmentLabel => 'MAINTENANCE';

  @override
  String get fault_historySectionLabel => 'HISTORY';

  @override
  String get fault_historyStatusCompleted => 'Resolved';

  @override
  String get fault_historyStatusMaintenance => 'Maintenance';

  @override
  String get fault_historyStatusFault => 'Fault';

  @override
  String get fault_historyActiveBadge => 'Active';

  @override
  String fault_activeFaultBanner(String label) {
    return 'This cell has an active $label record. Confirming will close this record.';
  }

  @override
  String get fault_reportFaultButton => 'Report Fault';

  @override
  String get fault_closeFaultButton => 'Close Record';

  @override
  String get fault_recordCreatedSuccess => 'Fault record created.';

  @override
  String get fault_recordClosedSuccess => 'Fault record closed.';

  @override
  String get cabin_mobileTypeLabel => 'MOBILE';

  @override
  String get cabin_mobileDrawerTitle => 'Mobile Drawer';

  @override
  String cabin_cellCountLabel(int count) {
    return '$count cells';
  }

  @override
  String get cabin_drawerStatsLabel => 'Drawers';

  @override
  String cabin_statsFullEmpty(int full, int empty) {
    return '$full full · $empty empty';
  }

  @override
  String get cabin_touchDrawerHint => 'Tap a drawer';

  @override
  String get cabin_mobileGridPlaceholder =>
      'Mobile cabinet cell grid will be displayed';

  @override
  String get cabin_masterGridPlaceholder =>
      'Cubic · Unit Dose · Serum internal structures will be displayed';

  @override
  String get cabin_kubikTypeLabel => 'CUBIC';

  @override
  String get cabin_serumDrawerName => 'Serum Drawer';

  @override
  String get cabin_kubikDrawerName => 'Cubic Drawer';

  @override
  String get cabin_unitDoseDrawerName => 'Unit Dose Drawer';

  @override
  String get cabin_serumRackView => 'Rack view';

  @override
  String get cabin_serumViewTitle => 'Serum view';

  @override
  String get cabin_serumViewTodo =>
      'TODO: Will be completed when serum internal structure is finalized';

  @override
  String get cabin_openButton => 'Open';

  @override
  String get cabin_assignDrugButton => 'Assign Drug';

  @override
  String get cabin_bannerPatientAssign =>
      'Patient Assignment — assign a patient / admission to cells.';

  @override
  String get cabin_bannerDrugAssign =>
      'Drug Assignment — assign drugs to cells, set min/max/critical values.';

  @override
  String get cabin_bannerDrugFill =>
      'Drug Filling — tap the cell to fill, enter the quantity.';

  @override
  String get cabin_bannerDrugCount =>
      'Stock Count — enter the actual quantity, the system will calculate the difference.';

  @override
  String get cabin_bannerFault =>
      'Fault — mark the faulty cell and enter a description.';

  @override
  String get cabin_statusWorking => 'Operational';

  @override
  String get cabin_statusFaultRecord => 'Fault Record';

  @override
  String get cabin_statusMaintenanceRecord => 'Maintenance Record';

  @override
  String get cabin_modeAssignLabel => 'Drug Assignment';

  @override
  String get cabin_modeFillLabel => 'Drug Filling';

  @override
  String get cabin_modeCountLabel => 'Drug Count';

  @override
  String get cabin_modeFaultLabel => 'Drawer Fault';

  @override
  String get cabin_operationPanelAssign => 'DRUG ASSIGNMENT';

  @override
  String get cabin_operationPanelFill => 'DRUG FILLING';

  @override
  String get cabin_operationPanelCount => 'DRUG COUNT';

  @override
  String get cabin_operationPanelFault => 'REPORT FAULT';

  @override
  String get cabin_legendAssignEmpty => 'Empty cell (assign)';

  @override
  String get cabin_legendAssignAssigned => 'Drug assigned';

  @override
  String get cabin_legendAssignFault => 'Faulty';

  @override
  String get cabin_legendAssignMaintenance => 'Under maintenance';

  @override
  String get cabin_legendPatientAssigned => 'Patient assigned';

  @override
  String get cabin_legendFilled => 'Filled';

  @override
  String get cabin_legendFillEmpty => 'Empty (no fill needed)';

  @override
  String get cabin_legendCountAssigned => 'To count (has drug)';

  @override
  String get cabin_legendCountLow => 'Low stock';

  @override
  String get cabin_legendCountEmpty => 'Empty (skip)';

  @override
  String get cabin_legendFaultNormal => 'Operating normally';

  @override
  String get cabin_legendFaultReported => 'Fault reported';

  @override
  String get cabin_legendFaultEmpty => 'Empty cell';

  @override
  String get wizard_sidebarTitle => 'Cabinet Setup';

  @override
  String get wizard_sidebarSubtitle => 'New device configuration';

  @override
  String get wizard_step1SidebarTitle => 'Cabinet Type';

  @override
  String get wizard_step1SidebarDesc => 'Standard or Mobile';

  @override
  String get wizard_step2SidebarTitle => 'Basic Information';

  @override
  String get wizard_step2SidebarDesc => 'Name, location, connection';

  @override
  String get wizard_step3SidebarTitle => 'Service Scope';

  @override
  String get wizard_step3SidebarDesc => 'Ward or room definitions';

  @override
  String get wizard_step4SidebarTitle => 'Drawer Structure';

  @override
  String get wizard_step4SidebarDesc => 'Scan or manual entry';

  @override
  String get wizard_step5SidebarTitle => 'Summary';

  @override
  String get wizard_step5SidebarDesc => 'Review and complete';

  @override
  String get wizard_step1Header => 'Select Cabinet Type';

  @override
  String get wizard_step1Subtitle =>
      'Specify the type of cabinet you want to manage. This choice will shape the subsequent steps.';

  @override
  String get wizard_cabinTypeNote => 'Cabinet type cannot be changed later.';

  @override
  String get wizard_masterCabinSpec1 => 'Cubic / Unit Dose';

  @override
  String get wizard_masterCabinSpec2 => 'Ward-Based';

  @override
  String get wizard_masterCabinDescription =>
      'Wall-mounted or freestanding cabinet with a combination of cubic and unit-dose drawers.';

  @override
  String get wizard_mobileCabinSpec1 => 'On Wheels';

  @override
  String get wizard_mobileCabinSpec2 => 'Room-Based';

  @override
  String get wizard_mobileCabinDescription =>
      'Wheeled, portable 4-row medication unit designed for ward rounds.';

  @override
  String get wizard_step2Header => 'Basic Information';

  @override
  String get wizard_step2Subtitle =>
      'Enter the cabinet name, location, and device connection settings.';

  @override
  String get wizard_cabinNameLabel => 'Cabinet Name';

  @override
  String get wizard_cabinNameHint => 'e.g. CB-304';

  @override
  String get wizard_connectionSettingsLabel => 'CONNECTION SETTINGS';

  @override
  String get wizard_noComPortWarning =>
      'No active COM Port found. Make sure the drivers are installed.';

  @override
  String get wizard_antennaSettingsLabel => 'ANTENNA SETTINGS';

  @override
  String get wizard_ipAddressLabel => 'IP Address';

  @override
  String get wizard_testConnectionButton => 'Test Connection';

  @override
  String get wizard_step3Header => 'Service Scope';

  @override
  String get wizard_step3Subtitle => 'Ward or room definitions.';

  @override
  String get wizard_roomBedSelectionLabel => 'ROOM & BED SELECTION';

  @override
  String get wizard_scanTitle => 'Scan Device';

  @override
  String get wizard_scanDescription =>
      'The drawer structure of the connected cabinet will be read automatically via the serial port.';

  @override
  String get wizard_startScanButton => 'Start Scan';

  @override
  String get wizard_scanningStatus => 'Scanning Cabinet..';

  @override
  String wizard_scanSuccessBanner(int count) {
    return 'Scan Successful — $count drawers found';
  }

  @override
  String get wizard_scanSuccessDescription =>
      'The cabinet\'s internal layout was read from the device successfully. Confirm the structure below.';

  @override
  String get wizard_scanWrongStructure =>
      'If the structure is incorrect, go back and check the connection details.';

  @override
  String get wizard_rescanButton => 'Re-Scan';

  @override
  String get wizard_scanErrorBanner =>
      'Scan failed. Check the COM port connection and try again.';

  @override
  String get wizard_scanLogConnecting => 'Connecting to serial port…';

  @override
  String get wizard_scanLogFetchingMetadata => 'Loading drawer definitions…';

  @override
  String get wizard_scanLogSearchingManager => 'Searching for management card…';

  @override
  String get wizard_scanLogScanningCards => 'Scanning control cards…';

  @override
  String get wizard_scanLogDrawerFound => 'Drawer found';

  @override
  String wizard_drawerLabel(int index) {
    return 'DRAWER $index';
  }

  @override
  String wizard_cellCountLabel(int count) {
    return '$count cells';
  }

  @override
  String wizard_rowCountLabel(int count) {
    return '$count rows';
  }

  @override
  String get wizard_drawerCountLabel => 'Drawer Count';

  @override
  String get wizard_addRowButton => 'Add Row';

  @override
  String get wizard_removeLastRowButton => 'Remove Last Row';

  @override
  String get wizard_step5Header => 'Summary & Complete';

  @override
  String get wizard_step5Subtitle =>
      'Confirm the information you have entered. The setup will be completed after confirmation.';

  @override
  String get wizard_summaryCabinInfoTitle => 'CABINET INFORMATION';

  @override
  String get wizard_summaryServiceScopeTitle => 'SERVICE SCOPE';

  @override
  String get wizard_summaryDrawerStructureTitle => 'DRAWER STRUCTURE';

  @override
  String get wizard_summaryCabinPreviewTitle => 'CABINET PREVIEW';

  @override
  String get wizard_summaryLabelType => 'Type';

  @override
  String get wizard_summaryLabelName => 'Name';

  @override
  String get wizard_summaryLabelStation => 'Station';

  @override
  String get wizard_summaryLabelRoomCount => 'Room count';

  @override
  String get wizard_summaryLabelRooms => 'Rooms';

  @override
  String get wizard_summaryLabelBeds => 'Beds';

  @override
  String get wizard_summaryLabelDrawerCount => 'Drawer count';

  @override
  String get wizard_summaryLabelTotalDrawers => 'Total drawers';

  @override
  String wizard_summaryLabelDrawerIndexed(int index) {
    return 'Drawer $index';
  }

  @override
  String get wizard_summaryTypeMobile => 'Mobile Cabinet';

  @override
  String get wizard_summaryTypeStandard => 'Standard Cabinet';

  @override
  String get wizard_summaryLabelComPort => 'COM Port';

  @override
  String get wizard_summaryLabelDvrIp => 'DVR IP';

  @override
  String get wizard_summaryLabelRfidAddress => 'RFID Address';

  @override
  String get wizard_summaryLabelRfidPort => 'RFID Port';

  @override
  String get wizard_savingMessage => 'Saving cabinet…';

  @override
  String get wizard_successTitle => 'Setup Complete!';

  @override
  String wizard_successMessage(String cabinName) {
    return '$cabinName has been successfully added to the system.';
  }

  @override
  String wizard_successCabinId(int id) {
    return 'Cabinet ID: #$id';
  }

  @override
  String get wizard_successDashboardButton => 'Go to Dashboard';

  @override
  String get wizard_errorTitle => 'Save Failed';

  @override
  String get wizard_retryButton => 'Go Back and Retry';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_systemConfigTitle => 'SYSTEM CONFIGURATION';

  @override
  String get settings_appearanceLabel => 'Appearance';

  @override
  String get settings_generalLabel => 'General';

  @override
  String get assignment_patientUpdatedSuccess =>
      'Patient assignment updated successfully';

  @override
  String get fault_selectSlotPlaceholder =>
      'Select a drawer from the\nleft panel to report a fault.';

  @override
  String get assignment_bedSectionLabel => 'Bed Selection';

  @override
  String get assignment_serviceSelectorHint => 'Select a service';

  @override
  String get assignment_roomSelectorHint => 'Select a room';

  @override
  String get assignment_bedSelectorHint => 'Select a bed';

  @override
  String get assignment_patientLabel => 'PATIENT';
}
