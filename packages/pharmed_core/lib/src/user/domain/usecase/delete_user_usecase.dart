// packages/pharmed_core/lib/src/user/domain/usecase/delete_user_use_case.dart
//
// [SWREQ-CORE-USER-UC-007]
// Sadece pharmed_manager tarafından kullanılır.
// Sınıf: Class B
// ─────────────────────────────────────────────────────────────────────────────

import 'package:pharmed_core/pharmed_core.dart';

class DeleteUserUseCase {
  const DeleteUserUseCase(this._repository);

  final IUserManager _repository;

  Future<Result<void>> call(int id) => _repository.deleteUser(id);
}
