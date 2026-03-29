// packages/pharmed_core/lib/src/role/domain/usecase/get_roles_use_case.dart
//
// [SWREQ-CORE-ROLE-UC-001]
// Sınıf: Class B
// ─────────────────────────────────────────────────────────────────────────────

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetRolesParams {
  const GetRolesParams({this.skip, this.take, this.search});

  final int? skip;
  final int? take;
  final String? search;
}

class GetRolesUseCase {
  const GetRolesUseCase(this._repository);

  final IRoleRepository _repository;

  Future<Result<ApiResponse<List<Role>>>> call(GetRolesParams params) =>
      _repository.getRoles(skip: params.skip, take: params.take, search: params.search);
}
