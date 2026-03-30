import 'package:flutter/material.dart';

import 'package:pharmed_manager/core/core.dart';

class InventoryNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<CabinStock> {
  final GetCurrentCabinStockUseCase _getCurrentCabinStockUseCase;

  InventoryNotifier({required GetCurrentCabinStockUseCase getCurrentCabinStockUseCase})
    : _getCurrentCabinStockUseCase = getCurrentCabinStockUseCase;

  OperationKey fetchOp = OperationKey.fetch();

  bool get isFetching => isLoading(fetchOp);

  List<CabinStock> get inventory => filteredItems;

  // Functions
  Future<void> getInventory() async {
    await execute(fetchOp, operation: () => _getCurrentCabinStockUseCase.call(), onData: (data) => allItems = data);
  }
}
