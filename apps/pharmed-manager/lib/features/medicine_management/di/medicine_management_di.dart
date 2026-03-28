import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../medicine_disposal/domain/usecase/dispose_material_usecase.dart';
import '../../medicine_disposal/domain/usecase/dispose_medicine_usecase.dart';
import '../../medicine_disposal/domain/usecase/get_disposable_materials_usecase.dart';
import '../../medicine_disposal/domain/usecase/get_disposables_usecase.dart';

import '../data/datasource/medicine_management_datasource.dart';
import '../data/datasource/medicine_management_remote_datasource.dart';
import '../data/repository/medicine_management_repository.dart';
import '../domain/repository/i_medicine_management_repository.dart';

class MedicineManagementProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<MedicineManagementDataSource>(
        create: (context) {
          return MedicineManagementRemoteDataSource(apiManager: context.read());
        },
      ),

      // 2. Repository
      Provider<IMedicineManagementRepository>(
        create: (context) => MedicineManagementRepository(context.read()),
      ),

      // 3. Use Cases
      Provider<DisposeMedicineUseCase>(
        create: (context) => DisposeMedicineUseCase(context.read()),
      ),
      Provider<GetDisposablesUseCase>(
        create: (context) => GetDisposablesUseCase(
          context.read(),
          context.read(),
        ),
      ),
      Provider<GetDisposableMaterialsUseCase>(
        create: (context) => GetDisposableMaterialsUseCase(context.read()),
      ),
      Provider<DisposeMaterialUseCase>(
        create: (context) => DisposeMaterialUseCase(context.read()),
      ),
    ];
  }
}
