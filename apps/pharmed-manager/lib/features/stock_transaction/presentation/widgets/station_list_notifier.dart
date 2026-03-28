part of 'stations_list_view.dart';

class StationListNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetStationsUseCase _getStationsUseCase;

  StationListNotifier(this._getStationsUseCase);

  OperationKey fetchOp = OperationKey.fetch();

  List<Station> _stations = [];
  List<Station> get stations => _stations;

  Station? _selectedStation;
  Station? get selectedStation => _selectedStation;

  int get activeIndex => !_stations.contains(_selectedStation) ? 0 : _stations.indexOf(_selectedStation!);

  Future getStations({Function(Station)? onInitialLoad}) async {
    await execute(
      fetchOp,
      operation: () => _getStationsUseCase.call(GetStationsParams()),
      onData: (response) {
        _stations = response.data ?? [];
        if (_stations.isNotEmpty) {
          final firstStation = _stations.first;
          selectStation(firstStation);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onInitialLoad?.call(firstStation);
          });
        }
      },
    );
  }

  void selectStation(Station station) {
    _selectedStation = station;
    notifyListeners();
  }
}
