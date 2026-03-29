// packages/pharmed_core/lib/src/role/domain/usecase/delete_role_use_case.dart
//
// [SWREQ-CORE-ROLE-UC-004]
// Sınıf: Class B
// ─────────────────────────────────────────────────────────────────────────────

import 'package:pharmed_core/pharmed_core.dart';

class DeleteRoleUseCase {
  const DeleteRoleUseCase(this._repository);

  final IRoleRepository _repository;

  Future<Result<void>> call(Role role) => _repository.deleteRole(role);
}
