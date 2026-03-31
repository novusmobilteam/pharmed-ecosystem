import 'package:pharmed_core/pharmed_core.dart';

class DefinePatientMedicineUseCase {
  final IWithdrawRepository _repository;

  DefinePatientMedicineUseCase(this._repository);

  Future<Result<void>> call(Map<String, dynamic> data) {
    return _repository.definePatientMedicine(data);
  }
}
