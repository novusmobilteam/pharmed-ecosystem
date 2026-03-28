import '../../../../core/core.dart';

import '../repository/i_medicine_withdraw_repository.dart';

class WithdrawPatientMedicineUseCase extends UseCase<void, int> {
  final IMedicineWithdrawRepository _repository;

  WithdrawPatientMedicineUseCase(this._repository);

  @override
  Future<Result<void>> call(int id) {
    return _repository.withdrawPatientMedicine(id: id);
  }
}
