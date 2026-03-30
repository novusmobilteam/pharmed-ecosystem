// [SWREQ-CORE-DRUGTYPE-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class DeleteDrugTypeUseCase {
  final IDrugTypeRepository _repository;

  DeleteDrugTypeUseCase(this._repository);

  Future<Result<void>> call(DrugType entity) {
    return _repository.deleteDrugType(entity);
  }
}
