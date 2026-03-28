import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../../../core/core.dart';
import '../../data/datasource/medicine_datasource.dart';
import '../../data/datasource/medicine_local_datasource.dart';
import '../../data/datasource/medicine_remote_datasource.dart';
import '../../data/repository/medicine_repository.dart';
import '../repository/i_medicine_repository.dart';
import '../usecase/create_medicine_usecase.dart';
import '../usecase/delete_medicine_usecase.dart';
import '../usecase/get_drug_usecase.dart';
import '../usecase/get_drugs_usecase.dart';
import '../usecase/get_medical_consumables_usecase.dart';
import '../usecase/get_medicines_usecase.dart';
import '../usecase/update_medicine_usecase.dart';

class MedicineProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<MedicineDataSource>(
        create: (context) {
          if (isDev) {
            return MedicineLocalDataSource(assetPath: 'assets/mocks/medicine.json');
          } else {
            return MedicineRemoteDataSource(apiManager: context.read<APIManager>());
          }
        },
      ),

      // 2. Repository
      Provider<IMedicineRepository>(
        create: (context) => MedicineRepository(context.read<MedicineDataSource>()),
      ),

      // 3. Use Cases
      Provider<CreateMedicineUseCase>(
        create: (context) => CreateMedicineUseCase(context.read()),
      ),
      Provider<DeleteMedicineUseCase>(
        create: (context) => DeleteMedicineUseCase(context.read()),
      ),
      Provider<GetDrugsUseCase>(
        create: (context) => GetDrugsUseCase(context.read()),
      ),
      Provider<GetMedicalConsumablesUseCase>(
        create: (context) => GetMedicalConsumablesUseCase(context.read()),
      ),
      Provider<GetMedicinesUseCase>(
        create: (context) => GetMedicinesUseCase(context.read()),
      ),
      Provider<UpdateMedicineUseCase>(
        create: (context) => UpdateMedicineUseCase(context.read()),
      ),
      Provider<GetDrugUseCase>(
        create: (context) => GetDrugUseCase(context.read()),
      ),
    ];
  }
}
