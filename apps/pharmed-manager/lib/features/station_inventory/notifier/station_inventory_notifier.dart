import 'package:flutter/material.dart';

import 'package:pharmed_manager/core/core.dart';

import '../../cabin_stock/domain/entity/cabin_stock.dart';
import '../../cabin_stock/domain/usecase/get_current_cabin_stock_usecase.dart';

class StationInventoryNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetCurrentCabinStockUseCase _getCurrentCabinStockUseCase;

  StationInventoryNotifier({required GetCurrentCabinStockUseCase getCurrentCabinStockUseCase})
    : _getCurrentCabinStockUseCase = getCurrentCabinStockUseCase;

  OperationKey fetchOp = OperationKey.fetch();

  // Data
  List<CabinStock> _inventory = [];

  // Getters
  List<CabinStock> get inventory => _inventory;

  bool get isEmpty => _inventory.isEmpty;

  Future<void> fetchInventory() async {
    await execute(fetchOp, operation: () => _getCurrentCabinStockUseCase.call(), onData: (data) => _inventory = data);
  }
}
