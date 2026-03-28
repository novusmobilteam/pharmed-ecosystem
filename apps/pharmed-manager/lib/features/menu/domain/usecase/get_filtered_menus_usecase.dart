import '../../../../core/core.dart';
import '../../menu.dart';

class FilteredMenus {
  final List<MenuItem> tree; // Ağaç yapısı (Sidebar için)
  final List<MenuItem> flattened; // Düz liste

  FilteredMenus({required this.tree, required this.flattened});
}

class GetFilteredMenusUseCase {
  final IMenuRepository _menuRepository;

  GetFilteredMenusUseCase(
    this._menuRepository,
  );

  Future<Result<FilteredMenus>> call({
    int? userId,
    bool isFiltered = true,
  }) async {
    final result = await _menuRepository.getMenus(userId: userId);

    return result.when(
      ok: (flatMenus) {
        // Herhangi bir filtreleme yapmadan doğrudan tüm listeyi alıyoruz
        final List<MenuItem> allItems = List.from(flatMenus);

        final tree = _buildTree(allItems);

        return Result.ok(FilteredMenus(tree: tree, flattened: allItems));
      },
      error: (f) => Result.error(f),
    );
  }

  List<MenuItem> _buildTree(List<MenuItem> allItems) {
    // 1. Tüm elemanları ID'ye göre Map'e diz (Hızlı erişim için)
    // children listesini her seferinde temizleyerek yeni bir referans oluşturuyoruz
    final Map<int, MenuItem> nodes = {for (var item in allItems) item.id!: item.copyWith(children: [])};

    final List<MenuItem> rootNodes = [];

    // 2. Tek bir döngüde hiyerarşiyi kur
    for (var item in allItems) {
      final currentNode = nodes[item.id];

      if (item.parentId != null && nodes.containsKey(item.parentId)) {
        // Eğer bir parentId varsa ve bu parent Map içinde mevcutsa ona ekle
        nodes[item.parentId]!.children.add(currentNode!);
      } else {
        // parentId yoksa veya parent listede bulunamadıysa bu bir kök elemandır
        rootNodes.add(currentNode!);
      }
    }

    // 3. Görsel düzen için sıralama (Opsiyonel ama önerilir)
    rootNodes.sort((a, b) => (a.orderNo ?? 0).compareTo(b.orderNo ?? 0));

    for (var node in nodes.values) {
      if (node.children.isNotEmpty) {
        node.children.sort((a, b) => (a.orderNo ?? 0).compareTo(b.orderNo ?? 0));
      }
    }

    return rootNodes;
  }
}
