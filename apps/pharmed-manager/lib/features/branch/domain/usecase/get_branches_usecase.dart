import '../../../../core/core.dart';

import '../entity/branch.dart';
import '../repository/i_branch_repository.dart';

class GetBranchesParams {
  final int? skip;
  final int? take;
  final String? search;

  GetBranchesParams({this.skip, this.take, this.search});
}

class GetBranchesUseCase implements UseCase<ApiResponse<List<Branch>>, GetBranchesParams> {
  final IBranchRepository _repository;
  GetBranchesUseCase(this._repository);

  @override
  Future<Result<ApiResponse<List<Branch>>>> call(GetBranchesParams params) {
    return _repository.getBranches(skip: params.skip, take: params.take, search: params.search);
  }
}
