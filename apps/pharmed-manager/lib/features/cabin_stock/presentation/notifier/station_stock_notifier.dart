import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../../../core/widgets/unified_table/unified_table_models.dart';

class StationStockNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<StationStock> {
  final GetStationsUseCase _getStationsUseCase;
  final GetStationStocksUseCase _getStationStocksUseCase;

  StationStockNotifier({
    required GetStationsUseCase getStationsUseCase,
    required GetStationStocksUseCase getStationStocksUseCase,
  }) : _getStationsUseCase = getStationsUseCase,
       _getStationStocksUseCase = getStationStocksUseCase;

  OperationKey fetchStocksOp = OperationKey.fetch();
  OperationKey fetchStationsOp = OperationKey.fetch();

  bool get isFetching => isLoading(fetchStocksOp);

  Station? _selectedStation;
  Station? get selectedStation => _selectedStation;

  List<Station> _stations = [];
  List<Station> get stations => _stations;

  int get activeIndex => !stations.contains(_selectedStation) ? 0 : stations.indexOf(_selectedStation!);

  String get selectedCategoryId => _selectedStation?.id.toString() ?? '-1';

  List<TableSideCategory> get tableCategories => [
    ..._stations.map(
      (s) => TableSideCategory(
        id: s.id.toString(),
        label: s.name ?? '-',
        count: allItems.where((item) => item.station?.id == s.id).length,
      ),
    ),
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

  Future<void> getStocks() async {
    final stationId = _selectedStation?.id ?? 0;
    await execute(
      fetchStocksOp,
      operation: () => _getStationStocksUseCase.call(stationId),
      onData: (data) {
        allItems = data;
      },
    );
  }

  void selectStation(Station? station) {
    _selectedStation = station;
    notifyListeners();
    getStocks();
  }
}
