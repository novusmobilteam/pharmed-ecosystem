import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/datasource/drug_type_datasource.dart';
import '../data/datasource/drug_type_local_datasource.dart';
import '../data/datasource/drug_type_remote_datasource.dart';
import '../data/repository/drug_type_repository.dart';
import '../domain/repository/i_drug_type_repository.dart';
import '../domain/usecase/create_drug_type_usecase.dart';
import '../domain/usecase/delete_drug_type_usecase.dart';
import '../domain/usecase/get_drug_types_usecase.dart';
import '../domain/usecase/update_drug_type_usecase.dart';

class DrugTypeProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<DrugTypeDataSource>(
        create: (context) {
          if (isDev) {
            return DrugTypeLocalDataSource(assetPath: 'assets/mocks/drug_type.json');
          } else {
            return DrugTypeRemoteDataSource(apiManager: context.read());
          }
        },
      ),
      // 2. Repository
      Provider<IDrugTypeRepository>(
        create: (context) => DrugTypeRepository(
          context.read<DrugTypeDataSource>(),
        ),
      ),
      // 3. Use Cases
      Provider<GetDrugTypesUseCase>(
        create: (context) => GetDrugTypesUseCase(context.read()),
      ),
      Provider<DeleteDrugTypeUseCase>(
        create: (context) => DeleteDrugTypeUseCase(context.read()),
      ),
      Provider<CreateDrugTypeUseCase>(
        create: (context) => CreateDrugTypeUseCase(context.read()),
      ),
      Provider<UpdateDrugTypeUseCase>(
        create: (context) => UpdateDrugTypeUseCase(context.read()),
      ),
    ];
  }
}
