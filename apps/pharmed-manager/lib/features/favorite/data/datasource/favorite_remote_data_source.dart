import '../../../../core/core.dart';
import '../../favorite.dart';
import '../model/favorite_menu_dto.dart';

class FavoriteRemoteDataSource extends BaseRemoteDataSource implements FavoriteDataSource {
  FavoriteRemoteDataSource({required super.apiManager});

  final String _basePath = '/FavoriteMenu';

  @override
  // TODO: implement logSwreq
  String get logSwreq => throw UnimplementedError();

  @override
  // TODO: implement logUnit
  String get logUnit => throw UnimplementedError();

  @override
  Future<Result<List<FavoriteMenuDTO>>> getFavorites() async {
    final result = await fetchRequest(
      path: _basePath,
      parser: BaseRemoteDataSource.listParser(FavoriteMenuDTO.fromJson),
    );

    return result.when(ok: (data) => Result.ok(data ?? const <FavoriteMenuDTO>[]), error: Result.error);
  }

  @override
  Future<Result<void>> updateFavorites(List<FavoriteMenuDTO> menus) async {
    return await createRequest(
      path: '$_basePath/bulk',
      parser: BaseRemoteDataSource.voidParser(),
      body: menus.map((menu) => menu.toJson()).toList(),
    );
  }
}
