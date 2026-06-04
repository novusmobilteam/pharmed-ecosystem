import 'package:pharmed_core/pharmed_core.dart';

class GetAllMenusUseCase {
  final IDashboardRepository _dashboardRepository;

  GetAllMenusUseCase(this._dashboardRepository);

  Future<Result<FilteredMenus>> call() async {
    final result = await _dashboardRepository.getMenuItems();
    return result.when(
      ok: (value) => Result.ok(FilteredMenus(tree: value, flattened: _flattenTree(value))),
      error: Result.error,
    );
  }

  List<MenuItem> _flattenTree(List<MenuItem> items) {
    final List<MenuItem> flatList = [];

    for (var item in items) {
      // Önce elemanı ekle
      flatList.add(item);

      // Eğer çocukları varsa onları da rekürsif olarak ekle
      if (item.children.isNotEmpty) {
        flatList.addAll(_flattenTree(item.children));
      }
    }

    return flatList;
  }
}
