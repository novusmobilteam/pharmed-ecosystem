// [SWREQ-CORE-STOCK-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class MobileCensusParams {
  final int? prescriptionDetailId;
  final int? userId;
  final double? dosePiece;
  final String? epc;

  MobileCensusParams({this.prescriptionDetailId, this.userId, this.dosePiece, this.epc});

  Map<String, dynamic> toJson() {
    return {'prescriptionDetailId': prescriptionDetailId};
  }
}

class CompleteMobileCensusUseCase {
  final ICensusRepository _repository;

  CompleteMobileCensusUseCase(this._repository);

  Future<Result<void>> call(List<MobileCensusParams> params) {
    final data = params.map((p) => p.toJson()).toList();
    return _repository.mobileCensus(data);
  }
}
