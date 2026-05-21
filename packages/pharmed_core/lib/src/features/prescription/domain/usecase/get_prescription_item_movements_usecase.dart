import 'package:pharmed_core/pharmed_core.dart';

class GetPrescriptionItemMovementsUseCase {
  const GetPrescriptionItemMovementsUseCase(this._repository);

  final IPrescriptionRepository _repository;

  Future<Result<List<PrescriptionItemMovement>>> call(int prescriptionItemId) =>
      _repository.getPrescriptionItemMovements(prescriptionItemId);
}
