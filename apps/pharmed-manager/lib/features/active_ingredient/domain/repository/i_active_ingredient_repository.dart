import '../../../../core/core.dart';
import '../entity/active_ingredient.dart';

abstract class IActiveIngredientRepository {
  Future<Result<ApiResponse<List<ActiveIngredient>>>> getActiveIngredients({
    int? skip,
    int? take,
    String? search,
  });
  Future<Result<void>> createActiveIngredient(ActiveIngredient entity);
  Future<Result<void>> updateActiveIngredient(ActiveIngredient entity);
  Future<Result<void>> deleteActiveIngredient(ActiveIngredient entity);
}
