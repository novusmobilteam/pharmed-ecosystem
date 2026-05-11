import 'package:pharmed_core/pharmed_core.dart';

class GetRefundablesUseCase {
  final IRefundRepository _repository;

  GetRefundablesUseCase(this._repository);

  Future<Result<List<MedicineIntakeItem>>> call(int hospitalizationId) async {
    return _repository.getRefundables(hospitalizationId: hospitalizationId);
  }
}
