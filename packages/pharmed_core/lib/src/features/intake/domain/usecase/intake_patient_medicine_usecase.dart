import 'package:pharmed_core/pharmed_core.dart';

class IntakePatientMedicineUseCase {
  final IIntakeRepository _repository;

  IntakePatientMedicineUseCase(this._repository);

  Future<Result<void>> call(int id) {
    return _repository.intakePatientMedicine(id: id);
  }
}
