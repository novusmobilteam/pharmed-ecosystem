import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../cabin_operation/cabin_operation.dart';
import '../cache/app_settings_cache.dart';
import 'providers.dart';

final getHospitalizationsUseCaseProvider = Provider((ref) {
  return GetHospitalizationsUseCase(ref.read(hospitalizationRepositoryProvider));
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
    ref.read(appSettingsCacheProvider),
    ref.read(getMasterCabinFaultRecordsProvider),
    ref.read(getMobileCabinFaultRecordsProvider),
    ref.read(getCabinStocksUseCaseProvider),
  );
});

final createCabinUseCaseProvider = Provider((ref) {
  return CreateCabinUseCase(ref.read(cabinRepositoryProvider), ref.read(stationRepositoryProvider));
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

final startMobileDrawerSessionUseCaseProvider = Provider((ref) {
  return StartMobileDrawerSessionUseCase(cabinOperationService: ref.read(cabinOperationServiceProvider));
});

final startMasterDrawerSessionUseCaseProvider = Provider((ref) {
  return StartMasterDrawerSessionUseCase(ref.read(cabinOperationServiceProvider));
});

final testRfidConnectionUseCaseProvider = Provider((ref) {
  return TestRfidConnectionUseCase(ref.read(rfidServiceProvider));
});

final testCabinConnectionUseCaseProvider = Provider((ref) {
  return TestCabinConnectionUseCase(ref.read(serialServiceProvider));
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
  return GetCabinAssignmentsUseCase(ref.read(cabinAssignmentRepositoryProvider));
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
  return GetMasterDisposableMaterialsUseCase(ref.read(wasteRepositoryProvider));
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

final getFilteredHospitalizationsUseCaseProvider = Provider((ref) {
  return GetFilteredHospitalizationsUseCase(ref.read(hospitalizationRepositoryProvider));
});

final createUrgentPatientUseCaseProvider = Provider((ref) {
  return CreateUrgentPatientUseCase(ref.read(patientRepositoryProvider));
});

final getMedicinesUseCaseProvider = Provider((ref) {
  return GetMedicinesUseCase(ref.read(medicineRepositoryProvider));
});

final getCabinExpectedEpcsUseCaseProvider = Provider((ref) {
  return GetCabinExpectedEpcsUseCase(ref.read(cabinStockRepositoryProvider));
});
