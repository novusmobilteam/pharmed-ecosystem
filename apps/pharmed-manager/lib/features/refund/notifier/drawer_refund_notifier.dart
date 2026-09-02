import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class DrawerRefundNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<Refund> {
  final GetStationsUseCase _getStationsUseCase;
  final GetDrawerRefundsUseCase _getRefundsUseCase;

  DrawerRefundNotifier({
    required GetStationsUseCase getStationsUseCase,
    required GetDrawerRefundsUseCase getRefundsUseCase,
  }) : _getStationsUseCase = getStationsUseCase,
       _getRefundsUseCase = getRefundsUseCase;

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

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      op: fetchRefundsOp,
      fetchMethod: (skip, take) => _getRefundsUseCase.call(
        stationId: _selectedStation?.id ?? 0,
        PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery, startDate: startDate, endDate: endDate),
      ),
    );
  }

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
}
