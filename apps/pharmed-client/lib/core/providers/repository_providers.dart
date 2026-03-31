import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/flavor/app_flavor.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

import 'datasource_providers.dart';

// StationRepository
final stationRepositoryProvider = Provider<IStationRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => MockStationRepository(),
    AppFlavor.dev || AppFlavor.prod => StationRepositoryImpl(
      dataSource: ref.read(stationRemoteDataSourceProvider),
      mapper: StationMapper(),
    ),
  };
});

// CabinRepository
final cabinRepositoryProvider = Provider<ICabinRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => MockCabinRepository(),
    AppFlavor.dev || AppFlavor.prod => CabinRepositoryImpl(
      dataSource: ref.read(cabinRemoteDataSourceProvider),
      cabinMapper: CabinMapper(),
      drawerSlotMapper: DrawerSlotMapper(),
      drawerConfigMapper: DrawerConfigMapper(),
      drawerUnitMapper: DrawerUnitMapper(),
      drawerTypeMapper: DrawerTypeMapper(),
    ),
  };
});
