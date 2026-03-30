// [SWREQ-CORE-DRUGTYPE-UC-003]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class UpdateDrugTypeUseCase {
  final IDrugTypeRepository _repository;

  UpdateDrugTypeUseCase(this._repository);

  Future<Result<void>> call(DrugType entity) {
    return _repository.updateDrugType(entity);
  }
}
