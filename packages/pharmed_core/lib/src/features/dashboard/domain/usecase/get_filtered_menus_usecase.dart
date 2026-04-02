import 'package:pharmed_core/pharmed_core.dart';

class FilteredMenus {
  final List<MenuItem> tree; // Sidebar hiyerarşisi (Ağaç yapısı)
  final List<MenuItem> flattened; // Arama ve düz listeleme için (Düz liste)

  FilteredMenus({required this.tree, required this.flattened});
}

class GetFilteredMenusUseCase {
  final IDashboardRepository _dashboardRepository;

  GetFilteredMenusUseCase(this._dashboardRepository);

  Future<RepoResult<FilteredMenus>> call({int? userId, bool forceRefresh = false}) async {
    final result = await _dashboardRepository.getMenuItems(userId: userId);

    return result.when(
      success: (treeMenus) {
        // 1. Veri başarıyla geldi (Tree yapısı Repo'dan geliyor)
        final tree = List<MenuItem>.from(treeMenus);
        final flattened = _flattenTree(tree);

        return RepoSuccess(FilteredMenus(tree: tree, flattened: flattened));
      },
      stale: (treeMenus, savedAt) {
        // 2. Veri cache'den geldi (Stale)
        final tree = List<MenuItem>.from(treeMenus);
        final flattened = _flattenTree(tree);

        return RepoStale(FilteredMenus(tree: tree, flattened: flattened), savedAt);
      },
      failure: (error) {
        // 3. Hata durumu
        return RepoFailure(error);
      },
    );
  }

  /// Ağaç yapısını (Tree) rekürsif olarak düz bir listeye (Flatten) dönüştürür.
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
