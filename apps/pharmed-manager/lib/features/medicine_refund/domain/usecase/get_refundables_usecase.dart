import '../../../../core/core.dart';

import '../../../medicine_withdraw/domain/entity/medicine_withdraw_item.dart';
import '../repository/i_medicine_refund_repository.dart';

class GetRefundablesUseCase implements UseCase<List<MedicineWithdrawItem>, int> {
  final IMedicineRefundRepository _repository;

  GetRefundablesUseCase(this._repository);

  @override
  Future<Result<List<MedicineWithdrawItem>>> call(int hospitalizationId) async {
    return _repository.getRefundables(hospitalizationId: hospitalizationId);
  }
}
