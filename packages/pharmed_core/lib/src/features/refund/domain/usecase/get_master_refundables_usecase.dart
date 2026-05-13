import 'package:pharmed_core/pharmed_core.dart';

class GetMasterRefundablesUseCase {
  final IRefundRepository _repository;

  GetMasterRefundablesUseCase(this._repository);

  Future<Result<List<MedicineIntakeItem>>> call(int hospitalizationId) async {
    return _repository.getMasterRefundables(hospitalizationId: hospitalizationId);
  }
}
