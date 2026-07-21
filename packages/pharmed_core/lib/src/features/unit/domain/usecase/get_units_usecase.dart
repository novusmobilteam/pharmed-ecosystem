// [SWREQ-CORE-UNIT-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetUnitsUseCase {
  final IUnitRepository _repository;
  GetUnitsUseCase(this._repository);

  Future<Result<ApiResponse<List<Unit>>>> call(PagedQueryParams params) {
    return _repository.getUnits(skip: params.skip, take: params.take, search: params.searchQuery);
  }
}
