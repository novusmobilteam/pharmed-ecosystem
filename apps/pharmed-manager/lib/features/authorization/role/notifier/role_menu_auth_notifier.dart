import 'package:flutter/material.dart';

import '../../../../core/core.dart';

class RoleMenuAuthNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetRoleMenuAuthorizationUseCase _getAuthUseCase;
  final SaveRoleMenuAuthorizationUseCase _saveAuthUseCase;
  final GetFilteredMenusUseCase _getMenusUseCase;
  final Role _role;

  RoleMenuAuthNotifier({
    required GetRoleMenuAuthorizationUseCase getAuthUseCase,
    required SaveRoleMenuAuthorizationUseCase saveAuthUseCase,
    required GetFilteredMenusUseCase getMenusUseCase,
    required Role role,
  }) : _getAuthUseCase = getAuthUseCase,
       _saveAuthUseCase = saveAuthUseCase,
       _getMenusUseCase = getMenusUseCase,
       _role = role;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey submitOp = OperationKey.update();

  List<MenuItem> _menuTree = [];
  List<MenuItem> get menuTree => _menuTree;

  RoleMenuAuthorization? _roleAuth;
  RoleMenuAuthorization? get roleAuth => _roleAuth;

  bool get hasChanges => _roleAuth?.isDirty ?? false;
  Role get role => _role;

  bool get isFetching => isLoading(fetchOp);
  bool get isSubmitting => isLoading(submitOp);

  List<MenuItem> get selectedItems {
    if (_roleAuth == null || _menuTree.isEmpty) return [];
    return _findSelectedItemsInTree(_menuTree, _roleAuth!.menuIdsPending);
  }

  /// Verileri Yükle (Initialize)
  Future<void> initialize() async {
    await executeVoid(
      fetchOp,
      operation: () async {
        final menuRes = await _getMenusUseCase.call();
        final authRes = await _getAuthUseCase.call(_role);

        if (menuRes case RepoFailure(error: final e)) return Result.error(e);
        if (authRes case Error(error: final e)) return Result.error(e);

        final menus = menuRes.dataOrNull;
        if (menus != null) _menuTree = menus.tree;

        if (authRes case Ok(value: final auth)) {
          _roleAuth = auth;
        }

        return const Result.ok(null);
      },
    );
  }

  /// Menü yetkisini toggle et
  void toggleMenuPermission(int menuId) {
    if (_roleAuth == null) return;
    _roleAuth = _roleAuth!.toggle(menuId);
    notifyListeners();
  }

  /// Kategoriye ait tüm menüleri seç/kaldır
  void toggleCategorySelection(MenuItem category) {
    if (_roleAuth == null) return;

    final categoryMenuIds = _getAllMenuIdsFromCategory(category);
    final currentIds = _roleAuth!.menuIdsPending;

    final bool shouldSelectAll = !categoryMenuIds.every(currentIds.contains);

    final newIds = shouldSelectAll
        ? {...currentIds, ...categoryMenuIds}
        : currentIds.where((id) => !categoryMenuIds.contains(id)).toSet();

    _roleAuth = _roleAuth!.withPending(newIds);
    notifyListeners();
  }

  /// Değişiklikleri kaydet
  Future<void> submit({Function(String? msg)? onSuccess, Function(String? msg)? onFailed}) async {
    if (_roleAuth == null || !_roleAuth!.isDirty) return;

    await execute(
      submitOp,
      operation: () => _saveAuthUseCase.call(_roleAuth!),
      onData: (_) {
        _roleAuth = _roleAuth!.commit();
        notifyListeners();
        onSuccess?.call('İşleminiz başarıyla tamamlandı');
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }

  /// Değişiklikleri iptal et
  void cancelChanges() {
    _roleAuth = _roleAuth?.reset();
    notifyListeners();
  }

  // Helpers
  bool isMenuSelected(int menuId) => _roleAuth?.menuIdsPending.contains(menuId) ?? false;

  /// Kategorideki tüm menülerin seçili olup olmadığını kontrol et
  bool isCategoryFullySelected(MenuItem category) {
    if (_roleAuth == null) return false;

    final categoryMenuIds = _getAllMenuIdsFromCategory(category);
    return categoryMenuIds.every(_roleAuth!.menuIdsPending.contains);
  }

  /// Kategorideki en az bir menünün seçili olup olmadığını kontrol et
  bool isCategoryPartiallySelected(MenuItem category) {
    final ids = _getAllMenuIdsFromCategory(category);

    final hasAny = ids.any(isMenuSelected);
    final hasAll = ids.every(isMenuSelected);

    return hasAny && !hasAll;
  }

  /// Kategorideki tüm menü ID'lerini getir
  Set<int> _getAllMenuIdsFromCategory(MenuItem category) {
    final ids = <int>{};
    if (category.id != null) ids.add(category.id!);
    for (final child in category.children) {
      ids.addAll(_getAllMenuIdsFromCategory(child));
    }
    return ids;
  }

  List<MenuItem> _findSelectedItemsInTree(List<MenuItem> nodes, Set<int> selectedIds) {
    final result = <MenuItem>[];
    for (final node in nodes) {
      if (node.id != null && selectedIds.contains(node.id)) {
        result.add(node);
      }
      if (node.children.isNotEmpty) {
        result.addAll(_findSelectedItemsInTree(node.children, selectedIds));
      }
    }
    return result;
  }
}
