import 'package:pharmed_core/pharmed_core.dart';

class ReportMissingStockUseCase {
  final IIntakeRepository _repository;

  ReportMissingStockUseCase(this._repository);

  Future<Result<void>> call(int prescriptionItemId) {
    return _repository.reportMissingStock(prescriptionItemId);
  }
}
