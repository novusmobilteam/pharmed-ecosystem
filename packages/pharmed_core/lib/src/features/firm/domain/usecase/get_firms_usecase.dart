// [SWREQ-CORE-FIRM-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetFirmsUseCase {
  final IFirmRepository _repository;
  GetFirmsUseCase(this._repository);

  Future<Result<ApiResponse<List<Firm>>>> call(PagedQueryParams params) {
    return _repository.getFirms(skip: params.skip, take: params.take, searchQuery: params.searchQuery);
  }
}
