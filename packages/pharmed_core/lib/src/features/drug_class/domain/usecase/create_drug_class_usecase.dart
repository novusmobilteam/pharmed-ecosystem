// [SWREQ-CORE-DRUGCLASS-UC-002]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class CreateDrugClassUseCase {
  final IDrugClassRepository _repository;

  CreateDrugClassUseCase(this._repository);

  Future<Result<void>> call(DrugClass entity) {
    return _repository.createDrugClass(entity);
  }
}
