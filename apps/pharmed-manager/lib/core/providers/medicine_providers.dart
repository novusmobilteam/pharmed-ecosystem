import 'package:pharmed_manager/core/core.dart';
import 'package:pharmed_manager/core/flavor/app_flavor.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class MedicineProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider(create: (context) => MedicineRemoteDataSource(apiManager: context.read())),

      Provider<MedicineMapper>(create: (_) => const MedicineMapper()),
      Provider<DrugMapper>(create: (_) => const DrugMapper()),
      Provider<MedicalConsumableMapper>(create: (_) => const MedicalConsumableMapper()),

      Provider<IMedicineRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => MedicineRepositoryImpl(
            dataSource: context.read(),
            mapper: context.read(),
            drugMapper: context.read(),
            mcMapper: context.read(),
          ),
          AppFlavor.dev || AppFlavor.prod => MedicineRepositoryImpl(
            dataSource: context.read(),
            mapper: context.read(),
            drugMapper: context.read(),
            mcMapper: context.read(),
          ),
        },
      ),
      Provider<CreateMedicineUseCase>(create: (context) => CreateMedicineUseCase(context.read())),
      Provider<DeleteMedicineUseCase>(create: (context) => DeleteMedicineUseCase(context.read())),
      Provider<GetDrugsUseCase>(create: (context) => GetDrugsUseCase(context.read())),
      Provider<GetMedicalConsumablesUseCase>(create: (context) => GetMedicalConsumablesUseCase(context.read())),
      Provider<GetMedicinesUseCase>(create: (context) => GetMedicinesUseCase(context.read())),
      Provider<UpdateMedicineUseCase>(create: (context) => UpdateMedicineUseCase(context.read())),
      Provider<GetDrugUseCase>(create: (context) => GetDrugUseCase(context.read())),
    ];
  }
}
