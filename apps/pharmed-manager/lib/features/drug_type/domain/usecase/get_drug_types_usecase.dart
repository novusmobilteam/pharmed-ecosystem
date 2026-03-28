import '../../../../core/core.dart';

import '../entity/drug_type.dart';
import '../repository/i_drug_type_repository.dart';

class GetDrugTypesParams {
  final int? skip;
  final int? take;
  final String? search;

  GetDrugTypesParams({this.skip, this.take, this.search});
}

class GetDrugTypesUseCase implements UseCase<ApiResponse<List<DrugType>>, GetDrugTypesParams> {
  final IDrugTypeRepository _repository;

  GetDrugTypesUseCase(this._repository);

  @override
  Future<Result<ApiResponse<List<DrugType>>>> call(GetDrugTypesParams params) async {
    return _repository.getDrugTypes(skip: params.skip, take: params.take, search: params.search);
  }
}
