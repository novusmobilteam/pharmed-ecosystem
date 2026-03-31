// [SWREQ-CORE-MEDICINE-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class CreateMedicineUseCase {
  final IMedicineRepository _repository;

  CreateMedicineUseCase(this._repository);

  Future<Result<void>> call(Medicine medicine) {
    return _repository.createMedicine(medicine);
  }
}
