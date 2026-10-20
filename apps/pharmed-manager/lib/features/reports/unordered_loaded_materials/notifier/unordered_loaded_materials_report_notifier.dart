import 'package:flutter/foundation.dart';
import 'package:pharmed_manager/core/core.dart';

/// Order Edilmemiş / Yüklü Malzeme raporu.
///
/// İstasyon seçimi çoklu yapılır (İstasyon Hareketleri raporuyla aynı kalıp);
/// hiçbir istasyon seçili değilse tüm istasyonlar listelenir.
class UnorderedLoadedMaterialsReportNotifier extends ChangeNotifier
    with ApiRequestMixin, PaginationMixin<UnorderedLoadedMaterial> {
  final GetStationsUseCase _getStationsUseCase;
  final GetUnorderedLoadedMaterialsUseCase _getUnorderedLoadedMaterialsUseCase;

  UnorderedLoadedMaterialsReportNotifier({
    required GetStationsUseCase getStationsUseCase,
    required GetUnorderedLoadedMaterialsUseCase getUnorderedLoadedMaterialsUseCase,
  }) : _getStationsUseCase = getStationsUseCase,
       _getUnorderedLoadedMaterialsUseCase = getUnorderedLoadedMaterialsUseCase;

  OperationKey fetchStationsOp = OperationKey.fetch();
  OperationKey fetchReportOp = OperationKey.custom('fetch-unordered-loaded-materials');

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
      fetchMethod: (skip, take) => _getUnorderedLoadedMaterialsUseCase.call(
        PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery, filters: _filters),
      ),
    );
  }
}
