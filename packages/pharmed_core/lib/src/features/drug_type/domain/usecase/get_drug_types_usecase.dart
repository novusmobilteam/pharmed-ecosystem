// [SWREQ-CORE-DRUGTYPE-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetDrugTypesParams {
  final int? skip;
  final int? take;
  final String? search;

  GetDrugTypesParams({this.skip, this.take, this.search});
}

class GetDrugTypesUseCase {
  final IDrugTypeRepository _repository;

  GetDrugTypesUseCase(this._repository);

  Future<Result<ApiResponse<List<DrugType>>>> call(GetDrugTypesParams params) async {
    return _repository.getDrugTypes(skip: params.skip, take: params.take, search: params.search);
  }
}
