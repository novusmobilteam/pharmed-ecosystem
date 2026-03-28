import '../../../../core/core.dart';
import '../model/active_ingredient_dto.dart';
import 'active_ingredient_datasource.dart';

/// Etken Madde işlemleri için uzak (API) veri kaynağı.
class ActiveIngredientRemoteDataSource extends BaseRemoteDataSource implements ActiveIngredientDataSource {
  // Endpoint sabitleri
  final String _basePath = '/ActiveIngredient';

  ActiveIngredientRemoteDataSource({required super.apiManager});

  @override
  Future<Result<ApiResponse<List<ActiveIngredientDTO>>>> getActiveIngredients({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await fetchRequest<ApiResponse<List<ActiveIngredientDTO>>>(
      path: _basePath,
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'name',
      envelope: ResponseEnvelope.raw,
      parser: apiResponseListParser(ActiveIngredientDTO.fromJson),
      successLog: 'Active ingredients fetched successfully',
      emptyLog: 'No active ingredients found',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const ApiResponse(data: [], totalCount: 0)),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> createActiveIngredient(ActiveIngredientDTO ingredient) {
    return createRequest(
      path: _basePath,
      body: ingredient.toJson(),
      parser: voidParser(),
      successLog: 'Active ingredient created successfully',
    );
  }

  @override
  Future<Result<void>> updateActiveIngredient(ActiveIngredientDTO ingredient) {
    final id = ingredient.id;

    return updateRequest(
      path: '$_basePath/$id',
      body: ingredient.toJson(),
      parser: voidParser(),
      successLog: 'Active ingredient updated successfully',
    );
  }

  @override
  Future<Result<void>> deleteActiveIngredient(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: voidParser(),
      successLog: 'Active ingredient deleted successfully',
    );
  }
}
