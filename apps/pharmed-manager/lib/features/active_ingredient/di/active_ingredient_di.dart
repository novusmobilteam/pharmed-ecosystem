import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/datasource/active_ingredient_datasource.dart';
import '../data/datasource/active_ingredient_local_datasource.dart';
import '../data/datasource/active_ingredient_remote_datasource.dart';
import '../data/repository/active_ingredient_repository.dart';
import '../domain/repository/i_active_ingredient_repository.dart';
import '../domain/usecase/create_active_ingredient_usecase.dart';
import '../domain/usecase/delete_active_ingredient_usecase.dart';
import '../domain/usecase/get_active_ingredients_usecase.dart';
import '../domain/usecase/update_active_ingredient_usecase.dart';

class ActiveIngredientProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<ActiveIngredientDataSource>(
        create: (context) {
          if (isDev) {
            return ActiveIngredientLocalDataSource(assetPath: 'assets/mocks/active_ingredient.json');
          } else {
            return ActiveIngredientRemoteDataSource(apiManager: context.read());
          }
        },
      ),
      // 2. Repository
      Provider<IActiveIngredientRepository>(
        create: (context) => ActiveIngredientRepository(
          context.read<ActiveIngredientDataSource>(),
        ),
      ),
      // 3. Use Cases
      Provider<GetActiveIngredientsUseCase>(
        create: (context) => GetActiveIngredientsUseCase(context.read()),
      ),
      Provider<CreateActiveIngredientUseCase>(
        create: (context) => CreateActiveIngredientUseCase(context.read()),
      ),
      Provider<UpdateActiveIngredientUseCase>(
        create: (context) => UpdateActiveIngredientUseCase(context.read()),
      ),
      Provider<DeleteActiveIngredientUseCase>(
        create: (context) => DeleteActiveIngredientUseCase(context.read()),
      ),
    ];
  }
}
