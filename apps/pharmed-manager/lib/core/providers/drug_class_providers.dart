import 'package:pharmed_manager/core/core.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../flavor/app_flavor.dart';

class DrugClassProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider(create: (context) => DrugClassRemoteDataSource(apiManager: context.read())),

      Provider<DrugClassMapper>(create: (_) => const DrugClassMapper()),

      Provider<IDrugClassRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => DrugClassRepositoryImpl(dataSource: context.read(), mapper: context.read()),
          AppFlavor.dev ||
          AppFlavor.prod => DrugClassRepositoryImpl(dataSource: context.read(), mapper: context.read()),
        },
      ),

      Provider<GetDrugClassUseCase>(create: (context) => GetDrugClassUseCase(context.read())),
      Provider<CreateDrugClassUseCase>(create: (context) => CreateDrugClassUseCase(context.read())),
      Provider<UpdateDrugClassUseCase>(create: (context) => UpdateDrugClassUseCase(context.read())),
      Provider<DeleteDrugClassUseCase>(create: (context) => DeleteDrugClassUseCase(context.read())),
    ];
  }
}
