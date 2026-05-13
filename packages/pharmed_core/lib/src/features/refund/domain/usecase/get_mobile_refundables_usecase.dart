import 'package:pharmed_core/pharmed_core.dart';

class GetMobileRefundablesUseCase {
  final IRefundRepository _repository;

  GetMobileRefundablesUseCase(this._repository);

  Future<Result<List<PrescriptionItem>>> call(int hospitalizationId) async {
    return _repository.getMobileRefundables(hospitalizationId: hospitalizationId);
  }
}
