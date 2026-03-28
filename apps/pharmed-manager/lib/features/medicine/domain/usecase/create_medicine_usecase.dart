import '../../../../core/core.dart';

import '../entity/medicine.dart';
import '../repository/i_medicine_repository.dart';

class CreateMedicineUseCase implements UseCase<void, Medicine> {
  final IMedicineRepository _repository;

  CreateMedicineUseCase(this._repository);

  @override
  Future<Result<void>> call(Medicine medicine) {
    return _repository.createMedicine(medicine);
  }
}
