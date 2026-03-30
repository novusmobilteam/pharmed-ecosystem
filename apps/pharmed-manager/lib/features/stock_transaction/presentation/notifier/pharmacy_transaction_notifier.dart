import 'package:flutter/material.dart';

import '../../../../../core/core.dart';

import '../../domain/entity/stock_transaction.dart';
import '../../domain/usecase/delete_stock_transaction_usecase.dart';
import '../../domain/usecase/get_stock_transactions_usecase.dart';
import '../../domain/entity/stock_transaction_mapper.dart';

class PharmacyTransactionNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<StockTransaction> {
  final GetStockTransactionsUseCase _getStockTransactionsUseCase;
  final DeleteStockTransactionUseCase _deleteStockTransactionUseCase;

  PharmacyTransactionNotifier({
    required GetStockTransactionsUseCase getStockTransactionsUseCase,
    required DeleteStockTransactionUseCase deleteStockTransactionUseCase,
  }) : _getStockTransactionsUseCase = getStockTransactionsUseCase,
       _deleteStockTransactionUseCase = deleteStockTransactionUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  static const deleteOp = OperationKey.delete();

  List<Warehouse> _warehouses = [];
  List<Warehouse> get warehouses => _warehouses;

  Warehouse? _selectedWarehouse;
  Warehouse? get selectedWarehouse => _selectedWarehouse;

  StockTransactionType _transactionType = StockTransactionType.entry;
  StockTransactionType get transactionType => _transactionType;

  int _selectedTab = 0;
  int get selectedTab => _selectedTab;

  int get activeIndex => !_warehouses.contains(_selectedWarehouse) ? 0 : _warehouses.indexOf(_selectedWarehouse!);

  bool get isFetching => isLoading(fetchOp);

  List<StockTransaction> get filteredTransactions {
    var items = filteredItems.where((refund) => refund.warehouse?.id == _selectedWarehouse?.id).toList();
    return items.where((transaction) {
      final typeMatch = transaction.transactionType == _transactionType;

      return typeMatch;
    }).toList();
  }

  // Functions
  Future<void> getTranscations() async {
    await execute(
      fetchOp,
      operation: () => _getStockTransactionsUseCase.call(),
      onData: (data) {
        allItems = data;
        _warehouses = data.toUniqueWarehouses;
        notifyListeners();
      },
    );
  }

  Future<void> deleteTransaction(StockTransaction transaction) async {
    final int id = transaction.id ?? 0;
    await executeVoid(
      deleteOp,
      operation: () => _deleteStockTransactionUseCase.call(id),
      onSuccess: () => getTranscations(),
    );
  }

  void selectTab(int index) {
    _selectedTab = index;
    _transactionType = StockTransactionType.values.elementAt(index);
    notifyListeners();
  }

  void selectWarehouse(Warehouse data) {
    _selectedWarehouse = data;
    notifyListeners();
  }
}
