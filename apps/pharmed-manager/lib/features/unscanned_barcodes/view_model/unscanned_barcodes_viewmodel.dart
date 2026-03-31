import 'package:flutter/widgets.dart';
import 'package:pharmed_manager/core/core.dart';

class UnscannedBarcodesViewModel extends ChangeNotifier
    with ApiRequestMixin, SearchMixin<PrescriptionItem>, DateFilterMixin<PrescriptionItem> {
  final IPrescriptionRepository _prescriptionRepository;

  UnscannedBarcodesViewModel({required IPrescriptionRepository prescriptionRepository})
    : _prescriptionRepository = prescriptionRepository;

  // Operation Keys
  static const fetchBarcodesOperation = OperationKey.fetch();
  static const scanBarcodeOperation = OperationKey.custom('scan-barcode');
  static const delete = OperationKey.delete();
  static const toggleWarningOperation = OperationKey.custom('toggle-warning');

  // Operation status getter'ları
  bool get isFetchingBarcodes => isLoading(fetchBarcodesOperation);
  bool get isScaning => isLoading(scanBarcodeOperation);
  bool get isDeleting => isLoading(delete);

  // Variables
  PrescriptionItem? _selectedItem;

  // Silme gerekçesi
  String _deleteDescription = '';

  // Okutulan karekod
  String? _barcode;

  // Getters

  PrescriptionItem? get selectedItem => _selectedItem;
  bool get canOpenWarning => _selectedItem != null;
  String get deleteDescription => _deleteDescription;
  String? get barcode => _barcode;

  List<PrescriptionItem> get dateFilteredItems {
    return applyDateFilter(filteredItems);
  }

  @override
  DateTime? getDateField(PrescriptionItem item) => item.approvalDate;

  Future<void> fetchBarcodes() async {
    await execute(
      fetchBarcodesOperation,
      operation: () => _prescriptionRepository.getUnscannedBarcodes(),
      onData: (apiResponse) {
        if (apiResponse?.data != null) {
          allItems = apiResponse?.data ?? [];
        }
      },
    );
  }

  Future<void> scanBarcode(PrescriptionItem item) async {
    final id = item.id ?? 0;
    await executeVoid(
      scanBarcodeOperation,
      operation: () => _prescriptionRepository.scanBarcode(prescriptionItemId: id, qrCode: _barcode ?? ''),
      onSuccess: () => fetchBarcodes(),
    );
  }

  Future<void> deleteBarcode(PrescriptionItem item) async {
    final id = item.id ?? 0;
    await executeVoid(
      delete,
      operation: () =>
          _prescriptionRepository.deleteUnscannedBarcode(prescriptionItemId: id, description: _deleteDescription),
      onSuccess: () => fetchBarcodes(),
    );
  }

  Future<void> toggleWarning() async {
    final id = _selectedItem?.id ?? 0;
    await executeVoid(
      toggleWarningOperation,
      operation: () => _prescriptionRepository.toggleWarning(id),
      onSuccess: () => fetchBarcodes(),
    );
  }

  set selectedItem(PrescriptionItem? value) {
    _selectedItem = value;
    notifyListeners();
  }

  set deleteDescription(String value) {
    _deleteDescription = value;
    notifyListeners();
  }

  set barcode(String? value) {
    _barcode = value;
    notifyListeners();
  }
}
