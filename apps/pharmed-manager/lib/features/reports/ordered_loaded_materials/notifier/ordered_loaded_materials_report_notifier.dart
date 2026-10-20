import 'package:flutter/foundation.dart';
import 'package:pharmed_manager/core/core.dart';

/// Order Edilmiş / Yüklü Malzeme raporu.
///
/// İstasyon seçimi çoklu yapılır (İstasyon Hareketleri raporuyla aynı kalıp);
/// hiçbir istasyon seçili değilse tüm istasyonlar listelenir.
/// Tarih aralığı servise `startDate` / `endDate` query parametreleriyle gönderilir.
class OrderedLoadedMaterialsReportNotifier extends ChangeNotifier
    with ApiRequestMixin, PaginationMixin<OrderedLoadedMaterial> {
  final GetStationsUseCase _getStationsUseCase;
  final GetOrderedLoadedMaterialsUseCase _getOrderedLoadedMaterialsUseCase;

  OrderedLoadedMaterialsReportNotifier({
    required GetStationsUseCase getStationsUseCase,
    required GetOrderedLoadedMaterialsUseCase getOrderedLoadedMaterialsUseCase,
  }) : _getStationsUseCase = getStationsUseCase,
       _getOrderedLoadedMaterialsUseCase = getOrderedLoadedMaterialsUseCase;

  OperationKey fetchStationsOp = OperationKey.fetch();
  OperationKey fetchReportOp = OperationKey.custom('fetch-ordered-loaded-materials');

  List<Station> _stations = [];
  List<Station> get stations => _stations;

  Set<int> _selectedStationIds = {};
  Set<int> get selectedStationIds => Set.unmodifiable(_selectedStationIds);

  List<TableSideCategory> get tableCategories => [
    ..._stations.map((s) => TableSideCategory(id: s.id.toString(), label: s.name ?? '-')),
  ];

  Set<String> get selectedCategoryIds => _selectedStationIds.map((id) => id.toString()).toSet();

  bool get isFetching => isLoading(fetchReportOp);

  Future<void> getStations() async {
    await execute(
      fetchStationsOp,
      operation: () => _getStationsUseCase.call(PagedQueryParams()),
      onData: (response) {
        _stations = response.data ?? [];
        notifyListeners();
        // Tablo varsayılan aralığı (dateRange) gösterir; ilk sorgunun da aynı
        // aralıkla gitmesi için aralık açıkça set edilir (setDateRange fetch tetikler).
        if (startDate == null && endDate == null) {
          setDateRange(dateRange);
        } else {
          _refetchFromFirstPage();
        }
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
      fetchMethod: (skip, take) => _getOrderedLoadedMaterialsUseCase.call(
        PagedQueryParams(
          skip: skip,
          take: take,
          searchQuery: searchQuery,
          startDate: startDate,
          endDate: endDate,
          filters: _filters,
        ),
      ),
    );
  }
}
