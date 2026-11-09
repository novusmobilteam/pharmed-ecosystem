import 'package:flutter/widgets.dart';
import 'package:pharmed_manager/core/core.dart';

/// SKT Malzeme Listesi raporu (`Report/remainingMiadDate/{stationId}`).
///
/// SKT'si Geçmiş Malzemeler raporunun (ExpiredItemsReportNotifier) ikizi:
/// tek istasyon seçilir, tarih filtresi `miadDate` alanına uygulanır.
class ExpiryDateMaterialsReportNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<CabinStock> {
  final GetExpiryDateStocksUseCase _getExpiryDateStocksUseCase;
  final GetStationsUseCase _getStationsUseCase;

  ExpiryDateMaterialsReportNotifier({
    required GetExpiryDateStocksUseCase getExpiryDateStocksUseCase,
    required GetStationsUseCase getStationsUseCase,
  }) : _getExpiryDateStocksUseCase = getExpiryDateStocksUseCase,
       _getStationsUseCase = getStationsUseCase;

  OperationKey fetchStationsOp = OperationKey.fetch();
  OperationKey fetchReportOp = OperationKey.custom('fetch-expiry-date-materials');

  List<Station> _stations = [];
  List<Station> get stations => _stations;

  Station? _selectedStation;
  Station? get selectedStation => _selectedStation;

  List<TableSideCategory> get tableCategories => [
    ..._stations.map((s) => TableSideCategory(id: s.id.toString(), label: s.name ?? '-')),
  ];

  String get selectedCategoryId => _selectedStation?.id.toString() ?? '-1';

  bool get isFetching => isLoading(fetchReportOp);

  Future<void> getStations() async {
    await execute(
      fetchStationsOp,
      operation: () => _getStationsUseCase.call(PagedQueryParams()),
      onData: (response) {
        _stations = response.data ?? [];
        notifyListeners();
        if (_stations.isNotEmpty) selectStation(_stations.first);
      },
    );
  }

  void selectStation(Station station) {
    if (_selectedStation?.id == station.id && items.isNotEmpty) return;
    _selectedStation = station;
    resetPage();
    notifyListeners();
    fetch();
  }

  @override
  Future<void> fetch() async {
    final stationId = _selectedStation?.id;
    if (stationId == null) return;
    await fetchPagedData(
      op: fetchReportOp,
      fetchMethod: (skip, take) => _getExpiryDateStocksUseCase.call(
        stationId: stationId,
        PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery, startDate: startDate, endDate: endDate),
      ),
    );
  }
}
