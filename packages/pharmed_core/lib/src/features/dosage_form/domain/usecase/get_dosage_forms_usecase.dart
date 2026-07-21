// [SWREQ-CORE-DOSAGE-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetDosageFormsUseCase {
  final IDosageFormRepository _repository;

  GetDosageFormsUseCase(this._repository);

  Future<Result<ApiResponse<List<DosageForm>>>> call(PagedQueryParams params) {
    return _repository.getDosageForms(skip: params.skip, take: params.take, search: params.searchQuery);
  }
}
