import '../../../../core/core.dart';

import '../entity/drug_class.dart';
import '../repository/i_drug_class_repository.dart';

class UpdateDrugClassUseCase extends UseCase<void, DrugClass> {
  final IDrugClassRepository _repository;

  UpdateDrugClassUseCase(this._repository);

  @override
  Future<Result<void>> call(DrugClass entity) {
    return _repository.updateDrugClass(entity);
  }
}
