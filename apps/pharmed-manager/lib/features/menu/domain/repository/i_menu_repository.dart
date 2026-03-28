import '../../../../core/core.dart';
import '../entity/menu_item.dart';

abstract class IMenuRepository {
  Future<Result<List<MenuItem>>> getMenus({int? userId});
}
