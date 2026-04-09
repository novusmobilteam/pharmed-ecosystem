import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_manager/core/flavor/app_flavor.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class MaterialTypeProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider(create: (context) => MaterialTypeRemoteDataSource(apiManager: context.read())),

      Provider<MaterialTypeMapper>(create: (_) => const MaterialTypeMapper()),

      Provider<IMaterialTypeRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => MaterialTypeRepositoryImpl(dataSource: context.read(), mapper: context.read()),
          AppFlavor.dev ||
          AppFlavor.prod => MaterialTypeRepositoryImpl(dataSource: context.read(), mapper: context.read()),
        },
      ),

      Provider<GetMaterialTypesUseCase>(create: (context) => GetMaterialTypesUseCase(context.read())),
      Provider<CreateMaterialTypeUseCase>(create: (context) => CreateMaterialTypeUseCase(context.read())),
      Provider<UpdateMaterialTypeUseCase>(create: (context) => UpdateMaterialTypeUseCase(context.read())),
      Provider<DeleteMaterialTypeUseCase>(create: (context) => DeleteMaterialTypeUseCase(context.read())),
    ];
  }
}
