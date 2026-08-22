import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../cache/app_settings_cache.dart';
import 'providers.dart';

final getHospitalizationsUseCaseProvider = Provider((ref) {
  return GetHospitalizationsUseCase(ref.read(hospitalizationRepositoryProvider));
});

final getActiveHospitalizationsUseCaseProvider = Provider((ref) {
  return GetActiveHospitalizationsUseCase(ref.read(hospitalizationRepositoryProvider));
});

final getDrugsUseCaseProvider = Provider((ref) {
  return GetDrugsUseCase(ref.read(medicineRepositoryProvider));
});

// GetStationUseCase
final getStationUseCaseProvider = Provider((ref) {
  return GetStationUseCase(ref.read(stationRepositoryProvider));
});

final getServiceUseCaseProvider = Provider((ref) {
  return GetServiceUseCase(ref.read(serviceRepositoryProvider));
});

final _getAllServicesUseCaseProvider = Provider((ref) {
  return GetAllServicesUseCase(ref.read(serviceRepositoryProvider));
});

final _getAllRoomsUseCaseProvider = Provider((ref) {
  return GetAllRoomsUseCase(ref.read(serviceRepositoryProvider));
});

final _getAllBedsUseCaseProvider = Provider((ref) {
  return GetAllBedsUseCase(ref.read(serviceRepositoryProvider));
});

final allServicesProvider = FutureProvider<List<HospitalService>>((ref) async {
  final useCase = ref.read(_getAllServicesUseCaseProvider);
  final result = await useCase.call();
  return result.when(ok: (services) => services ?? [], error: (e) => throw e);
});

final allRoomsProvider = FutureProvider<List<Room>>((ref) async {
  final useCase = ref.read(_getAllRoomsUseCaseProvider);
  final result = await useCase.call();
  return result.when(ok: (rooms) => rooms ?? [], error: (_) => []);
});

final allBedsProvider = FutureProvider<List<Bed>>((ref) async {
  final useCase = ref.read(_getAllBedsUseCaseProvider);
  final result = await useCase.call();
  return result.when(ok: (beds) => beds ?? [], error: (_) => []);
});

// GetCriticalStocksUseCase
final getCriticalStocksUseCaseProvider = Provider((ref) {
  return GetCriticalStocksUseCase(ref.read(dashboardRepositoryProvider));
});

// GetExpiringMaterialsUseCase
final getExpiringMaterialsUseCaseProvider = Provider((ref) {
  return GetExpiringMaterialsUseCase(ref.read(dashboardRepositoryProvider));
});

// GetUpcomingTreatmensUseCase
final getUpcomingTreatmensUseCaseProvider = Provider((ref) {
  return GetUpcomingTreatmentsUseCase(ref.read(dashboardRepositoryProvider));
});

final getFilteredMenusUseCaseProvider = Provider<GetFilteredMenusUseCase>((ref) {
  return GetFilteredMenusUseCase(ref.read(dashboardRepositoryProvider), isManager: false);
});

final createBedAssignmentUseCaseProvider = Provider((ref) {
  return CreateBedAssignmentUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final createAssignmentUseCaseProvider = Provider((ref) {
  return CreateMedicineAssignmentUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final deleteBedAssignmentUseCaseProvider = Provider((ref) {
  return DeleteBedAssignmentUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final deleteAssignmentUseCaseProvider = Provider((ref) {
  return DeleteMedicineAssignmentUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final getBedAssignmentsUseCaseProvider = Provider((ref) {
  return GetBedAssignmentsUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final getMedicineAssignmentsUseCaseProvider = Provider((ref) {
  return GetMedicineAssignmentsUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final updateBedAssignmentUseCaseProvider = Provider((ref) {
  return UpdateBedAssignmentUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final updateMedicineAssignmentUseCaseProvider = Provider((ref) {
  return UpdateMedicineAssignmentUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final getCabinUseCaseProvider = Provider((ref) {
  return GetCabinUseCase(ref.read(cabinRepositoryProvider));
});

final clearMasterCabinFaultRecordProvider = Provider((ref) {
  return ClearMasterCabinFaultRecordUseCase(ref.read(faultRepositoryProvider));
});

final clearMobileCabinFaultRecordProvider = Provider((ref) {
  return ClearMobileCabinFaultRecordUseCase(ref.read(faultRepositoryProvider));
});

final createMasterCabinFaultRecordProvider = Provider((ref) {
  return CreateMasterCabinFaultRecordUseCase(ref.read(faultRepositoryProvider));
});

final createMobileCabinFaultRecordProvider = Provider((ref) {
  return CreateMobileCabinFaultRecordUseCase(ref.read(faultRepositoryProvider));
});

final getMasterCabinFaultRecordsProvider = Provider((ref) {
  return GetMasterCabinFaultRecordsUseCase(ref.read(faultRepositoryProvider));
});

final getMobileCabinFaultRecordsProvider = Provider((ref) {
  return GetMobileCabinFaultRecordsUseCase(ref.read(faultRepositoryProvider));
});

final getCabinVisualizerDataUseCaseProvider = Provider((ref) {
  return GetCabinVisualizerDataUseCase(
    ref.read(cabinRepositoryProvider),
    ref.read(getMasterCabinFaultRecordsProvider),
    ref.read(getMobileCabinFaultRecordsProvider),
  );
});

final createCabinUseCaseProvider = Provider((ref) {
  return CreateCabinUseCase(ref.read(cabinRepositoryProvider), ref.read(stationRepositoryProvider));
});

final updateCabinUseCaseProvider = Provider((ref) {
  return UpdateCabinUseCase(ref.read(cabinRepositoryProvider));
});

final saveCabinDesignUseCaseProvider = Provider((ref) {
  return SaveCabinDesignUseCase(
    cabinRepository: ref.read(cabinRepositoryProvider),
    localDataSource: ref.read(cabinLocaleDataSourceProvider),
  );
});

final saveMobileCabinDesignUseCaseProvider = Provider((ref) {
  return SaveMobileCabinDesignUseCase(
    cabinRepository: ref.read(cabinRepositoryProvider),
    localDataSource: ref.read(cabinLocaleDataSourceProvider),
  );
});

final finishCabinSetupUseCaseProvider = Provider((ref) {
  return FinishCabinSetupUseCase(
    createCabin: ref.read(createCabinUseCaseProvider),
    saveCabinDesign: ref.read(saveCabinDesignUseCaseProvider),
    appSettingsCache: ref.read(appSettingsCacheProvider),
    saveMobileCabinDesign: ref.read(saveMobileCabinDesignUseCaseProvider),
  );
});

final scanCabinUseCaseProvider = Provider((ref) {
  return ScanCabinUseCase(
    cabinRepository: ref.read(cabinRepositoryProvider),
    cabinOperationService: ref.read(cabinOperationServiceProvider),
    serialService: ref.read(serialServiceProvider),
  );
});

final getUnassignedStationsUseCaseProvider = Provider((ref) {
  return GetUnassignedStationsUseCase(ref.read(stationRepositoryProvider));
});

final testRfidConnectionUseCaseProvider = Provider((ref) {
  return TestRfidConnectionUseCase(ref.read(rfidServiceProvider));
});

final getPatientPrescriptionHistoryUseCaseProvider = Provider((ref) {
  return GetPatientPrescriptionHistoryUseCase(ref.read(prescriptionRepositoryProvider));
});

final getCurrentStationDrugActivityUseCaseProvider = Provider((ref) {
  return GetCurrentStationDrugActivityUseCase(ref.read(prescriptionRepositoryProvider));
});

final getPrescriptionItemMovementsUseCaseProvider = Provider((ref) {
  return GetPrescriptionItemMovementsUseCase(ref.read(prescriptionRepositoryProvider));
});

final refillMobileCabinUseCaseProvider = Provider((ref) {
  return RefillMobileCabinUseCase(ref.read(cabinStockRepositoryProvider));
});

final refillMasterCabinUseCaseProvider = Provider((ref) {
  return RefillMasterCabinUseCase(ref.read(cabinStockRepositoryProvider));
});

final getCabinAssignmentsUseCaseProvider = Provider((ref) {
  return GetStationAssignmentsUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final getCabinAssignmentsWitCabinUseCaseProvider = Provider((ref) {
  return GetCabinAssignmentsWithCabinUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final getCabinStocksUseCaseProvider = Provider((ref) {
  return GetCabinStockUseCase(ref.read(cabinStockRepositoryProvider));
});

final refillMasterCabinUsecaseProvider = Provider((ref) {
  return RefillMasterCabinUseCase(ref.read(cabinStockRepositoryProvider));
});

final checkMobileIntakeUseCaseProvider = Provider((ref) {
  return CheckMobileIntakeUseCase(ref.read(intakeRepositoryProvider));
});

final completeMobileIntakeUseCaseProvider = Provider((ref) {
  return CompleteMobileIntakeUseCase(ref.read(intakeRepositoryProvider));
});

final getMobileRefundablesUseCaseProvider = Provider((ref) {
  return GetMobileRefundablesUseCase(ref.read(refundRepositoryProvider));
});

final completeMobileRefundUseCaseProvider = Provider((ref) {
  return CompleteMobileRefundUseCase(ref.read(refundRepositoryProvider));
});

final checkMobileRefundStatusUseCaseProvider = Provider((ref) {
  return CheckMobileRefundStatusUseCase(ref.read(refundRepositoryProvider));
});

final mobileWastageUseCaseProvider = Provider((ref) {
  return MobileWastageUseCase(ref.read(wasteRepositoryProvider));
});

final mobileDestructionUseCaseProvider = Provider((ref) {
  return MobileDestructionUseCase(ref.read(wasteRepositoryProvider));
});

final masterWastageUseCaseProvider = Provider((ref) {
  return MasterWastageUseCase(ref.read(wasteRepositoryProvider));
});

final masterDisposeMaterialUseCaseProvider = Provider((ref) {
  return MasterDisposeMaterialUseCase(ref.read(wasteRepositoryProvider));
});

final masterDestructionUseCaseProvider = Provider((ref) {
  return MasterDestructionUseCase(ref.read(wasteRepositoryProvider));
});

final getMobileDisposablesUseCaseProvider = Provider((ref) {
  return GetMobileDisposablesUseCase(ref.read(wasteRepositoryProvider));
});

final getMasterDisposablesUseCaseProvider = Provider((ref) {
  return GetMasterDisposablesUseCase(ref.read(wasteRepositoryProvider), ref.read(medicineRepositoryProvider));
});

final getMasterDisposableMaterialsUseCaseProvider = Provider((ref) {
  return GetMasterDisposableMaterialsUseCase(ref.read(wasteRepositoryProvider), ref.read(medicineRepositoryProvider));
});

final getMyPatientsUseCaseProvider = Provider((ref) {
  return GetMyPatientsUseCase(ref.read(patientRepositoryProvider));
});

final addPatientUseCaseProvider = Provider((ref) {
  return AddPatientUseCase(ref.read(patientRepositoryProvider));
});

final removePatientsUseCaseProvider = Provider((ref) {
  return RemovePatientsUseCase(ref.read(patientRepositoryProvider));
});

final completeMobileCensusUseCaseProvider = Provider((ref) {
  return CompleteMobileCensusUseCase(ref.read(censusRepositoryProvider));
});

final completeMasterCensusUseCaseProvider = Provider((ref) {
  return CompleteMasterCensusUseCase(ref.read(censusRepositoryProvider));
});

final completeMobileUnloadUseCaseProvider = Provider((ref) {
  return CompleteMobileUnloadUseCase(ref.read(unloadRepositoryProvider));
});

final completeMasterUnloadUseCaseProvider = Provider((ref) {
  return CompleteMasterUnloadUseCase(ref.read(unloadRepositoryProvider));
});

final reportMissingStockUseCaseProvider = Provider((ref) {
  return ReportMissingStockUseCase(ref.read(cabinStockRepositoryProvider));
});

final reportExcessStockUseCaseProvider = Provider((ref) {
  return ReportExcessStockUseCase(ref.read(cabinStockRepositoryProvider));
});

final getIntakeItemsUseCaseProvider = Provider((ref) {
  return GetIntakeItemsUseCase(
    intakeRepository: ref.read(intakeRepositoryProvider),
    assignmentRepository: ref.read(assignmentRepositoryProvider),
    medicineRepository: ref.read(medicineRepositoryProvider),
  );
});

final checkIntakeUseCaseProvider = Provider((ref) {
  return CheckIntakeUseCase(ref.read(intakeRepositoryProvider));
});

final completeIntakeUseCaseProvider = Provider((ref) {
  return CompleteIntakeUseCase(ref.read(intakeRepositoryProvider));
});

final getCurrentStationUseCaseProvider = Provider((ref) {
  return GetCurrentStationUseCase(ref.read(stationRepositoryProvider));
});

final loginWitnessUseCaseProvider = Provider((ref) {
  return WitnessUserLoginUseCase(ref.read(userManagerProvider));
});

final getHospitalizationsByServiceUseCaseProvider = Provider((ref) {
  return GetHospitalizationsByServiceUseCase(ref.read(hospitalizationRepositoryProvider));
});

final createUrgentPatientUseCaseProvider = Provider((ref) {
  return CreateUrgentPatientUseCase(ref.read(patientRepositoryProvider));
});

final deleteUrgentPatientUseCaseProvider = Provider((ref) {
  return DeleteUrgentPatientUseCase(ref.read(patientRepositoryProvider));
});

final getUrgentPatientsUseCaseProvider = Provider((ref) {
  return GetUrgentPatientsUseCase(ref.read(patientRepositoryProvider));
});

final getMedicinesUseCaseProvider = Provider((ref) {
  return GetMedicinesUseCase(ref.read(medicineRepositoryProvider));
});

final getCabinExpectedEpcsUseCaseProvider = Provider((ref) {
  return GetCabinExpectedEpcsUseCase(ref.read(cabinStockRepositoryProvider));
});

final getDrugActivitiesUseCaseProvider = Provider((ref) {
  return GetDrugActivitiesUseCase(ref.read(dashboardRepositoryProvider));
});

final getUnappliedPrescriptionsUseCaseProvider = Provider((ref) {
  return GetDashboardUnappliedPrescriptionsUseCase(ref.read(dashboardRepositoryProvider));
});

final saveSensorValuesUseCaseProvider = Provider<SaveSensorValuesUseCase>(
  (ref) =>
      SaveSensorValuesUseCase(ref.read(cabinTemperatureRepositoryProvider), ref.read(getCurrentStationUseCaseProvider)),
);

final getCabinThresholdsUseCaseProvider = Provider<GetCabinThresholdsUseCase>(
  (ref) => GetCabinThresholdsUseCase(
    ref.read(cabinTemperatureRepositoryProvider),
    ref.read(getCurrentStationUseCaseProvider),
  ),
);

final scanManagerUseCaseProvider = Provider<ScanManagerUseCase>(
  (ref) => ScanManagerUseCase(ref.read(cabinOperationServiceProvider)),
);

final streamCabinSensorsUseCaseProvider = Provider<StreamCabinSensorsUseCase>(
  (ref) => StreamCabinSensorsUseCase(ref.read(scanManagerUseCaseProvider), ref.read(cabinOperationServiceProvider)),
);

final startMobileDrawerSessionUseCaseProvider = Provider((ref) {
  return StartMobileDrawerSessionUseCase(ref.read(scanManagerUseCaseProvider), ref.read(cabinOperationServiceProvider));
});

final startMasterDrawerSessionUseCaseProvider = Provider((ref) {
  return StartMasterDrawerSessionUseCase(ref.read(scanManagerUseCaseProvider), ref.read(cabinOperationServiceProvider));
});

final openCubicLidUseCaseProvider = Provider((ref) {
  return OpenCubicLidUseCase(ref.read(scanManagerUseCaseProvider), ref.read(cabinOperationServiceProvider));
});

final monitorDrawerClosureUseCaseProvider = Provider((ref) {
  return MonitorDrawerClosureUseCase(ref.read(scanManagerUseCaseProvider), ref.read(cabinOperationServiceProvider));
});

final getCabinsUseCaseProvider = Provider((ref) {
  return GetCabinsUseCase(ref.read(cabinRepositoryProvider));
});

final getSystemParametersUseCaseProvider = Provider((ref) {
  return GetSystemParametersUseCase(ref.read(settingsRepositoryProvider));
});

final getMasterRefundablesUseCaseProvider = Provider((ref) {
  return GetMasterRefundablesUseCase(ref.read(refundRepositoryProvider));
});

final checkMasterRefundStatusUseCaseProvider = Provider((ref) {
  return CheckMasterRefundStatusUseCase(ref.read(refundRepositoryProvider));
});

final completeRefundUseCaseProvider = Provider((ref) {
  return CompleteRefundUseCase(ref.read(refundRepositoryProvider));
});

final getExpiringStocksUseCaseProvider = Provider((ref) {
  return GetExpiringStocksUseCase(ref.read(cabinStockRepositoryProvider));
});

final getDailyJobListUseCaseProvider = Provider((ref) {
  return GetDailyJobListUseCase(ref.read(prescriptionRepositoryProvider));
});

final getUnscannedBarcodesUseCaseProvider = Provider((ref) {
  return GetUnscannedBarcodesUseCase(ref.read(prescriptionRepositoryProvider));
});

final getEquivalentMedicinesUseCaseProvider = Provider((ref) {
  return GetEquivalentMedicinesUseCase(ref.read(intakeRepositoryProvider), ref.read(medicineRepositoryProvider));
});

final checkEquivalentIntakeUseCaseProvider = Provider((ref) {
  return CheckEquivalentIntakeUseCase(ref.read(intakeRepositoryProvider));
});

final completeEquivalentIntakeUseCaseProvider = Provider((ref) {
  return CompleteEquivalentIntakeUseCase(ref.read(intakeRepositoryProvider));
});

final getOtherStationMedicinesUseCaseProvider = Provider((ref) {
  return GetOtherStationMedicinesUseCase(ref.read(intakeRepositoryProvider));
});

final redirectIntakeUseCaseProvider = Provider((ref) {
  return RedirectIntakeUseCase(ref.read(intakeRepositoryProvider));
});

final getPrescriptionDetailUseCaseProvider = Provider((ref) {
  return GetPrescriptionDetailUseCase(ref.read(prescriptionRepositoryProvider));
});

final getRedirectedIntakeOrdersUseCaseProvider = Provider((ref) {
  return GetRedirectedIntakeOrdersUseCase(ref.read(intakeRepositoryProvider));
});

final checkRedirectedIntakeUseCaseProvider = Provider((ref) {
  return CheckRedirectedIntakeUseCase(ref.read(intakeRepositoryProvider));
});

final completeRedirectedIntakeUseCaseProvider = Provider((ref) {
  return CompleteRedirectedIntakeUseCase(ref.read(intakeRepositoryProvider));
});

final setReturnDrawerUseCaseProvider = Provider((ref) {
  return SetReturnDrawerUseCase(ref.read(cabinRepositoryProvider));
});

final getReturnDrawerMedicinesUseCaseProvider = Provider((ref) {
  return GetReturnDrawerMedicinesUseCase(ref.read(unloadRepositoryProvider));
});

final unloadReturnDrawerUseCaseProvider = Provider((ref) {
  return UnloadReturnDrawerUseCase(ref.read(unloadRepositoryProvider));
});

final getReturnBoxMedicinesUseCaseProvider = Provider((ref) {
  return GetReturnBoxMedicinesUseCase(ref.read(unloadRepositoryProvider));
});

final unloadReturnBoxUseCaseProvider = Provider((ref) {
  return UnloadReturnBoxUseCase(ref.read(unloadRepositoryProvider));
});
