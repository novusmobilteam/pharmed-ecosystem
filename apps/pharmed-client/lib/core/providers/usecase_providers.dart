import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../cabin_operation/cabin_operation.dart';
import '../cache/app_settings_cache.dart';
import 'providers.dart';

final getHospitalizationsUseCaseProvider = Provider<GetHospitalizationsUseCase>((ref) {
  return GetHospitalizationsUseCase(ref.read(hospitalizationRepositoryProvider));
});

final getDrugsUseCaseProvider = Provider<GetDrugsUseCase>((ref) {
  return GetDrugsUseCase(ref.read(medicineRepositoryProvider));
});

// GetStationUseCase
final getStationUseCaseProvider = Provider<GetStationUseCase>((ref) {
  return GetStationUseCase(ref.read(stationRepositoryProvider));
});

final getServiceUseCaseProvider = Provider<GetServiceUseCase>((ref) {
  return GetServiceUseCase(ref.read(serviceRepositoryProvider));
});

final _getAllServicesUseCaseProvider = Provider<GetAllServicesUseCase>((ref) {
  return GetAllServicesUseCase(ref.read(serviceRepositoryProvider));
});

final _getAllRoomsUseCaseProvider = Provider<GetAllRoomsUseCase>((ref) {
  return GetAllRoomsUseCase(ref.read(serviceRepositoryProvider));
});

final _getAllBedsUseCaseProvider = Provider<GetAllBedsUseCase>((ref) {
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
final getCriticalStocksUseCaseProvider = Provider<GetCriticalStocksUseCase>((ref) {
  return GetCriticalStocksUseCase(ref.read(dashboardRepositoryProvider));
});

// GetExpiringMaterialsUseCase
final getExpiringMaterialsUseCaseProvider = Provider<GetExpiringMaterialsUseCase>((ref) {
  return GetExpiringMaterialsUseCase(ref.read(dashboardRepositoryProvider));
});

// GetUpcomingTreatmensUseCase
final getUpcomingTreatmensUseCaseProvider = Provider<GetUpcomingTreatmensUseCase>((ref) {
  return GetUpcomingTreatmensUseCase(ref.read(dashboardRepositoryProvider));
});

final getFilteredMenusUseCaseProvider = Provider<GetFilteredMenusUseCase>((ref) {
  return GetFilteredMenusUseCase(ref.read(dashboardRepositoryProvider), isManager: false);
});

final createBedAssignmentUseCaseProvider = Provider<CreateBedAssignmentUseCase>((ref) {
  return CreateBedAssignmentUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final createAssignmentUseCaseProvider = Provider<CreateMedicineAssignmentUseCase>((ref) {
  return CreateMedicineAssignmentUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final deleteBedAssignmentUseCaseProvider = Provider<DeleteBedAssignmentUseCase>((ref) {
  return DeleteBedAssignmentUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final deleteAssignmentUseCaseProvider = Provider<DeleteMedicineAssignmentUseCase>((ref) {
  return DeleteMedicineAssignmentUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final getBedAssignmentsUseCaseProvider = Provider<GetBedAssignmentsUseCase>((ref) {
  return GetBedAssignmentsUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final getMedicineAssignmentsUseCaseProvider = Provider<GetMedicineAssignmentsUseCase>((ref) {
  return GetMedicineAssignmentsUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final updateBedAssignmentUseCaseProvider = Provider<UpdateBedAssignmentUseCase>((ref) {
  return UpdateBedAssignmentUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final updateMedicineAssignmentUseCaseProvider = Provider<UpdateMedicineAssignmentUseCase>((ref) {
  return UpdateMedicineAssignmentUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final getCabinUseCaseProvider = Provider<GetCabinUseCase>((ref) {
  return GetCabinUseCase(ref.read(cabinRepositoryProvider));
});

final clearMasterCabinFaultRecordProvider = Provider<ClearMasterCabinFaultRecordUseCase>((ref) {
  return ClearMasterCabinFaultRecordUseCase(ref.read(faultRepositoryProvider));
});

final clearMobileCabinFaultRecordProvider = Provider<ClearMobileCabinFaultRecordUseCase>((ref) {
  return ClearMobileCabinFaultRecordUseCase(ref.read(faultRepositoryProvider));
});

final createMasterCabinFaultRecordProvider = Provider<CreateMasterCabinFaultRecordUseCase>((ref) {
  return CreateMasterCabinFaultRecordUseCase(ref.read(faultRepositoryProvider));
});

final createMobileCabinFaultRecordProvider = Provider<CreateMobileCabinFaultRecordUseCase>((ref) {
  return CreateMobileCabinFaultRecordUseCase(ref.read(faultRepositoryProvider));
});

final getMasterCabinFaultRecordsProvider = Provider<GetMasterCabinFaultRecordsUseCase>((ref) {
  return GetMasterCabinFaultRecordsUseCase(ref.read(faultRepositoryProvider));
});

final getMobileCabinFaultRecordsProvider = Provider<GetMobileCabinFaultRecordsUseCase>((ref) {
  return GetMobileCabinFaultRecordsUseCase(ref.read(faultRepositoryProvider));
});

final getCabinVisualizerDataUseCaseProvider = Provider<GetCabinVisualizerDataUseCase>((ref) {
  return GetCabinVisualizerDataUseCase(
    ref.read(cabinRepositoryProvider),
    ref.read(appSettingsCacheProvider),
    ref.read(getMasterCabinFaultRecordsProvider),
    ref.read(getMobileCabinFaultRecordsProvider),
    ref.read(getCabinStocksUseCaseProvider),
  );
});

final createCabinUseCaseProvider = Provider<CreateCabinUseCase>((ref) {
  return CreateCabinUseCase(ref.read(cabinRepositoryProvider), ref.read(stationRepositoryProvider));
});

final saveCabinDesignUseCaseProvider = Provider<SaveCabinDesignUseCase>((ref) {
  return SaveCabinDesignUseCase(
    cabinRepository: ref.read(cabinRepositoryProvider),
    localDataSource: ref.read(cabinLocaleDataSourceProvider),
  );
});

final saveMobileCabinDesignUseCaseProvider = Provider<SaveMobileCabinDesignUseCase>((ref) {
  return SaveMobileCabinDesignUseCase(
    cabinRepository: ref.read(cabinRepositoryProvider),
    localDataSource: ref.read(cabinLocaleDataSourceProvider),
  );
});

final finishCabinSetupUseCaseProvider = Provider<FinishCabinSetupUseCase>((ref) {
  return FinishCabinSetupUseCase(
    createCabin: ref.read(createCabinUseCaseProvider),
    saveCabinDesign: ref.read(saveCabinDesignUseCaseProvider),
    appSettingsCache: ref.read(appSettingsCacheProvider),
    saveMobileCabinDesign: ref.read(saveMobileCabinDesignUseCaseProvider),
  );
});

final scanCabinUseCaseProvider = Provider<ScanCabinUseCase>((ref) {
  return ScanCabinUseCase(
    cabinRepository: ref.read(cabinRepositoryProvider),
    cabinOperationService: ref.read(cabinOperationServiceProvider),
    serialService: ref.read(serialServiceProvider),
  );
});

final getUnassignedStationsUseCaseProvider = Provider<GetUnassignedStationsUseCase>((ref) {
  return GetUnassignedStationsUseCase(ref.read(stationRepositoryProvider));
});

final startMobileDrawerSessionUseCaseProvider = Provider<StartMobileDrawerSessionUseCase>((ref) {
  return StartMobileDrawerSessionUseCase(cabinOperationService: ref.read(cabinOperationServiceProvider));
});

final startMasterDrawerSessionUseCaseProvider = Provider<StartMasterDrawerSessionUseCase>((ref) {
  return StartMasterDrawerSessionUseCase(ref.read(cabinOperationServiceProvider));
});

final testRfidConnectionUseCaseProvider = Provider<TestRfidConnectionUseCase>((ref) {
  return TestRfidConnectionUseCase(ref.read(rfidServiceProvider));
});

final testCabinConnectionUseCaseProvider = Provider<TestCabinConnectionUseCase>((ref) {
  return TestCabinConnectionUseCase(ref.read(serialServiceProvider));
});

final getPatientPrescriptionHistoryUseCaseProvider = Provider<GetPatientPrescriptionHistoryUseCase>((ref) {
  return GetPatientPrescriptionHistoryUseCase(ref.read(prescriptionRepositoryProvider));
});

final refillMobileCabinUseCaseProvider = Provider<RefillMobileCabinUseCase>((ref) {
  return RefillMobileCabinUseCase(ref.read(cabinStockRepositoryProvider));
});

final getCabinAssignmentsUseCaseProvider = Provider<GetCabinAssignmentsUseCase>((ref) {
  return GetCabinAssignmentsUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final getCabinStocksUseCaseProvider = Provider<GetCabinStockUseCase>((ref) {
  return GetCabinStockUseCase(ref.read(cabinStockRepositoryProvider));
});

final refillMasterCabinUsecaseProvider = Provider<RefillMasterCabinUseCase>((ref) {
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
