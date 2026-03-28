import '../../../../core/core.dart';

import '../entity/medicine.dart';
import '../repository/i_medicine_repository.dart';

class GetDrugsParams {
  final int? skip;
  final int? take;
  final String? search;

  GetDrugsParams({this.skip, this.take, this.search});
}

class GetDrugsUseCase implements UseCase<ApiResponse<List<Medicine>>, GetDrugsParams> {
  final IMedicineRepository _repository;

  GetDrugsUseCase(this._repository);

  @override
  Future<Result<ApiResponse<List<Medicine>>>> call(GetDrugsParams params) {
    return _repository.getMedicines(skip: params.skip, take: params.take, search: params.search);
  }
}
