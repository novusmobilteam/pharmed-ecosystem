// [SWREQ-CORE-STOCK-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class UnloadReportMissingStockUseCase {
  final IUnloadRepository _repository;

  UnloadReportMissingStockUseCase(this._repository);

  Future<Result<void>> call(int prescriptionItemId) {
    return _repository.reportMissingStock(prescriptionItemId);
  }
}
