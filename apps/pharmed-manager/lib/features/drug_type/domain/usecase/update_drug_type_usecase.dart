import '../../../../core/core.dart';

import '../entity/drug_type.dart';
import '../repository/i_drug_type_repository.dart';

class UpdateDrugTypeUseCase extends UseCase<void, DrugType> {
  final IDrugTypeRepository _repository;

  UpdateDrugTypeUseCase(this._repository);

  @override
  Future<Result<void>> call(DrugType entity) {
    return _repository.updateDrugType(entity);
  }
}
