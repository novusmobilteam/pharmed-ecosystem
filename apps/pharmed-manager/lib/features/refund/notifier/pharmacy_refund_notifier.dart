import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class PharmacyRefundNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<Refund> {
  final GetStationsUseCase _getStationsUseCase;
  final GetPharmacyRefundsUseCase _getPharmacyRefundsUseCase;
  final GetCompletedPharmacyRefundsUseCase _getCompletedPharmacyRefundsUseCase;
  final CompletePharmacyRefundUseCase _completePharmacyRefundUseCase;
  final DeletePharmacyRefundUseCase _deletePharmacyRefundUseCase;

  PharmacyRefundNotifier({
    required GetStationsUseCase getStationsUseCase,
    required GetPharmacyRefundsUseCase getPharmacyRefundsUseCase,
    required GetCompletedPharmacyRefundsUseCase getCompletedPharmacyRefundsUseCase,
    required CompletePharmacyRefundUseCase completePharmacyRefundUseCase,
    required DeletePharmacyRefundUseCase deletePharmacyRefundUseCase,
  }) : _getStationsUseCase = getStationsUseCase,
       _getPharmacyRefundsUseCase = getPharmacyRefundsUseCase,
       _getCompletedPharmacyRefundsUseCase = getCompletedPharmacyRefundsUseCase,
       _completePharmacyRefundUseCase = completePharmacyRefundUseCase,
       _deletePharmacyRefundUseCase = deletePharmacyRefundUseCase;

  OperationKey fetchStationsOp = OperationKey.fetch();
  OperationKey fetchRefundsOp = OperationKey.fetch();
  OperationKey deleteOp = OperationKey.delete();
  OperationKey completeOp = OperationKey.create();

  List<Station> _stations = [];
  List<Station> get stations => _stations;

  Station? _selectedStation;
  Station? get selectedStation => _selectedStation;

  List<TableSideCategory> get tableCategories => [
    ..._stations.map((s) => TableSideCategory(id: s.id.toString(), label: s.name ?? '-')),
  ];

  String get selectedCategoryId => _selectedStation?.id.toString() ?? '-1';
  int get activeIndex => !stations.contains(_selectedStation) ? 0 : stations.indexOf(_selectedStation!);

  bool _showCompleted = false;
  bool get showCompleted => _showCompleted;

  bool get isFetching => isLoading(fetchRefundsOp);
  String? get statusMessage => message(fetchRefundsOp);

  String? _description;
  set description(String? value) {
    _description = value;
    notifyListeners();
  }

  @override
  Future<void> fetch() async {
    if (_showCompleted) {
      await fetchPagedData(
        fetchMethod: (skip, take) => _getCompletedPharmacyRefundsUseCase.call(
          stationId: _selectedStation?.id ?? 0,
          PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery, startDate: startDate, endDate: endDate),
        ),
      );
    } else {
      await fetchPagedData(
        fetchMethod: (skip, take) => _getPharmacyRefundsUseCase.call(
          stationId: _selectedStation?.id ?? 0,
          PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery, startDate: startDate, endDate: endDate),
        ),
      );
    }
  }

  Future<void> getStations() async {
    await execute(
      fetchStationsOp,
      operation: () => _getStationsUseCase.call(PagedQueryParams()),
      onData: (response) {
        final data = response.data ?? [];
        _stations = data;
        if (data.isNotEmpty) {
          selectStation(data.first);
        }
      },
    );
  }

  void selectStation(Station station) {
    _selectedStation = station;
    fetch();
    notifyListeners();
  }

  void deleteRefund(Refund refund, {Function(String?)? onSuccess, Function(String?)? onFailed}) async {
    final id = refund.id;
    if (id == null) {
      onFailed?.call('Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz');
      return;
    }
    await executeVoid(
      deleteOp,
      operation: () => _deletePharmacyRefundUseCase.call(DeletePharmacyRefundParams(id: id, description: _description)),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        onSuccess?.call('Silme işlemi başarıyla tamamlandı.');
        fetch();
      },
    );
  }

  void completeRefund(Refund refund, {Function(String?)? onSuccess, Function(String?)? onFailed}) async {
    final id = refund.id;
    if (id == null) {
      onFailed?.call('Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz');
      return;
    }
    await executeVoid(
      completeOp,
      operation: () => _completePharmacyRefundUseCase.call(id),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        onSuccess?.call('İade alma işlemi başarıyla tamamlandı.');
        fetch();
      },
    );
  }

  void toggleCompleted() {
    _showCompleted = !_showCompleted;
    resetFilters(notify: false, resetDate: false);
    notifyListeners();
    fetch();
  }
}
