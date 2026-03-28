import '../../../../core/core.dart';
import '../model/menu_dto.dart';
import 'menu_data_source.dart';

class MenuLocalDataSource extends BaseLocalDataSource<MenuDTO, int> implements MenuDataSource {
  MenuLocalDataSource({required String assetPath})
      : super(
          filePath: assetPath,
          fromJson: MenuDTO.fromJson,
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (value, id) => MenuDTO(id: id),
        );

  @override
  Future<Result<List<MenuDTO>>> getMenus({int? userId}) async {
    final res = await fetchRequest();
    return res.when(ok: (r) => Result.ok(r.data ?? []), error: Result.error);
  }
}
