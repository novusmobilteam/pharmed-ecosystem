import '../../../../core/core.dart';
import '../model/menu_dto.dart';
import 'menu_data_source.dart';

class MenuRemoteDataSource extends BaseRemoteDataSource implements MenuDataSource {
  MenuRemoteDataSource({required super.apiManager});

  @override
  Future<Result<List<MenuDTO>?>> getMenus({int? userId}) async {
    final path = userId == null ? '/Menu' : '/Menu/user/$userId';

    return await fetchRequest<List<MenuDTO>>(
      path: path,
      parser: listParser(MenuDTO.fromJson),
    );
  }
}
