import '../../../../core/core.dart';

import '../entity/dosage_form.dart';
import '../repository/i_dosage_form_repository.dart';

class GetDosageFormParams {
  final int? skip;
  final int? take;
  final String? search;

  GetDosageFormParams({this.skip, this.take, this.search});
}

class GetDosageFormsUseCase implements UseCase<ApiResponse<List<DosageForm>>, GetDosageFormParams> {
  final IDosageFormRepository _repository;
  GetDosageFormsUseCase(this._repository);

  @override
  Future<Result<ApiResponse<List<DosageForm>>>> call(GetDosageFormParams params) {
    return _repository.getDosageForms(skip: params.skip, take: params.take, search: params.search);
  }
}
