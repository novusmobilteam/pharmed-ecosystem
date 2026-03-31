import 'package:pharmed_core/pharmed_core.dart';

class WithdrawPatientMedicineUseCase {
  final IWithdrawRepository _repository;

  WithdrawPatientMedicineUseCase(this._repository);

  Future<Result<void>> call(int id) {
    return _repository.withdrawPatientMedicine(id: id);
  }
}
