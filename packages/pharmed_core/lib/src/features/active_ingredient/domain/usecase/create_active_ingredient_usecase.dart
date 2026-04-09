import 'package:pharmed_core/pharmed_core.dart';

class CreateActiveIngredientUseCase {
  final IActiveIngredientRepository _repository;

  CreateActiveIngredientUseCase(this._repository);

  Future<Result<void>> call(ActiveIngredient ingredient) {
    return _repository.createActiveIngredient(ingredient);
  }
}
