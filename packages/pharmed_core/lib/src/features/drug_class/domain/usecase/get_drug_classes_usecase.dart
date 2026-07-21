// [SWREQ-CORE-DRUGCLASS-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetDrugClassUseCase {
  GetDrugClassUseCase(this._repository);

  final IDrugClassRepository _repository;

  Future<Result<ApiResponse<List<DrugClass>>>> call(PagedQueryParams params) async {
    return _repository.getDrugClasses(skip: params.skip, take: params.take, search: params.searchQuery);
  }
}
