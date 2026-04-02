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

// FinishCabinSetupUseCase
final finishCabinSetupUseCaseProvider = Provider<FinishCabinSetupUseCase>((ref) {
  return FinishCabinSetupUseCase(
    createCabin: ref.read(createCabinUseCaseProvider),
    saveCabinDesign: ref.read(saveCabinDesignUseCaseProvider),
    appSettingsCache: ref.read(appSettingsCacheProvider),
  );
});

// GetFilteredMenusUseCase
final getFilteredMenusUseCaseProvider = Provider<GetFilteredMenusUseCase>((ref) {
  return GetFilteredMenusUseCase(ref.read(dashboardRepositoryProvider));
});
