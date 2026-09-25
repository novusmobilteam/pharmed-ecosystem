import 'package:flutter/foundation.dart';
import 'package:pharmed_manager/core/core.dart';

class StationTransactionReportNotifier extends ChangeNotifier
    with ApiRequestMixin, PaginationMixin<StationTransaction> {
  final GetStationsUseCase _getStationsUseCase;
  final GetStationTransactionsUseCase _getStationTransactionsUseCase;
  final GetTransactionStepsUseCase _getTransactionStepsUseCase;

  StationTransactionReportNotifier({
    required GetStationsUseCase getStationsUseCase,
    required GetStationTransactionsUseCase getStationTransactionsUseCase,
    required GetTransactionStepsUseCase getTransactionStepsUseCase,
  }) : _getStationsUseCase = getStationsUseCase,
       _getStationTransactionsUseCase = getStationTransactionsUseCase,
       _getTransactionStepsUseCase = getTransactionStepsUseCase;

  OperationKey fetchStationsOp = OperationKey.fetch();
  OperationKey fetchReportsOp = OperationKey.fetch();
  final OperationKey fetchStepsOp = OperationKey.custom('fetch-transaction-steps');

  List<Station> _stations = [];
  List<Station> get stations => _stations;

  Station? _selectedStation;
  Station? get selectedStation => _selectedStation;

  Set<int> _selectedStationIds = {};
  Set<int> get selectedStationIds => Set.unmodifiable(_selectedStationIds);

  List<TableSideCategory> get tableCategories => [
    ..._stations.map((s) => TableSideCategory(id: s.id.toString(), label: s.name ?? '-')),
  ];

  Set<String> get selectedCategoryIds => _selectedStationIds.map((id) => id.toString()).toSet();

  bool get isFetching => isLoading(fetchReportsOp);
  String? get statusMessage => message(fetchReportsOp);

  Map<String, Set<Object>> _serverFilters = {};
  Map<String, Set<Object>> get serverFilters => _serverFilters;

  StationTransaction? _detailItem;

  List<StationTransactionStep> _detailSteps = [];
  List<StationTransactionStep> get detailSteps => _detailSteps;

  bool get isFetchingSteps => isLoading(fetchStepsOp);
  bool get isStepsFailed => isFailed(fetchStepsOp);

  Future<void> getStations() async {
    await execute(
      fetchStationsOp,
      operation: () => _getStationsUseCase.call(PagedQueryParams()),
      onData: (response) {
        _stations = response.data ?? [];
        //_selectedStationIds = {if (_stations.isNotEmpty && _stations.first.id != null) _stations.first.id!};
        _reloadFromFirstPage();
        notifyListeners();
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
    resetPage(); // mixin'de sayfa numarasını fetch tetiklemeden 1'e çeken metot
    fetch();
  }

  /// Filtre değişince sayfa 1'e dönmeli; yoksa 3. sayfadayken
  /// daha az kayıtlı bir filtreye geçildiğinde boş sayfa gelir.
  void _reloadFromFirstPage() {
    // PaginationMixin'deki sayfa sıfırlama metodu neyse onu kullan
    // (örn. goToPage(1) zaten fetch tetikliyorsa sadece o yeterli).
    setPage(1);
  }

  List<Object>? get _filters {
    final clauses = <Object>[
      if (_selectedStationIds.isNotEmpty) Filter.inList('stationId', _selectedStationIds.toList()),
      for (final e in _serverFilters.entries)
        if (e.value.isNotEmpty) Filter.inList(e.key, e.value.toList()),
    ];
    return clauses.isEmpty ? null : clauses;
  }

  void onServerFiltersChanged(Map<String, Set<Object>> filters) {
    _serverFilters = filters;
    notifyListeners();
    _refetchFromFirstPage();
  }

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      op: fetchReportsOp,
      fetchMethod: (skip, take) => _getStationTransactionsUseCase.call(
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

  /// Detay dialog'u açılırken çağrılır. hasSteps false ise istek atılmaz.
  void openDetail(StationTransaction item) {
    _detailItem = item;
    _detailSteps = [];
    notifyListeners();
    if (item.hasSteps == true && item.id != null) _fetchSteps(item);
  }

  void retrySteps() {
    final item = _detailItem;
    if (item != null && item.hasSteps == true && item.id != null) _fetchSteps(item);
  }

  /// Dialog kapanınca çağrılır.
  void closeDetail() {
    _detailItem = null;
    _detailSteps = [];
    notifyListeners();
  }

  Future<void> _fetchSteps(StationTransaction item) async {
    await execute(
      fetchStepsOp,
      operation: () => _getTransactionStepsUseCase.call(item.id!),
      onData: (steps) {
        // Dialog kapanmış veya başka bir kayda geçilmişse eski yanıtı yok say.
        if (_detailItem?.id != item.id) return;
        _detailSteps = [...steps]..sort((a, b) => (a.stepNo ?? 0).compareTo(b.stepNo ?? 0));
        notifyListeners();
      },
    );
  }
}
