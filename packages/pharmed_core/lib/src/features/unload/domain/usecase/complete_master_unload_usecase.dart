// [SWREQ-CORE-STOCK-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class CompleteMasterUnloadUseCase {
  final IUnloadRepository _repository;

  CompleteMasterUnloadUseCase(this._repository);

  Future<Result<void>> call(List<CabinOperationMedicineParams> params) {
    final data = params.map((p) => p.toJson()).toList();
    return _repository.masterUnload(data);
  }
}
