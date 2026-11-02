import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

/// İstasyon Hareket Listesi. Sayfalama yerine sonsuz kaydırma kullanır
/// (InfiniteScrollMixin); tarih filtresi saatlidir.
class StationTransactionReportNotifier extends ChangeNotifier
    with ApiRequestMixin, InfiniteScrollMixin<StationTransaction> {
  final GetStationsUseCase _getStationsUseCase;
  final GetStationTransactionsUseCase _getStationTransactionsUseCase;
  final GetTransactionStepsUseCase _getTransactionStepsUseCase;

  StationTransactionReportNotifier({
    required GetStationsUseCase getStationsUseCase,
    required GetStationTransactionsUseCase getStationTransactionsUseCase,
    required GetTransactionStepsUseCase getTransactionStepsUseCase,
  }) : _getStationsUseCase = getStationsUseCase,
       _getStationTransactionsUseCase = getStationTransactionsUseCase,
       _getTransactionStepsUseCase = getTransactionStepsUseCase {
    // Varsayılan: bugün 00:00 – 23:59:59.
    final now = DateTime.now();
    initDateRange(
      DateTimeRange(
        start: DateTime(now.year, now.month, now.day),
        end: DateTime(now.year, now.month, now.day, 23, 59, 59),
      ),
    );
  }

  OperationKey fetchStationsOp = OperationKey.custom('fetch-stations');
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

  bool get isFetching => isFirstPageLoading;

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
        notifyListeners();
        reload();
      },
    );
  }

  void onCategorySelectionChanged(Set<String> ids) {
    final next = ids.map(int.tryParse).whereType<int>().toSet();
    if (setEquals(next, _selectedStationIds)) return;
    _selectedStationIds = next;
    notifyListeners();
    reload();
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
    reload();
  }

  @override
  Future<Result<ApiResponse<List<StationTransaction>>?>> fetchPage(int skip, int take) {
    return _getStationTransactionsUseCase.call(
      PagedQueryParams(
        skip: skip,
        take: take,
        searchQuery: searchQuery,
        startDate: startDate,
        endDate: endDate,
        filters: _filters,
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
