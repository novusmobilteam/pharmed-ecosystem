import 'package:flutter/widgets.dart';
import 'package:pharmed_manager/core/core.dart';

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

  bool _isPanelOpen = false;
  bool get isPanelOpen => _isPanelOpen;

  RefillList? _selectedItem;
  RefillList? get selectedItem => _selectedItem;

  List<Station> _stations = [];
  List<Station> get stations => _stations;

  List<RefillList> _items = [];
  List<RefillList> get items => _items;

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

  void openPanel({RefillList? item}) {
    _isPanelOpen = true;
    _selectedItem = item;
    notifyListeners();
  }

  void closePanel() {
    _isPanelOpen = false;
    notifyListeners();
  }
}
