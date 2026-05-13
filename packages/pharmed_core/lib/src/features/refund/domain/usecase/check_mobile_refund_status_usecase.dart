import 'package:pharmed_core/pharmed_core.dart';

class CheckMobileRefundStatusUseCase {
  final IRefundRepository _repository;

  CheckMobileRefundStatusUseCase(this._repository);

  Future<Result<void>> call({required int prescriptionItemId, required double quantity}) async {
    return _repository.checkMobileRefundStatus(id: prescriptionItemId, quantity: quantity);
  }
}
