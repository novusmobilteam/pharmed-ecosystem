import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../../../core/core.dart';

class MedicineProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // // 1. Data Source
      // Provider<MedicineDataSource>(
      //   create: (context) {
      //     if (isDev) {
      //       return MedicineLocalDataSource(assetPath: 'assets/mocks/medicine.json');
      //     } else {
      //       return MedicineRemoteDataSource(apiManager: context.read<APIManager>());
      //     }
      //   },
      // ),

      // // 2. Repository
      // Provider<IMedicineRepository>(
      //   create: (context) => MedicineRepository(context.read<MedicineDataSource>()),
      // ),

      // 3. Use Cases
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
