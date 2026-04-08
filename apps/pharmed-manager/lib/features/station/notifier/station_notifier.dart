import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class StationNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<Station> {
  final GetStationsUseCase _getStationsUseCase;
  final DeleteStationUseCase _deleteStationUseCase;

  StationNotifier({required GetStationsUseCase getStationsUseCase, required DeleteStationUseCase deleteStationUseCase})
    : _getStationsUseCase = getStationsUseCase,
      _deleteStationUseCase = deleteStationUseCase;

  OperationKey deleteOp = OperationKey.delete();
  OperationKey fetchOp = OperationKey.fetch();

  int _activeIndex = 0;
  int get activeIndex => _activeIndex;

  bool _isPanelOpen = false;
  bool get isPanelOpen => _isPanelOpen;

  Station? _editingStation;
  Station? get editingStation => _editingStation;

  set activeIndex(int index) {
    if (_activeIndex == index) return;
    _activeIndex = index;
    notifyListeners();
  }

  void openPanel({Station? station}) {
    _editingStation = station;
    _isPanelOpen = true;
    notifyListeners();
  }

  void closePanel() {
    _isPanelOpen = false;
    _editingStation = null;
    notifyListeners();
  }

  Future<void> getStations() async {
    await execute(
      fetchOp,
      operation: () => _getStationsUseCase.call(GetStationsParams()),
      onData: (response) {
        if (response.data != null) {
          allItems = response.data!;
        }
      },
    );
  }

  Future<void> deleteStation(
    Station station, {
    Function(String? msg)? onFailed,
    Function(String? msg)? onSuccess,
  }) async {
    await executeVoid(
      deleteOp,
      operation: () => _deleteStationUseCase.call(station),
      onSuccess: () {
        onSuccess?.call('İşleminiz başarıyla tamamlandı');
        getStations();
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }
}
