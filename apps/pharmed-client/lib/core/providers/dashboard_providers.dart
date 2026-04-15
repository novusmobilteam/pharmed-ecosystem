import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/flavor/app_flavor.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

import '../../features/dashboard/domain/usecase/cabin_visualizer_usecase.dart';
import '../cache/app_settings_cache.dart';
import 'providers.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) {
  return DashboardRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

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

// GetCriticalStocksUseCase
final getCriticalStocksUseCaseProvider = Provider<GetCriticalStocksUseCase>((ref) {
  return GetCriticalStocksUseCase(ref.read(dashboardRepositoryProvider));
});

// GetExpiringMaterialsUseCase
final getExpiringMaterialsUseCaseProvider = Provider<GetExpiringMaterialsUseCase>((ref) {
  return GetExpiringMaterialsUseCase(ref.read(dashboardRepositoryProvider));
});

// GetUpcomingTreatmensUseCase
final getUpcomingTreatmensUseCaseProvider = Provider<GetUpcomingTreatmensUseCase>((ref) {
  return GetUpcomingTreatmensUseCase(ref.read(dashboardRepositoryProvider));
});

final getFilteredMenusUseCaseProvider = Provider<GetFilteredMenusUseCase>((ref) {
  return GetFilteredMenusUseCase(ref.read(dashboardRepositoryProvider), isManager: false);
});

// GetUpcomingTreatmensUseCase
final getCabinVisualizerDataUseCaseProvider = Provider<GetCabinVisualizerDataUseCase>((ref) {
  return GetCabinVisualizerDataUseCase(
    ref.read(cabinRepositoryProvider),
    ref.read(cabinStockRepositoryProvider),
    ref.read(appSettingsCacheProvider),
  );
});
