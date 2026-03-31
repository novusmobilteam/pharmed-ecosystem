// [SWREQ-CORE-DRUGCLASS-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetDrugClassParams {
  final int? skip;
  final int? take;
  final String? search;

  GetDrugClassParams({this.skip, this.take, this.search});
}

class GetDrugClassUseCase {
  final IDrugClassRepository _repository;

  GetDrugClassUseCase(this._repository);

  Future<Result<ApiResponse<List<DrugClass>>>> call(GetDrugClassParams params) async {
    return _repository.getDrugClasses(skip: params.skip, take: params.take, search: params.search);
  }
}
