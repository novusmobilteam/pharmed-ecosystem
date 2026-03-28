import '../../../../core/core.dart';

import '../repository/i_medicine_refund_repository.dart';

class DeletePharmacyRefundParams {
  final int id;
  final String? description;

  DeletePharmacyRefundParams({required this.id, this.description});
}

class DeletePharmacyRefundUseCase implements UseCase<void, DeletePharmacyRefundParams> {
  final IMedicineRefundRepository _repository;

  DeletePharmacyRefundUseCase(this._repository);

  @override
  Future<Result<void>> call(DeletePharmacyRefundParams params) async {
    return _repository.deletePharmacyRefund(params.id, params.description);
  }
}
