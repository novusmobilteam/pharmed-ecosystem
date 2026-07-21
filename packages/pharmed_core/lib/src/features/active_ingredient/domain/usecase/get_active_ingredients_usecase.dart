import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetActiveIngredientsUseCase {
  final IActiveIngredientRepository _repository;

  GetActiveIngredientsUseCase(this._repository);

  Future<Result<ApiResponse<List<ActiveIngredient>>>> call(PagedQueryParams params) async {
    return _repository.getActiveIngredients(skip: params.skip, take: params.take, search: params.searchQuery);
  }
}
