import 'package:pharmed_core/pharmed_core.dart';

class ScanBarcodeUseCase {
  final IPrescriptionRepository _repository;

  ScanBarcodeUseCase(this._repository);

  Future<Result<void>> call(int prescriptionItemId, String qrCode) {
    return _repository.scanBarcode(prescriptionItemId: prescriptionItemId, qrCode: qrCode);
  }
}
