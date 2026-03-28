import '../../../../core/core.dart';

import '../repository/i_medicine_refund_repository.dart';

class CompletePharmacyRefundUseCase implements UseCase<void, int> {
  final IMedicineRefundRepository _repository;

  CompletePharmacyRefundUseCase(this._repository);

  @override
  Future<Result<void>> call(int id) async {
    return _repository.completePharmacyRefund(id);
  }
}
