import 'package:flutter/widgets.dart';
import 'package:pharmed_manager/core/core.dart';

enum BarcodeListMode { unscanned, scanned, deleted }

class UnscannedBarcodesNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<PrescriptionItem> {
  final GetUnscannedBarcodesWithStationIdUseCase _getUnscannedBarcodesUseCase;
  final GetStationsUseCase _getStationsUseCase;
  final GetScannedBarcodesUseCase _getScannedBarcodesUseCase;
  final GetDeletedBarcodesUseCase _getDeletedBarcodesUseCase;
  final DeleteUnscannedBarcodeUseCase _deleteUnscannedBarcodeUseCase;
  final ScanBarcodeUseCase _scanBarcodeUseCase;
  final ToggleBarcodeWarningUseCase _toggleBarcodeWarningUseCase;

  UnscannedBarcodesNotifier({
    required GetUnscannedBarcodesWithStationIdUseCase getUnscannedBarcodesUseCase,
    required GetStationsUseCase getStationsUseCase,
    required GetScannedBarcodesUseCase getScannedBarcodesUseCase,
    required GetDeletedBarcodesUseCase getDeletedBarcodesUseCase,
    required DeleteUnscannedBarcodeUseCase deleteUnscannedBarcodeUseCase,

    required ScanBarcodeUseCase scanBarcodeUseCase,
    required ToggleBarcodeWarningUseCase toggleBarcodeWarningUseCase,
  }) : _deleteUnscannedBarcodeUseCase = deleteUnscannedBarcodeUseCase,
       _getStationsUseCase = getStationsUseCase,
       _getUnscannedBarcodesUseCase = getUnscannedBarcodesUseCase,
       _getScannedBarcodesUseCase = getScannedBarcodesUseCase,
       _getDeletedBarcodesUseCase = getDeletedBarcodesUseCase,
       _scanBarcodeUseCase = scanBarcodeUseCase,
       _toggleBarcodeWarningUseCase = toggleBarcodeWarningUseCase;

  BarcodeListMode _mode = BarcodeListMode.unscanned;
  BarcodeListMode get mode => _mode;

  // Operation Keys
  final OperationKey fetchOp = OperationKey.custom('fetch-unscanned');
  final OperationKey fetchStationsOp = OperationKey.custom('fetch-stations');
  final OperationKey scanOp = OperationKey.custom('scan-barcode');
  final OperationKey deleteOp = OperationKey.delete();
  final OperationKey toggleOp = OperationKey.custom('toggle-warning');

  // Operation status getter'ları
  bool get isFetching => isLoading(fetchOp);
  bool get isScaning => isLoading(scanOp);
  bool get isDeleting => isLoading(deleteOp);

  bool get canOpenWarning => _selectedItem != null;
  bool get canSelectItem => mode == BarcodeListMode.unscanned;

  PrescriptionItem? _selectedItem;
  PrescriptionItem? get selectedItem => _selectedItem;

  List<PrescriptionItem> _scannedBarcodes = [];
  List<PrescriptionItem> get scannedBarcodes => _scannedBarcodes;

  List<Station> _stations = [];
  List<Station> get stations => _stations;

  Station? _selectedStation;
  Station? get selectedStation => _selectedStation;

  List<PrescriptionItem> _deletedBarcodes = [];
  List<PrescriptionItem> get deletedBarcodes => _deletedBarcodes;

  List<TableSideCategory> get tableCategories => [
    ..._stations.map((s) => TableSideCategory(id: s.id.toString(), label: s.name ?? '-')),
  ];

  String get selectedCategoryId => _selectedStation?.id.toString() ?? '-1';
  int get activeIndex => !stations.contains(_selectedStation) ? 0 : stations.indexOf(_selectedStation!);

  set selectedItem(PrescriptionItem? value) {
    _selectedItem = value;
    notifyListeners();
  }

  String _deleteDescription = '';
  String get deleteDescription => _deleteDescription;

  set deleteDescription(String value) {
    _deleteDescription = value;
    notifyListeners();
  }

  String? _barcode;
  String? get barcode => _barcode;

  set barcode(String? value) {
    _barcode = value;
    notifyListeners();
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

  Future<void> cycleBarcodeListMode() async {
    _mode = switch (_mode) {
      BarcodeListMode.unscanned => BarcodeListMode.scanned,
      BarcodeListMode.scanned => BarcodeListMode.deleted,
      BarcodeListMode.deleted => BarcodeListMode.unscanned,
    };
    notifyListeners();
    fetch();
  }

  @override
  Future<void> fetch() async {
    final stationId = _selectedStation?.id;
    if (stationId == null) return;

    switch (_mode) {
      case BarcodeListMode.unscanned:
        await fetchPagedData(
          op: fetchOp,
          fetchMethod: (skip, take) => _getUnscannedBarcodesUseCase.call(
            stationId: stationId,
            params: PagedQueryParams(
              skip: skip,
              take: take,
              searchQuery: searchQuery,
              startDate: startDate,
              endDate: endDate,
            ),
          ),
        );
      case BarcodeListMode.scanned:
        await fetchPagedData(
          op: fetchOp,
          fetchMethod: (skip, take) => _getScannedBarcodesUseCase.call(
            stationId: stationId,
            params: PagedQueryParams(
              skip: skip,
              take: take,
              searchQuery: searchQuery,
              startDate: startDate,
              endDate: endDate,
            ),
          ),
        );
        break;
      case BarcodeListMode.deleted:
        await fetchPagedData(
          op: fetchOp,
          fetchMethod: (skip, take) => _getDeletedBarcodesUseCase.call(
            stationId: stationId,
            params: PagedQueryParams(
              skip: skip,
              take: take,
              searchQuery: searchQuery,
              startDate: startDate,
              endDate: endDate,
            ),
          ),
        );
    }
  }

  Future<void> scanBarcode(PrescriptionItem item, {Function(String? msg)? onFailed, VoidCallback? onSuccess}) async {
    final id = item.id ?? 0;
    await executeVoid(
      scanOp,
      operation: () => _scanBarcodeUseCase.call(id, _barcode ?? ''),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        _mode = BarcodeListMode.unscanned;
        fetch();
        onSuccess?.call();
      },
    );
  }

  Future<void> deleteBarcode(PrescriptionItem item, {Function(String? msg)? onFailed, VoidCallback? onSuccess}) async {
    final id = item.id ?? 0;
    await executeVoid(
      deleteOp,
      operation: () => _deleteUnscannedBarcodeUseCase.call(id, _deleteDescription),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        _mode = BarcodeListMode.unscanned;
        fetch();
        onSuccess?.call();
      },
    );
  }

  Future<void> toggleWarning({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    final id = _selectedItem?.id ?? 0;
    await executeVoid(
      toggleOp,
      operation: () => _toggleBarcodeWarningUseCase.call(id),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        fetch();
        onSuccess?.call('İşleminiz başarıyla tamamlandı..');
      },
    );
  }
}
