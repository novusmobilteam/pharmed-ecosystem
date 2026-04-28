import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

enum StationPanelType { station, service, warehouse }

class StationSetupNotifier extends ChangeNotifier with SidePanelMixin<void, StationPanelType> {
  int _activeIndex = 0;
  int get activeIndex => _activeIndex;
  set activeIndex(int value) {
    if (_activeIndex == value) return;
    _activeIndex = value;
    closePanel();
    notifyListeners();
  }

  Station? _selectedStation;
  Station? get selectedStation => _selectedStation;

  HospitalService? _selectedService;
  HospitalService? get selectedService => _selectedService;

  Warehouse? _editingWarehouse;
  Warehouse? get editingWarehouse => _editingWarehouse;

  void openStationPanel({Station? station}) {
    _selectedStation = station;
    openPanel(type: StationPanelType.station);
    notifyListeners();
  }

  void openServicePanel({HospitalService? service}) {
    _selectedService = service;
    openPanel(type: StationPanelType.service);
    notifyListeners();
  }

  void openWarehousePanel({Warehouse? warehouse}) {
    _editingWarehouse = warehouse;
    openPanel(type: StationPanelType.warehouse);
    notifyListeners();
  }

  @override
  void closePanel() {
    _selectedStation = null;
    _selectedService = null;
    _editingWarehouse = null;
    notifyListeners();
  }
}
