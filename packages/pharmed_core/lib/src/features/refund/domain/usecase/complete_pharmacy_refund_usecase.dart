import 'package:pharmed_core/pharmed_core.dart';

class CompletePharmacyRefundUseCase {
  final IRefundRepository _repository;

  CompletePharmacyRefundUseCase(this._repository);

  Future<Result<void>> call(int id) async {
    return _repository.completePharmacyRefund(id);
  }
}
