import '../../../../core/core.dart';
import '../../domain/entity/menu_item.dart';
import '../../domain/repository/i_menu_repository.dart';
import '../../utils/menu_tree_mapper.dart';
import '../datasource/menu_data_source.dart';

class MenuRepository implements IMenuRepository {
  final MenuDataSource _ds;
  final MenuTreeMapper _mapper;

  MenuRepository({required MenuDataSource dataSource, required MenuTreeMapper mapper})
      : _ds = dataSource,
        _mapper = mapper;

  @override
  Future<Result<List<MenuItem>>> getMenus({int? userId}) async {
    final res = await _ds.getMenus(userId: userId);
    return res.when(
      ok: (data) {
        final flatList = _mapper.mapDtosToFlatList(data ?? []);

        return Result.ok(flatList);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }
}
