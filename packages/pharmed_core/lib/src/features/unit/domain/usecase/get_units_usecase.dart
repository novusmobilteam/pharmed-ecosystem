// [SWREQ-CORE-UNIT-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetUnitsParams {
  final int? skip;
  final int? take;
  final String? search;

  GetUnitsParams({this.skip, this.take, this.search});
}

class GetUnitsUseCase {
  final IUnitRepository _repository;
  GetUnitsUseCase(this._repository);

  Future<Result<ApiResponse<List<Unit>>>> call(GetUnitsParams params) {
    return _repository.getUnits(skip: params.skip, take: params.take, search: params.search);
  }
}
