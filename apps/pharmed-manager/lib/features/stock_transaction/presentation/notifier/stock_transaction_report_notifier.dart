import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../domain/entity/stock_transaction.dart';
import '../../domain/usecase/get_cabin_stock_transactions_usecase.dart';

class StockTransactionReportNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetCabinStockTransactionsUseCase _getCabinStockTransactionsUseCase;

  OperationKey fetchStationsOp = OperationKey.fetch();
  OperationKey fetchTransactionsOp = OperationKey.fetch();

  StockTransactionReportNotifier({required GetCabinStockTransactionsUseCase getCabinStockTransactionsUseCase})
    : _getCabinStockTransactionsUseCase = getCabinStockTransactionsUseCase;

  Station? _selectedStation;
  Station? get selectedStation => _selectedStation;

  List<StockTransaction> _transactions = [];
  List<StockTransaction> get transactions => _transactions;

  bool get isFetching => isLoading(fetchTransactionsOp);

  void getTransactions() async {
    if (_selectedStation == null) return;

    await execute(
      fetchTransactionsOp,
      operation: () => _getCabinStockTransactionsUseCase.call(_selectedStation!.id!),
      onData: (transactions) {
        _transactions = transactions;
        notifyListeners();
      },
    );
  }

  void selectStation(Station station) {
    _selectedStation = station;
    getTransactions();
    notifyListeners();
  }
}
