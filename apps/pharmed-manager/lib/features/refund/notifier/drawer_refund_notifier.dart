import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class DrawerRefundNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<Refund> {
  final GetStationsUseCase _getStationsUseCase;
  final GetDrawerRefundsUseCase _getDrawerRefunds;
  final GetReturnBoxRefundsUseCase _getReturnBoxRefunds;

  DrawerRefundNotifier({
    required GetStationsUseCase getStationsUseCase,
    required GetDrawerRefundsUseCase getDrawerRefunds,
    required GetReturnBoxRefundsUseCase getReturnBoxRefunds,
  }) : _getStationsUseCase = getStationsUseCase,
       _getDrawerRefunds = getDrawerRefunds,
       _getReturnBoxRefunds = getReturnBoxRefunds;

  final OperationKey fetchStationsOp = OperationKey.custom('fetch-stations');
  final OperationKey fetchRefundsOp = OperationKey.custom('fetch-refunds');

  List<Station> _stations = [];
  List<Station> get stations => _stations;

  Station? _selectedStation;
  Station? get selectedStation => _selectedStation;

  List<TableSideCategory> get tableCategories => [
    ..._stations.map((s) => TableSideCategory(id: s.id.toString(), label: s.name ?? '-')),
  ];

  String get selectedCategoryId => _selectedStation?.id.toString() ?? '-1';
  int get activeIndex => !stations.contains(_selectedStation) ? 0 : stations.indexOf(_selectedStation!);

  bool get isFetching => isLoading(fetchRefundsOp);

  bool _showReturnBox = false;
  bool get showReturnBox => _showReturnBox;

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
    if (_showReturnBox) {
      await _fetchReturnBoxRefunds();
    } else {
      await _fetchDrawerRefunds();
    }
  }

  Future<void> _fetchDrawerRefunds() async {
    await fetchPagedData(
      op: fetchRefundsOp,
      fetchMethod: (skip, take) => _getDrawerRefunds.call(
        stationId: _selectedStation?.id ?? 0,
        PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery, startDate: startDate, endDate: endDate),
      ),
    );
  }

  Future<void> _fetchReturnBoxRefunds() async {
    await fetchPagedData(
      op: fetchRefundsOp,
      fetchMethod: (skip, take) => _getReturnBoxRefunds.call(
        stationId: _selectedStation?.id ?? 0,
        PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery, startDate: startDate, endDate: endDate),
      ),
    );
  }

  void toggleView() {
    _showReturnBox = !_showReturnBox;
    notifyListeners();
    fetch();
  }
}
