import '../../../../core/core.dart';
import '../entity/favorite_menu.dart';

abstract class IFavoriteRepository {
  Future<Result<List<FavoriteMenu>>> getFavorites();
  Future<Result<void>> updateFavorites(List<FavoriteMenu> menus);
}
