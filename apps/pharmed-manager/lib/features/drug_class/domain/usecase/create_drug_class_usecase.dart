import '../../../../core/core.dart';

import '../entity/drug_class.dart';
import '../repository/i_drug_class_repository.dart';

class CreateDrugClassUseCase extends UseCase<void, DrugClass> {
  final IDrugClassRepository _repository;

  CreateDrugClassUseCase(this._repository);

  @override
  Future<Result<void>> call(DrugClass entity) {
    return _repository.createDrugClass(entity);
  }
}
