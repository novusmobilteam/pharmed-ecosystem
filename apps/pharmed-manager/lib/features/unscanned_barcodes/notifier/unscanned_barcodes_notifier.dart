import 'package:flutter/widgets.dart';
import 'package:pharmed_manager/core/core.dart';

class UnscannedBarcodesNotifier extends ChangeNotifier
    with ApiRequestMixin, SearchMixin<PrescriptionItem>, DateFilterMixin<PrescriptionItem> {
  final GetUnscannedBarcodesUseCase _getUnscannedBarcodesUseCase;
  final GetScannedBarcodesUseCase _getScannedBarcodesUseCase;
  final GetDeletedBarcodesUseCase _getDeletedBarcodesUseCase;
  final DeleteUnscannedBarcodeUseCase _deleteUnscannedBarcodeUseCase;
  final ScanBarcodeUseCase _scanBarcodeUseCase;
  final ToggleBarcodeWarningUseCase _toggleBarcodeWarningUseCase;

  UnscannedBarcodesNotifier({
    required GetUnscannedBarcodesUseCase getUnscannedBarcodesUseCase,
    required GetScannedBarcodesUseCase getScannedBarcodesUseCase,
    required GetDeletedBarcodesUseCase getDeletedBarcodesUseCase,
    required DeleteUnscannedBarcodeUseCase deleteUnscannedBarcodeUseCase,

    required ScanBarcodeUseCase scanBarcodeUseCase,
    required ToggleBarcodeWarningUseCase toggleBarcodeWarningUseCase,
  }) : _deleteUnscannedBarcodeUseCase = deleteUnscannedBarcodeUseCase,
       _getUnscannedBarcodesUseCase = getUnscannedBarcodesUseCase,
       _getScannedBarcodesUseCase = getScannedBarcodesUseCase,
       _getDeletedBarcodesUseCase = getDeletedBarcodesUseCase,
       _scanBarcodeUseCase = scanBarcodeUseCase,
       _toggleBarcodeWarningUseCase = toggleBarcodeWarningUseCase;

  // Operation Keys
  OperationKey fetchOp = OperationKey.custom('fetch');
  OperationKey fetchScannedOp = OperationKey.custom('fetch-scanned');
  OperationKey fetchDeletedOp = OperationKey.custom('fetch-deleted');
  OperationKey scanOp = OperationKey.custom('scan-barcode');
  OperationKey deleteOp = OperationKey.delete();
  OperationKey toggleOp = OperationKey.custom('toggle-warning');

  // Operation status getter'ları
  bool get isFetching => isLoading(fetchOp);
  bool get isScaning => isLoading(scanOp);
  bool get isDeleting => isLoading(deleteOp);

  bool get canOpenWarning => _selectedItem != null;

  List<PrescriptionItem> get dateFilteredItems {
    return applyDateFilter(filteredItems);
  }

  PrescriptionItem? _selectedItem;
  PrescriptionItem? get selectedItem => _selectedItem;

  List<PrescriptionItem> _scannedBarcodes = [];
  List<PrescriptionItem> get scannedBarcodes => _scannedBarcodes;

  List<PrescriptionItem> _deletedBarcodes = [];
  List<PrescriptionItem> get deletedBarcodes => _deletedBarcodes;

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

  @override
  DateTime? getDateField(PrescriptionItem item) => item.approvalDate;

  Future<void> getUnscannedBarcodes() async {
    await execute(
      fetchOp,
      operation: () => _getUnscannedBarcodesUseCase.call(),
      onData: (apiResponse) {
        if (apiResponse?.data != null) {
          allItems = apiResponse?.data ?? [];
        }
      },
    );
  }

  Future<void> getScannedBarcodes() async {
    await execute(
      fetchOp,
      operation: () => _getScannedBarcodesUseCase.call(),
      onData: (apiResponse) {
        if (apiResponse?.data != null) {
          _scannedBarcodes = apiResponse?.data ?? [];
        }
      },
    );
  }

  Future<void> getDeletedBarcodes() async {
    await execute(
      fetchOp,
      operation: () => _getDeletedBarcodesUseCase.call(),
      onData: (apiResponse) {
        if (apiResponse?.data != null) {
          _deletedBarcodes = apiResponse?.data ?? [];
        }
      },
    );
  }

  Future<void> scanBarcode(
    PrescriptionItem item, {
    Function(String? msg)? onFailed,
    Function(String? msg)? onSuccess,
  }) async {
    final id = item.id ?? 0;
    await executeVoid(
      scanOp,
      operation: () => _scanBarcodeUseCase.call(id, _barcode ?? ''),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        getUnscannedBarcodes();
        onSuccess?.call('İşleminiz başarıyla tamamlandı..');
      },
    );
  }

  Future<void> deleteBarcode(
    PrescriptionItem item, {
    Function(String? msg)? onFailed,
    Function(String? msg)? onSuccess,
  }) async {
    final id = item.id ?? 0;
    await executeVoid(
      deleteOp,
      operation: () => _deleteUnscannedBarcodeUseCase.call(id, _deleteDescription),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        getUnscannedBarcodes();
        onSuccess?.call('İşleminiz başarıyla tamamlandı..');
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
        getUnscannedBarcodes();
        onSuccess?.call('İşleminiz başarıyla tamamlandı..');
      },
    );
  }
}
