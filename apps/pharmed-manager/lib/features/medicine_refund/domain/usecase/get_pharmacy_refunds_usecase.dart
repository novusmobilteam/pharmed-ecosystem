import '../../../../core/core.dart';

import '../entity/refund.dart';
import '../repository/i_medicine_refund_repository.dart';

class GetPharmacyRefundsUseCase implements NoParamsUseCase<List<Refund>> {
  final IMedicineRefundRepository _repository;

  GetPharmacyRefundsUseCase(this._repository);

  @override
  Future<Result<List<Refund>>> call() async {
    return _repository.getPharmacyRefunds();
  }
}
