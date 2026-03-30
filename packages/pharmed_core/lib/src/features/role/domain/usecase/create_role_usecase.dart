// [SWREQ-CORE-ROLE-UC-002]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class CreateRoleUseCase {
  const CreateRoleUseCase(this._repository);

  final IRoleRepository _repository;

  Future<Result<void>> call(Role role) => _repository.createRole(role);
}
