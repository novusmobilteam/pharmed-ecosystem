import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

import '../flavor/app_flavor.dart';
import 'providers.dart';

final medicineRemoteDataSourceProvider = Provider<MedicineRemoteDataSource>((ref) {
  return MedicineRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

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

final getDrugsUseCaseProvider = Provider<GetDrugsUseCase>((ref) {
  return GetDrugsUseCase(ref.read(medicineRepositoryProvider));
});
