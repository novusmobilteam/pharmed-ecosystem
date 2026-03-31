// [SWREQ-CORE-DRUGTYPE-UC-003]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class CreateDrugTypeUseCase {
  final IDrugTypeRepository _repository;

  CreateDrugTypeUseCase(this._repository);

  Future<Result<void>> call(DrugType entity) {
    return _repository.createDrugType(entity);
  }
}
