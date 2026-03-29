// packages/pharmed_core/lib/src/user/domain/usecase/get_current_user_use_case.dart
//
// [SWREQ-CORE-USER-UC-001]
// Her iki app tarafından kullanılır.
// IUserReader bağımlılığı — client ve manager için aynı.
// Sınıf: Class B
// ─────────────────────────────────────────────────────────────────────────────

import 'package:pharmed_core/pharmed_core.dart';

class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);

  final IUserReader _repository;

  Future<Result<User?>> call() => _repository.getCurrentUser();
}
