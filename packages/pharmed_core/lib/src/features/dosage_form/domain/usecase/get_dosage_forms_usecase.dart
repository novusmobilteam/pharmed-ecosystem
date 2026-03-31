// [SWREQ-CORE-DOSAGE-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetDosageFormParams {
  final int? skip;
  final int? take;
  final String? search;

  GetDosageFormParams({this.skip, this.take, this.search});
}

class GetDosageFormsUseCase {
  final IDosageFormRepository _repository;
  GetDosageFormsUseCase(this._repository);

  Future<Result<ApiResponse<List<DosageForm>>>> call(GetDosageFormParams params) {
    return _repository.getDosageForms(skip: params.skip, take: params.take, search: params.search);
  }
}
