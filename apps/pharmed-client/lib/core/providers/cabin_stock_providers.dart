import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/flavor/app_flavor.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

import 'providers.dart';

final cabinStockRemoteDataSourceProvider = Provider<CabinStockRemoteDataSource>((ref) {
  return CabinStockRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final cabinStockLocalDataSourceProvider = Provider<CabinStockLocalDataSource>((ref) {
  return CabinStockLocalDataSource();
});

final cabinStockRepositoryProvider = Provider<ICabinStockRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => MockCabinStockRepository(),
    AppFlavor.dev || AppFlavor.prod => CabinStockRepository(
      dataSource: ref.read(cabinStockRemoteDataSourceProvider),
      localDataSource: ref.read(cabinStockLocalDataSourceProvider),
      cabinMapper: CabinStockMapper(),
      stationMapper: StationStockMapper(),
    ),
  };
});
