import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

import '../flavor/app_flavor.dart';
import 'providers.dart';

final hospitalizationRemoteDataSourceProvider = Provider<HospitalizationRemoteDataSource>((ref) {
  return HospitalizationRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final hospitalizationRepositoryProvider = Provider<IHospitalizationRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => HospitalizationRepositoryImpl(
      mapper: HospitalizationMapper(),
      dataSource: ref.read(hospitalizationRemoteDataSourceProvider),
    ),
    AppFlavor.dev || AppFlavor.prod => HospitalizationRepositoryImpl(
      mapper: HospitalizationMapper(),
      dataSource: ref.read(hospitalizationRemoteDataSourceProvider),
    ),
  };
});

final getHospitalizationsUseCaseProvider = Provider<GetHospitalizationsUseCase>((ref) {
  return GetHospitalizationsUseCase(ref.read(hospitalizationRepositoryProvider));
});
