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
  String get dashboard_treatmentsLoadError =>
      'Upcoming treatments could not be loaded';

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
  String get wizard_successReloginPrompt => 'You must log in to continue.';

  @override
  String get wizard_successLoginButton => 'Log In';

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

  @override
  String get settings_languageTitle => 'LANGUAGE';

  @override
  String get settings_languageSubtitle => 'Interface language';

  @override
  String get emptyStateCabinDataTitle => 'Cabinet data not found';

  @override
  String get emptyStateCabinDataDescription =>
      'The cabinet may not be configured yet\nor connection could not be established.';

  @override
  String get emptyStateNoResultsTitle => 'No results found';

  @override
  String get emptyStateNoResultsDescription =>
      'Try changing your search criteria.';

  @override
  String get emptyStateNoCellSelectedTitle => 'No cell selected';

  @override
  String get emptyStateNoCellSelectedDescription =>
      'Select a cell to start filling.';

  @override
  String get emptyStateNoPatientTitle => 'No patient assigned';

  @override
  String get emptyStateNoPatientDescription =>
      'No patient has been assigned to this cell yet.';

  @override
  String get emptyStateNoPrescriptionTitle => 'No prescription found';

  @override
  String get emptyStateNoPrescriptionDescription =>
      'There are no active prescriptions for this patient.';

  @override
  String get emptyStateNoCabinTitle => 'No Cabinet Found';

  @override
  String get emptyStateNoCabinDescription =>
      'No cabinet has been defined yet. Please define a cabinet to continue.';

  @override
  String get emptyStateNetworkErrorTitle => 'No Internet Connection';

  @override
  String get emptyStateNetworkErrorDescription =>
      'Please check your network connection and try again.';

  @override
  String get emptyStateServerErrorTitle => 'Server Unreachable';

  @override
  String get emptyStateServerErrorDescription =>
      'The server could not be reached. Please try again later.';

  @override
  String get emptyStateErrorTitle => 'Something Went Wrong';

  @override
  String get emptyStateErrorDescription =>
      'An unexpected error occurred. Please try again or contact your system administrator.';

  @override
  String get emptyStateNoDataTitle => 'No Data';

  @override
  String get emptyStateNoDataDescription => 'There is no data to display yet.';

  @override
  String get refundNoRefundableDrugs =>
      'No refundable medications found for this patient.';

  @override
  String get refundSelectPatient =>
      'Select a patient from the list on the left to start a refund.';

  @override
  String get wasteNoWastableDrugs => 'No disposable drugs found.';

  @override
  String get wasteSelectPatient => 'Select a patient to proceed.';

  @override
  String get common_confirmCancelButton => 'Cancel';

  @override
  String get common_dismissButton => 'Dismiss';

  @override
  String get common_action_saving => 'Saving';

  @override
  String get common_action_drawerOpening => 'Opening drawer';

  @override
  String get common_action_connecting => 'Connecting';

  @override
  String get common_action_processing => 'Processing...';

  @override
  String get common_cancelInfo_drawerClose =>
      'To cancel the operation, close the drawer.';

  @override
  String get common_patientListTitle => 'Patient List';

  @override
  String common_patientCountSubtitle(int count) {
    return 'Total $count patients';
  }

  @override
  String get assignment_error_stationLoadFailed =>
      'Could not load cabin station information';

  @override
  String get cabinStock_panel_title =>
      'Medications in Cabin Assigned to Patient';

  @override
  String get census_cancelDialog_title => 'Cancel Census';

  @override
  String get census_cancelDialog_message => 'Cancel the census operation?';

  @override
  String get census_action_start => 'Start census';

  @override
  String get census_action_drawerOpen => 'Count medications';

  @override
  String get census_action_complete => 'Complete census';

  @override
  String get census_action_continue => 'Continue census';

  @override
  String get census_success_completed => 'Census completed successfully.';

  @override
  String get drugActivity_column_date => 'Date';

  @override
  String get drugActivity_column_time => 'Time';

  @override
  String get drugActivity_column_patient => 'Patient';

  @override
  String get drugActivity_column_user => 'User';

  @override
  String get drugActivity_column_material => 'Material';

  @override
  String get drugActivity_column_quantity => 'Quantity';

  @override
  String get drugActivity_column_movement => 'Movement';

  @override
  String get intake_cancelDialog_title => 'Cancel Intake';

  @override
  String get intake_cancelDialog_message =>
      'No medication taken yet. Cancel the intake?';

  @override
  String get intake_action_start => 'Start intake';

  @override
  String get intake_action_drawerOpen => 'Take medications';

  @override
  String get intake_action_complete => 'Complete intake';

  @override
  String get intake_action_continue => 'Continue intake';

  @override
  String get intake_success_completed => 'Intake completed successfully.';

  @override
  String get intake_action_reportMissingStock => 'Report Missing Stock';

  @override
  String get myPatients_search_hint => 'Search patient, room, service...';

  @override
  String get refill_cancelDialog_title => 'Cancel Refill';

  @override
  String get refill_cancelDialog_message =>
      'Medications will be assumed removed from the drawer. Cancel the refill?';

  @override
  String get refill_action_start => 'Start refill';

  @override
  String get refill_action_placeDrugs => 'Place medications';

  @override
  String get refill_action_complete => 'Complete refill';

  @override
  String get refill_action_continue => 'Continue refill';

  @override
  String get refill_success_completedMobile => 'Refill completed successfully.';

  @override
  String get refill_success_completedMaster => 'Refill completed successfully';

  @override
  String get refill_hint_selectDrawer =>
      'Select a drawer from the left panel to start refilling.';

  @override
  String get refill_hint_selectCell => 'Select a cell from the drawer.';

  @override
  String get refill_hint_cellError => 'Select a cell.';

  @override
  String get refill_label_countQty => 'Count';

  @override
  String get refill_label_fillQty => 'Fill quantity';

  @override
  String get refill_label_expiryDate => 'Expiry';

  @override
  String get refill_title_selectMedicines => 'Select medicines to refill';

  @override
  String get refill_title_autoRefill => 'Auto refill';

  @override
  String refill_label_selectedCount(int count) {
    return '$count selected';
  }

  @override
  String refill_label_cellCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cells',
      one: '$count cell',
    );
    return '$_temp0';
  }

  @override
  String refill_label_multiMedicine(int count) {
    return '$count medicines';
  }

  @override
  String get refill_label_targetCells => 'Cells to refill';

  @override
  String refill_label_queueProgress(int done, int total) {
    return '$done / $total drawers';
  }

  @override
  String refill_label_current(String qty) {
    return 'Current: $qty';
  }

  @override
  String refill_chip_drawer(String address) {
    return 'Drawer $address';
  }

  @override
  String refill_chip_drawerCell(String address, String cell) {
    return 'Drawer $address - Cell $cell';
  }

  @override
  String refill_subtitle_kubikCells(String address, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cells',
      one: '$count cell',
    );
    return 'Drawer $address · $_temp0';
  }

  @override
  String get refill_status_done => 'Done';

  @override
  String get refill_status_open => 'Open';

  @override
  String get refill_status_queued => 'Queued';

  @override
  String get refill_status_drawerOpen => 'Drawer open';

  @override
  String get refill_status_drawerOpening => 'Opening drawer';

  @override
  String get refill_hint_searchMedicine => 'Search medicine…';

  @override
  String get refill_hint_noMedicines => 'No medicines assigned to this cabinet';

  @override
  String get refill_hint_autoQueueOrder =>
      'Selected drawers open one by one; the next opens once the current is closed.';

  @override
  String get refill_hint_confirmCloses =>
      'Saving will close the drawer and open the next one.';

  @override
  String get refill_action_startAuto => 'Start auto refill';

  @override
  String get refill_action_completeFilling => 'Complete refill';

  @override
  String get refill_action_stop => 'Stop';

  @override
  String get refill_label_min => 'Min';

  @override
  String get refill_label_critical => 'Critical';

  @override
  String get refill_label_max => 'Max';

  @override
  String get refill_error_queueTitle => 'Operation could not be completed';

  @override
  String get refill_error_queueMessage =>
      'This drawer’s refill could not be saved. Please take back the medicines you placed.';

  @override
  String get refill_error_continueNext => 'Next drawer';

  @override
  String get refill_error_endProcess => 'End process';

  @override
  String get refill_status_failed => 'Failed';

  @override
  String refill_label_cellProgress(int current, int total) {
    return 'Cell $current/$total';
  }

  @override
  String refill_label_cellNo(int no) {
    return 'Cell $no';
  }

  @override
  String get refill_action_nextCell => 'Next cell';

  @override
  String get refill_hint_nextCellOpens =>
      'Saving closes this cell and opens the next one.';

  @override
  String get refill_hint_selectionLocked =>
      'Refill in progress — selection locked.';

  @override
  String get refill_hint_idleExecution =>
      'Select medicines on the left to start refilling.';

  @override
  String get refund_success_title => 'Refund successful';

  @override
  String get refund_success_message =>
      'Please deliver the refunded medication to the pharmacist.';

  @override
  String get refund_panel_title => 'Refundable Medications';

  @override
  String get refund_action_checking => 'Checking...';

  @override
  String get refund_action_refunding => 'Refunding...';

  @override
  String get refund_action_refund => 'Refund';

  @override
  String get unappliedPrescription_panel_patientTitle => 'Patients';

  @override
  String get unload_cancelDialog_title => 'Cancel Unload';

  @override
  String get unload_cancelDialog_message =>
      'No medication removed yet. Cancel the unload?';

  @override
  String get unload_action_start => 'Start unload';

  @override
  String get unload_action_drawerOpen => 'Remove medications';

  @override
  String get unload_action_complete => 'Complete unload';

  @override
  String get unload_action_continue => 'Continue unload';

  @override
  String get unload_success_completed => 'Unload completed successfully.';

  @override
  String get waste_panel_title => 'Wasteable/Destructible Medications';

  @override
  String get waste_action_wastage => 'Waste';

  @override
  String get waste_action_destruction => 'Destroy';

  @override
  String get wastage_success_title => 'Wastage recorded';

  @override
  String get wastage_success_message =>
      'Please place the wasted medication in the wastage bin.';

  @override
  String get destruction_success_title => 'Destruction recorded';

  @override
  String get destruction_success_message =>
      'Please dispose of the medication in accordance with the destruction procedure.';

  @override
  String get assignment_success_created => 'Bed assignment saved successfully.';

  @override
  String get assignment_success_deleted => 'Bed assignment removed.';

  @override
  String get cabin_bannerCensus =>
      'After the drawer opens, select the medications in the cabinet and complete the count. Medications with status \"Pending Intake\" can be counted; unselected medications are assumed to have a quantity of 0.';

  @override
  String get cabin_bannerIntake => 'Drug Intake';

  @override
  String get cabin_bannerUnload => 'Drug Unload';

  @override
  String get operationPanel_title_assign => 'DRUG ASSIGNMENT';

  @override
  String get operationPanel_badge_assign => 'ASSIGN';

  @override
  String get operationPanel_title_refill => 'DRUG REFILL';

  @override
  String get operationPanel_badge_refill => 'REFILL';

  @override
  String get operationPanel_title_census => 'DRUG COUNT';

  @override
  String get operationPanel_badge_census => 'COUNT';

  @override
  String get operationPanel_title_fault => 'REPORT FAULT';

  @override
  String get operationPanel_badge_fault => 'FAULT';

  @override
  String get operationPanel_title_intake => 'DRUG INTAKE';

  @override
  String get operationPanel_badge_intake => 'INTAKE';

  @override
  String get operationPanel_title_unload => 'DRUG UNLOAD';

  @override
  String get operationPanel_badge_unload => 'UNLOAD';

  @override
  String get drugAssignment_panel_title => 'Select Drug';

  @override
  String get session_timeout_warning => 'Your session is about to expire.';

  @override
  String get session_timeout_continueButton => 'Continue';

  @override
  String get session_timeout_prefix => 'Your session will close in ';

  @override
  String get session_timeout_suffix => ' seconds.';

  @override
  String get session_locked_prefix => 'Your session ';

  @override
  String get session_locked_reason => 'timed out';

  @override
  String get session_locked_suffix =>
      ' and was closed. Please log in to continue.';

  @override
  String get movement_noHistory => 'No movement history found.';

  @override
  String get movement_performedBy => 'Performed by';

  @override
  String get common_search_noPatientResults => 'No patients match your search.';

  @override
  String get common_drug_noFilterResults => 'No medications match this filter.';

  @override
  String get common_unknownName => 'Unknown';

  @override
  String get rfidStatus_read => 'Read';

  @override
  String get rfidStatus_waiting => 'Waiting';

  @override
  String get rfidStatus_inCabin => 'In cabinet';

  @override
  String get rfidStatus_notInCabin => 'Not in cabinet';

  @override
  String get rfidStatus_taken => 'Taken';

  @override
  String get rfidStatus_missing => 'Missing';

  @override
  String get drawerStatus_full => 'Full';

  @override
  String get drawerStatus_low => 'Low';

  @override
  String get drawerStatus_critical => 'Critical';

  @override
  String get drawerStatus_empty => 'Empty';

  @override
  String cabin_cellCount(Object count) {
    return '$count cells';
  }

  @override
  String cabin_drawerStats(Object columns, Object rowCount, Object totalCells) {
    return '$rowCount rows · $totalCells cells · $columns columns';
  }

  @override
  String hospitalization_admissionDate(Object date) {
    return 'Admission Date | $date';
  }

  @override
  String get movement_dateLabel => 'Date';

  @override
  String get movement_quantityLabel => 'Quantity';

  @override
  String get movement_showAll => 'Show All Movements';

  @override
  String cabin_masterDrawerStats(Object groupCount, Object mult, Object steps) {
    return '$groupCount groups · $steps steps × $mult';
  }

  @override
  String get dashboard_cabinConnectionStatus_connected => 'Connected';

  @override
  String get dashboard_cabinConnectionStatus_connecting => 'Connecting…';

  @override
  String get dashboard_cabinConnectionStatus_error => 'No Connection';

  @override
  String get dashboard_cabinConnectionStatus_disconnected => 'Disconnected';

  @override
  String get dashboard_cabinConnection_reconnectButton => 'Reconnect';

  @override
  String get prescription_noPatients_title => 'No Assigned Patients';

  @override
  String get prescription_noPatients_message =>
      'No patients have been assigned to this cabinet yet. Patients must be assigned before prescriptions can be reviewed.';

  @override
  String get myPatients_empty_title => 'No Patients Selected Yet';

  @override
  String get myPatients_empty_description =>
      'Select patients from the list on the left to add them to your patient list. Your selected patients will appear here.';

  @override
  String get cabin_stock_empty_title => 'No stock for this patient';

  @override
  String get cabin_stock_empty_description =>
      'This patient has no medications stocked in this cabin yet.';

  @override
  String get unadministered_prescriptions_empty_title =>
      'No pending prescriptions';

  @override
  String get unadministered_prescriptions_empty_description =>
      'There are no prescriptions waiting to be administered for this patient.';

  @override
  String get empty_state_no_patient_selected_title => 'Select a patient';

  @override
  String get empty_state_no_patient_selected_description =>
      'Choose a patient from the list to view their details.';

  @override
  String get date_preset_today => 'Today';

  @override
  String get date_preset_last_3_days => 'Last 3 days';

  @override
  String get date_preset_last_7_days => 'Last 7 days';

  @override
  String get date_preset_all => 'All';

  @override
  String get filter_all => 'All';

  @override
  String get census_action_report_extra_stock => 'Report Extra Stock';

  @override
  String get census_extra_stock_dialog_title => 'Report Extra Stock';

  @override
  String get census_extra_stock_quantity_label => 'Quantity';

  @override
  String get common_action_add => 'Add';

  @override
  String get census_extra_stock_summary_title => 'Reported Extra Stocks';

  @override
  String get core_serialPortDisconnectedLabel => 'Not Connected';

  @override
  String core_serialConnectingStatus(String portName) {
    return 'Connecting to port: $portName...';
  }

  @override
  String core_serialConnectSuccessStatus(String portName) {
    return 'Connected successfully: $portName';
  }

  @override
  String core_serialPortFailedScanningOthersStatus(String portName) {
    return '$portName failed. Scanning other ports...';
  }

  @override
  String core_serialNoOtherPortsError(String portName) {
    return 'The default port ($portName) failed and no other port was found.';
  }

  @override
  String core_serialTryingPortStatus(String portName) {
    return 'Trying: $portName...';
  }

  @override
  String core_serialConnectionEstablishedStatus(String portName) {
    return 'Connection established: $portName';
  }

  @override
  String get core_serialNoPortConnectedError =>
      'Could not connect to any port. Check the cables.';

  @override
  String core_serialPortOpenFailedError(String portName) {
    return 'The port could not be opened ($portName).';
  }

  @override
  String get core_serialNoConnectionError => 'No connection.';

  @override
  String get core_serialPortBusyTimeoutError => 'Port timed out.';

  @override
  String get core_serialWriteFailedError => 'Write failed.';

  @override
  String get common_defaultSuccessMessage => 'Operation successful';

  @override
  String get common_operationSuccessMessage =>
      'Your operation was completed successfully.';

  @override
  String get common_loadingEllipsis => 'Loading...';

  @override
  String get common_searchHint => 'Search...';

  @override
  String get common_searchTooltip => 'Search';

  @override
  String get common_addTooltip => 'Add';

  @override
  String get common_closeTooltip => 'Close';

  @override
  String get common_saveButton => 'Save';

  @override
  String get common_editTooltip => 'Edit';

  @override
  String get common_deleteTooltip => 'Delete';

  @override
  String get common_statusLabel => 'Status';

  @override
  String get common_emptyListMessage => 'The list is currently empty';

  @override
  String get common_nameLabel => 'Name';

  @override
  String get common_requiredFieldsError =>
      'Please fill in the required fields.';

  @override
  String get common_descriptionLabel => 'Description';

  @override
  String get common_deselectAllButton => 'Deselect All';

  @override
  String get common_selectAllButton => 'Select All';

  @override
  String get common_defaultUnitFallback => 'Piece';

  @override
  String get common_flagFirstDoseEmergency => 'First Dose Emergency';

  @override
  String get common_flagAskDoctor => 'Ask Doctor';

  @override
  String get common_flagInCaseOfNecessity => 'As Needed';

  @override
  String common_addItemHint(String item) {
    return 'Tap the \"+\" button to add a new $item';
  }

  @override
  String get common_genericErrorMessage => 'An error occurred.';

  @override
  String get hospitalizationCard_noDoctorFallback => 'No Doctor Specified';

  @override
  String get hospitalizationCard_nationalIdLabel => 'National ID No.';

  @override
  String get hospitalizationCard_admissionDateLabel => 'Admission Date';

  @override
  String get menuBrowser_categoriesHeader => 'CATEGORIES';

  @override
  String get menuBrowser_searchHint => 'Search category...';

  @override
  String menuBrowser_selectionCountBadge(int selected, int total) {
    return '$selected/$total';
  }

  @override
  String get menuBrowser_emptyCategoryMessage =>
      'No menu found in this category';

  @override
  String rxGroup_headerTitle(Object id) {
    return 'Prescription #$id';
  }

  @override
  String rxGroup_headerSubtitle(String doctorName, String date) {
    return '$doctorName · $date';
  }

  @override
  String rxGroup_itemCountBadge(int count) {
    return '$count items';
  }

  @override
  String rxGroup_selectableCountLabel(int count) {
    return '$count actionable items';
  }

  @override
  String get rxGroup_unknownDoctorFallback => 'Unknown';

  @override
  String get rxGroup_rfidTagLabel => 'RFID TAG';

  @override
  String get rxGroup_rfidTagLoadingLabel => 'Waiting for tag...';

  @override
  String get rxGroup_rfidTagUnassignedLabel => 'No tag assigned yet';

  @override
  String get rxGroup_rfidChangeButton => 'Change';

  @override
  String get rxGroup_rfidAssignButton => 'Assign Tag';

  @override
  String rxGroup_selectedCountBar(int count) {
    return '$count items selected';
  }

  @override
  String get rxGroup_approveAction => 'Approve';

  @override
  String get rxGroup_rejectAction => 'Reject';

  @override
  String get changePassword_dialogTitle => 'Change Password';

  @override
  String get changePassword_currentPasswordLabel => 'Current Password';

  @override
  String get changePassword_newPasswordLabel => 'New Password';

  @override
  String get changePassword_confirmPasswordLabel => 'Confirm New Password';

  @override
  String get changePassword_submitButton => 'Change Password';

  @override
  String get home_appBarBadgeLabel => 'MANAGEMENT PANEL';

  @override
  String get home_devSettingsTooltip => 'Developer Settings';

  @override
  String get home_noAuthorizedMenuTitle => 'No Authorized Menu Found';

  @override
  String get home_noAuthorizedMenuDescription =>
      'Your account has no access permissions defined.\nPlease contact your system administrator to obtain access.';

  @override
  String get branch_listDialogTitle => 'Branch Definition';

  @override
  String get branch_addTitle => 'Add Branch';

  @override
  String get branch_editTitle => 'Edit Branch';

  @override
  String get branch_nameLabel => 'Branch Name';

  @override
  String get firm_createSuccessMessage => 'Firm created successfully';

  @override
  String get firm_updateSuccessMessage => 'Firm updated successfully';

  @override
  String get firm_createPanelTitle => 'New Firm';

  @override
  String get firm_editPanelTitle => 'Edit Firm';

  @override
  String get firm_createPanelSubtitle => 'Fill in the firm details';

  @override
  String get firm_editPanelSubtitle => 'Update the firm details';

  @override
  String get firm_nameLabel => 'Firm Name';

  @override
  String get firm_taxNoLabel => 'Tax No.';

  @override
  String get firm_taxOfficeLabel => 'Tax Office';

  @override
  String get firm_typeLabel => 'Firm Type';

  @override
  String get firm_screenDefaultTitle => 'Firm Definition';

  @override
  String get dosageForm_deleteSuccessMessage =>
      'The dosage form was deleted successfully.';

  @override
  String get dosageForm_saveSuccessMessage =>
      'The dosage form was saved successfully.';

  @override
  String get dosageForm_createTitle => 'Create Dosage Form';

  @override
  String get dosageForm_editTitle => 'Edit Dosage Form';

  @override
  String get dosageForm_listDialogTitle => 'Dosage Form';

  @override
  String get dosageForm_emptyTitle => 'No dosage forms yet';

  @override
  String get dosageForm_emptyDescription =>
      'Tap the \"+\" button to create a dosage form';

  @override
  String get authorization_userTabTitle => 'User Authorization';

  @override
  String get authorization_roleTabTitle => 'Role Authorization';

  @override
  String get authorization_screenTitleFallback => 'User/Role Authorization';

  @override
  String authorization_rolePanelTitle(String roleName) {
    return 'Role Authorization - $roleName';
  }

  @override
  String get authorization_tabMenuLabel => 'Menu';

  @override
  String get authorization_tabDrugLabel => 'Drug';

  @override
  String get authorization_tabConsumableLabel => 'Medical Consumable';

  @override
  String get authorization_drugTable_pullColumn => 'Pull Drug';

  @override
  String get authorization_drugTable_fillColumn => 'Refill';

  @override
  String get authorization_drugTable_returnColumn => 'Return';

  @override
  String get authorization_drugTable_disposeColumn => 'Dispose';

  @override
  String get authorization_drugTable_allDrugsRow => 'All Drugs';

  @override
  String get authorization_drugTable_unknownDrugFallback => 'Unknown Drug';

  @override
  String get settings_updateSuccessMessage => 'Settings updated successfully.';

  @override
  String get settingsCabin_drawerOpenWaitLabel =>
      'Drawer Open Wait Time (seconds)';

  @override
  String get settingsCabin_drawerOpenWaitDescription =>
      'Specifies when the system will send a close command to the drawer if it is left open.';

  @override
  String get settingsDeveloper_adminDashboardActiveLabel =>
      'Admin Dashboard Active';

  @override
  String get settingsDeveloper_appModeLabel => 'Application Mode';

  @override
  String get settingsDeveloper_clientModeButton => 'Client Mode';

  @override
  String get settingsDeveloper_managerModeButton => 'Manager Mode';

  @override
  String get settingsGeneral_autoStandbyDurationLabel =>
      'Auto-Standby Duration (seconds)';

  @override
  String get settingsGeneral_expiryWarningLabel => 'Expiry Warning';

  @override
  String get settingsGeneral_hbysStockControlLabel => 'HIS Stock Control';

  @override
  String get settingsGeneral_fingerprintOnlyLabel =>
      'Only allow fingerprint reader use on cabinets.';

  @override
  String get settingsGeneral_allowOutOfWindowOrdersLabel =>
      'Orders outside the time window may be accepted.';

  @override
  String get settingsGeneral_perCellExpiryDateLabel =>
      'Allow entering a separate expiry date for each compartment in unit-dose drawers during drug refill.';

  @override
  String get settingsPrescription_accessDurationLabel =>
      'Prescription Access Duration (minutes)';

  @override
  String get settingsPrescription_accessDurationDescription =>
      'Specifies how long before and after product pickup times prescriptions remain accessible.';

  @override
  String get settingsView_cabinTabTitle => 'Cabinet Communication Settings';

  @override
  String get settingsView_prescriptionTabTitle => 'Prescription Settings';

  @override
  String get settingsView_generalTabTitle => 'General Settings';

  @override
  String get settingsView_developerTabTitle => 'Developer Settings';

  @override
  String get settingsView_refreshPermissionsButton => 'Refresh Permissions';

  @override
  String stationSetup_defaultRoomName(int index) {
    return 'Room $index';
  }

  @override
  String get stationSetup_service_createdSuccessMessage =>
      'Service created successfully';

  @override
  String get stationSetup_service_updatedSuccessMessage =>
      'Service updated successfully';

  @override
  String get stationSetup_roomsSectionTitle => 'Rooms & Beds';

  @override
  String stationSetup_roomsBedsSummary(int roomCount, int bedCount) {
    return '$roomCount rooms · $bedCount beds';
  }

  @override
  String get stationSetup_addRoomButton => 'Add Room';

  @override
  String stationSetup_bedCountBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count beds',
      one: '$count bed',
    );
    return '$_temp0';
  }

  @override
  String get stationSetup_noBedsAddedYetMessage => 'No beds added yet';

  @override
  String get stationSetup_addBedButton => 'Add Bed';

  @override
  String get stationSetup_service_formTitleNew => 'New Service';

  @override
  String get stationSetup_service_formTitleEdit => 'Edit Service';

  @override
  String get stationSetup_service_formSubtitleNew =>
      'Fill in the service details';

  @override
  String get stationSetup_service_formSubtitleEdit =>
      'Update the service details';

  @override
  String get stationSetup_service_nameLabel => 'Service Name';

  @override
  String get stationSetup_service_branchLabel => 'Branch';

  @override
  String get stationSetup_service_branchSelectTitle => 'Select Branch';

  @override
  String get stationSetup_service_userLabel => 'User';

  @override
  String get stationSetup_common_statusLabel => 'Status';

  @override
  String get stationSetup_station_createdSuccessMessage =>
      'Station created successfully';

  @override
  String get stationSetup_station_updatedSuccessMessage =>
      'Station updated successfully';

  @override
  String get stationSetup_station_formTitleNew => 'New Station';

  @override
  String get stationSetup_station_formTitleEdit => 'Edit Station';

  @override
  String get stationSetup_station_formSubtitleNew =>
      'Fill in the station details';

  @override
  String get stationSetup_station_formSubtitleEdit =>
      'Update the station details';

  @override
  String get stationSetup_station_nameLabel => 'Station Name';

  @override
  String get stationSetup_station_drugWarehouseLabel => 'Drug Warehouse';

  @override
  String get stationSetup_station_drugWarehouseSelectTitle =>
      'Select Drug Warehouse';

  @override
  String get stationSetup_station_drugStatusLabel => 'Drug Status';

  @override
  String get stationSetup_station_consumableWarehouseLabel =>
      'Medical Consumable Warehouse';

  @override
  String get stationSetup_station_consumableWarehouseSelectTitle =>
      'Select Medical Consumable Warehouse';

  @override
  String get stationSetup_station_consumableStatusLabel =>
      'Medical Consumable Status';

  @override
  String get stationSetup_station_serviceLabel => 'Service';

  @override
  String get stationSetup_station_serviceSelectTitle => 'Select Service';

  @override
  String get stationSetup_station_providedServicesLabel => 'Services Served';

  @override
  String get stationSetup_station_typeLabel => 'Station Type';

  @override
  String get stationSetup_station_typePatientBasedLabel => 'Patient-Based';

  @override
  String get stationSetup_station_typeMedicineBasedLabel => 'Medicine-Based';

  @override
  String get stationSetup_warehouse_createdSuccessMessage =>
      'Warehouse created successfully';

  @override
  String get stationSetup_warehouse_updatedSuccessMessage =>
      'Warehouse updated successfully';

  @override
  String get stationSetup_warehouse_formTitleNew => 'New Warehouse';

  @override
  String get stationSetup_warehouse_formTitleEdit => 'Edit Warehouse';

  @override
  String get stationSetup_warehouse_formSubtitleNew =>
      'Fill in the warehouse details';

  @override
  String get stationSetup_warehouse_formSubtitleEdit =>
      'Update the warehouse details';

  @override
  String get stationSetup_warehouse_codeLabel => 'Warehouse Code';

  @override
  String get stationSetup_warehouse_nameLabel => 'Warehouse Name';

  @override
  String get stationSetup_warehouse_typeLabel => 'Warehouse Type';

  @override
  String get stationSetup_warehouse_managerLabel => 'Warehouse Manager';

  @override
  String get stationSetup_warehouse_managerSelectTitle =>
      'Select Warehouse Manager';

  @override
  String get stationSetup_screen_stationTabTitle => 'Station Definition';

  @override
  String get stationSetup_screen_serviceTabTitle => 'Service Definition';

  @override
  String get stationSetup_screen_warehouseTabTitle => 'Warehouse Definition';

  @override
  String get stationSetup_screen_setupWizardButton => 'Setup Wizard';

  @override
  String get stationSetup_wizard_title => 'Station Setup Wizard';

  @override
  String get stationSetup_wizard_completeSetupButton => 'Complete Setup';

  @override
  String get stationSetup_wizard_continueButton => 'Continue';

  @override
  String get stationSetup_wizard_backButton => 'Go Back';

  @override
  String get unappliedPrescription_detailDialogTitle => 'Material List';

  @override
  String get unappliedPrescription_screenTitleFallback =>
      'Unapplied Prescriptions';

  @override
  String get unappliedPrescription_viewDetailsTooltip => 'View Details';

  @override
  String get dashboardCabinsLoadErrorFallback => 'Cabinets could not be loaded';

  @override
  String get dashboardCabinListStaleLabel => 'Cabinet list is out of date';

  @override
  String get dashboardDrugActivityPanelTitle => 'DRUG ACTIVITY';

  @override
  String get dashboardDrugActivityEmptyTitle => 'No activity';

  @override
  String get dashboardDrugActivityDateTimeLabel => 'DATE / TIME';

  @override
  String get dashboardMissingStockPanelTitle => 'MISSING STOCK REPORTS';

  @override
  String get dashboardMissingStockEmptyTitle => 'No missing stock reports';

  @override
  String get dashboardMissingStockTimeLabel => 'TIME';

  @override
  String get dashboardMissingStockApproveButton => 'Approve';

  @override
  String get dashboardMissingStockRejectButton => 'Reject';

  @override
  String get dashboardOtherCabinPlaceholderText =>
      'Expired materials & critical stock (coming next)';

  @override
  String get dashboardUnappliedPrescriptionsPanelTitle =>
      'UNAPPLIED PRESCRIPTIONS';

  @override
  String get dashboardUnappliedPrescriptionsEmptyTitle =>
      'No unapplied prescriptions';

  @override
  String get dashboardDoctorLabel => 'DOCTOR';

  @override
  String get dashboardRoomBedLabel => 'ROOM / BED';

  @override
  String get dashboardUpcomingTreatmentsPanelTitle => 'UPCOMING TREATMENTS';

  @override
  String get dashboardUpcomingTreatmentsEmptyTitle => 'No upcoming treatments';

  @override
  String get dashboardListPanelLoadErrorFallback => 'Could not load';

  @override
  String get prescriptionActionCompletedSuccess =>
      'The operation was completed successfully.';

  @override
  String get prescriptionApprovedSuccess =>
      'The prescription was approved successfully.';

  @override
  String get prescriptionDetailPanelPatientFallback => 'Patient';

  @override
  String get prescriptionDetailPanelSubtitle => 'Prescription History';

  @override
  String get prescriptionDetailStartDateLabel => 'Start Date';

  @override
  String get prescriptionDetailEndDateLabel => 'End Date';

  @override
  String get prescriptionDetailStatusLabel => 'Status';

  @override
  String get prescriptionCheckWarningDialogTitle => 'Check Warning';

  @override
  String get prescriptionSaveWithTemplateSuccess =>
      'The prescription and template were saved successfully.';

  @override
  String get prescriptionSavedTemplateFailedMessage =>
      'The prescription was saved, but the template could not be saved.';

  @override
  String get prescriptionSavedSuccess =>
      'The prescription was saved successfully.';

  @override
  String get prescriptionCreatingLoadingMessage =>
      'Creating prescription. Please wait.';

  @override
  String get prescriptionTemplateSavingLoadingMessage => 'Saving template.';

  @override
  String get prescriptionNewTitle => 'New Prescription';

  @override
  String get prescriptionNewDialogSubtitle =>
      'Create a prescription or import one from history';

  @override
  String get prescriptionTabHistory => 'History';

  @override
  String get prescriptionTabTemplates => 'Templates';

  @override
  String get prescriptionContentEmptyTitle =>
      'You haven\'t added any medicine to the prescription yet.';

  @override
  String get prescriptionContentEmptyDescription =>
      'The medicines you add will be displayed here.';

  @override
  String get prescriptionItemNoTimesLabel => 'No times added';

  @override
  String get prescriptionItemNoMedicineSelected => 'No medicine selected yet';

  @override
  String get prescriptionPatientFieldLabel => 'Patient';

  @override
  String get prescriptionDoctorFieldLabel => 'Doctor';

  @override
  String get prescriptionSaveButton => 'Save Prescription';

  @override
  String get prescriptionSaveAsTemplateCheckboxLabel => 'Also save as template';

  @override
  String get prescriptionTemplateNameHint => 'Template Name';

  @override
  String get prescriptionMedicineFieldLabel => 'Medicine / Material';

  @override
  String get prescriptionDescriptionFieldLabel => 'Description';

  @override
  String get prescriptionTomorrowLabel => 'Tomorrow';

  @override
  String get prescriptionTimesLabel => 'Times';

  @override
  String get prescriptionAddTimeButton => 'Add time';

  @override
  String get prescriptionHistorySelectPatientTitle => 'Select a patient';

  @override
  String get prescriptionHistorySelectPatientDescription =>
      'Select a patient first to view their prescription history';

  @override
  String get prescriptionHistoryEmptyDescription =>
      'This patient has no prescription history';

  @override
  String prescriptionAddToRxButton(int count) {
    return 'Add to Prescription ($count)';
  }

  @override
  String get prescriptionTemplateEmptyTitle => 'No template found';

  @override
  String get prescriptionTemplateEmptyDescription =>
      'There is no saved prescription template';

  @override
  String get prescriptionTemplateNoItemsMessage => 'This template has no items';

  @override
  String get prescriptionScreenTitleFallback => 'Prescription Operations';

  @override
  String get prescriptionContentTooltip => 'Prescription Content';

  @override
  String get prescriptionShowActiveButton => 'Show active admissions';

  @override
  String get prescriptionShowDischargedButton => 'Show discharged patients';

  @override
  String get cabinTemperatureScreenTitle => 'Cabinet Temperature Control';

  @override
  String get cabinTemperatureFormDialogTitle => 'Edit Cabinet';

  @override
  String get cabinTemperatureInsideBottomLabel => 'Inside Bottom Temperature';

  @override
  String get cabinTemperatureInsideTopLabel => 'Inside Top Temperature';

  @override
  String get cabinTemperatureOutsideBottomLabel => 'Outside Bottom Temperature';

  @override
  String get cabinTemperatureOutsideTopLabel => 'Outside Top Temperature';

  @override
  String get cabinTemperatureHumidityBottomLabel => 'Humidity Lower Limit';

  @override
  String get cabinTemperatureHumidityTopLabel => 'Humidity Upper Limit';

  @override
  String cabinTemperatureGenericErrorMessage(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get cabinTemperatureStationNotSelectedError => 'No station selected';

  @override
  String get cabinTemperatureCreateSuccess =>
      'The cabinet temperature setting was created successfully.';

  @override
  String get cabinTemperatureUpdateRecordNotFoundError =>
      'No record found to update';

  @override
  String get cabinTemperatureUpdateSuccess =>
      'The cabinet temperature setting was updated successfully.';

  @override
  String get cabinTemperatureUnnamedStationFallback => 'Unnamed Station';

  @override
  String get cabinTemperatureStationsLoadingMessage => 'Loading stations...';

  @override
  String get cabinTemperatureDetailsLoadingMessage =>
      'Loading temperature details...';

  @override
  String get cabinTemperatureColumnCabin => 'Cabinet';

  @override
  String get directedOrdersScreenTitle => 'Directed Order List';

  @override
  String get directedOrdersColumnProtocolNo => 'Protocol No.';

  @override
  String get directedOrdersColumnBed => 'Bed';

  @override
  String get directedOrdersColumnRoom => 'Room';

  @override
  String get directedOrdersMedicinesTooltip => 'Medicines';

  @override
  String get directedOrdersPatientsLoadingMessage => 'Loading patients...';

  @override
  String get directedOrdersColumnBarcode => 'Barcode';

  @override
  String get medicine_successCreated => 'Drug created';

  @override
  String get medicine_successUpdated => 'Drug updated';

  @override
  String get medicalConsumable_successCreated => 'Medical consumable created';

  @override
  String get medicalConsumable_successUpdated => 'Medical consumable updated';

  @override
  String get medicine_formTitleNew => 'New Drug';

  @override
  String get medicine_formTitleEdit => 'Edit Drug';

  @override
  String get medicine_formSubtitleNew => 'Fill in the drug details';

  @override
  String get medicine_formSubtitleEdit => 'Update the drug details';

  @override
  String get medicine_fieldDefinitionName => 'Definition Name';

  @override
  String get medicine_fieldBarcode => 'Barcode';

  @override
  String get medicine_fieldName => 'Drug Name';

  @override
  String get medicine_fieldCode => 'Drug Code';

  @override
  String get medicine_fieldPrescriptionType => 'Prescription Type';

  @override
  String get medicine_fieldDose => 'Dose';

  @override
  String get medicine_fieldManufacturer => 'Manufacturer';

  @override
  String get medicine_fieldDailyMaxUsage => 'Daily Max. Usage Amount';

  @override
  String get medicine_fieldDrugType => 'Drug Type';

  @override
  String get medicine_fieldReturnType => 'Return Method';

  @override
  String get medicine_checkboxSerumMaxValue =>
      'Check the max value in the serum cabinet';

  @override
  String get medicine_checkboxCubicMaxValue =>
      'Check the max value in the cubic drawer';

  @override
  String get medicine_checkboxQrCode => 'Has QR Code';

  @override
  String get medicine_fieldPieceCountLabel => 'Piece Count';

  @override
  String get medicine_fieldDrugClass => 'Drug Class';

  @override
  String get medicine_fieldPurchaseType => 'Purchase Method';

  @override
  String get medicine_checkboxUseMeasurementUnit => 'Use Measurement Unit';

  @override
  String get medicine_fieldVolume => 'Volume';

  @override
  String get medicine_fieldDosageForm => 'Dosage Form';

  @override
  String get medicine_fieldStatus => 'Status';

  @override
  String get medicine_fieldCountType => 'Count Type';

  @override
  String get medicine_fieldAtcCode => 'ATC Code';

  @override
  String get medicine_fieldEquivalentCode => 'Equivalent Code';

  @override
  String get medicine_checkboxWitnessedPurchase => 'Witnessed Purchase';

  @override
  String get medicine_checkboxWastageWitnessed => 'Witnessed Waste/Disposal';

  @override
  String get medicine_checkboxDestroyable => 'Disposable';

  @override
  String get medicine_fieldActiveIngredient => 'Active Ingredient';

  @override
  String get medicine_fieldCollectNote => 'Purchase Note';

  @override
  String get medicine_fieldReturnNote => 'Return Note';

  @override
  String get medicine_fieldDestructionNote => 'Disposal Note';

  @override
  String get medicalConsumable_dialogTitle => 'Add/Edit Medical Consumable';

  @override
  String get medicalConsumable_fieldName => 'Material Name';

  @override
  String get medicalConsumable_fieldInstitutionCode => 'Institution Code';

  @override
  String get medicalConsumable_fieldSutCode => 'SUT Code/Annex';

  @override
  String get medicalConsumable_fieldUbbCode => 'UBB Code';

  @override
  String get medicalConsumable_fieldMaterialType => 'Material Type';

  @override
  String get medicalConsumable_fieldStatus => 'Status';

  @override
  String get medicine_screenTitleFallback =>
      'Drug/Medical Consumable Definition';

  @override
  String get medicine_newButtonLabel => 'New Drug';

  @override
  String get medicine_defineMedicalConsumableButton =>
      'Define Medical Consumable';

  @override
  String get medicine_defineActiveIngredientButton =>
      'Define Active Ingredient';

  @override
  String get medicine_defineDrugClassButton => 'Define Drug Class';

  @override
  String get medicine_defineDrugTypeButton => 'Define Drug Type';

  @override
  String get medicine_createKitButton => 'Create Drug Kit';

  @override
  String get medicine_defineMaterialTypeButton => 'Define Material Type';

  @override
  String get medicine_checkboxLowerDose =>
      'A dose lower than specified may be taken';

  @override
  String get medicine_checkboxRfid => 'RFID Available';

  @override
  String get medicine_checkboxMultiPatientAccess => 'Multi-Patient Access';

  @override
  String get medicine_checkboxSingleUse => 'Single Use';

  @override
  String get medicine_checkboxCameraRecording => 'Camera Recording';

  @override
  String get medicine_checkboxIndependentMaterial => 'Independent Drug';

  @override
  String get medicine_checkboxWastagePharmacyApproval =>
      'Require Pharmacy Approval for Waste/Disposal?';

  @override
  String get medicine_checkboxWastageOrderRenewed => 'Renew Waste Order?';

  @override
  String get medicine_fieldPersonnel => 'Personnel';

  @override
  String get medicine_fieldStation => 'Station';

  @override
  String get medicine_fieldUnit => 'Unit';

  @override
  String get refillList_dialogTitle => 'Drug Refill List';

  @override
  String refillList_recordNoLabel(Object id) {
    return 'Refill Record No: $id';
  }

  @override
  String refillList_createdDateLabel(String date) {
    return 'Created Date: $date';
  }

  @override
  String refillList_assignedUserNameLabel(String name) {
    return 'Assigned To: $name';
  }

  @override
  String get refillList_formTitleCreate => 'Create Refill List';

  @override
  String get refillList_formTitleUpdate => 'Update Refill List';

  @override
  String get refillList_fieldAssignedUser => 'User Assigned to Refill';

  @override
  String get refillList_screenTitleFallback => 'Refill List';

  @override
  String get refillList_newButtonLabel => 'New Refill List';

  @override
  String get report_stationsCategoryTitle => 'Stations';

  @override
  String get refillList_cellValueYes => 'Yes';

  @override
  String get refillList_cellValueNo => 'No';

  @override
  String get refillList_updateStatusTooltip => 'Update Status';

  @override
  String get refillList_defaultUnitFallback => 'Piece';

  @override
  String get report_expiredItemsTitleFallback => 'Expired Materials';

  @override
  String get report_stationStockTitle => 'Station Cabinet Stock';

  @override
  String get report_stationTransactionTitleFallback => 'Station Transactions';

  @override
  String get report_hospitalStocksTitleFallback => 'Hospital Material List';

  @override
  String get inconsistency_screenTitleFallback => 'Inconsistency Movements';

  @override
  String get inconsistency_viewTooltip => 'View';

  @override
  String get inconsistency_photoTooltip => 'Photo';

  @override
  String get hospitalization_formTitleNew => 'Enter New Admission';

  @override
  String get hospitalization_formTitleEdit => 'Edit Admission';

  @override
  String get hospitalization_fieldPatient => 'Patient';

  @override
  String get hospitalization_fieldCode => 'Admission Code';

  @override
  String get hospitalization_fieldDoctor => 'Doctor';

  @override
  String get hospitalization_fieldPhysicalService => 'Physical Service';

  @override
  String get hospitalization_fieldInpatientService => 'Inpatient Service';

  @override
  String get hospitalization_fieldRoom => 'Room';

  @override
  String get hospitalization_roomDialogTitle => 'Select Room';

  @override
  String get hospitalization_fieldBed => 'Bed';

  @override
  String get hospitalization_bedDialogTitle => 'Select Bed';

  @override
  String get hospitalization_fieldAdmissionDate => 'Admission Date';

  @override
  String get hospitalization_fieldExitDate => 'Discharge Date';

  @override
  String get hospitalization_checkboxBaby => 'Infant';

  @override
  String get hospitalization_screenTitleFallback => 'Patient Operations';

  @override
  String get hospitalization_editPatientTooltip => 'Edit Patient Details';

  @override
  String get hospitalization_showActiveTooltip => 'Show active admissions';

  @override
  String get hospitalization_showDischargedTooltip =>
      'Show discharged patients';

  @override
  String get hospitalization_createButton => 'Create New Admission';

  @override
  String get patient_formTitleNew => 'Create New Patient';

  @override
  String get patient_formTitleEdit => 'Edit Patient';

  @override
  String get patient_fieldIdentity => 'National ID No.';

  @override
  String get patient_fieldName => 'First Name';

  @override
  String get patient_fieldSurname => 'Last Name';

  @override
  String get patient_fieldBirthDate => 'Date of Birth';

  @override
  String get patient_fieldGender => 'Gender';

  @override
  String get patient_fieldWeight => 'Weight';

  @override
  String get patient_fieldMotherName => 'Mother\'s Name';

  @override
  String get patient_fieldFatherName => 'Father\'s Name';

  @override
  String get patient_fieldPhone => 'Phone';

  @override
  String get patient_fieldAddress => 'Address';

  @override
  String get patient_fieldProtocolNo => 'Protocol No.';

  @override
  String get activeIngredientDialogSelectTitle => 'Select Active Ingredient';

  @override
  String get activeIngredientDialogTitle => 'Active Ingredient Definition';

  @override
  String get activeIngredientFormAddTitle => 'Add Active Ingredient';

  @override
  String get activeIngredientFormEditTitle => 'Edit Active Ingredient';

  @override
  String get activeIngredientListEmptyTitle => 'No active ingredients yet';

  @override
  String get assignmentScreenTitle => 'Station Material Assignment';

  @override
  String get assignmentStationSelectPlaceholder => 'Select a station';

  @override
  String get drugClassDialogSelectTitle => 'Select Drug Class';

  @override
  String get drugClassDialogTitle => 'Drug Class Definition';

  @override
  String get drugClassFormAddTitle => 'Add Drug Class';

  @override
  String get drugClassFormEditTitle => 'Edit Drug Class';

  @override
  String get drugClassFormNameLabel => 'Drug Class Name';

  @override
  String get drugClassListEmptyTitle => 'No drug classes yet';

  @override
  String get drugTypeDialogSelectTitle => 'Select Drug Type';

  @override
  String get drugTypeDialogTitle => 'Drug Type Definition';

  @override
  String get drugTypeFormAddTitle => 'Add Drug Type';

  @override
  String get drugTypeFormEditTitle => 'Edit Drug Type';

  @override
  String get drugTypeFormNameLabel => 'Drug Type Name';

  @override
  String get drugTypeListEmptyTitle => 'No drug types yet';

  @override
  String get kitFormAddTitle => 'New Kit';

  @override
  String get kitFormEditTitle => 'Edit Kit';

  @override
  String get kitFormNameLabel => 'Kit Name';

  @override
  String get kitDialogSelectTitle => 'Select Kit';

  @override
  String get kitDialogTitle => 'Kit Definition';

  @override
  String get kitListEmptyTitle => 'No kits yet';

  @override
  String get kitListManageContentTooltip => 'Manage Kit Content';

  @override
  String get kitContentFormAddTitle => 'Add Kit Content';

  @override
  String get kitContentFormEditTitle => 'Edit Kit Content';

  @override
  String get kitContentFormMaterialLabel => 'Material';

  @override
  String get kitContentFormPieceLabel => 'Piece Count';

  @override
  String get kitContentDialogTitle => 'Kit Content Definition';

  @override
  String get kitContentListEmptyTitle => 'No kit content yet';

  @override
  String get materialTypeFormAddTitle => 'New Material Type';

  @override
  String get materialTypeFormEditTitle => 'Edit Material Type';

  @override
  String get materialTypeFormNameLabel => 'Material Type Name';

  @override
  String get materialTypeDialogSelectTitle => 'Select Material Type';

  @override
  String get materialTypeDialogTitle => 'Material Type Definition';

  @override
  String get materialTypeListEmptyTitle => 'No material types yet';

  @override
  String get roleFormEditTitle => 'Edit Role';

  @override
  String get roleFormAddTitle => 'Add Role';

  @override
  String get roleFormNameLabel => 'Role Name';

  @override
  String get roleScreenTitle => 'Role Definition';

  @override
  String get roleScreenAddButton => 'New Role';

  @override
  String get roleDeleteSuccessMessage => 'Role deleted successfully';

  @override
  String get unitFormAddTitle => 'Create New Unit';

  @override
  String get unitFormEditTitle => 'Edit Unit';

  @override
  String get unitDialogTitle => 'Unit';

  @override
  String get unitListEmptyTitle => 'No units yet';

  @override
  String get userCategoryNormalLabel => 'Normal';

  @override
  String get userCategoryTimeBasedLabel => 'Time-Limited';

  @override
  String get userCategoryTemporaryLabel => 'Temporary';

  @override
  String get userDeleteSuccessMessage => 'User deleted successfully';

  @override
  String get userValidDateUpdateSuccessMessage => 'Expiry date updated';

  @override
  String get userFormEditTitle => 'Edit User';

  @override
  String get userFormCreateTitle => 'Create User';

  @override
  String get userRegistrationNumberLabel => 'Institution Registry No.';

  @override
  String get userNameLabel => 'First Name';

  @override
  String get userSurnameLabel => 'Last Name';

  @override
  String get userRoleTypeLabel => 'Occupation Type';

  @override
  String get userUsageTypeLabel => 'Usage Type';

  @override
  String get userValidUntilLabel => 'Expiry Date';

  @override
  String get userEmailLabel => 'Email';

  @override
  String get userOrderPermissionLabel => 'Purchase Without Order';

  @override
  String get userWitnessedStationEntryLabel => 'Witnessed Station Entry';

  @override
  String get userKitPurchaseLabel => 'Kit Purchase';

  @override
  String get user_badgeCardLabel => 'Badge Card';

  @override
  String get user_badgeCardHint => 'Scan card';

  @override
  String get userAuthorizedStationsLabel => 'Authorized Stations';

  @override
  String get userUsernameLabel => 'Username';

  @override
  String get userScreenTitle => 'User List';

  @override
  String get userScreenAddButton => 'New User';

  @override
  String get userBulkUpdateValidDateButton => 'Update Expiry Date';

  @override
  String get userValidDateDialogTitle => 'Update Date';

  @override
  String get userValidDateDialogSaveButton => 'Update';

  @override
  String get userNewValidUntilLabel => 'New Expiry Date';

  @override
  String get userNationalIdColumnHeader => 'National ID No.';

  @override
  String get warningFormAddTitle => 'New Warning';

  @override
  String get warningFormEditTitle => 'Edit Warning';

  @override
  String get warningFormAddSubtitle => 'Fill in the warning details';

  @override
  String get warningFormEditSubtitle => 'Update the warning details';

  @override
  String get warningFormSubjectLabel => 'Warning Subject';

  @override
  String get warningFormTextLabel => 'Warning Text';

  @override
  String get warningScreenTitle => 'Warning Definition';

  @override
  String get dashboard_allSectionsLoadError =>
      'The data could not be loaded. Please try again.';

  @override
  String get dashboard_sktCriticalRingLabel => 'Critical\n(<7 days)';

  @override
  String get dashboard_sktWarningRingLabel => 'Warning\n(7-30 days)';

  @override
  String get dashboard_sktExpiredRingLabel => 'Expired\nItems';

  @override
  String get dashboard_sktStatusHeader => 'EXPIRY STATUS';

  @override
  String dashboard_sktItemCountBadge(int count) {
    return '$count Items';
  }

  @override
  String get dashboard_sktExpiredTag => 'EXPIRED';

  @override
  String get dashboard_sktDestroyHint => 'destroy';

  @override
  String dashboard_sktDaysRemainingLabel(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'days left',
      one: 'day left',
    );
    return '$_temp0';
  }

  @override
  String get dashboard_upcomingTreatmentsHeader => 'UPCOMING TREATMENTS';

  @override
  String dashboard_pendingTreatmentsBadge(int count) {
    return '$count Pending';
  }

  @override
  String get dashboard_pendingFilterLabel => 'Pending';

  @override
  String get dashboard_urgentFilterLabel => 'Urgent';

  @override
  String get dashboard_treatmentSearchHint => 'Search patient or medicine...';

  @override
  String get dashboard_newAssignButton => 'New Assignment';

  @override
  String get dashboard_noTreatmentsAllFilter => 'No treatment records found';

  @override
  String get dashboard_noTreatmentsPendingFilter => 'No pending treatments';

  @override
  String get dashboard_noTreatmentsUrgentFilter => 'No urgent treatments';

  @override
  String get dashboard_priorityUrgentLabel => 'Urgent';

  @override
  String get dashboard_priorityNormalLabel => 'Normal';

  @override
  String get dashboard_priorityRoutineLabel => 'Routine';

  @override
  String get dashboard_statusPendingLabel => 'Pending';

  @override
  String get dashboard_statusDoneLabel => 'Dispensed';

  @override
  String get dashboard_statusReturnedLabel => 'Returned';

  @override
  String settings_sectionComingSoon(String label) {
    return '$label settings coming soon';
  }

  @override
  String get refund_masterScreenNotReady =>
      'The master cabinet return screen isn\'t ready yet.';

  @override
  String get core_cabinConn_managerNotFoundError =>
      'Management card not found.';

  @override
  String get core_cabinConn_disconnectedError => 'Connection lost';

  @override
  String get common_action_pullDrawerTitle => 'Open the drawer';

  @override
  String get common_action_pullDrawerSubtitle =>
      'The lock is open, please pull it.';

  @override
  String get masterDrawer_openingLidTitle => 'Opening lids';

  @override
  String get masterDrawer_openingLidSubtitle =>
      'Preparing the cubic drawer lids.';

  @override
  String get masterDrawer_readySubtitle =>
      'Complete the operation and confirm.';

  @override
  String get common_action_closeDrawerTitle => 'Close the drawer';

  @override
  String get common_action_closeDrawerSubtitle =>
      'The operation is confirmed, please close it.';

  @override
  String get common_action_drawerClosed => 'Drawer closed';

  @override
  String get common_action_operationCompletedSubtitle =>
      'The operation is complete.';

  @override
  String get common_action_drawerError => 'Drawer error';

  @override
  String common_error_unexpectedWithDetail(Object error) {
    return 'Unexpected error: $error';
  }

  @override
  String masterDrawer_lidOpenFailedError(Object error) {
    return 'The lid could not be opened: $error';
  }

  @override
  String get common_action_devicePreparing => 'Preparing device...';

  @override
  String common_error_connectionErrorWithDetail(Object error) {
    return 'Connection error: $error';
  }

  @override
  String get common_action_lockOpening => 'Opening lock...';

  @override
  String common_error_lockOpenFailedWithDetail(Object error) {
    return 'The lock could not be opened: $error';
  }

  @override
  String mobileDrawer_portSubtitle(int port) {
    return 'Drawer $port';
  }

  @override
  String get mobileDrawer_openedSubtitle =>
      'Close the drawer to complete the operation.';

  @override
  String get mobileDrawer_closedSubtitle => 'Waiting for your confirmation';

  @override
  String common_error_managerConnectFailedWithDetail(Object error) {
    return 'Could not connect to the management card: $error';
  }

  @override
  String mobileDrawer_openCommandFailedError(Object error) {
    return 'Could not send the drawer-open command: $error';
  }

  @override
  String get mobileDrawer_statusTimeoutError =>
      'Timed out while reading the drawer status.';

  @override
  String get mobileDrawer_openNotConfirmedError =>
      'Could not confirm that the drawer opened.';

  @override
  String mobileDrawer_statusReadError(Object error) {
    return 'An error occurred while reading the drawer status: $error';
  }

  @override
  String get patientPicker_searchHint => 'Search patient';

  @override
  String get patientPicker_orderlessToggleLabel => 'Without Order';

  @override
  String get patientPicker_orderedToggleLabel => 'With Order';

  @override
  String get patientPicker_myPatientsToggleLabel => 'My Patients';

  @override
  String get patientPicker_urgentPatientHint =>
      'Create a record for an urgent patient not on the list.';

  @override
  String get patientPicker_createUrgentPatientButton => 'Create Urgent Patient';

  @override
  String get patientPicker_urgentPatientCreatedMessage =>
      'Urgent patient created.';

  @override
  String get hw_cabinOps_serumSlaveModeError =>
      'The serum card could not be set to slave mode...';

  @override
  String hw_cabinOps_solenoidMissingError(Object port) {
    return 'Port $port has no solenoid (.no).';
  }

  @override
  String hw_cabinOps_portOpenFailedError(Object port, Object response) {
    return 'Port $port could not be opened. Response: $response';
  }

  @override
  String hw_cabinOps_masterDrawerOpenFailedError(
    Object row,
    Object port,
    Object drawer,
    Object response,
  ) {
    return 'The master drawer could not be opened (row=$row, port=$port, drawer=$drawer). Response: $response';
  }

  @override
  String hw_cabinOps_masterSerumOpenFailedError(Object row, Object response) {
    return 'The master serum drawer could not be opened (row=$row). Response: $response';
  }

  @override
  String hw_serial_connectFailedDetailedError(String portName) {
    return 'Could not connect to port $portName. Make sure the device is connected and powered on, and that the port isn\'t in use by another application.';
  }

  @override
  String hw_serial_portConfigFailedError(String portName, Object error) {
    return 'Port configuration failed ($portName): $error';
  }

  @override
  String hw_serial_systemErrorSuffix(Object error) {
    return 'System error: $error';
  }

  @override
  String get hw_serial_portInUseSuffix =>
      'The port may be in use by another application.';

  @override
  String hw_serial_readErrorWithDetail(Object error) {
    return 'Port read error: $error';
  }

  @override
  String get hw_serial_reconnectingStatus => 'Restarting the connection.';

  @override
  String hw_rfid_connectFailedError(Object error) {
    return 'Could not connect to the RFID reader: $error';
  }

  @override
  String get hw_rfid_invalidResponseError =>
      'An invalid response was received.';

  @override
  String hw_rfid_unreachableError(Object error) {
    return 'The RFID reader could not be reached: $error';
  }

  @override
  String get hw_rfid_testTimeoutError => 'The RFID connection test timed out.';

  @override
  String get hw_rfid_powerChangeBlockedError =>
      'The power setting cannot be changed while inventory is active. Call stopInventory() first.';

  @override
  String hw_rfid_setModeRejectedError(Object status) {
    return 'SetWorkingMode was rejected (status=0x$status)';
  }

  @override
  String hw_rfid_setAntennaRejectedError(Object status) {
    return 'SetWorkingAntenna was rejected (status=0x$status)';
  }

  @override
  String get hw_rfid_antennaConnFailedHint =>
      ' (antenna connection error — one of the enabled ports is empty)';

  @override
  String get hw_rfid_noAntennaConnectedError =>
      'Could not connect to any antenna (all ports are empty).';

  @override
  String get hw_rfid_notConnectedError => 'The RFID service is not connected.';

  @override
  String get hw_rfid_commandPendingError =>
      'The previous command is still awaiting a response.';

  @override
  String hw_rfid_commandTimeoutError(Object cmd) {
    return 'The command response timed out (cmd=0x$cmd).';
  }

  @override
  String hw_rfid_commandErrorWithDetail(Object error) {
    return 'Command error: $error';
  }

  @override
  String get hw_rfid_mockNotConnectedError =>
      'The mock RFID service is not connected.';

  @override
  String get operationStatus_fatalErrorLabel => 'Critical Error';

  @override
  String get operationStatus_errorLabel => 'Error';

  @override
  String get operationStatus_rollingBackLabel => 'Rolling back the operation';

  @override
  String get operationStatus_finalizingLabel => 'Finalizing the operation';

  @override
  String get operationStatus_drugsStillInCabinetLabel =>
      'Medicines are still in the cabinet';

  @override
  String get operationStatus_incompleteLabel => 'Incomplete / Inconsistent';

  @override
  String get operationStatus_scanningLabel => 'Scanning';

  @override
  String get operationStatus_reportedMissingLabel => 'Reported Missing';

  @override
  String get operationBanner_unplannedMovementTitle =>
      'Unplanned movement detected';

  @override
  String operationBanner_unplannedMovementMessage(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString tags were removed from the cabinet unexpectedly.',
      one: '$countString tag was removed from the cabinet unexpectedly.',
    );
    return '$_temp0 A report will be sent to the pharmacy.';
  }

  @override
  String get operationBanner_unexpectedTagBlockingTitle =>
      'Tag(s) not belonging to this cabinet detected';

  @override
  String get operationBanner_unexpectedTagWarningTitle => 'Unexpected medicine';

  @override
  String operationBanner_unexpectedTagBlockingMessage(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString tags',
      one: '$countString tag',
    );
    return 'Remove the following $_temp0 from the drawer to continue.';
  }

  @override
  String operationBanner_unexpectedTagWarningMessage(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString tags',
      one: '$countString tag',
    );
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'were',
      one: 'was',
    );
    String _temp2 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'them',
      one: 'it',
    );
    return '$_temp0 not belonging to this cabinet $_temp1 read. Please remove $_temp2.';
  }

  @override
  String get operationBanner_missingStockTitle => 'Missing stock';

  @override
  String operationBanner_missingStockMessage(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString medicines were',
      one: '$countString medicine was',
    );
    return '$_temp0 not found in the cabinet. It will be reported as missing stock when completed.';
  }

  @override
  String get common_okButton => 'OK';

  @override
  String get cabinPatientPicker_searchHint =>
      'Search patient, room, bed, or service...';

  @override
  String get common_unknownPatientFallback => 'Unknown Patient';

  @override
  String get patientListPanel_searchHint => 'Search patient...';

  @override
  String rxItemCard_maxQuantitySuffix(String max, String unit) {
    return '/ max. $max $unit';
  }

  @override
  String get census_extraStockSummaryMessage =>
      'Excess stock will be reported at the end of the operation.';

  @override
  String get cabinOperation_hint_scanning =>
      'Scanning the cabinet, please wait';

  @override
  String get census_hint_waitingClose =>
      'Recorded — close the drawer to finish the census';

  @override
  String get census_hint_closedEarly =>
      'The drawer closed early — you can retry or cancel';

  @override
  String get cabinOperation_hint_error => 'An error occurred — you can retry';

  @override
  String get census_hint_unexpectedTag =>
      'There is a tag that doesn\'t belong in this cabinet — remove it to continue';

  @override
  String get census_hint_readyToComplete =>
      'Press the button to complete the census';

  @override
  String get cabinOperation_action_closeDrawer => 'Close the Drawer';

  @override
  String get census_label_counted => 'Counted';

  @override
  String get census_label_excess => 'Excess';

  @override
  String get cabinOperation_label_unexpectedTag => 'Foreign';

  @override
  String get intake_error_witnessRequired => 'A witness login is required.';

  @override
  String get intake_error_noValidTargets =>
      'The intake could not be performed for the selected medicines.';

  @override
  String get intake_error_noDrawerFound => 'No drawer was found to take from.';

  @override
  String get intake_hint_noStock => 'There is no stock in the cabinet';

  @override
  String intake_label_witnessName(String name) {
    return 'Witness: $name';
  }

  @override
  String get intake_hint_witnessRequired => 'Witness login required';

  @override
  String get intake_status_checking => 'Checking...';

  @override
  String get intake_status_readyToTake => 'Ready to take';

  @override
  String get intake_status_checkFailed => 'Check failed';

  @override
  String get intake_emptyState_selectMedicine =>
      'Select a medicine to start the intake.';

  @override
  String intake_label_multiMedicine(int count) {
    return '$count different medicines';
  }

  @override
  String intake_label_takenAmount(String amount, String unit) {
    return 'Taken: $amount $unit';
  }

  @override
  String intake_label_countFieldLabel(String unit) {
    return 'Count ($unit)';
  }

  @override
  String get intake_hint_nextCellOpens =>
      'The next cell will open once you confirm.';

  @override
  String get intake_hint_confirmCloses =>
      'The drawer will close once you confirm.';

  @override
  String get intake_hint_searchMedicine => 'Search medicine (name / barcode)';

  @override
  String get intake_hint_selectionLocked =>
      'Intake in progress — selection is locked.';

  @override
  String get intake_hint_autoQueueOrder =>
      'Drawers will open in the shortest-path order.';

  @override
  String intake_info_witnessAutoAssigned(String name) {
    return '$name was also assigned as the witness for this medicine.';
  }

  @override
  String get intake_error_queueTitle => 'The intake could not be completed';

  @override
  String get intake_error_queueMessage =>
      'Put the medicines back where you took them from.';

  @override
  String get intake_error_selfWitness =>
      'The user performing the operation cannot also witness it.';

  @override
  String intake_success_witnessConfirmed(String name) {
    return '$name was confirmed as the witness.';
  }

  @override
  String get intake_witnessDialog_title => 'Witness Verification';

  @override
  String get intake_witnessDialog_usernameLabel => 'Witness Username';

  @override
  String get intake_witnessDialog_usernameRequired => 'Enter a username';

  @override
  String get intake_witnessDialog_passwordLabel => 'Witness Password';

  @override
  String get intake_witnessDialog_passwordRequired => 'Enter a password';

  @override
  String get intake_witnessDialog_confirmButton => 'Confirm Witness';

  @override
  String get intake_witnessDialog_anyoneInfo =>
      'Any staff member can witness this operation.';

  @override
  String intake_witnessDialog_authorizedWitnesses(int count) {
    return 'Authorized Witnesses ($count)';
  }

  @override
  String cabinOperation_hint_fatalError(String message) {
    return 'A critical error occurred: $message';
  }

  @override
  String get cabinOperation_hint_completed => 'Operation completed';

  @override
  String get cabinOperation_hint_waitingCloseGeneric =>
      'Recorded. Close the drawer to finish the operation';

  @override
  String get cabinOperation_hint_closedEarlyGeneric =>
      'The drawer was closed. You can cancel or continue where you left off';

  @override
  String get cabinOperation_hint_ready =>
      'Ready — you can complete the operation';

  @override
  String get intake_hint_extraPlacement =>
      'A medicine that shouldn\'t be in the cabinet was loaded, please remove it.';

  @override
  String get intake_hint_takeItems =>
      'Take the medicines, then complete the operation';

  @override
  String get cabinOperation_action_completeGeneric => 'Complete the operation';

  @override
  String get rfidStatus_notFound => 'Not Found';

  @override
  String get rfidStatus_scanning => 'Scanning';

  @override
  String get intake_label_noRfid => 'No RFID';

  @override
  String get cabinOperation_label_selected => 'Selected';

  @override
  String get intake_label_readInCabin => 'Read in Cabinet';

  @override
  String intake_label_tagCount(int count) {
    return '$count tags';
  }

  @override
  String get intake_label_takenCount => 'Taken';

  @override
  String get intake_label_unauthorizedTake => 'Unauthorized Take';

  @override
  String get intake_error_retryOrFinish =>
      'You can retry, or finish the operation by taking back the medicines you placed.';

  @override
  String get refill_label_placed => 'Placed';

  @override
  String get refill_label_placedCount => 'Placed';

  @override
  String refill_label_placedProgress(Object done, Object total) {
    return '$done / $total';
  }

  @override
  String get cabinOperation_label_unplanned => 'Unplanned';

  @override
  String get refill_label_extraTag => 'Extra Tag';

  @override
  String get refill_error_retry => 'You can try again.';

  @override
  String get unload_hint_waitingClose =>
      'Recorded — close the drawer to finish unloading';

  @override
  String get unload_hint_closedEarly =>
      'The drawer closed early — you can retry or cancel';

  @override
  String get unload_hint_readyToComplete =>
      'Press the button to complete unloading';

  @override
  String get unload_label_unloaded => 'Unloaded';

  @override
  String unload_label_unloadProgress(Object done, Object total) {
    return '$done / $total';
  }

  @override
  String wizard_stepBadge(int step, int total) {
    return 'Step $step / $total';
  }

  @override
  String get wizard_step4Header => 'Drawer Configuration';

  @override
  String get wizard_step4SubtitleMobile =>
      'Define the mobile cabinet\'s drawer count, internal sections, and port connections.';

  @override
  String get wizard_step4SubtitleMaster =>
      'The cabinet\'s internal structure will be read automatically from the device.';

  @override
  String get wizard_backButton => 'Back';

  @override
  String get wizard_testCabinConnectionButton => 'Test Cabinet Connection';

  @override
  String get wizard_testingInProgress => 'Testing…';

  @override
  String get wizard_connectionSuccessLabel => 'Connection successful';

  @override
  String get wizard_retestLink => 'Test again';

  @override
  String get wizard_cabinConnectionErrorFallback =>
      'Could not establish a connection. Check the port settings.';

  @override
  String get wizard_testRfidConnectionButton => 'Test Antenna Connection';

  @override
  String wizard_rfidFirmwareInfo(String firmwareVersion, Object power) {
    return '· FW $firmwareVersion  $power dBm';
  }

  @override
  String get wizard_rfidConnectionErrorFallback =>
      'Could not establish a connection. Check the IP and port settings.';

  @override
  String get wizard_portLabel => 'Port';

  @override
  String get wizard_rfidReaderToggleLabel => 'Has RFID reader';

  @override
  String get wizard_rfidIpAddressLabel => 'RFID IP Address';

  @override
  String get wizard_rfidPortFieldLabel => 'RFID Port';

  @override
  String get wizard_drawerCountRangeHint => '1–8 drawers';

  @override
  String get wizard_sameConfigToggleLabel =>
      'All drawers have the same structure';

  @override
  String get wizard_sameConfigToggleOnDesc =>
      'All drawers use the same row/column configuration';

  @override
  String get wizard_sameConfigToggleOffDesc =>
      'When off, row/column can be set separately for each drawer';

  @override
  String wizard_drawerRowCellSummary(int rowCount, int totalCells) {
    return '$rowCount rows · $totalCells cells';
  }

  @override
  String wizard_drawerPortLabel(Object portNumber) {
    return 'Port $portNumber';
  }

  @override
  String wizard_rowLabel(int rowIndex) {
    return 'ROW $rowIndex';
  }

  @override
  String get wizard_serviceDetailsLoadError =>
      'Could not load the service details.';

  @override
  String get wizard_stationDetailsLoadError =>
      'Could not load the station details.';

  @override
  String get wizard_stationsLoadErrorFallback => 'Could not load the stations.';

  @override
  String get wizard_noStationsFoundMessage =>
      'No registered stations were found.';

  @override
  String get wizard_noRoomsDefinedMessage =>
      'No rooms are defined for this station.';

  @override
  String wizard_selectedRoomCountBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rooms',
      one: '$count room',
    );
    return '$_temp0';
  }

  @override
  String wizard_roomSelectionFraction(int selected, int total) {
    return '$selected/$total';
  }

  @override
  String get refill_hint_extraPlacement =>
      'A tag other than the selected medicines was placed, please remove it';

  @override
  String get refill_hint_placeItems =>
      'Place the medicines, then complete the operation';

  @override
  String get appException_networkUnavailable =>
      'Could not connect to the server. Check your network connection.';

  @override
  String get appException_timeout =>
      'The server did not respond. Please try again.';

  @override
  String appException_serviceError5xx(Object statusCode) {
    return 'Server error ($statusCode). Please try again.';
  }

  @override
  String appException_serviceErrorOther(Object statusCode) {
    return 'The operation could not be completed ($statusCode).';
  }

  @override
  String get appException_malformedData =>
      'Unexpected data was received from the server.';

  @override
  String get appException_emptyResponse =>
      'The server returned an empty response.';

  @override
  String appException_validationField(String field) {
    return 'The $field field is invalid.';
  }

  @override
  String get appException_validationGeneric =>
      'The information entered is invalid.';

  @override
  String get appException_mapping =>
      'An error occurred while processing the data.';

  @override
  String get appException_cache => 'Could not read local data.';

  @override
  String get appException_staleCache =>
      'Cannot reach up-to-date data. Please check the connection.';

  @override
  String appException_notFoundWithType(String resourceType) {
    return '$resourceType not found.';
  }

  @override
  String get appException_notFoundGeneric => 'Record not found.';

  @override
  String get appException_unexpected =>
      'An unexpected error occurred. Please try again.';

  @override
  String get appException_serialPort =>
      'Could not connect to the serial port. Please contact technical service.';

  @override
  String get appException_custom =>
      'An unknown error occurred. Please try again later.';

  @override
  String get dataError_emptyResponse => 'The server returned an empty response';

  @override
  String get dataError_malformedResponse =>
      'The response could not be processed';

  @override
  String get dataError_requestTimeout => 'The request timed out';

  @override
  String get dataError_networkUnavailable => 'Could not connect to the network';

  @override
  String get dataError_genericApiError =>
      'We encountered an error. Please try again later.';

  @override
  String get dataError_requestCancelled => 'The request was cancelled';

  @override
  String get dataError_envelopeErrorFallback => 'Error';

  @override
  String get authError_invalidTokenResponse =>
      'An invalid token response was received from the server';

  @override
  String get authError_userInfoFetchFailed =>
      'Could not retrieve user information';

  @override
  String get authError_userInfoEmpty =>
      'The user information returned was empty';

  @override
  String get authError_genericLoginError => 'An error occurred';

  @override
  String get authError_invalidCredentialsMock =>
      'Incorrect username or password.';

  @override
  String get dataGuard_deleteActiveIngredientIdEmpty =>
      'The ID of the active ingredient to delete cannot be empty';

  @override
  String get dataGuard_deleteBranchIdEmpty =>
      'The ID of the branch to delete cannot be empty';

  @override
  String get dataGuard_deleteCabinIdEmpty =>
      'The ID of the cabinet to delete cannot be empty';

  @override
  String get dataGuard_deleteDosageFormIdEmpty =>
      'The ID of the dosage form to delete cannot be empty';

  @override
  String get dataGuard_deleteDrugClassIdEmpty =>
      'The ID of the drug class to delete cannot be empty';

  @override
  String get dataGuard_deleteFirmIdEmpty =>
      'The ID of the firm to delete cannot be empty';

  @override
  String get dataGuard_deleteDrugTypeIdEmpty =>
      'The ID of the drug type to delete cannot be empty';

  @override
  String get dataGuard_deleteHospitalizationIdEmpty =>
      'The ID of the admission to delete cannot be empty';

  @override
  String get dataGuard_deleteKitIdEmpty =>
      'The ID of the kit to delete cannot be empty';

  @override
  String get dataGuard_deleteKitContentIdEmpty =>
      'The ID of the kit content to delete cannot be empty';

  @override
  String get dataGuard_deleteMaterialTypeIdEmpty =>
      'The ID of the material type to delete cannot be empty';

  @override
  String get dataGuard_deleteMedicineIdEmpty =>
      'The ID of the medicine to delete cannot be empty';

  @override
  String get dataGuard_deletePatientIdEmpty =>
      'The ID of the patient to delete cannot be empty';

  @override
  String get dataGuard_deleteRoleIdEmpty =>
      'The ID of the role to delete cannot be empty';

  @override
  String get dataGuard_deleteServiceIdEmpty =>
      'The ID of the service to delete cannot be empty';

  @override
  String get dataGuard_deleteStationIdEmpty =>
      'The ID of the station to delete cannot be empty';

  @override
  String get dataGuard_deleteUnitIdEmpty =>
      'The ID of the unit to delete cannot be empty';

  @override
  String get dataGuard_deleteWarehouseIdEmpty =>
      'The ID of the warehouse to delete cannot be empty';

  @override
  String get dataGuard_deleteWarningIdEmpty =>
      'The ID of the warning to delete cannot be empty';

  @override
  String get dataGuard_updatePatientIdEmpty =>
      'The ID of the patient to update cannot be empty';

  @override
  String get dataGuard_updateHospitalizationIdEmpty =>
      'The ID of the admission to update cannot be empty';

  @override
  String get core_genericErrorRetryMessage =>
      'An error occurred. Please try again later.';

  @override
  String get core_genericErrorShortMessage => 'An error occurred.';

  @override
  String get cabinCore_createError =>
      'An error occurred while creating the cabinet. Please try again later.';

  @override
  String get cabinCore_activeCabinNotFound => 'No active cabinet found';

  @override
  String get cabinCore_mobileCabinDesignNotFound =>
      'Mobile cabinet design not found';

  @override
  String get cabinCore_cabinDesignNotFound => 'Cabinet design not found';

  @override
  String get cabinCore_createdButIdMissing =>
      'The cabinet was created but its ID could not be retrieved.';

  @override
  String get cabinCore_definitionsNotFound =>
      'The definitions could not be retrieved.';

  @override
  String get cabinCore_noCardsFound => 'No cards were found.';

  @override
  String get cabinCore_noMatchingDrawerFound => 'No matching drawer was found.';

  @override
  String get cabinCore_designDataNotFound => 'No data was found to save.';

  @override
  String get prescriptionCore_createError =>
      'An error occurred while creating the prescription. Please try again later.';

  @override
  String get prescriptionCore_rfidTagNotFoundInReader =>
      'No RFID tag was found in the reader\'s range.';

  @override
  String prescriptionCore_rfidReadErrorWithDetail(Object error) {
    return 'An error occurred while reading the RFID tag: $error';
  }

  @override
  String get tableCore_roleNameColumn => 'Role Name';

  @override
  String get tableCore_warningSubjectColumn => 'Warning Subject';

  @override
  String get tableCore_warningTextColumn => 'Warning Text';

  @override
  String get tableCore_warehouseCodeColumn => 'Warehouse Code';

  @override
  String get tableCore_warehouseNameColumn => 'Warehouse Name';

  @override
  String get tableCore_warehouseManagerColumn => 'Warehouse Manager';

  @override
  String get tableCore_dosageFormBranchColumn => 'Branch Name';

  @override
  String get tableCore_firmIdColumn => 'ID';

  @override
  String get tableCore_firmNameColumn => 'Name';

  @override
  String get tableCore_firmTypeColumn => 'Firm Type';

  @override
  String get tableCore_firmTaxOfficeColumn => 'Tax Office';

  @override
  String get tableCore_firmTaxNoColumn => 'Tax No.';

  @override
  String get tableCore_kitNameColumn => 'Kit Name';

  @override
  String get tableCore_kitContentMaterialNameColumn => 'Material Name';

  @override
  String get tableCore_kitContentPieceColumn => 'Piece Count';

  @override
  String get tableCore_drugTypeColumn => 'Drug Type';

  @override
  String get tableCore_drugClassColumn => 'Drug Class';

  @override
  String get tableCore_materialTypeColumn => 'Material Type';

  @override
  String get tableCore_stationCodeColumn => 'Station Code';

  @override
  String get tableCore_stationNameColumn => 'Station Name';

  @override
  String get tableCore_stationDrugWarehouseColumn => 'Drug Warehouse';

  @override
  String get tableCore_stationDrugColumn => 'Drug';

  @override
  String get tableCore_stationConsumableWarehouseColumn =>
      'Medical Consumable Warehouse';

  @override
  String get tableCore_stationConsumableColumn => 'Medical Consumable';

  @override
  String get tableCore_stationWorkingTypeColumn => 'Working Type';

  @override
  String get tableCore_hospitalizationProtocolNoColumn => 'Protocol No.';

  @override
  String get tableCore_hospitalizationNationalIdColumn => 'National ID No.';

  @override
  String get tableCore_hospitalizationPatientColumn => 'Patient';

  @override
  String get tableCore_patientRowNationalIdColumn => 'Patient National ID';

  @override
  String get tableCore_patientRowFullNameColumn => 'Full Name';

  @override
  String get tableCore_inconsistencyCabinColumn => 'Cabinet';

  @override
  String get tableCore_inconsistencyRowNoColumn => 'Row No.';

  @override
  String get tableCore_inconsistencyCellColumn => 'Cell';

  @override
  String get tableCore_inconsistencyExpectedColumn => 'Expected';

  @override
  String get tableCore_inconsistencyCountedColumn => 'Counted Quantity';

  @override
  String get tableCore_stockTransactionDateColumn => 'Date';

  @override
  String get tableCore_stockTransactionBarcodeColumn => 'Barcode';

  @override
  String get tableCore_stockTransactionTypeColumn => 'Transaction Type';

  @override
  String get tableCore_stockTransactionQuantityColumn => 'Quantity';

  @override
  String get tableCore_stockTransactionPreviousQuantityColumn =>
      'Quantity Before Movement';

  @override
  String get tableCore_stockTransactionActorColumn => 'Performed By';

  @override
  String get tableCore_serviceColumn => 'Service';

  @override
  String get tableCore_admissionDateColumn => 'Admission Date';

  @override
  String get tableCore_dischargeDateColumn => 'Discharge Date';

  @override
  String get tableCore_materialColumn => 'Material';

  @override
  String get enumCore_statusActive => 'Active';

  @override
  String get enumCore_statusPassive => 'Inactive';

  @override
  String get enumCore_warehouseTypeMain => 'Main Warehouse';

  @override
  String get enumCore_firmTypeSupplier => 'Supplier';

  @override
  String get enumCore_firmTypeCustomer => 'Customer';

  @override
  String get enumCore_firmTypeManufacturer => 'Manufacturer';

  @override
  String get enumCore_warningSubjectUntimelyPurchase => 'Untimely Purchase';

  @override
  String get enumCore_warningSubjectWaste => 'Waste';

  @override
  String get enumCore_warningSubjectInconsistencyResolution =>
      'Inconsistency Resolution';

  @override
  String get enumCore_warningSubjectDisposal => 'Disposal';

  @override
  String get enumCore_stockTxKindRefill => 'Material Refill';

  @override
  String get enumCore_stockTxKindStockOut => 'Stock Out';

  @override
  String get enumCore_stockTxKindConsistent => 'Consistent Count';

  @override
  String get enumCore_stockTxKindReturnInward => 'Return Intake';

  @override
  String get enumCore_stockTxKindWastage => 'Wastage';

  @override
  String get enumCore_stockTxTypeIn => 'Stock In';

  @override
  String get enumCore_stockTxTypeOut => 'Stock Out';

  @override
  String get enumCore_stockTxKindReturn => 'Material Return';

  @override
  String get enumCore_stockTxKindExcess => 'Count Excess';

  @override
  String get enumCore_stockTxKindShortage => 'Count Shortage';

  @override
  String get enumCore_stockTxKindPurchase => 'Material Intake';

  @override
  String get enumCore_stockTxKindUnload => 'Material Unload';

  @override
  String get enumCore_countTypeNone => 'No Census';

  @override
  String get enumCore_countTypeNormal => 'Normal Census';

  @override
  String get enumCore_countTypeBlind => 'Blind Census';

  @override
  String get enumCore_returnTypeToOrigin => 'Return to Origin';

  @override
  String get enumCore_returnTypeToDrawer => 'Return to Drawer';

  @override
  String get enumCore_returnTypeToReturnBox => 'Return to Return Box';

  @override
  String get enumCore_returnTypeToPharmacy => 'Return to Pharmacy';

  @override
  String get enumCore_requestTypeNormal => 'Normal Request';

  @override
  String get enumCore_requestTypeUrgent => 'Urgent Request';

  @override
  String get enumCore_purchaseTypeBoth => 'Both';

  @override
  String get enumCore_prescriptionTypeWhite => 'White Prescription';

  @override
  String get enumCore_prescriptionTypeSerumWhite =>
      'Serum (White Prescription)';

  @override
  String get enumCore_prescriptionTypeRed => 'Red Prescription';

  @override
  String get enumCore_prescriptionTypeGreen => 'Green Prescription';

  @override
  String get enumCore_prescriptionTypeOrange => 'Orange Prescription';

  @override
  String get enumCore_prescriptionTypePurple => 'Purple Prescription';

  @override
  String get enumCore_refillListStatusToCollect => 'To Collect';

  @override
  String get enumCore_refillListStatusCollected => 'Collected';

  @override
  String get enumCore_refillListStatusSent => 'Sent';

  @override
  String get enumCore_fillingTypeMinimum => 'Minimum';

  @override
  String get enumCore_fillingTypeCritical => 'Critical';

  @override
  String get enumCore_fillingTypeMaximum => 'Maximum';

  @override
  String get enumCore_patientFilterOrderTimeReached => 'Order Time Reached';

  @override
  String get enumCore_patientFilterAll => 'All Patients';

  @override
  String get enumCore_patientFilterTimeNotReached => 'Time Not Reached Yet';

  @override
  String get enumCore_patientFilterTimePassed => 'Time Passed';

  @override
  String get enumCore_patientFilterReturnable => 'Return Available';

  @override
  String get enumCore_patientFilterWasteDisposable =>
      'Waste/Disposal Available';

  @override
  String get enumCore_cabinTypeStandard => 'Standard Cabinet';

  @override
  String get enumCore_cabinTypeCloset => 'Closet';

  @override
  String get enumCore_cabinTypeFridge => 'Refrigerator';

  @override
  String get enumCore_cabinTypeOpenCloset => 'Open Closet';

  @override
  String get enumCore_cabinTypeMobile => 'Mobile Cabinet';

  @override
  String get enumCore_cabinTypeExternalReturn => 'External Return Cabinet';

  @override
  String get enumCore_cabinTypeOpen => 'Open Cabinet';

  @override
  String get enumCore_cabinTypeSerum => 'Serum Cabinet';

  @override
  String get enumCore_cabinOpModeAssignDrug => 'Drug Assignment';

  @override
  String get enumCore_cabinOpModeRefill => 'Drug Refill';

  @override
  String get enumCore_cabinOpModeCensus => 'Drug Census';

  @override
  String get enumCore_cabinOpModeIntake => 'Drug Intake';

  @override
  String get enumCore_cabinOpModeFault => 'Drawer Fault';

  @override
  String get enumCore_cabinOpModeUnload => 'Drug Unload';

  @override
  String get enumCore_permissionCan => 'Can';

  @override
  String get enumCore_permissionCannot => 'Cannot';

  @override
  String get enumCore_genderFemale => 'Female';

  @override
  String get enumCore_genderMale => 'Male';

  @override
  String get enumCore_genderUnknown => 'Unknown';

  @override
  String get enumCore_userTypeUnlimited => 'Unlimited';

  @override
  String get enumCore_appModeAdmin => 'Admin';

  @override
  String get enumCore_appModeManager => 'Management';

  @override
  String get enumCore_appModeStation => 'Station';

  @override
  String get enumCore_userRoleManager => 'Manager';

  @override
  String get enumCore_userRoleStationOperator => 'Station Operator';

  @override
  String get enumCore_parityBitNone => 'None';

  @override
  String get enumCore_parityBitEven => 'Even';

  @override
  String get enumCore_parityBitOdd => 'Odd';

  @override
  String get enumCore_cabinColorBlue => 'Blue';

  @override
  String get enumCore_cabinColorTurquoise => 'Turquoise';

  @override
  String get enumCore_cabinColorGreen => 'Green';

  @override
  String get enumCore_cabinColorRed => 'Red';

  @override
  String get enumCore_cabinColorOrange => 'Orange';

  @override
  String get enumCore_cabinColorPurple => 'Purple';

  @override
  String get enumCore_cabinColorGray => 'Gray';

  @override
  String get enumCore_cabinColorBlack => 'Black';

  @override
  String get enumCore_cabinColorWhite => 'White';

  @override
  String get common_confirmButton => 'Confirm';

  @override
  String get common_warningTitle => 'Warning!';

  @override
  String get dialog_deleteTitle => 'Delete';

  @override
  String get dialog_deleteDefaultMessage =>
      'Are you sure you want to delete this item?';

  @override
  String dialog_deleteItemMessage(String itemName) {
    return 'Are you sure you want to delete \"$itemName\"?\nThis action cannot be undone.';
  }

  @override
  String get dialog_exitConfirmButtonText => 'Exit';

  @override
  String get dialog_exitConfirmMessage =>
      'You have unsaved changes. If you exit, these changes will be lost.';

  @override
  String get dialog_exitConfirmMessageNoChanges =>
      'Are you sure you want to leave this page?';

  @override
  String get dialog_confirmDiscardButton => 'Yes, Discard';

  @override
  String get dialog_logoutTitle => 'Log Out';

  @override
  String get dialog_logoutMessage =>
      'Are you sure you want to log out of your account?';

  @override
  String get table_noDataTitle => 'No data found';

  @override
  String get table_actionsColumnHeader => 'Actions';

  @override
  String get table_activeFiltersLabel => 'Filters:';

  @override
  String get common_clearButton => 'Clear';

  @override
  String table_selectedCountLabel(int count) {
    return '$count selected';
  }

  @override
  String table_columnSelectedCountLabel(String column, int count) {
    return '$column: $count selected';
  }

  @override
  String get table_columnFallbackLabel => 'Column';

  @override
  String table_selectAllCountLabel(int count) {
    return 'Select All ($count)';
  }

  @override
  String get table_noResultsShort => 'No results';

  @override
  String table_applyCountLabel(int count) {
    return 'Apply ($count)';
  }

  @override
  String get table_applyButton => 'Apply';

  @override
  String table_recordCountFiltered(int filtered, int total) {
    return '$filtered / $total records';
  }

  @override
  String table_recordCount(int total) {
    return '$total records';
  }

  @override
  String table_totalRecordCount(int total) {
    return 'Total $total records';
  }

  @override
  String get table_prevPageTooltip => 'Previous page';

  @override
  String get table_nextPageTooltip => 'Next page';

  @override
  String get table_exportSelectedTooltip => 'Export Selected';

  @override
  String get table_categoriesDefaultTitle => 'Categories';

  @override
  String table_columnFallback(int index) {
    return 'Column $index';
  }

  @override
  String get dateFilter_yesterday => 'Yesterday';

  @override
  String get dateFilter_lastWeek => 'Last Week';

  @override
  String get dateFilter_thisMonth => 'This Month';

  @override
  String get dateFilter_last30Days => 'Last 30 Days';

  @override
  String get dateFilter_customRange => 'Set Custom Range...';

  @override
  String get dateFilter_clearFilter => 'Clear Filter';

  @override
  String get dateFilter_noFilter => 'No Filter';

  @override
  String get dateFilter_selectedRange => 'Selected Range';

  @override
  String get dateFilter_selectRangeTitle => 'Select Date Range';

  @override
  String get dateFilter_startDate => 'Start';

  @override
  String get dateFilter_endDate => 'End';

  @override
  String get common_selectPlaceholder => 'Please select';

  @override
  String selectionDialog_selectedCount(int count) {
    return '$count items selected';
  }

  @override
  String get selectionDialog_noSelection => 'No selection made';

  @override
  String get selectionDialog_confirmButton => 'Select';

  @override
  String get dateField_placeholder => 'Select date';

  @override
  String timeField_helpTextWithDay(String day) {
    return 'Select a time for $day';
  }

  @override
  String get timeField_helpText => 'Select a time';

  @override
  String get timeField_placeholder => 'Select time';

  @override
  String doseStepper_manualEntryTitle(String unit) {
    return 'Enter $unit Amount';
  }

  @override
  String get numpad_defaultTitle => 'Enter Amount';

  @override
  String get keyboard_closeButton => 'Close';

  @override
  String get keyboard_enterLabel => '↵ OK';

  @override
  String get keyboard_dashKeyLabel => '— Dash';

  @override
  String get keyboard_periodKeyLabel => '. Period';

  @override
  String get keyboard_shiftLabel => '⇧ Shift';

  @override
  String get keyboard_spaceLabel => 'SPACE';

  @override
  String get staleBanner_justNow => 'just now';

  @override
  String staleBanner_minutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String staleBanner_hoursAgo(int hours) {
    return '$hours hr ago';
  }

  @override
  String get staleBanner_dataStaleMessage => 'Data is not up to date. ';

  @override
  String get staleBanner_dataUnavailableMessage =>
      'Up-to-date data is unavailable. The operation cannot proceed. ';

  @override
  String staleBanner_lastUpdatedLabel(String time) {
    return 'Last updated: $time';
  }

  @override
  String get staleBanner_blockedBadge => 'Blocked';

  @override
  String timeChip_today(String time) {
    return 'Today $time';
  }

  @override
  String timeChip_tomorrow(String time) {
    return 'Tomorrow $time';
  }

  @override
  String get cabin_lockButton => 'Lock';

  @override
  String get cabin_criticalStockLabel => 'Critical Stock';

  @override
  String get cabin_criticalStockSubLabel => 'refill needed';

  @override
  String get cabin_legendFillNormal => 'Normal stock';

  @override
  String get cabin_legendFillNeeded => 'Refill needed';

  @override
  String get cabin_legendFillUrgent => 'Urgent refill';

  @override
  String get cabin_serumTypeLabel => 'SERUM';

  @override
  String get cabin_unitDoseTypeLabel => 'U.DOSE';

  @override
  String get refund_showCompletedTooltip => 'Show Completed';

  @override
  String get refund_showIncompleteTooltip => 'Show Incomplete';

  @override
  String get dashboard_sensor_title => 'Sensors';

  @override
  String get dashboard_sensor_temperature => 'Temperature';

  @override
  String get dashboard_sensor_humidity => 'Humidity';

  @override
  String get dashboard_sensor_battery => 'Battery';

  @override
  String get dashboard_climate_title => 'Environment';

  @override
  String get dashboard_sensor_outOfRange => 'Out of range';

  @override
  String get dashboard_upcomingTreatmentsPanelTitle => 'Upcoming Treatments';

  @override
  String dashboard_upcomingTreatmentsCountBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scheduled',
      one: '$count scheduled',
    );
    return '$_temp0';
  }

  @override
  String get dashboard_upcomingTreatmentsEmptyTitle =>
      'No scheduled treatments';

  @override
  String get dashboard_upcomingTreatmentsOverdueStatus => 'overdue';

  @override
  String get dashboard_drugActivityPanelTitle => 'Drug Activity';

  @override
  String get dashboard_drugActivityEmptyTitle => 'No activity yet';

  @override
  String get dashboard_activitiesLoadError =>
      'Drug activity could not be loaded';

  @override
  String get dashboard_telemetryPanelTitle => 'Cabin Climate';

  @override
  String get dashboard_telemetryPausedStatus => 'Paused';

  @override
  String get dashboard_kpiActivePatientsLabel => 'Active Patients';

  @override
  String get dashboard_kpiCompletedOperationsLabel => 'Completed Operations';

  @override
  String get dashboard_kpiPendingPrescriptionsLabel => 'Pending Prescriptions';

  @override
  String get dashboard_kpiCriticalAlertsLabel => 'Critical Alerts';

  @override
  String get common_seeAllButton => 'See All';

  @override
  String get common_unknownFallback => 'Unknown';

  @override
  String get common_justNowStatus => 'just now';

  @override
  String common_minutesAgoStatus(int count) {
    return '$count min ago';
  }

  @override
  String common_hoursAgoStatus(int count) {
    return '$count h ago';
  }

  @override
  String common_daysAgoStatus(int count) {
    return '$count d ago';
  }

  @override
  String common_minutesRemainingStatus(int count) {
    return 'in $count min';
  }

  @override
  String common_hoursRemainingStatus(int count) {
    return 'in $count h';
  }

  @override
  String common_daysRemainingStatus(int count) {
    return 'in $count d';
  }

  @override
  String get refill_hint_selectSlots =>
      'Select the cells to fill. Low-stock cells are marked.';

  @override
  String get refill_title_fillCells => 'Fill Cells';

  @override
  String get refill_hint_miadRequired => 'Expiry date required';

  @override
  String get refill_status_openingTitle => 'Opening drawer…';

  @override
  String get refill_status_openingBody =>
      'Please wait, the physical drawer is opening.';

  @override
  String get refill_status_waitingPullTitle => 'Pull the drawer';

  @override
  String get refill_status_waitingPullBody =>
      'The lock is released. Pull the drawer to continue.';

  @override
  String get refill_status_openingLidTitle => 'Opening cell…';

  @override
  String get refill_status_openingLidBody =>
      'Please wait, the cell lid is opening.';

  @override
  String get refill_status_stockOk => 'In stock';

  @override
  String get refill_status_stockLow => 'Low';

  @override
  String get refill_status_stockCritical => 'Critical';

  @override
  String get refill_stop_confirmTitle => 'Stop the refill?';

  @override
  String get refill_stop_confirmMessage =>
      'If you stop, the open drawer will be locked and this refill will be marked as partially completed. Entered counts and fill amounts are kept, but you cannot resume — you must start a new refill.';

  @override
  String get refill_stop_confirmYes => 'Yes, Stop';
}
