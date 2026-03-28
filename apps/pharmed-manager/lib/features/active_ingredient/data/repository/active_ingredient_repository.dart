import '../../../../core/core.dart';
import '../../domain/entity/active_ingredient.dart';
import '../../domain/repository/i_active_ingredient_repository.dart';
import '../datasource/active_ingredient_datasource.dart';

class ActiveIngredientRepository implements IActiveIngredientRepository {
  final ActiveIngredientDataSource _ds;

  ActiveIngredientRepository(this._ds);

  @override
  Future<Result<ApiResponse<List<ActiveIngredient>>>> getActiveIngredients({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await _ds.getActiveIngredients(
      skip: skip,
      take: take,
      search: search,
    );
    return res.when(
      ok: (response) {
        List<ActiveIngredient> entities = [];

        if (response.data != null) {
          entities = response.data!.map((e) => e.toEntity()).toList();
        }

        return Result.ok(ApiResponse<List<ActiveIngredient>>(
          data: entities,
          statusCode: response.statusCode,
          isSuccess: response.isSuccess,
          totalCount: response.totalCount,
          groupCount: response.groupCount,
        ));
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<void>> createActiveIngredient(ActiveIngredient entity) async {
    return await _ds.createActiveIngredient(entity.toDTO());
  }

  @override
  Future<Result<void>> updateActiveIngredient(ActiveIngredient entity) async {
    return await _ds.updateActiveIngredient(entity.toDTO());
  }

  @override
  Future<Result<void>> deleteActiveIngredient(ActiveIngredient entity) async {
    final id = entity.id;
    return await _ds.deleteActiveIngredient(id ?? 0);
  }
}
