// [SWREQ-CORE-MEDICINE-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetDrugsParams {
  final int? skip;
  final int? take;
  final String? search;

  GetDrugsParams({this.skip, this.take, this.search});
}

class GetDrugsUseCase {
  final IMedicineRepository _repository;

  GetDrugsUseCase(this._repository);

  Future<Result<ApiResponse<List<Medicine>>>> call(GetDrugsParams params) {
    return _repository.getMedicines(skip: params.skip, take: params.take, search: params.search);
  }
}
