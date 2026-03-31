// [SWREQ-CORE-DRUGCLASS-UC-003]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class UpdateDrugClassUseCase {
  final IDrugClassRepository _repository;

  UpdateDrugClassUseCase(this._repository);

  Future<Result<void>> call(DrugClass entity) {
    return _repository.updateDrugClass(entity);
  }
}
