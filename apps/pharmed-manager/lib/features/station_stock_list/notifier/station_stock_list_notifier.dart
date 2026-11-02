// [SWREQ-MGR-STATIONSTOCK-001] [IEC 62304 §5.5]
// İstasyon stok listesi: seçili istasyonun stokları, tablodan seçilen
// satırlar ve seçilenlerin yazdırılması için kullanılan hesaplanmış değerler.
//
// Kalan (remainingQuantity) ve Dolum (fillingQuantity) servisten gelir,
// istemcide hesaplanmaz.
//
// Sınıf: Class B

import 'package:flutter/foundation.dart';

import '../../../core/core.dart';

class StationStockListNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetStationsUseCase _getStationsUseCase;
  final GetStationStocksUseCase _getStationStockUseCase;

  StationStockListNotifier({
    required GetStationsUseCase getStationsUseCase,
    required GetStationStocksUseCase getStationStockUseCase,
  }) : _getStationsUseCase = getStationsUseCase,
       _getStationStockUseCase = getStationStockUseCase;

  OperationKey fetchOp = OperationKey.custom('fetch-stocks');
  OperationKey fetchStationsOp = OperationKey.custom('fetch-stations');

  List<Station> _stations = [];
  List<Station> get stations => _stations;

  Station? _selectedStation;
  Station? get selectedStation => _selectedStation;

  List<StationStock> _items = [];
  List<StationStock> get items => _items;

  /// Tablodan seçilen satırlar — yazdırma bunları basar.
  Set<StationStock> _selected = {};

  /// Seçili satırlar, listedeki sırayla. İstasyon değişince/yenilenince
  /// listede olmayanlar düşer (tablo kendi seçimini sessizce budar).
  List<StationStock> get selectedItems => _items.where(_selected.contains).toList();

  bool get canPrint => !isFetching && selectedItems.isNotEmpty;

  bool get isFetching => areLoading([fetchOp, fetchStationsOp]);

  List<TableSideCategory> get tableCategories => [
    ..._stations.map((s) => TableSideCategory(id: s.id.toString(), label: s.name ?? '-')),
  ];

  String get selectedCategoryId => _selectedStation?.id.toString() ?? '-1';
  int get activeIndex => !stations.contains(_selectedStation) ? 0 : stations.indexOf(_selectedStation!);

  /// Kod: kayıttaki kod, yoksa ilacın kodu.
  static String? codeOf(StationStock s) {
    final own = s.code;
    if (own != null && own.isNotEmpty) return own;
    final medicine = s.medicine;
    return medicine is Drug ? medicine.code : null;
  }

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
    _selected = {};
    _fetchStocks();
    notifyListeners();
  }

  void onSelectionChanged(Set<StationStock> selected) {
    _selected = selected;
    notifyListeners();
  }

  Future<void> _fetchStocks() async {
    final stationId = _selectedStation?.id;
    if (stationId == null) return;

    await execute(
      fetchOp,
      operation: () => _getStationStockUseCase.call(stationId),
      onData: (stocks) {
        _items = stocks;
        notifyListeners();
      },
    );
  }
}
