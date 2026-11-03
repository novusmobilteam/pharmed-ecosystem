import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

/// Dolum listesi sekmeleri: tümü, bekleyen (henüz tamamlanmamış), tamamlanan, iptal.
enum RefillListTab { all, active, completed, cancelled }

class RefillListNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetRefillListsUseCase _getRefillLists;
  final UpdateRefillListStatusUseCase _updateRefillListStatus;
  final CancelRefillListUseCase _cancelRefillList;
  final GetStationsUseCase _getStations;

  RefillListNotifier({
    required GetStationsUseCase getStations,
    required GetRefillListsUseCase getRefillLists,
    required UpdateRefillListStatusUseCase updateRefillListStatus,
    required CancelRefillListUseCase cancelRefillList,
  }) : _getStations = getStations,
       _getRefillLists = getRefillLists,
       _updateRefillListStatus = updateRefillListStatus,
       _cancelRefillList = cancelRefillList;

  OperationKey fetchStationsOp = OperationKey.custom('fetch-stations');
  OperationKey fetchRecordsOp = OperationKey.custom('fetch-records');
  OperationKey updateOp = OperationKey.update();
  OperationKey cancelOp = OperationKey.custom('cancel');

  List<Station> _stations = [];
  List<Station> get stations => _stations;

  List<RefillList> _items = [];

  RefillListTab _tab = RefillListTab.active;
  RefillListTab get tab => _tab;

  DateTimeRange? _dateRange;

  RefillListTab tabOf(RefillList list) {
    if (list.isCancel) return RefillListTab.cancelled;
    if (list.status == RefillListStatus.completed) return RefillListTab.completed;
    return RefillListTab.active;
  }

  bool _inTab(RefillList l, RefillListTab tab) => tab == RefillListTab.all || tabOf(l) == tab;

  int countOf(RefillListTab tab) => _items.where((l) => _inTab(l, tab)).length;

  /// Seçili sekmedeki, tarih aralığına giren listeler (yeniden eskiye).
  List<RefillList> get items {
    final range = _dateRange;
    final result = _items.where((l) {
      if (!_inTab(l, _tab)) return false;
      if (range == null) return true;
      final d = l.date;
      if (d == null) return false;
      final day = DateTime(d.year, d.month, d.day);
      final start = DateTime(range.start.year, range.start.month, range.start.day);
      final end = DateTime(range.end.year, range.end.month, range.end.day);
      return !day.isBefore(start) && !day.isAfter(end);
    }).toList();
    result.sort((a, b) => (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0)));
    return result;
  }

  void selectTab(RefillListTab tab) {
    if (_tab == tab) return;
    _tab = tab;
    notifyListeners();
  }

  void setDateRange(DateTimeRange? range) {
    _dateRange = range;
    notifyListeners();
  }

  // Station
  Station? _selectedStation;
  Station? get selectedStation => _selectedStation;
  String get selectedStationId => _selectedStation?.id.toString() ?? '-1';

  bool get isTableLoading => isLoading(fetchStationsOp) || isLoading(fetchRecordsOp);

  List<TableSideCategory> get tableCategories => [
    ...stations.map((s) => TableSideCategory(id: s.id.toString(), label: s.name ?? '-')),
  ];

  void getStations() async {
    await execute(
      fetchStationsOp,
      operation: () => _getStations.call(PagedQueryParams()),
      onData: (response) {
        if (response.data != null) {
          _stations = response.data!;
          selectStation(_stations.first);
          notifyListeners();
        }
      },
    );
  }

  // Dolum listelerini getirme işlemi
  Future<void> getRefillLists() async {
    final stationId = _selectedStation?.id ?? 0;
    await execute(fetchRecordsOp, operation: () => _getRefillLists.call(stationId), onData: (data) => _items = data);
  }

  // Dolum listesi iptal etme işlemi
  Future<void> cancelRefillList(
    RefillList record, {
    Function(String? msg)? onFailed,
    Function(String? msg)? onSuccess,
  }) async {
    await executeVoid(
      cancelOp,
      operation: () => _cancelRefillList.call(record),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        getRefillLists();
        onSuccess?.call(null);
      },
    );
  }

  // Kayıt durumunu güncelleyen servis (Toplandı/toplanacak/gönderildi vb.)
  Future<void> updateRefillListStatus(
    RefillList record, {
    Function(String? msg)? onFailed,
    Function(String? msg)? onSuccess,
  }) async {
    await executeVoid(
      updateOp,
      operation: () => _updateRefillListStatus.call(record),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        getRefillLists();
        onSuccess?.call(null);
      },
    );
  }

  void selectStation(Station? station) {
    _selectedStation = station;
    getRefillLists();
    notifyListeners();
  }
}
