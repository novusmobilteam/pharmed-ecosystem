import '../../../../core/core.dart';

import '../entity/user_menu_authentication.dart';
import '../repository/i_user_authentication_repository.dart';

class SaveUserMenuAuthenticationUseCase extends UseCase<void, UserMenuAuthentication> {
  final IUserAuthenticationRepository _repository;
  SaveUserMenuAuthenticationUseCase(this._repository);

  @override
  Future<Result<void>> call(UserMenuAuthentication params) {
    return _repository.saveAuthentication(params);
  }
}
