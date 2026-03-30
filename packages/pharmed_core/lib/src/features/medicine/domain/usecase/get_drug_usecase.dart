// [SWREQ-CORE-MEDICINE-UC-003]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class GetDrugUseCase {
  final IMedicineRepository _repository;

  GetDrugUseCase(this._repository);

  Future<Result<Drug?>> call(int id) {
    return _repository.getDrug(id);
  }
}
