import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/flavor/app_flavor.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

import 'providers.dart';

final stationRemoteDataSourceProvider = Provider<StationRemoteDataSource>((ref) {
  return StationRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final stationRepositoryProvider = Provider<IStationRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => MockStationRepository(),
    AppFlavor.dev || AppFlavor.prod => StationRepositoryImpl(
      dataSource: ref.read(stationRemoteDataSourceProvider),
      mapper: StationMapper(),
    ),
  };
});

final getStationsUseCaseProvider = Provider<GetStationsUseCase>((ref) {
  return GetStationsUseCase(ref.read(stationRepositoryProvider));
});

// GetStationUseCase
final getStationUseCaseProvider = Provider<GetStationUseCase>((ref) {
  return GetStationUseCase(ref.read(stationRepositoryProvider));
});
