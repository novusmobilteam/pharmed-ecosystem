import '../../../../core/core.dart';

import '../entity/role.dart';
import '../repository/i_role_repository.dart';

class GetRolesParams {
  final int? skip;
  final int? take;
  final String? search;

  GetRolesParams({this.skip, this.take, this.search});
}

class GetRolesUseCase extends UseCase<ApiResponse<List<Role>>, GetRolesParams> {
  final IRoleRepository _repository;

  GetRolesUseCase(this._repository);

  @override
  Future<Result<ApiResponse<List<Role>>>> call(GetRolesParams params) {
    return _repository.getRoles(skip: params.skip, take: params.take, search: params.search);
  }
}
