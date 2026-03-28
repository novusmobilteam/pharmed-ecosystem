import '../../../../core/core.dart';
import '../model/menu_dto.dart';

abstract class MenuDataSource {
  Future<Result<List<MenuDTO>?>> getMenus({int? userId});
}
