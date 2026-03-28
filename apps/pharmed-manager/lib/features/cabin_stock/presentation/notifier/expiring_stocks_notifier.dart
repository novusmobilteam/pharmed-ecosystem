import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../domain/entity/cabin_stock.dart';
import '../../domain/usecase/get_expiring_stocks_usecase.dart';

class ExpiringStocksNotifier extends ChangeNotifier with SearchMixin<CabinStock>, ApiRequestMixin {
  final GetExpiringStocksUseCase _expiringStocksUsecase;

  ExpiringStocksNotifier({required GetExpiringStocksUseCase expiringStocksUsecase})
    : _expiringStocksUsecase = expiringStocksUsecase;

  // Operation Keys
  static const fetch = OperationKey.fetch();

  // Getters
  bool get isFetching => isLoading(fetch);

  // Functions
  Future<void> getExpiringStocks() async {
    await execute(fetch, operation: () => _expiringStocksUsecase.call(), onData: (data) => allItems = data);
  }
}
