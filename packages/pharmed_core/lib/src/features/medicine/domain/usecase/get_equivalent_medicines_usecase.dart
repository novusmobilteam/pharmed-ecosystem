import 'package:pharmed_data/pharmed_data.dart';

import '../../../../../pharmed_core.dart';

class GetEquivalentMedicinesUseCase {
  final IMedicineRepository _medicineRepository;

  GetEquivalentMedicinesUseCase(this._medicineRepository);

  Future<Result<ApiResponse<List<Medicine>>>> execute(int medicineId, {required PagedQueryParams params}) async {
    return await _medicineRepository.getEquivalentMedicines(medicineId, params: params);
  }
}
