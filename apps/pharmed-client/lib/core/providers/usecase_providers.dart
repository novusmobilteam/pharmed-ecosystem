import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/cache/app_settings_cache.dart';
import 'package:pharmed_client/features/dashboard/domain/usecase/cabin_visualizer_usecase.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../features/setup_wizard/domain/usecase/finish_cabin_setup_usecase.dart';
import 'providers.dart';
import '../../features/cabin/cabin.dart';

/// ----- Dashboard -----

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

// GetUpcomingTreatmensUseCase
final getCabinVisualizerDataUseCaseProvider = Provider<GetCabinVisualizerDataUseCase>((ref) {
  return GetCabinVisualizerDataUseCase(
    ref.read(cabinRepositoryProvider),
    ref.read(cabinStockRepositoryProvider),
    ref.read(appSettingsCacheProvider),
  );
});

/// ----- Dashboard -----

// GetStationsUseCase
final getStationsUseCaseProvider = Provider<GetStationsUseCase>((ref) {
  return GetStationsUseCase(ref.read(stationRepositoryProvider));
});

// GetStationUseCase
final getStationUseCaseProvider = Provider<GetStationUseCase>((ref) {
  return GetStationUseCase(ref.read(stationRepositoryProvider));
});

// GetServiceUseCase
final getServiceUseCaseProvider = Provider<GetServiceUseCase>((ref) {
  return GetServiceUseCase(ref.read(serviceRepositoryProvider));
});

/// ----- Cabin -----

// ScanCabinUseCase
final scanCabinUseCaseProvider = Provider<ScanCabinUseCase>((ref) {
  return ScanCabinUseCase(
    cabinRepository: ref.read(cabinRepositoryProvider),
    cabinOperationService: ref.read(cabinOperationServiceProvider),
    serialService: ref.read(serialServiceProvider),
  );
});

// CreateCabinUseCase
final createCabinUseCaseProvider = Provider<CreateCabinUseCase>((ref) {
  return CreateCabinUseCase(ref.read(cabinRepositoryProvider), ref.read(stationRepositoryProvider));
});

// SaveCabinDesingUseCase
final saveCabinDesignUseCaseProvider = Provider<SaveCabinDesignUseCase>((ref) {
  return SaveCabinDesignUseCase(
    cabinRepository: ref.read(cabinRepositoryProvider),
    localDataSource: ref.read(cabinLocaleDataSourceProvider),
  );
});

// SaveMobileCabinDesingUseCase
final saveMobileCabinDesignUseCaseProvider = Provider<SaveMobileCabinDesignUseCase>((ref) {
  return SaveMobileCabinDesignUseCase(
    cabinRepository: ref.read(cabinRepositoryProvider),
    localDataSource: ref.read(cabinLocaleDataSourceProvider),
  );
});

// FinishCabinSetupUseCase
final finishCabinSetupUseCaseProvider = Provider<FinishCabinSetupUseCase>((ref) {
  return FinishCabinSetupUseCase(
    createCabin: ref.read(createCabinUseCaseProvider),
    saveCabinDesign: ref.read(saveCabinDesignUseCaseProvider),
    appSettingsCache: ref.read(appSettingsCacheProvider),
    saveMobileCabinDesign: ref.read(saveMobileCabinDesignUseCaseProvider),
  );
});

// GetFilteredMenusUseCase
final getFilteredMenusUseCaseProvider = Provider<GetFilteredMenusUseCase>((ref) {
  return GetFilteredMenusUseCase(ref.read(dashboardRepositoryProvider), isManager: false);
});

/// ----- Cabin -----

/// ----- Assignment -----

final getAssignmentsUseCaseProvider = Provider<GetAssignmentsUseCase>((ref) {
  return GetAssignmentsUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final createAssignmentUseCaseProvider = Provider<CreateAssignmentUseCase>((ref) {
  return CreateAssignmentUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final updateAssignmentUseCaseProvider = Provider<UpdateAssignmentUseCase>((ref) {
  return UpdateAssignmentUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final deleteAssignmentUseCaseProvider = Provider<DeleteAssignmentUseCase>((ref) {
  return DeleteAssignmentUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

/// ----- Assignment -----

/// ----- Medicine -----

final getDrugsUseCaseProvider = Provider<GetDrugsUseCase>((ref) {
  return GetDrugsUseCase(ref.read(medicineRepositoryProvider));
});

/// ----- Medicine -----

/// ----- Fault -----
final getCabinFaultsUseCaseProvider = Provider<GetCabinFaultsUseCase>((ref) {
  return GetCabinFaultsUseCase(ref.read(faultRepositoryProvider));
});

final createFaultRecordUseCaseProvider = Provider<CreateFaultRecordUseCase>((ref) {
  return CreateFaultRecordUseCase(ref.read(faultRepositoryProvider));
});

final clearFaultRecordUseCaseProvider = Provider<ClearFaultRecordUseCase>((ref) {
  return ClearFaultRecordUseCase(ref.read(faultRepositoryProvider));
});

/// ----- Fault -----
