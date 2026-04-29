import 'package:pharmed_core/pharmed_core.dart';

class DeleteUnscannedBarcodeUseCase {
  final IPrescriptionRepository _repository;

  DeleteUnscannedBarcodeUseCase(this._repository);

  Future<Result<void>> call(int prescriptionItemId, String description) {
    return _repository.deleteUnscannedBarcode(prescriptionItemId: prescriptionItemId, description: description);
  }
}
