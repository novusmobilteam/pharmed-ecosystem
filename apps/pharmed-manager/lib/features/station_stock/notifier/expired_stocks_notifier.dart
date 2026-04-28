import 'package:flutter/widgets.dart';
import 'package:pharmed_manager/core/core.dart';

class ExpiredStockNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<CabinStock> {
  final GetExpiredStocksUseCase _expiredStocksUseCase;

  ExpiredStockNotifier({required GetExpiredStocksUseCase expiredStocksUseCase})
    : _expiredStocksUseCase = expiredStocksUseCase;

  OperationKey fetchOp = OperationKey.fetch();

  bool get isFetching => isLoading(fetchOp);
  String? get statusMessage => message(fetchOp);

  void getExpiredStocks() async {
    await execute(
      fetchOp,
      operation: () => _expiredStocksUseCase.call(),
      onData: (data) {
        allItems = data;
        notifyListeners();
      },
    );
  }
}
