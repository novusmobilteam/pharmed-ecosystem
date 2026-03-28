import '../../../../core/core.dart';

import '../entity/material_type.dart';
import '../repository/i_material_type_repository.dart';

class GetMaterialTypeParams {
  final int? skip;
  final int? take;
  final String? search;

  GetMaterialTypeParams({this.skip, this.take, this.search});
}

class GetMaterialTypesUseCase implements UseCase<ApiResponse<List<MaterialType>>, GetMaterialTypeParams> {
  final IMaterialTypeRepository _repository;
  GetMaterialTypesUseCase(this._repository);

  @override
  Future<Result<ApiResponse<List<MaterialType>>>> call(GetMaterialTypeParams params) {
    return _repository.getMaterialTypes(skip: params.skip, take: params.take, search: params.search);
  }
}
