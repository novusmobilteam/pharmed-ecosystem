import 'package:flutter/foundation.dart';

import '../../../../../../../core/core.dart';

import '../../../cabin/domain/entity/cabin_input_data.dart';
import '../../domain/usecase/refill_medicine_usecase.dart';

class MedicineRefillNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<CabinAssignment> {
  final RefillMedicineUseCase _refillMedicineUseCase;

  MedicineRefillNotifier({required RefillMedicineUseCase refillMedicineUseCase})
    : _refillMedicineUseCase = refillMedicineUseCase;

  Future<Result<void>> fillCabin(List<CabinInputData> inputs) async {
    // 1. Mapping: InputData -> StandardFillingRequest
    final data = inputs.map((e) {
      return RefillMedicineParams(
        cabinDrawerDetailId: e.cabinDrawerDetailId ?? 0,
        quantity: e.quantity,
        countQuantity: e.censusQuantity,
        miadDate: e.miadDate,
        materialId: e.materialId,
        shelfNo: e.shelfNo ?? 0,
        compartmentNo: e.compartmentNo ?? 0,
      );
    }).toList();

    return await _refillMedicineUseCase.call(data);
  }
}
