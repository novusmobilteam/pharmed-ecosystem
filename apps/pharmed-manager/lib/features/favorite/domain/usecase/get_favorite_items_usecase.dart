import '../../../../core/core.dart';
import '../../../menu/menu.dart';
import '../repository/i_favorite_repository.dart';

class GetFavoriteItemsUseCase {
  final IFavoriteRepository _favoriteRepository;

  GetFavoriteItemsUseCase(this._favoriteRepository);

  Future<Result<List<MenuItem>>> call(List<MenuItem> menuTree) async {
    final favResult = await _favoriteRepository.getFavorites();

    return favResult.when(
      ok: (favorites) {
        final favoriteIds = favorites.map((f) => f.menuId).toSet();
        final flattenedMenus = _flattenMenuTree(menuTree);
        final favoriteMenus = flattenedMenus.where((menu) => favoriteIds.contains(menu.id)).toList();
        return Result.ok(favoriteMenus);
      },
      error: (e) => Result.error(e),
    );
  }

  List<MenuItem> _flattenMenuTree(List<MenuItem> items) {
    List<MenuItem> result = [];
    for (var item in items) {
      result.add(item);
      if (item.children.isNotEmpty) {
        result.addAll(_flattenMenuTree(item.children));
      }
    }
    return result;
  }
}
