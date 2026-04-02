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
        final processed = _processMenus(treeMenus);
        return RepoSuccess(processed);
      },
      stale: (treeMenus, savedAt) {
        final processed = _processMenus(treeMenus);
        return RepoStale(processed, savedAt);
      },
      failure: (error) => RepoFailure(error),
    );
  }

  FilteredMenus _processMenus(List<MenuItem> treeMenus) {
    // 1. Dashboard öğesini oluştur
    final dashboardItem = MenuItem(id: -1, name: 'Anasayfa', route: 'dashboard', children: []);

    // 2. Orijinal listeyi bozmamak için kopyala ve Dashboard'u başa ekle
    final updatedTree = [dashboardItem, ...treeMenus];

    // 3. Yeni ağaç üzerinden düz listeyi (Flatten) oluştur
    final flattened = _flattenTree(updatedTree);

    return FilteredMenus(tree: updatedTree, flattened: flattened);
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
