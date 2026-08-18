// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

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
  String get common_boolYes => 'Oui';

  @override
  String get common_boolNo => 'Non';

  @override
  String get common_action_discharge => 'Sortie du patient';

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
      'Impossible de charger les traitements à venir';

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
  String get census_action_start => 'Démarrer l\'inventaire';

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
  String get unload_action_start => 'Démarrer le déchargement';

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
  String get waste_action_wastage => 'Perte';

  @override
  String get waste_action_destruction => 'Destruction';

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
  String get date_preset_today => 'Aujourd\'hui';

  @override
  String get date_preset_tomorrow => 'Demain';

  @override
  String get date_preset_last_3_days => '3 derniers jours';

  @override
  String get date_preset_last_7_days => '7 derniers jours';

  @override
  String get date_preset_all => 'Tout';

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
  String get core_serialPortDisconnectedLabel => 'Non connecté';

  @override
  String core_serialConnectingStatus(String portName) {
    return 'Connexion au port : $portName...';
  }

  @override
  String core_serialConnectSuccessStatus(String portName) {
    return 'Connexion réussie : $portName';
  }

  @override
  String core_serialPortFailedScanningOthersStatus(String portName) {
    return 'Échec de $portName. Analyse des autres ports...';
  }

  @override
  String core_serialNoOtherPortsError(String portName) {
    return 'Le port par défaut ($portName) a échoué et aucun autre port n\'a été trouvé.';
  }

  @override
  String core_serialTryingPortStatus(String portName) {
    return 'Tentative : $portName...';
  }

  @override
  String core_serialConnectionEstablishedStatus(String portName) {
    return 'Connexion établie : $portName';
  }

  @override
  String get core_serialNoPortConnectedError =>
      'Impossible de se connecter à un port. Vérifiez les câbles.';

  @override
  String core_serialPortOpenFailedError(String portName) {
    return 'Le port n\'a pas pu être ouvert ($portName).';
  }

  @override
  String get core_serialNoConnectionError => 'Aucune connexion.';

  @override
  String get core_serialPortBusyTimeoutError => 'Délai d\'expiration du port.';

  @override
  String get core_serialWriteFailedError => 'Échec de l\'écriture.';

  @override
  String get common_defaultSuccessMessage => 'Opération réussie';

  @override
  String get common_operationSuccessMessage =>
      'Votre opération a été effectuée avec succès.';

  @override
  String get common_loadingEllipsis => 'Chargement...';

  @override
  String get common_searchHint => 'Rechercher...';

  @override
  String get common_searchTooltip => 'Rechercher';

  @override
  String get common_addTooltip => 'Ajouter';

  @override
  String get common_closeTooltip => 'Fermer';

  @override
  String get common_saveButton => 'Enregistrer';

  @override
  String get common_editTooltip => 'Modifier';

  @override
  String get common_deleteTooltip => 'Supprimer';

  @override
  String get common_statusLabel => 'Statut';

  @override
  String get common_emptyListMessage => 'La liste est actuellement vide';

  @override
  String get common_nameLabel => 'Nom';

  @override
  String get common_requiredFieldsError =>
      'Veuillez remplir les champs obligatoires.';

  @override
  String get common_descriptionLabel => 'Description';

  @override
  String get common_deselectAllButton => 'Tout désélectionner';

  @override
  String get common_selectAllButton => 'Tout sélectionner';

  @override
  String get common_defaultUnitFallback => 'Pièce';

  @override
  String get common_flagFirstDoseEmergency => 'Première dose urgente';

  @override
  String get common_flagAskDoctor => 'Demander au médecin';

  @override
  String get common_flagInCaseOfNecessity => 'Si nécessaire';

  @override
  String common_addItemHint(String item) {
    return 'Appuyez sur le bouton « + » pour ajouter un(e) nouveau/nouvelle $item';
  }

  @override
  String get common_genericErrorMessage => 'Une erreur s\'est produite.';

  @override
  String get hospitalizationCard_noDoctorFallback => 'Aucun médecin spécifié';

  @override
  String get hospitalizationCard_nationalIdLabel => 'N° d\'identité nationale';

  @override
  String get hospitalizationCard_admissionDateLabel => 'Date d\'admission';

  @override
  String get menuBrowser_categoriesHeader => 'CATÉGORIES';

  @override
  String get menuBrowser_searchHint => 'Rechercher une catégorie...';

  @override
  String menuBrowser_selectionCountBadge(int selected, int total) {
    return '$selected/$total';
  }

  @override
  String get menuBrowser_emptyCategoryMessage =>
      'Aucun menu trouvé dans cette catégorie';

  @override
  String rxGroup_headerTitle(Object id) {
    return 'Ordonnance n° $id';
  }

  @override
  String rxGroup_headerSubtitle(String doctorName, String date) {
    return '$doctorName · $date';
  }

  @override
  String rxGroup_itemCountBadge(int count) {
    return '$count articles';
  }

  @override
  String rxGroup_selectableCountLabel(int count) {
    return '$count articles pouvant faire l\'objet d\'une action';
  }

  @override
  String get rxGroup_unknownDoctorFallback => 'Inconnu';

  @override
  String get rxGroup_rfidTagLabel => 'ÉTIQUETTE RFID';

  @override
  String get rxGroup_rfidTagLoadingLabel => 'En attente de l\'étiquette...';

  @override
  String get rxGroup_rfidTagUnassignedLabel =>
      'Aucune étiquette assignée pour le moment';

  @override
  String get rxGroup_rfidChangeButton => 'Modifier';

  @override
  String get rxGroup_rfidAssignButton => 'Assigner une étiquette';

  @override
  String rxGroup_selectedCountBar(int count) {
    return '$count articles sélectionnés';
  }

  @override
  String get rxGroup_approveAction => 'Approuver';

  @override
  String get rxGroup_rejectAction => 'Rejeter';

  @override
  String get changePassword_dialogTitle => 'Changer le mot de passe';

  @override
  String get changePassword_currentPasswordLabel => 'Mot de passe actuel';

  @override
  String get changePassword_newPasswordLabel => 'Nouveau mot de passe';

  @override
  String get changePassword_confirmPasswordLabel =>
      'Confirmer le nouveau mot de passe';

  @override
  String get changePassword_submitButton => 'Changer le mot de passe';

  @override
  String get home_appBarBadgeLabel => 'PANNEAU DE GESTION';

  @override
  String get home_devSettingsTooltip => 'Paramètres développeur';

  @override
  String get home_noAuthorizedMenuTitle => 'Aucun menu autorisé trouvé';

  @override
  String get home_noAuthorizedMenuDescription =>
      'Aucune autorisation d\'accès n\'est définie pour votre compte.\nVeuillez contacter votre administrateur système pour obtenir un accès.';

  @override
  String get branch_listDialogTitle => 'Définition de la spécialité';

  @override
  String get branch_addTitle => 'Ajouter une spécialité';

  @override
  String get branch_editTitle => 'Modifier la spécialité';

  @override
  String get branch_nameLabel => 'Nom de la spécialité';

  @override
  String get firm_createSuccessMessage => 'Entreprise créée avec succès';

  @override
  String get firm_updateSuccessMessage => 'Entreprise mise à jour avec succès';

  @override
  String get firm_createPanelTitle => 'Nouvelle entreprise';

  @override
  String get firm_editPanelTitle => 'Modifier l\'entreprise';

  @override
  String get firm_createPanelSubtitle =>
      'Renseignez les informations de l\'entreprise';

  @override
  String get firm_editPanelSubtitle =>
      'Mettez à jour les informations de l\'entreprise';

  @override
  String get firm_nameLabel => 'Nom de l\'entreprise';

  @override
  String get firm_taxNoLabel => 'N° fiscal';

  @override
  String get firm_taxOfficeLabel => 'Centre des impôts';

  @override
  String get firm_typeLabel => 'Type d\'entreprise';

  @override
  String get firm_screenDefaultTitle => 'Définition de l\'entreprise';

  @override
  String get dosageForm_deleteSuccessMessage =>
      'La forme posologique a été supprimée avec succès.';

  @override
  String get dosageForm_saveSuccessMessage =>
      'La forme posologique a été enregistrée avec succès.';

  @override
  String get dosageForm_createTitle => 'Créer une forme posologique';

  @override
  String get dosageForm_editTitle => 'Modifier la forme posologique';

  @override
  String get dosageForm_listDialogTitle => 'Forme posologique';

  @override
  String get dosageForm_emptyTitle => 'Aucune forme posologique pour le moment';

  @override
  String get dosageForm_emptyDescription =>
      'Appuyez sur le bouton « + » pour créer une forme posologique';

  @override
  String get authorization_userTabTitle => 'Autorisation utilisateur';

  @override
  String get authorization_roleTabTitle => 'Autorisation de rôle';

  @override
  String get authorization_screenTitleFallback =>
      'Autorisation utilisateur/rôle';

  @override
  String authorization_rolePanelTitle(String roleName) {
    return 'Autorisation de rôle - $roleName';
  }

  @override
  String get authorization_tabMenuLabel => 'Menu';

  @override
  String get authorization_tabDrugLabel => 'Médicament';

  @override
  String get authorization_tabConsumableLabel => 'Consommable médical';

  @override
  String get authorization_drugTable_pullColumn => 'Prélever le médicament';

  @override
  String get authorization_drugTable_fillColumn => 'Remplissage';

  @override
  String get authorization_drugTable_returnColumn => 'Retour';

  @override
  String get authorization_drugTable_disposeColumn => 'Élimination';

  @override
  String get authorization_drugTable_allDrugsRow => 'Tous les médicaments';

  @override
  String get authorization_drugTable_unknownDrugFallback =>
      'Médicament inconnu';

  @override
  String get settings_updateSuccessMessage =>
      'Paramètres mis à jour avec succès.';

  @override
  String get settingsCabin_drawerOpenWaitLabel =>
      'Délai d\'attente tiroir ouvert (secondes)';

  @override
  String get settingsCabin_drawerOpenWaitDescription =>
      'Indique quand le système enverra une commande de fermeture au tiroir s\'il reste ouvert.';

  @override
  String get settingsDeveloper_adminDashboardActiveLabel =>
      'Tableau de bord admin actif';

  @override
  String get settingsDeveloper_appModeLabel => 'Mode de l\'application';

  @override
  String get settingsDeveloper_clientModeButton => 'Mode client';

  @override
  String get settingsDeveloper_managerModeButton => 'Mode gestionnaire';

  @override
  String get settingsGeneral_autoStandbyDurationLabel =>
      'Durée avant mise en veille automatique (secondes)';

  @override
  String get settingsGeneral_expiryWarningLabel => 'Alerte d\'expiration';

  @override
  String get settingsGeneral_hbysStockControlLabel => 'Contrôle de stock SIH';

  @override
  String get settingsGeneral_fingerprintOnlyLabel =>
      'N\'autoriser que le lecteur d\'empreintes digitales sur les cabines.';

  @override
  String get settingsGeneral_allowOutOfWindowOrdersLabel =>
      'Les commandes hors délai peuvent être acceptées.';

  @override
  String get settingsGeneral_perCellExpiryDateLabel =>
      'Autoriser la saisie d\'une date d\'expiration distincte pour chaque compartiment des tiroirs à dose unitaire lors du remplissage.';

  @override
  String get settingsGeneral_collectOrderTimeLabel =>
      'Plage horaire de consultation des détails de commande (heures)';

  @override
  String get settingsGeneral_wasteDestructionTimeLabel =>
      'Délai de péremption/destruction (heures)';

  @override
  String get settingsGeneral_wasteOrderReactivateLabel =>
      'Réactiver la commande après péremption/destruction';

  @override
  String get settingsGeneral_badgeCardPasswordLabel =>
      'Exiger un mot de passe lors de la connexion par badge';

  @override
  String get settingsPrescription_accessDurationLabel =>
      'Durée d\'accès à l\'ordonnance (minutes)';

  @override
  String get settingsPrescription_accessDurationDescription =>
      'Indique la durée pendant laquelle les ordonnances restent accessibles avant et après les heures de retrait des produits.';

  @override
  String get settingsView_cabinTabTitle =>
      'Paramètres de communication de la cabine';

  @override
  String get settingsView_prescriptionTabTitle => 'Paramètres de l\'ordonnance';

  @override
  String get settingsView_generalTabTitle => 'Paramètres généraux';

  @override
  String get settingsView_developerTabTitle => 'Paramètres développeur';

  @override
  String get settingsView_refreshPermissionsButton =>
      'Actualiser les autorisations';

  @override
  String stationSetup_defaultRoomName(int index) {
    return 'Chambre $index';
  }

  @override
  String get stationSetup_service_createdSuccessMessage =>
      'Service créé avec succès';

  @override
  String get stationSetup_service_updatedSuccessMessage =>
      'Service mis à jour avec succès';

  @override
  String get stationSetup_roomsSectionTitle => 'Chambres et lits';

  @override
  String stationSetup_roomsBedsSummary(int roomCount, int bedCount) {
    return '$roomCount chambres · $bedCount lits';
  }

  @override
  String get stationSetup_addRoomButton => 'Ajouter une chambre';

  @override
  String stationSetup_bedCountBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lits',
      one: '$count lit',
    );
    return '$_temp0';
  }

  @override
  String get stationSetup_noBedsAddedYetMessage =>
      'Aucun lit ajouté pour le moment';

  @override
  String get stationSetup_addBedButton => 'Ajouter un lit';

  @override
  String get stationSetup_service_formTitleNew => 'Nouveau service';

  @override
  String get stationSetup_service_formTitleEdit => 'Modifier le service';

  @override
  String get stationSetup_service_formSubtitleNew =>
      'Renseignez les informations du service';

  @override
  String get stationSetup_service_formSubtitleEdit =>
      'Mettez à jour les informations du service';

  @override
  String get stationSetup_service_nameLabel => 'Nom du service';

  @override
  String get stationSetup_service_branchLabel => 'Spécialité';

  @override
  String get stationSetup_service_branchSelectTitle =>
      'Sélectionner une spécialité';

  @override
  String get stationSetup_service_userLabel => 'Utilisateur';

  @override
  String get stationSetup_common_statusLabel => 'Statut';

  @override
  String get stationSetup_station_createdSuccessMessage =>
      'Station créée avec succès';

  @override
  String get stationSetup_station_updatedSuccessMessage =>
      'Station mise à jour avec succès';

  @override
  String get stationSetup_station_formTitleNew => 'Nouvelle station';

  @override
  String get stationSetup_station_formTitleEdit => 'Modifier la station';

  @override
  String get stationSetup_station_formSubtitleNew =>
      'Renseignez les informations de la station';

  @override
  String get stationSetup_station_formSubtitleEdit =>
      'Mettez à jour les informations de la station';

  @override
  String get stationSetup_station_nameLabel => 'Nom de la station';

  @override
  String get stationSetup_station_drugWarehouseLabel =>
      'Entrepôt de médicaments';

  @override
  String get stationSetup_station_drugWarehouseSelectTitle =>
      'Sélectionner un entrepôt de médicaments';

  @override
  String get stationSetup_station_drugStatusLabel => 'Statut du médicament';

  @override
  String get stationSetup_station_consumableWarehouseLabel =>
      'Entrepôt de consommables médicaux';

  @override
  String get stationSetup_station_consumableWarehouseSelectTitle =>
      'Sélectionner un entrepôt de consommables médicaux';

  @override
  String get stationSetup_station_consumableStatusLabel =>
      'Statut du consommable médical';

  @override
  String get stationSetup_station_serviceLabel => 'Service';

  @override
  String get stationSetup_station_serviceSelectTitle =>
      'Sélectionner un service';

  @override
  String get stationSetup_station_providedServicesLabel => 'Services desservis';

  @override
  String get stationSetup_station_typeLabel => 'Type de station';

  @override
  String get stationSetup_station_typePatientBasedLabel =>
      'Basé sur le patient';

  @override
  String get stationSetup_station_typeMedicineBasedLabel =>
      'Basé sur le médicament';

  @override
  String get stationSetup_warehouse_createdSuccessMessage =>
      'Entrepôt créé avec succès';

  @override
  String get stationSetup_warehouse_updatedSuccessMessage =>
      'Entrepôt mis à jour avec succès';

  @override
  String get stationSetup_warehouse_formTitleNew => 'Nouvel entrepôt';

  @override
  String get stationSetup_warehouse_formTitleEdit => 'Modifier l\'entrepôt';

  @override
  String get stationSetup_warehouse_formSubtitleNew =>
      'Renseignez les informations de l\'entrepôt';

  @override
  String get stationSetup_warehouse_formSubtitleEdit =>
      'Mettez à jour les informations de l\'entrepôt';

  @override
  String get stationSetup_warehouse_codeLabel => 'Code de l\'entrepôt';

  @override
  String get stationSetup_warehouse_nameLabel => 'Nom de l\'entrepôt';

  @override
  String get stationSetup_warehouse_typeLabel => 'Type d\'entrepôt';

  @override
  String get stationSetup_warehouse_managerLabel =>
      'Responsable de l\'entrepôt';

  @override
  String get stationSetup_warehouse_managerSelectTitle =>
      'Sélectionner un responsable d\'entrepôt';

  @override
  String get stationSetup_screen_stationTabTitle => 'Définition de la station';

  @override
  String get stationSetup_screen_serviceTabTitle => 'Définition du service';

  @override
  String get stationSetup_screen_warehouseTabTitle =>
      'Définition de l\'entrepôt';

  @override
  String get stationSetup_screen_setupWizardButton =>
      'Assistant de configuration';

  @override
  String get stationSetup_wizard_title =>
      'Assistant de configuration de la station';

  @override
  String get stationSetup_wizard_completeSetupButton =>
      'Terminer la configuration';

  @override
  String get stationSetup_wizard_continueButton => 'Continuer';

  @override
  String get stationSetup_wizard_backButton => 'Retour';

  @override
  String get unappliedPrescription_detailDialogTitle => 'Liste des matériaux';

  @override
  String get unappliedPrescription_screenTitleFallback =>
      'Ordonnances non appliquées';

  @override
  String get unappliedPrescription_viewDetailsTooltip => 'Voir les détails';

  @override
  String get dashboardCabinsLoadErrorFallback =>
      'Les cabines n\'ont pas pu être chargées';

  @override
  String get dashboardCabinListStaleLabel =>
      'La liste des cabines n\'est pas à jour';

  @override
  String get dashboardDrugActivityPanelTitle => 'MOUVEMENTS DE MÉDICAMENTS';

  @override
  String get dashboardDrugActivityEmptyTitle => 'Aucun mouvement';

  @override
  String get dashboardDrugActivityDateTimeLabel => 'DATE / HEURE';

  @override
  String get dashboardMissingStockPanelTitle =>
      'SIGNALEMENTS DE STOCK MANQUANT';

  @override
  String get dashboardMissingStockEmptyTitle =>
      'Aucun signalement de stock manquant';

  @override
  String get dashboardMissingStockTimeLabel => 'HEURE';

  @override
  String get dashboardMissingStockApproveButton => 'Approuver';

  @override
  String get dashboardMissingStockRejectButton => 'Rejeter';

  @override
  String get dashboardOtherCabinPlaceholderText =>
      'Matériaux périmés et stocks critiques (prochainement)';

  @override
  String get dashboardUnappliedPrescriptionsPanelTitle =>
      'ORDONNANCES NON APPLIQUÉES';

  @override
  String get dashboardUnappliedPrescriptionsEmptyTitle =>
      'Aucune ordonnance non appliquée';

  @override
  String get dashboardDoctorLabel => 'MÉDECIN';

  @override
  String get dashboardRoomBedLabel => 'CHAMBRE / LIT';

  @override
  String get dashboardUpcomingTreatmentsPanelTitle => 'TRAITEMENTS À VENIR';

  @override
  String get dashboardUpcomingTreatmentsEmptyTitle =>
      'Aucun traitement à venir';

  @override
  String get dashboardListPanelLoadErrorFallback => 'Le chargement a échoué';

  @override
  String get prescriptionActionCompletedSuccess =>
      'L\'opération a été effectuée avec succès.';

  @override
  String get prescriptionApprovedSuccess =>
      'L\'ordonnance a été approuvée avec succès.';

  @override
  String get prescriptionDetailPanelPatientFallback => 'Patient';

  @override
  String get prescriptionDetailPanelSubtitle => 'Historique des ordonnances';

  @override
  String get prescriptionDetailStartDateLabel => 'Date de début';

  @override
  String get prescriptionDetailEndDateLabel => 'Date de fin';

  @override
  String get prescriptionDetailStatusLabel => 'Statut';

  @override
  String get prescriptionCheckWarningDialogTitle => 'Avertissement de contrôle';

  @override
  String get prescriptionSaveWithTemplateSuccess =>
      'L\'ordonnance et le modèle ont été enregistrés avec succès.';

  @override
  String get prescriptionSavedTemplateFailedMessage =>
      'L\'ordonnance a été enregistrée, mais le modèle n\'a pas pu être enregistré.';

  @override
  String get prescriptionSavedSuccess =>
      'L\'ordonnance a été enregistrée avec succès.';

  @override
  String get prescriptionCreatingLoadingMessage =>
      'Création de l\'ordonnance en cours. Veuillez patienter.';

  @override
  String get prescriptionTemplateSavingLoadingMessage =>
      'Enregistrement du modèle en cours.';

  @override
  String get prescriptionNewTitle => 'Nouvelle ordonnance';

  @override
  String get prescriptionNewDialogSubtitle =>
      'Créer une ordonnance ou en importer une depuis l\'historique';

  @override
  String get prescriptionTabHistory => 'Historique';

  @override
  String get prescriptionTabTemplates => 'Modèles';

  @override
  String get prescriptionContentEmptyTitle =>
      'Vous n\'avez pas encore ajouté de médicament à l\'ordonnance.';

  @override
  String get prescriptionContentEmptyDescription =>
      'Les médicaments que vous ajoutez s\'afficheront ici.';

  @override
  String get prescriptionItemNoTimesLabel => 'Aucun horaire ajouté';

  @override
  String get prescriptionItemNoMedicineSelected =>
      'Aucun médicament sélectionné pour le moment';

  @override
  String get prescriptionPatientFieldLabel => 'Patient';

  @override
  String get prescriptionDoctorFieldLabel => 'Médecin';

  @override
  String get prescriptionSaveButton => 'Enregistrer l\'ordonnance';

  @override
  String get prescriptionSaveAsTemplateCheckboxLabel =>
      'Enregistrer également comme modèle';

  @override
  String get prescriptionTemplateNameHint => 'Nom du modèle';

  @override
  String get prescriptionMedicineFieldLabel => 'Médicament / Matériel';

  @override
  String get prescriptionDescriptionFieldLabel => 'Description';

  @override
  String get prescriptionTomorrowLabel => 'Demain';

  @override
  String get prescriptionTimesLabel => 'Horaires';

  @override
  String get prescriptionAddTimeButton => 'Ajouter un horaire';

  @override
  String get prescriptionHistorySelectPatientTitle => 'Sélectionner un patient';

  @override
  String get prescriptionHistorySelectPatientDescription =>
      'Sélectionnez d\'abord un patient pour consulter son historique d\'ordonnances';

  @override
  String get prescriptionHistoryEmptyDescription =>
      'Ce patient n\'a aucun historique d\'ordonnances';

  @override
  String prescriptionAddToRxButton(int count) {
    return 'Ajouter à l\'ordonnance ($count)';
  }

  @override
  String get prescriptionTemplateEmptyTitle => 'Aucun modèle trouvé';

  @override
  String get prescriptionTemplateEmptyDescription =>
      'Aucun modèle d\'ordonnance enregistré';

  @override
  String get prescriptionTemplateNoItemsMessage =>
      'Ce modèle ne contient aucun article';

  @override
  String get prescriptionScreenTitleFallback => 'Opérations d\'ordonnance';

  @override
  String get prescriptionContentTooltip => 'Contenu de l\'ordonnance';

  @override
  String get prescriptionShowActiveButton => 'Afficher les admissions actives';

  @override
  String get prescriptionShowDischargedButton => 'Afficher les patients sortis';

  @override
  String get cabinTemperatureScreenTitle =>
      'Contrôle de température de la cabine';

  @override
  String get cabinTemperatureFormDialogTitle => 'Modifier la cabine';

  @override
  String get cabinTemperatureInsideBottomLabel =>
      'Température intérieure basse';

  @override
  String get cabinTemperatureInsideTopLabel => 'Température intérieure haute';

  @override
  String get cabinTemperatureOutsideBottomLabel =>
      'Température extérieure basse';

  @override
  String get cabinTemperatureOutsideTopLabel => 'Température extérieure haute';

  @override
  String get cabinTemperatureHumidityBottomLabel =>
      'Limite inférieure d\'humidité';

  @override
  String get cabinTemperatureHumidityTopLabel =>
      'Limite supérieure d\'humidité';

  @override
  String cabinTemperatureGenericErrorMessage(String error) {
    return 'Une erreur s\'est produite : $error';
  }

  @override
  String get cabinTemperatureStationNotSelectedError =>
      'Aucune station sélectionnée';

  @override
  String get cabinTemperatureCreateSuccess =>
      'Le paramètre de température de la cabine a été créé avec succès.';

  @override
  String get cabinTemperatureUpdateRecordNotFoundError =>
      'Aucun enregistrement trouvé à mettre à jour';

  @override
  String get cabinTemperatureUpdateSuccess =>
      'Le paramètre de température de la cabine a été mis à jour avec succès.';

  @override
  String get cabinTemperatureUnnamedStationFallback => 'Station sans nom';

  @override
  String get cabinTemperatureStationsLoadingMessage =>
      'Chargement des stations...';

  @override
  String get cabinTemperatureDetailsLoadingMessage =>
      'Chargement des détails de température...';

  @override
  String get cabinTemperatureColumnCabin => 'Cabine';

  @override
  String get directedOrdersScreenTitle => 'Liste des commandes dirigées';

  @override
  String get directedOrdersColumnProtocolNo => 'N° de protocole';

  @override
  String get directedOrdersColumnBed => 'Lit';

  @override
  String get directedOrdersColumnRoom => 'Chambre';

  @override
  String get directedOrdersMedicinesTooltip => 'Médicaments';

  @override
  String get directedOrdersPatientsLoadingMessage =>
      'Chargement des patients...';

  @override
  String get directedOrdersColumnBarcode => 'Code-barres';

  @override
  String get medicine_successCreated => 'Médicament créé';

  @override
  String get medicine_successUpdated => 'Médicament mis à jour';

  @override
  String get medicalConsumable_successCreated => 'Consommable médical créé';

  @override
  String get medicalConsumable_successUpdated =>
      'Consommable médical mis à jour';

  @override
  String get medicine_formTitleNew => 'Nouveau médicament';

  @override
  String get medicine_formTitleEdit => 'Modifier le médicament';

  @override
  String get medicine_formSubtitleNew =>
      'Renseignez les informations du médicament';

  @override
  String get medicine_formSubtitleEdit =>
      'Mettez à jour les informations du médicament';

  @override
  String get medicine_fieldDefinitionName => 'Nom de la définition';

  @override
  String get medicine_fieldBarcode => 'Code-barres';

  @override
  String get medicine_fieldName => 'Nom du médicament';

  @override
  String get medicine_fieldCode => 'Code du médicament';

  @override
  String get medicine_fieldPrescriptionType => 'Type d\'ordonnance';

  @override
  String get medicine_fieldDose => 'Dose';

  @override
  String get medicine_fieldManufacturer => 'Fabricant';

  @override
  String get medicine_fieldDailyMaxUsage =>
      'Quantité d\'utilisation maximale quotidienne';

  @override
  String get medicine_fieldDrugType => 'Type de médicament';

  @override
  String get medicine_fieldReturnType => 'Mode de retour';

  @override
  String get medicine_checkboxSerumMaxValue =>
      'Vérifier la valeur maximale dans l\'armoire à sérum';

  @override
  String get medicine_checkboxCubicMaxValue =>
      'Vérifier la valeur maximale dans le tiroir cubique';

  @override
  String get medicine_checkboxQrCode => 'Avec code QR';

  @override
  String get medicine_fieldPieceCountLabel => 'Nombre de pièces';

  @override
  String get medicine_fieldDrugClass => 'Classe de médicament';

  @override
  String get medicine_fieldPurchaseType => 'Mode d\'achat';

  @override
  String get medicine_checkboxUseMeasurementUnit =>
      'Utiliser une unité de mesure';

  @override
  String get medicine_fieldVolume => 'Volume';

  @override
  String get medicine_fieldDosageForm => 'Forme posologique';

  @override
  String get medicine_fieldStatus => 'Statut';

  @override
  String get medicine_fieldCountType => 'Type de comptage';

  @override
  String get medicine_fieldAtcCode => 'Code ATC';

  @override
  String get medicine_fieldEquivalentCode => 'Code équivalent';

  @override
  String get medicine_checkboxWitnessedPurchase => 'Achat avec témoin';

  @override
  String get medicine_checkboxWastageWitnessed =>
      'Perte/élimination avec témoin';

  @override
  String get medicine_checkboxDestroyable => 'Peut être éliminé';

  @override
  String get medicine_fieldActiveIngredient => 'Principe actif';

  @override
  String get medicine_fieldCollectNote => 'Note d\'achat';

  @override
  String get medicine_fieldReturnNote => 'Note de retour';

  @override
  String get medicine_fieldDestructionNote => 'Note d\'élimination';

  @override
  String get medicalConsumable_dialogTitle =>
      'Ajouter/Modifier un consommable médical';

  @override
  String get medicalConsumable_fieldName => 'Nom du matériel';

  @override
  String get medicalConsumable_fieldInstitutionCode =>
      'Code de l\'établissement';

  @override
  String get medicalConsumable_fieldSutCode => 'Code/Annexe SUT';

  @override
  String get medicalConsumable_fieldUbbCode => 'Code UBB';

  @override
  String get medicalConsumable_fieldMaterialType => 'Type de matériel';

  @override
  String get medicalConsumable_fieldStatus => 'Statut';

  @override
  String get medicine_screenTitleFallback =>
      'Définition médicament/consommable médical';

  @override
  String get medicine_newButtonLabel => 'Nouveau médicament';

  @override
  String get medicine_defineMedicalConsumableButton =>
      'Définir un consommable médical';

  @override
  String get medicine_defineActiveIngredientButton =>
      'Définir un principe actif';

  @override
  String get medicine_defineDrugClassButton =>
      'Définir une classe de médicament';

  @override
  String get medicine_defineDrugTypeButton => 'Définir un type de médicament';

  @override
  String get medicine_createKitButton => 'Créer un kit de médicaments';

  @override
  String get medicine_defineMaterialTypeButton => 'Définir un type de matériel';

  @override
  String get medicine_checkboxLowerDose =>
      'Une dose inférieure à celle spécifiée peut être prise';

  @override
  String get medicine_checkboxRfid => 'RFID disponible';

  @override
  String get medicine_checkboxMultiPatientAccess => 'Accès multi-patients';

  @override
  String get medicine_checkboxSingleUse => 'Usage unique';

  @override
  String get medicine_checkboxCameraRecording => 'Enregistrement caméra';

  @override
  String get medicine_checkboxIndependentMaterial => 'Médicament libre';

  @override
  String get medicine_checkboxWastagePharmacyApproval =>
      'Exiger l\'approbation de la pharmacie pour la perte/élimination ?';

  @override
  String get medicine_checkboxWastageOrderRenewed =>
      'Renouveler la commande de perte ?';

  @override
  String get medicine_fieldPersonnel => 'Personnel';

  @override
  String get medicine_fieldStation => 'Station';

  @override
  String get medicine_fieldUnit => 'Unité';

  @override
  String get refillList_dialogTitle => 'Liste de remplissage de médicaments';

  @override
  String refillList_recordNoLabel(Object id) {
    return 'N° d\'enregistrement de remplissage : $id';
  }

  @override
  String refillList_createdDateLabel(String date) {
    return 'Date de création : $date';
  }

  @override
  String refillList_assignedUserNameLabel(String name) {
    return 'Assigné à : $name';
  }

  @override
  String get refillList_formTitleCreate => 'Créer une liste de remplissage';

  @override
  String get refillList_formTitleUpdate =>
      'Mettre à jour la liste de remplissage';

  @override
  String get refillList_fieldAssignedUser =>
      'Utilisateur assigné au remplissage';

  @override
  String get refillList_screenTitleFallback => 'Liste de remplissage';

  @override
  String get refillList_newButtonLabel => 'Nouvelle liste de remplissage';

  @override
  String get report_stationsCategoryTitle => 'Stations';

  @override
  String get refillList_cellValueYes => 'Oui';

  @override
  String get refillList_cellValueNo => 'Non';

  @override
  String get refillList_updateStatusTooltip => 'Mettre à jour le statut';

  @override
  String get refillList_defaultUnitFallback => 'Pièce';

  @override
  String get report_expiredItemsTitleFallback => 'Matériaux périmés';

  @override
  String get report_stationStockTitle => 'Stock de la cabine de station';

  @override
  String get report_stationTransactionTitleFallback =>
      'Mouvements de la station';

  @override
  String get report_hospitalStocksTitleFallback =>
      'Liste du Matériel Hospitalier';

  @override
  String get inconsistency_screenTitleFallback => 'Mouvements d\'incohérence';

  @override
  String get inconsistency_viewTooltip => 'Afficher';

  @override
  String get inconsistency_photoTooltip => 'Photo';

  @override
  String get hospitalization_formTitleNew => 'Saisir une nouvelle admission';

  @override
  String get hospitalization_formTitleEdit => 'Modifier l\'admission';

  @override
  String get hospitalization_fieldPatient => 'Patient';

  @override
  String get hospitalization_fieldCode => 'Code d\'admission';

  @override
  String get hospitalization_fieldDoctor => 'Médecin';

  @override
  String get hospitalization_fieldPhysicalService => 'Service physique';

  @override
  String get hospitalization_fieldInpatientService =>
      'Service d\'hospitalisation';

  @override
  String get hospitalization_fieldRoom => 'Chambre';

  @override
  String get hospitalization_roomDialogTitle => 'Sélectionner une chambre';

  @override
  String get hospitalization_fieldBed => 'Lit';

  @override
  String get hospitalization_bedDialogTitle => 'Sélectionner un lit';

  @override
  String get hospitalization_fieldAdmissionDate => 'Date d\'admission';

  @override
  String get hospitalization_fieldExitDate => 'Date de sortie';

  @override
  String get hospitalization_checkboxBaby => 'Nourrisson';

  @override
  String get hospitalization_screenTitleFallback => 'Opérations patient';

  @override
  String get hospitalization_editPatientTooltip =>
      'Modifier les informations du patient';

  @override
  String get hospitalization_showActiveTooltip =>
      'Afficher les admissions actives';

  @override
  String get hospitalization_showDischargedTooltip =>
      'Afficher les patients sortis';

  @override
  String get hospitalization_createButton => 'Créer une nouvelle admission';

  @override
  String get patient_formTitleNew => 'Créer un nouveau patient';

  @override
  String get patient_formTitleEdit => 'Modifier le patient';

  @override
  String get patient_fieldIdentity => 'N° d\'identité nationale';

  @override
  String get patient_fieldName => 'Prénom';

  @override
  String get patient_fieldSurname => 'Nom de famille';

  @override
  String get patient_fieldBirthDate => 'Date de naissance';

  @override
  String get patient_fieldGender => 'Sexe';

  @override
  String get patient_fieldWeight => 'Poids';

  @override
  String get patient_fieldMotherName => 'Nom de la mère';

  @override
  String get patient_fieldFatherName => 'Nom du père';

  @override
  String get patient_fieldPhone => 'Téléphone';

  @override
  String get patient_fieldAddress => 'Adresse';

  @override
  String get patient_fieldProtocolNo => 'N° de protocole';

  @override
  String get activeIngredientDialogSelectTitle =>
      'Sélectionner un principe actif';

  @override
  String get activeIngredientDialogTitle => 'Définition du principe actif';

  @override
  String get activeIngredientFormAddTitle => 'Ajouter un principe actif';

  @override
  String get activeIngredientFormEditTitle => 'Modifier le principe actif';

  @override
  String get activeIngredientListEmptyTitle =>
      'Aucun principe actif pour le moment';

  @override
  String get assignmentScreenTitle => 'Attribution de matériel de station';

  @override
  String get assignmentStationSelectPlaceholder => 'Sélectionnez une station';

  @override
  String get drugClassDialogSelectTitle =>
      'Sélectionner une classe de médicament';

  @override
  String get drugClassDialogTitle => 'Définition de la classe de médicament';

  @override
  String get drugClassFormAddTitle => 'Ajouter une classe de médicament';

  @override
  String get drugClassFormEditTitle => 'Modifier la classe de médicament';

  @override
  String get drugClassFormNameLabel => 'Nom de la classe de médicament';

  @override
  String get drugClassListEmptyTitle =>
      'Aucune classe de médicament pour le moment';

  @override
  String get drugTypeDialogSelectTitle => 'Sélectionner un type de médicament';

  @override
  String get drugTypeDialogTitle => 'Définition du type de médicament';

  @override
  String get drugTypeFormAddTitle => 'Ajouter un type de médicament';

  @override
  String get drugTypeFormEditTitle => 'Modifier le type de médicament';

  @override
  String get drugTypeFormNameLabel => 'Nom du type de médicament';

  @override
  String get drugTypeListEmptyTitle =>
      'Aucun type de médicament pour le moment';

  @override
  String get kitFormAddTitle => 'Nouveau kit';

  @override
  String get kitFormEditTitle => 'Modifier le kit';

  @override
  String get kitFormNameLabel => 'Nom du kit';

  @override
  String get kitDialogSelectTitle => 'Sélectionner un kit';

  @override
  String get kitDialogTitle => 'Définition du kit';

  @override
  String get kitListEmptyTitle => 'Aucun kit pour le moment';

  @override
  String get kitListManageContentTooltip => 'Gérer le contenu du kit';

  @override
  String get kitContentFormAddTitle => 'Ajouter le contenu du kit';

  @override
  String get kitContentFormEditTitle => 'Modifier le contenu du kit';

  @override
  String get kitContentFormMaterialLabel => 'Matériel';

  @override
  String get kitContentFormPieceLabel => 'Nombre de pièces';

  @override
  String get kitContentDialogTitle => 'Définition du contenu du kit';

  @override
  String get kitContentListEmptyTitle => 'Aucun contenu de kit pour le moment';

  @override
  String get materialTypeFormAddTitle => 'Nouveau type de matériel';

  @override
  String get materialTypeFormEditTitle => 'Modifier le type de matériel';

  @override
  String get materialTypeFormNameLabel => 'Nom du type de matériel';

  @override
  String get materialTypeDialogSelectTitle =>
      'Sélectionner un type de matériel';

  @override
  String get materialTypeDialogTitle => 'Définition du type de matériel';

  @override
  String get materialTypeListEmptyTitle =>
      'Aucun type de matériel pour le moment';

  @override
  String get roleFormEditTitle => 'Modifier le rôle';

  @override
  String get roleFormAddTitle => 'Ajouter un rôle';

  @override
  String get roleFormNameLabel => 'Nom du rôle';

  @override
  String get roleScreenTitle => 'Définition du rôle';

  @override
  String get roleScreenAddButton => 'Nouveau rôle';

  @override
  String get roleDeleteSuccessMessage => 'Rôle supprimé avec succès';

  @override
  String get unitFormAddTitle => 'Créer une nouvelle unité';

  @override
  String get unitFormEditTitle => 'Modifier l\'unité';

  @override
  String get unitDialogTitle => 'Unité';

  @override
  String get unitListEmptyTitle => 'Aucune unité pour le moment';

  @override
  String get userCategoryNormalLabel => 'Normal';

  @override
  String get userCategoryTimeBasedLabel => 'Limité dans le temps';

  @override
  String get userCategoryTemporaryLabel => 'Temporaire';

  @override
  String get userDeleteSuccessMessage => 'Utilisateur supprimé avec succès';

  @override
  String get userValidDateUpdateSuccessMessage =>
      'Date d\'expiration mise à jour';

  @override
  String get userFormEditTitle => 'Modifier l\'utilisateur';

  @override
  String get userFormCreateTitle => 'Créer un utilisateur';

  @override
  String get userRegistrationNumberLabel =>
      'N° de registre de l\'établissement';

  @override
  String get userNameLabel => 'Prénom';

  @override
  String get userSurnameLabel => 'Nom de famille';

  @override
  String get userRoleTypeLabel => 'Type de profession';

  @override
  String get userUsageTypeLabel => 'Type d\'utilisation';

  @override
  String get userValidUntilLabel => 'Date d\'expiration';

  @override
  String get userEmailLabel => 'E-mail';

  @override
  String get userOrderPermissionLabel => 'Achat sans commande';

  @override
  String get userWitnessedStationEntryLabel => 'Entrée de station avec témoin';

  @override
  String get userKitPurchaseLabel => 'Achat de kit';

  @override
  String get user_badgeCardLabel => 'Badge';

  @override
  String get user_badgeCardHint => 'Scannez la carte';

  @override
  String get userAuthorizedStationsLabel => 'Stations autorisées';

  @override
  String get userUsernameLabel => 'Nom d\'utilisateur';

  @override
  String get userScreenTitle => 'Liste des utilisateurs';

  @override
  String get userScreenAddButton => 'Nouvel utilisateur';

  @override
  String get userBulkUpdateValidDateButton =>
      'Mettre à jour la date d\'expiration';

  @override
  String get userValidDateDialogTitle => 'Mettre à jour la date';

  @override
  String get userValidDateDialogSaveButton => 'Mettre à jour';

  @override
  String get userNewValidUntilLabel => 'Nouvelle date d\'expiration';

  @override
  String get userNationalIdColumnHeader => 'N° d\'identité nationale';

  @override
  String get warningFormAddTitle => 'Nouvel avertissement';

  @override
  String get warningFormEditTitle => 'Modifier l\'avertissement';

  @override
  String get warningFormAddSubtitle =>
      'Renseignez les informations de l\'avertissement';

  @override
  String get warningFormEditSubtitle =>
      'Mettez à jour les informations de l\'avertissement';

  @override
  String get warningFormSubjectLabel => 'Objet de l\'avertissement';

  @override
  String get warningFormTextLabel => 'Texte de l\'avertissement';

  @override
  String get warningScreenTitle => 'Définition de l\'avertissement';

  @override
  String get dashboard_allSectionsLoadError =>
      'Les données n\'ont pas pu être chargées. Veuillez réessayer.';

  @override
  String get dashboard_sktCriticalRingLabel => 'Critique\n(<7 jours)';

  @override
  String get dashboard_sktWarningRingLabel => 'Avertissement\n(7-30 jours)';

  @override
  String get dashboard_sktExpiredRingLabel => 'Périmés';

  @override
  String get dashboard_sktStatusHeader => 'STATUT D\'EXPIRATION';

  @override
  String dashboard_sktItemCountBadge(int count) {
    return '$count articles';
  }

  @override
  String get dashboard_sktExpiredTag => 'EXPIRÉ';

  @override
  String get dashboard_sktDestroyHint => 'détruire';

  @override
  String dashboard_sktDaysRemainingLabel(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'jours restants',
      one: 'jour restant',
    );
    return '$_temp0';
  }

  @override
  String get dashboard_upcomingTreatmentsHeader => 'TRAITEMENTS À VENIR';

  @override
  String dashboard_pendingTreatmentsBadge(int count) {
    return '$count en attente';
  }

  @override
  String get dashboard_pendingFilterLabel => 'En attente';

  @override
  String get dashboard_urgentFilterLabel => 'Urgent';

  @override
  String get dashboard_treatmentSearchHint =>
      'Rechercher un patient ou un médicament...';

  @override
  String get dashboard_newAssignButton => 'Nouvelle attribution';

  @override
  String get dashboard_noTreatmentsAllFilter =>
      'Aucun enregistrement de traitement trouvé';

  @override
  String get dashboard_noTreatmentsPendingFilter =>
      'Aucun traitement en attente';

  @override
  String get dashboard_noTreatmentsUrgentFilter => 'Aucun traitement urgent';

  @override
  String get dashboard_priorityUrgentLabel => 'Urgent';

  @override
  String get dashboard_priorityNormalLabel => 'Normal';

  @override
  String get dashboard_priorityRoutineLabel => 'Routine';

  @override
  String get dashboard_statusPendingLabel => 'En attente';

  @override
  String get dashboard_statusDoneLabel => 'Distribué';

  @override
  String get dashboard_statusReturnedLabel => 'Retourné';

  @override
  String settings_sectionComingSoon(String label) {
    return 'Paramètres $label bientôt disponibles';
  }

  @override
  String get refund_masterScreenNotReady =>
      'L\'écran de retour de la cabine maître n\'est pas encore prêt.';

  @override
  String get core_cabinConn_managerNotFoundError =>
      'Carte de gestion introuvable.';

  @override
  String get core_cabinConn_disconnectedError => 'Connexion perdue';

  @override
  String get common_action_pullDrawerTitle => 'Ouvrez le tiroir';

  @override
  String get common_action_pullDrawerSubtitle =>
      'Le verrou est ouvert, veuillez tirer.';

  @override
  String get masterDrawer_openingLidTitle => 'Ouverture des couvercles';

  @override
  String get masterDrawer_openingLidSubtitle =>
      'Préparation des couvercles du tiroir cubique.';

  @override
  String get masterDrawer_readySubtitle =>
      'Terminez l\'opération et confirmez.';

  @override
  String get common_action_closeDrawerTitle => 'Fermez le tiroir';

  @override
  String get common_action_closeDrawerSubtitle =>
      'L\'opération est confirmée, veuillez fermer.';

  @override
  String get common_action_drawerClosed => 'Tiroir fermé';

  @override
  String get common_action_operationCompletedSubtitle =>
      'L\'opération est terminée.';

  @override
  String get common_action_drawerError => 'Erreur de tiroir';

  @override
  String common_error_unexpectedWithDetail(Object error) {
    return 'Erreur inattendue : $error';
  }

  @override
  String masterDrawer_lidOpenFailedError(Object error) {
    return 'Le couvercle n\'a pas pu être ouvert : $error';
  }

  @override
  String get common_action_devicePreparing => 'Préparation de l\'appareil...';

  @override
  String common_error_connectionErrorWithDetail(Object error) {
    return 'Erreur de connexion : $error';
  }

  @override
  String get common_action_lockOpening => 'Ouverture du verrou...';

  @override
  String common_error_lockOpenFailedWithDetail(Object error) {
    return 'Le verrou n\'a pas pu être ouvert : $error';
  }

  @override
  String mobileDrawer_portSubtitle(int port) {
    return 'Tiroir $port';
  }

  @override
  String get mobileDrawer_openedSubtitle =>
      'Fermez le tiroir pour terminer l\'opération.';

  @override
  String get mobileDrawer_closedSubtitle => 'En attente de votre confirmation';

  @override
  String common_error_managerConnectFailedWithDetail(Object error) {
    return 'Impossible de se connecter à la carte de gestion : $error';
  }

  @override
  String mobileDrawer_openCommandFailedError(Object error) {
    return 'Impossible d\'envoyer la commande d\'ouverture du tiroir : $error';
  }

  @override
  String get mobileDrawer_statusTimeoutError =>
      'Délai d\'expiration lors de la lecture de l\'état du tiroir.';

  @override
  String get mobileDrawer_openNotConfirmedError =>
      'Impossible de confirmer que le tiroir s\'est ouvert.';

  @override
  String mobileDrawer_statusReadError(Object error) {
    return 'Une erreur s\'est produite lors de la lecture de l\'état du tiroir : $error';
  }

  @override
  String get patientPicker_searchHint => 'Rechercher un patient';

  @override
  String get patientPicker_orderlessToggleLabel => 'Sans commande';

  @override
  String get patientPicker_orderedToggleLabel => 'Avec commande';

  @override
  String get patientPicker_myPatientsToggleLabel => 'Mes patients';

  @override
  String get patientPicker_urgentPatientHint =>
      'Créez un dossier pour un patient urgent qui ne figure pas dans la liste.';

  @override
  String get patientPicker_createUrgentPatientButton =>
      'Créer un patient urgent';

  @override
  String get patientPicker_urgentPatientCreatedMessage =>
      'Patient urgent créé.';

  @override
  String get hw_cabinOps_serumSlaveModeError =>
      'La carte sérum n\'a pas pu être mise en mode esclave...';

  @override
  String hw_cabinOps_solenoidMissingError(Object port) {
    return 'Le port $port n\'a pas de solénoïde (.no).';
  }

  @override
  String hw_cabinOps_portOpenFailedError(Object port, Object response) {
    return 'Le port $port n\'a pas pu être ouvert. Réponse : $response';
  }

  @override
  String hw_cabinOps_masterDrawerOpenFailedError(
    Object row,
    Object port,
    Object drawer,
    Object response,
  ) {
    return 'Le tiroir maître n\'a pas pu être ouvert (ligne=$row, port=$port, tiroir=$drawer). Réponse : $response';
  }

  @override
  String hw_cabinOps_masterSerumOpenFailedError(Object row, Object response) {
    return 'Le tiroir sérum maître n\'a pas pu être ouvert (ligne=$row). Réponse : $response';
  }

  @override
  String hw_serial_connectFailedDetailedError(String portName) {
    return 'Impossible de se connecter au port $portName. Assurez-vous que l\'appareil est connecté et sous tension, et que le port n\'est pas utilisé par une autre application.';
  }

  @override
  String hw_serial_portConfigFailedError(String portName, Object error) {
    return 'Échec de la configuration du port ($portName) : $error';
  }

  @override
  String hw_serial_systemErrorSuffix(Object error) {
    return 'Erreur système : $error';
  }

  @override
  String get hw_serial_portInUseSuffix =>
      'Le port est peut-être utilisé par une autre application.';

  @override
  String hw_serial_readErrorWithDetail(Object error) {
    return 'Erreur de lecture du port : $error';
  }

  @override
  String get hw_serial_reconnectingStatus => 'Redémarrage de la connexion.';

  @override
  String hw_rfid_connectFailedError(Object error) {
    return 'Impossible de se connecter au lecteur RFID : $error';
  }

  @override
  String get hw_rfid_invalidResponseError =>
      'Une réponse invalide a été reçue.';

  @override
  String hw_rfid_unreachableError(Object error) {
    return 'Le lecteur RFID n\'a pas pu être joint : $error';
  }

  @override
  String get hw_rfid_testTimeoutError => 'Le test de connexion RFID a expiré.';

  @override
  String get hw_rfid_powerChangeBlockedError =>
      'Le réglage de puissance ne peut pas être modifié pendant que l\'inventaire est actif. Appelez d\'abord stopInventory().';

  @override
  String hw_rfid_setModeRejectedError(Object status) {
    return 'SetWorkingMode a été rejeté (statut=0x$status)';
  }

  @override
  String hw_rfid_setAntennaRejectedError(Object status) {
    return 'SetWorkingAntenna a été rejeté (statut=0x$status)';
  }

  @override
  String get hw_rfid_antennaConnFailedHint =>
      ' (erreur de connexion d\'antenne — l\'un des ports activés est vide)';

  @override
  String get hw_rfid_noAntennaConnectedError =>
      'Impossible de se connecter à une antenne (tous les ports sont vides).';

  @override
  String get hw_rfid_notConnectedError =>
      'Le service RFID n\'est pas connecté.';

  @override
  String get hw_rfid_commandPendingError =>
      'La commande précédente est toujours en attente d\'une réponse.';

  @override
  String hw_rfid_commandTimeoutError(Object cmd) {
    return 'La réponse à la commande a expiré (cmd=0x$cmd).';
  }

  @override
  String hw_rfid_commandErrorWithDetail(Object error) {
    return 'Erreur de commande : $error';
  }

  @override
  String get hw_rfid_mockNotConnectedError =>
      'Le service RFID simulé n\'est pas connecté.';

  @override
  String get operationStatus_fatalErrorLabel => 'Erreur critique';

  @override
  String get operationStatus_errorLabel => 'Erreur';

  @override
  String get operationStatus_rollingBackLabel =>
      'Annulation de l\'opération en cours';

  @override
  String get operationStatus_finalizingLabel =>
      'Finalisation de l\'opération en cours';

  @override
  String get operationStatus_drugsStillInCabinetLabel =>
      'Les médicaments sont toujours dans la cabine';

  @override
  String get operationStatus_incompleteLabel => 'Incomplet / Incohérent';

  @override
  String get operationStatus_scanningLabel => 'Analyse en cours';

  @override
  String get operationStatus_reportedMissingLabel => 'Signalé manquant';

  @override
  String get operationBanner_unplannedMovementTitle =>
      'Mouvement imprévu détecté';

  @override
  String operationBanner_unplannedMovementMessage(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$countString étiquettes ont été retirées de la cabine de manière imprévue.',
      one:
          '$countString étiquette a été retirée de la cabine de manière imprévue.',
    );
    return '$_temp0 Un signalement sera envoyé à la pharmacie.';
  }

  @override
  String get operationBanner_unexpectedTagBlockingTitle =>
      'Étiquette(s) n\'appartenant pas à cette cabine détectée(s)';

  @override
  String get operationBanner_unexpectedTagWarningTitle =>
      'Médicament inattendu';

  @override
  String operationBanner_unexpectedTagBlockingMessage(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'les $countString étiquettes suivantes',
      one: 'la $countString étiquette suivante',
    );
    return 'Retirez $_temp0 du tiroir pour continuer.';
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
      other: '$countString étiquettes n\'appartenant pas',
      one: '$countString étiquette n\'appartenant pas',
    );
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ont été lues',
      one: 'a été lue',
    );
    return '$_temp0 à cette cabine $_temp1. Veuillez la/les retirer.';
  }

  @override
  String get operationBanner_missingStockTitle => 'Stock manquant';

  @override
  String operationBanner_missingStockMessage(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString médicaments n\'ont pas été trouvés',
      one: '$countString médicament n\'a pas été trouvé',
    );
    return '$_temp0 dans la cabine. Cela sera signalé comme stock manquant une fois terminé.';
  }

  @override
  String get common_okButton => 'OK';

  @override
  String get cabinPatientPicker_searchHint =>
      'Rechercher un patient, une chambre, un lit ou un service...';

  @override
  String get common_unknownPatientFallback => 'Patient inconnu';

  @override
  String get patientListPanel_searchHint => 'Rechercher un patient...';

  @override
  String rxItemCard_maxQuantitySuffix(String max, String unit) {
    return '/ max. $max $unit';
  }

  @override
  String get census_extraStockSummaryMessage =>
      'Le stock excédentaire sera signalé à la fin de l\'opération.';

  @override
  String get cabinOperation_hint_scanning =>
      'Analyse de la cabine en cours, veuillez patienter';

  @override
  String get census_hint_waitingClose =>
      'Enregistré — fermez le tiroir pour terminer le comptage';

  @override
  String get census_hint_closedEarly =>
      'Le tiroir s\'est fermé prématurément — vous pouvez réessayer ou annuler';

  @override
  String get cabinOperation_hint_error =>
      'Une erreur s\'est produite — vous pouvez réessayer';

  @override
  String get census_hint_unexpectedTag =>
      'Une étiquette n\'appartenant pas à cette cabine est présente — retirez-la pour continuer';

  @override
  String get census_hint_readyToComplete =>
      'Appuyez sur le bouton pour terminer le comptage';

  @override
  String get cabinOperation_action_closeDrawer => 'Fermez le tiroir';

  @override
  String get census_label_counted => 'Compté';

  @override
  String get census_label_excess => 'Excédent';

  @override
  String get cabinOperation_label_unexpectedTag => 'Étranger';

  @override
  String get intake_error_witnessRequired =>
      'Une connexion de témoin est requise.';

  @override
  String get intake_error_noValidTargets =>
      'L\'entrée n\'a pas pu être effectuée pour les médicaments sélectionnés.';

  @override
  String get intake_error_noDrawerFound =>
      'Aucun tiroir trouvé pour le prélèvement.';

  @override
  String get intake_hint_noStock => 'Il n\'y a pas de stock dans la cabine';

  @override
  String intake_label_witnessName(String name) {
    return 'Témoin : $name';
  }

  @override
  String get intake_hint_witnessRequired => 'Connexion de témoin requise';

  @override
  String get intake_status_checking => 'Vérification en cours...';

  @override
  String get intake_status_readyToTake => 'Prêt pour le prélèvement';

  @override
  String get intake_status_checkFailed => 'Échec de la vérification';

  @override
  String get intake_emptyState_selectMedicine =>
      'Sélectionnez un médicament pour commencer l\'entrée.';

  @override
  String intake_label_multiMedicine(int count) {
    return '$count médicaments différents';
  }

  @override
  String intake_label_takenAmount(String amount, String unit) {
    return 'Prélevé : $amount $unit';
  }

  @override
  String intake_label_countFieldLabel(String unit) {
    return 'Comptage ($unit)';
  }

  @override
  String get intake_hint_nextCellOpens =>
      'La case suivante s\'ouvrira une fois que vous aurez confirmé.';

  @override
  String get intake_hint_confirmCloses =>
      'Le tiroir se fermera une fois que vous aurez confirmé.';

  @override
  String get intake_hint_searchMedicine =>
      'Rechercher un médicament (nom / code-barres)';

  @override
  String get intake_hint_selectionLocked =>
      'Entrée en cours — la sélection est verrouillée.';

  @override
  String get intake_hint_autoQueueOrder =>
      'Les tiroirs s\'ouvriront dans l\'ordre du chemin le plus court.';

  @override
  String intake_info_witnessAutoAssigned(String name) {
    return '$name a également été désigné comme témoin pour ce médicament.';
  }

  @override
  String get intake_error_queueTitle => 'L\'entrée n\'a pas pu être terminée';

  @override
  String get intake_error_queueMessage =>
      'Remettez les médicaments à l\'endroit où vous les avez pris.';

  @override
  String get intake_error_selfWitness =>
      'L\'utilisateur effectuant l\'opération ne peut pas également en être témoin.';

  @override
  String intake_success_witnessConfirmed(String name) {
    return '$name a été confirmé comme témoin.';
  }

  @override
  String get intake_witnessDialog_title => 'Vérification du témoin';

  @override
  String get intake_witnessDialog_usernameLabel =>
      'Nom d\'utilisateur du témoin';

  @override
  String get intake_witnessDialog_usernameRequired =>
      'Saisissez un nom d\'utilisateur';

  @override
  String get intake_witnessDialog_passwordLabel => 'Mot de passe du témoin';

  @override
  String get intake_witnessDialog_passwordRequired =>
      'Saisissez un mot de passe';

  @override
  String get intake_witnessDialog_confirmButton => 'Confirmer le témoin';

  @override
  String get intake_witnessDialog_anyoneInfo =>
      'Tout membre du personnel peut être témoin de cette opération.';

  @override
  String intake_witnessDialog_authorizedWitnesses(int count) {
    return 'Témoins autorisés ($count)';
  }

  @override
  String cabinOperation_hint_fatalError(String message) {
    return 'Une erreur critique s\'est produite : $message';
  }

  @override
  String get cabinOperation_hint_completed => 'Opération terminée';

  @override
  String get cabinOperation_hint_waitingCloseGeneric =>
      'Enregistré. Fermez le tiroir pour terminer l\'opération';

  @override
  String get cabinOperation_hint_closedEarlyGeneric =>
      'Le tiroir a été fermé. Vous pouvez annuler ou continuer là où vous vous êtes arrêté';

  @override
  String get cabinOperation_hint_ready =>
      'Prêt — vous pouvez terminer l\'opération';

  @override
  String get intake_hint_extraPlacement =>
      'Un médicament qui ne devrait pas se trouver dans la cabine a été chargé, veuillez le retirer.';

  @override
  String get intake_hint_takeItems =>
      'Prenez les médicaments, puis terminez l\'opération';

  @override
  String get cabinOperation_action_completeGeneric => 'Terminer l\'opération';

  @override
  String get rfidStatus_notFound => 'Introuvable';

  @override
  String get rfidStatus_scanning => 'Analyse en cours';

  @override
  String get intake_label_noRfid => 'Pas de RFID';

  @override
  String get cabinOperation_label_selected => 'Sélectionné';

  @override
  String get intake_label_readInCabin => 'Lu dans la cabine';

  @override
  String intake_label_tagCount(int count) {
    return '$count étiquettes';
  }

  @override
  String get intake_label_takenCount => 'Prélevé';

  @override
  String get intake_label_unauthorizedTake => 'Prélèvement non autorisé';

  @override
  String get intake_error_retryOrFinish =>
      'Vous pouvez réessayer, ou terminer l\'opération en reprenant les médicaments que vous avez placés.';

  @override
  String get refill_label_placed => 'Placé';

  @override
  String get refill_label_placedCount => 'Placé';

  @override
  String refill_label_placedProgress(Object done, Object total) {
    return '$done / $total';
  }

  @override
  String get cabinOperation_label_unplanned => 'Imprévu';

  @override
  String get refill_label_extraTag => 'Étiquette en trop';

  @override
  String get refill_error_retry => 'Vous pouvez réessayer.';

  @override
  String get unload_hint_waitingClose =>
      'Enregistré — fermez le tiroir pour terminer le déchargement';

  @override
  String get unload_hint_closedEarly =>
      'Le tiroir s\'est fermé prématurément — vous pouvez réessayer ou annuler';

  @override
  String get unload_hint_readyToComplete =>
      'Appuyez sur le bouton pour terminer le déchargement';

  @override
  String get unload_label_unloaded => 'Déchargé';

  @override
  String unload_label_unloadProgress(Object done, Object total) {
    return '$done / $total';
  }

  @override
  String wizard_stepBadge(int step, int total) {
    return 'Étape $step / $total';
  }

  @override
  String get wizard_step4Header => 'Configuration du tiroir';

  @override
  String get wizard_step4SubtitleMobile =>
      'Définissez le nombre de tiroirs, les sections internes et les connexions de port de la cabine mobile.';

  @override
  String get wizard_step4SubtitleMaster =>
      'La structure interne de la cabine sera lue automatiquement depuis l\'appareil.';

  @override
  String get wizard_backButton => 'Retour';

  @override
  String get wizard_testCabinConnectionButton =>
      'Tester la connexion de la cabine';

  @override
  String get wizard_testingInProgress => 'Test en cours…';

  @override
  String get wizard_connectionSuccessLabel => 'Connexion réussie';

  @override
  String get wizard_retestLink => 'Tester à nouveau';

  @override
  String get wizard_cabinConnectionErrorFallback =>
      'Impossible d\'établir une connexion. Vérifiez les paramètres du port.';

  @override
  String get wizard_testRfidConnectionButton =>
      'Tester la connexion de l\'antenne';

  @override
  String wizard_rfidFirmwareInfo(String firmwareVersion, Object power) {
    return '· FW $firmwareVersion  $power dBm';
  }

  @override
  String get wizard_rfidConnectionErrorFallback =>
      'Impossible d\'établir une connexion. Vérifiez les paramètres IP et de port.';

  @override
  String get wizard_portLabel => 'Port';

  @override
  String get wizard_rfidReaderToggleLabel => 'Possède un lecteur RFID';

  @override
  String get wizard_rfidIpAddressLabel => 'Adresse IP RFID';

  @override
  String get wizard_rfidPortFieldLabel => 'Port RFID';

  @override
  String get wizard_drawerCountRangeHint => '1 à 8 tiroirs';

  @override
  String get wizard_sameConfigToggleLabel =>
      'Tous les tiroirs ont la même structure';

  @override
  String get wizard_sameConfigToggleOnDesc =>
      'Tous les tiroirs utilisent la même configuration de lignes/colonnes';

  @override
  String get wizard_sameConfigToggleOffDesc =>
      'Si désactivé, les lignes/colonnes peuvent être définies séparément pour chaque tiroir';

  @override
  String wizard_drawerRowCellSummary(int rowCount, int totalCells) {
    return '$rowCount lignes · $totalCells cellules';
  }

  @override
  String wizard_drawerPortLabel(Object portNumber) {
    return 'Port $portNumber';
  }

  @override
  String wizard_rowLabel(int rowIndex) {
    return 'LIGNE $rowIndex';
  }

  @override
  String get wizard_serviceDetailsLoadError =>
      'Impossible de charger les détails du service.';

  @override
  String get wizard_stationDetailsLoadError =>
      'Impossible de charger les détails de la station.';

  @override
  String get wizard_stationsLoadErrorFallback =>
      'Impossible de charger les stations.';

  @override
  String get wizard_noStationsFoundMessage =>
      'Aucune station enregistrée n\'a été trouvée.';

  @override
  String get wizard_noRoomsDefinedMessage =>
      'Aucune chambre n\'est définie pour cette station.';

  @override
  String wizard_selectedRoomCountBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chambres',
      one: '$count chambre',
    );
    return '$_temp0';
  }

  @override
  String wizard_roomSelectionFraction(int selected, int total) {
    return '$selected/$total';
  }

  @override
  String get refill_hint_extraPlacement =>
      'Une étiquette autre que les médicaments sélectionnés a été placée, veuillez la retirer';

  @override
  String get refill_hint_placeItems =>
      'Placez les médicaments, puis terminez l\'opération';

  @override
  String get appException_networkUnavailable =>
      'Impossible de se connecter au serveur. Vérifiez votre connexion réseau.';

  @override
  String get appException_timeout =>
      'Le serveur n\'a pas répondu. Veuillez réessayer.';

  @override
  String appException_serviceError5xx(Object statusCode) {
    return 'Erreur du serveur ($statusCode). Veuillez réessayer.';
  }

  @override
  String appException_serviceErrorOther(Object statusCode) {
    return 'L\'opération n\'a pas pu être terminée ($statusCode).';
  }

  @override
  String get appException_malformedData =>
      'Des données inattendues ont été reçues du serveur.';

  @override
  String get appException_emptyResponse =>
      'Le serveur a renvoyé une réponse vide.';

  @override
  String appException_validationField(String field) {
    return 'Le champ $field est invalide.';
  }

  @override
  String get appException_validationGeneric =>
      'Les informations saisies sont invalides.';

  @override
  String get appException_mapping =>
      'Une erreur s\'est produite lors du traitement des données.';

  @override
  String get appException_cache => 'Impossible de lire les données locales.';

  @override
  String get appException_staleCache =>
      'Impossible d\'accéder aux données à jour. Veuillez vérifier la connexion.';

  @override
  String appException_notFoundWithType(String resourceType) {
    return '$resourceType introuvable.';
  }

  @override
  String get appException_notFoundGeneric => 'Enregistrement introuvable.';

  @override
  String get appException_unexpected =>
      'Une erreur inattendue s\'est produite. Veuillez réessayer.';

  @override
  String get appException_serialPort =>
      'Impossible de se connecter au port série. Veuillez contacter le service technique.';

  @override
  String get appException_custom =>
      'Une erreur inconnue s\'est produite. Veuillez réessayer plus tard.';

  @override
  String get dataError_emptyResponse => 'Le serveur a renvoyé une réponse vide';

  @override
  String get dataError_malformedResponse =>
      'La réponse n\'a pas pu être traitée';

  @override
  String get dataError_requestTimeout => 'La requête a expiré';

  @override
  String get dataError_networkUnavailable =>
      'Impossible de se connecter au réseau';

  @override
  String get dataError_genericApiError =>
      'Nous avons rencontré une erreur. Veuillez réessayer plus tard.';

  @override
  String get dataError_requestCancelled => 'La requête a été annulée';

  @override
  String get dataError_envelopeErrorFallback => 'Erreur';

  @override
  String get authError_invalidTokenResponse =>
      'Une réponse de jeton invalide a été reçue du serveur';

  @override
  String get authError_userInfoFetchFailed =>
      'Impossible de récupérer les informations utilisateur';

  @override
  String get authError_userInfoEmpty =>
      'Les informations utilisateur renvoyées étaient vides';

  @override
  String get authError_genericLoginError => 'Une erreur s\'est produite';

  @override
  String get authError_invalidCredentialsMock =>
      'Nom d\'utilisateur ou mot de passe incorrect.';

  @override
  String get dataGuard_deleteActiveIngredientIdEmpty =>
      'L\'ID du principe actif à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteBranchIdEmpty =>
      'L\'ID de la spécialité à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteCabinIdEmpty =>
      'L\'ID de la cabine à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteDosageFormIdEmpty =>
      'L\'ID de la forme posologique à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteDrugClassIdEmpty =>
      'L\'ID de la classe de médicament à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteFirmIdEmpty =>
      'L\'ID de l\'entreprise à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteDrugTypeIdEmpty =>
      'L\'ID du type de médicament à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteHospitalizationIdEmpty =>
      'L\'ID de l\'admission à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteKitIdEmpty =>
      'L\'ID du kit à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteKitContentIdEmpty =>
      'L\'ID du contenu du kit à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteMaterialTypeIdEmpty =>
      'L\'ID du type de matériel à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteMedicineIdEmpty =>
      'L\'ID du médicament à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deletePatientIdEmpty =>
      'L\'ID du patient à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteRoleIdEmpty =>
      'L\'ID du rôle à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteServiceIdEmpty =>
      'L\'ID du service à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteStationIdEmpty =>
      'L\'ID de la station à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteUnitIdEmpty =>
      'L\'ID de l\'unité à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteWarehouseIdEmpty =>
      'L\'ID de l\'entrepôt à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteWarningIdEmpty =>
      'L\'ID de l\'avertissement à supprimer ne peut pas être vide';

  @override
  String get dataGuard_updatePatientIdEmpty =>
      'L\'ID du patient à mettre à jour ne peut pas être vide';

  @override
  String get dataGuard_updateHospitalizationIdEmpty =>
      'L\'ID de l\'admission à mettre à jour ne peut pas être vide';

  @override
  String get core_genericErrorRetryMessage =>
      'Une erreur s\'est produite. Veuillez réessayer plus tard.';

  @override
  String get core_genericErrorShortMessage => 'Une erreur s\'est produite.';

  @override
  String get cabinCore_createError =>
      'Une erreur s\'est produite lors de la création de la cabine. Veuillez réessayer plus tard.';

  @override
  String get cabinCore_activeCabinNotFound => 'Aucune cabine active trouvée';

  @override
  String get cabinCore_mobileCabinDesignNotFound =>
      'Conception de cabine mobile introuvable';

  @override
  String get cabinCore_cabinDesignNotFound =>
      'Conception de cabine introuvable';

  @override
  String get cabinCore_createdButIdMissing =>
      'La cabine a été créée mais son ID n\'a pas pu être récupéré.';

  @override
  String get cabinCore_definitionsNotFound =>
      'Les définitions n\'ont pas pu être récupérées.';

  @override
  String get cabinCore_noCardsFound => 'Aucune carte n\'a été trouvée.';

  @override
  String get cabinCore_noMatchingDrawerFound =>
      'Aucun tiroir correspondant n\'a été trouvé.';

  @override
  String get cabinCore_designDataNotFound =>
      'Aucune donnée trouvée à enregistrer.';

  @override
  String get prescriptionCore_createError =>
      'Une erreur s\'est produite lors de la création de l\'ordonnance. Veuillez réessayer plus tard.';

  @override
  String get prescriptionCore_rfidTagNotFoundInReader =>
      'Aucune étiquette RFID trouvée dans la zone du lecteur.';

  @override
  String prescriptionCore_rfidReadErrorWithDetail(Object error) {
    return 'Une erreur s\'est produite lors de la lecture de l\'étiquette RFID : $error';
  }

  @override
  String get tableCore_roleNameColumn => 'Nom du rôle';

  @override
  String get tableCore_warningSubjectColumn => 'Objet de l\'avertissement';

  @override
  String get tableCore_warningTextColumn => 'Texte de l\'avertissement';

  @override
  String get tableCore_warehouseCodeColumn => 'Code de l\'entrepôt';

  @override
  String get tableCore_warehouseNameColumn => 'Nom de l\'entrepôt';

  @override
  String get tableCore_warehouseManagerColumn => 'Responsable de l\'entrepôt';

  @override
  String get tableCore_dosageFormBranchColumn => 'Nom de la spécialité';

  @override
  String get tableCore_firmIdColumn => 'ID';

  @override
  String get tableCore_firmNameColumn => 'Nom';

  @override
  String get tableCore_firmTypeColumn => 'Type d\'entreprise';

  @override
  String get tableCore_firmTaxOfficeColumn => 'Centre des impôts';

  @override
  String get tableCore_firmTaxNoColumn => 'N° fiscal';

  @override
  String get tableCore_kitNameColumn => 'Nom du kit';

  @override
  String get tableCore_kitContentMaterialNameColumn => 'Nom du matériel';

  @override
  String get tableCore_kitContentPieceColumn => 'Nombre de pièces';

  @override
  String get tableCore_drugTypeColumn => 'Type de médicament';

  @override
  String get tableCore_drugClassColumn => 'Classe de médicament';

  @override
  String get tableCore_materialTypeColumn => 'Type de matériel';

  @override
  String get tableCore_stationCodeColumn => 'Code de la station';

  @override
  String get tableCore_stationNameColumn => 'Nom de la station';

  @override
  String get tableCore_stationDrugWarehouseColumn => 'Entrepôt de médicaments';

  @override
  String get tableCore_stationDrugColumn => 'Médicament';

  @override
  String get tableCore_stationConsumableWarehouseColumn =>
      'Entrepôt de consommables médicaux';

  @override
  String get tableCore_stationConsumableColumn => 'Consommable médical';

  @override
  String get tableCore_stationWorkingTypeColumn => 'Type de fonctionnement';

  @override
  String get tableCore_hospitalizationProtocolNoColumn => 'N° de protocole';

  @override
  String get tableCore_hospitalizationNationalIdColumn =>
      'N° d\'identité nationale';

  @override
  String get tableCore_hospitalizationPatientColumn => 'Patient';

  @override
  String get tableCore_patientRowNationalIdColumn =>
      'Identité nationale du patient';

  @override
  String get tableCore_patientRowFullNameColumn => 'Nom complet';

  @override
  String get tableCore_inconsistencyCabinColumn => 'Cabine';

  @override
  String get tableCore_inconsistencyRowNoColumn => 'N° de ligne';

  @override
  String get tableCore_inconsistencyCellColumn => 'Case';

  @override
  String get tableCore_inconsistencyExpectedColumn => 'Attendu';

  @override
  String get tableCore_inconsistencyCountedColumn => 'Quantité comptée';

  @override
  String get tableCore_stockTransactionDateColumn => 'Date';

  @override
  String get tableCore_stockTransactionBarcodeColumn => 'Code-barres';

  @override
  String get tableCore_stockTransactionTypeColumn => 'Type de transaction';

  @override
  String get tableCore_stockTransactionQuantityColumn => 'Quantité';

  @override
  String get tableCore_stockTransactionPreviousQuantityColumn =>
      'Quantité avant mouvement';

  @override
  String get tableCore_stockTransactionActorColumn => 'Effectué par';

  @override
  String get tableCore_serviceColumn => 'Service';

  @override
  String get tableCore_admissionDateColumn => 'Date d\'admission';

  @override
  String get tableCore_dischargeDateColumn => 'Date de sortie';

  @override
  String get tableCore_materialColumn => 'Matériel';

  @override
  String get enumCore_statusActive => 'Actif';

  @override
  String get enumCore_statusPassive => 'Inactif';

  @override
  String get enumCore_warehouseTypeMain => 'Entrepôt principal';

  @override
  String get enumCore_firmTypeSupplier => 'Fournisseur';

  @override
  String get enumCore_firmTypeCustomer => 'Client';

  @override
  String get enumCore_firmTypeManufacturer => 'Fabricant';

  @override
  String get enumCore_warningSubjectUntimelyPurchase => 'Achat intempestif';

  @override
  String get enumCore_warningSubjectWaste => 'Perte';

  @override
  String get enumCore_warningSubjectInconsistencyResolution =>
      'Résolution d\'incohérence';

  @override
  String get enumCore_warningSubjectDisposal => 'Élimination';

  @override
  String get enumCore_stockTxKindRefill => 'Remplissage de Matériel';

  @override
  String get enumCore_stockTxKindStockOut => 'Sortie de Stock';

  @override
  String get enumCore_stockTxKindConsistent => 'Comptage Conforme';

  @override
  String get enumCore_stockTxKindReturnInward => 'Réception de Retour';

  @override
  String get enumCore_stockTxKindWastage => 'Gaspillage';

  @override
  String get enumCore_stockTxTypeIn => 'Entrée de stock';

  @override
  String get enumCore_stockTxTypeOut => 'Sortie de stock';

  @override
  String get enumCore_stockTxKindReturn => 'Retour de Matériel';

  @override
  String get enumCore_stockTxKindExcess => 'Excédent de Comptage';

  @override
  String get enumCore_stockTxKindShortage => 'Manque de Comptage';

  @override
  String get enumCore_stockTxKindPurchase => 'Réception de Matériel';

  @override
  String get enumCore_stockTxKindUnload => 'Déchargement de Matériel';

  @override
  String get enumCore_countTypeNone => 'Aucun comptage';

  @override
  String get enumCore_countTypeNormal => 'Comptage normal';

  @override
  String get enumCore_countTypeBlind => 'Comptage à l\'aveugle';

  @override
  String get enumCore_returnTypeToOrigin => 'Retour à l\'origine';

  @override
  String get enumCore_returnTypeToDrawer => 'Retour au tiroir';

  @override
  String get enumCore_returnTypeToReturnBox => 'Retour à la boîte de retour';

  @override
  String get enumCore_returnTypeToPharmacy => 'Retour à la pharmacie';

  @override
  String get enumCore_requestTypeNormal => 'Demande normale';

  @override
  String get enumCore_requestTypeUrgent => 'Demande urgente';

  @override
  String get enumCore_purchaseTypeBoth => 'Les deux';

  @override
  String get enumCore_prescriptionTypeWhite => 'Ordonnance blanche';

  @override
  String get enumCore_prescriptionTypeSerumWhite =>
      'Sérum (ordonnance blanche)';

  @override
  String get enumCore_prescriptionTypeRed => 'Ordonnance rouge';

  @override
  String get enumCore_prescriptionTypeGreen => 'Ordonnance verte';

  @override
  String get enumCore_prescriptionTypeOrange => 'Ordonnance orange';

  @override
  String get enumCore_prescriptionTypePurple => 'Ordonnance violette';

  @override
  String get enumCore_refillListStatusToCollect => 'À rassembler';

  @override
  String get enumCore_refillListStatusCollected => 'Rassemblé';

  @override
  String get enumCore_refillListStatusSent => 'Envoyé';

  @override
  String get enumCore_fillingTypeMinimum => 'Minimum';

  @override
  String get enumCore_fillingTypeCritical => 'Critique';

  @override
  String get enumCore_fillingTypeMaximum => 'Maximum';

  @override
  String get enumCore_patientFilterOrderTimeReached =>
      'Heure de commande atteinte';

  @override
  String get enumCore_patientFilterAll => 'Tous les patients';

  @override
  String get enumCore_patientFilterTimeNotReached => 'Heure non atteinte';

  @override
  String get enumCore_patientFilterTimePassed => 'Heure dépassée';

  @override
  String get enumCore_patientFilterReturnable => 'Retour possible';

  @override
  String get enumCore_patientFilterWasteDisposable =>
      'Perte/élimination possible';

  @override
  String get enumCore_cabinTypeStandard => 'Cabine standard';

  @override
  String get enumCore_cabinTypeCloset => 'Armoire';

  @override
  String get enumCore_cabinTypeFridge => 'Réfrigérateur';

  @override
  String get enumCore_cabinTypeOpenCloset => 'Armoire ouverte';

  @override
  String get enumCore_cabinTypeMobile => 'Cabine mobile';

  @override
  String get enumCore_cabinTypeExternalReturn => 'Cabine de retour externe';

  @override
  String get enumCore_cabinTypeOpen => 'Cabine ouverte';

  @override
  String get enumCore_cabinTypeSerum => 'Cabine à sérum';

  @override
  String get enumCore_cabinOpModeAssignDrug => 'Attribution de médicament';

  @override
  String get enumCore_cabinOpModeRefill => 'Remplissage de médicament';

  @override
  String get enumCore_cabinOpModeCensus => 'Comptage de médicament';

  @override
  String get enumCore_cabinOpModeIntake => 'Entrée de médicament';

  @override
  String get enumCore_cabinOpModeFault => 'Panne de tiroir';

  @override
  String get enumCore_cabinOpModeUnload => 'Déchargement de médicament';

  @override
  String get enumCore_permissionCan => 'Peut';

  @override
  String get enumCore_permissionCannot => 'Ne peut pas';

  @override
  String get enumCore_genderFemale => 'Femme';

  @override
  String get enumCore_genderMale => 'Homme';

  @override
  String get enumCore_genderUnknown => 'Inconnu';

  @override
  String get enumCore_userTypeUnlimited => 'Illimité';

  @override
  String get enumCore_appModeAdmin => 'Admin';

  @override
  String get enumCore_appModeManager => 'Gestion';

  @override
  String get enumCore_appModeStation => 'Station';

  @override
  String get enumCore_userRoleManager => 'Gestionnaire';

  @override
  String get enumCore_userRoleStationOperator => 'Opérateur de station';

  @override
  String get enumCore_parityBitNone => 'Aucun';

  @override
  String get enumCore_parityBitEven => 'Pair';

  @override
  String get enumCore_parityBitOdd => 'Impair';

  @override
  String get enumCore_cabinColorBlue => 'Bleu';

  @override
  String get enumCore_cabinColorTurquoise => 'Turquoise';

  @override
  String get enumCore_cabinColorGreen => 'Vert';

  @override
  String get enumCore_cabinColorRed => 'Rouge';

  @override
  String get enumCore_cabinColorOrange => 'Orange';

  @override
  String get enumCore_cabinColorPurple => 'Violet';

  @override
  String get enumCore_cabinColorGray => 'Gris';

  @override
  String get enumCore_cabinColorBlack => 'Noir';

  @override
  String get enumCore_cabinColorWhite => 'Blanc';

  @override
  String get common_confirmButton => 'Confirmer';

  @override
  String get common_warningTitle => 'Avertissement !';

  @override
  String get dialog_deleteTitle => 'Suppression';

  @override
  String get dialog_deleteDefaultMessage =>
      'Êtes-vous sûr de vouloir supprimer cet élément ?';

  @override
  String dialog_deleteItemMessage(String itemName) {
    return 'Êtes-vous sûr de vouloir supprimer « $itemName » ?\nCette action est irréversible.';
  }

  @override
  String get dialog_exitConfirmButtonText => 'Quitter';

  @override
  String get dialog_exitConfirmMessage =>
      'Vous avez des modifications non enregistrées. Si vous quittez, ces modifications seront perdues.';

  @override
  String get dialog_exitConfirmMessageNoChanges =>
      'Êtes-vous sûr de vouloir quitter cette page ?';

  @override
  String get dialog_confirmDiscardButton => 'Oui, annuler';

  @override
  String get dialog_logoutTitle => 'Se déconnecter';

  @override
  String get dialog_logoutMessage =>
      'Êtes-vous sûr de vouloir vous déconnecter de votre compte ?';

  @override
  String get table_noDataTitle => 'Aucune donnée trouvée';

  @override
  String get table_actionsColumnHeader => 'Actions';

  @override
  String get table_activeFiltersLabel => 'Filtres :';

  @override
  String get common_clearButton => 'Effacer';

  @override
  String table_selectedCountLabel(int count) {
    return '$count sélectionné(s)';
  }

  @override
  String table_columnSelectedCountLabel(String column, int count) {
    return '$column : $count sélectionné(s)';
  }

  @override
  String get table_columnFallbackLabel => 'Colonne';

  @override
  String table_selectAllCountLabel(int count) {
    return 'Tout sélectionner ($count)';
  }

  @override
  String get table_noResultsShort => 'Aucun résultat';

  @override
  String table_applyCountLabel(int count) {
    return 'Appliquer ($count)';
  }

  @override
  String get table_applyButton => 'Appliquer';

  @override
  String table_recordCountFiltered(int filtered, int total) {
    return '$filtered / $total enregistrements';
  }

  @override
  String table_recordCount(int total) {
    return '$total enregistrements';
  }

  @override
  String table_totalRecordCount(int total) {
    return 'Total : $total enregistrements';
  }

  @override
  String get table_prevPageTooltip => 'Page précédente';

  @override
  String get table_nextPageTooltip => 'Page suivante';

  @override
  String get table_exportSelectedTooltip => 'Exporter la sélection';

  @override
  String get table_categoriesDefaultTitle => 'Catégories';

  @override
  String table_columnFallback(int index) {
    return 'Colonne $index';
  }

  @override
  String get dateFilter_yesterday => 'Hier';

  @override
  String get dateFilter_lastWeek => 'La semaine dernière';

  @override
  String get dateFilter_thisMonth => 'Ce mois-ci';

  @override
  String get dateFilter_last30Days => 'Les 30 derniers jours';

  @override
  String get dateFilter_customRange => 'Définir une plage personnalisée...';

  @override
  String get dateFilter_clearFilter => 'Effacer le filtre';

  @override
  String get dateFilter_noFilter => 'Aucun filtre';

  @override
  String get dateFilter_selectedRange => 'Plage sélectionnée';

  @override
  String get dateFilter_selectRangeTitle => 'Sélectionner la plage de dates';

  @override
  String get dateFilter_startDate => 'Début';

  @override
  String get dateFilter_endDate => 'Fin';

  @override
  String get common_selectPlaceholder => 'Veuillez sélectionner';

  @override
  String selectionDialog_selectedCount(int count) {
    return '$count éléments sélectionnés';
  }

  @override
  String get selectionDialog_noSelection => 'Aucune sélection effectuée';

  @override
  String get selectionDialog_confirmButton => 'Sélectionner';

  @override
  String get dateField_placeholder => 'Sélectionner une date';

  @override
  String timeField_helpTextWithDay(String day) {
    return 'Sélectionnez une heure pour $day';
  }

  @override
  String get timeField_helpText => 'Sélectionner une heure';

  @override
  String get timeField_placeholder => 'Sélectionner l\'heure';

  @override
  String doseStepper_manualEntryTitle(String unit) {
    return 'Entrez la quantité en $unit';
  }

  @override
  String get numpad_defaultTitle => 'Entrez la quantité';

  @override
  String get keyboard_closeButton => 'Fermer';

  @override
  String get keyboard_enterLabel => '↵ OK';

  @override
  String get keyboard_dashKeyLabel => '— Tiret';

  @override
  String get keyboard_periodKeyLabel => '. Point';

  @override
  String get keyboard_shiftLabel => '⇧ Majuscule';

  @override
  String get keyboard_spaceLabel => 'ESPACE';

  @override
  String get staleBanner_justNow => 'à l\'instant';

  @override
  String staleBanner_minutesAgo(int minutes) {
    return 'il y a $minutes min';
  }

  @override
  String staleBanner_hoursAgo(int hours) {
    return 'il y a $hours h';
  }

  @override
  String get staleBanner_dataStaleMessage => 'Les données ne sont pas à jour. ';

  @override
  String get staleBanner_dataUnavailableMessage =>
      'Les données à jour sont indisponibles. L\'opération ne peut pas continuer. ';

  @override
  String staleBanner_lastUpdatedLabel(String time) {
    return 'Dernière mise à jour : $time';
  }

  @override
  String get staleBanner_blockedBadge => 'Bloqué';

  @override
  String timeChip_today(String time) {
    return 'Aujourd\'hui $time';
  }

  @override
  String timeChip_tomorrow(String time) {
    return 'Demain $time';
  }

  @override
  String get cabin_lockButton => 'Verrouiller';

  @override
  String get cabin_criticalStockLabel => 'Stock critique';

  @override
  String get cabin_criticalStockSubLabel => 'réapprovisionnement nécessaire';

  @override
  String get cabin_legendFillNormal => 'Stock normal';

  @override
  String get cabin_legendFillNeeded => 'Remplissage nécessaire';

  @override
  String get cabin_legendFillUrgent => 'Remplissage urgent';

  @override
  String get cabin_serumTypeLabel => 'SÉRUM';

  @override
  String get cabin_unitDoseTypeLabel => 'D.UNIT';

  @override
  String get refund_showCompletedTooltip => 'Afficher les Terminés';

  @override
  String get refund_showIncompleteTooltip => 'Afficher les Non Terminés';

  @override
  String get dashboard_sensor_title => 'Capteurs';

  @override
  String get dashboard_sensor_temperature => 'Température';

  @override
  String get dashboard_sensor_humidity => 'Humidité';

  @override
  String get dashboard_sensor_battery => 'Batterie';

  @override
  String get dashboard_climate_title => 'Conditions ambiantes';

  @override
  String get dashboard_sensor_outOfRange => 'Hors plage';

  @override
  String get dashboard_upcomingTreatmentsPanelTitle => 'Traitements à Venir';

  @override
  String dashboard_upcomingTreatmentsCountBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count planifiés',
      one: '$count planifié',
    );
    return '$_temp0';
  }

  @override
  String get dashboard_upcomingTreatmentsEmptyTitle =>
      'Aucun traitement planifié';

  @override
  String get dashboard_upcomingTreatmentsOverdueStatus => 'en retard';

  @override
  String get dashboard_drugActivityPanelTitle => 'Activité des Médicaments';

  @override
  String get dashboard_drugActivityEmptyTitle =>
      'Aucune activité pour le moment';

  @override
  String get dashboard_activitiesLoadError =>
      'Impossible de charger l\'activité des médicaments';

  @override
  String get dashboard_telemetryPanelTitle => 'Environnement de l\'Armoire';

  @override
  String get dashboard_telemetryPausedStatus => 'En pause';

  @override
  String get dashboard_kpiActivePatientsLabel => 'Patients Actifs';

  @override
  String get dashboard_kpiCompletedOperationsLabel => 'Opérations Terminées';

  @override
  String get dashboard_kpiPendingPrescriptionsLabel =>
      'Prescriptions en Attente';

  @override
  String get dashboard_kpiCriticalAlertsLabel => 'Alertes Critiques';

  @override
  String get common_seeAllButton => 'Tout Voir';

  @override
  String get common_unknownFallback => 'Inconnu';

  @override
  String get common_justNowStatus => 'à l\'instant';

  @override
  String common_minutesAgoStatus(int count) {
    return 'il y a $count min';
  }

  @override
  String common_hoursAgoStatus(int count) {
    return 'il y a $count h';
  }

  @override
  String common_daysAgoStatus(int count) {
    return 'il y a $count j';
  }

  @override
  String common_minutesRemainingStatus(int count) {
    return 'dans $count min';
  }

  @override
  String common_hoursRemainingStatus(int count) {
    return 'dans $count h';
  }

  @override
  String common_daysRemainingStatus(int count) {
    return 'dans $count j';
  }

  @override
  String get refill_hint_selectSlots =>
      'Sélectionnez les cellules à remplir. Les cellules à faible stock sont signalées.';

  @override
  String get refill_title_fillCells => 'Remplir les cellules';

  @override
  String get refill_hint_miadRequired => 'Date de péremption requise';

  @override
  String get refill_status_openingTitle => 'Ouverture du tiroir…';

  @override
  String get refill_status_openingBody =>
      'Veuillez patienter, le tiroir physique s\'ouvre.';

  @override
  String get refill_status_waitingPullTitle => 'Tirez le tiroir';

  @override
  String get refill_status_waitingPullBody =>
      'Le verrou est libéré. Tirez le tiroir pour continuer.';

  @override
  String get refill_status_openingLidTitle => 'Ouverture de la cellule…';

  @override
  String get refill_status_openingLidBody =>
      'Veuillez patienter, le couvercle de la cellule s\'ouvre.';

  @override
  String get refill_status_stockOk => 'En stock';

  @override
  String get refill_status_stockLow => 'Faible';

  @override
  String get refill_status_stockCritical => 'Critique';

  @override
  String get refill_stop_confirmTitle => 'Arrêter le remplissage ?';

  @override
  String get refill_stop_confirmMessage =>
      'Si vous arrêtez, le tiroir ouvert sera verrouillé et ce remplissage sera marqué comme partiellement terminé. Les quantités saisies sont conservées, mais vous ne pourrez pas reprendre — vous devrez démarrer un nouveau remplissage.';

  @override
  String get refill_stop_confirmYes => 'Oui, arrêter';

  @override
  String get enumCore_prescriptionMovementPendingApprovalLabel =>
      'En attente d\'approbation';

  @override
  String get enumCore_prescriptionMovementPurchasePendingLabel =>
      'En attente d\'achat';

  @override
  String get enumCore_prescriptionMovementAppliedLabel => 'Appliqué';

  @override
  String get enumCore_prescriptionMovementReturnedLabel => 'Retourné';

  @override
  String get enumCore_prescriptionMovementWastagedLabel => 'Gaspillé';

  @override
  String get enumCore_prescriptionMovementDestructedLabel => 'Détruit';

  @override
  String get enumCore_prescriptionMovementCancelledLabel => 'Annulé';

  @override
  String get enumCore_prescriptionMovementRejectedLabel => 'Rejeté';

  @override
  String get enumCore_prescriptionMovementFilledWaitingLabel =>
      'En attente de remplissage';

  @override
  String get enumCore_prescriptionMovementReturnPendingLabel =>
      'Retour en attente';

  @override
  String get enumCore_prescriptionMovementUnloadedLabel => 'Déchargé';

  @override
  String get enumCore_prescriptionMovementShortageReportedLabel =>
      'Pénurie signalée';

  @override
  String get enumCore_prescriptionMovementReplenishmentPendingLabel =>
      'Réapprovisionnement en attente';

  @override
  String get enumCore_prescriptionMovementPendingApprovalActorLabel =>
      'Créé par';

  @override
  String get enumCore_prescriptionMovementPurchasePendingActorLabel =>
      'Rempli par';

  @override
  String get enumCore_prescriptionMovementAppliedActorLabel => 'Appliqué par';

  @override
  String get enumCore_prescriptionMovementReturnedActorLabel => 'Retourné par';

  @override
  String get enumCore_prescriptionMovementWastagedActorLabel => 'Gaspillé par';

  @override
  String get enumCore_prescriptionMovementDestructedActorLabel => 'Détruit par';

  @override
  String get enumCore_prescriptionMovementCancelledActorLabel => 'Annulé par';

  @override
  String get enumCore_prescriptionMovementRejectedActorLabel => 'Rejeté par';

  @override
  String get enumCore_prescriptionMovementFilledWaitingActorLabel =>
      'Approuvé par';

  @override
  String get enumCore_prescriptionMovementReturnPendingActorLabel =>
      'Retour demandé par';

  @override
  String get enumCore_prescriptionMovementUnloadedActorLabel => 'Déchargé par';

  @override
  String get enumCore_prescriptionMovementShortageReportedActorLabel =>
      'Pénurie signalée par';

  @override
  String get enumCore_prescriptionMovementReplenishmentPendingActorLabel =>
      'Réapprovisionnement approuvé par';

  @override
  String get enumCore_prescriptionMovementRedirectedLabel => 'Redirigé';

  @override
  String get enumCore_prescriptionMovementRedirectedActorLabel =>
      'Redirigé par';

  @override
  String get enumCore_prescriptionMovementRedirectedActionLabel => 'A redirigé';

  @override
  String get enumCore_prescriptionMovementPendingApprovalActionLabel => 'Créé';

  @override
  String get enumCore_prescriptionMovementPurchasePendingActionLabel =>
      'Rempli';

  @override
  String get enumCore_prescriptionMovementAppliedActionLabel => 'Appliqué';

  @override
  String get enumCore_prescriptionMovementReturnedActionLabel => 'Retourné';

  @override
  String get enumCore_prescriptionMovementWastagedActionLabel => 'Gaspillé';

  @override
  String get enumCore_prescriptionMovementDestructedActionLabel => 'Détruit';

  @override
  String get enumCore_prescriptionMovementCancelledActionLabel => 'Annulé';

  @override
  String get enumCore_prescriptionMovementRejectedActionLabel => 'Rejeté';

  @override
  String get enumCore_prescriptionMovementFilledWaitingActionLabel =>
      'Approuvé';

  @override
  String get enumCore_prescriptionMovementReturnPendingActionLabel =>
      'Retour demandé';

  @override
  String get enumCore_prescriptionMovementUnloadedActionLabel => 'Déchargé';

  @override
  String get enumCore_prescriptionMovementShortageReportedActionLabel =>
      'Pénurie signalée';

  @override
  String get enumCore_prescriptionMovementReplenishmentPendingActionLabel =>
      'Réapprovisionnement approuvé';

  @override
  String get userAuth_table_firstNameColumn => 'Prénom';

  @override
  String get userAuth_table_lastNameColumn => 'Nom';

  @override
  String get userAuth_table_occupationTypeColumn => 'Type de profession';

  @override
  String get userAuth_table_expiryDateColumn => 'Date d\'expiration';

  @override
  String get userAuth_table_remainingDaysColumn => 'Jours restants';

  @override
  String get userAuth_table_statusColumn => 'Statut';

  @override
  String get medicine_table_barcodeColumn => 'Code-barres';

  @override
  String get medicine_table_atcCodeColumn => 'Code ATC';

  @override
  String get medicine_table_nameColumn => 'Nom';

  @override
  String get medicine_table_materialTypeColumn => 'Type de matériel';

  @override
  String get medicine_table_prescriptionTypeColumn => 'Type d\'ordonnance';

  @override
  String get medicine_table_countTypeColumn => 'Type de comptage';

  @override
  String get medicine_table_purchaseTypeColumn => 'Mode d\'acquisition';

  @override
  String get medicine_table_returnTypeColumn => 'Mode de retour';

  @override
  String get medicine_table_statusColumn => 'Actif';

  @override
  String get enumCore_medicineTypeDrug => 'Médicament';

  @override
  String get enumCore_medicineTypeConsumable => 'Consommable médical';

  @override
  String get refund_table_patientCodeColumn => 'Code patient';

  @override
  String get refund_table_patientColumn => 'Patient';

  @override
  String get refund_table_userColumn => 'Utilisateur';

  @override
  String get refund_table_medicineColumn => 'Médicament';

  @override
  String get refund_table_quantityColumn => 'Quantité';

  @override
  String get refund_table_dateColumn => 'Date';

  @override
  String get refund_table_approvedUserColumn => 'Retour accepté par';

  @override
  String get refund_table_approvedDateColumn => 'Date d\'acceptation';

  @override
  String get refund_table_descriptionColumn => 'Description';

  @override
  String get authorization_table_userColumn => 'Utilisateur';

  @override
  String get authorization_table_roleColumn => 'Rôle';

  @override
  String get authorization_table_encryptedLoginColumn => 'Connexion chiffrée';

  @override
  String get authorization_table_isDeletedColumn => 'Supprimé';

  @override
  String get authorization_table_extraAuthCountColumn =>
      'Autorisation supplémentaire';

  @override
  String get cabinTemperature_table_dateColumn => 'Date';

  @override
  String get cabinTemperature_table_cabinColumn => 'Armoire';

  @override
  String get cabinTemperature_table_insideTempColumn =>
      'Température intérieure';

  @override
  String get cabinTemperature_table_outsideTempColumn =>
      'Température extérieure';

  @override
  String get cabinTemperature_table_humidityColumn => 'Humidité';

  @override
  String get cabinTemperature_action_showOutOfRange => 'Afficher hors limites';

  @override
  String get cabinTemperature_action_showAll => 'Tout afficher';

  @override
  String get expiredItems_table_barcodeColumn => 'Code-barres';

  @override
  String get expiredItems_table_medicineColumn => 'Médicament';

  @override
  String get expiredItems_table_cabinColumn => 'Armoire';

  @override
  String get expiredItems_table_locationColumn => 'Emplacement';

  @override
  String get expiredItems_table_minQuantityColumn => 'Minimum';

  @override
  String get expiredItems_table_maxQuantityColumn => 'Maximum';

  @override
  String get expiredItems_table_criticalQuantityColumn => 'Critique';

  @override
  String get expiredItems_table_quantityColumn => 'Quantité';

  @override
  String get expiredItems_table_expiryDateColumn => 'Date d\'exp.';

  @override
  String get expiredItems_table_remainingDaysColumn => 'Jours restants';

  @override
  String get hospitalStock_table_serviceColumn => 'Service';

  @override
  String get hospitalStock_table_codeColumn => 'Code';

  @override
  String get hospitalStock_table_medicineColumn => 'Médicament';

  @override
  String get hospitalStock_table_quantityColumn => 'Quantité';

  @override
  String get patientInventory_table_doctorColumn => 'Médecin';

  @override
  String get patientInventory_table_departmentColumn => 'Département';

  @override
  String get patientInventory_table_barcodeColumn => 'Code-barres';

  @override
  String get patientInventory_table_medicineColumn => 'Médicament';

  @override
  String get patientInventory_table_requestedQuantityColumn => 'Qté demandée';

  @override
  String get patientInventory_table_processedQuantityColumn => 'Qté traitée';

  @override
  String get patientInventory_table_requestDateColumn => 'Date de demande';

  @override
  String get patientInventory_table_processDateColumn => 'Date de traitement';

  @override
  String get patientInventory_table_movementColumn => 'Mouvement';

  @override
  String patientInventory_pdf_title(String patientName) {
    return 'Liste d\'inventaire du patient $patientName';
  }

  @override
  String patientInventory_pdf_patientCode(Object code) {
    return 'Code patient : $code';
  }

  @override
  String patientInventory_pdf_service(String name) {
    return 'Service : $name';
  }

  @override
  String patientInventory_pdf_bed(String name) {
    return 'Lit : $name';
  }

  @override
  String patientInventory_pdf_reportDate(String date) {
    return 'Date du rapport : $date';
  }

  @override
  String get service_table_nameColumn => 'Nom du service';

  @override
  String get service_table_branchColumn => 'Branche';

  @override
  String get service_table_managerColumn => 'Responsable du service';

  @override
  String get service_table_statusColumn => 'Statut';

  @override
  String get unappliedPrescription_table_serviceColumn => 'Service';

  @override
  String get unappliedPrescription_table_roomColumn => 'Chambre';

  @override
  String get unappliedPrescription_table_bedColumn => 'Lit';

  @override
  String get unappliedPrescription_table_patientCodeColumn => 'Code patient';

  @override
  String get unappliedPrescription_table_patientColumn => 'Patient';

  @override
  String get unappliedPrescription_table_hospitalizationCodeColumn =>
      'Code d\'admission';

  @override
  String get unappliedPrescription_table_admissionDateColumn =>
      'Date d\'admission';

  @override
  String get unappliedPrescription_table_pendingCountColumn => 'En attente';

  @override
  String get drugActivity_table_dateColumn => 'Date';

  @override
  String get drugActivity_table_timeColumn => 'Heure';

  @override
  String get drugActivity_table_patientColumn => 'Patient';

  @override
  String get drugActivity_table_userColumn => 'Utilisateur';

  @override
  String get drugActivity_table_medicineColumn => 'Médicament';

  @override
  String get drugActivity_table_quantityColumn => 'Quantité';

  @override
  String get drugActivity_table_movementColumn => 'Mouvement';

  @override
  String get rfid_notConnectedError => 'Le lecteur RFID n\'est pas connecté';

  @override
  String rfid_inventoryStartFailedError(String detail) {
    return 'Échec du démarrage de l\'inventaire RFID : $detail';
  }

  @override
  String rfid_inventoryStreamError(String detail) {
    return 'Erreur du flux d\'inventaire RFID : $detail';
  }

  @override
  String get mobileDrawer_cabinConnectionErrorMessage =>
      'Impossible de communiquer avec l\'armoire. Veuillez réessayer ou contacter le personnel autorisé.';

  @override
  String get settingsView_title => 'Paramètres';

  @override
  String get settingsView_subtitle => 'CONFIGURATION SYSTÈME';

  @override
  String get settingsView_generalNav => 'Général';

  @override
  String get settingsView_appearanceNav => 'Apparence';

  @override
  String get settingsView_cabinNav => 'Paramètres de l\'armoire';

  @override
  String get settingsView_prescriptionNav => 'Paramètres de prescription';

  @override
  String get settingsView_developerNav => 'Développeur';

  @override
  String get settingsView_debugNav => 'Débogage';

  @override
  String get settingsView_sectionComingSoon =>
      'Le contenu de cette section sera bientôt disponible.';

  @override
  String get census_hint_noMedicines => 'Aucun médicament à compter';

  @override
  String census_label_queueProgress(Object current, Object total) {
    return '$current / $total tiroirs';
  }

  @override
  String get census_action_stop => 'Arrêter';

  @override
  String get census_stop_confirmTitle =>
      'Voulez-vous vraiment arrêter l\'inventaire ?';

  @override
  String get census_stop_confirmMessage =>
      'Le processus d\'inventaire sera arrêté ; les comptages déjà effectués resteront enregistrés.';

  @override
  String get census_stop_confirmYes => 'Oui, arrêter';

  @override
  String get census_status_waitingPullTitle => 'En attente du tiroir';

  @override
  String get census_status_waitingPullBody => 'Veuillez tirer le tiroir';

  @override
  String get census_status_openingLidTitle => 'Ouverture de la case';

  @override
  String get census_status_openingLidBody =>
      'Veuillez patienter, la case s\'ouvre';

  @override
  String get census_status_openingTitle => 'Ouverture du tiroir';

  @override
  String get census_status_openingBody =>
      'Veuillez patienter, le tiroir s\'ouvre';

  @override
  String get census_action_nextCell => 'Case suivante';

  @override
  String get census_action_completeCensus => 'Terminer l\'inventaire';

  @override
  String get census_error_queueTitle =>
      'Une erreur s\'est produite pendant l\'inventaire';

  @override
  String get census_error_queueMessage =>
      'Vous pouvez retirer les médicaments du tiroir et continuer, ou terminer le processus ici.';

  @override
  String get census_error_continueNext => 'Continuer';

  @override
  String get census_error_endProcess => 'Terminer';

  @override
  String get census_label_countQty => 'Comptage';

  @override
  String get intake_screenTitle => 'Prise de Médicament';

  @override
  String get intake_phase_patientLabel => 'Sélection du Patient';

  @override
  String get intake_phase_medicineLabel => 'Sélection des Médicaments';

  @override
  String get intake_phase_executingLabel => 'Processus de Prise';

  @override
  String patientPicker_roomLabel(String room) {
    return 'Chambre $room';
  }

  @override
  String patientPicker_bedLabel(String bed) {
    return 'Lit $bed';
  }

  @override
  String intake_label_countFieldLabelIndexed(String unit, int index) {
    return 'Comptage $index ($unit)';
  }

  @override
  String get patientListPanel_filter_patientStatusLabel => 'Statut du Patient';

  @override
  String get patientListPanel_filter_orderStatusLabel => 'Statut de Commande';

  @override
  String get masterDrawer_status_devicePreparingTitle => 'Préparation';

  @override
  String get masterDrawer_status_devicePreparingSubtitle =>
      'Le système se prépare. Veuillez patienter un instant.';

  @override
  String get masterDrawer_status_lockOpeningTitle => 'Déverrouillage';

  @override
  String get masterDrawer_status_lockOpeningSubtitle =>
      'Le verrou du tiroir s\'ouvre. Veuillez patienter un instant.';

  @override
  String get masterDrawer_status_waitingPullTitle => 'Veuillez Tirer le Tiroir';

  @override
  String get masterDrawer_status_waitingPullSubtitle =>
      'Le verrou a été libéré. Tirez le tiroir pour l\'ouvrir et continuer.';

  @override
  String get masterDrawer_status_openingLidTitle => 'Ouverture du Compartiment';

  @override
  String get masterDrawer_status_openingLidSubtitle =>
      'Le couvercle du compartiment s\'ouvre. Veuillez patienter un instant.';

  @override
  String get masterDrawer_status_waitingCloseTitle =>
      'Veuillez Fermer le Tiroir';

  @override
  String get masterDrawer_status_waitingCloseSubtitle =>
      'Fermez le tiroir pour passer à l\'étape suivante.';

  @override
  String get masterDrawer_status_failedTitle => 'Un Problème est Survenu';

  @override
  String get masterDrawer_status_failedSubtitle =>
      'Veuillez patienter, l\'état du tiroir est en cours de vérification.';

  @override
  String get masterDrawer_status_openingTitle => 'Ouverture du Tiroir';

  @override
  String get masterDrawer_status_openingSubtitle =>
      'Le tiroir s\'ouvre. Veuillez patienter un instant.';

  @override
  String get masterDrawer_stop_waitingCloseTitle =>
      'Veuillez Fermer le Tiroir Ouvert';

  @override
  String get masterDrawer_stop_waitingCloseSubtitle =>
      'Veuillez fermer le tiroir ouvert. Le processus s\'arrêtera une fois celui-ci fermé.';

  @override
  String intake_label_queueProgress(int done, int total) {
    return 'Tiroir $done/$total';
  }

  @override
  String get intake_action_stop => 'Arrêter';

  @override
  String get intake_stop_confirmTitle => 'Arrêter la Prise ?';

  @override
  String get intake_stop_confirmMessage =>
      'Le processus de prise en cours sera arrêté. Les tiroirs terminés seront conservés.';

  @override
  String get intake_stop_confirmYes => 'Oui, Arrêter';

  @override
  String intake_hint_mergedFromMultiplePrescriptions(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Combiné à partir de $countString prescriptions',
      one: 'Combiné à partir de $countString prescription',
    );
    return '$_temp0';
  }

  @override
  String get refund_hint_searchMedicine => 'Rechercher un médicament';

  @override
  String get refund_hint_selectPatientFirst =>
      'Sélectionnez d\'abord un patient';

  @override
  String get refund_hint_noMedicineFound =>
      'Aucun médicament remboursable trouvé';

  @override
  String get refund_action_start => 'Démarrer le retour';

  @override
  String get refund_action_nextCell => 'Cellule suivante';

  @override
  String get refund_action_completeRefund => 'Terminer le retour';

  @override
  String get refund_action_stop => 'Arrêter';

  @override
  String get refund_action_stopConfirmTitle => 'Arrêter le retour ?';

  @override
  String get refund_action_stopConfirmMessage =>
      'Les retours terminés seront conservés, les tiroirs restants ne seront pas traités.';

  @override
  String get refund_action_stopConfirmYes => 'Oui, arrêter';

  @override
  String get refund_field_maxAmount => 'Max. remboursable';

  @override
  String get refund_field_returnNote => 'Note de retour';

  @override
  String get refund_status_checking => 'Vérification en cours...';

  @override
  String get refund_status_ready => 'Prêt';

  @override
  String get refund_status_checkFailed => 'Échec de la vérification';

  @override
  String get refund_error_queueTitle => 'Erreur de retour';

  @override
  String get refund_error_continueNext => 'Continuer avec le suivant';

  @override
  String get refund_error_endProcess => 'Terminer le processus';

  @override
  String get refund_error_amountZero =>
      'Le montant du retour ne peut pas être 0';

  @override
  String get refund_error_amountExceedsMax =>
      'Le montant du retour ne peut pas dépasser la quantité reçue';

  @override
  String refund_label_progress(int done, int total) {
    return '$done / $total tiroirs';
  }

  @override
  String get waste_hint_searchMedicine => 'Rechercher un médicament';

  @override
  String get waste_hint_selectPatientFirst =>
      'Sélectionnez un patient pour continuer';

  @override
  String get waste_hint_noMedicineFound =>
      'Aucun médicament à jeter/détruire trouvé';

  @override
  String waste_label_availableAmount(String amount) {
    return 'Quantité disponible : $amount';
  }

  @override
  String get witnessDialog_title => 'Vérification du témoin';

  @override
  String get witnessDialog_usernameLabel => 'Nom d\'utilisateur';

  @override
  String get witnessDialog_usernameRequired =>
      'Le nom d\'utilisateur est requis';

  @override
  String get witnessDialog_passwordLabel => 'Mot de passe';

  @override
  String get witnessDialog_passwordRequired => 'Le mot de passe est requis';

  @override
  String get witnessDialog_confirmButton => 'Confirmer';

  @override
  String get witnessDialog_anyoneInfo =>
      'N\'importe quel utilisateur peut témoigner pour cet élément.';

  @override
  String witnessDialog_authorizedWitnesses(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString témoins autorisés',
      one: '$countString témoin autorisé',
    );
    return '$_temp0';
  }

  @override
  String get witnessDialog_error_selfWitness =>
      'Vous ne pouvez pas témoigner de votre propre opération.';

  @override
  String witnessDialog_success_confirmed(String witnessName) {
    return '$witnessName confirmé comme témoin.';
  }

  @override
  String witnessDialog_assignedLabel(String witnessName) {
    return 'Témoin : $witnessName';
  }

  @override
  String get witnessDialog_requiredHint => 'Confirmation du témoin requise';

  @override
  String witnessDialog_autoAssigned(String witnessName) {
    return '$witnessName a été automatiquement assigné comme témoin pour cet élément.';
  }

  @override
  String get unload_hint_searchMedicine =>
      'Rechercher un médicament ou un code-barres';

  @override
  String get unload_hint_noMedicineFound => 'Aucun médicament trouvé';

  @override
  String get unload_action_stop => 'Arrêter';

  @override
  String get unload_action_nextCell => 'Cellule suivante';

  @override
  String get unload_action_completeUnloading => 'Terminer le déchargement';

  @override
  String get unload_stop_confirmTitle => 'Arrêter le déchargement ?';

  @override
  String get unload_stop_confirmMessage =>
      'Les tiroirs restants dans la file d\'attente ne seront pas déchargés. Voulez-vous vraiment arrêter ?';

  @override
  String get unload_stop_confirmYes => 'Oui, arrêter';

  @override
  String get unload_error_queueTitle => 'Erreur de Vidage';

  @override
  String get unload_error_continueNext => 'Continuer au tiroir suivant';

  @override
  String get unload_error_endProcess => 'Terminer le processus';

  @override
  String unload_label_queueProgress(int done, int total) {
    return 'Tiroir $done sur $total';
  }

  @override
  String get unload_label_countQty => 'Comptage';

  @override
  String get unload_label_unloadQty => 'Qté à retirer';

  @override
  String get refund_label_quantity => 'Quantité';

  @override
  String destruction_label_queueProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String get destruction_action_stop => 'Arrêter';

  @override
  String get destruction_stop_confirmTitle => 'Arrêter la destruction ?';

  @override
  String get destruction_stop_confirmMessage =>
      'Le processus de destruction sera arrêté. Les éléments déjà traités seront conservés.';

  @override
  String get destruction_stop_confirmYes => 'Oui, arrêter';

  @override
  String get destruction_label_quantity => 'Qté à détruire';

  @override
  String get destruction_action_nextCell => 'Cellule suivante';

  @override
  String get destruction_action_completeDestruction =>
      'Terminer la destruction';

  @override
  String get waste_hint_notAuthorized =>
      'Vous n\'êtes pas autorisé à détruire ce médicament';

  @override
  String get intake_action_checkEquivalent => 'Vérifier l\'équivalent';

  @override
  String get intake_hint_noEquivalentFound =>
      'Aucun médicament équivalent trouvé';

  @override
  String get intake_label_equivalentOptions => 'Équivalents disponibles';

  @override
  String get intake_hint_searchingOtherStations =>
      'Recherche dans d\'autres armoires...';

  @override
  String get intake_hint_noStockAnywhere =>
      'Ce médicament est introuvable dans toutes les armoires';

  @override
  String get intake_label_otherStationOptions =>
      'Disponible dans d\'autres armoires';

  @override
  String get intake_action_redirect => 'Rediriger';

  @override
  String intake_hint_redirectedTo(String stationName) {
    return 'Redirigé vers l\'armoire $stationName';
  }

  @override
  String get intake_status_redirected => 'Redirigé';

  @override
  String get intake_tab_prescriptions => 'Prescriptions';

  @override
  String get intake_tab_redirectedOrders => 'Commandes redirigées';

  @override
  String get intake_hint_noRedirectedOrders => 'Aucune commande redirigée';

  @override
  String intake_status_redirectedFrom(String stationName) {
    return 'Redirigé depuis $stationName';
  }

  @override
  String intake_label_redirectedBy(String userName) {
    return 'Redirigé par $userName';
  }

  @override
  String get refund_action_completeDirect => 'Retourner';

  @override
  String get refund_success_dialogTitle => 'Retour terminé';

  @override
  String get refund_success_toPharmacyMessage =>
      'Le retour a été effectué. Veuillez remettre le médicament au pharmacien.';

  @override
  String get refund_success_toReturnBoxMessage =>
      'Le retour a été effectué. Veuillez placer le médicament dans la boîte de retour.';

  @override
  String get cabin_returnDrawerName => 'Tiroir de retour';

  @override
  String get cabin_returnDrawerView => 'Boîte de retour';

  @override
  String get cabin_returnDrawerViewTitle =>
      'Ce tiroir est désigné comme boîte de retour';

  @override
  String get cabin_returnDrawerViewSubtitle =>
      'L\'attribution/le remplissage de médicaments n\'est pas disponible pour ce tiroir';

  @override
  String get cabinDesign_dialogTitle => 'Conception de l\'armoire';

  @override
  String get cabinDesign_syncBadge => 'SYNCHRONISÉ';

  @override
  String get cabinDesign_basicSettings_sectionTitle => 'Paramètres de base';

  @override
  String get cabinDesign_basicSettings_nameLabel => 'Nom de l\'armoire';

  @override
  String get cabinDesign_basicSettings_stationLabel => 'Station';

  @override
  String get cabinDesign_basicSettings_comPortLabel => 'Port COM';

  @override
  String get cabinDesign_basicSettings_dvrIpLabel => 'IP DVR';

  @override
  String get cabinDesign_detail_sectionTitle => 'Détail du tiroir';

  @override
  String get cabinDesign_detail_typeLabel => 'Type';

  @override
  String cabinDesign_detail_typeKubik(int rows, int cols) {
    return 'Cubique $rows×$cols';
  }

  @override
  String get cabinDesign_detail_cellCountLabel => 'Nombre de cases';

  @override
  String get cabinDesign_detail_addressLabel => 'Adresse';

  @override
  String get cabinDesign_detail_configLabel => 'Configuration';

  @override
  String get cabinDesign_returnDrawer_toggleLabel => 'Tiroir de retour';

  @override
  String get cabinDesign_returnDrawer_toggleHint =>
      'Ce tiroir sera réservé aux opérations de retour';

  @override
  String cabinDesign_returnDrawer_currentInfo(String address) {
    return 'Un seul tiroir de retour peut être désigné par armoire. Actuellement : $address';
  }

  @override
  String get cabinDesign_returnDrawer_noneInfo =>
      'Un seul tiroir de retour peut être désigné par armoire. Aucun désigné pour le moment.';

  @override
  String get cabinDesign_serum_sectionTitle => 'Disposition interne';

  @override
  String get cabinDesign_serum_manualBadge => 'CONFIGURATION MANUELLE';

  @override
  String get cabinDesign_serum_infoBanner =>
      'La disposition interne d\'une armoire à sérum n\'est pas lue depuis la carte ; définissez ici ses tiroirs et la disposition du matériel.';

  @override
  String get cabinDesign_serum_drawerCountLabel => 'Nombre de tiroirs';

  @override
  String cabinDesign_serum_drawerCardTitle(int index) {
    return 'Tiroir $index';
  }

  @override
  String cabinDesign_serum_drawerCardSummary(
    int sideBySide,
    int frontToBack,
    int total,
  ) {
    return '$sideBySide×$frontToBack = $total équipements';
  }

  @override
  String get cabinDesign_serum_equipmentLayoutTitle =>
      'Disposition du matériel';

  @override
  String cabinDesign_serum_drawerBadge(int index) {
    return 'S-0$index';
  }

  @override
  String get cabinDesign_serum_sideBySideLabel => 'Côte à côte';

  @override
  String get cabinDesign_serum_frontToBackLabel => 'D\'avant en arrière';

  @override
  String get cabinDesign_serum_topViewLabel => 'Vue de dessus';

  @override
  String cabinDesign_serum_totalEquipmentLabel(
    int sideBySide,
    int frontToBack,
    int total,
  ) {
    return '$sideBySide × $frontToBack = $total équipements';
  }

  @override
  String get cabinDesign_serum_frontLabel => '← avant';

  @override
  String get cabinDesign_serum_backLabel => 'arrière →';

  @override
  String get cabinDesign_serum_applyToAllButton =>
      'Appliquer cette disposition à tous les tiroirs';

  @override
  String cabinDesign_serum_incompleteWarning(String missingDrawerLabel) {
    return 'La conception ne peut pas être enregistrée tant que la disposition de chaque tiroir n\'est pas définie. Manquant : $missingDrawerLabel';
  }

  @override
  String get cabinDesign_noSelectionHint =>
      'Sélectionnez un tiroir pour voir ses détails.';

  @override
  String get cabinDesign_scanButton => 'Scanner l\'appareil';

  @override
  String get cabinDesign_saveButton => 'Enregistrer la conception';

  @override
  String get cabinDesign_returnBadge => 'RETOUR';

  @override
  String get cabin_returnBoxLabel => 'BOÎTE DE RETOUR';

  @override
  String get unload_segment_returnDrawer => 'Tiroir de Retour';

  @override
  String get unload_segment_returnBox => 'Boîte de Retour';

  @override
  String get unload_hint_noDrawerMedicineFound =>
      'Aucun médicament trouvé dans le tiroir de retour';

  @override
  String get unload_hint_noBoxMedicineFound =>
      'Aucun médicament trouvé dans la boîte de retour';

  @override
  String get unload_fieldReturnedBy => 'Retourné Par';

  @override
  String get unload_action_startDrawerUnload => 'Démarrer le Vidage du Tiroir';

  @override
  String get unload_action_completeBoxUnload =>
      'Terminer le Vidage de la Boîte';

  @override
  String get unload_label_drawerInProgress =>
      'Vidage du Tiroir de Retour en Cours';

  @override
  String get unload_action_stopConfirmTitle => 'Arrêter le Vidage du Tiroir ?';

  @override
  String get unload_action_stopConfirmMessage =>
      'Le tiroir se fermera et le vidage ne sera pas terminé. Voulez-vous continuer ?';

  @override
  String get unload_action_stopConfirmYes => 'Oui, Arrêter';

  @override
  String get unload_action_completeDrawerUnload =>
      'Terminer le Vidage du Tiroir';

  @override
  String get masterDrawer_error_managerNotFound =>
      'Carte de gestion introuvable. Vérifiez la connexion de l\'armoire.';

  @override
  String get masterDrawer_error_managerConnectFailed =>
      'Impossible de se connecter à l\'armoire. Vérifiez la connexion et réessayez.';

  @override
  String get masterDrawer_error_lockOpenFailed =>
      'Le verrou du tiroir n\'a pas pu être ouvert. Vérifiez le matériel.';

  @override
  String get masterDrawer_error_lidOpenFailed =>
      'Le couvercle n\'a pas pu être ouvert. Assurez-vous que le tiroir est complètement ouvert.';

  @override
  String get masterDrawer_error_lockOpenTimeout =>
      'Le tiroir ne s\'est pas complètement ouvert à temps. Veuillez tirer le tiroir jusqu\'au bout.';

  @override
  String get masterDrawer_error_sensorCommunicationLost =>
      'La communication avec le matériel a été perdue. Vérifiez la connexion et réessayez.';

  @override
  String get masterDrawer_error_unexpectedlyClosed =>
      'Le tiroir a été fermé de manière inattendue pendant son utilisation. Veuillez le rouvrir et réessayer.';

  @override
  String get masterDrawer_status_completingTitle =>
      'Finalisation de votre opération';

  @override
  String get masterDrawer_status_completingSubtitle => 'Veuillez patienter';
}
