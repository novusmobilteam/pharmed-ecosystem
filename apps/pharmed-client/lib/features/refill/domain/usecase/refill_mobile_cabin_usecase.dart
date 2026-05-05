import 'package:pharmed_core/pharmed_core.dart';

class RefillMobileCabinParams {
  final int prescriptionDetailId;
  final String epc;

  RefillMobileCabinParams({required this.prescriptionDetailId, required this.epc});

  Map<String, dynamic> toJson() {
    return {'prescriptionDetailId': prescriptionDetailId, 'rfidCardTag': epc};
  }
}

class RefillMobileCabinUseCase {
  final ICabinStockRepository _repository;

  RefillMobileCabinUseCase(this._repository);

  Future<Result<void>> call(List<RefillMobileCabinParams> params) async {
    final body = params.map((p) => p.toJson()).toList();
    return await _repository.refillMobileCabin(body);
  }
}
