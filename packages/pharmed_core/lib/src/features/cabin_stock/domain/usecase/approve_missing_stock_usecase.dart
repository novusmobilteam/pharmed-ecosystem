import 'package:pharmed_core/pharmed_core.dart';

class ApproveMissingStockUseCase {
  final ICabinStockRepository _repository;

  ApproveMissingStockUseCase(this._repository);

  Future<Result<void>> call(int prescriptionItemId) {
    return _repository.approveMissingStock(prescriptionItemId);
  }
}
