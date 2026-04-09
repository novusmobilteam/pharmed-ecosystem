import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_manager/core/flavor/app_flavor.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class ActiveIngredientProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider(create: (context) => ActiveIngredientRemoteDataSource(apiManager: context.read())),

      Provider<ActiveIngredientMapper>(create: (_) => const ActiveIngredientMapper()),

      Provider<IActiveIngredientRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => ActiveIngredientRepositoryImpl(dataSource: context.read(), mapper: context.read()),
          AppFlavor.dev ||
          AppFlavor.prod => ActiveIngredientRepositoryImpl(dataSource: context.read(), mapper: context.read()),
        },
      ),

      Provider<GetActiveIngredientsUseCase>(create: (context) => GetActiveIngredientsUseCase(context.read())),
      Provider<CreateActiveIngredientUseCase>(create: (context) => CreateActiveIngredientUseCase(context.read())),
      Provider<UpdateActiveIngredientUseCase>(create: (context) => UpdateActiveIngredientUseCase(context.read())),
      Provider<DeleteActiveIngredientUseCase>(create: (context) => DeleteActiveIngredientUseCase(context.read())),
    ];
  }
}
