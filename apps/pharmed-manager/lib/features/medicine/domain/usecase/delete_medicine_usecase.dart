import '../../../../core/core.dart';

import '../entity/medicine.dart';
import '../repository/i_medicine_repository.dart';

class DeleteMedicineUseCase implements UseCase<void, Medicine> {
  final IMedicineRepository _repository;

  DeleteMedicineUseCase(this._repository);

  @override
  Future<Result<void>> call(Medicine medicine) {
    return _repository.deleteMedicine(medicine);
  }
}
