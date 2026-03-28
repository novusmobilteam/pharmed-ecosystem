import '../../../../core/core.dart';

import '../entity/drug_class.dart';
import '../repository/i_drug_class_repository.dart';

class GetDrugClassParams {
  final int? skip;
  final int? take;
  final String? search;

  GetDrugClassParams({this.skip, this.take, this.search});
}

class GetDrugClassUseCase implements UseCase<ApiResponse<List<DrugClass>>, GetDrugClassParams> {
  final IDrugClassRepository _repository;

  GetDrugClassUseCase(this._repository);

  @override
  Future<Result<ApiResponse<List<DrugClass>>>> call(GetDrugClassParams params) async {
    return _repository.getDrugClasses(skip: params.skip, take: params.take, search: params.search);
  }
}
