// [SWREQ-CORE-STOCK-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetAuthorizationSummaryUseCase {
  final IReportRepository _repository;

  GetAuthorizationSummaryUseCase(this._repository);

  Future<Result<ApiResponse<List<UserAuthorizationSummary>>?>> call(PagedQueryParams params) => _repository
      .getAuthorizationSummary(params: params.copyWith(searchFields: ['userFullName', 'roleName', 'material.name']));
}

class GetUserAuthorizationSummaryUseCase {
  final IReportRepository _repository;

  GetUserAuthorizationSummaryUseCase(this._repository);

  Future<Result<UserAuthorizationDetail?>> call(int userId) => _repository.getUserAuthorizationSummary(userId);
}
