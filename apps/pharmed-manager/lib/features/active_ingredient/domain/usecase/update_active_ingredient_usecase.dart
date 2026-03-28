import '../../../../core/core.dart';

import '../entity/active_ingredient.dart';
import '../repository/i_active_ingredient_repository.dart';

class UpdateActiveIngredientUseCase extends UseCase<void, ActiveIngredient> {
  final IActiveIngredientRepository _repository;

  UpdateActiveIngredientUseCase(this._repository);

  @override
  Future<Result<void>> call(ActiveIngredient ingredient) {
    return _repository.updateActiveIngredient(ingredient);
  }
}
