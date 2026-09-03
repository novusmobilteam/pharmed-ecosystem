import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class DrugAssignmentNotifier extends ChangeNotifier with ApiRequestMixin {
  DrugAssignmentNotifier({
    required GetStationsUseCase getStationsUseCase,
    required GetCabinsByStationUseCase getCabinsByStationUseCase,
    required GetMedicineAssignmentsUseCase getAssignmentsUseCase,
    required GetCabinVisualizerDataUseCase getCabinVisualizerDataUseCase,
    required DeleteMedicineAssignmentUseCase deleteAssignmentUseCase,
  }) : _getStationsUseCase = getStationsUseCase,
       _getCabinsByStationUseCase = getCabinsByStationUseCase,
       _getAssignmentsUseCase = getAssignmentsUseCase,
       _getCabinVisualizerDataUseCase = getCabinVisualizerDataUseCase,
       _deleteAssignmentUseCase = deleteAssignmentUseCase;

  final GetStationsUseCase _getStationsUseCase;
  final GetCabinsByStationUseCase _getCabinsByStationUseCase;
  final GetMedicineAssignmentsUseCase _getAssignmentsUseCase;
  final GetCabinVisualizerDataUseCase _getCabinVisualizerDataUseCase;
  final DeleteMedicineAssignmentUseCase _deleteAssignmentUseCase;

  final OperationKey _getStationsOp = OperationKey.custom('fetch-stations');
  final OperationKey _getAssignmentsOp = OperationKey.custom('fetch-assignments');
  final OperationKey _getVisualizerOp = OperationKey.custom('fetch-cabin-visualizer');
  final OperationKey _deleteAssignmentOp = OperationKey.custom('delete-assignment');

  List<Station> _stations = [];
  List<Station> get stations => _stations;

  List<MedicineAssignment> _assignments = [];
  List<MedicineAssignment> get assignments => _assignments;

  List<DrawerGroup> _groups = [];
  List<DrawerGroup> get groups => _groups;

  final Map<int, List<Cabin>> _cabinsByStationId = {};
  List<Cabin> cabinsOf(int stationId) => _cabinsByStationId[stationId] ?? const [];

  int? _selectedStationId;

  int? _selectedCabinId;
  int? get selectedCabinId => _selectedCabinId;

  int? _selectedUnitId;
  int? get selectedUnitId => _selectedUnitId;

  Cabin? get selectedCabin {
    final cabins = _cabinsByStationId[_selectedStationId];
    if (cabins == null) return null;
    return cabins.firstWhereOrNull((c) => c.id == _selectedCabinId);
  }

  String? get selectedCategoryId => _selectedCabinId != null ? 'cabin-$_selectedCabinId' : null;

  // Kabin değişince eski cevabın geç gelip yeni seçimi ezmesini önlemek için.
  int _assignmentsRequestToken = 0;

  bool get isFetching => areLoading([_getVisualizerOp, _getAssignmentsOp]);
  bool get isSaving => isLoading(_deleteAssignmentOp);

  DrawerUnit? findUnit(int unitId) {
    for (final group in groups) {
      for (final unit in group.units) {
        if (unit.id == unitId) return unit;
      }
    }
    return null;
  }

  List<TableSideCategory> get sideCategories {
    return _stations.map((station) {
      final cabins = cabinsOf(station.id!);
      return TableSideCategory(
        id: 'station-${station.id}',
        label: station.name ?? '',
        count: cabins.length,
        children: cabins
            .map(
              (cabin) => TableSideCategory(
                id: 'cabin-${cabin.id}',
                label: cabin.name ?? '',
                // subtitle/statusColor alanları Cabin entity'nizdeki
                // gerçek alan adlarına göre güncellenmeli — burada
                // varsayım yaptım.
                subtitle: '${cabin.type?.label}',
                // statusColor: cabin.isOnline ? MedColors.green : MedColors.border,
              ),
            )
            .toList(),
      );
    }).toList();
  }

  Future<void> init() async {
    await _fetchStations();

    await Future.wait(_stations.map(_fetchCabinsForStation));
  }

  Future<void> _fetchStations() async {
    await execute(
      _getStationsOp,
      operation: () => _getStationsUseCase.call(const PagedQueryParams()),
      onData: (response) {
        _stations = response.data ?? [];
        notifyListeners();
      },
    );
  }

  Future<void> _fetchCabinsForStation(Station station) async {
    final stationId = station.id;
    if (stationId == null) return;
    await execute(
      OperationKey.custom('fetch-cabins-$stationId'),
      operation: () => _getCabinsByStationUseCase.call(stationId),
      onData: (data) {
        _cabinsByStationId[stationId] = data;
        if (_selectedCabinId == null && data.isNotEmpty) {
          _selectedStationId = stationId;
          _selectedCabinId = data.first.id;
          unawaited(_fetchCabinData(stationId, data.first.id!)); // ← _fetchAssignments değil
        }
        notifyListeners();
      },
    );
  }

  void selectCabin(int stationId, int cabinId) {
    if (_selectedStationId == stationId && _selectedCabinId == cabinId) return;
    _selectedStationId = stationId;
    _selectedCabinId = cabinId;
    _selectedUnitId = null;
    _groups = [];
    _assignments = [];
    notifyListeners();
    unawaited(_fetchCabinData(stationId, cabinId));
  }

  Future<void> _fetchCabinData(int stationId, int cabinId) async {
    final cabin = cabinsOf(stationId).firstWhereOrNull((c) => c.id == cabinId);
    if (cabin == null) return;

    await Future.wait([
      execute(
        _getVisualizerOp,
        operation: () =>
            _getCabinVisualizerDataUseCase.call(cabin: cabin, deviceMode: CabinType.master, forceRefresh: true),
        onData: (data) {
          _groups = data.groups;
          notifyListeners();
        },
      ),
      execute(
        _getAssignmentsOp,
        operation: () => _getAssignmentsUseCase.call(cabinId),
        onData: (data) {
          _assignments = data;
          notifyListeners();
        },
      ),
    ]);
  }

  /// Atama kaydet/sil sonrası — kabin FİZİKSEL YAPISI (groups) değişmez,
  /// sadece atamalar değişir; bu yüzden tüm visualizer'ı değil sadece
  /// assignments'ı yeniden çekmek yeterli.
  Future<void> refreshAssignments() async {
    final cabinId = _selectedCabinId;
    if (cabinId == null) return;
    final result = await _getAssignmentsUseCase.call(cabinId);
    result.when(
      ok: (data) {
        _assignments = data;
        notifyListeners();
      },
      error: (_) {},
    );
  }

  Future<void> deleteAssignment(
    MedicineAssignment assignment, {
    VoidCallback? onSuccess,
    void Function(String? msg)? onFailed,
  }) async {
    final id = assignment.cabinDrawerId;
    if (id == null) return;
    await executeVoid(
      _deleteAssignmentOp,
      operation: () => _deleteAssignmentUseCase.call(id),
      onSuccess: () {
        unawaited(refreshAssignments());
        onSuccess?.call();
      },
      onFailed: (err) => onFailed?.call(err.message),
    );
  }

  void selectUnit(int? unitId) {
    if (_selectedUnitId == unitId) return;
    _selectedUnitId = unitId;
    notifyListeners();
  }

  void selectCategory(String id) {
    final cabinId = int.tryParse(id.replaceFirst('cabin-', ''));
    if (cabinId == null) return;
    for (final entry in _cabinsByStationId.entries) {
      if (entry.value.any((c) => c.id == cabinId)) {
        selectCabin(entry.key, cabinId);
        return;
      }
    }
  }
}
