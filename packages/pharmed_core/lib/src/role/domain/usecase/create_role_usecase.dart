// packages/pharmed_core/lib/src/role/domain/usecase/create_role_use_case.dart
//
// [SWREQ-CORE-ROLE-UC-002]
// Sınıf: Class B
// ─────────────────────────────────────────────────────────────────────────────

import 'package:pharmed_core/pharmed_core.dart';

class CreateRoleUseCase {
  const CreateRoleUseCase(this._repository);

  final IRoleRepository _repository;

  Future<Result<void>> call(Role role) => _repository.createRole(role);
}
