import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/flavor/app_flavor.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

import '../../features/cabin/cabin.dart';
import '../../features/setup_wizard/domain/usecase/finish_cabin_setup_usecase.dart';
import '../cache/app_settings_cache.dart';
import 'providers.dart';

final cabinRemoteDataSourceProvider = Provider<CabinRemoteDataSource>((ref) {
  return CabinRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final cabinLocaleDataSourceProvider = Provider<ICabinLocalDataSource>((ref) {
  return CabinLocalDataSource();
});

final cabinRepositoryProvider = Provider<ICabinRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => CabinMockRepository(),
    AppFlavor.dev || AppFlavor.prod => CabinRepositoryImpl(
      cabinMapper: CabinMapper(),
      drawerSlotMapper: DrawerSlotMapper(),
      drawerConfigMapper: DrawerConfigMapper(),
      drawerUnitMapper: DrawerUnitMapper(),
      drawerTypeMapper: DrawerTypeMapper(),
      remoteDataSource: ref.read(cabinRemoteDataSourceProvider),
      localDataSource: ref.read(cabinLocaleDataSourceProvider),
    ),
  };
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

// SaveMobileCabinDesingUseCase
final saveMobileCabinDesignUseCaseProvider = Provider<SaveMobileCabinDesignUseCase>((ref) {
  return SaveMobileCabinDesignUseCase(
    cabinRepository: ref.read(cabinRepositoryProvider),
    localDataSource: ref.read(cabinLocaleDataSourceProvider),
  );
});

//FinishCabinSetupUseCase
final finishCabinSetupUseCaseProvider = Provider<FinishCabinSetupUseCase>((ref) {
  return FinishCabinSetupUseCase(
    createCabin: ref.read(createCabinUseCaseProvider),
    saveCabinDesign: ref.read(saveCabinDesignUseCaseProvider),
    appSettingsCache: ref.read(appSettingsCacheProvider),
    saveMobileCabinDesign: ref.read(saveMobileCabinDesignUseCaseProvider),
  );
});

// GetCabinsUseCase
final getCabinsUseCaseProvider = Provider<GetCabinsUseCase>((ref) {
  return GetCabinsUseCase(ref.read(cabinRepositoryProvider));
});
