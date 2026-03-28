import '../../../../core/core.dart';
import '../../domain/entity/favorite_menu.dart';
import '../../favorite.dart';

class FavoriteRepository implements IFavoriteRepository {
  final FavoriteDataSource _dataSource;

  FavoriteRepository(this._dataSource);

  @override
  Future<Result<List<FavoriteMenu>>> getFavorites() async {
    final result = await _dataSource.getFavorites();
    return result.when(
      ok: (list) {
        final entities = list.map((d) => d.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<void>> updateFavorites(List<FavoriteMenu> menus) async {
    final dtos = menus.map((m) => m.toDTO()).toList();
    return await _dataSource.updateFavorites(dtos);
  }
}
