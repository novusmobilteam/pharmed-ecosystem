import 'package:pharmed_core/pharmed_core.dart';

class ReportExcessStockUseCase {
  final ICabinStockRepository _repository;

  ReportExcessStockUseCase(this._repository);

  Future<Result<void>> call({required int prescriptionItemId, required CabinInventoryType type}) {
    return _repository.reportExcessStock(prescriptionItemId: prescriptionItemId, cabinInventoryTypeId: type.id);
  }
}
