// [SWREQ-CORE-STOCK-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class MobileUnloadParams {
  final int? prescriptionDetailId;

  MobileUnloadParams({this.prescriptionDetailId});

  Map<String, dynamic> toJson() {
    return {'prescriptionDetailId': prescriptionDetailId};
  }
}

class CompleteMobileUnloadUseCase {
  final IUnloadRepository _repository;

  CompleteMobileUnloadUseCase(this._repository);

  Future<Result<void>> call(List<MobileUnloadParams> params) {
    final data = params.map((p) => p.toJson()).toList();
    return _repository.mobileUnload(data);
  }
}
