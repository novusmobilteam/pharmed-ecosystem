import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../../menu/menu.dart';
import '../../favorite.dart';

class FavoriteNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetFavoriteItemsUseCase _getFavoriteItemsUseCase;
  final UpdateFavoritesUseCase _updateFavoritesUseCase;

  FavoriteNotifier({
    required GetFavoriteItemsUseCase getFavoriteItemsUseCase,
    required UpdateFavoritesUseCase toggleFavoriteUseCase,
  }) : _getFavoriteItemsUseCase = getFavoriteItemsUseCase,
       _updateFavoritesUseCase = toggleFavoriteUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey submitOp = OperationKey.submit();

  List<MenuItem> _allMenuItems = [];

  List<MenuItem> _favoriteMenuItems = [];
  List<MenuItem> get favoriteMenuItems => _favoriteMenuItems;

  List<int> _favoriteIds = [];
  List<int> get favoriteIds => _favoriteIds;

  List<MenuItem> _pendingFavorites = [];
  List<MenuItem> get pendingFavorites => _pendingFavorites;

  List<MenuItem> get parents => _allMenuItems.where((m) => m.parentId == null).toList();

  int _activeParentIndex = 0;
  int get activeParentIndex => _activeParentIndex;

  bool get canAddMore => _pendingFavorites.length < 7;

  /// Menü favori mi kontrolü (Local state üzerinden senkron çalışır)
  bool isMenuFavorite(int menuId) => _favoriteIds.contains(menuId);

  /// Dashboard veya üst katmandan tüm menüleri alır ve favorileri yükler.
  Future<void> initialize(List<MenuItem> menuItems) async {
    _allMenuItems = menuItems;
    await getFavorites();
  }

  void initializePending() {
    _pendingFavorites = List.from(_favoriteMenuItems);
  }

  /// Favori verilerini (hem ID hem Entity olarak) UseCase'lerden günceller.
  Future<void> getFavorites() async {
    await execute(
      fetchOp,
      operation: () => _getFavoriteItemsUseCase(_allMenuItems),
      onData: (items) {
        _favoriteMenuItems = items;
        _favoriteIds = items.map((e) => e.id ?? 0).toList();

        notifyListeners();
      },
    );
  }

  void togglePending(MenuItem item, {Function(String? msg)? onFailed}) {
    final exists = _pendingFavorites.any((m) => m.id == item.id);
    if (exists) {
      _pendingFavorites = _pendingFavorites.where((m) => m.id != item.id).toList();
    } else {
      if (!canAddMore) {
        onFailed?.call('En fazla 7 favori menü ekleyebilirsiniz');
        return;
      }
      _pendingFavorites = [..._pendingFavorites, item];
    }
    notifyListeners();
  }

  bool isPendingFavorite(int menuId) => _pendingFavorites.any((m) => m.id == menuId);

  Future<void> saveFavorites({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    await executeVoid(
      submitOp,
      operation: () => _updateFavoritesUseCase.call(_pendingFavorites),
      onSuccess: () {
        onSuccess?.call('İşleminiz başarıyla tamamlandı');
        getFavorites();
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }

  void selectParent(MenuItem selectedItem) {
    final index = parents.indexOf(selectedItem);

    if (index != -1) {
      _activeParentIndex = index;
      notifyListeners();
    }
  }

  void clearPending() {
    _pendingFavorites = [];
    notifyListeners();
  }
}
