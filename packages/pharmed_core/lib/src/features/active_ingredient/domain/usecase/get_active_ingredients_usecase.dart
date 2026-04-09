import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetActiveIngredientsParams {
  final int? skip;
  final int? take;
  final String? search;

  GetActiveIngredientsParams({this.skip, this.take, this.search});
}

class GetActiveIngredientsUseCase {
  final IActiveIngredientRepository _repository;

  GetActiveIngredientsUseCase(this._repository);

  Future<Result<ApiResponse<List<ActiveIngredient>>>> call(GetActiveIngredientsParams params) async {
    return _repository.getActiveIngredients(skip: params.skip, take: params.take, search: params.search);
  }
}
