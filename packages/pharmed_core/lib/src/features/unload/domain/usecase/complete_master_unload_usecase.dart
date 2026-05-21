// [SWREQ-CORE-STOCK-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class UnloadMasterParams {
  final int materialId;
  final int cabinDrawerDetailId;
  final double countQuantity;
  final double quantity;
  final DateTime? miadDate;
  final int shelfNo;
  final int compartmentNo;

  UnloadMasterParams({
    required this.materialId,
    required this.cabinDrawerDetailId,
    required this.countQuantity,
    required this.quantity,
    required this.miadDate,
    required this.shelfNo,
    required this.compartmentNo,
  });

  Map<String, dynamic> toJson() {
    return {
      "materialId": materialId,
      "cabinDrawrDetailId": cabinDrawerDetailId,
      "censusQuantity": countQuantity,
      "quantity": quantity,
      "miadDate": miadDate?.toIso8601String(),
      "shelfNo": shelfNo,
      "corpartmentNo": compartmentNo,
    };
  }
}

class CompleteMasterUnloadUseCase {
  final IUnloadRepository _repository;

  CompleteMasterUnloadUseCase(this._repository);

  Future<Result<void>> call(List<UnloadMasterParams> params) {
    final data = params.map((p) => p.toJson()).toList();
    return _repository.masterUnload(data);
  }
}
