// [SWREQ-CORE-DRUGCLASS-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class DeleteDrugClassUseCase {
  final IDrugClassRepository _repository;

  DeleteDrugClassUseCase(this._repository);

  Future<Result<void>> call(DrugClass entity) {
    return _repository.deleteDrugClass(entity);
  }
}
