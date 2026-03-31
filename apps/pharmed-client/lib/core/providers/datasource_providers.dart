import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_data/pharmed_data.dart';

import 'network_providers.dart';

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
