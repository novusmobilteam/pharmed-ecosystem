import '../../../../core/core.dart';

import '../entity/refund.dart';
import '../repository/i_medicine_refund_repository.dart';

class GetCompletedPharmacyRefundsUseCase implements NoParamsUseCase<List<Refund>> {
  final IMedicineRefundRepository _repository;

  GetCompletedPharmacyRefundsUseCase(this._repository);

  @override
  Future<Result<List<Refund>>> call() async {
    return _repository.getCompletedPharmacyRefunds();
  }
}
