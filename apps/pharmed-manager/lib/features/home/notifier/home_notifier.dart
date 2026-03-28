import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:pharmed_manager/core/core.dart';
import '../../../core/storage/auth/auth.dart';
import '../../menu/domain/usecase/get_filtered_menus_usecase.dart';
import '../../menu/menu.dart';

class HomeNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetFilteredMenusUseCase _getFilteredMenusUseCase;
  final AuthStorageNotifier _authStorageNotifier;

  HomeNotifier({
    required GetFilteredMenusUseCase getFilteredMenusUseCase,
    required AuthStorageNotifier authStorageNotifier,
  }) : _getFilteredMenusUseCase = getFilteredMenusUseCase,
       _authStorageNotifier = authStorageNotifier;

  OperationKey fetchOp = OperationKey.fetch();

  List<MenuItem> _menuTree = [];
  List<MenuItem> get menuItems => _menuTree;

  List<MenuItem> _flattenedMenus = [];
  List<MenuItem> get allMenuItemsFlattened => _flattenedMenus;

  int _activeTab = 0;
  int get activeTab => _activeTab;

  bool get isFetching => isLoading(fetchOp);
  bool get isEmpty => _menuTree.isEmpty;

  String? get statusMessage => message(fetchOp);

  /// Sidebar için parentlar
  List<MenuItem> get parentMenuItems =>
      _menuTree.where((menu) => menu.parentId == null && menu.label != 'Diğer').toList();

  List<MenuItem> getChildMenuItems(int parentIndex) {
    final parents = parentMenuItems;
    if (parentIndex >= parents.length) return [];
    return parents[parentIndex].children;
  }

  /// Seçili tabın çocukları (Grid için)
  List<MenuItem> get activeTabMenuItems {
    final parents = parentMenuItems;
    if (parents.isEmpty || _activeTab >= parents.length) return [];
    return parents[_activeTab].children;
  }

  Future<void> fetchMenus() async {
    await execute(
      fetchOp,
      operation: () => _getFilteredMenusUseCase.call(userId: _authStorageNotifier.user?.id),
      onData: (data) {
        _activeTab = 0;
        _menuTree = data.tree.sorted((a, b) => (b.orderNo ?? 0).compareTo(a.orderNo ?? 0)).toList();
        _flattenedMenus = data.flattened;
        notifyListeners();
      },
    );
  }

  void changeTab(int index) {
    if (_activeTab == index) return;
    _activeTab = index;
    notifyListeners();
  }

  void goToDashboard() {
    _activeTab = -1;
    notifyListeners();
  }
}
