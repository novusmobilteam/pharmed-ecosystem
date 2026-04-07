import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_data/pharmed_data.dart';

import 'network_providers.dart';

// DashboardDataSource
final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) {
  return DashboardRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

// StationDataSource
final stationRemoteDataSourceProvider = Provider<StationRemoteDataSource>((ref) {
  return StationRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

// CabinDataSource
final cabinRemoteDataSourceProvider = Provider<CabinRemoteDataSource>((ref) {
  return CabinRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final cabinLocaleDataSourceProvider = Provider<ICabinLocalDataSource>((ref) {
  return CabinLocalDataSource();
});

// CabinStockDataSource
final cabinStockRemoteDataSourceProvider = Provider<CabinStockRemoteDataSource>((ref) {
  return CabinStockRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final cabinStockLocalDataSourceProvider = Provider<CabinStockLocalDataSource>((ref) {
  return CabinStockLocalDataSource();
});

// CabinAssignmentDataSource
final cabinAssignmentRemoteDataSourceProvider = Provider<CabinAssignmentRemoteDataSource>((ref) {
  return CabinAssignmentRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

// final cabinAssignmentLocalDataSourceProvider = Provider<CabinStockLocalDataSource>((ref) {
//   return CabinStockLocalDataSource();
// });

// MedicineDataSource
final medicineRemoteDataSourceProvider = Provider<MedicineRemoteDataSource>((ref) {
  return MedicineRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

// FaultDataSource
final faultRemoteDataSourceProvider = Provider<FaultRemoteDataSource>((ref) {
  return FaultRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});
