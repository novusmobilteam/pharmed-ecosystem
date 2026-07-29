import 'package:pharmed_core/pharmed_core.dart';

class GetMasterRefundablesUseCase {
  final IRefundRepository _repository;

  GetMasterRefundablesUseCase(this._repository);

  Future<Result<List<CabinTargetedPrescriptionItem>>> call(int hospitalizationId) =>
      _repository.getMasterRefundables(hospitalizationId: hospitalizationId);
}
