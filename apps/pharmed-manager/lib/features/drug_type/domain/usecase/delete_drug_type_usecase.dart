import '../../../../core/core.dart';

import '../entity/drug_type.dart';
import '../repository/i_drug_type_repository.dart';

class DeleteDrugTypeUseCase extends UseCase<void, DrugType> {
  final IDrugTypeRepository _repository;

  DeleteDrugTypeUseCase(this._repository);

  @override
  Future<Result<void>> call(DrugType entity) {
    return _repository.deleteDrugType(entity);
  }
}
