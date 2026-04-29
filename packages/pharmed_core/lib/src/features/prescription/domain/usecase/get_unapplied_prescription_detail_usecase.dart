import 'package:pharmed_core/pharmed_core.dart';

class GetUnappliedPrescriptionDetailUseCase {
  final IPrescriptionRepository _repository;

  GetUnappliedPrescriptionDetailUseCase(this._repository);

  Future<Result<List<PrescriptionItem>>> call(int prescriptionId) {
    return _repository.getUnappliedPrescriptionDetail(prescriptionId);
  }
}
