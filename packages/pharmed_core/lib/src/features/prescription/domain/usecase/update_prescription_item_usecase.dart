import 'package:pharmed_core/pharmed_core.dart';

class UpdatePrescriptionItemUseCase {
  final IPrescriptionRepository _repository;

  UpdatePrescriptionItemUseCase(this._repository);

  Future<Result<void>> call(PrescriptionItem item) {
    return _repository.updatePrescriptionItem(item);
  }
}
