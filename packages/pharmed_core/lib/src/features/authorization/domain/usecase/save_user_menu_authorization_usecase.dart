import 'package:pharmed_core/pharmed_core.dart';

class SaveUserMenuAuthorizationUseCase {
  final IUserAuthorizationRepository _repository;
  SaveUserMenuAuthorizationUseCase(this._repository);

  Future<Result<void>> call(UserMenuAuthorization params) {
    return _repository.saveAuthorization(params);
  }
}
