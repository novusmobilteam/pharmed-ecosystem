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

// ServiceRepository
final serviceRepositoryProvider = Provider<IServiceRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => ServiceRepositoryImpl(
      dataSource: ref.read(serviceRemoteDataSourceProvider),
      mapper: ServiceMapper(),
    ),
    AppFlavor.dev || AppFlavor.prod => ServiceRepositoryImpl(
      dataSource: ref.read(serviceRemoteDataSourceProvider),
      mapper: ServiceMapper(),
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

// CabinAssignmentRepository
final cabinAssignmentRepositoryProvider = Provider<ICabinAssignmentRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => CabinAssignmentRepository(
      dataSource: ref.read(cabinAssignmentRemoteDataSourceProvider),
      mapper: CabinAssignmentMapper(),
    ),
    AppFlavor.dev || AppFlavor.prod => CabinAssignmentRepository(
      dataSource: ref.read(cabinAssignmentRemoteDataSourceProvider),
      mapper: CabinAssignmentMapper(),
    ),
  };
});

// MedicineRepository
final medicineRepositoryProvider = Provider<IMedicineRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => MedicineRepositoryImpl(
      dataSource: ref.read(medicineRemoteDataSourceProvider),
      mapper: MedicineMapper(),
      drugMapper: DrugMapper(),
      mcMapper: MedicalConsumableMapper(),
    ),
    AppFlavor.dev || AppFlavor.prod => MedicineRepositoryImpl(
      dataSource: ref.read(medicineRemoteDataSourceProvider),
      mapper: MedicineMapper(),
      drugMapper: DrugMapper(),
      mcMapper: MedicalConsumableMapper(),
    ),
  };
});

// FaultRepository

final faultRepositoryProvider = Provider<IFaultRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => FaultRepositoryImpl(dataSource: ref.read(faultRemoteDataSourceProvider), mapper: FaultMapper()),
    AppFlavor.dev ||
    AppFlavor.prod => FaultRepositoryImpl(dataSource: ref.read(faultRemoteDataSourceProvider), mapper: FaultMapper()),
  };
});
