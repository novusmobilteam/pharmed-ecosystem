import 'package:pharmed_core/pharmed_core.dart';

class GetPrescriptionDetailUseCase {
  final IPrescriptionRepository _repository;

  GetPrescriptionDetailUseCase(this._repository);

  Future<Result<List<PrescriptionItem>>> call(int prescriptionId) {
    return _repository.getPrescriptionDetail(prescriptionId);
  }
}
