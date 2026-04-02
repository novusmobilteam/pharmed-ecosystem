import 'package:flutter/material.dart';

import '../../../../../core/core.dart';

import '../../../domain/entity/user_menu_authentication.dart';
import '../../../domain/usecase/get_user_menu_authentication_usecase.dart';
import '../../../domain/usecase/save_user_menu_authentication_usecase.dart';

class UserAuthenticationNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetUserMenuAuthenticationUseCase _getAuthUseCase;
  final SaveUserMenuAuthenticationUseCase _saveAuthUseCase;
  final GetFilteredMenusUseCase _getMenusUseCase;
  final User _user;

  UserAuthenticationNotifier({
    required GetUserMenuAuthenticationUseCase getAuthUseCase,
    required SaveUserMenuAuthenticationUseCase saveAuthUseCase,
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

  UserMenuAuthentication? _userAuth;
  UserMenuAuthentication? get userAuth => _userAuth;

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
        final results = await Future.wait([_getMenusUseCase.call(), _getAuthUseCase.call(_user)]);

        final menuRes = results[0] as Result<FilteredMenus>;
        final authRes = results[1] as Result<UserMenuAuthentication>;

        if (menuRes case Error(error: final e)) return Result.error(e);
        if (authRes case Error(error: final e)) return Result.error(e);

        if (menuRes case Ok(value: final menus)) {
          _menuTree = menus.tree;
        }

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
  Future<void> saveChanges() async {
    if (_userAuth == null || !_userAuth!.isDirty) return;

    await execute(
      submitKey,
      operation: () => _saveAuthUseCase.call(_userAuth!),
      onData: (_) {
        _userAuth = _userAuth!.commit();
        notifyListeners();
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
