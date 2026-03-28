import '../../../../core/core.dart';

import '../entity/medicine.dart';
import '../repository/i_medicine_repository.dart';

class GetDrugUseCase implements UseCase<Drug?, int> {
  final IMedicineRepository _repository;

  GetDrugUseCase(this._repository);

  @override
  Future<Result<Drug?>> call(int id) {
    return _repository.getDrug(id);
  }
}
