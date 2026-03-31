// [SWREQ-CORE-MEDICINE-UC-007]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class UpdateMedicineUseCase {
  final IMedicineRepository _repository;

  UpdateMedicineUseCase(this._repository);

  Future<Result<void>> call(Medicine medicine) {
    return _repository.updateMedicine(medicine);
  }
}
