import 'package:pharmed_core/pharmed_core.dart';

class GetUserMenuAuthorizationUseCase {
  final IUserAuthorizationRepository _repository;

  GetUserMenuAuthorizationUseCase(this._repository);

  Future<Result<UserMenuAuthorization>> call(User params) {
    return _repository.getAuthorization(params);
  }
}
