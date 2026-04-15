import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

import '../../../../core/flavor/app_flavor.dart';
import '../../../../core/providers/providers.dart';
import '../../fault.dart';

final faultRemoteDataSourceProvider = Provider<FaultRemoteDataSource>((ref) {
  return FaultRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final faultRepositoryProvider = Provider<IFaultRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => FaultRepositoryImpl(dataSource: ref.read(faultRemoteDataSourceProvider), mapper: FaultMapper()),
    AppFlavor.dev ||
    AppFlavor.prod => FaultRepositoryImpl(dataSource: ref.read(faultRemoteDataSourceProvider), mapper: FaultMapper()),
  };
});

final getCabinFaultsUseCaseProvider = Provider<GetCabinFaultsUseCase>((ref) {
  return GetCabinFaultsUseCase(ref.read(faultRepositoryProvider));
});

final createFaultRecordUseCaseProvider = Provider<CreateFaultRecordUseCase>((ref) {
  return CreateFaultRecordUseCase(ref.read(faultRepositoryProvider));
});

final clearFaultRecordUseCaseProvider = Provider<ClearFaultRecordUseCase>((ref) {
  return ClearFaultRecordUseCase(ref.read(faultRepositoryProvider));
});
