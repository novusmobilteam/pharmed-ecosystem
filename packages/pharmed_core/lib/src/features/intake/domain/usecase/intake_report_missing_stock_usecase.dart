import 'package:pharmed_core/pharmed_core.dart';

class IntakeReportMissingStockUseCase {
  final IIntakeRepository _repository;

  IntakeReportMissingStockUseCase(this._repository);

  Future<Result<void>> call(int prescriptionItemId) {
    return _repository.reportMissingStock(prescriptionItemId);
  }
}
