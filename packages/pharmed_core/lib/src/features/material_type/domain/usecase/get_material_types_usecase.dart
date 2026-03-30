// [SWREQ-CORE-MATERIALTYPE-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetMaterialTypeParams {
  final int? skip;
  final int? take;
  final String? search;

  GetMaterialTypeParams({this.skip, this.take, this.search});
}

class GetMaterialTypesUseCase {
  final IMaterialTypeRepository _repository;
  GetMaterialTypesUseCase(this._repository);

  Future<Result<ApiResponse<List<MaterialType>>>> call(GetMaterialTypeParams params) {
    return _repository.getMaterialTypes(skip: params.skip, take: params.take, search: params.search);
  }
}
