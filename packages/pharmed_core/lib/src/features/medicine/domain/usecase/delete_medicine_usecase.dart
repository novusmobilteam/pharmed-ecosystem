// [SWREQ-CORE-MEDICINE-UC-002]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class DeleteMedicineUseCase {
  final IMedicineRepository _repository;

  DeleteMedicineUseCase(this._repository);

  Future<Result<void>> call(Medicine medicine) {
    return _repository.deleteMedicine(medicine);
  }
}
