import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/flavor/app_flavor.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

import 'datasource_providers.dart';

// DashboardRepository
final dashboardRepositoryProvider = Provider<IDashboardRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => MockDashboardRepository(),
    AppFlavor.dev || AppFlavor.prod => DashboardRepositoryImpl(
      dataSource: ref.read(dashboardRemoteDataSourceProvider),
      cabinStockMapper: CabinStockMapper(),
      prescriptionItemMapper: PrescriptionItemMapper(),
      prescriptionMapper: PrescriptionMapper(),
      refundMapper: RefundMapper(),
      menuMapper: MenuTreeMapper(),
    ),
  };
});

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

// StockRepository
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
