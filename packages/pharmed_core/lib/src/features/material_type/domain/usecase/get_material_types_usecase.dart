// [SWREQ-CORE-MATERIALTYPE-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetMaterialTypesUseCase {
  final IMaterialTypeRepository _repository;
  GetMaterialTypesUseCase(this._repository);

  Future<Result<ApiResponse<List<MaterialType>>>> call(PagedQueryParams params) {
    return _repository.getMaterialTypes(skip: params.skip, take: params.take, search: params.searchQuery);
  }
}
