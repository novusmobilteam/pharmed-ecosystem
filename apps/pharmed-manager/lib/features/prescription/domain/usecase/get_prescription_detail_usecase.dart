import '../../../../core/core.dart';

import '../entity/prescription_item.dart';
import '../repository/i_prescription_repository.dart';

class GetPrescriptionDetailUseCase implements UseCase<List<PrescriptionItem>, int> {
  final IPrescriptionRepository _repository;

  GetPrescriptionDetailUseCase(this._repository);

  @override
  Future<Result<List<PrescriptionItem>>> call(int prescriptionId) {
    return _repository.getPrescriptionDetail(prescriptionId);
  }
}
