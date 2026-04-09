import 'package:pharmed_core/pharmed_core.dart';

class DeleteActiveIngredientUseCase {
  final IActiveIngredientRepository _repository;

  DeleteActiveIngredientUseCase(this._repository);

  Future<Result<void>> call(ActiveIngredient ingredient) {
    return _repository.deleteActiveIngredient(ingredient);
  }
}
