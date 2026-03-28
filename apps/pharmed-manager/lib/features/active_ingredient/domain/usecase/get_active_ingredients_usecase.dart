import '../../../../core/core.dart';

import '../entity/active_ingredient.dart';
import '../repository/i_active_ingredient_repository.dart';

class GetActiveIngredientsParams {
  final int? skip;
  final int? take;
  final String? search;

  GetActiveIngredientsParams({this.skip, this.take, this.search});
}

class GetActiveIngredientsUseCase implements UseCase<ApiResponse<List<ActiveIngredient>>, GetActiveIngredientsParams> {
  final IActiveIngredientRepository _repository;

  GetActiveIngredientsUseCase(this._repository);

  @override
  Future<Result<ApiResponse<List<ActiveIngredient>>>> call(GetActiveIngredientsParams params) async {
    return _repository.getActiveIngredients(skip: params.skip, take: params.take, search: params.search);
  }
}
