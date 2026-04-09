import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

abstract class IActiveIngredientRepository {
  Future<Result<ApiResponse<List<ActiveIngredient>>>> getActiveIngredients({int? skip, int? take, String? search});
  Future<Result<void>> createActiveIngredient(ActiveIngredient entity);
  Future<Result<void>> updateActiveIngredient(ActiveIngredient entity);
  Future<Result<void>> deleteActiveIngredient(ActiveIngredient entity);
}
