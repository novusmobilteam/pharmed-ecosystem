import 'package:pharmed_core/pharmed_core.dart';

class RefillMobileCabinParams {
  final int prescriptionDetailId;
  final String? epc;

  RefillMobileCabinParams({required this.prescriptionDetailId, this.epc});

  Map<String, dynamic> toJson() {
    return {'prescriptionDetailId': prescriptionDetailId, 'rfidCardTag': epc ?? null};
  }
}

class RefillMobileCabinUseCase {
  final ICabinStockRepository _repository;

  RefillMobileCabinUseCase(this._repository);

  Future<Result<void>> call(List<RefillMobileCabinParams> params) async {
    return await _repository.refillMobileCabin(params);
  }
}
