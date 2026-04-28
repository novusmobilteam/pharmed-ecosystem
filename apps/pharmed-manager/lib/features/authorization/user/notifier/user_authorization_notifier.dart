import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class UserAuthorizationNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetUserMenuAuthorizationUseCase _getAuthUseCase;
  final SaveUserMenuAuthorizationUseCase _saveAuthUseCase;
  final GetFilteredMenusUseCase _getMenusUseCase;
  final User _user;

  UserAuthorizationNotifier({
    required GetUserMenuAuthorizationUseCase getAuthUseCase,
    required SaveUserMenuAuthorizationUseCase saveAuthUseCase,
    required GetFilteredMenusUseCase getMenusUseCase,
    required User user,
  }) : _getAuthUseCase = getAuthUseCase,
       _saveAuthUseCase = saveAuthUseCase,
       _getMenusUseCase = getMenusUseCase,
       _user = user;

  OperationKey fetchKey = OperationKey.fetch();
  OperationKey submitKey = OperationKey.update();

  List<MenuItem> _menuTree = [];
  List<MenuItem> get menuTree => _menuTree;

  UserMenuAuthorization? _userAuth;
  UserMenuAuthorization? get userAuth => _userAuth;

  bool get hasChanges => _userAuth?.isDirty ?? false;
  User get user => _user;

  bool get isFetching => isLoading(fetchKey);
  bool get isUpdating => isLoading(submitKey);

  String? get statusMessage => message(submitKey);

  List<MenuItem> get selectedItems {
    if (_userAuth == null || _menuTree.isEmpty) return [];
    return _findSelectedItemsInTree(_menuTree, _userAuth!.menuIdsPending);
  }

  /// Verileri Yükle (Initialize)
  Future<void> initialize() async {
    await executeVoid(
      fetchKey,
      operation: () async {
        final menuRes = await _getMenusUseCase.call();
        final authRes = await _getAuthUseCase.call(_user);

        if (menuRes case RepoFailure(error: final e)) return Result.error(e);
        if (authRes case Error(error: final e)) return Result.error(e);

        final menus = menuRes.dataOrNull;
        if (menus != null) _menuTree = menus.tree;

        if (authRes case Ok(value: final auth)) {
          _userAuth = auth;
        }

        return const Result.ok(null);
      },
    );
  }

  /// Menü yetkisini toggle et
  void toggleMenuPermission(int menuId) {
    if (_userAuth == null) return;
    _userAuth = _userAuth!.toggle(menuId);
    notifyListeners();
  }

  /// Kategoriye ait tüm menüleri seç/kaldır
  void toggleCategorySelection(MenuItem category) {
    if (_userAuth == null) return;

    final categoryMenuIds = _getAllMenuIdsFromCategory(category);
    final currentIds = _userAuth!.menuIdsPending;

    final bool shouldSelectAll = !categoryMenuIds.every(currentIds.contains);

    final newIds = shouldSelectAll
        ? {...currentIds, ...categoryMenuIds}
        : currentIds.where((id) => !categoryMenuIds.contains(id)).toSet();

    _userAuth = _userAuth!.withPending(newIds);
    notifyListeners();
  }

  /// Değişiklikleri kaydet
  Future<void> submit({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    if (_userAuth == null || !_userAuth!.isDirty) return;

    await execute(
      submitKey,
      operation: () => _saveAuthUseCase.call(_userAuth!),
      onData: (_) {
        _userAuth = _userAuth!.commit();
        notifyListeners();
        onSuccess?.call('İşleminiz başarıyla tamamlandı');
      },
    );
  }

  /// Değişiklikleri iptal et
  void cancelChanges() {
    _userAuth = _userAuth?.reset();
    notifyListeners();
  }

  // Yardımcı Metodlar
  bool isMenuSelected(int menuId) => _userAuth?.menuIdsPending.contains(menuId) ?? false;

  /// Kategorideki tüm menülerin seçili olup olmadığını kontrol et
  bool isCategoryFullySelected(MenuItem category) {
    if (_userAuth == null) return false;

    final categoryMenuIds = _getAllMenuIdsFromCategory(category);
    return categoryMenuIds.every(_userAuth!.menuIdsPending.contains);
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
      // Eğer bu düğümün ID'si seçiliyse listeye ekle
      if (node.id != null && selectedIds.contains(node.id)) {
        result.add(node);
      }
      // Çocuklarını da tara
      if (node.children.isNotEmpty) {
        result.addAll(_findSelectedItemsInTree(node.children, selectedIds));
      }
    }
    return result;
  }
}
