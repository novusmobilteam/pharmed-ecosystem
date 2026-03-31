// [SWREQ-CORE-USER-UC-006]
// Sadece pharmed_manager tarafından kullanılır.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class UpdateUserUseCase {
  const UpdateUserUseCase(this._repository);

  final IUserManager _repository;

  Future<Result<void>> call(User user) => _repository.updateUser(user);
}
