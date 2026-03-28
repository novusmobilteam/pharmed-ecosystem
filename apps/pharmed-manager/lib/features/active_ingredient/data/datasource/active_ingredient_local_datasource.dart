import '../../../../../core/core.dart';
import '../model/active_ingredient_dto.dart';
import 'active_ingredient_datasource.dart';

class ActiveIngredientLocalDataSource extends BaseLocalDataSource<ActiveIngredientDTO, int>
    implements ActiveIngredientDataSource {
  ActiveIngredientLocalDataSource({
    required String assetPath, // ör: 'assets/mock/active_ingredients.json'
  }) : super(
          filePath: assetPath,
          fromJson: (m) => ActiveIngredientDTO.fromJson(m),
          toJson: (dto) => dto.toJson(),
          getId: (dto) => dto.id ?? -1,
          assignId: (dto, id) => ActiveIngredientDTO(
            id: id,
            name: dto.name,
            isActive: dto.isActive,
          ),
        );

  @override
  Future<Result<ApiResponse<List<ActiveIngredientDTO>>>> getActiveIngredients({
    int? skip,
    int? take,
    String? search,
  }) {
    return fetchRequest(
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'name', // JSON içinde 'name' alanında arama yapar
    );
  }

  @override
  Future<Result<ActiveIngredientDTO?>> createActiveIngredient(ActiveIngredientDTO ingredient) {
    return createRequest(ingredient);
  }

  @override
  Future<Result<ActiveIngredientDTO?>> updateActiveIngredient(ActiveIngredientDTO ingredient) {
    return updateRequest(ingredient);
  }

  @override
  Future<Result<void>> deleteActiveIngredient(int id) {
    return deleteRequest(id);
  }
}
