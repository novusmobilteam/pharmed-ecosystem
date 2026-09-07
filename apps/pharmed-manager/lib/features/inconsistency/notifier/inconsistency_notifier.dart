import 'package:flutter/material.dart';

import 'package:pharmed_manager/core/core.dart';

class InconsistencyNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<Inconsistency> {
  final GetStationsUseCase _getStationsUseCase;
  final GetInconsistenciesUseCase _getInconsistenciesUseCase;
  final SolveInconsistencyUseCase _solveUseCase;

  InconsistencyNotifier({
    required GetStationsUseCase getStationsUseCase,
    required GetInconsistenciesUseCase getInconsistenciesUseCase,
    required SolveInconsistencyUseCase solveUseCase,
  }) : _getStationsUseCase = getStationsUseCase,
       _getInconsistenciesUseCase = getInconsistenciesUseCase,
       _solveUseCase = solveUseCase;

  final OperationKey _fetchOp = OperationKey.custom('fetch-inconsistencies');
  final OperationKey _fetchStationsOp = OperationKey.custom('fetch-stations');
  final OperationKey _solveOp = OperationKey.custom('solve-inconsistency');

  List<Station> _stations = [];
  List<Station> get stations => _stations;

  Station? _selectedStation;
  Station? get selectedStation => _selectedStation;

  bool get isFetching => areLoading([_fetchOp, _fetchStationsOp]);
  bool get isSolving => isLoading(_solveOp);

  List<TableSideCategory> get tableCategories => [
    ..._stations.map((s) => TableSideCategory(id: s.id.toString(), label: s.name ?? '-')),
  ];

  String get selectedCategoryId => _selectedStation?.id.toString() ?? '-1';
  int get activeIndex => !stations.contains(_selectedStation) ? 0 : stations.indexOf(_selectedStation!);

  String? _description;
  String? get description => _description;

  Future<void> getStations() async {
    await execute(
      _fetchStationsOp,
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
      op: _fetchOp,
      fetchMethod: (skip, take) => _getInconsistenciesUseCase.call(
        stationId,
        params: PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery),
      ),
    );
  }

  Future<void> solveInconsistency(
    Inconsistency item, {
    Function(String? msg)? onFailed,
    VoidCallback? onSuccess,
  }) async {
    final id = item.id;
    if (id == null) return;

    await executeVoid(
      _solveOp,
      operation: () => _solveUseCase.call(id, description: _description ?? ''),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: onSuccess,
    );
  }

  void updateDescription(String? value) {
    _description = value;
    notifyListeners();
  }
}
