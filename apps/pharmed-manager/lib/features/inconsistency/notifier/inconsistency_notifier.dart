import 'package:flutter/material.dart';

import 'package:pharmed_manager/core/core.dart';

class InconsistencyNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<Inconsistency> {
  final GetStationsUseCase _getStationsUseCase;
  final GetInconsistenciesUseCase _getInconsistenciesUseCase;

  InconsistencyNotifier({
    required GetStationsUseCase getStationsUseCase,
    required GetInconsistenciesUseCase getInconsistenciesUseCase,
  }) : _getStationsUseCase = getStationsUseCase,
       _getInconsistenciesUseCase = getInconsistenciesUseCase;

  OperationKey fetchOp = OperationKey.custom('fetch-inconsistencies');
  OperationKey fetchStationsOp = OperationKey.custom('fetch-stations');

  List<Station> _stations = [];
  List<Station> get stations => _stations;

  Station? _selectedStation;
  Station? get selectedStation => _selectedStation;

  // Getters
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
    fetch();
    notifyListeners();
  }

  @override
  Future<void> fetch() async {
    final stationId = _selectedStation?.id;
    if (stationId == null) return;

    await fetchPagedData(
      op: fetchOp,
      fetchMethod: (skip, take) => _getInconsistenciesUseCase.call(
        stationId,
        params: PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery),
      ),
    );
  }
}
