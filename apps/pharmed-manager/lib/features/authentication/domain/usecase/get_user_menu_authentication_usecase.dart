import '../../../../core/core.dart';

import '../entity/user_menu_authentication.dart';
import '../repository/i_user_authentication_repository.dart';

class GetUserMenuAuthenticationUseCase extends UseCase<UserMenuAuthentication, User> {
  final IUserAuthenticationRepository _repository;
  GetUserMenuAuthenticationUseCase(this._repository);

  @override
  Future<Result<UserMenuAuthentication>> call(User params) {
    return _repository.getAuthentication(params);
  }
}
