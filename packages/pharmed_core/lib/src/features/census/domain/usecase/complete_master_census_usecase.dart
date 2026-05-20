// [SWREQ-CORE-STOCK-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class MasterCensusParams {
  final int materialId;
  final int cabinDrawerDetailId;
  final double countQuantity;
  final DateTime? miadDate;
  final int shelfNo;
  final int compartmentNo;

  MasterCensusParams(
    this.materialId,
    this.cabinDrawerDetailId,
    this.countQuantity,
    this.miadDate,
    this.shelfNo,
    this.compartmentNo,
  );

  Map<String, dynamic> toJson() {
    return {
      "materialId": materialId,
      "cabinDrawrDetailId": cabinDrawerDetailId,
      "censusQuantity": countQuantity,
      "miadDate": miadDate?.toIso8601String(),
      "shelfNo": shelfNo,
      "corpartmentNo": compartmentNo,
    };
  }
}

class CompleteMasterCensusUseCase {
  final ICensusRepository _repository;

  CompleteMasterCensusUseCase(this._repository);

  Future<Result<void>> call(List<MasterCensusParams> params) {
    return _repository.masterCensus(params);
  }
}
