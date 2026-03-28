import '../../../../core/core.dart';
import '../../favorite.dart';
import '../model/favorite_menu_dto.dart';

class FavoriteRemoteDataSource extends BaseRemoteDataSource implements FavoriteDataSource {
  FavoriteRemoteDataSource({required super.apiManager});

  final String _basePath = '/FavoriteMenu';

  @override
  Future<Result<List<FavoriteMenuDTO>>> getFavorites() async {
    final result = await fetchRequest(
      path: _basePath,
      parser: listParser(FavoriteMenuDTO.fromJson),
    );

    return result.when(
      ok: (data) => Result.ok(data ?? const <FavoriteMenuDTO>[]),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> updateFavorites(List<FavoriteMenuDTO> menus) async {
    return await createRequest(
      path: '$_basePath/bulk',
      parser: voidParser(),
      body: menus.map((menu) => menu.toJson()).toList(),
    );
  }
}
