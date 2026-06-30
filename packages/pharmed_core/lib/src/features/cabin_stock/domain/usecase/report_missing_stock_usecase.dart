import 'package:pharmed_core/pharmed_core.dart';

class ReportMissingStockUseCase {
  final ICabinStockRepository _repository;

  ReportMissingStockUseCase(this._repository);

  Future<Result<void>> call({required int prescriptionItemId, required CabinInventoryType type}) {
    return _repository.reportMissingStock(prescriptionItemId: prescriptionItemId, cabinInventoryTypeId: type.id);
  }
}
