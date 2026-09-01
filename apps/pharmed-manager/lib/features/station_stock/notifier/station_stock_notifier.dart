import 'package:flutter/foundation.dart';

import '../../../core/core.dart';

class StationStockNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetStationsUseCase _getStationsUseCase;
  final GetStationStocksUseCase _getStationStockUseCase;

  StationStockNotifier({
    required GetStationsUseCase getStationsUseCase,
    required GetStationStocksUseCase getStationStockUseCase,
  }) : _getStationsUseCase = getStationsUseCase,
       _getStationStockUseCase = getStationStockUseCase;

  OperationKey fetchOp = OperationKey.custom('fetch-stocks');
  OperationKey fetchStationsOp = OperationKey.custom('fetch-stations');

  List<Station> _stations = [];
  List<Station> get stations => _stations;

  Station? _selectedStation;
  Station? get selectedStation => _selectedStation;

  List<StationStock> _items = [];
  List<StationStock> get items => _items;

  bool get isFetching => isLoading(fetchOp);

  Future<void> getStations() async {
    await execute(
      fetchStationsOp,
      operation: () => _getStationsUseCase.call(PagedQueryParams()),
      onData: (response) {
        if (response.data != null) {
          _stations = response.data!;
        }
        if (_stations.isNotEmpty) {
          selectStation(_stations.first);
        }
        notifyListeners();
      },
    );
  }

  void selectStation(Station? station) {
    _selectedStation = station;
    _fetchStocks();
    notifyListeners();
  }

  Future<void> _fetchStocks() async {
    final stationId = _selectedStation?.id;
    if (stationId == null) return;

    await execute(
      fetchOp,
      operation: () => _getStationStockUseCase.call(stationId),
      onData: (stocks) {
        _items = stocks;
        notifyListeners();
      },
    );
  }
}
