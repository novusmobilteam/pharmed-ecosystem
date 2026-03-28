import '../../../../core/core.dart';

import '../repository/i_medicine_withdraw_repository.dart';

class DefinePatientMedicineUseCase extends UseCase<void, Map<String, dynamic>> {
  final IMedicineWithdrawRepository _repository;

  DefinePatientMedicineUseCase(this._repository);

  @override
  Future<Result<void>> call(Map<String, dynamic> data) {
    return _repository.definePatientMedicine(data);
  }
}
