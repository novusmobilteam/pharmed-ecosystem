import '../../../../core/core.dart';

import '../entity/prescription_item.dart';
import '../repository/i_prescription_repository.dart';

class UpdatePrescriptionItemUseCase implements UseCase<void, PrescriptionItem> {
  final IPrescriptionRepository _repository;

  UpdatePrescriptionItemUseCase(this._repository);

  @override
  Future<Result<void>> call(PrescriptionItem item) {
    return _repository.updatePrescriptionItem(item);
  }
}
