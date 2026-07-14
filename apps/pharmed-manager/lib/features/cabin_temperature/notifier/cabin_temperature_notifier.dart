import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:pharmed_manager/core/core.dart';

class CabinTemperatureNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetStationsUseCase _getStationsUseCase;
  final GetCabinsByStationUseCase _getCabinsByStationUseCase;
  final GetCabinTemperatureUseCase _getCabinTemperatureUseCase;
  final CreateCabinTemperatureUseCase _createCabinTemperatureUseCase;

  CabinTemperatureNotifier({
    required GetStationsUseCase getStationsUseCase,
    required GetCabinsByStationUseCase getCabinsByStationUseCase,
    required GetCabinTemperatureUseCase getCabinTemperatureUseCase,
    required CreateCabinTemperatureUseCase createCabinTemperatureUseCase,
  }) : _getStationsUseCase = getStationsUseCase,
       _getCabinsByStationUseCase = getCabinsByStationUseCase,
       _getCabinTemperatureUseCase = getCabinTemperatureUseCase,
       _createCabinTemperatureUseCase = createCabinTemperatureUseCase;

  OperationKey getStationsOp = OperationKey.custom('get_stations');
  OperationKey getCabinsOp = OperationKey.custom('get_stations');
  OperationKey getTempOp = OperationKey.custom('get_temp');
  OperationKey submitOp = OperationKey.submit();

  List<Station> _stations = [];
  List<Station> get stations => _stations;

  Station? _selectedStation;
  Station? get selectedStation => _selectedStation;

  List<Cabin> _cabins = [];
  List<Cabin> get cabins => _cabins;

  Cabin? _selectedCabin;
  Cabin? get selectedCabin => _selectedCabin;

  List<CabinTemperature> _temperatures = [];
  List<CabinTemperature> get temperatures => _temperatures;

  CabinTemperature _temperature = CabinTemperature();
  CabinTemperature get temperature => _temperature;

  Future<void> getStations() async {
    await execute(
      getStationsOp,
      operation: () => _getStationsUseCase.call(PagedQueryParams()),
      onData: (response) {
        if (response.data != null) {
          _stations = response.data!;
          final first = _stations.firstOrNull;
          if (first != null) {
            selectStation(first);
          }
        }
      },
    );
  }

  void selectStation(Station? station) {
    _selectedStation = station;
    _selectedCabin = null;
    _temperature = CabinTemperature();
    _temperatures = [];
    _getCabins();
    _getCabinTemperature();
    notifyListeners();
  }

  Future<void> _getCabins() async {
    if (_selectedStation == null) return;

    await execute(
      getStationsOp,
      operation: () => _getCabinsByStationUseCase.call(_selectedStation!.id ?? 0),
      onData: (data) {
        _cabins = data;
        notifyListeners();
      },
    );
  }

  void selectCabin(Cabin? cabin) {
    _selectedCabin = cabin;
    _resolveTemperatureForSelectedCabin();
    notifyListeners();
  }

  Future<void> _getCabinTemperature() async {
    final station = _selectedStation;
    if (station?.id == null) return;

    await execute(
      getTempOp,
      operation: () => _getCabinTemperatureUseCase.call(station!.id!),
      onData: (data) {
        _temperatures = data;
        _resolveTemperatureForSelectedCabin();
        notifyListeners();
      },
    );
  }

  /// Seçili kabine ait sıcaklık kaydını mevcut listeden bulur;
  /// yoksa yeni kayıt için boş bir taslak oluşturur.
  void _resolveTemperatureForSelectedCabin() {
    final cabinId = _selectedCabin?.id;
    if (cabinId == null) {
      _temperature = CabinTemperature();
      return;
    }

    _temperature =
        _temperatures.firstWhereOrNull((t) => t.cabin?.id == cabinId) ??
        CabinTemperature(station: _selectedStation, cabin: _selectedCabin);
  }

  Future<void> submit({Function(String? msg)? onFailed, VoidCallback? onSuccess}) async {
    await executeVoid(
      submitOp,
      operation: () => _createCabinTemperatureUseCase.call(_temperature),
      onFailed: (error) => onFailed!(error.message),
      onSuccess: onSuccess,
    );
  }

  void updateInsideBottomTemp(String? value) {
    var temp = int.tryParse(value ?? "");
    _temperature = _temperature.copyWith(bottomTemperatureInside: temp);
    notifyListeners();
  }

  void updateInsideTopTemp(String? value) {
    var temp = int.tryParse(value ?? "");
    _temperature = _temperature.copyWith(topTemperatureInside: temp);
    notifyListeners();
  }

  void updateOutsideBottomTemp(String? value) {
    var temp = int.tryParse(value ?? "");
    _temperature = _temperature.copyWith(bottomTemperatureOutside: temp);
    notifyListeners();
  }

  void updateOutsideTopTemp(String? value) {
    var temp = int.tryParse(value ?? "");
    _temperature = _temperature.copyWith(topTemperatureOutside: temp);
    notifyListeners();
  }

  void updateBottomHumidity(String? value) {
    var temp = int.tryParse(value ?? "");
    _temperature = _temperature.copyWith(bottomLimitHumidity: temp);
    notifyListeners();
  }

  void updateTopHumidity(String? value) {
    var temp = int.tryParse(value ?? "");
    _temperature = _temperature.copyWith(topLimitHumidity: temp);
    notifyListeners();
  }
}
