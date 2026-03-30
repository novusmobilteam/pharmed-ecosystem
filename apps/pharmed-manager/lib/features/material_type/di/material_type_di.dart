import 'package:pharmed_core/pharmed_core.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class MaterialTypeProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // // 1. Data Source
      // Provider<MaterialTypeDataSource>(
      //   create: (context) {
      //     if (isDev) {
      //       return MaterialTypeLocalDataSource(assetPath: 'assets/mocks/material_type.json');
      //     } else {
      //       return MaterialTypeRemoteDataSource(apiManager: context.read());
      //     }
      //   },
      // ),
      // // 2. Repository
      // Provider<IMaterialTypeRepository>(
      //   create: (context) => MaterialTypeRepository(
      //     context.read<MaterialTypeDataSource>(),
      //   ),
      // ),
      // 3. Use Cases
      Provider<GetMaterialTypesUseCase>(create: (context) => GetMaterialTypesUseCase(context.read())),
      Provider<CreateMaterialTypeUseCase>(create: (context) => CreateMaterialTypeUseCase(context.read())),
      Provider<UpdateMaterialTypeUseCase>(create: (context) => UpdateMaterialTypeUseCase(context.read())),
      Provider<DeleteMaterialTypeUseCase>(create: (context) => DeleteMaterialTypeUseCase(context.read())),
    ];
  }
}
