import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:pharmed_manager/core/core.dart';

import '../../auth/presentation/notifier/auth_notifier.dart';

class HomeNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetFilteredMenusUseCase _getFilteredMenusUseCase;
  final AuthNotifier _authNotifier;

  HomeNotifier({required GetFilteredMenusUseCase getFilteredMenusUseCase, required AuthNotifier authNotifier})
    : _getFilteredMenusUseCase = getFilteredMenusUseCase,
      _authNotifier = authNotifier;

  OperationKey fetchOp = OperationKey.fetch();

  List<MenuItem> _menuTree = [];
  List<MenuItem> get menuItems => _menuTree;

  MenuItem? _activeChildMenu;
  MenuItem? get activeChildMenu => _activeChildMenu;

  List<MenuItem> _flattenedMenus = [];
  List<MenuItem> get allMenuItemsFlattened => _flattenedMenus;

  int _activeTab = 0;
  int get activeTab => _activeTab;

  bool get isFetching => isLoading(fetchOp);
  bool get isEmpty => _menuTree.isEmpty;

  String? get statusMessage => message(fetchOp);

  MenuItem? get activeMenu {
    final parents = parentMenuItems;
    if (parents.isEmpty || _activeTab < 0 || _activeTab >= parents.length) return null;
    return parents[_activeTab];
  }

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
    await executeRepo(
      fetchOp,
      operation: () => _getFilteredMenusUseCase.call(userId: _authNotifier.currentUser?.id),
      onData: (data) {
        _activeTab = 0;
        _menuTree = data.tree.sorted((a, b) => (b.orderNo ?? 0).compareTo(a.orderNo ?? 0)).toList();
        _flattenedMenus = data.flattened;
        notifyListeners();
      },
    );
  }

  void changeTab(MenuItem menu) {
    final index = parentMenuItems.indexOf(menu);
    if (index == -1 || _activeTab == index) return;
    _activeTab = index;
    _activeChildMenu = null; // parent değişince child sıfırlanır
    notifyListeners();
  }

  void selectChild(MenuItem child) {
    _activeChildMenu = child;
    print(child.slug);
    notifyListeners();
  }

  void goToDashboard() {
    _activeTab = -1;
    notifyListeners();
  }
}
