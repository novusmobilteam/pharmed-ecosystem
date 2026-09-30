import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

/// İstasyon Stok Veri ekranına özel [MedicineAssignment] okuma yardımcıları.
///
/// ⚠️ VARSAYIM: `stockQuantity` alan adı MedicineAssignment entity'sindeki
/// güncel stok alanına göre güncellenmeli. Entity'ye stok erişimi yalnızca
/// burada yapılır.
extension StationStockAssignmentX on MedicineAssignment {
  num? get currentStock => totalQuantity;

  /// Güncel stokun maksimum miktara oranı (0.5 = %50).
  ///
  /// Stok ve maksimum backend'de aynı birimde tutulduğu için oran
  /// birimden bağımsızdır. 1'in üzerindeki değerler kırpılmaz; maksimumun
  /// aşıldığı görülebilsin. Maksimum tanımsız veya sıfırsa `null` döner.
  double? get fillRatio {
    final stock = currentStock;
    final max = maxQuantity;
    if (stock == null || max <= 0) return null;
    return stock / max;
  }
}

class StationStockDataNotifier extends ChangeNotifier with ApiRequestMixin {
  StationStockDataNotifier({
    required GetStationsUseCase getStationsUseCase,
    required GetCabinsByStationUseCase getCabinsByStationUseCase,
    required GetCabinAssignmentsWithCabinUseCase getCabinAssignmentsUseCase,
    required GetCabinVisualizerDataUseCase getCabinVisualizerDataUseCase,
  }) : _getStationsUseCase = getStationsUseCase,
       _getCabinsByStationUseCase = getCabinsByStationUseCase,
       _getCabinAssignmentsUseCase = getCabinAssignmentsUseCase,
       _getCabinVisualizerDataUseCase = getCabinVisualizerDataUseCase;

  final GetStationsUseCase _getStationsUseCase;
  final GetCabinsByStationUseCase _getCabinsByStationUseCase;
  final GetCabinAssignmentsWithCabinUseCase _getCabinAssignmentsUseCase;
  final GetCabinVisualizerDataUseCase _getCabinVisualizerDataUseCase;

  static const _cabinPrefix = 'cabin-';

  final OperationKey _getStationsOp = OperationKey.custom('fetch-stations');
  final OperationKey _getAssignmentsOp = OperationKey.custom('fetch-cabin-stock');
  final OperationKey _getVisualizerOp = OperationKey.custom('fetch-cabin-visualizer');

  List<Station> _stations = [];

  final Map<int, List<Cabin>> _cabinsByStationId = {};
  List<Cabin> cabinsOf(int stationId) => _cabinsByStationId[stationId] ?? const [];

  List<MedicineAssignment> _assignments = [];
  List<MedicineAssignment> get assignments => _assignments;

  List<DrawerGroup> _groups = [];
  List<DrawerGroup> get groups => _groups;

  int? _selectedCabinId;
  int? get selectedCabinId => _selectedCabinId;

  String? get selectedCategoryId => _selectedCabinId != null ? '$_cabinPrefix$_selectedCabinId' : null;

  /// Yalnızca ilk istasyon listesi yüklenirken true; ekran genelindeki
  /// loading için kullanılır. Kabin değişiminde tüm ekran kilitlenmez.
  bool get isInitializing => isLoading(_getStationsOp);

  /// Seçili kabinin stok ve görsel verisi yüklenirken true.
  bool get isFetching => areLoading([_getAssignmentsOp, _getVisualizerOp]);

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
                id: '$_cabinPrefix${cabin.id}',
                label: cabin.name ?? '',
                subtitle: '${cabin.type?.label}',
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
        // İstasyonlar paralel yüklendiği için ilk yanıt dönen istasyonun
        // ilk kabini seçilir (atama ekranıyla aynı davranış).
        final firstCabinId = data.firstOrNull?.id;
        if (_selectedCabinId == null && firstCabinId != null) {
          _selectedCabinId = firstCabinId;
          unawaited(_fetchCabinData(firstCabinId));
        }
        notifyListeners();
      },
    );
  }

  void selectCategory(String id) {
    // İstasyon satırları yalnızca grup başlığıdır; sadece kabin seçimi veri çeker.
    if (!id.startsWith(_cabinPrefix)) return;
    final cabinId = int.tryParse(id.substring(_cabinPrefix.length));
    if (cabinId == null || cabinId == _selectedCabinId) return;

    _selectedCabinId = cabinId;
    _assignments = [];
    _groups = [];
    notifyListeners();
    unawaited(_fetchCabinData(cabinId));
  }

  Future<void> refresh() async {
    final cabinId = _selectedCabinId;
    if (cabinId == null) return;
    await _fetchCabinData(cabinId);
  }

  Cabin? _findCabin(int cabinId) => _cabinsByStationId.values.expand((c) => c).firstWhereOrNull((c) => c.id == cabinId);

  /// Stok ve kabin görselini paralel çeker. Hızlı kabin değişiminde geç
  /// dönen eski yanıtın yeni seçimin verisinin üzerine yazılması,
  /// `cabinId != _selectedCabinId` kontrolüyle engellenir.
  Future<void> _fetchCabinData(int cabinId) async {
    final cabin = _findCabin(cabinId);
    if (cabin == null) return;

    await Future.wait([
      execute(
        _getAssignmentsOp,
        operation: () => _getCabinAssignmentsUseCase.call(cabinId),
        onData: (data) {
          if (cabinId != _selectedCabinId) return;
          _assignments = data;
          notifyListeners();
        },
      ),
      execute(
        _getVisualizerOp,
        operation: () =>
            _getCabinVisualizerDataUseCase.call(cabin: cabin, deviceMode: CabinType.master, forceRefresh: true),
        onData: (data) {
          if (cabinId != _selectedCabinId) return;
          _groups = data.groups;
          notifyListeners();
        },
      ),
    ]);
  }
}
