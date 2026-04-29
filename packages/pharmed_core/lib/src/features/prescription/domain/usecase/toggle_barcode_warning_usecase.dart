import 'package:pharmed_core/pharmed_core.dart';

class ToggleBarcodeWarningUseCase {
  final IPrescriptionRepository _repository;

  ToggleBarcodeWarningUseCase(this._repository);

  Future<Result<void>> call(int prescriptionItemId) {
    return _repository.toggleWarning(prescriptionItemId);
  }
}
