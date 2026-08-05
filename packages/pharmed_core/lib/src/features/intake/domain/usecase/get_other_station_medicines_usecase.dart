import 'package:pharmed_core/pharmed_core.dart';

class GetOtherStationMedicinesUseCase {
  const GetOtherStationMedicinesUseCase(this._repository);

  final IIntakeRepository _repository;

  Future<Result<List<OtherStationMedicine>>> call(int prescriptionDetailId) async {
    return await _repository.getOtherStationMedicines(prescriptionDetailId: prescriptionDetailId);
  }
}
