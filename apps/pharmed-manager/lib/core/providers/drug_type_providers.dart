import 'package:pharmed_manager/core/core.dart';
import 'package:pharmed_manager/core/flavor/app_flavor.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class DrugTypeProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider(create: (context) => DrugTypeRemoteDataSource(apiManager: context.read())),

      Provider<DrugTypeMapper>(create: (_) => const DrugTypeMapper()),

      Provider<IDrugTypeRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => DrugTypeRepositoryImpl(dataSource: context.read(), mapper: context.read()),
          AppFlavor.dev || AppFlavor.prod => DrugTypeRepositoryImpl(dataSource: context.read(), mapper: context.read()),
        },
      ),

      Provider<GetDrugTypesUseCase>(create: (context) => GetDrugTypesUseCase(context.read())),
      Provider<DeleteDrugTypeUseCase>(create: (context) => DeleteDrugTypeUseCase(context.read())),
      Provider<CreateDrugTypeUseCase>(create: (context) => CreateDrugTypeUseCase(context.read())),
      Provider<UpdateDrugTypeUseCase>(create: (context) => UpdateDrugTypeUseCase(context.read())),
    ];
  }
}
