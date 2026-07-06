import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class AssignmentNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetStationsUseCase _getStationsUseCase;
  final GetStationUseCase _getStationUseCase;
  final GetCabinVisualizerDataUseCase _getCabinVisualizerDataUseCase;

  AssignmentNotifier({
    required GetStationsUseCase getStationsUseCase,
    required GetStationUseCase getStationUseCase,
    required GetCabinVisualizerDataUseCase getCabinVisualizerDataUseCase,
  }) : _getStationsUseCase = getStationsUseCase,
       _getStationUseCase = getStationUseCase,
       _getCabinVisualizerDataUseCase = getCabinVisualizerDataUseCase;

  String? get statusMessage => message(fetchStationsOp);

  OperationKey fetchStationsOp = OperationKey.fetch();
  OperationKey fetchVisualizerOp = OperationKey.fetch();
  OperationKey fetchStationOp = OperationKey.fetch();

  List<Station> _stations = [];
  List<Station> get stations => _stations;

  Station? _selectedStation;
  Station? get selectedStation => _selectedStation;

  Cabin? get cabin => _selectedStation?.activeCabin;

  CabinVisualizerData? _cabinVisualizer;
  CabinVisualizerData? get cabinVisualizer => _cabinVisualizer;

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
    _cabinVisualizer = null;
    _fetchCabin();
    notifyListeners();
    _fetchStationDetail();
  }

  Future<void> _fetchStationDetail() async {
    if (_selectedStation != null && _selectedStation?.id != null) {
      await execute(
        fetchStationOp,
        operation: () => _getStationUseCase.call(_selectedStation!.id!),
        onData: (data) {
          if (data != null) {
            _selectedStation = data;
            // var services = [
            //   if (data.service != null) data.service!,
            //   ...data.services.where((s) => s.id != data.service?.id),
            // ];
            // _selectedStation = _selectedStation?.copyWith(services: services);
            notifyListeners();
          }
        },
      );
    }
  }

  Future<void> _fetchCabin() async {
    if (cabin == null) {
      return;
    }
    await execute(
      fetchVisualizerOp,
      operation: () => _getCabinVisualizerDataUseCase.call(cabinId: cabin!.id, deviceMode: cabin?.type),
      onData: (data) {
        _cabinVisualizer = data;
        notifyListeners();
      },
    );
  }
}
