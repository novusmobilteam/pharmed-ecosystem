import 'package:pharmed_core/pharmed_core.dart';

class GetAllMenusUseCase {
  final IDashboardRepository _dashboardRepository;

  GetAllMenusUseCase(this._dashboardRepository);

  Future<RepoResult<FilteredMenus>> call() async {
    final result = await _dashboardRepository.getMenuItems();
    return result.when(
      success: (menus) => RepoSuccess(FilteredMenus(tree: menus, flattened: _flattenTree(menus))),
      stale: (menus, savedAt) => RepoStale(FilteredMenus(tree: menus, flattened: _flattenTree(menus)), savedAt),
      failure: (error) => RepoFailure(error),
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
