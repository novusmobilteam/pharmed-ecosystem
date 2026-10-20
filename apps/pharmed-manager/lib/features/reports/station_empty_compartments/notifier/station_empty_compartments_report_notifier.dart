import 'package:flutter/foundation.dart';
import 'package:pharmed_manager/core/core.dart';

/// İstasyon Boş Göz Listesi.
///
/// Ana tablo çekmece bazında boş/dolu göz sayılarını listeler; istasyon seçimi
/// çoklu yapılır (seçim yoksa tüm istasyonlar). Bir satırın detayı açıldığında
/// o çekmecenin boş gözleri ayrı servisten çekilir.
class StationEmptyCompartmentsReportNotifier extends ChangeNotifier
    with ApiRequestMixin, PaginationMixin<StationEmptyCompartment> {
  final GetStationsUseCase _getStationsUseCase;
  final GetStationEmptyCompartmentsUseCase _getStationEmptyCompartmentsUseCase;
  final GetStationEmptyCompartmentDetailsUseCase _getStationEmptyCompartmentDetailsUseCase;
  final GetDrawerTypesUseCase _getDrawerTypesUseCase;

  StationEmptyCompartmentsReportNotifier({
    required GetStationsUseCase getStationsUseCase,
    required GetStationEmptyCompartmentsUseCase getStationEmptyCompartmentsUseCase,
    required GetStationEmptyCompartmentDetailsUseCase getStationEmptyCompartmentDetailsUseCase,
    required GetDrawerTypesUseCase getDrawerTypesUseCase,
  }) : _getStationsUseCase = getStationsUseCase,
       _getStationEmptyCompartmentsUseCase = getStationEmptyCompartmentsUseCase,
       _getStationEmptyCompartmentDetailsUseCase = getStationEmptyCompartmentDetailsUseCase,
       _getDrawerTypesUseCase = getDrawerTypesUseCase;

  OperationKey fetchStationsOp = OperationKey.fetch();
  OperationKey fetchReportOp = OperationKey.custom('fetch-station-empty-compartments');
  final OperationKey fetchDetailsOp = OperationKey.custom('fetch-station-empty-compartment-details');
  final OperationKey fetchDrawerTypesOp = OperationKey.custom('fetch-drawer-types');

  /// Rapordaki `drawerId` aslında çekmece tipi id'sidir (DrawerType.id).
  Map<int, DrawerType> _drawerTypesById = {};

  /// Çekmece tipinin okunur adı ("Kübik Çekmece" vb.); tip bulunamazsa servisteki kod.
  String? drawerLabel(StationEmptyCompartment item) =>
      _drawerTypesById[item.drawerId]?.displayName ?? item.drawerName;

  List<Station> _stations = [];
  List<Station> get stations => _stations;

  Set<int> _selectedStationIds = {};
  Set<int> get selectedStationIds => Set.unmodifiable(_selectedStationIds);

  List<TableSideCategory> get tableCategories => [
    ..._stations.map((s) => TableSideCategory(id: s.id.toString(), label: s.name ?? '-')),
  ];

  Set<String> get selectedCategoryIds => _selectedStationIds.map((id) => id.toString()).toSet();

  bool get isFetching => isLoading(fetchReportOp);

  StationEmptyCompartment? _detailItem;

  List<StationEmptyCompartmentDetail> _details = [];
  List<StationEmptyCompartmentDetail> get details => _details;

  bool get isFetchingDetails => isLoading(fetchDetailsOp);
  bool get isDetailsFailed => isFailed(fetchDetailsOp);

  /// Ekran açılışı: çekmece tipleri (cache'li) ve istasyonlar paralel yüklenir.
  Future<void> init() async {
    await Future.wait([_getDrawerTypes(), getStations()]);
  }

  Future<void> _getDrawerTypes() async {
    await execute(
      fetchDrawerTypesOp,
      operation: () => _getDrawerTypesUseCase.call(),
      onData: (types) {
        _drawerTypesById = {for (final t in types) if (t.id != null) t.id!: t};
        notifyListeners();
      },
    );
  }

  Future<void> getStations() async {
    await execute(
      fetchStationsOp,
      operation: () => _getStationsUseCase.call(PagedQueryParams()),
      onData: (response) {
        _stations = response.data ?? [];
        notifyListeners();
        _refetchFromFirstPage();
      },
    );
  }

  void onCategorySelectionChanged(Set<String> ids) {
    final next = ids.map(int.tryParse).whereType<int>().toSet();
    if (setEquals(next, _selectedStationIds)) return;
    _selectedStationIds = next;
    notifyListeners();
    _refetchFromFirstPage();
  }

  /// Filtre değişimi sayfa navigasyonu değildir: sayfayı koşulsuz 1'e çek
  /// ve her durumda yeniden sorgula.
  void _refetchFromFirstPage() {
    resetPage();
    fetch();
  }

  List<Object>? get _filters {
    if (_selectedStationIds.isEmpty) return null;
    return [Filter.inList('stationId', _selectedStationIds.toList())];
  }

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      op: fetchReportOp,
      fetchMethod: (skip, take) => _getStationEmptyCompartmentsUseCase.call(
        PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery, filters: _filters),
      ),
    );
  }

  // ── Detay (boş gözler) ────────────────────────────────────────────────────

  /// Detay dialog'u açılırken çağrılır. Boş göz yoksa istek atılmaz.
  void openDetail(StationEmptyCompartment item) {
    _detailItem = item;
    _details = [];
    notifyListeners();
    if (_canFetchDetails(item)) _fetchDetails(item);
  }

  void retryDetails() {
    final item = _detailItem;
    if (item != null && _canFetchDetails(item)) _fetchDetails(item);
  }

  /// Dialog kapanınca çağrılır.
  void closeDetail() {
    _detailItem = null;
    _details = [];
    notifyListeners();
  }

  bool _canFetchDetails(StationEmptyCompartment item) => item.cabinDesignId != null && (item.emptyCount ?? 0) > 0;

  Future<void> _fetchDetails(StationEmptyCompartment item) async {
    await execute(
      fetchDetailsOp,
      operation: () => _getStationEmptyCompartmentDetailsUseCase.call(item.cabinDesignId!),
      onData: (details) {
        // Dialog kapanmış veya başka bir kayda geçilmişse eski yanıtı yok say.
        if (_detailItem?.cabinDesignId != item.cabinDesignId) return;
        _details = [...details]
          ..sort((a, b) {
            final byCompartment = (a.compartmentNo ?? 0).compareTo(b.compartmentNo ?? 0);
            return byCompartment != 0 ? byCompartment : (a.orderNo ?? 0).compareTo(b.orderNo ?? 0);
          });
        notifyListeners();
      },
    );
  }
}
