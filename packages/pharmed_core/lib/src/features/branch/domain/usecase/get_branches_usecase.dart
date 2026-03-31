// [SWREQ-CORE-BRANCH-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetBranchesParams {
  const GetBranchesParams({this.skip, this.take, this.search});

  final int? skip;
  final int? take;
  final String? search;
}

class GetBranchesUseCase {
  const GetBranchesUseCase(this._repository);

  final IBranchRepository _repository;

  Future<Result<ApiResponse<List<Branch>>>> call(GetBranchesParams params) =>
      _repository.getBranches(skip: params.skip, take: params.take, search: params.search);
}
