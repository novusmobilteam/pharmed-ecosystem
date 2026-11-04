import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

/// Yetki Kırım raporu — ordersız ve serbest erişimle yapılan alımlar.
///
/// Tek istasyon seçilir (Malzeme Kullanım raporuyla aynı kalıp); istasyon ve
/// tarih aralığı servise query parametresi olarak gider.
class AuthorizationBreakdownReportNotifier extends ChangeNotifier
    with ApiRequestMixin, PaginationMixin<AuthorizationBreakdown> {
  final GetStationsUseCase _getStationsUseCase;
  final GetAuthorizationBreakdownsUseCase _getAuthorizationBreakdownsUseCase;

  AuthorizationBreakdownReportNotifier({
    required GetStationsUseCase getStationsUseCase,
    required GetAuthorizationBreakdownsUseCase getAuthorizationBreakdownsUseCase,
  }) : _getStationsUseCase = getStationsUseCase,
       _getAuthorizationBreakdownsUseCase = getAuthorizationBreakdownsUseCase;

  OperationKey fetchStationsOp = OperationKey.fetch();
  OperationKey fetchReportOp = OperationKey.custom('fetch-authorization-breakdowns');

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
    notifyListeners();
    // Tablo varsayılan aralığı (dateRange) gösterir; ilk sorgu da aynı
    // aralıkla gitsin diye aralık açıkça set edilir (setDateRange fetch tetikler).
    if (startDate == null && endDate == null) {
      setDateRange(dateRange);
    } else {
      resetPage();
      fetch();
    }
  }

  @override
  Future<void> fetch() async {
    final stationId = _selectedStation?.id;
    if (stationId == null) return;
    await fetchPagedData(
      op: fetchReportOp,
      fetchMethod: (skip, take) => _getAuthorizationBreakdownsUseCase.call(
        stationId: stationId,
        PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery, startDate: startDate, endDate: endDate),
      ),
    );
  }
}
