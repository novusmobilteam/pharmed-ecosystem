import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/datasource/material_type_datasource.dart';
import '../data/datasource/material_type_local_datasource.dart';
import '../data/datasource/material_type_remote_datasource.dart';
import '../data/repository/material_type_repository.dart';
import '../domain/repository/i_material_type_repository.dart';
import '../domain/usecase/create_material_type_usecase.dart';
import '../domain/usecase/delete_material_type_usecase.dart';
import '../domain/usecase/get_material_types_usecase.dart';
import '../domain/usecase/update_material_type_usecase.dart';

class MaterialTypeProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<MaterialTypeDataSource>(
        create: (context) {
          if (isDev) {
            return MaterialTypeLocalDataSource(assetPath: 'assets/mocks/material_type.json');
          } else {
            return MaterialTypeRemoteDataSource(apiManager: context.read());
          }
        },
      ),
      // 2. Repository
      Provider<IMaterialTypeRepository>(
        create: (context) => MaterialTypeRepository(
          context.read<MaterialTypeDataSource>(),
        ),
      ),
      // 3. Use Cases
      Provider<GetMaterialTypesUseCase>(
        create: (context) => GetMaterialTypesUseCase(context.read()),
      ),
      Provider<CreateMaterialTypeUseCase>(
        create: (context) => CreateMaterialTypeUseCase(context.read()),
      ),
      Provider<UpdateMaterialTypeUseCase>(
        create: (context) => UpdateMaterialTypeUseCase(context.read()),
      ),
      Provider<DeleteMaterialTypeUseCase>(
        create: (context) => DeleteMaterialTypeUseCase(context.read()),
      ),
    ];
  }
}
