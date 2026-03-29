// packages/pharmed_core/lib/src/role/domain/usecase/update_role_use_case.dart
//
// [SWREQ-CORE-ROLE-UC-003]
// Sınıf: Class B
// ─────────────────────────────────────────────────────────────────────────────

import 'package:pharmed_core/pharmed_core.dart';

class UpdateRoleUseCase {
  const UpdateRoleUseCase(this._repository);

  final IRoleRepository _repository;

  Future<Result<void>> call(Role role) => _repository.updateRole(role);
}
