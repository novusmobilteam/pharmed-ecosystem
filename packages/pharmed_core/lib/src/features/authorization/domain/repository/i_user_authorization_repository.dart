import 'package:pharmed_core/pharmed_core.dart';

abstract class IUserAuthorizationRepository {
  Future<Result<UserMenuAuthorization>> getAuthorization(User user);
  Future<Result<void>> saveAuthorization(UserMenuAuthorization auth);
}
