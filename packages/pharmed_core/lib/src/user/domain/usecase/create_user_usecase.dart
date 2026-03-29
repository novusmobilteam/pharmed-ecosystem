// packages/pharmed_core/lib/src/user/domain/usecase/create_user_use_case.dart
//
// [SWREQ-CORE-USER-UC-005]
// Sadece pharmed_manager tarafından kullanılır.
// Sınıf: Class B
// ─────────────────────────────────────────────────────────────────────────────

import 'package:pharmed_core/pharmed_core.dart';

class CreateUserUseCase {
  const CreateUserUseCase(this._repository);

  final IUserManager _repository;

  Future<Result<void>> call(User user) => _repository.createUser(user);
}
