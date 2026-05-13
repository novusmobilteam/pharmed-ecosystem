import 'package:pharmed_core/pharmed_core.dart';

class CompleteMobileRefundUseCase {
  final IRefundRepository _repository;

  CompleteMobileRefundUseCase(this._repository);

  Future<Result<void>> call({required int prescriptionItemId, required double quantity}) async {
    return _repository.refundMobile(id: prescriptionItemId, quantity: quantity);
  }
}
