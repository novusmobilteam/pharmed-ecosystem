import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class CabinTemperatureReportNotifier extends ChangeNotifier
    with ApiRequestMixin, PaginationMixin<CabinTemperatureValue> {
  final GetStationsUseCase _getStationsUseCase;
  final GetCabinTemperatureValuesUseCase _getCabinTemperaturesUseCase;

  CabinTemperatureReportNotifier({
    required GetStationsUseCase getStationsUseCase,
    required GetCabinTemperatureValuesUseCase getCabinTemperaturesUseCase,
  }) : _getStationsUseCase = getStationsUseCase,
       _getCabinTemperaturesUseCase = getCabinTemperaturesUseCase;

  OperationKey fetchStationsOp = OperationKey.fetch();
  OperationKey fetchReportsOp = OperationKey.fetch();

  List<Station> _stations = [];
  List<Station> get stations => _stations;

  Station? _selectedStation;
  Station? get selectedStation => _selectedStation;

  List<TableSideCategory> get tableCategories => [
    ..._stations.map((s) => TableSideCategory(id: s.id.toString(), label: s.name ?? '-')),
  ];

  String get selectedCategoryId => _selectedStation?.id.toString() ?? '-1';
  int get activeIndex => !stations.contains(_selectedStation) ? 0 : stations.indexOf(_selectedStation!);

  bool _showOutOfRange = false;
  bool get showOutOfRange => _showOutOfRange;

  bool get isFetching => isLoading(fetchReportsOp);
  String? get statusMessage => message(fetchReportsOp);

  Future<void> getStations() async {
    await execute(
      fetchStationsOp,
      operation: () => _getStationsUseCase.call(PagedQueryParams()),
      onData: (response) {
        final data = response.data ?? [];
        _stations = data;
        if (data.isNotEmpty) {
          selectStation(data.first);
        }
      },
    );
  }

  void selectStation(Station station) {
    _selectedStation = station;
    fetch();
    notifyListeners();
  }

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      op: fetchReportsOp,
      fetchMethod: (skip, take) => _getCabinTemperaturesUseCase.call(
        stationId: _selectedStation?.id ?? 0,
        outOfRange: _showOutOfRange,
        PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery, startDate: startDate, endDate: endDate),
      ),
    );
  }

  void toggleOutOfRange() {
    _showOutOfRange = !_showOutOfRange;
    resetFilters(notify: false, resetDate: false);
    notifyListeners();
    fetch();
  }
}
