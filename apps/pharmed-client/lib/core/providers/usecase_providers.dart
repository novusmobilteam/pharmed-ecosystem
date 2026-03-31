import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../features/setup_wizard/domain/usecase/finish_cabin_setup_usecase.dart';
import 'providers.dart';
import '../../features/cabin/cabin.dart';

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
  return SaveCabinDesignUseCase(cabinRepository: ref.read(cabinRepositoryProvider));
});

// FinishCabinSetupUseCase
final finishCabinSetupUseCaseProvider = Provider<FinishCabinSetupUseCase>((ref) {
  return FinishCabinSetupUseCase(
    createCabinUseCase: ref.read(createCabinUseCaseProvider),
    saveCabinDesignUseCase: ref.read(saveCabinDesignUseCaseProvider),
  );
});
