import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class StationTransactionReportNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<StockTransaction> {
  final GetStationsUseCase _getStationsUseCase;
  final GetCabinStockTransactionsUseCase _getCabinStockTransactionsUseCase;

  StationTransactionReportNotifier({
    required GetCabinStockTransactionsUseCase getCabinStockTransactionsUseCase,
    required GetStationsUseCase getStationsUseCase,
  }) : _getCabinStockTransactionsUseCase = getCabinStockTransactionsUseCase,
       _getStationsUseCase = getStationsUseCase;

  OperationKey fetchStationsOp = OperationKey.fetch();
  OperationKey fetchTransactionsOp = OperationKey.fetch();

  Station? _selectedStation;
  Station? get selectedStation => _selectedStation;

  List<Station> _stations = [];
  List<Station> get stations => _stations;

  List<StockTransaction> _transactions = [];
  List<StockTransaction> get transactions => _transactions;

  bool get isFetching => isLoading(fetchTransactionsOp);

  int get activeIndex => !stations.contains(_selectedStation) ? 0 : stations.indexOf(_selectedStation!);

  String get selectedCategoryId => _selectedStation?.id.toString() ?? '-1';

  List<TableSideCategory> get tableCategories => [
    ..._stations.map((s) => TableSideCategory(id: s.id.toString(), label: s.name ?? '-')),
  ];

  Future<void> getStations() async {
    await execute(
      fetchStationsOp,
      operation: () => _getStationsUseCase.call(GetStationsParams()),
      onData: (response) {
        final data = response.data ?? [];
        _stations = data;
        if (data.isNotEmpty) {
          selectStation(data.first);
        }
      },
    );
  }

  Future<void> getTransactions() async {
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
