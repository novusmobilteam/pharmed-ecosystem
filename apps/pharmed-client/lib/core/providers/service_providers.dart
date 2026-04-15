import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

import '../flavor/app_flavor.dart';
import 'providers.dart';

final serviceRemoteDataSourceProvider = Provider<ServiceRemoteDataSource>((ref) {
  return ServiceRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final serviceRepositoryProvider = Provider<IServiceRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => ServiceRepositoryImpl(
      dataSource: ref.read(serviceRemoteDataSourceProvider),
      mapper: ServiceMapper(),
      roomMapper: RoomMapper(),
      bedMapper: BedMapper(),
    ),
    AppFlavor.dev || AppFlavor.prod => ServiceRepositoryImpl(
      dataSource: ref.read(serviceRemoteDataSourceProvider),
      mapper: ServiceMapper(),
      roomMapper: RoomMapper(),
      bedMapper: BedMapper(),
    ),
  };
});

final getServiceUseCaseProvider = Provider<GetServiceUseCase>((ref) {
  return GetServiceUseCase(ref.read(serviceRepositoryProvider));
});
