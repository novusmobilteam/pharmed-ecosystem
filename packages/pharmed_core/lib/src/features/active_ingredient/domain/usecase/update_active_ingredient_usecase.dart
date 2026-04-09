import 'package:pharmed_core/pharmed_core.dart';

class UpdateActiveIngredientUseCase {
  final IActiveIngredientRepository _repository;

  UpdateActiveIngredientUseCase(this._repository);

  Future<Result<void>> call(ActiveIngredient ingredient) {
    return _repository.updateActiveIngredient(ingredient);
  }
}
