import '../../../../../core/core.dart';
import '../model/active_ingredient_dto.dart';

/// Etken Madde (Active Ingredient) işlemleri için veri kaynağı arayüzü.
abstract class ActiveIngredientDataSource {
  /// Etken maddeleri sayfalı bir şekilde listeler.
  ///
  /// [skip]: Atlanacak kayıt sayısı (Pagination).
  /// [take]: Alınacak kayıt sayısı (Pagination).
  /// [search]: İsim bazlı arama metni.
  Future<Result<ApiResponse<List<ActiveIngredientDTO>>>> getActiveIngredients({
    int? skip,
    int? take,
    String? search,
  });

  /// Yeni bir etken madde oluşturur.
  Future<Result<void>> createActiveIngredient(ActiveIngredientDTO ingredient);

  /// Mevcut bir etken maddeyi günceller.
  Future<Result<void>> updateActiveIngredient(ActiveIngredientDTO ingredient);

  /// ID'si verilen etken maddeyi siler.
  Future<Result<void>> deleteActiveIngredient(int id);
}
