import '../../../../core/core.dart';

import '../entity/unit.dart';
import '../repository/i_unit_repository.dart';

class GetUnitsParams {
  final int? skip;
  final int? take;
  final String? search;

  GetUnitsParams({this.skip, this.take, this.search});
}

class GetUnitsUseCase implements UseCase<ApiResponse<List<Unit>>, GetUnitsParams> {
  final IUnitRepository _repository;
  GetUnitsUseCase(this._repository);

  @override
  Future<Result<ApiResponse<List<Unit>>>> call(GetUnitsParams params) {
    return _repository.getUnits(skip: params.skip, take: params.take, search: params.search);
  }
}
