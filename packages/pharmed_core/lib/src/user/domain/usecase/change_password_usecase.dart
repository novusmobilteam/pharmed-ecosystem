// packages/pharmed_core/lib/src/user/domain/usecase/change_password_use_case.dart
//
// [SWREQ-CORE-USER-UC-002]
// Her iki app tarafından kullanılır.
// IUserManager bağımlılığı — changePassword IUserReader'da yok.
// Sınıf: Class B
// ─────────────────────────────────────────────────────────────────────────────

import 'package:pharmed_core/pharmed_core.dart';

class ChangePasswordParams {
  const ChangePasswordParams({required this.currentPassword, required this.newPassword});

  final String currentPassword;
  final String newPassword;
}

class ChangePasswordUseCase {
  const ChangePasswordUseCase(this._repository);

  final IUserManager _repository;

  Future<Result<void>> call(ChangePasswordParams params) =>
      _repository.changePassword(currentPassword: params.currentPassword, newPassword: params.newPassword);
}
