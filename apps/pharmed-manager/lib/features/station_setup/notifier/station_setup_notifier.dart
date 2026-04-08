import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

enum StationPanelType { station, service, warehouse }

class StationSetupNotifier extends ChangeNotifier {
  bool _isPanelOpen = false;
  bool get isPanelOpen => _isPanelOpen;

  StationPanelType? _panelType;
  StationPanelType? get panelType => _panelType;

  int _activeIndex = 0;
  int get activeIndex => _activeIndex;
  set activeIndex(int value) {
    if (_activeIndex == value) return;
    _activeIndex = value;
    closePanel();
    notifyListeners();
  }

  // Her panel tipine özgü editing entity
  Station? _editingStation;
  Station? get editingStation => _editingStation;

  HospitalService? _editingService;
  HospitalService? get editingService => _editingService;

  Warehouse? _editingWarehouse;
  Warehouse? get editingWarehouse => _editingWarehouse;

  void openStationPanel({Station? station}) {
    _editingStation = station;
    _panelType = StationPanelType.station;
    _isPanelOpen = true;
    notifyListeners();
  }

  void openServicePanel({HospitalService? service}) {
    _editingService = service;
    _panelType = StationPanelType.service;
    _isPanelOpen = true;
    notifyListeners();
  }

  void openWarehousePanel({Warehouse? warehouse}) {
    _editingWarehouse = warehouse;
    _panelType = StationPanelType.warehouse;
    _isPanelOpen = true;
    notifyListeners();
  }

  void closePanel() {
    _isPanelOpen = false;
    _panelType = null;
    _editingStation = null;
    _editingService = null;
    _editingWarehouse = null;
    notifyListeners();
  }
}
