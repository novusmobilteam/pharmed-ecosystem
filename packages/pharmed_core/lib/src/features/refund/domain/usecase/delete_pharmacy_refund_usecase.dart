import 'package:pharmed_core/pharmed_core.dart';

class DeletePharmacyRefundParams {
  final int id;
  final String? description;

  DeletePharmacyRefundParams({required this.id, this.description});
}

class DeletePharmacyRefundUseCase {
  final IRefundRepository _repository;

  DeletePharmacyRefundUseCase(this._repository);

  Future<Result<void>> call(DeletePharmacyRefundParams params) async {
    return _repository.deletePharmacyRefund(params.id, params.description);
  }
}
