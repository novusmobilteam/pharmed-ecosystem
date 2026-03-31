// [SWREQ-CORE-MEDICINE-UC-005]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetMedicalConsumablesParams {
  final int? skip;
  final int? take;
  final String? search;

  GetMedicalConsumablesParams({this.skip, this.take, this.search});
}

class GetMedicalConsumablesUseCase {
  final IMedicineRepository _repository;

  GetMedicalConsumablesUseCase(this._repository);

  Future<Result<ApiResponse<List<Medicine>>>> call(GetMedicalConsumablesParams params) {
    return _repository.getMedicines(skip: params.skip, take: params.take, search: params.search);
  }
}
