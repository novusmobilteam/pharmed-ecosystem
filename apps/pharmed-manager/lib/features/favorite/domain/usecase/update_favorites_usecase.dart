import '../../../../core/core.dart';

import '../../../menu/menu.dart';

import '../entity/favorite_menu.dart';
import '../repository/i_favorite_repository.dart';

class UpdateFavoritesUseCase implements UseCase<void, List<MenuItem>> {
  final IFavoriteRepository _repository;

  UpdateFavoritesUseCase(this._repository);

  @override
  Future<Result<void>> call(List<MenuItem> menus) async {
    final dtos = menus.map((m) => FavoriteMenu(menuId: m.id)).toList();
    return await _repository.updateFavorites(dtos);
  }
}
