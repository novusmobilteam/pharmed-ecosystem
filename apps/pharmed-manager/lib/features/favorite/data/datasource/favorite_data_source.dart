import '../../../../core/core.dart';
import '../model/favorite_menu_dto.dart';

abstract class FavoriteDataSource {
  Future<Result<List<FavoriteMenuDTO>>> getFavorites();
  Future<Result<void>> updateFavorites(List<FavoriteMenuDTO> menus);
}
