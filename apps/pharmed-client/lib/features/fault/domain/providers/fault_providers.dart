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
    AppFlavor.mock => FaultRepositoryImpl(
      dataSource: ref.read(faultRemoteDataSourceProvider),
      masterFaultMapper: MasterFaultMapper(),
      mobileFaultMapper: MobileFaultMapper(),
    ),
    AppFlavor.dev || AppFlavor.prod => FaultRepositoryImpl(
      dataSource: ref.read(faultRemoteDataSourceProvider),
      masterFaultMapper: MasterFaultMapper(),
      mobileFaultMapper: MobileFaultMapper(),
    ),
  };
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
