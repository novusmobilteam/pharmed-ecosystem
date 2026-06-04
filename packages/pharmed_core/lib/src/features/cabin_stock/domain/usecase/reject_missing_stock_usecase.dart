import 'package:pharmed_core/pharmed_core.dart';

class RejectMissingStockUseCase {
  final ICabinStockRepository _repository;

  RejectMissingStockUseCase(this._repository);

  Future<Result<void>> call(int prescriptionItemId) {
    return _repository.rejectMissingStock(prescriptionItemId);
  }
}
